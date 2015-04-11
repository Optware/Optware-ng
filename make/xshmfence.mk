###########################################################
#
# xshmfence
#
###########################################################

#
# XSHMFENCE_VERSION, XSHMFENCE_SITE and XSHMFENCE_SOURCE define
# the upstream location of the source code for the package.
# XSHMFENCE_DIR is the directory which is created when the source
# archive is unpacked.
#
XSHMFENCE_SITE=http://xorg.freedesktop.org/releases/individual/lib
XSHMFENCE_SOURCE=libxshmfence-$(XSHMFENCE_VERSION).tar.gz
XSHMFENCE_VERSION=1.2
XSHMFENCE_FULL_VERSION=$(XSHMFENCE_VERSION)
XSHMFENCE_DIR=libxshmfence-$(XSHMFENCE_VERSION)
XSHMFENCE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XSHMFENCE_DESCRIPTION=Shared memory \'SyncFence\' synchronization primitive
XSHMFENCE_SECTION=lib
XSHMFENCE_PRIORITY=optional
XSHMFENCE_DEPENDS=

#
# XSHMFENCE_IPK_VERSION should be incremented when the ipk changes.
#
XSHMFENCE_IPK_VERSION=1

#
# XSHMFENCE_CONFFILES should be a list of user-editable files
XSHMFENCE_CONFFILES=

#
# XSHMFENCE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XSHMFENCE_PATCHES=$(XSHMFENCE_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XSHMFENCE_CPPFLAGS=
XSHMFENCE_LDFLAGS=

#
# XSHMFENCE_BUILD_DIR is the directory in which the build is done.
# XSHMFENCE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XSHMFENCE_IPK_DIR is the directory in which the ipk is built.
# XSHMFENCE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XSHMFENCE_BUILD_DIR=$(BUILD_DIR)/xshmfence
XSHMFENCE_SOURCE_DIR=$(SOURCE_DIR)/xshmfence
XSHMFENCE_IPK_DIR=$(BUILD_DIR)/xshmfence-$(XSHMFENCE_FULL_VERSION)-ipk
XSHMFENCE_IPK=$(BUILD_DIR)/xshmfence_$(XSHMFENCE_FULL_VERSION)-$(XSHMFENCE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XSHMFENCE_IPK_DIR)/CONTROL/control:
	@install -d $(XSHMFENCE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xshmfence" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XSHMFENCE_PRIORITY)" >>$@
	@echo "Section: $(XSHMFENCE_SECTION)" >>$@
	@echo "Version: $(XSHMFENCE_FULL_VERSION)-$(XSHMFENCE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XSHMFENCE_MAINTAINER)" >>$@
	@echo "Source: $(XSHMFENCE_SITE)/$(XSHMFENCE_SOURCE)" >>$@
	@echo "Description: $(XSHMFENCE_DESCRIPTION)" >>$@
	@echo "Depends: $(XSHMFENCE_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XSHMFENCE_SOURCE):
	$(WGET) -P $(@D) $(XSHMFENCE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xshmfence-source: $(DL_DIR)/$(XSHMFENCE_SOURCE) $(XSHMFENCE_PATCHES)

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
$(XSHMFENCE_BUILD_DIR)/.configured: $(DL_DIR)/$(XSHMFENCE_SOURCE) $(XSHMFENCE_PATCHES) make/xshmfence.mk
	$(MAKE) xorg-macros-stage xproto-stage
	rm -rf $(BUILD_DIR)/$(XSHMFENCE_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XSHMFENCE_SOURCE)
	if test -n "$(XSHMFENCE_PATCHES)" ; \
		then cat $(XSHMFENCE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XSHMFENCE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XSHMFENCE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XSHMFENCE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XSHMFENCE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XSHMFENCE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-malloc0returnsnull \
	)
	touch $@

xshmfence-unpack: $(XSHMFENCE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XSHMFENCE_BUILD_DIR)/.built: $(XSHMFENCE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xshmfence: $(XSHMFENCE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XSHMFENCE_BUILD_DIR)/.staged: $(XSHMFENCE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xshmfence.pc
	rm -f $(STAGING_LIB_DIR)/libxshmfence.la
	touch $@

xshmfence-stage: $(XSHMFENCE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XSHMFENCE_IPK_DIR)/opt/sbin or $(XSHMFENCE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XSHMFENCE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XSHMFENCE_IPK_DIR)/opt/etc/xshmfence/...
# Documentation files should be installed in $(XSHMFENCE_IPK_DIR)/opt/doc/xshmfence/...
# Daemon startup scripts should be installed in $(XSHMFENCE_IPK_DIR)/opt/etc/init.d/S??xshmfence
#
# You may need to patch your application to make it use these locations.
#
$(XSHMFENCE_IPK): $(XSHMFENCE_BUILD_DIR)/.built
	rm -rf $(XSHMFENCE_IPK_DIR) $(BUILD_DIR)/xshmfence_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XSHMFENCE_BUILD_DIR) DESTDIR=$(XSHMFENCE_IPK_DIR) install-strip
	$(MAKE) $(XSHMFENCE_IPK_DIR)/CONTROL/control
#	install -m 644 $(XSHMFENCE_SOURCE_DIR)/postinst $(XSHMFENCE_IPK_DIR)/CONTROL/postinst
	rm -f $(XSHMFENCE_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XSHMFENCE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xshmfence-ipk: $(XSHMFENCE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xshmfence-clean:
	-$(MAKE) -C $(XSHMFENCE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xshmfence-dirclean:
	rm -rf $(BUILD_DIR)/$(XSHMFENCE_DIR) $(XSHMFENCE_BUILD_DIR) $(XSHMFENCE_IPK_DIR) $(XSHMFENCE_IPK)
