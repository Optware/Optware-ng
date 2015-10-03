###########################################################
#
# libzip
#
###########################################################

#
# LIBZIP_VERSION, LIBZIP_SITE and LIBZIP_SOURCE define
# the upstream location of the source code for the package.
# LIBZIP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBZIP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
LIBZIP_SITE=http://www.nih.at/libzip
LIBZIP_VERSION=0.11.2
LIBZIP_SOURCE=libzip-$(LIBZIP_VERSION).tar.gz
LIBZIP_DIR=libzip-$(LIBZIP_VERSION)
LIBZIP_UNZIP=zcat
LIBZIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBZIP_DESCRIPTION=libzip is a C library for reading, creating, and modifying zip archives
LIBZIP_SECTION=lib
LIBZIP_PRIORITY=optional
LIBZIP_DEPENDS=

#
# LIBZIP_IPK_VERSION should be incremented when the ipk changes.
#
LIBZIP_IPK_VERSION=1

#
# LIBZIP_LOCALES defines which locales get installed
#
LIBZIP_LOCALES=

#
# LIBZIP_CONFFILES should be a list of user-editable files
#LIBZIP_CONFFILES=/opt/etc/libzip.conf /opt/etc/init.d/SXXlibzip

#
# LIBZIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBZIP_PATCHES=$(LIBZIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBZIP_CPPFLAGS=
LIBZIP_LDFLAGS=

#
# LIBZIP_BUILD_DIR is the directory in which the build is done.
# LIBZIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBZIP_IPK_DIR is the directory in which the ipk is built.
# LIBZIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBZIP_BUILD_DIR=$(BUILD_DIR)/libzip
LIBZIP_SOURCE_DIR=$(SOURCE_DIR)/libzip
LIBZIP_IPK_DIR=$(BUILD_DIR)/libzip-$(LIBZIP_VERSION)-ipk
LIBZIP_IPK=$(BUILD_DIR)/libzip_$(LIBZIP_VERSION)-$(LIBZIP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libzip-source libzip-unpack libzip libzip-stage libzip-ipk libzip-clean libzip-dirclean libzip-check

#
# Automatically create a ipkg control file
#
$(LIBZIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libzip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBZIP_PRIORITY)" >>$@
	@echo "Section: $(LIBZIP_SECTION)" >>$@
	@echo "Version: $(LIBZIP_VERSION)-$(LIBZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBZIP_MAINTAINER)" >>$@
	@echo "Source: $(LIBZIP_SITE)/$(LIBZIP_SOURCE)" >>$@
	@echo "Description: $(LIBZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBZIP_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBZIP_SOURCE):
	$(WGET) -P $(@D) $(LIBZIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libzip-source: $(DL_DIR)/$(LIBZIP_SOURCE) $(LIBZIP_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(LIBZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBZIP_SOURCE) $(LIBZIP_PATCHES) make/libzip.mk
	rm -rf $(BUILD_DIR)/$(LIBZIP_DIR) $(LIBZIP_BUILD_DIR)
	$(LIBZIP_UNZIP) $(DL_DIR)/$(LIBZIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBZIP_DIR) $(LIBZIP_BUILD_DIR)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBZIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBZIP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libzip-unpack: $(LIBZIP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBZIP_BUILD_DIR)/.built: $(LIBZIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libzip: $(LIBZIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBZIP_BUILD_DIR)/.staged: $(LIBZIP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR)
	cp -f $(LIBZIP_BUILD_DIR)/lib/*.h $(STAGING_INCLUDE_DIR)/
	rm -f $(STAGING_LIB_DIR)/libzip.la
	rm -rf $(STAGING_LIB_DIR)/libzip
	sed -i -e 's|libincludedir=.*||' -e 's|Cflags:.*|Cflags: -I\$${includedir}|' \
						$(STAGING_LIB_DIR)/pkgconfig/libzip.pc
	touch $@

libzip-stage: $(LIBZIP_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBZIP_IPK_DIR)/opt/sbin or $(LIBZIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBZIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBZIP_IPK_DIR)/opt/etc/libzip/...
# Documentation files should be installed in $(LIBZIP_IPK_DIR)/opt/doc/libzip/...
# Daemon startup scripts should be installed in $(LIBZIP_IPK_DIR)/opt/etc/init.d/S??libzip
#
# You may need to patch your application to make it use these locations.
#
$(LIBZIP_IPK): $(LIBZIP_BUILD_DIR)/.built
	rm -rf $(LIBZIP_IPK_DIR) $(BUILD_DIR)/libzip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBZIP_BUILD_DIR) DESTDIR=$(LIBZIP_IPK_DIR) install-strip
	cp -f $(LIBZIP_BUILD_DIR)/lib/*.h $(LIBZIP_IPK_DIR)/opt/include/
	rm -f $(LIBZIP_IPK_DIR)/opt/lib/libzip.la
	rm -rf $(LIBZIP_IPK_DIR)/opt/lib/libzip
	sed -i -e 's|libincludedir=.*||' -e 's|Cflags:.*|Cflags: -I\$${includedir}|' \
					$(LIBZIP_IPK_DIR)/opt/lib/pkgconfig/libzip.pc
	$(MAKE) $(LIBZIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBZIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libzip-ipk: $(LIBZIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libzip-clean:
	-$(MAKE) -C $(LIBZIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libzip-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBZIP_DIR) $(LIBZIP_BUILD_DIR) $(LIBZIP_IPK_DIR) $(LIBZIP_IPK)

#
# Some sanity check for the package.
#
libzip-check: $(LIBZIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBZIP_IPK)
