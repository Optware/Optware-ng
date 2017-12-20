###########################################################
#
# perl
#
###########################################################

PERL_CROSS_VERSION=1.1.8
PERL_CROSS_SITE=https://raw.github.com/arsv/perl-cross/releases
PERL_CROSS_SOURCE=perl-cross-$(PERL_CROSS_VERSION).tar.gz
PERL_CROSS_UNZIP=zcat

$(DL_DIR)/$(PERL_CROSS_SOURCE):
	$(WGET) -P $(@D) $(PERL_CROSS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_CROSS_NLO_SITE)/$(@F)

perl-source: $(DL_DIR)/$(PERL_CROSS_SOURCE)

#
# PERL_CONFFILES should be a list of user-editable files
#PERL_CONFFILES=$(TARGET_PREFIX)/etc/perl.conf $(TARGET_PREFIX)/etc/init.d/SXXperl
 
#
# PERL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PERL_PATCHES=#

PERL_CROSS_PATCHES=\
$(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/dynamic_ext.fix.patch \

#PERL_POST_CONFIGURE_PATCHES=$(PERL_SOURCE_DIR)/Makefile-pp_hot.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL_CPPFLAGS=-pthread
PERL_ARCH = $(strip \
    $(if $(filter buildroot-armeabi-ng buildroot-armeabihf, $(OPTWARE_TARGET)), armv7l-linux, \
    $(if $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)), mips-linux, \
    $(if $(filter armeb, $(TARGET_ARCH)), armv5b-linux, \
    $(TARGET_ARCH)-linux))))
PERL_LIB_CORE_DIR=perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE
PERL_LDFLAGS=-pthread -Wl,-rpath,$(TARGET_PREFIX)/lib/$(PERL_LIB_CORE_DIR)

PERL_MODULES_CFLAGS = -pthread -fwrapv -fno-strict-aliasing -fstack-protector-strong -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
PERL_MODULES_LDFLAGS = -pthread -fstack-protector-strong

PERL_LIBS=-lm

#
# PERL_BUILD_DIR is the directory in which the build is done.
# PERL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PERL_IPK_DIR is the directory in which the ipk is built.
# PERL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PERL_BUILD_DIR=$(BUILD_DIR)/perl

PERL_HOST_BUILD_DIR=$(BUILD_DIR)/perl-host
PERL_HOST_MINIPERL=$(PERL_HOST_BUILD_DIR)/miniperl
PERL_HOSTPERL=$(PERL_HOST_BUILD_DIR)/perl
PERL_INC=PERL_INC=$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)

PERL_SOURCE_DIR=$(SOURCE_DIR)/perl

PERL_ERRNO_H_DIR ?= $(TARGET_INCDIR)

ifdef EXACT_TARGET_NAME
PERL_TARGET_NAME=$(EXACT_TARGET_NAME)
else
PERL_TARGET_NAME=$(GNU_TARGET_NAME)
endif

PERL_IPK_DIR=$(BUILD_DIR)/perl-$(PERL_VERSION)-ipk
PERL_IPK=$(BUILD_DIR)/perl_$(PERL_VERSION)-$(PERL_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-DOC_IPK_DIR=$(BUILD_DIR)/perl-doc-$(PERL_VERSION)-ipk
PERL-DOC_IPK=$(BUILD_DIR)/perl-doc_$(PERL_VERSION)-$(PERL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-source perl-unpack perl perl-stage perl-ipk perl-clean perl-dirclean perl-check perl-hostperl

$(PERL_HOST_BUILD_DIR)/.hostbuilt: $(DL_DIR)/$(PERL_SOURCE) # make/perl.mk
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(@D)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL_DIR) $(@D) ; \
	(cd $(@D); \
		rm -f config.sh Policy.sh; \
		sh ./Configure -des \
			-Dinstallstyle='lib/perl5' \
			-Darchname=$(PERL_ARCH) \
			-Dstartperl='#!$(TARGET_PREFIX)/bin/perl' \
			-Dprefix=$(@D)/staging-install; \
	)
	$(MAKE) -C $(@D) install
	ln -s Config.pm $(@D)/lib/config.pm
	touch $@

perl-hostperl: $(PERL_HOST_BUILD_DIR)/.hostbuilt

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(PERL_BUILD_DIR)/.configured: $(PERL_PATCHES) $(DL_DIR)/$(PERL_CROSS_SOURCE) $(PERL_HOST_BUILD_DIR)/.hostbuilt $(SOURCE_DIR)/perl/$(PERL_MAJOR_VER)/perl.mk
	$(MAKE) gdbm-stage
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(@D)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_PATCHES)" ; then \
		cat $(PERL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PERL_DIR) $(@D)
	$(PERL_CROSS_UNZIP) $(DL_DIR)/$(PERL_CROSS_SOURCE) | tar --overwrite --strip-components=1 -C $(@D) -xvf -
	if test -n "$(PERL_CROSS_PATCHES)" ; then \
		cat $(PERL_CROSS_PATCHES) | $(PATCH) -d $(@D) -p1 ; \
	fi
	(cd $(@D); \
		./configure \
		--target=$(PERL_ARCH) \
		--mode=cross \
		--target-tools-prefix=$(TARGET_CROSS) \
		--prefix=$(TARGET_PREFIX) \
		-Darchname=$(PERL_ARCH) \
		-Accflags="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
		-Aldlags="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA)" \
		-Alibs="$(PERL_LIBS)" \
		-Dld=$(TARGET_CC) \
		-Duseshrplib \
		-Dusethreads \
	)
	touch $@

