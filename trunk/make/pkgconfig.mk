###########################################################
#
# pkgconfig
#
###########################################################

#
# PKGCONFIG_VERSION, PKGCONFIG_SITE and PKGCONFIG_SOURCE define
# the upstream location of the source code for the package.
# PKGCONFIG_DIR is the directory which is created when the source
# archive is unpacked.
# PKGCONFIG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PKGCONFIG_SITE=http://www.freedesktop.org/software/pkgconfig/releases
PKGCONFIG_VERSION=0.15.0
PKGCONFIG_SOURCE=pkgconfig-$(PKGCONFIG_VERSION).tar.gz
PKGCONFIG_DIR=pkgconfig-$(PKGCONFIG_VERSION)
PKGCONFIG_UNZIP=zcat
PKGCONFIG_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PKGCONFIG_DESCRIPTION=Package configuration tool
PKGCONFIG_SECTION=util
PKGCONFIG_PRIORITY=optional
PKGCONFIG_DEPENDS=

#
# PKGCONFIG_IPK_VERSION should be incremented when the ipk changes.
#
PKGCONFIG_IPK_VERSION=1

#
# PKGCONFIG_LOCALES defines which locales get installed
#
PKGCONFIG_LOCALES=

#
# PKGCONFIG_CONFFILES should be a list of user-editable files
#PKGCONFIG_CONFFILES=/opt/etc/pkgconfig.conf /opt/etc/init.d/SXXpkgconfig

#
# PKGCONFIG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PKGCONFIG_PATCHES=$(PKGCONFIG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PKGCONFIG_CPPFLAGS=
PKGCONFIG_LDFLAGS=

#
# PKGCONFIG_BUILD_DIR is the directory in which the build is done.
# PKGCONFIG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PKGCONFIG_IPK_DIR is the directory in which the ipk is built.
# PKGCONFIG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PKGCONFIG_BUILD_DIR=$(BUILD_DIR)/pkgconfig
PKGCONFIG_SOURCE_DIR=$(SOURCE_DIR)/pkgconfig
PKGCONFIG_IPK_DIR=$(BUILD_DIR)/pkgconfig-$(PKGCONFIG_VERSION)-ipk
PKGCONFIG_IPK=$(BUILD_DIR)/pkgconfig_$(PKGCONFIG_VERSION)-$(PKGCONFIG_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(PKGCONFIG_IPK_DIR)/CONTROL/control:
	@install -d $(PKGCONFIG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pkgconfig" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(PKGCONFIG_PRIORITY)" >>$@
	@echo "Section: $(PKGCONFIG_SECTION)" >>$@
	@echo "Version: $(PKGCONFIG_VERSION)-$(PKGCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PKGCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(PKGCONFIG_SITE)/$(PKGCONFIG_SOURCE)" >>$@
	@echo "Description: $(PKGCONFIG_DESCRIPTION)" >>$@
	@echo "Depends: $(PKGCONFIG_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PKGCONFIG_SOURCE):
	$(WGET) -P $(DL_DIR) $(PKGCONFIG_SITE)/$(PKGCONFIG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pkgconfig-source: $(DL_DIR)/$(PKGCONFIG_SOURCE) $(PKGCONFIG_PATCHES)

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
$(PKGCONFIG_BUILD_DIR)/.configured: $(DL_DIR)/$(PKGCONFIG_SOURCE) $(PKGCONFIG_PATCHES)
	rm -rf $(BUILD_DIR)/$(PKGCONFIG_DIR) $(PKGCONFIG_BUILD_DIR)
	$(PKGCONFIG_UNZIP) $(DL_DIR)/$(PKGCONFIG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PKGCONFIG_PATCHES) | patch -d $(BUILD_DIR)/$(PKGCONFIG_DIR) -p1
	mv $(BUILD_DIR)/$(PKGCONFIG_DIR) $(PKGCONFIG_BUILD_DIR)
	(cd $(PKGCONFIG_BUILD_DIR); autoconf)
	(cd $(PKGCONFIG_BUILD_DIR)/glib-1.2.8; aclocal-1.9 -I .; autoconf)
	cp $(PKGCONFIG_SOURCE_DIR)/pkgconfig.cache $(PKGCONFIG_BUILD_DIR)/arm.cache
	cp $(PKGCONFIG_SOURCE_DIR)/glibconfig-sysdefs.h $(PKGCONFIG_BUILD_DIR)/glib-1.2.8
	(cd $(PKGCONFIG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS=`echo $(STAGING_CPPFLAGS) $(PKGCONFIG_CPPFLAGS)` \
		LDFLAGS=`echo $(STAGING_LDFLAGS) $(PKGCONFIG_LDFLAGS)` \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--cache-file=arm.cache \
		--disable-threads \
		--disable-shared \
	)
	touch $(PKGCONFIG_BUILD_DIR)/.configured

pkgconfig-unpack: $(PKGCONFIG_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PKGCONFIG_BUILD_DIR)/.built: $(PKGCONFIG_BUILD_DIR)/.configured
	rm -f $(PKGCONFIG_BUILD_DIR)/.built
	$(MAKE) -C $(PKGCONFIG_BUILD_DIR)
	touch $(PKGCONFIG_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
pkgconfig: $(PKGCONFIG_BUILD_DIR)/.built

# Binaries should be installed into $(PKGCONFIG_IPK_DIR)/opt/sbin or $(PKGCONFIG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PKGCONFIG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PKGCONFIG_IPK_DIR)/opt/etc/pkgconfig/...
# Documentation files should be installed in $(PKGCONFIG_IPK_DIR)/opt/doc/pkgconfig/...
# Daemon startup scripts should be installed in $(PKGCONFIG_IPK_DIR)/opt/etc/init.d/S??pkgconfig
#
# You may need to patch your application to make it use these locations.
#
$(PKGCONFIG_IPK): $(PKGCONFIG_BUILD_DIR)/.built
	rm -rf $(PKGCONFIG_IPK_DIR) $(BUILD_DIR)/pkgconfig_*_armeb.ipk
	$(MAKE) -C $(PKGCONFIG_BUILD_DIR) DESTDIR=$(PKGCONFIG_IPK_DIR) install-strip
	$(MAKE) $(PKGCONFIG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PKGCONFIG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pkgconfig-ipk: $(PKGCONFIG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pkgconfig-clean:
	-$(MAKE) -C $(PKGCONFIG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pkgconfig-dirclean:
	rm -rf $(BUILD_DIR)/$(PKGCONFIG_DIR) $(PKGCONFIG_BUILD_DIR) $(PKGCONFIG_IPK_DIR) $(PKGCONFIG_IPK)
