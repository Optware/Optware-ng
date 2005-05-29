###########################################################
#
# madplay
#
###########################################################

# You must replace "madplay" and "MADPLAY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MADPLAY_VERSION, MADPLAY_SITE and MADPLAY_SOURCE define
# the upstream location of the source code for the package.
# MADPLAY_DIR is the directory which is created when the source
# archive is unpacked.
# MADPLAY_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MADPLAY_SITE=http://dl.sourceforge.net/sourceforge/mad
MADPLAY_VERSION=0.15.2b
MADPLAY_SOURCE=madplay-$(MADPLAY_VERSION).tar.gz
MADPLAY_DIR=madplay-$(MADPLAY_VERSION)
MADPLAY_UNZIP=zcat

#
# MADPLAY_IPK_VERSION should be incremented when the ipk changes.
#
MADPLAY_IPK_VERSION=1

#
# MADPLAY_CONFFILES should be a list of user-editable files
MADPLAY_CONFFILES=

#
# MADPLAY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MADPLAY_PATCHES=/dev/null

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MADPLAY_CPPFLAGS=
MADPLAY_LDFLAGS=

#
# MADPLAY_BUILD_DIR is the directory in which the build is done.
# MADPLAY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MADPLAY_IPK_DIR is the directory in which the ipk is built.
# MADPLAY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MADPLAY_BUILD_DIR=$(BUILD_DIR)/madplay
MADPLAY_SOURCE_DIR=$(SOURCE_DIR)/madplay
MADPLAY_IPK_DIR=$(BUILD_DIR)/madplay-$(MADPLAY_VERSION)-ipk
MADPLAY_IPK=$(BUILD_DIR)/madplay_$(MADPLAY_VERSION)-$(MADPLAY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MADPLAY_SOURCE):
	$(WGET) -P $(DL_DIR) $(MADPLAY_SITE)/$(MADPLAY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
madplay-source: $(DL_DIR)/$(MADPLAY_SOURCE) $(MADPLAY_PATCHES)

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
$(MADPLAY_BUILD_DIR)/.configured: $(DL_DIR)/$(MADPLAY_SOURCE) $(MADPLAY_PATCHES)
	$(MAKE) libmad-stage libid3tag-stage
	rm -rf $(BUILD_DIR)/$(MADPLAY_DIR) $(MADPLAY_BUILD_DIR)
	$(MADPLAY_UNZIP) $(DL_DIR)/$(MADPLAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MADPLAY_PATCHES) | patch -d $(BUILD_DIR)/$(MADPLAY_DIR) -p1
	mv $(BUILD_DIR)/$(MADPLAY_DIR) $(MADPLAY_BUILD_DIR)
	(cd $(MADPLAY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MADPLAY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MADPLAY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(MADPLAY_BUILD_DIR)/.configured

madplay-unpack: $(MADPLAY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MADPLAY_BUILD_DIR)/.built: $(MADPLAY_BUILD_DIR)/.configured
	rm -f $(MADPLAY_BUILD_DIR)/.built
	$(MAKE) -C $(MADPLAY_BUILD_DIR)
	touch $(MADPLAY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
madplay: $(MADPLAY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MADPLAY_BUILD_DIR)/.staged: $(MADPLAY_BUILD_DIR)/.built
	rm -f $(MADPLAY_BUILD_DIR)/.staged
	$(MAKE) -C $(MADPLAY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MADPLAY_BUILD_DIR)/.staged

madplay-stage: $(MADPLAY_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(MADPLAY_IPK_DIR)/opt/sbin or $(MADPLAY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MADPLAY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MADPLAY_IPK_DIR)/opt/etc/madplay/...
# Documentation files should be installed in $(MADPLAY_IPK_DIR)/opt/doc/madplay/...
# Daemon startup scripts should be installed in $(MADPLAY_IPK_DIR)/opt/etc/init.d/S??madplay
#
# You may need to patch your application to make it use these locations.
#
$(MADPLAY_IPK): $(MADPLAY_BUILD_DIR)/.built
	rm -rf $(MADPLAY_IPK_DIR) $(BUILD_DIR)/madplay_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MADPLAY_BUILD_DIR) DESTDIR=$(MADPLAY_IPK_DIR) install
	install -d $(MADPLAY_IPK_DIR)/CONTROL
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(MADPLAY_VERSION)/" \
		-e "s/@RELEASE@/$(MADPLAY_IPK_VERSION)/" $(MADPLAY_SOURCE_DIR)/control > $(MADPLAY_IPK_DIR)/CONTROL/control
	echo $(MADPLAY_CONFFILES) | sed -e 's/ /\n/g' > $(MADPLAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MADPLAY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
madplay-ipk: $(MADPLAY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
madplay-clean:
	-$(MAKE) -C $(MADPLAY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
madplay-dirclean:
	rm -rf $(BUILD_DIR)/$(MADPLAY_DIR) $(MADPLAY_BUILD_DIR) $(MADPLAY_IPK_DIR) $(MADPLAY_IPK)