perl-unpack: $(PERL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_BUILD_DIR)/.built: $(PERL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) miniperl
	$(MAKE) -C $(@D) libperl.so lib/Config.pm \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -fstack-protector" \
		LDDLFLAGS="-shared -O2 $(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -fstack-protector"
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -fstack-protector" \
		LDDLFLAGS="-shared -O2 $(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -fstack-protector"
	touch $@

#
# This is the build convenience target.
#
perl: $(PERL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERL_BUILD_DIR)/.staged: $(PERL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_DIR)/*.0
	(cd $(STAGING_DIR)$(TARGET_PREFIX)/bin; \
		rm -f perl; \
		ln -s perl$(PERL_VERSION) perl; \
	)
	touch $@

perl-stage: $(PERL_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PERL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PERL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PERL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PERL_IPK_DIR)$(TARGET_PREFIX)/etc/perl/...
# Documentation files should be installed in $(PERL_IPK_DIR)$(TARGET_PREFIX)/doc/perl/...
# Daemon startup scripts should be installed in $(PERL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??perl
#
# You may need to patch your application to make it use these locations.
#
$(PERL_IPK) $(PERL-DOC_IPK): $(PERL_BUILD_DIR)/.built
	rm -rf $(PERL_IPK_DIR) $(BUILD_DIR)/perl_*_$(TARGET_ARCH).ipk
	rm -rf $(PERL-DOC_IPK_DIR) $(BUILD_DIR)/perl-doc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) install
	rm -f $(PERL_IPK_DIR)/*.0
	for f in $(PERL_IPK_DIR)$(TARGET_PREFIX)/bin/perl$(PERL_VERSION) \
		$(PERL_IPK_DIR)$(TARGET_PREFIX)/bin/a2p \
		`find $(PERL_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/ -name '*.so'`; \
		do chmod u+w $$f; $(STRIP_COMMAND) $$f; done
	(cd $(PERL_IPK_DIR)$(TARGET_PREFIX)/bin; \
		rm -f perl; \
		ln -s perl$(PERL_VERSION) perl; \
	)
	sed -i -e 's|$(TARGET_CROSS)|$(TARGET_PREFIX)/bin/|g' \
		$(PERL_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/Config_heavy.pl \
		$(PERL_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/Config.pm \
		$(PERL_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE/config.h
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	$(INSTALL) -d $(PERL_IPK_DIR)/usr/bin
	ln -s $(TARGET_PREFIX)/bin/perl $(PERL_IPK_DIR)/usr/bin/perl
endif
	$(MAKE) $(PERL_IPK_DIR)/CONTROL/control
	echo $(PERL_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_IPK_DIR)/CONTROL/conffiles
	$(MAKE) $(PERL-DOC_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PERL-DOC_IPK_DIR)$(TARGET_PREFIX)/bin
	mv $(PERL_IPK_DIR)$(TARGET_PREFIX)/bin/perldoc $(PERL-DOC_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(PERL-DOC_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)
	mv $(PERL_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/pod $(PERL-DOC_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/
	cp -rp $(PERL_HOST_BUILD_DIR)/staging-install/man $(PERL-DOC_IPK_DIR)$(TARGET_PREFIX)/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-ipk: $(PERL_IPK) $(PERL-DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-clean:
	rm -f $(PERL_BUILD_DIR)/.built
	-$(MAKE) -C $(PERL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK) $(PERL_HOST_BUILD_DIR)

#
#
# Some sanity check for the package.
#
perl-check: $(PERL_IPK) $(PERL-DOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL_IPK)
