###########################################################
#
# perl
#
###########################################################

PERL_CROSS_VERSION=1.0.2
PERL_CROSS_SITE=https://raw.github.com/arsv/perl-cross/releases
PERL_CROSS_SOURCE=perl-$(PERL_VERSION)-cross-$(PERL_CROSS_VERSION).tar.gz
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

PERL_CROSS_PATCHES=$(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/dynamic_ext.fix.patch

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
    $(if $(filter powerpc, $(TARGET_ARCH)), ppc-linux, \
    $(TARGET_ARCH)-linux)))))
PERL_LIB_CORE_DIR=perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE
PERL_LDFLAGS=-pthread -Wl,-rpath,$(TARGET_PREFIX)/lib/$(PERL_LIB_CORE_DIR)

PERL_LIBS=-ldl -lcrypt -lm -ldb-$(LIBDB_LIB_VERSION) -lgdbm -lgdbm_compat

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
ifneq ($(HOSTCC), $(TARGET_CC))
PERL_HOST_BUILD_DIR=$(BUILD_DIR)/perl-host
PERL_HOST_MINIPERL=$(PERL_HOST_BUILD_DIR)/miniperl
PERL_HOSTPERL=$(PERL_HOST_BUILD_DIR)/perl
PERL_INC=PERL_INC=$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)
else
PERL_HOSTPERL=perl
PERL_INC=
endif
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
ifeq ($(HOSTCC), $(TARGET_CC))
$(PERL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_SOURCE) $(PERL_PATCHES) $(SOURCE_DIR)/perl/$(PERL_MAJOR_VER)/perl.mk
else
$(PERL_BUILD_DIR)/.configured: $(PERL_PATCHES) $(DL_DIR)/$(PERL_CROSS_SOURCE) $(PERL_HOST_BUILD_DIR)/.hostbuilt $(SOURCE_DIR)/perl/$(PERL_MAJOR_VER)/perl.mk
endif
	$(MAKE) libdb-stage gdbm-stage
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(@D)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_PATCHES)" ; then \
		cat $(PERL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL_DIR) -p1 ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	$(PERL_CROSS_UNZIP) $(DL_DIR)/$(PERL_CROSS_SOURCE) | tar --overwrite -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_CROSS_PATCHES)" ; then \
		cat $(PERL_CROSS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL_DIR) -p1 ; \
	fi
endif
	mv $(BUILD_DIR)/$(PERL_DIR) $(@D)
	sed -i -e '/LIBS/s|-L/usr/local/lib|-L$(STAGING_LIB_DIR)|' $(@D)/ext/*/Makefile.PL
ifeq ($(HOSTCC), $(TARGET_CC))
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS)" \
		./Configure \
		-Dcc=gcc \
		-Dprefix=$(TARGET_PREFIX) \
		-Duseshrplib \
		-Dd_dlopen \
		-de \
	)
else
ifeq ($(shell [ -e $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/config.sh-$(OPTWARE_TARGET) ] || [ -e $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/config.sh-$(PERL_TARGET_NAME) ]; echo $?), 0)
	(cd $(@D); \
		( [ -e $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/config.sh-$(OPTWARE_TARGET) ] && \
		$(INSTALL) -m 644 $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/config.sh-$(OPTWARE_TARGET) config.sh-$(PERL_TARGET_NAME) ) || \
		( [ -e $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/config.sh-$(PERL_TARGET_NAME) ] && \
		$(INSTALL) -m 644 $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/config.sh-$(PERL_TARGET_NAME) . ) ; \
	)
	sed -i -e 's|-ldb |-ldb-$(LIBDB_LIB_VERSION) |' $(@D)/config.sh-$(PERL_TARGET_NAME)
#	sed -i -e "s|^cc=.*|cc='$(TARGET_CC)'|" -e "s|^cpp=.*|cpp='$(TARGET_CC) -E'|" -e \
#		"s|^ld=.*|ld='$(TARGET_LD)'|" -e "s|^ar=.*|ar='$(TARGET_AR)'|" -e \
#		"s|^nm=.*|nm='$(TARGET_NM)'|" $(@D)/config.sh-$(PERL_TARGET_NAME)
#	clear dynamic_ext, static_ext and nonxs_ext variables generated by perl's Configure on the target,
#	since they're not compatible with perl-cross's extensions,
#	and let perl-cross generate list of available extensions
	sed -i -e "/^extensions=\|^nonxs_ext=\|^static_ext=\|^dynamic_ext=/s/=.*/=''/" $(@D)/config.sh-$(PERL_TARGET_NAME)
	(cd $(@D); \
		PATH="`dirname $(TARGET_CC)`:$$PATH" \
		LC_ALL=C \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--mode=cross \
		--target-tools-prefix=`basename $(TARGET_CROSS)` \
		--prefix=$(TARGET_PREFIX) \
		-O \
		-f "$(@D)/config.sh-$(PERL_TARGET_NAME)"\
		--with-ranlib=$(TARGET_RANLIB) \
		--with-objdump=$(TARGET_CROSS)objdump \
		-Accflags="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
		-Aldlags="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA)" \
		-Alibs="$(PERL_LIBS)" \
		-Dcc=$(TARGET_CC) \
		-Dld=$(TARGET_LD) \
		-Dnm=$(TARGET_NM) \
		-Dar=$(TARGET_AR) \
		-Dcpp=$(TARGET_CPP) \
		-Dranlib=$(TARGET_RANLIB) \
		-Duseshrplib \
		-Dusethreads \
	)
