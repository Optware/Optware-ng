###########################################################
#
# alsa-oss
#
###########################################################

# You must replace "alsa-oss" and "ALSA-OSS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ALSA-OSS_VERSION, ALSA-OSS_SITE and ALSA-OSS_SOURCE define
# the upstream location of the source code for the package.
# ALSA-OSS_DIR is the directory which is created when the source
# archive is unpacked.
# ALSA-OSS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ALSA-OSS_SITE=ftp://ftp.alsa-project.org/pub/oss-lib
ALSA-OSS_VERSION=1.0.8
ALSA-OSS_SOURCE=alsa-oss-$(ALSA-OSS_VERSION).tar.bz2
ALSA-OSS_DIR=alsa-oss-$(ALSA-OSS_VERSION)
ALSA-OSS_UNZIP=bzcat

#
# ALSA-OSS_IPK_VERSION should be incremented when the ipk changes.
#
ALSA-OSS_IPK_VERSION=1

#
# ALSA-OSS_CONFFILES should be a list of user-editable files
ALSA-OSS_CONFFILES=

#
# ALSA-OSS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ALSA-OSS_PATCHES=/dev/null

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ALSA-OSS_CPPFLAGS=
ALSA-OSS_LDFLAGS=

#
# ALSA-OSS_BUILD_DIR is the directory in which the build is done.
# ALSA-OSS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ALSA-OSS_IPK_DIR is the directory in which the ipk is built.
# ALSA-OSS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ALSA-OSS_BUILD_DIR=$(BUILD_DIR)/alsa-oss
ALSA-OSS_SOURCE_DIR=$(SOURCE_DIR)/alsa-oss
ALSA-OSS_IPK_DIR=$(BUILD_DIR)/alsa-oss-$(ALSA-OSS_VERSION)-ipk
ALSA-OSS_IPK=$(BUILD_DIR)/alsa-oss_$(ALSA-OSS_VERSION)-$(ALSA-OSS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ALSA-OSS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ALSA-OSS_SITE)/$(ALSA-OSS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
alsa-oss-source: $(DL_DIR)/$(ALSA-OSS_SOURCE) $(ALSA-OSS_PATCHES)

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
$(ALSA-OSS_BUILD_DIR)/.configured: $(DL_DIR)/$(ALSA-OSS_SOURCE) $(ALSA-OSS_PATCHES)
	$(MAKE) alsa-lib-stage
	rm -rf $(BUILD_DIR)/$(ALSA-OSS_DIR) $(ALSA-OSS_BUILD_DIR)
	$(ALSA-OSS_UNZIP) $(DL_DIR)/$(ALSA-OSS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ALSA-OSS_PATCHES) | patch -d $(BUILD_DIR)/$(ALSA-OSS_DIR) -p1
	mv $(BUILD_DIR)/$(ALSA-OSS_DIR) $(ALSA-OSS_BUILD_DIR)
	(cd $(ALSA-OSS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ALSA-OSS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ALSA-OSS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(ALSA-OSS_BUILD_DIR)/.configured

alsa-oss-unpack: $(ALSA-OSS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ALSA-OSS_BUILD_DIR)/.built: $(ALSA-OSS_BUILD_DIR)/.configured
	rm -f $(ALSA-OSS_BUILD_DIR)/.built
	$(MAKE) -C $(ALSA-OSS_BUILD_DIR)
	touch $(ALSA-OSS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
alsa-oss: $(ALSA-OSS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ALSA-OSS_BUILD_DIR)/.staged: $(ALSA-OSS_BUILD_DIR)/.built
	rm -f $(ALSA-OSS_BUILD_DIR)/.staged
	$(MAKE) -C $(ALSA-OSS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ALSA-OSS_BUILD_DIR)/.staged

alsa-oss-stage: $(ALSA-OSS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ALSA-OSS_IPK_DIR)/opt/sbin or $(ALSA-OSS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ALSA-OSS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ALSA-OSS_IPK_DIR)/opt/etc/alsa-oss/...
# Documentation files should be installed in $(ALSA-OSS_IPK_DIR)/opt/doc/alsa-oss/...
# Daemon startup scripts should be installed in $(ALSA-OSS_IPK_DIR)/opt/etc/init.d/S??alsa-oss
#
# You may need to patch your application to make it use these locations.
#
$(ALSA-OSS_IPK): $(ALSA-OSS_BUILD_DIR)/.built
	rm -rf $(ALSA-OSS_IPK_DIR) $(BUILD_DIR)/alsa-oss_*_armeb.ipk
	$(MAKE) -C $(ALSA-OSS_BUILD_DIR) DESTDIR=$(ALSA-OSS_IPK_DIR) install
	install -d $(ALSA-OSS_IPK_DIR)/CONTROL
	install -m 644 $(ALSA-OSS_SOURCE_DIR)/control $(ALSA-OSS_IPK_DIR)/CONTROL/control
	echo $(ALSA-OSS_CONFFILES) | sed -e 's/ /\n/g' > $(ALSA-OSS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ALSA-OSS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
alsa-oss-ipk: $(ALSA-OSS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
alsa-oss-clean:
	-$(MAKE) -C $(ALSA-OSS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
alsa-oss-dirclean:
	rm -rf $(BUILD_DIR)/$(ALSA-OSS_DIR) $(ALSA-OSS_BUILD_DIR) $(ALSA-OSS_IPK_DIR) $(ALSA-OSS_IPK)
