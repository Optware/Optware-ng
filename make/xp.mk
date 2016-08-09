###########################################################
#
# xp
#
###########################################################

#
# XP_VERSION, XP_SITE and XP_SOURCE define
# the upstream location of the source code for the package.
# XP_DIR is the directory which is created when the source
# archive is unpacked.
#
XP_SITE=http://xorg.freedesktop.org/releases/individual/lib
XP_SOURCE=libXp-$(XP_VERSION).tar.gz
XP_VERSION=1.0.3
XP_FULL_VERSION=r$(XP_VERSION)
XP_DIR=libXp-$(XP_VERSION)
XP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XP_DESCRIPTION=libXp - X Print Client Library
XP_SECTION=lib
XP_PRIORITY=optional
XP_DEPENDS=x11, xext

#
# XP_IPK_VERSION should be incremented when the ipk changes.
#
XP_IPK_VERSION=2

#
# XP_CONFFILES should be a list of user-editable files
XP_CONFFILES=

#
# XP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XP_PATCHES=$(XP_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XP_CPPFLAGS=
XP_LDFLAGS=

#
# XP_BUILD_DIR is the directory in which the build is done.
# XP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XP_IPK_DIR is the directory in which the ipk is built.
# XP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XP_BUILD_DIR=$(BUILD_DIR)/xp
XP_SOURCE_DIR=$(SOURCE_DIR)/xp
XP_IPK_DIR=$(BUILD_DIR)/xp-$(XP_FULL_VERSION)-ipk
XP_IPK=$(BUILD_DIR)/xp_$(XP_FULL_VERSION)-$(XP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XP_PRIORITY)" >>$@
	@echo "Section: $(XP_SECTION)" >>$@
	@echo "Version: $(XP_FULL_VERSION)-$(XP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XP_MAINTAINER)" >>$@
	@echo "Source: $(XP_SITE)/$(XP_SOURCE)" >>$@
	@echo "Description: $(XP_DESCRIPTION)" >>$@
	@echo "Depends: $(XP_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XP_SOURCE):
	$(WGET) -P $(@D) $(XP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xp-source: $(DL_DIR)/$(XP_SOURCE) $(XP_PATCHES)

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
$(XP_BUILD_DIR)/.configured: $(DL_DIR)/$(XP_SOURCE) $(XP_PATCHES) make/xp.mk
	$(MAKE) xorg-macros-stage x11-stage xext-stage xau-stage \
		xextproto-stage printproto-stage
	rm -rf $(BUILD_DIR)/$(XP_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XP_SOURCE)
	if test -n "$(XP_PATCHES)" ; \
		then cat $(XP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XP_LDFLAGS)" \
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

xp-unpack: $(XP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XP_BUILD_DIR)/.built: $(XP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xp: $(XP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XP_BUILD_DIR)/.staged: $(XP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xp.pc
	rm -f $(STAGING_LIB_DIR)/libXp.la
	touch $@

xp-stage: $(XP_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XP_IPK_DIR)$(TARGET_PREFIX)/etc/xp/...
# Documentation files should be installed in $(XP_IPK_DIR)$(TARGET_PREFIX)/doc/xp/...
# Daemon startup scripts should be installed in $(XP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xp
#
# You may need to patch your application to make it use these locations.
#
$(XP_IPK): $(XP_BUILD_DIR)/.built
	rm -rf $(XP_IPK_DIR) $(BUILD_DIR)/xp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XP_BUILD_DIR) DESTDIR=$(XP_IPK_DIR) install-strip
	$(MAKE) $(XP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(XP_SOURCE_DIR)/postinst $(XP_IPK_DIR)/CONTROL/postinst
	rm -f $(XP_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xp-ipk: $(XP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xp-clean:
	-$(MAKE) -C $(XP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xp-dirclean:
	rm -rf $(BUILD_DIR)/$(XP_DIR) $(XP_BUILD_DIR) $(XP_IPK_DIR) $(XP_IPK)
