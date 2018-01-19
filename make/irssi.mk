###########################################################
#
# irssi
#
###########################################################
#
# IRSSI_VERSION, IRSSI_SITE and IRSSI_SOURCE define
# the upstream location of the source code for the package.
# IRSSI_DIR is the directory which is created when the source
# archive is unpacked.
# IRSSI_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
IRSSI_SITE=https://github.com/irssi/irssi/releases/download/$(IRSSI_VERSION)/
IRSSI_VERSION=1.1.0
IRSSI_SOURCE=irssi-$(IRSSI_VERSION).tar.xz
IRSSI_DIR=irssi-$(IRSSI_VERSION)
IRSSI_UNZIP=xzcat
IRSSI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IRSSI_DESCRIPTION=A terminal based IRC client for UNIX systems.
IRSSI_SECTION=net
IRSSI_PRIORITY=optional
IRSSI_DEPENDS=glib, ncurses, gconv-modules, openssl
IRSSI_CONFIGURE_OPTIONS=

ifneq (,$(filter perl, $(PACKAGES)))
IRSSI_SUGGESTS=perl
IRSSI_CONFIGURE_OPTIONS+=--with-perl
else
IRSSI_SUGGESTS=
IRSSI_CONFIGURE_OPTIONS+=--without-perl
endif

ifeq (no,$(IPV6))
IRSSI_CONFIGURE_OPTIONS+=--disable-ipv6
else
IRSSI_CONFIGURE_OPTIONS+=--enable-ipv6
endif
IRSSI_CONFLICTS=

#
# IRSSI_IPK_VERSION should be incremented when the ipk changes.
#
IRSSI_IPK_VERSION=1

#
# IRSSI_CONFFILES should be a list of user-editable files
#IRSSI_CONFFILES=$(TARGET_PREFIX)/etc/irssi.conf $(TARGET_PREFIX)/etc/init.d/SXXirssi

#
# IRSSI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IRSSI_PATCHES=$(IRSSI_SOURCE_DIR)/configure.ac.patch \
	$(IRSSI_SOURCE_DIR)/src-perl-Makefile.am.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IRSSI_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
IRSSI_LDFLAGS=
IRSSI_PERL_CFLAGS=-fomit-frame-pointer  -I$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)
IRSSI_PERL_LDFLAGS=-Wl,-rpath,$(TARGET_PREFIX)/lib/$(PERL_LIB_CORE_DIR) \
	-L$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR) \
	-L$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE \
	-lperl -lnsl -ldl -lm -lcrypt -lutil -lc -lgcc_s \

IRSSI_PERL_LDFLAGS += $(if $(filter 5.8, $(PERL_MAJOR_VER)), \
$(STAGING_LIB_DIR)/perl5/$(PERL_VERSION)/$(PERL_ARCH)/auto/DynaLoader/DynaLoader.a,)

#
# IRSSI_BUILD_DIR is the directory in which the build is done.
# IRSSI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IRSSI_IPK_DIR is the directory in which the ipk is built.
# IRSSI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IRSSI_BUILD_DIR=$(BUILD_DIR)/irssi
IRSSI_SOURCE_DIR=$(SOURCE_DIR)/irssi

