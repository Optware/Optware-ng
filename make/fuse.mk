###########################################################
#
# fuse
#
###########################################################
#
# FUSE_VERSION, FUSE_SITE and FUSE_SOURCE define
# the upstream location of the source code for the package.
# FUSE_DIR is the directory which is created when the source
# archive is unpacked.
# FUSE_UNZIP is the command used to unzip the source.
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
FUSE_SITE=http://pkgs.fedoraproject.org/repo/pkgs/fuse/$(FUSE_SOURCE)/ecb712b5ffc6dffd54f4a405c9b372d8
FUSE_VERSION=2.9.4
FUSE_SOURCE=fuse-$(FUSE_VERSION).tar.gz
FUSE_DIR=fuse-$(FUSE_VERSION)
FUSE_UNZIP=zcat
FUSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FUSE_DESCRIPTION=FUSE mount/unmount program.
LIBFUSE_DESCRIPTION=FUSE userspace library.
LIBFUSE-DEV_DESCRIPTION=FUSE headers.
LIBFUSE_SECTION=lib
FUSE_SECTION=misc
FUSE_PRIORITY=optional
FUSE_DEPENDS=libfuse
LIBFUSE-DEV_DEPENDS=libfuse
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBFUSE_DEPENDS=libiconv
else
LIBFUSE_DEPENDS=
endif
LIBFUSE_SUGGESTS=fuse
FUSE_SUGGESTS=
FUSE_CONFLICTS=

#
# FUSE_IPK_VERSION should be incremented when the ipk changes.
#
FUSE_IPK_VERSION=2

#
# FUSE_CONFFILES should be a list of user-editable files
FUSE_CONFFILES=$(TARGET_PREFIX)/etc/init.d/fuse $(TARGET_PREFIX)/etc/udev/rules.d/99-fuse.rules

#
# FUSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FUSE_PATCHES=$(FUSE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FUSE_CPPFLAGS=
FUSE_LDFLAGS=

ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
FUSE_ADDITIONAL_CONFIG_ARGS=--with-libiconv-prefix=$(STAGING_PREFIX)
else
FUSE_ADDITIONAL_CONFIG_ARGS=--without-libiconv-prefix
endif


#
# FUSE_BUILD_DIR is the directory in which the build is done.
# FUSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FUSE_IPK_DIR is the directory in which the ipk is built.
# FUSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FUSE_BUILD_DIR=$(BUILD_DIR)/fuse
FUSE_SOURCE_DIR=$(SOURCE_DIR)/fuse