else
	(cd $(@D); \
		PATH="`dirname $(TARGET_CC)`:$$PATH" \
		LC_ALL=C \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--mode=cross \
		--target-tools-prefix=`basename $(TARGET_CROSS)` \
		--prefix=$(TARGET_PREFIX) \
		-O \
		-f $(PERL_SOURCE_DIR)/$(PERL_MAJOR_VER)/defines.$(LIBC_STYLE) \
		-Darchname=$(PERL_ARCH) \
		--with-ranlib=$(TARGET_RANLIB) \
		--with-objdump=$(TARGET_CROSS)objdump \
		-Accflags="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
		-Aldlags="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA)" \
		-Alibs="$(PERL_LIBS)" \
		-Dcc=$(TARGET_CC) \
		-Dld=$(TARGET_LD) \
		-Dnm=$(TARGET_NM) \
		-Dar=$(TARGET_AR) \
		-Dcpp=$(TARGET_CPP) \
		-Dranlib=$(TARGET_RANLIB) \
		-Duseshrplib \
		-Dusethreads \
	)
endif
endif
	touch $@

perl-unpack: $(PERL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_BUILD_DIR)/.built: $(PERL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) libperl.so \
		LD=$(TARGET_CC) \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -lpthread -fstack-protector" \
		LDDLFLAGS="-shared -O2 $(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -lpthread -fstack-protector"
	$(MAKE) -C $(@D) \
		LD=$(TARGET_CC) \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -lpthread -fstack-protector" \
		LDDLFLAGS="-shared -O2 $(STAGING_LDFLAGS) $(PERL_LDFLAGS) $(PERL_LDFLAGS_EXTRA) -lpthread -fstack-protector"
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
ifeq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install.perl
else
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_DIR)/*.0
endif
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
ifeq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) install.perl
else
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) install
	rm -f $(PERL_IPK_DIR)/*.0
	for f in $(PERL_IPK_DIR)$(TARGET_PREFIX)/bin/perl$(PERL_VERSION) \
		$(PERL_IPK_DIR)$(TARGET_PREFIX)/bin/a2p \
		`find $(PERL_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/ -name '*.so'`; \
		do chmod u+w $$f; $(STRIP_COMMAND) $$f; done
endif
	(cd $(PERL_IPK_DIR)$(TARGET_PREFIX)/bin; \
		rm -f perl; \
		ln -s perl$(PERL_VERSION) perl; \
	)
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
ifeq ($(HOSTCC), $(TARGET_CC))
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK)
else
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK) $(PERL_HOST_BUILD_DIR)
endif

#
#
# Some sanity check for the package.
#
perl-check: $(PERL_IPK) $(PERL-DOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL_IPK)
