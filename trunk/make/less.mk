###########################################################
#
# less
#
###########################################################

LESS_SITE=http://www.greenwoodsoftware.com/less/
LESS_VERSION=381
LESS_SOURCE=less-$(LESS_VERSION).tar.gz
LESS_DIR=less-$(LESS_VERSION)
LESS_UNZIP=zcat

#
# LESS_IPK_VERSION should be incremented when the ipk changes.
#
LESS_IPK_VERSION=1

#
# LESS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LESS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LESS_CPPFLAGS=
LESS_LDFLAGS=

#
# LESS_BUILD_DIR is the directory in which the build is done.
# LESS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LESS_IPK_DIR is the directory in which the ipk is built.
# LESS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LESS_BUILD_DIR=$(BUILD_DIR)/less
LESS_SOURCE_DIR=$(SOURCE_DIR)/less
LESS_IPK_DIR=$(BUILD_DIR)/less-$(LESS_VERSION)-ipk
LESS_IPK=$(BUILD_DIR)/less_$(LESS_VERSION)-$(LESS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LESS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LESS_SITE)/$(LESS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
less-source: $(DL_DIR)/$(LESS_SOURCE) $(LESS_PATCHES)

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
$(LESS_BUILD_DIR)/.configured: $(DL_DIR)/$(LESS_SOURCE) $(LESS_PATCHES)
	rm -rf $(BUILD_DIR)/$(LESS_DIR) $(LESS_BUILD_DIR)
	$(LESS_UNZIP) $(DL_DIR)/$(LESS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LESS_DIR) $(LESS_BUILD_DIR)
	(cd $(LESS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LESS_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(LESS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LESS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LESS_BUILD_DIR)/.configured

less-unpack: $(LESS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LESS_BUILD_DIR)/less: $(LESS_BUILD_DIR)/.configured
	rm -f $(LESS_BUILD_DIR)/less
	$(MAKE) -C $(LESS_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
less: $(LESS_BUILD_DIR)/less

#
# This builds the IPK file.
#
# Binaries should be installed into $(LESS_IPK_DIR)/opt/sbin or $(LESS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LESS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LESS_IPK_DIR)/opt/etc/less/...
# Documentation files should be installed in $(LESS_IPK_DIR)/opt/doc/less/...
# Daemon startup scripts should be installed in $(LESS_IPK_DIR)/opt/etc/init.d/S??less
#
# You may need to patch your application to make it use these locations.
#
$(LESS_IPK): $(LESS_BUILD_DIR)/less
	rm -rf $(LESS_IPK_DIR) $(BUILD_DIR)/less_*_$(TARGET_ARCH).ipk
	install -d $(LESS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(LESS_BUILD_DIR)/less -o $(LESS_IPK_DIR)/opt/bin/less
	install -d $(LESS_IPK_DIR)/CONTROL
	install -m 644 $(LESS_SOURCE_DIR)/control $(LESS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LESS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
less-ipk: $(LESS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
less-clean:
	-$(MAKE) -C $(LESS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
less-dirclean:
	rm -rf $(BUILD_DIR)/$(LESS_DIR) $(LESS_BUILD_DIR) $(LESS_IPK_DIR) $(LESS_IPK)
