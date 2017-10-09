###########################################################
#
# pixman
#
###########################################################

#
# PIXMAN_VERSION, PIXMAN_SITE and PIXMAN_SOURCE define
# the upstream location of the source code for the package.
# PIXMAN_DIR is the directory which is created when the source
# archive is unpacked.
# PIXMAN_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PIXMAN_SITE=http://cairographics.org/releases
PIXMAN_VERSION=0.32.6
PIXMAN_SOURCE=pixman-$(PIXMAN_VERSION).tar.gz
PIXMAN_DIR=pixman-$(PIXMAN_VERSION)
PIXMAN_UNZIP=zcat
PIXMAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PIXMAN_DESCRIPTION=a library that provides low-level pixel manipulation features such as image compositing and trapezoid rasterization
PIXMAN_SECTION=lib
PIXMAN_PRIORITY=optional
PIXMAN_DEPENDS=

#
# PIXMAN_IPK_VERSION should be incremented when the ipk changes.
#
PIXMAN_IPK_VERSION=2

#
# PIXMAN_LOCALES defines which locales get installed
#
PIXMAN_LOCALES=

#
# PIXMAN_CONFFILES should be a list of user-editable files
#PIXMAN_CONFFILES=$(TARGET_PREFIX)/etc/pixman.conf $(TARGET_PREFIX)/etc/init.d/SXXpixman

#
# PIXMAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PIXMAN_PATCHES=
#$(PIXMAN_SOURCE_DIR)/pixman-arm.patch $(PIXMAN_SOURCE_DIR)/AT_HWCAP.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PIXMAN_CPPFLAGS=
PIXMAN_LDFLAGS=

PIXMAN_CONF_ARGS=
ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel buildroot-mipsel-ng, $(OPTWARE_TARGET)))
PIXMAN_CONF_ARGS += --disable-mips-dspr2
endif

#
# PIXMAN_BUILD_DIR is the directory in which the build is done.
# PIXMAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PIXMAN_IPK_DIR is the directory in which the ipk is built.
# PIXMAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PIXMAN_BUILD_DIR=$(BUILD_DIR)/pixman
PIXMAN_SOURCE_DIR=$(SOURCE_DIR)/pixman
PIXMAN_IPK_DIR=$(BUILD_DIR)/pixman-$(PIXMAN_VERSION)-ipk
PIXMAN_IPK=$(BUILD_DIR)/pixman_$(PIXMAN_VERSION)-$(PIXMAN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PIXMAN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: pixman" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PIXMAN_PRIORITY)" >>$@
	@echo "Section: $(PIXMAN_SECTION)" >>$@
	@echo "Version: $(PIXMAN_VERSION)-$(PIXMAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PIXMAN_MAINTAINER)" >>$@
	@echo "Source: $(PIXMAN_SITE)/$(PIXMAN_SOURCE)" >>$@
	@echo "Description: $(PIXMAN_DESCRIPTION)" >>$@
	@echo "Depends: $(PIXMAN_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PIXMAN_SOURCE):
	$(WGET) -P $(@D) $(PIXMAN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pixman-source: $(DL_DIR)/$(PIXMAN_SOURCE) $(PIXMAN_PATCHES)

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
$(PIXMAN_BUILD_DIR)/.configured: $(DL_DIR)/$(PIXMAN_SOURCE) $(PIXMAN_PATCHES) make/pixman.mk
	rm -rf $(BUILD_DIR)/$(PIXMAN_DIR) $(@D)
	$(PIXMAN_UNZIP) $(DL_DIR)/$(PIXMAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PIXMAN_PATCHES)" ; \
		then cat $(PIXMAN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PIXMAN_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PIXMAN_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PIXMAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PIXMAN_LDFLAGS)" \
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
		$(PIXMAN_CONF_ARGS) \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

pixman-unpack: $(PIXMAN_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PIXMAN_BUILD_DIR)/.built: $(PIXMAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
pixman: $(PIXMAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PIXMAN_BUILD_DIR)/.staged: $(PIXMAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR)
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/pixman*.pc
	rm -f $(STAGING_LIB_DIR)/libpixman*.la
	touch $@

pixman-stage: $(PIXMAN_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/etc/pixman/...
# Documentation files should be installed in $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/doc/pixman/...
# Daemon startup scripts should be installed in $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??pixman
#
# You may need to patch your application to make it use these locations.
#
$(PIXMAN_IPK): $(PIXMAN_BUILD_DIR)/.built
	rm -rf $(PIXMAN_IPK_DIR) $(BUILD_DIR)/pixman_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PIXMAN_BUILD_DIR) DESTDIR=$(PIXMAN_IPK_DIR) install-strip
	rm -f $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	rm -rf $(PIXMAN_IPK_DIR)$(TARGET_PREFIX)/share/gtk-doc
	$(MAKE) $(PIXMAN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PIXMAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pixman-ipk: $(PIXMAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pixman-clean:
	-$(MAKE) -C $(PIXMAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pixman-dirclean:
	rm -rf $(BUILD_DIR)/$(PIXMAN_DIR) $(PIXMAN_BUILD_DIR) $(PIXMAN_IPK_DIR) $(PIXMAN_IPK)

#
# Some sanity check for the package.
#
pixman-check: $(PIXMAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