FUSE_IPK_DIR=$(BUILD_DIR)/fuse-$(FUSE_VERSION)-ipk
FUSE_IPK=$(BUILD_DIR)/fuse_$(FUSE_VERSION)-$(FUSE_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBFUSE_IPK_DIR=$(BUILD_DIR)/libfuse-$(FUSE_VERSION)-ipk
LIBFUSE_IPK=$(BUILD_DIR)/libfuse_$(FUSE_VERSION)-$(FUSE_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBFUSE-DEV_IPK_DIR=$(BUILD_DIR)/libfuse-dev-$(FUSE_VERSION)-ipk
LIBFUSE-DEV_IPK=$(BUILD_DIR)/libfuse-dev_$(FUSE_VERSION)-$(FUSE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fuse-source fuse-unpack fuse fuse-stage fuse-ipk fuse-clean fuse-dirclean fuse-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FUSE_SOURCE):
	$(WGET) -P $(@D) $(FUSE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fuse-source: $(DL_DIR)/$(FUSE_SOURCE) $(FUSE_PATCHES)

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
$(FUSE_BUILD_DIR)/.configured: $(DL_DIR)/$(FUSE_SOURCE) $(FUSE_PATCHES) make/fuse.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(FUSE_DIR) $(@D)
	$(FUSE_UNZIP) $(DL_DIR)/$(FUSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FUSE_PATCHES)" ; \
		then cat $(FUSE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FUSE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FUSE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FUSE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FUSE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FUSE_LDFLAGS)" \
		MOUNT_FUSE_PATH=$(TARGET_PREFIX)/sbin \
		UDEV_RULES_PATH=$(TARGET_PREFIX)/etc/udev/rules.d \
		INIT_D_PATH=$(TARGET_PREFIX)/etc/init.d \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--sysconfdir=$(TARGET_PREFIX)/etc \
		--disable-nls \
		--disable-static \
		--program-transform-name='s/^//' \
		$(FUSE_ADDITIONAL_CONFIG_ARGS) \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

fuse-unpack: $(FUSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FUSE_BUILD_DIR)/.built: $(FUSE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/lib
	$(MAKE) -C $(@D)/util
	touch $@

#
# This is the build convenience target.
#
fuse: $(FUSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FUSE_BUILD_DIR)/.staged: $(FUSE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/lib DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(@D)/include DESTDIR=$(STAGING_DIR) install
	mkdir -p $(STAGING_LIB_DIR)/pkgconfig
	cp -f $(@D)/fuse.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fuse.pc
	touch $@

fuse-stage: $(FUSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fuse
#
$(FUSE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: fuse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FUSE_PRIORITY)" >>$@
	@echo "Section: $(FUSE_SECTION)" >>$@
	@echo "Version: $(FUSE_VERSION)-$(FUSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FUSE_MAINTAINER)" >>$@
	@echo "Source: $(FUSE_SITE)/$(FUSE_SOURCE)" >>$@
	@echo "Description: $(FUSE_DESCRIPTION)" >>$@
	@echo "Depends: $(FUSE_DEPENDS)" >>$@
	@echo "Suggests: $(FUSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(FUSE_CONFLICTS)" >>$@

$(LIBFUSE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libfuse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FUSE_PRIORITY)" >>$@
	@echo "Section: $(LIBFUSE_SECTION)" >>$@
	@echo "Version: $(FUSE_VERSION)-$(FUSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FUSE_MAINTAINER)" >>$@
	@echo "Source: $(FUSE_SITE)/$(FUSE_SOURCE)" >>$@
	@echo "Description: $(LIBFUSE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFUSE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFUSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFUSE_CONFLICTS)" >>$@

$(LIBFUSE-DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libfuse-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FUSE_PRIORITY)" >>$@
	@echo "Section: $(LIBFUSE_SECTION)" >>$@
	@echo "Version: $(FUSE_VERSION)-$(FUSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FUSE_MAINTAINER)" >>$@
	@echo "Source: $(FUSE_SITE)/$(FUSE_SOURCE)" >>$@
	@echo "Description: $(LIBFUSE-DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFUSE-DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFUSE-DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFUSE-DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FUSE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(FUSE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FUSE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/fuse/...
# Documentation files should be installed in $(FUSE_IPK_DIR)$(TARGET_PREFIX)/doc/fuse/...
# Daemon startup scripts should be installed in $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??fuse
#
# You may need to patch your application to make it use these locations.
#
$(LIBFUSE_IPK): $(FUSE_BUILD_DIR)/.built
	rm -rf $(LIBFUSE_IPK_DIR) $(BUILD_DIR)/libfuse_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FUSE_BUILD_DIR)/lib DESTDIR=$(LIBFUSE_IPK_DIR) install
	rm -f $(LIBFUSE_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(STRIP_COMMAND) $(LIBFUSE_IPK_DIR)$(TARGET_PREFIX)/lib/*
#	$(INSTALL) -d $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(FUSE_SOURCE_DIR)/fuse.conf $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/fuse.conf
#	$(INSTALL) -d $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(FUSE_SOURCE_DIR)/rc.fuse $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfuse
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfuse
	$(MAKE) $(LIBFUSE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(FUSE_SOURCE_DIR)/postinst $(FUSE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(FUSE_SOURCE_DIR)/prerm $(FUSE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FUSE_IPK_DIR)/CONTROL/postinst $(FUSE_IPK_DIR)/CONTROL/prerm; \
	fi
#	echo $(FUSE_CONFFILES) | sed -e 's/ /\n/g' > $(FUSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFUSE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBFUSE_IPK_DIR)

$(FUSE_IPK): $(FUSE_BUILD_DIR)/.built
	rm -rf $(FUSE_IPK_DIR) $(BUILD_DIR)/fuse_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FUSE_BUILD_DIR)/util DESTDIR=$(FUSE_IPK_DIR) install
	rm -rf $(FUSE_IPK_DIR)/dev
	$(STRIP_COMMAND) $(FUSE_IPK_DIR)$(TARGET_PREFIX)/bin/* $(FUSE_IPK_DIR)$(TARGET_PREFIX)/sbin/*
#	$(INSTALL) -d $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(FUSE_SOURCE_DIR)/fuse.conf $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/fuse.conf
#	$(INSTALL) -d $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(FUSE_SOURCE_DIR)/rc.fuse $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfuse
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfuse
	$(MAKE) $(FUSE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(FUSE_SOURCE_DIR)/postinst $(FUSE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(FUSE_SOURCE_DIR)/prerm $(FUSE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FUSE_IPK_DIR)/CONTROL/postinst $(FUSE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FUSE_CONFFILES) | sed -e 's/ /\n/g' > $(FUSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FUSE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(FUSE_IPK_DIR)

$(LIBFUSE-DEV_IPK): $(FUSE_BUILD_DIR)/.built
	rm -rf $(LIBFUSE-DEV_IPK_DIR) $(BUILD_DIR)/libfuse-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FUSE_BUILD_DIR)/include DESTDIR=$(LIBFUSE-DEV_IPK_DIR) install
	$(MAKE) $(LIBFUSE-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFUSE-DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBFUSE-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fuse-ipk: $(LIBFUSE_IPK) $(FUSE_IPK) $(LIBFUSE-DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fuse-clean:
	rm -f $(FUSE_BUILD_DIR)/.built
	-$(MAKE) -C $(FUSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fuse-dirclean:
	rm -rf $(BUILD_DIR)/$(FUSE_DIR) $(FUSE_BUILD_DIR) $(FUSE_IPK_DIR) $(FUSE_IPK)
#
#
# Some sanity check for the package.
#
fuse-check: $(LIBFUSE_IPK) $(FUSE_IPK) $(LIBFUSE-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
