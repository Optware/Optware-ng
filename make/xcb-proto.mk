###########################################################
#
# xcb-proto
#
###########################################################

#
# XCB-PROTO_VERSION, XCB-PROTO_SITE and XCB-PROTO_SOURCE define
# the upstream location of the source code for the package.
# XCB-PROTO_DIR is the directory which is created when the source
# archive is unpacked.
# XCB-PROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XCB-PROTO_SITE=http://xorg.freedesktop.org/releases/individual/xcb
XCB-PROTO_SOURCE=xcb-proto-$(XCB-PROTO_VERSION).tar.gz
XCB-PROTO_VERSION=1.11
XCB-PROTO_DIR=xcb-proto-$(XCB-PROTO_VERSION)
XCB-PROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XCB-PROTO_DESCRIPTION=XML-XCB protocol descriptions
XCB-PROTO_SECTION=lib
XCB-PROTO_PRIORITY=optional

#
# XCB-PROTO_IPK_VERSION should be incremented when the ipk changes.
#
XCB-PROTO_IPK_VERSION=1

#
# XCB-PROTO_CONFFILES should be a list of user-editable files
XCB-PROTO_CONFFILES=

#
# XCB-PROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XCB-PROTO_PATCHES=$(XCB-PROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XCB-PROTO_CPPFLAGS=
XCB-PROTO_LDFLAGS=

#
# XCB-PROTO_BUILD_DIR is the directory in which the build is done.
# XCB-PROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XCB-PROTO_IPK_DIR is the directory in which the ipk is built.
# XCB-PROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XCB-PROTO_BUILD_DIR=$(BUILD_DIR)/xcb-proto
XCB-PROTO_SOURCE_DIR=$(SOURCE_DIR)/xcb-proto
XCB-PROTO_IPK_DIR=$(BUILD_DIR)/xcb-proto-$(XCB-PROTO_VERSION)-ipk
XCB-PROTO_IPK=$(BUILD_DIR)/xcb-proto_$(XCB-PROTO_VERSION)-$(XCB-PROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XCB-PROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XCB-PROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xcb-proto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XCB-PROTO_PRIORITY)" >>$@
	@echo "Section: $(XCB-PROTO_SECTION)" >>$@
	@echo "Version: $(XCB-PROTO_VERSION)-$(XCB-PROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XCB-PROTO_MAINTAINER)" >>$@
	@echo "Source: $(XCB-PROTO_SITE)/$(XCB-PROTO_SOURCE)" >>$@
	@echo "Description: $(XCB-PROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XCB-PROTO_SOURCE):
	$(WGET) -P $(@D) $(XCB-PROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xcb-proto-source: $(DL_DIR)/$(XCB-PROTO_SOURCE) $(XCB-PROTO_PATCHES)

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
$(XCB-PROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(XCB-PROTO_SOURCE) $(XCB-PROTO_PATCHES) make/xcb-proto.mk
	rm -rf $(BUILD_DIR)/$(XCB-PROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XCB-PROTO_SOURCE)
	if test -n "$(XCB-PROTO_PATCHES)" ; \
		then cat $(XCB-PROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XCB-PROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XCB-PROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XCB-PROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XCB-PROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XCB-PROTO_LDFLAGS)" \
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

xcb-proto-unpack: $(XCB-PROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XCB-PROTO_BUILD_DIR)/.built: $(XCB-PROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xcb-proto: $(XCB-PROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XCB-PROTO_BUILD_DIR)/.staged: $(XCB-PROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xcb-proto.pc
	touch $@

xcb-proto-stage: $(XCB-PROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XCB-PROTO_IPK_DIR)/opt/sbin or $(XCB-PROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XCB-PROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XCB-PROTO_IPK_DIR)/opt/etc/xcb-proto/...
# Documentation files should be installed in $(XCB-PROTO_IPK_DIR)/opt/doc/xcb-proto/...
# Daemon startup scripts should be installed in $(XCB-PROTO_IPK_DIR)/opt/etc/init.d/S??xcb-proto
#
# You may need to patch your application to make it use these locations.
#
$(XCB-PROTO_IPK): $(XCB-PROTO_BUILD_DIR)/.built
	rm -rf $(XCB-PROTO_IPK_DIR) $(BUILD_DIR)/xcb-proto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XCB-PROTO_BUILD_DIR) DESTDIR=$(XCB-PROTO_IPK_DIR) install
	$(MAKE) $(XCB-PROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XCB-PROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xcb-proto-ipk: $(XCB-PROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xcb-proto-clean:
	-$(MAKE) -C $(XCB-PROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xcb-proto-dirclean:
	rm -rf $(BUILD_DIR)/$(XCB-PROTO_DIR) $(XCB-PROTO_BUILD_DIR) $(XCB-PROTO_IPK_DIR) $(XCB-PROTO_IPK)
