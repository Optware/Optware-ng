###########################################################
#
# mpc
#
###########################################################

# You must replace "mpc" and "MPC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MPC_VERSION, MPC_SITE and MPC_SOURCE define
# the upstream location of the source code for the package.
# MPC_DIR is the directory which is created when the source
# archive is unpacked.
# MPC_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MPC_SITE=http://mercury.chem.pitt.edu/~shank
MPC_VERSION=0.11.1
MPC_SOURCE=mpc-$(MPC_VERSION).tar.gz
MPC_DIR=mpc-$(MPC_VERSION)
MPC_UNZIP=zcat

#
# MPC_IPK_VERSION should be incremented when the ipk changes.
#
MPC_IPK_VERSION=1

#
# MPC_CONFFILES should be a list of user-editable files
MPC_CONFFILES=

#
# MPC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MPC_PATCHES=/dev/null

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPC_CPPFLAGS=
MPC_LDFLAGS=

#
# MPC_BUILD_DIR is the directory in which the build is done.
# MPC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPC_IPK_DIR is the directory in which the ipk is built.
# MPC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPC_BUILD_DIR=$(BUILD_DIR)/mpc
MPC_SOURCE_DIR=$(SOURCE_DIR)/mpc
MPC_IPK_DIR=$(BUILD_DIR)/mpc-$(MPC_VERSION)-ipk
MPC_IPK=$(BUILD_DIR)/mpc_$(MPC_VERSION)-$(MPC_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPC_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPC_SITE)/$(MPC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpc-source: $(DL_DIR)/$(MPC_SOURCE) $(MPC_PATCHES)

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
$(MPC_BUILD_DIR)/.configured: $(DL_DIR)/$(MPC_SOURCE) $(MPC_PATCHES)
	rm -rf $(BUILD_DIR)/$(MPC_DIR) $(MPC_BUILD_DIR)
	$(MPC_UNZIP) $(DL_DIR)/$(MPC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MPC_PATCHES) | patch -d $(BUILD_DIR)/$(MPC_DIR) -p1
	mv $(BUILD_DIR)/$(MPC_DIR) $(MPC_BUILD_DIR)
	(cd $(MPC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(MPC_BUILD_DIR)/.configured

mpc-unpack: $(MPC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPC_BUILD_DIR)/.built: $(MPC_BUILD_DIR)/.configured
	rm -f $(MPC_BUILD_DIR)/.built
	$(MAKE) -C $(MPC_BUILD_DIR)
	touch $(MPC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mpc: $(MPC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPC_BUILD_DIR)/.staged: $(MPC_BUILD_DIR)/.built
	rm -f $(MPC_BUILD_DIR)/.staged
	$(MAKE) -C $(MPC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MPC_BUILD_DIR)/.staged

mpc-stage: $(MPC_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPC_IPK_DIR)/opt/sbin or $(MPC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPC_IPK_DIR)/opt/etc/mpc/...
# Documentation files should be installed in $(MPC_IPK_DIR)/opt/doc/mpc/...
# Daemon startup scripts should be installed in $(MPC_IPK_DIR)/opt/etc/init.d/S??mpc
#
# You may need to patch your application to make it use these locations.
#
$(MPC_IPK): $(MPC_BUILD_DIR)/.built
	rm -rf $(MPC_IPK_DIR) $(BUILD_DIR)/mpc_*_armeb.ipk
	$(MAKE) -C $(MPC_BUILD_DIR) DESTDIR=$(MPC_IPK_DIR) install
	install -d $(MPC_IPK_DIR)/CONTROL
	install -m 644 $(MPC_SOURCE_DIR)/control $(MPC_IPK_DIR)/CONTROL/control
	echo $(MPC_CONFFILES) | sed -e 's/ /\n/g' > $(MPC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpc-ipk: $(MPC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpc-clean:
	-$(MAKE) -C $(MPC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpc-dirclean:
	rm -rf $(BUILD_DIR)/$(MPC_DIR) $(MPC_BUILD_DIR) $(MPC_IPK_DIR) $(MPC_IPK)
