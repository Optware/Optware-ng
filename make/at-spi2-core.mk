###########################################################
#
# at-spi2-core
#
###########################################################

# You must replace "at-spi2-core" and "AT-SPI2-CORE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# AT-SPI2-CORE_VERSION, AT-SPI2-CORE_SITE and AT-SPI2-CORE_SOURCE define
# the upstream location of the source code for the package.
# AT-SPI2-CORE_DIR is the directory which is created when the source
# archive is unpacked.
# AT-SPI2-CORE_UNZIP is the command used to unzip the source.
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
AT-SPI2-CORE_SITE=http://ftp.gnome.org/pub/GNOME/sources/at-spi2-core/2.15
AT-SPI2-CORE_VERSION=2.15.90
AT-SPI2-CORE_SOURCE=at-spi2-core-$(AT-SPI2-CORE_VERSION).tar.xz
AT-SPI2-CORE_DIR=at-spi2-core-$(AT-SPI2-CORE_VERSION)
AT-SPI2-CORE_UNZIP=xzcat
AT-SPI2-CORE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AT-SPI2-CORE_DESCRIPTION=This package includes the protocol definitions for the new D-Bus at-spi
AT-SPI2-CORE_SECTION=lib
AT-SPI2-CORE_PRIORITY=optional
AT-SPI2-CORE_DEPENDS=glib, dbus, x11, ice, sm, xtst
AT-SPI2-CORE_SUGGESTS=
AT-SPI2-CORE_CONFLICTS=

#
# AT-SPI2-CORE_IPK_VERSION should be incremented when the ipk changes.
#
AT-SPI2-CORE_IPK_VERSION=2

#
# AT-SPI2-CORE_CONFFILES should be a list of user-editable files
#AT-SPI2-CORE_CONFFILES=$(TARGET_PREFIX)/etc/at-spi2-core.conf $(TARGET_PREFIX)/etc/init.d/SXXat-spi2-core

#
# AT-SPI2-CORE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#AT-SPI2-CORE_PATCHES=$(AT-SPI2-CORE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AT-SPI2-CORE_CPPFLAGS=
AT-SPI2-CORE_LDFLAGS=

