###########################################################
#
# mdadm
#
###########################################################

# You must replace "mdadm" and "MDADM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MDADM_VERSION, MDADM_SITE and MDADM_SOURCE define
# the upstream location of the source code for the package.
# MDADM_DIR is the directory which is created when the source
# archive is unpacked.
# MDADM_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MDADM_SITE=http://www.cse.unsw.edu.au/~neilb/source/mdadm/
MDADM_VERSION=1.8.0
MDADM_SOURCE=mdadm-$(MDADM_VERSION).tgz
MDADM_DIR=mdadm-$(MDADM_VERSION)
MDADM_UNZIP=zcat

#
# MDADM_IPK_VERSION should be incremented when the ipk changes.
#
MDADM_IPK_VERSION=1

#
# MDADM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MDADM_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MDADM_CPPFLAGS=
MDADM_LDFLAGS=

#
# MDADM_BUILD_DIR is the directory in which the build is done.
# MDADM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MDADM_IPK_DIR is the directory in which the ipk is built.
# MDADM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MDADM_BUILD_DIR=$(BUILD_DIR)/mdadm
MDADM_SOURCE_DIR=$(SOURCE_DIR)/mdadm
MDADM_IPK_DIR=$(BUILD_DIR)/mdadm-$(MDADM_VERSION)-ipk
MDADM_IPK=$(BUILD_DIR)/mdadm_$(MDADM_VERSION)-$(MDADM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MDADM_SOURCE):
	$(WGET) -P $(DL_DIR) $(MDADM_SITE)/$(MDADM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mdadm-source: $(DL_DIR)/$(MDADM_SOURCE) $(MDADM_PATCHES)

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
$(MDADM_BUILD_DIR)/.configured: $(DL_DIR)/$(MDADM_SOURCE) $(MDADM_PATCHES)
	rm -rf $(BUILD_DIR)/$(MDADM_DIR) $(MDADM_BUILD_DIR)
	$(MDADM_UNZIP) $(DL_DIR)/$(MDADM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MDADM_PATCHES) | patch -d $(BUILD_DIR)/$(MDADM_DIR) -p1
	mv $(BUILD_DIR)/$(MDADM_DIR) $(MDADM_BUILD_DIR)
	touch $(MDADM_BUILD_DIR)/.configured

mdadm-unpack: $(MDADM_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(MDADM_BUILD_DIR)/mdadm: $(MDADM_BUILD_DIR)/.configured
	$(MAKE) -C $(MDADM_BUILD_DIR) CC=$(TARGET_CC) DESTDIR="$(MDADM_BUILD_DIR)/opt/"

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
mdadm: $(MDADM_BUILD_DIR)/mdadm

#
# If you are building a library, then you need to stage it too.
#


#
# This builds the IPK file.
#
# Binaries should be installed into $(MDADM_IPK_DIR)/opt/sbin or $(MDADM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MDADM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MDADM_IPK_DIR)/opt/etc/mdadm/...
# Documentation files should be installed in $(MDADM_IPK_DIR)/opt/doc/mdadm/...
# Daemon startup scripts should be installed in $(MDADM_IPK_DIR)/opt/etc/init.d/S??mdadm
#
# You may need to patch your application to make it use these locations.
#
$(MDADM_IPK): $(MDADM_BUILD_DIR)/mdadm
	rm -rf $(MDADM_IPK_DIR) $(MDADM_IPK)
	install -d $(MDADM_IPK_DIR)/opt/sbin
	install -d $(MDADM_IPK_DIR)/opt/man/man8
	install -d $(MDADM_IPK_DIR)/opt/man/man4
	install -d $(MDADM_IPK_DIR)/opt/man/man5
	$(STRIP_COMMAND) $(MDADM_BUILD_DIR)/mdadm -o $(MDADM_IPK_DIR)/opt/sbin/mdadm
	install -d $(MDADM_IPK_DIR)/CONTROL
	install -m 644 $(MDADM_SOURCE_DIR)/control $(MDADM_IPK_DIR)/CONTROL/control
	install -m 644 $(MDADM_BUILD_DIR)/mdadm.8 $(MDADM_IPK_DIR)/opt/man/man8
	install -m 644 $(MDADM_BUILD_DIR)/md.4 $(MDADM_IPK_DIR)/opt/man/man4
	install -m 644 $(MDADM_BUILD_DIR)/mdadm.conf.5 $(MDADM_IPK_DIR)/opt/man/man5/mdadm.c
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MDADM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mdadm-ipk: $(MDADM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mdadm-clean:
	-$(MAKE) -C $(MDADM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mdadm-dirclean:
	rm -rf $(BUILD_DIR)/$(MDADM_DIR) $(MDADM_BUILD_DIR) $(MDADM_IPK_DIR) $(MDADM_IPK)
