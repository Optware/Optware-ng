###########################################################
#
# parted
#
###########################################################

# You must replace "parted" and "PARTED" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PARTED_VERSION, PARTED_SITE and PARTED_SOURCE define
# the upstream location of the source code for the package.
# PARTED_DIR is the directory which is created when the source
# archive is unpacked.
# PARTED_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PARTED_SITE=http://ftp.gnu.org/gnu/parted/
PARTED_VERSION=1.6.21
PARTED_SOURCE=parted-$(PARTED_VERSION).tar.gz
PARTED_DIR=parted-$(PARTED_VERSION)
PARTED_UNZIP=zcat

#
# PARTED_IPK_VERSION should be incremented when the ipk changes.
#
PARTED_IPK_VERSION=1

#
# PARTED_CONFFILES should be a list of user-editable files
PARTED_CONFFILES=
# /opt/etc/parted.conf /opt/etc/init.d/SXXparted

#
# PARTED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PARTED_PATCHES=
#$(PARTED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PARTED_CPPFLAGS=
PARTED_LDFLAGS=

#
# PARTED_BUILD_DIR is the directory in which the build is done.
# PARTED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PARTED_IPK_DIR is the directory in which the ipk is built.
# PARTED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PARTED_BUILD_DIR=$(BUILD_DIR)/parted
PARTED_SOURCE_DIR=$(SOURCE_DIR)/parted
PARTED_IPK_DIR=$(BUILD_DIR)/parted-$(PARTED_VERSION)-ipk
PARTED_IPK=$(BUILD_DIR)/parted_$(PARTED_VERSION)-$(PARTED_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PARTED_SOURCE):
	$(WGET) -P $(DL_DIR) $(PARTED_SITE)/$(PARTED_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
parted-source: $(DL_DIR)/$(PARTED_SOURCE) $(PARTED_PATCHES)

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
$(PARTED_BUILD_DIR)/.configured: $(DL_DIR)/$(PARTED_SOURCE) $(PARTED_PATCHES)
	$(MAKE) e2fsprogs-stage libiconv-stage
	rm -rf $(BUILD_DIR)/$(PARTED_DIR) $(PARTED_BUILD_DIR)
	$(PARTED_UNZIP) $(DL_DIR)/$(PARTED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PARTED_PATCHES) | patch -d $(BUILD_DIR)/$(PARTED_DIR) -p1
	mv $(BUILD_DIR)/$(PARTED_DIR) $(PARTED_BUILD_DIR)
	(cd $(PARTED_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PARTED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PARTED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-readline \
		--disable-nls \
	)
	touch $(PARTED_BUILD_DIR)/.configured

parted-unpack: $(PARTED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PARTED_BUILD_DIR)/.built: $(PARTED_BUILD_DIR)/.configured
	rm -f $(PARTED_BUILD_DIR)/.built
	$(MAKE) -C $(PARTED_BUILD_DIR)
	touch $(PARTED_BUILD_DIR)/.built

#
# This is the build convenience target.
#
parted: $(PARTED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PARTED_BUILD_DIR)/.staged: $(PARTED_BUILD_DIR)/.built
#	rm -f $(PARTED_BUILD_DIR)/.staged
#	$(MAKE) -C $(PARTED_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(PARTED_BUILD_DIR)/.staged

parted-stage: $(PARTED_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PARTED_IPK_DIR)/opt/sbin or $(PARTED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PARTED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PARTED_IPK_DIR)/opt/etc/parted/...
# Documentation files should be installed in $(PARTED_IPK_DIR)/opt/doc/parted/...
# Daemon startup scripts should be installed in $(PARTED_IPK_DIR)/opt/etc/init.d/S??parted
#
# You may need to patch your application to make it use these locations.
#
$(PARTED_IPK): $(PARTED_BUILD_DIR)/.built
	rm -rf $(PARTED_IPK_DIR) $(BUILD_DIR)/parted_*_armeb.ipk
	$(MAKE) -C $(PARTED_BUILD_DIR) DESTDIR=$(PARTED_IPK_DIR) install
#	install -d $(PARTED_IPK_DIR)/opt/etc/
#	install -m 644 $(PARTED_SOURCE_DIR)/parted.conf $(PARTED_IPK_DIR)/opt/etc/parted.conf
#	install -d $(PARTED_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PARTED_SOURCE_DIR)/rc.parted $(PARTED_IPK_DIR)/opt/etc/init.d/SXXparted
	install -d $(PARTED_IPK_DIR)/CONTROL
	install -m 644 $(PARTED_SOURCE_DIR)/control $(PARTED_IPK_DIR)/CONTROL/control
#	install -m 644 $(PARTED_SOURCE_DIR)/postinst $(PARTED_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PARTED_SOURCE_DIR)/prerm $(PARTED_IPK_DIR)/CONTROL/prerm
#	echo $(PARTED_CONFFILES) | sed -e 's/ /\n/g' > $(PARTED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PARTED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
parted-ipk: $(PARTED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
parted-clean:
	-$(MAKE) -C $(PARTED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
parted-dirclean:
	rm -rf $(BUILD_DIR)/$(PARTED_DIR) $(PARTED_BUILD_DIR) $(PARTED_IPK_DIR) $(PARTED_IPK)