#
# AT-SPI2-CORE_BUILD_DIR is the directory in which the build is done.
# AT-SPI2-CORE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AT-SPI2-CORE_IPK_DIR is the directory in which the ipk is built.
# AT-SPI2-CORE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AT-SPI2-CORE_BUILD_DIR=$(BUILD_DIR)/at-spi2-core
AT-SPI2-CORE_SOURCE_DIR=$(SOURCE_DIR)/at-spi2-core
AT-SPI2-CORE_IPK_DIR=$(BUILD_DIR)/at-spi2-core-$(AT-SPI2-CORE_VERSION)-ipk
AT-SPI2-CORE_IPK=$(BUILD_DIR)/at-spi2-core_$(AT-SPI2-CORE_VERSION)-$(AT-SPI2-CORE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: at-spi2-core-source at-spi2-core-unpack at-spi2-core at-spi2-core-stage at-spi2-core-ipk at-spi2-core-clean at-spi2-core-dirclean at-spi2-core-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AT-SPI2-CORE_SOURCE):
	$(WGET) -P $(@D) $(AT-SPI2-CORE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
at-spi2-core-source: $(DL_DIR)/$(AT-SPI2-CORE_SOURCE) $(AT-SPI2-CORE_PATCHES)

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
$(AT-SPI2-CORE_BUILD_DIR)/.configured: $(DL_DIR)/$(AT-SPI2-CORE_SOURCE) $(AT-SPI2-CORE_PATCHES) make/at-spi2-core.mk
	$(MAKE) glib-stage dbus-stage x11-stage xtst-stage ice-stage sm-stage
	rm -rf $(BUILD_DIR)/$(AT-SPI2-CORE_DIR) $(@D)
	$(AT-SPI2-CORE_UNZIP) $(DL_DIR)/$(AT-SPI2-CORE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AT-SPI2-CORE_PATCHES)" ; \
		then cat $(AT-SPI2-CORE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(AT-SPI2-CORE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(AT-SPI2-CORE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(AT-SPI2-CORE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AT-SPI2-CORE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AT-SPI2-CORE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-x \
		--disable-gtk-doc-html \
		--disable-nls \
		--disable-static \
		--disable-introspection \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

at-spi2-core-unpack: $(AT-SPI2-CORE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AT-SPI2-CORE_BUILD_DIR)/.built: $(AT-SPI2-CORE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
at-spi2-core: $(AT-SPI2-CORE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AT-SPI2-CORE_BUILD_DIR)/.staged: $(AT-SPI2-CORE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/atspi-2.pc
	rm -f $(STAGING_LIB_DIR)/libatspi.la
	touch $@

at-spi2-core-stage: $(AT-SPI2-CORE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/at-spi2-core
#
$(AT-SPI2-CORE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: at-spi2-core" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AT-SPI2-CORE_PRIORITY)" >>$@
	@echo "Section: $(AT-SPI2-CORE_SECTION)" >>$@
	@echo "Version: $(AT-SPI2-CORE_VERSION)-$(AT-SPI2-CORE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AT-SPI2-CORE_MAINTAINER)" >>$@
	@echo "Source: $(AT-SPI2-CORE_SITE)/$(AT-SPI2-CORE_SOURCE)" >>$@
	@echo "Description: $(AT-SPI2-CORE_DESCRIPTION)" >>$@
	@echo "Depends: $(AT-SPI2-CORE_DEPENDS)" >>$@
	@echo "Suggests: $(AT-SPI2-CORE_SUGGESTS)" >>$@
	@echo "Conflicts: $(AT-SPI2-CORE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/at-spi2-core/...
# Documentation files should be installed in $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/doc/at-spi2-core/...
# Daemon startup scripts should be installed in $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??at-spi2-core
#
# You may need to patch your application to make it use these locations.
#
$(AT-SPI2-CORE_IPK): $(AT-SPI2-CORE_BUILD_DIR)/.built
	rm -rf $(AT-SPI2-CORE_IPK_DIR) $(BUILD_DIR)/at-spi2-core_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(AT-SPI2-CORE_BUILD_DIR) DESTDIR=$(AT-SPI2-CORE_IPK_DIR) install-strip
	rm -f $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(AT-SPI2-CORE_SOURCE_DIR)/at-spi2-core.conf $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/at-spi2-core.conf
#	$(INSTALL) -d $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(AT-SPI2-CORE_SOURCE_DIR)/rc.at-spi2-core $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXat-spi2-core
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(AT-SPI2-CORE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXat-spi2-core
	$(MAKE) $(AT-SPI2-CORE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(AT-SPI2-CORE_SOURCE_DIR)/postinst $(AT-SPI2-CORE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(AT-SPI2-CORE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(AT-SPI2-CORE_SOURCE_DIR)/prerm $(AT-SPI2-CORE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(AT-SPI2-CORE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(AT-SPI2-CORE_IPK_DIR)/CONTROL/postinst $(AT-SPI2-CORE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(AT-SPI2-CORE_CONFFILES) | sed -e 's/ /\n/g' > $(AT-SPI2-CORE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AT-SPI2-CORE_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(AT-SPI2-CORE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
at-spi2-core-ipk: $(AT-SPI2-CORE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
at-spi2-core-clean:
	rm -f $(AT-SPI2-CORE_BUILD_DIR)/.built
	-$(MAKE) -C $(AT-SPI2-CORE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
at-spi2-core-dirclean:
	rm -rf $(BUILD_DIR)/$(AT-SPI2-CORE_DIR) $(AT-SPI2-CORE_BUILD_DIR) $(AT-SPI2-CORE_IPK_DIR) $(AT-SPI2-CORE_IPK)
#
#
# Some sanity check for the package.
#
at-spi2-core-check: $(AT-SPI2-CORE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
