###########################################################
#
# libgd
#
###########################################################

#
# LIBGD_VERSION, LIBGD_SITE and LIBGD_SOURCE define
# the upstream location of the source code for the package.
# LIBGD_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
LIBGD_SITE=http://www.libgd.org/releases
LIBGD_VERSION=2.0.35
LIBGD_SOURCE=gd-$(LIBGD_VERSION).tar.bz2
LIBGD_DIR=gd-$(LIBGD_VERSION)
LIBGD_UNZIP=bzcat
LIBGD_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
LIBGD_DESCRIPTION=An ANSI C library for the dynamic creation of images
LIBGD_SECTION=lib
LIBGD_PRIORITY=optional
LIBGD_DEPENDS=libpng, libjpeg, freetype, fontconfig

#
# LIBGD_IPK_VERSION should be incremented when the ipk changes.
#
LIBGD_IPK_VERSION=1

#
# LIBGD_LOCALES defines which locales get installed
#
LIBGD_LOCALES=

#
# LIBGD_CONFFILES should be a list of user-editable files
#LIBGD_CONFFILES=/opt/etc/libgd.conf /opt/etc/init.d/SXXlibgd

#
# LIBGD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBGD_PATCHES=$(LIBGD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGD_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
ifneq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBGD_CPPFLAGS+= -DLIBICONV_PLUG
endif
LIBGD_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# LIBGD_BUILD_DIR is the directory in which the build is done.
# LIBGD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGD_IPK_DIR is the directory in which the ipk is built.
# LIBGD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGD_BUILD_DIR=$(BUILD_DIR)/libgd
LIBGD_SOURCE_DIR=$(SOURCE_DIR)/libgd
LIBGD_IPK_DIR=$(BUILD_DIR)/libgd-$(LIBGD_VERSION)-ipk
LIBGD_IPK=$(BUILD_DIR)/libgd_$(LIBGD_VERSION)-$(LIBGD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgd-source libgd-unpack libgd libgd-stage libgd-ipk libgd-clean libgd-dirclean libgd-check

#
# Automatically create a ipkg control file
#
$(LIBGD_IPK_DIR)/CONTROL/control:
	@install -d $(LIBGD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libgd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGD_PRIORITY)" >>$@
	@echo "Section: $(LIBGD_SECTION)" >>$@
	@echo "Version: $(LIBGD_VERSION)-$(LIBGD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGD_MAINTAINER)" >>$@
	@echo "Source: $(LIBGD_SITE)/$(LIBGD_SOURCE)" >>$@
	@echo "Description: $(LIBGD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGD_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGD_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBGD_SITE)/$(LIBGD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgd-source: $(DL_DIR)/$(LIBGD_SOURCE) $(LIBGD_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(LIBGD_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGD_SOURCE) \
		$(LIBGD_PATCHES)
	$(MAKE) libpng-stage libjpeg-stage freetype-stage fontconfig-stage
	rm -rf $(BUILD_DIR)/$(LIBGD_DIR) $(LIBGD_BUILD_DIR)
	$(LIBGD_UNZIP) $(DL_DIR)/$(LIBGD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBGD_DIR) $(LIBGD_BUILD_DIR)
	(cd $(LIBGD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/opt/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--without-x \
		--without-libiconv-prefix \
		--with-png=$(STAGING_DIR)/opt \
		--with-jpeg=$(STAGING_DIR)/opt \
		--with-freetype=$(STAGING_DIR)/opt \
		--with-fontconfig=$(STAGING_DIR)/opt \
		--without-xpm \
	)
	$(PATCH_LIBTOOL) $(LIBGD_BUILD_DIR)/libtool
	touch $(LIBGD_BUILD_DIR)/.configured

libgd-unpack: $(LIBGD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBGD_BUILD_DIR)/.built: $(LIBGD_BUILD_DIR)/.configured
	rm -f $(LIBGD_BUILD_DIR)/.built
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/opt/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
	$(MAKE) -C $(LIBGD_BUILD_DIR)
	touch $(LIBGD_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libgd: $(LIBGD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGD_BUILD_DIR)/.staged: $(LIBGD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBGD_BUILD_DIR) install DESTDIR=$(STAGING_DIR)
	rm -rf $(STAGING_DIR)/opt/lib/libgd.la
	touch $@

libgd-stage: $(LIBGD_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGD_IPK_DIR)/opt/sbin or $(LIBGD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGD_IPK_DIR)/opt/etc/libgd/...
# Documentation files should be installed in $(LIBGD_IPK_DIR)/opt/doc/libgd/...
# Daemon startup scripts should be installed in $(LIBGD_IPK_DIR)/opt/etc/init.d/S??libgd
#
# You may need to patch your application to make it use these locations.
#
$(LIBGD_IPK): $(LIBGD_BUILD_DIR)/.built
	rm -rf $(LIBGD_IPK_DIR) $(BUILD_DIR)/libgd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGD_BUILD_DIR) DESTDIR=$(LIBGD_IPK_DIR) install-strip transform=''
	rm -f $(LIBGD_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(LIBGD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgd-ipk: $(LIBGD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgd-clean:
	-$(MAKE) -C $(LIBGD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgd-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGD_DIR) $(LIBGD_BUILD_DIR) $(LIBGD_IPK_DIR) $(LIBGD_IPK)

#
# Some sanity check for the package.
#
libgd-check: $(LIBGD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBGD_IPK)
