###########################################################
#
# scponly
#
###########################################################

# You must replace "scponly" and "SCPONLY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SCPONLY_VERSION, SCPONLY_SITE and SCPONLY_SOURCE define
# the upstream location of the source code for the package.
# SCPONLY_DIR is the directory which is created when the source
# archive is unpacked.
# SCPONLY_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SCPONLY_SITE=http://www.sublimation.org/scponly
SCPONLY_VERSION=3.11
SCPONLY_SOURCE=scponly-$(SCPONLY_VERSION).tgz
SCPONLY_DIR=scponly-$(SCPONLY_VERSION)
SCPONLY_UNZIP=zcat

#
# SCPONLY_IPK_VERSION should be incremented when the ipk changes.
#
SCPONLY_IPK_VERSION=1

#
# SCPONLY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SCPONLY_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCPONLY_CPPFLAGS=
SCPONLY_LDFLAGS=

#
# SCPONLY_BUILD_DIR is the directory in which the build is done.
# SCPONLY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCPONLY_IPK_DIR is the directory in which the ipk is built.
# SCPONLY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCPONLY_BUILD_DIR=$(BUILD_DIR)/scponly
SCPONLY_SOURCE_DIR=$(SOURCE_DIR)/scponly
SCPONLY_IPK_DIR=$(BUILD_DIR)/scponly-$(SCPONLY_VERSION)-ipk
SCPONLY_IPK=$(BUILD_DIR)/scponly_$(SCPONLY_VERSION)-$(SCPONLY_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCPONLY_SOURCE):
	$(WGET) -P $(DL_DIR) $(SCPONLY_SITE)/$(SCPONLY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
scponly-source: $(DL_DIR)/$(SCPONLY_SOURCE) $(SCPONLY_PATCHES)

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
$(SCPONLY_BUILD_DIR)/.configured: $(DL_DIR)/$(SCPONLY_SOURCE) $(SCPONLY_PATCHES)
	rm -rf $(BUILD_DIR)/$(SCPONLY_DIR) $(SCPONLY_BUILD_DIR)
	$(SCPONLY_UNZIP) $(DL_DIR)/$(SCPONLY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(SCPONLY_DIR) $(SCPONLY_BUILD_DIR)
	(cd $(SCPONLY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SCPONLY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SCPONLY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(SCPONLY_BUILD_DIR)/.configured

scponly-unpack: $(SCPONLY_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(SCPONLY_BUILD_DIR)/scponly: $(SCPONLY_BUILD_DIR)/.configured
	$(MAKE) -C $(SCPONLY_BUILD_DIR) PROG_SCP="/opt/bin/scp"

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
scponly: $(SCPONLY_BUILD_DIR)/scponly


#
# This builds the IPK file.
#
# Binaries should be installed into $(SCPONLY_IPK_DIR)/opt/sbin or $(SCPONLY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCPONLY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCPONLY_IPK_DIR)/opt/etc/scponly/...
# Documentation files should be installed in $(SCPONLY_IPK_DIR)/opt/doc/scponly/...
# Daemon startup scripts should be installed in $(SCPONLY_IPK_DIR)/opt/etc/init.d/S??scponly
#
# You may need to patch your application to make it use these locations.
#
$(SCPONLY_IPK): $(SCPONLY_BUILD_DIR)/scponly
	rm -rf $(SCPONLY_IPK_DIR) $(SCPONLY_IPK)
	install -d $(SCPONLY_IPK_DIR)/opt/bin
	$(TARGET_STRIP) $(SCPONLY_BUILD_DIR)/scponly -o $(SCPONLY_IPK_DIR)/opt/bin/scponly
	$(TARGET_STRIP) $(SCPONLY_BUILD_DIR)/groups -o $(SCPONLY_IPK_DIR)/opt/bin/groups
	install -d $(SCPONLY_IPK_DIR)/CONTROL
	install -m 644 $(SCPONLY_SOURCE_DIR)/control $(SCPONLY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCPONLY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
scponly-ipk: $(SCPONLY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
scponly-clean:
	-$(MAKE) -C $(SCPONLY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
scponly-dirclean:
	rm -rf $(BUILD_DIR)/$(SCPONLY_DIR) $(SCPONLY_BUILD_DIR) $(SCPONLY_IPK_DIR) $(SCPONLY_IPK)
