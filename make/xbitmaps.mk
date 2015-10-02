###########################################################
#
# xbitmaps
#
###########################################################

#
# XBITMAPS_VERSION, XBITMAPS_SITE and XBITMAPS_SOURCE define
# the upstream location of the source code for the package.
# XBITMAPS_DIR is the directory which is created when the source
# archive is unpacked.
# XBITMAPS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XBITMAPS_SITE=http://xorg.freedesktop.org/releases/individual/data
XBITMAPS_SOURCE=xbitmaps-$(XBITMAPS_VERSION).tar.gz
XBITMAPS_VERSION=1.1.1
XBITMAPS_DIR=xbitmaps-$(XBITMAPS_VERSION)
XBITMAPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XBITMAPS_DESCRIPTION=The package contains bitmap images used by multiple Xorg applications. 
XBITMAPS_SECTION=lib
XBITMAPS_PRIORITY=optional

#
# XBITMAPS_IPK_VERSION should be incremented when the ipk changes.
#
XBITMAPS_IPK_VERSION=1

#
# XBITMAPS_CONFFILES should be a list of user-editable files
XBITMAPS_CONFFILES=

#
# XBITMAPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XBITMAPS_PATCHES=$(XBITMAPS_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XBITMAPS_CPPFLAGS=
XBITMAPS_LDFLAGS=

#
# XBITMAPS_BUILD_DIR is the directory in which the build is done.
# XBITMAPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XBITMAPS_IPK_DIR is the directory in which the ipk is built.
# XBITMAPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XBITMAPS_BUILD_DIR=$(BUILD_DIR)/xbitmaps
XBITMAPS_SOURCE_DIR=$(SOURCE_DIR)/xbitmaps
XBITMAPS_IPK_DIR=$(BUILD_DIR)/xbitmaps-$(XBITMAPS_VERSION)-ipk
XBITMAPS_IPK=$(BUILD_DIR)/xbitmaps_$(XBITMAPS_VERSION)-$(XBITMAPS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XBITMAPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XBITMAPS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xbitmaps" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XBITMAPS_PRIORITY)" >>$@
	@echo "Section: $(XBITMAPS_SECTION)" >>$@
	@echo "Version: $(XBITMAPS_VERSION)-$(XBITMAPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XBITMAPS_MAINTAINER)" >>$@
	@echo "Source: $(XBITMAPS_SITE)/$(XBITMAPS_SOURCE)" >>$@
	@echo "Description: $(XBITMAPS_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XBITMAPS_SOURCE):
	$(WGET) -P $(@D) $(XBITMAPS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xbitmaps-source: $(DL_DIR)/$(XBITMAPS_SOURCE) $(XBITMAPS_PATCHES)

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
$(XBITMAPS_BUILD_DIR)/.configured: $(DL_DIR)/$(XBITMAPS_SOURCE) $(XBITMAPS_PATCHES) make/xbitmaps.mk
	rm -rf $(BUILD_DIR)/$(XBITMAPS_DIR) $(@D)
	$(MAKE) xorg-macros-stage
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XBITMAPS_SOURCE)
	if test -n "$(XBITMAPS_PATCHES)" ; \
		then cat $(XBITMAPS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XBITMAPS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XBITMAPS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XBITMAPS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XBITMAPS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XBITMAPS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $@

xbitmaps-unpack: $(XBITMAPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XBITMAPS_BUILD_DIR)/.built: $(XBITMAPS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xbitmaps: $(XBITMAPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XBITMAPS_BUILD_DIR)/.staged: $(XBITMAPS_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xbitmaps.pc
	touch $@

xbitmaps-stage: $(XBITMAPS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XBITMAPS_IPK_DIR)/opt/sbin or $(XBITMAPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XBITMAPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XBITMAPS_IPK_DIR)/opt/etc/xbitmaps/...
# Documentation files should be installed in $(XBITMAPS_IPK_DIR)/opt/doc/xbitmaps/...
# Daemon startup scripts should be installed in $(XBITMAPS_IPK_DIR)/opt/etc/init.d/S??xbitmaps
#
# You may need to patch your application to make it use these locations.
#
$(XBITMAPS_IPK): $(XBITMAPS_BUILD_DIR)/.built
	rm -rf $(XBITMAPS_IPK_DIR) $(BUILD_DIR)/xbitmaps_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XBITMAPS_BUILD_DIR) DESTDIR=$(XBITMAPS_IPK_DIR) install
	$(MAKE) $(XBITMAPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XBITMAPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xbitmaps-ipk: $(XBITMAPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xbitmaps-clean:
	-$(MAKE) -C $(XBITMAPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xbitmaps-dirclean:
	rm -rf $(BUILD_DIR)/$(XBITMAPS_DIR) $(XBITMAPS_BUILD_DIR) $(XBITMAPS_IPK_DIR) $(XBITMAPS_IPK)
