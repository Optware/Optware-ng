###########################################################
#
# atk-bridge
#
###########################################################

# You must replace "atk-bridge" and "ATK-BRIDGE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ATK-BRIDGE_VERSION, ATK-BRIDGE_SITE and ATK-BRIDGE_SOURCE define
# the upstream location of the source code for the package.
# ATK-BRIDGE_DIR is the directory which is created when the source
# archive is unpacked.
# ATK-BRIDGE_UNZIP is the command used to unzip the source.
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
ATK-BRIDGE_SITE=http://ftp.gnome.org/pub/GNOME/sources/at-spi2-atk/2.15
ATK-BRIDGE_VERSION=2.15.90
ATK-BRIDGE_SOURCE=at-spi2-atk-$(ATK-BRIDGE_VERSION).tar.xz
ATK-BRIDGE_DIR=at-spi2-atk-$(ATK-BRIDGE_VERSION)
ATK-BRIDGE_UNZIP=xzcat
ATK-BRIDGE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ATK-BRIDGE_DESCRIPTION=This package includes libatk-bridge, a library that bridges ATK to the new D-Bus based AT-SPI
ATK-BRIDGE_SECTION=lib
ATK-BRIDGE_PRIORITY=optional
ATK-BRIDGE_DEPENDS=libxml2, atk, glib, dbus, at-spi2-core
ATK-BRIDGE_SUGGESTS=
ATK-BRIDGE_CONFLICTS=

#
# ATK-BRIDGE_IPK_VERSION should be incremented when the ipk changes.
#
ATK-BRIDGE_IPK_VERSION=2

#
# ATK-BRIDGE_CONFFILES should be a list of user-editable files
#ATK-BRIDGE_CONFFILES=$(TARGET_PREFIX)/etc/atk-bridge.conf $(TARGET_PREFIX)/etc/init.d/SXXatk-bridge

#
# ATK-BRIDGE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ATK-BRIDGE_PATCHES=$(ATK-BRIDGE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ATK-BRIDGE_CPPFLAGS=
ATK-BRIDGE_LDFLAGS=

#
# ATK-BRIDGE_BUILD_DIR is the directory in which the build is done.
# ATK-BRIDGE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ATK-BRIDGE_IPK_DIR is the directory in which the ipk is built.
# ATK-BRIDGE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ATK-BRIDGE_BUILD_DIR=$(BUILD_DIR)/atk-bridge
ATK-BRIDGE_SOURCE_DIR=$(SOURCE_DIR)/atk-bridge
ATK-BRIDGE_IPK_DIR=$(BUILD_DIR)/atk-bridge-$(ATK-BRIDGE_VERSION)-ipk
ATK-BRIDGE_IPK=$(BUILD_DIR)/atk-bridge_$(ATK-BRIDGE_VERSION)-$(ATK-BRIDGE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: atk-bridge-source atk-bridge-unpack atk-bridge atk-bridge-stage atk-bridge-ipk atk-bridge-clean atk-bridge-dirclean atk-bridge-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ATK-BRIDGE_SOURCE):
	$(WGET) -P $(@D) $(ATK-BRIDGE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
atk-bridge-source: $(DL_DIR)/$(ATK-BRIDGE_SOURCE) $(ATK-BRIDGE_PATCHES)

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
$(ATK-BRIDGE_BUILD_DIR)/.configured: $(DL_DIR)/$(ATK-BRIDGE_SOURCE) $(ATK-BRIDGE_PATCHES) make/atk-bridge.mk
	$(MAKE) libxml2-stage atk-stage glib-stage dbus-stage at-spi2-core-stage
	rm -rf $(BUILD_DIR)/$(ATK-BRIDGE_DIR) $(@D)
	$(ATK-BRIDGE_UNZIP) $(DL_DIR)/$(ATK-BRIDGE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ATK-BRIDGE_PATCHES)" ; \
		then cat $(ATK-BRIDGE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ATK-BRIDGE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ATK-BRIDGE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ATK-BRIDGE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ATK-BRIDGE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ATK-BRIDGE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

atk-bridge-unpack: $(ATK-BRIDGE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ATK-BRIDGE_BUILD_DIR)/.built: $(ATK-BRIDGE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
atk-bridge: $(ATK-BRIDGE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ATK-BRIDGE_BUILD_DIR)/.staged: $(ATK-BRIDGE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/atk-bridge-2.0.pc
	rm -f $(STAGING_LIB_DIR)/libatk-bridge-2.0.la \
		$(STAGING_LIB_DIR)/gtk-2.0/modules/libatk-bridge.la
	touch $@

atk-bridge-stage: $(ATK-BRIDGE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/atk-bridge
#
$(ATK-BRIDGE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: atk-bridge" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ATK-BRIDGE_PRIORITY)" >>$@
	@echo "Section: $(ATK-BRIDGE_SECTION)" >>$@
	@echo "Version: $(ATK-BRIDGE_VERSION)-$(ATK-BRIDGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ATK-BRIDGE_MAINTAINER)" >>$@
	@echo "Source: $(ATK-BRIDGE_SITE)/$(ATK-BRIDGE_SOURCE)" >>$@
	@echo "Description: $(ATK-BRIDGE_DESCRIPTION)" >>$@
	@echo "Depends: $(ATK-BRIDGE_DEPENDS)" >>$@
	@echo "Suggests: $(ATK-BRIDGE_SUGGESTS)" >>$@
	@echo "Conflicts: $(ATK-BRIDGE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/atk-bridge/...
# Documentation files should be installed in $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/doc/atk-bridge/...
# Daemon startup scripts should be installed in $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??atk-bridge
#
# You may need to patch your application to make it use these locations.
#
$(ATK-BRIDGE_IPK): $(ATK-BRIDGE_BUILD_DIR)/.built
	rm -rf $(ATK-BRIDGE_IPK_DIR) $(BUILD_DIR)/atk-bridge_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ATK-BRIDGE_BUILD_DIR) DESTDIR=$(ATK-BRIDGE_IPK_DIR) install-strip
	rm -f $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(ATK-BRIDGE_SOURCE_DIR)/atk-bridge.conf $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/atk-bridge.conf
#	$(INSTALL) -d $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(ATK-BRIDGE_SOURCE_DIR)/rc.atk-bridge $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXatk-bridge
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ATK-BRIDGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXatk-bridge
	$(MAKE) $(ATK-BRIDGE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ATK-BRIDGE_SOURCE_DIR)/postinst $(ATK-BRIDGE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ATK-BRIDGE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ATK-BRIDGE_SOURCE_DIR)/prerm $(ATK-BRIDGE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ATK-BRIDGE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ATK-BRIDGE_IPK_DIR)/CONTROL/postinst $(ATK-BRIDGE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ATK-BRIDGE_CONFFILES) | sed -e 's/ /\n/g' > $(ATK-BRIDGE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATK-BRIDGE_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(ATK-BRIDGE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
atk-bridge-ipk: $(ATK-BRIDGE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
atk-bridge-clean:
	rm -f $(ATK-BRIDGE_BUILD_DIR)/.built
	-$(MAKE) -C $(ATK-BRIDGE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
atk-bridge-dirclean:
	rm -rf $(BUILD_DIR)/$(ATK-BRIDGE_DIR) $(ATK-BRIDGE_BUILD_DIR) $(ATK-BRIDGE_IPK_DIR) $(ATK-BRIDGE_IPK)
#
#
# Some sanity check for the package.
#
atk-bridge-check: $(ATK-BRIDGE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
