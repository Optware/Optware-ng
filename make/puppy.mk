###########################################################
#
# puppy
#
###########################################################

# PUPPY_REPOSITORY=:ext:$(LOGNAME)@cvs.sf.net:/cvsroot/puppy
PUPPY_REPOSITORY=:pserver:anonymous@cvs.sf.net:/cvsroot/puppy
PUPPY_VERSION=1.8
PUPPY_SOURCE=puppy-$(PUPPY_VERSION).tar.gz
PUPPY_TAG=-r PUPPY_1_8
PUPPY_MODULE=puppy
PUPPY_DIR=puppy-$(PUPPY_VERSION)
PUPPY_UNZIP=zcat

#
# PUPPY_IPK_VERSION should be incremented when the ipk changes.
#
PUPPY_IPK_VERSION=1

#
# PUPPY_BUILD_DIR is the directory in which the build is done.
# PUPPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PUPPY_IPK_DIR is the directory in which the ipk is built.
# PUPPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PUPPY_BUILD_DIR=$(BUILD_DIR)/puppy
PUPPY_SOURCE_DIR=$(SOURCE_DIR)/puppy
PUPPY_IPK_DIR=$(BUILD_DIR)/puppy-$(PUPPY_VERSION)-ipk
PUPPY_IPK=$(BUILD_DIR)/puppy_$(PUPPY_VERSION)-$(PUPPY_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PUPPY_SOURCE):
	cd $(DL_DIR) ; $(CVS) -d $(PUPPY_REPOSITORY) co $(PUPPY_TAG) $(PUPPY_MODULE)
	mv $(DL_DIR)/$(PUPPY_MODULE) $(DL_DIR)/$(PUPPY_DIR)
	cd $(DL_DIR) ; tar zcvf $(PUPPY_SOURCE) $(PUPPY_DIR)
	rm -rf $(DL_DIR)/$(PUPPY_DIR)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
puppy-source: $(DL_DIR)/$(PUPPY_SOURCE) $(PUPPY_PATCHES)

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
$(PUPPY_BUILD_DIR)/.configured: $(DL_DIR)/$(PUPPY_SOURCE) $(PUPPY_PATCHES)
	rm -rf $(BUILD_DIR)/$(PUPPY_DIR) $(PUPPY_BUILD_DIR)
	$(PUPPY_UNZIP) $(DL_DIR)/$(PUPPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PUPPY_DIR) $(PUPPY_BUILD_DIR)
	touch $(PUPPY_BUILD_DIR)/.configured

puppy-unpack: $(PUPPY_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PUPPY_BUILD_DIR)/puppy: $(PUPPY_BUILD_DIR)/.configured
	$(MAKE) -C $(PUPPY_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) CPPFLAGS="-I$(PUPPY_BUILD_DIR)/puppy"

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
puppy: $(PUPPY_BUILD_DIR)/puppy

#
# This builds the IPK file.
#
# Binaries should be installed into $(PUPPY_IPK_DIR)/opt/sbin or $(PUPPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PUPPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PUPPY_IPK_DIR)/opt/etc/puppy/...
# Documentation files should be installed in $(PUPPY_IPK_DIR)/opt/doc/puppy/...
# Daemon startup scripts should be installed in $(PUPPY_IPK_DIR)/opt/etc/init.d/S??puppy
#
# You may need to patch your application to make it use these locations.
#
$(PUPPY_IPK): $(PUPPY_BUILD_DIR)/puppy
	rm -rf $(PUPPY_IPK_DIR) $(BUILD_DIR)/puppy_*_armeb.ipk
	install -d $(PUPPY_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PUPPY_BUILD_DIR)/puppy -o $(PUPPY_IPK_DIR)/opt/bin/puppy
	install -d $(PUPPY_IPK_DIR)/CONTROL
	install -m 644 $(PUPPY_SOURCE_DIR)/control $(PUPPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PUPPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
puppy-ipk: $(PUPPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
puppy-clean:
	-$(MAKE) -C $(PUPPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
puppy-dirclean:
	rm -rf $(BUILD_DIR)/$(PUPPY_DIR) $(PUPPY_BUILD_DIR) $(PUPPY_IPK_DIR) $(PUPPY_IPK)
