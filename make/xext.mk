###########################################################
#
# xext
#
###########################################################

#
# XEXT_VERSION, XEXT_SITE and XEXT_SOURCE define
# the upstream location of the source code for the package.
# XEXT_DIR is the directory which is created when the source
# archive is unpacked.
#
XEXT_SITE=http://xorg.freedesktop.org/releases/individual/lib
XEXT_SOURCE=libXext-$(XEXT_VERSION).tar.gz
XEXT_VERSION=1.3.3
XEXT_FULL_VERSION=release-$(XEXT_VERSION)
XEXT_DIR=libXext-$(XEXT_VERSION)
XEXT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XEXT_DESCRIPTION=X extensions library
XEXT_SECTION=lib
XEXT_PRIORITY=optional
XEXT_DEPENDS=x11

#
# XEXT_IPK_VERSION should be incremented when the ipk changes.
#
XEXT_IPK_VERSION=1

#
# XEXT_CONFFILES should be a list of user-editable files
XEXT_CONFFILES=

#
# XEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XEXT_PATCHES=$(XEXT_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XEXT_CPPFLAGS=
XEXT_LDFLAGS=

#
# XEXT_BUILD_DIR is the directory in which the build is done.
# XEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XEXT_IPK_DIR is the directory in which the ipk is built.
# XEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XEXT_BUILD_DIR=$(BUILD_DIR)/xext
XEXT_SOURCE_DIR=$(SOURCE_DIR)/xext
XEXT_IPK_DIR=$(BUILD_DIR)/xext-$(XEXT_FULL_VERSION)-ipk
XEXT_IPK=$(BUILD_DIR)/xext_$(XEXT_FULL_VERSION)-$(XEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XEXT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XEXT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xext" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XEXT_PRIORITY)" >>$@
	@echo "Section: $(XEXT_SECTION)" >>$@
	@echo "Version: $(XEXT_FULL_VERSION)-$(XEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XEXT_MAINTAINER)" >>$@
	@echo "Source: $(XEXT_SITE)/$(XEXT_SOURCE)" >>$@
	@echo "Description: $(XEXT_DESCRIPTION)" >>$@
	@echo "Depends: $(XEXT_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XEXT_SOURCE):
	$(WGET) -P $(@D) $(XEXT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xext-source: $(DL_DIR)/$(XEXT_SOURCE) $(XEXT_PATCHES)

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
$(XEXT_BUILD_DIR)/.configured: $(DL_DIR)/$(XEXT_SOURCE) $(XEXT_PATCHES) make/xext.mk
	$(MAKE) xextensions-stage x11-stage
	rm -rf $(BUILD_DIR)/$(XEXT_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XEXT_SOURCE)
	if test -n "$(XEXT_PATCHES)" ; \
		then cat $(XEXT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XEXT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XEXT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XEXT_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XEXT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-malloc0returnsnull \
	)
	touch $@

xext-unpack: $(XEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XEXT_BUILD_DIR)/.built: $(XEXT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xext: $(XEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XEXT_BUILD_DIR)/.staged: $(XEXT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xext.pc
	rm -f $(STAGING_LIB_DIR)/libXext.la
	touch $@

xext-stage: $(XEXT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XEXT_IPK_DIR)/opt/sbin or $(XEXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XEXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XEXT_IPK_DIR)/opt/etc/xext/...
# Documentation files should be installed in $(XEXT_IPK_DIR)/opt/doc/xext/...
# Daemon startup scripts should be installed in $(XEXT_IPK_DIR)/opt/etc/init.d/S??xext
#
# You may need to patch your application to make it use these locations.
#
$(XEXT_IPK): $(XEXT_BUILD_DIR)/.built
	rm -rf $(XEXT_IPK_DIR) $(BUILD_DIR)/xext_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XEXT_BUILD_DIR) DESTDIR=$(XEXT_IPK_DIR) install-strip
	$(MAKE) $(XEXT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(XEXT_SOURCE_DIR)/postinst $(XEXT_IPK_DIR)/CONTROL/postinst
	rm -f $(XEXT_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xext-ipk: $(XEXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xext-clean:
	-$(MAKE) -C $(XEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xext-dirclean:
	rm -rf $(BUILD_DIR)/$(XEXT_DIR) $(XEXT_BUILD_DIR) $(XEXT_IPK_DIR) $(XEXT_IPK)
