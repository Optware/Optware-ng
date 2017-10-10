###########################################################
#
# x11
#
###########################################################

#
# X11_VERSION, X11_SITE and X11_SOURCE define
# the upstream location of the source code for the package.
# X11_DIR is the directory which is created when the source
# archive is unpacked.
#
X11_SITE=http://xorg.freedesktop.org/releases/individual/lib
X11_SOURCE=libX11-$(X11_VERSION).tar.gz
X11_VERSION=1.6.2
X11_FULL_VERSION=release-$(X11_VERSION)
X11_DIR=libX11-$(X11_VERSION)
X11_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
X11_DESCRIPTION=X protocol library
X11_SECTION=lib
X11_PRIORITY=optional
X11_DEPENDS=xau, xdmcp, xcb

#
# X11_IPK_VERSION should be incremented when the ipk changes.
#
X11_IPK_VERSION=3

#
# X11_CONFFILES should be a list of user-editable files
X11_CONFFILES=

#
# X11_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#X11_PATCHES=$(X11_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifneq ($(OPTWARE_TARGET), wl500g)
X11_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/X11/Xtrans
else
X11_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/X11/Xtrans -DMB_CUR_MAX=1
endif
X11_LDFLAGS=

#
# X11_BUILD_DIR is the directory in which the build is done.
# X11_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# X11_IPK_DIR is the directory in which the ipk is built.
# X11_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
X11_BUILD_DIR=$(BUILD_DIR)/x11
X11_SOURCE_DIR=$(SOURCE_DIR)/x11
X11_IPK_DIR=$(BUILD_DIR)/x11-$(X11_FULL_VERSION)-ipk
X11_IPK=$(BUILD_DIR)/x11_$(X11_FULL_VERSION)-$(X11_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(X11_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(X11_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: x11" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(X11_PRIORITY)" >>$@
	@echo "Section: $(X11_SECTION)" >>$@
	@echo "Version: $(X11_FULL_VERSION)-$(X11_IPK_VERSION)" >>$@
	@echo "Maintainer: $(X11_MAINTAINER)" >>$@
	@echo "Source: $(X11_SITE)/$(X11_SOURCE)" >>$@
	@echo "Description: $(X11_DESCRIPTION)" >>$@
	@echo "Depends: $(X11_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(X11_SOURCE):
	$(WGET) -P $(@D) $(X11_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

x11-source: $(DL_DIR)/$(X11_SOURCE) $(X11_PATCHES)

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
$(X11_BUILD_DIR)/.configured: $(DL_DIR)/$(X11_SOURCE) $(X11_PATCHES) make/x11.mk
	$(MAKE) xproto-stage kbproto-stage inputproto-stage xextproto-stage xcb-stage
	$(MAKE) xau-stage
	$(MAKE) xextensions-stage
	$(MAKE) xdmcp-stage
	$(MAKE) xtrans-stage
	rm -rf $(BUILD_DIR)/$(X11_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(X11_SOURCE)
	if test -n "$(X11_PATCHES)" ; \
		then cat $(X11_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(X11_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(X11_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(X11_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(X11_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(X11_LDFLAGS)" \
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

x11-unpack: $(X11_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(X11_BUILD_DIR)/.built: $(X11_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
x11: $(X11_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(X11_BUILD_DIR)/.staged: $(X11_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/x11.pc
	rm -f $(STAGING_LIB_DIR)/libX11.la $(STAGING_LIB_DIR)/libX11-xcb.la
	touch $@

x11-stage: $(X11_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(X11_IPK_DIR)$(TARGET_PREFIX)/sbin or $(X11_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(X11_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(X11_IPK_DIR)$(TARGET_PREFIX)/etc/x11/...
# Documentation files should be installed in $(X11_IPK_DIR)$(TARGET_PREFIX)/doc/x11/...
# Daemon startup scripts should be installed in $(X11_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??x11
#
# You may need to patch your application to make it use these locations.
#
$(X11_IPK): $(X11_BUILD_DIR)/.built
	rm -rf $(X11_IPK_DIR) $(BUILD_DIR)/x11_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(X11_BUILD_DIR) DESTDIR=$(X11_IPK_DIR) install-strip
	$(MAKE) $(X11_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(X11_SOURCE_DIR)/postinst $(X11_IPK_DIR)/CONTROL/postinst
	rm -f $(X11_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(X11_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
x11-ipk: $(X11_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
x11-clean:
	-$(MAKE) -C $(X11_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
x11-dirclean:
	rm -rf $(BUILD_DIR)/$(X11_DIR) $(X11_BUILD_DIR) $(X11_IPK_DIR) $(X11_IPK)

#
# Some sanity check for the package.
#
x11-check: $(X11_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
