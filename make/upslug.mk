###########################################################
#
# upslug
#
###########################################################

# UPSLUG_REPOSITORY=:ext:$(LOGNAME)@cvs.sf.net:/cvsroot/upslug
UPSLUG_REPOSITORY=:pserver:anonymous@cvs.sf.net:/cvsroot/nslu
UPSLUG_VERSION=1.0
UPSLUG_SOURCE=upslug-$(UPSLUG_VERSION).tar.gz
# UPSLUG_TAG=-r UPSLUG_1_2
UPSLUG_MODULE=upslug
UPSLUG_DIR=upslug-$(UPSLUG_VERSION)
UPSLUG_UNZIP=zcat

#
# UPSLUG_IPK_VERSION should be incremented when the ipk changes.
#
UPSLUG_IPK_VERSION=1

#
# UPSLUG_BUILD_DIR is the directory in which the build is done.
# UPSLUG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UPSLUG_IPK_DIR is the directory in which the ipk is built.
# UPSLUG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UPSLUG_BUILD_DIR=$(BUILD_DIR)/upslug
UPSLUG_SOURCE_DIR=$(SOURCE_DIR)/upslug
UPSLUG_IPK_DIR=$(BUILD_DIR)/upslug-$(UPSLUG_VERSION)-ipk
UPSLUG_IPK=$(BUILD_DIR)/upslug_$(UPSLUG_VERSION)-$(UPSLUG_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UPSLUG_SOURCE):
	cd $(DL_DIR) ; $(CVS) -d $(UPSLUG_REPOSITORY) co $(UPSLUG_TAG) $(UPSLUG_MODULE)
	mv $(DL_DIR)/$(UPSLUG_MODULE) $(DL_DIR)/$(UPSLUG_DIR)
	cd $(DL_DIR) ; tar zcvf $(UPSLUG_SOURCE) $(UPSLUG_DIR)
	rm -rf $(DL_DIR)/$(UPSLUG_DIR)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
upslug-source: $(DL_DIR)/$(UPSLUG_SOURCE) $(UPSLUG_PATCHES)

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
$(UPSLUG_BUILD_DIR)/.configured: $(DL_DIR)/$(UPSLUG_SOURCE) $(UPSLUG_PATCHES)
	rm -rf $(BUILD_DIR)/$(UPSLUG_DIR) $(UPSLUG_BUILD_DIR)
	$(UPSLUG_UNZIP) $(DL_DIR)/$(UPSLUG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(UPSLUG_DIR) $(UPSLUG_BUILD_DIR)
	touch $(UPSLUG_BUILD_DIR)/.configured

upslug-unpack: $(UPSLUG_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(UPSLUG_BUILD_DIR)/upslug: $(UPSLUG_BUILD_DIR)/.configured
	$(MAKE) -C $(UPSLUG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
upslug: $(UPSLUG_BUILD_DIR)/upslug

#
# This builds the IPK file.
#
# Binaries should be installed into $(UPSLUG_IPK_DIR)/opt/sbin or $(UPSLUG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UPSLUG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UPSLUG_IPK_DIR)/opt/etc/upslug/...
# Documentation files should be installed in $(UPSLUG_IPK_DIR)/opt/doc/upslug/...
# Daemon startup scripts should be installed in $(UPSLUG_IPK_DIR)/opt/etc/init.d/S??upslug
#
# You may need to patch your application to make it use these locations.
#
$(UPSLUG_IPK): $(UPSLUG_BUILD_DIR)/upslug
	rm -rf $(UPSLUG_IPK_DIR) $(UPSLUG_IPK)
	install -d $(UPSLUG_IPK_DIR)/opt/bin
	$(TARGET_STRIP) $(UPSLUG_BUILD_DIR)/upslug -o $(UPSLUG_IPK_DIR)/opt/bin/upslug
	install -d $(UPSLUG_IPK_DIR)/CONTROL
	install -m 644 $(UPSLUG_SOURCE_DIR)/control $(UPSLUG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UPSLUG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
upslug-ipk: $(UPSLUG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
upslug-clean:
	-$(MAKE) -C $(UPSLUG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
upslug-dirclean:
	rm -rf $(BUILD_DIR)/$(UPSLUG_DIR) $(UPSLUG_BUILD_DIR) $(UPSLUG_IPK_DIR) $(UPSLUG_IPK)
