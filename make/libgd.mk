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
LIBGD_SITE=https://bitbucket.org/libgd/gd-libgd/downloads
LIBGD_VERSION=2.1.0
LIBGD_SOURCE=libgd-$(LIBGD_VERSION).tar.bz2
LIBGD_DIR=libgd-$(LIBGD_VERSION)
LIBGD_UNZIP=bzcat
LIBGD_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
LIBGD_DESCRIPTION=An ANSI C library for the dynamic creation of images
LIBGD_SECTION=lib
LIBGD_PRIORITY=optional
LIBGD_DEPENDS=libpng, libjpeg, freetype, fontconfig
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBGD_DEPENDS+=, libiconv
endif

#
# LIBGD_IPK_VERSION should be incremented when the ipk changes.
#
LIBGD_IPK_VERSION=4

#
# LIBGD_LOCALES defines which locales get installed
#
LIBGD_LOCALES=

#
# LIBGD_CONFFILES should be a list of user-editable files
#LIBGD_CONFFILES=$(TARGET_PREFIX)/etc/libgd.conf $(TARGET_PREFIX)/etc/init.d/SXXlibgd

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
	@$(INSTALL) -d $(@D)
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
	$(WGET) -P $(@D) $(LIBGD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(LIBGD_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGD_SOURCE) $(LIBGD_PATCHES) make/libgd.mk
	$(MAKE) libpng-stage libjpeg-stage freetype-stage fontconfig-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(LIBGD_DIR) $(LIBGD_BUILD_DIR)
	$(LIBGD_UNZIP) $(DL_DIR)/$(LIBGD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBGD_DIR) $(LIBGD_BUILD_DIR)
	sed -i -e 's|libpng12-config --|$(STAGING_PREFIX)/bin/&|' \
	       -e 's|libpng-config --|$(STAGING_PREFIX)/bin/&|' \
	       -e 's|AM_INIT_AUTOMAKE(\[|AM_INIT_AUTOMAKE(\[subdir-objects |' $(@D)/configure.ac
	$(AUTORECONF1.14) -vif $(@D)
	sed -i -e 's/ceill/ceil/g' $(@D)/src/gd_bmp.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_LIBPNG12_CONFIG="$(STAGING_PREFIX)/bin/libpng12-config" \
		ac_cv_path_LIBPNG_CONFIG="$(STAGING_PREFIX)/bin/libpng-config" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--without-x \
		--without-libiconv-prefix \
		--with-png=$(STAGING_PREFIX) \
		--with-jpeg=$(STAGING_PREFIX) \
		--with-freetype=$(STAGING_PREFIX) \
		--with-fontconfig=$(STAGING_PREFIX) \
		--without-xpm \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libgd-unpack: $(LIBGD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBGD_BUILD_DIR)/.built: $(LIBGD_BUILD_DIR)/.configured
	rm -f $@
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) -C $(@D) LIBICONV=-liconv
else
	$(MAKE) -C $(@D) LIBICONV=""
endif
	touch $@

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
	$(MAKE) -C $(@D) install \
		DESTDIR=$(STAGING_DIR) transform=''
	rm -rf $(STAGING_LIB_DIR)/libgd.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
	       -e 's| -L$(TARGET_PREFIX)/lib||g' $(STAGING_PREFIX)/bin/gdlib-config
	touch $@

libgd-stage: $(LIBGD_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/etc/libgd/...
# Documentation files should be installed in $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/doc/libgd/...
# Daemon startup scripts should be installed in $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libgd
#
# You may need to patch your application to make it use these locations.
#
$(LIBGD_IPK): $(LIBGD_BUILD_DIR)/.built
	rm -rf $(LIBGD_IPK_DIR) $(BUILD_DIR)/libgd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGD_BUILD_DIR) DESTDIR=$(LIBGD_IPK_DIR) install-strip transform=''
	rm -f $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	sed -i -e 's|$(STAGING_LIB_DIR)|$(TARGET_PREFIX)/lib|g' $(LIBGD_IPK_DIR)$(TARGET_PREFIX)/bin/gdlib-config
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