IRSSI_IPK_DIR=$(BUILD_DIR)/irssi-$(IRSSI_VERSION)-ipk
IRSSI_IPK=$(BUILD_DIR)/irssi_$(IRSSI_VERSION)-$(IRSSI_IPK_VERSION)_$(TARGET_ARCH).ipk
IRSSI-DEV_IPK_DIR=$(BUILD_DIR)/irssi-dev-$(IRSSI_VERSION)-ipk
IRSSI-DEV_IPK=$(BUILD_DIR)/irssi-dev_$(IRSSI_VERSION)-$(IRSSI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IRSSI_SOURCE):
	$(WGET) -P $(@D) $(IRSSI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
irssi-source: $(DL_DIR)/$(IRSSI_SOURCE) $(IRSSI_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(IRSSI_BUILD_DIR)/.configured: $(DL_DIR)/$(IRSSI_SOURCE) $(IRSSI_PATCHES) make/irssi.mk
	$(MAKE) glib-stage ncurses-stage openssl-stage
ifneq (,$(filter perl, $(PACKAGES)))
	$(MAKE) perl-stage
endif
	rm -rf $(BUILD_DIR)/$(IRSSI_DIR) $(@D)
	$(IRSSI_UNZIP) $(DL_DIR)/$(IRSSI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IRSSI_PATCHES)" ; \
		then cat $(IRSSI_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(IRSSI_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IRSSI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IRSSI_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IRSSI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IRSSI_LDFLAGS)" \
		ac_cv_path_perlpath=$(PERL_HOSTPERL) \
		PERL_CFLAGS="$(STAGING_CPPFLAGS) $(IRSSI_CPPFLAGS) $(IRSSI_PERL_CFLAGS)" \
		PERL_LDFLAGS="$(STAGING_LDFLAGS) $(IRSSI_LDFLAGS) $(IRSSI_PERL_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		$(IRSSI_CONFIGURE_OPTIONS) \
		--with-ncurses=$(STAGING_PREFIX) \
		--with-bot \
		--without-gc \
		--with-proxy \
		--enable-ssl \
		--disable-glibtest \
		--with-glib-prefix=$(STAGING_PREFIX) \
		--disable-static \
		--enable-shared \
	)
ifneq (,$(filter perl, $(PACKAGES)))
	for i in common irc ui textui; do \
	    (cd $(IRSSI_BUILD_DIR)/src/perl/$$i; \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		$(TARGET_CONFIGURE_OPTS) \
		PREFIX=$(TARGET_PREFIX) \
	    ) \
	done
endif
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

irssi-unpack: $(IRSSI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IRSSI_BUILD_DIR)/.built: $(IRSSI_BUILD_DIR)/.configured
	rm -f $@
ifneq (,$(filter perl, $(PACKAGES)))
	for i in common irc ui textui; do \
	    $(MAKE) -C $(@D)/src/perl/$$i \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
	    ; \
	done
endif
	$(MAKE) -C $(@D) GLIB_CFLAGS=""
	touch $@

#
# This is the build convenience target.
#
irssi: $(IRSSI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IRSSI_BUILD_DIR)/.staged: $(IRSSI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

irssi-stage: $(IRSSI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/irssi
#
$(IRSSI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: irssi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IRSSI_PRIORITY)" >>$@
	@echo "Section: $(IRSSI_SECTION)" >>$@
	@echo "Version: $(IRSSI_VERSION)-$(IRSSI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IRSSI_MAINTAINER)" >>$@
	@echo "Source: $(IRSSI_SITE)/$(IRSSI_SOURCE)" >>$@
	@echo "Description: $(IRSSI_DESCRIPTION)" >>$@
	@echo "Depends: $(IRSSI_DEPENDS)" >>$@
	@echo "Suggests: $(IRSSI_SUGGESTS)" >>$@
	@echo "Conflicts: $(IRSSI_CONFLICTS)" >>$@

$(IRSSI-DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: irssi-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IRSSI_PRIORITY)" >>$@
	@echo "Section: $(IRSSI_SECTION)" >>$@
	@echo "Version: $(IRSSI_VERSION)-$(IRSSI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IRSSI_MAINTAINER)" >>$@
	@echo "Source: $(IRSSI_SITE)/$(IRSSI_SOURCE)" >>$@
	@echo "Description: irssi dev files" >>$@
	@echo "Depends: $(IRSSI_DEPENDS)" >>$@
	@echo "Suggests: $(IRSSI_SUGGESTS)" >>$@
	@echo "Conflicts: $(IRSSI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/sbin or $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/etc/irssi/...
# Documentation files should be installed in $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/doc/irssi/...
# Daemon startup scripts should be installed in $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??irssi
#
# You may need to patch your application to make it use these locations.
#
$(IRSSI_IPK) $(IRSSI-DEV_IPK): $(IRSSI_BUILD_DIR)/.built
	rm -rf $(IRSSI_IPK_DIR) $(BUILD_DIR)/irssi_*_$(TARGET_ARCH).ipk
	rm -rf $(IRSSI-DEV_IPK_DIR) $(BUILD_DIR)/irssi-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IRSSI_BUILD_DIR) DESTDIR=$(IRSSI_IPK_DIR) install-strip
	$(INSTALL) -d $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(IRSSI_SOURCE_DIR)/irssi.conf $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/etc/irssi.conf
#	$(INSTALL) -d $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(IRSSI_SOURCE_DIR)/rc.irssi $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXirssi
ifneq (,$(filter perl, $(PACKAGES)))
	(cd $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	mv $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/perllocal.pod \
	   $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/perllocal.pod.irssi
endif
	$(MAKE) $(IRSSI_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(IRSSI-DEV_IPK_DIR)$(TARGET_PREFIX)
	mv $(IRSSI_IPK_DIR)$(TARGET_PREFIX)/include $(IRSSI-DEV_IPK_DIR)$(TARGET_PREFIX)/
	$(MAKE) $(IRSSI-DEV_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(IRSSI_SOURCE_DIR)/postinst $(IRSSI_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(IRSSI_SOURCE_DIR)/prerm $(IRSSI_IPK_DIR)/CONTROL/prerm
	echo $(IRSSI_CONFFILES) | sed -e 's/ /\n/g' > $(IRSSI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IRSSI_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IRSSI-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
irssi-ipk: $(IRSSI_IPK) $(IRSSI-DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
irssi-clean:
	rm -f $(IRSSI_BUILD_DIR)/.built
	-$(MAKE) -C $(IRSSI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
irssi-dirclean:
	rm -rf $(BUILD_DIR)/$(IRSSI_DIR) $(IRSSI_BUILD_DIR)
	rm -rf $(IRSSI_IPK_DIR) $(IRSSI_IPK)
	rm -rf $(IRSSI-DEV_IPK_DIR) $(IRSSI-DEV_IPK)

#
# Some sanity check for the package.
#
irssi-check: $(IRSSI_IPK) $(IRSSI-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
