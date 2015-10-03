###########################################################
#
# xcb
#
###########################################################

#
# XCB_VERSION, XCB_SITE and XCB_SOURCE define
# the upstream location of the source code for the package.
# XCB_DIR is the directory which is created when the source
# archive is unpacked.
#
XCB_SITE=http://xorg.freedesktop.org/releases/individual/xcb
XCB_SOURCE=libxcb-$(XCB_VERSION).tar.gz
XCB_VERSION=1.11
XCB_DIR=libxcb-$(XCB_VERSION)
XCB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XCB_DESCRIPTION=Library interface to the X Window System protocol
XCB_SECTION=lib
XCB_PRIORITY=optional
XCB_DEPENDS=pthread-stubs, xau

#
# XCB_IPK_VERSION should be incremented when the ipk changes.
#
XCB_IPK_VERSION=1

#
# XCB_CONFFILES should be a list of user-editable files
XCB_CONFFILES=

#
# XCB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XCB_PATCHES=$(XCB_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XCB_CPPFLAGS=
XCB_LDFLAGS=

#
# XCB_BUILD_DIR is the directory in which the build is done.
# XCB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XCB_IPK_DIR is the directory in which the ipk is built.
# XCB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XCB_BUILD_DIR=$(BUILD_DIR)/xcb
XCB_SOURCE_DIR=$(SOURCE_DIR)/xcb
XCB_IPK_DIR=$(BUILD_DIR)/xcb-$(XCB_VERSION)-ipk
XCB_IPK=$(BUILD_DIR)/xcb_$(XCB_VERSION)-$(XCB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XCB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XCB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xcb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XCB_PRIORITY)" >>$@
	@echo "Section: $(XCB_SECTION)" >>$@
	@echo "Version: $(XCB_VERSION)-$(XCB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XCB_MAINTAINER)" >>$@
	@echo "Source: $(XCB_SITE)/$(XCB_SOURCE)" >>$@
	@echo "Description: $(XCB_DESCRIPTION)" >>$@
	@echo "Depends: $(XCB_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XCB_SOURCE):
	$(WGET) -P $(@D) $(XCB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xcb-source: $(DL_DIR)/$(XCB_SOURCE) $(XCB_PATCHES)

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
$(XCB_BUILD_DIR)/.configured: $(DL_DIR)/$(XCB_SOURCE) $(XCB_PATCHES) make/xcb.mk
	$(MAKE) xcb-proto-stage pthread-stubs-stage xau-stage
	rm -rf $(BUILD_DIR)/$(XCB_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XCB_SOURCE)
	if test -n "$(XCB_PATCHES)" ; \
		then cat $(XCB_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XCB_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XCB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XCB_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XCB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XCB_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	touch $@

xcb-unpack: $(XCB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XCB_BUILD_DIR)/.built: $(XCB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xcb: $(XCB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XCB_BUILD_DIR)/.staged: $(XCB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/xcb.pc $(STAGING_LIB_DIR)/pkgconfig/xcb-*.pc
	rm -f $(STAGING_LIB_DIR)/libxcb.la $(STAGING_LIB_DIR)/libxcb-*.la
	touch $@

xcb-stage: $(XCB_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XCB_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XCB_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XCB_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XCB_IPK_DIR)$(TARGET_PREFIX)/etc/xcb/...
# Documentation files should be installed in $(XCB_IPK_DIR)$(TARGET_PREFIX)/doc/xcb/...
# Daemon startup scripts should be installed in $(XCB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xcb
#
# You may need to patch your application to make it use these locations.
#
$(XCB_IPK): $(XCB_BUILD_DIR)/.built
	rm -rf $(XCB_IPK_DIR) $(BUILD_DIR)/xcb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XCB_BUILD_DIR) DESTDIR=$(XCB_IPK_DIR) install-strip
	$(MAKE) $(XCB_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(XCB_SOURCE_DIR)/postinst $(XCB_IPK_DIR)/CONTROL/postinst
	rm -f $(XCB_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XCB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xcb-ipk: $(XCB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xcb-clean:
	-$(MAKE) -C $(XCB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xcb-dirclean:
	rm -rf $(BUILD_DIR)/$(XCB_DIR) $(XCB_BUILD_DIR) $(XCB_IPK_DIR) $(XCB_IPK)
