###########################################################
#
# wakelan
#
###########################################################

# You must replace "wakelan" and "WAKELAN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WAKELAN_VERSION, WAKELAN_SITE and WAKELAN_SOURCE define
# the upstream location of the source code for the package.
# WAKELAN_DIR is the directory which is created when the source
# archive is unpacked.
# WAKELAN_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
WAKELAN_SITE=ftp://metalab.unc.edu/pub/Linux/system/network/misc/
WAKELAN_VERSION=1.1
WAKELAN_SOURCE=wakelan-$(WAKELAN_VERSION).tar.gz
WAKELAN_DIR=wakelan-$(WAKELAN_VERSION)
WAKELAN_UNZIP=zcat

#
# WAKELAN_IPK_VERSION should be incremented when the ipk changes.
#
WAKELAN_IPK_VERSION=1

#
# WAKELAN_CONFFILES should be a list of user-editable files
#WAKELAN_CONFFILES=

#
# WAKELAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#WAKELAN_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WAKELAN_CPPFLAGS=
WAKELAN_LDFLAGS=

#
# WAKELAN_BUILD_DIR is the directory in which the build is done.
# WAKELAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WAKELAN_IPK_DIR is the directory in which the ipk is built.
# WAKELAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WAKELAN_BUILD_DIR=$(BUILD_DIR)/wakelan
WAKELAN_SOURCE_DIR=$(SOURCE_DIR)/wakelan
WAKELAN_IPK_DIR=$(BUILD_DIR)/wakelan-$(WAKELAN_VERSION)-ipk
WAKELAN_IPK=$(BUILD_DIR)/wakelan_$(WAKELAN_VERSION)-$(WAKELAN_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WAKELAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(WAKELAN_SITE)/$(WAKELAN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wakelan-source: $(DL_DIR)/$(WAKELAN_SOURCE) $(WAKELAN_PATCHES)

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
$(WAKELAN_BUILD_DIR)/.configured: $(DL_DIR)/$(WAKELAN_SOURCE) $(WAKELAN_PATCHES)
	rm -rf $(BUILD_DIR)/$(WAKELAN_DIR) $(WAKELAN_BUILD_DIR)
	$(WAKELAN_UNZIP) $(DL_DIR)/$(WAKELAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(WAKELAN_PATCHES) | patch -d $(BUILD_DIR)/$(WAKELAN_DIR) -p1
	mv $(BUILD_DIR)/$(WAKELAN_DIR) $(WAKELAN_BUILD_DIR)
	(cd $(WAKELAN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WAKELAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WAKELAN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(WAKELAN_BUILD_DIR)/.configured

wakelan-unpack: $(WAKELAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WAKELAN_BUILD_DIR)/.built: $(WAKELAN_BUILD_DIR)/.configured
	rm -f $(WAKELAN_BUILD_DIR)/.built
	$(MAKE) -C $(WAKELAN_BUILD_DIR)
	touch $(WAKELAN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
wakelan: $(WAKELAN_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(WAKELAN_IPK_DIR)/opt/sbin or $(WAKELAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WAKELAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WAKELAN_IPK_DIR)/opt/etc/wakelan/...
# Documentation files should be installed in $(WAKELAN_IPK_DIR)/opt/doc/wakelan/...
# Daemon startup scripts should be installed in $(WAKELAN_IPK_DIR)/opt/etc/init.d/S??wakelan
#
# You may need to patch your application to make it use these locations.
#
$(WAKELAN_IPK): $(WAKELAN_BUILD_DIR)/.built
	rm -rf $(WAKELAN_IPK_DIR) $(BUILD_DIR)/wakelan_*_armeb.ipk
	install -d $(WAKELAN_IPK_DIR)/opt/bin
	install -d $(WAKELAN_IPK_DIR)/opt/man/man1
	$(MAKE) -C $(WAKELAN_BUILD_DIR) prefix=$(WAKELAN_IPK_DIR)/opt install
	install -d $(WAKELAN_IPK_DIR)/CONTROL
	install -m 644 $(WAKELAN_SOURCE_DIR)/control $(WAKELAN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WAKELAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wakelan-ipk: $(WAKELAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wakelan-clean:
	-$(MAKE) -C $(WAKELAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wakelan-dirclean:
	rm -rf $(BUILD_DIR)/$(WAKELAN_DIR) $(WAKELAN_BUILD_DIR) $(WAKELAN_IPK_DIR) $(WAKELAN_IPK)
