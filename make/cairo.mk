###########################################################
#
# cairo
#
###########################################################

#
# CAIRO_VERSION, CAIRO_SITE and CAIRO_SOURCE define
# the upstream location of the source code for the package.
# CAIRO_DIR is the directory which is created when the source
# archive is unpacked.
# CAIRO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
CAIRO_SITE=http://cairographics.org/releases
CAIRO_VERSION=1.14.2
CAIRO_SOURCE=cairo-$(CAIRO_VERSION).tar.xz
CAIRO_DIR=cairo-$(CAIRO_VERSION)
CAIRO_UNZIP=xzcat
CAIRO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CAIRO_DESCRIPTION=Cairo is a vector graphics library with cross-device output support.
CAIRO_SECTION=lib
CAIRO_PRIORITY=optional
CAIRO_DEPENDS=freetype, fontconfig, libpng, pixman, xrender, xext

#
# CAIRO_IPK_VERSION should be incremented when the ipk changes.
#
CAIRO_IPK_VERSION=2

#
# CAIRO_LOCALES defines which locales get installed
#
CAIRO_LOCALES=

#
# CAIRO_CONFFILES should be a list of user-editable files
#CAIRO_CONFFILES=$(TARGET_PREFIX)/etc/cairo.conf $(TARGET_PREFIX)/etc/init.d/SXXcairo

#
# CAIRO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CAIRO_PATCHES=$(CAIRO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CAIRO_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
CAIRO_LDFLAGS=

#
# CAIRO_BUILD_DIR is the directory in which the build is done.
# CAIRO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CAIRO_IPK_DIR is the directory in which the ipk is built.
# CAIRO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CAIRO_BUILD_DIR=$(BUILD_DIR)/cairo
CAIRO_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/cairo
CAIRO_SOURCE_DIR=$(SOURCE_DIR)/cairo
CAIRO_IPK_DIR=$(BUILD_DIR)/cairo-$(CAIRO_VERSION)-ipk
CAIRO_IPK=$(BUILD_DIR)/cairo_$(CAIRO_VERSION)-$(CAIRO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(CAIRO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cairo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CAIRO_PRIORITY)" >>$@
	@echo "Section: $(CAIRO_SECTION)" >>$@
	@echo "Version: $(CAIRO_VERSION)-$(CAIRO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CAIRO_MAINTAINER)" >>$@
	@echo "Source: $(CAIRO_SITE)/$(CAIRO_SOURCE)" >>$@
	@echo "Description: $(CAIRO_DESCRIPTION)" >>$@
	@echo "Depends: $(CAIRO_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CAIRO_SOURCE):
	$(WGET) -P $(@D) $(CAIRO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cairo-source: $(DL_DIR)/$(CAIRO_SOURCE) $(CAIRO_PATCHES)

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
$(CAIRO_BUILD_DIR)/.configured: $(DL_DIR)/$(CAIRO_SOURCE) $(CAIRO_PATCHES) make/cairo.mk
	$(MAKE) freetype-stage fontconfig-stage libpng-stage pixman-stage xrender-stage xext-stage
	rm -rf $(BUILD_DIR)/$(CAIRO_DIR) $(CAIRO_BUILD_DIR)
	$(CAIRO_UNZIP) $(DL_DIR)/$(CAIRO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(CAIRO_DIR) $(CAIRO_BUILD_DIR)
	(cd $(CAIRO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CAIRO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CAIRO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--enable-ft=yes \
		--enable-fc=yes \
		ac_cv_func_XRenderCreateLinearGradient=yes \
		ac_cv_func_XRenderCreateRadialGradient=yes \
		ac_cv_func_XRenderCreateConicalGradient=yes \
	)
	$(PATCH_LIBTOOL) $(CAIRO_BUILD_DIR)/libtool
	touch $@

cairo-unpack: $(CAIRO_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CAIRO_BUILD_DIR)/.built: $(CAIRO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CAIRO_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
cairo: $(CAIRO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CAIRO_BUILD_DIR)/.staged: $(CAIRO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install-strip prefix=$(STAGING_PREFIX)
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/cairo*.pc
	rm -f $(STAGING_LIB_DIR)/libcairo*.la
	touch $@

cairo-stage: $(CAIRO_BUILD_DIR)/.staged

$(CAIRO_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(CAIRO_SOURCE) $(CAIRO_PATCHES) make/cairo.mk
	$(MAKE) glib-host-stage freetype-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(CAIRO_DIR) $(@D)
	$(CAIRO_UNZIP) $(DL_DIR)/$(CAIRO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(CAIRO_DIR) $(@D)
	(cd $(@D); \
		CPPFLAGS="-I$(HOST_STAGING_INCLUDE_DIR) -I$(HOST_STAGING_INCLUDE_DIR)/freetype2" \
		LDFLAGS="-L$(HOST_STAGING_LIB_DIR) -fPIC" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX) \
		--disable-shared \
		--enable-xlib=no \
		--enable-xlib-xrender=no \
		--enable-xcb=no \
		--enable-xlib-xcb=no \
		--enable-xcb-shm=no \
		--enable-ft=yes \
		--enable-fc=no \
	)
	$(MAKE) -C $(@D) install
	rm -f $(HOST_STAGING_LIB_DIR)/libcairo.la
	touch $@

cairo-host-stage: $(CAIRO_HOST_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/etc/cairo/...
# Documentation files should be installed in $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/doc/cairo/...
# Daemon startup scripts should be installed in $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cairo
#
# You may need to patch your application to make it use these locations.
#
$(CAIRO_IPK): $(CAIRO_BUILD_DIR)/.built
	rm -rf $(CAIRO_IPK_DIR) $(BUILD_DIR)/cairo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CAIRO_BUILD_DIR) DESTDIR=$(CAIRO_IPK_DIR) install-strip
	rm -f $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	rm -rf $(CAIRO_IPK_DIR)$(TARGET_PREFIX)/share/gtk-doc
	$(MAKE) $(CAIRO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CAIRO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cairo-ipk: $(CAIRO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cairo-clean:
	-$(MAKE) -C $(CAIRO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cairo-dirclean:
	rm -rf $(BUILD_DIR)/$(CAIRO_DIR) $(CAIRO_BUILD_DIR) $(CAIRO_IPK_DIR) $(CAIRO_IPK)
