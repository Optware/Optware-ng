###########################################################
#
# ccxstream
#
###########################################################

CCXSTREAM_SITE=http://belnet.dl.sourceforge.net/sourceforge/xbmc
CCXSTREAM_VERSION=1.0.15
CCXSTREAM_SOURCE=ccxstream-$(CCXSTREAM_VERSION).tar.gz
CCXSTREAM_DIR=ccxstream-$(CCXSTREAM_VERSION)
CCXSTREAM_UNZIP=zcat

#
# CCXSTREAM_IPK_VERSION should be incremented when the ipk changes.
#
CCXSTREAM_IPK_VERSION=1

#
# CCXSTREAM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CCXSTREAM_PATCHES=$(CCXSTREAM_SOURCE_DIR)/ccxstream.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CCXSTREAM_CPPFLAGS=
CCXSTREAM_LDFLAGS=

#
# CCXSTREAM_BUILD_DIR is the directory in which the build is done.
# CCXSTREAM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CCXSTREAM_IPK_DIR is the directory in which the ipk is built.
# CCXSTREAM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CCXSTREAM_BUILD_DIR=$(BUILD_DIR)/ccxstream
CCXSTREAM_SOURCE_DIR=$(SOURCE_DIR)/ccxstream
CCXSTREAM_IPK_DIR=$(BUILD_DIR)/ccxstream-$(CCXSTREAM_VERSION)-ipk
CCXSTREAM_IPK=$(BUILD_DIR)/ccxstream_$(CCXSTREAM_VERSION)-$(CCXSTREAM_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CCXSTREAM_SOURCE):
	$(WGET) -P $(DL_DIR) $(CCXSTREAM_SITE)/$(CCXSTREAM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ccxstream-source: $(DL_DIR)/$(CCXSTREAM_SOURCE) $(CCXSTREAM_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(CCXSTREAM_BUILD_DIR)/.configured: $(DL_DIR)/$(CCXSTREAM_SOURCE) $(CCXSTREAM_PATCHES)
	rm -rf $(BUILD_DIR)/$(CCXSTREAM_DIR) $(CCXSTREAM_BUILD_DIR)
	$(CCXSTREAM_UNZIP) $(DL_DIR)/$(CCXSTREAM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CCXSTREAM_PATCHES) | patch -d $(BUILD_DIR)/$(CCXSTREAM_DIR) -p1
	mv $(BUILD_DIR)/$(CCXSTREAM_DIR) $(CCXSTREAM_BUILD_DIR)
	touch $(CCXSTREAM_BUILD_DIR)/.configured

ccxstream-unpack: $(CCXSTREAM_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CCXSTREAM_BUILD_DIR)/ccxstream: $(CCXSTREAM_BUILD_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(CCXSTREAM_BUILD_DIR)

#
# These are the dependencies for the package (remove ccxstream-dependencies if
# there are no build dependencies for this package.  Again, you should change
# the final dependency to refer directly to the main binary which is built.
#
ccxstream: ccxstream-dependencies $(CCXSTREAM_BUILD_DIR)/ccxstream

#
# This builds the IPK file.
#
# Binaries should be installed into $(CCXSTREAM_IPK_DIR)/opt/sbin or $(CCXSTREAM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CCXSTREAM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CCXSTREAM_IPK_DIR)/opt/etc/ccxstream/...
# Documentation files should be installed in $(CCXSTREAM_IPK_DIR)/opt/doc/ccxstream/...
# Daemon startup scripts should be installed in $(CCXSTREAM_IPK_DIR)/opt/etc/init.d/S??ccxstream
#
# You may need to patch your application to make it use these locations.
#
$(CCXSTREAM_IPK): $(CCXSTREAM_BUILD_DIR)/ccxstream
	rm -rf $(CCXSTREAM_IPK_DIR) $(CCXSTREAM_IPK)
	install -d $(CCXSTREAM_IPK_DIR)/opt/doc/ccxstream
	install -m 644 $(CCXSTREAM_BUILD_DIR)/README $(CCXSTREAM_IPK_DIR)/opt/doc/ccxstream
	install -d $(CCXSTREAM_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(CCXSTREAM_BUILD_DIR)/ccxstream -o $(CCXSTREAM_IPK_DIR)/opt/sbin/ccxstream
	install -d $(CCXSTREAM_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CCXSTREAM_SOURCE_DIR)/rc.ccxstream $(CCXSTREAM_IPK_DIR)/opt/etc/init.d/S75ccxstream
	install -d $(CCXSTREAM_IPK_DIR)/CONTROL
	install -m 644 $(CCXSTREAM_SOURCE_DIR)/control $(CCXSTREAM_IPK_DIR)/CONTROL/control
	install -m 644 $(CCXSTREAM_SOURCE_DIR)/postinst $(CCXSTREAM_IPK_DIR)/CONTROL/postinst
	install -m 644 $(CCXSTREAM_SOURCE_DIR)/prerm $(CCXSTREAM_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CCXSTREAM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ccxstream-ipk: $(CCXSTREAM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ccxstream-clean:
	-$(MAKE) -C $(CCXSTREAM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ccxstream-dirclean:
	rm -rf $(BUILD_DIR)/$(CCXSTREAM_DIR) $(CCXSTREAM_BUILD_DIR) $(CCXSTREAM_IPK_DIR) $(CCXSTREAM_IPK)
