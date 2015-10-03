###########################################################
#
# xdamage
#
###########################################################

#
# XDAMAGE_VERSION, XDAMAGE_SITE and XDAMAGE_SOURCE define
# the upstream location of the source code for the package.
# XDAMAGE_DIR is the directory which is created when the source
# archive is unpacked.
#
XDAMAGE_SITE=http://xorg.freedesktop.org/releases/individual/lib
XDAMAGE_SOURCE=libXdamage-$(XDAMAGE_VERSION).tar.gz
XDAMAGE_VERSION=1.1.4
XDAMAGE_FULL_VERSION=$(XDAMAGE_VERSION)
XDAMAGE_DIR=libXdamage-$(XDAMAGE_VERSION)
XDAMAGE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XDAMAGE_DESCRIPTION=library for the X Damage extension
XDAMAGE_SECTION=lib
XDAMAGE_PRIORITY=optional
XDAMAGE_DEPENDS=x11, xfixes

#
# XDAMAGE_IPK_VERSION should be incremented when the ipk changes.
#
XDAMAGE_IPK_VERSION=1

#
# XDAMAGE_CONFFILES should be a list of user-editable files
XDAMAGE_CONFFILES=

#
# XDAMAGE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XDAMAGE_PATCHES=$(XDAMAGE_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XDAMAGE_CPPFLAGS=
XDAMAGE_LDFLAGS=

#
# XDAMAGE_BUILD_DIR is the directory in which the build is done.
# XDAMAGE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XDAMAGE_IPK_DIR is the directory in which the ipk is built.
# XDAMAGE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XDAMAGE_BUILD_DIR=$(BUILD_DIR)/xdamage
XDAMAGE_SOURCE_DIR=$(SOURCE_DIR)/xdamage
XDAMAGE_IPK_DIR=$(BUILD_DIR)/xdamage-$(XDAMAGE_FULL_VERSION)-ipk
XDAMAGE_IPK=$(BUILD_DIR)/xdamage_$(XDAMAGE_FULL_VERSION)-$(XDAMAGE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XDAMAGE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XDAMAGE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xdamage" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XDAMAGE_PRIORITY)" >>$@
	@echo "Section: $(XDAMAGE_SECTION)" >>$@
	@echo "Version: $(XDAMAGE_FULL_VERSION)-$(XDAMAGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XDAMAGE_MAINTAINER)" >>$@
	@echo "Source: $(XDAMAGE_SITE)/$(XDAMAGE_SOURCE)" >>$@
	@echo "Description: $(XDAMAGE_DESCRIPTION)" >>$@
	@echo "Depends: $(XDAMAGE_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XDAMAGE_SOURCE):
	$(WGET) -P $(@D) $(XDAMAGE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xdamage-source: $(DL_DIR)/$(XDAMAGE_SOURCE) $(XDAMAGE_PATCHES)

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
$(XDAMAGE_BUILD_DIR)/.configured: $(DL_DIR)/$(XDAMAGE_SOURCE) $(XDAMAGE_PATCHES) make/xdamage.mk
	$(MAKE) xorg-macros-stage x11-stage xfixes-stage damageproto-stage xfixesproto-stage xextproto-stage
	rm -rf $(BUILD_DIR)/$(XDAMAGE_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XDAMAGE_SOURCE)
	if test -n "$(XDAMAGE_PATCHES)" ; \
		then cat $(XDAMAGE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XDAMAGE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XDAMAGE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XDAMAGE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XDAMAGE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XDAMAGE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--enable-malloc0returnsnull \
	)
	touch $@

xdamage-unpack: $(XDAMAGE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XDAMAGE_BUILD_DIR)/.built: $(XDAMAGE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xdamage: $(XDAMAGE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XDAMAGE_BUILD_DIR)/.staged: $(XDAMAGE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xdamage.pc
	rm -f $(STAGING_LIB_DIR)/libXdamage.la
	touch $@

xdamage-stage: $(XDAMAGE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/etc/xdamage/...
# Documentation files should be installed in $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/doc/xdamage/...
# Daemon startup scripts should be installed in $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xdamage
#
# You may need to patch your application to make it use these locations.
#
$(XDAMAGE_IPK): $(XDAMAGE_BUILD_DIR)/.built
	rm -rf $(XDAMAGE_IPK_DIR) $(BUILD_DIR)/xdamage_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XDAMAGE_BUILD_DIR) DESTDIR=$(XDAMAGE_IPK_DIR) install-strip
	$(MAKE) $(XDAMAGE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(XDAMAGE_SOURCE_DIR)/postinst $(XDAMAGE_IPK_DIR)/CONTROL/postinst
	rm -f $(XDAMAGE_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XDAMAGE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xdamage-ipk: $(XDAMAGE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xdamage-clean:
	-$(MAKE) -C $(XDAMAGE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xdamage-dirclean:
	rm -rf $(BUILD_DIR)/$(XDAMAGE_DIR) $(XDAMAGE_BUILD_DIR) $(XDAMAGE_IPK_DIR) $(XDAMAGE_IPK)
