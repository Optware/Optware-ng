###########################################################
#
# gimp-print
#
###########################################################

# You must replace "gimp-print" and "GIMP-PRINT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIMP-PRINT_VERSION, GIMP-PRINT_SITE and GIMP-PRINT_SOURCE define
# the upstream location of the source code for the package.
# GIMP-PRINT_DIR is the directory which is created when the source
# archive is unpacked.
# GIMP-PRINT_UNZIP is the command used to unzip the source.
# It is usually "bzcat" (for .bz2) or "bbzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIMP-PRINT_SITE=http://unc.dl.sourceforge.net/sourceforge/gimp-print
GIMP-PRINT_VERSION=5.0.0-beta2
GIMP-PRINT_SOURCE=gimp-print-$(GIMP-PRINT_VERSION).tar.bz2
GIMP-PRINT_DIR=gimp-print-$(GIMP-PRINT_VERSION)
GIMP-PRINT_UNZIP=bzcat

#
# GIMP-PRINT_IPK_VERSION should be incremented when the ipk changes.
#
GIMP-PRINT_IPK_VERSION=1

#
# GIMP-PRINT_CONFFILES should be a list of user-editable files
GIMP-PRINT_CONFFILES=/opt/etc/gimp-print.conf /opt/etc/init.d/SXXgimp-print

#
## GIMP-PRINT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIMP-PRINT_PATCHES=$(GIMP-PRINT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIMP-PRINT_CPPFLAGS=
GIMP-PRINT_LDFLAGS=

#
# GIMP-PRINT_BUILD_DIR is the directory in which the build is done.
# GIMP-PRINT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIMP-PRINT_IPK_DIR is the directory in which the ipk is built.
# GIMP-PRINT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIMP-PRINT_BUILD_DIR=$(BUILD_DIR)/gimp-print
GIMP-PRINT_SOURCE_DIR=$(SOURCE_DIR)/gimp-print
GIMP-PRINT_IPK_DIR=$(BUILD_DIR)/gimp-print-$(GIMP-PRINT_VERSION)-ipk
GIMP-PRINT_IPK=$(BUILD_DIR)/gimp-print_$(GIMP-PRINT_VERSION)-$(GIMP-PRINT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIMP-PRINT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIMP-PRINT_SITE)/$(GIMP-PRINT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.bz2, .bz2, etc.)
#
#gimp-print-source: $(DL_DIR)/$(GIMP-PRINT_SOURCE) $(GIMP-PRINT_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.bz2 or .tar.bz2, then you will need
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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(GIMP-PRINT_BUILD_DIR)/.configured: $(DL_DIR)/$(GIMP-PRINT_SOURCE) $(GIMP-PRINT_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GIMP-PRINT_DIR) $(GIMP-PRINT_BUILD_DIR)
	$(GIMP-PRINT_UNZIP) $(DL_DIR)/$(GIMP-PRINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIMP-PRINT_PATCHES) | patch -d $(BUILD_DIR)/$(GIMP-PRINT_DIR) -p1
	mv $(BUILD_DIR)/$(GIMP-PRINT_DIR) $(GIMP-PRINT_BUILD_DIR)
	(cd $(GIMP-PRINT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIMP-PRINT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIMP-PRINT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIMP-PRINT_BUILD_DIR)/.configured

gimp-print-unpack: $(GIMP-PRINT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GIMP-PRINT_BUILD_DIR)/.built: $(GIMP-PRINT_BUILD_DIR)/.configured
	rm -f $(GIMP-PRINT_BUILD_DIR)/.built
	$(MAKE) -C $(GIMP-PRINT_BUILD_DIR)
	touch $(GIMP-PRINT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
gimp-print: $(GIMP-PRINT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GIMP-PRINT_BUILD_DIR)/.staged: $(GIMP-PRINT_BUILD_DIR)/.built
	rm -f $(GIMP-PRINT_BUILD_DIR)/.staged
	$(MAKE) -C $(GIMP-PRINT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(GIMP-PRINT_BUILD_DIR)/.staged

gimp-print-stage: $(GIMP-PRINT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIMP-PRINT_IPK_DIR)/opt/sbin or $(GIMP-PRINT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIMP-PRINT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIMP-PRINT_IPK_DIR)/opt/etc/gimp-print/...
# Documentation files should be installed in $(GIMP-PRINT_IPK_DIR)/opt/doc/gimp-print/...
# Daemon startup scripts should be installed in $(GIMP-PRINT_IPK_DIR)/opt/etc/init.d/S??gimp-print
#
# You may need to patch your application to make it use these locations.
#
$(GIMP-PRINT_IPK): $(GIMP-PRINT_BUILD_DIR)/.built
	rm -rf $(GIMP-PRINT_IPK_DIR) $(BUILD_DIR)/gimp-print_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GIMP-PRINT_BUILD_DIR) DESTDIR=$(GIMP-PRINT_IPK_DIR) install-strip
	install -d $(GIMP-PRINT_IPK_DIR)/CONTROL
	install -m 644 $(GIMP-PRINT_SOURCE_DIR)/control $(GIMP-PRINT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIMP-PRINT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gimp-print-ipk: $(GIMP-PRINT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gimp-print-clean:
	-$(MAKE) -C $(GIMP-PRINT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gimp-print-dirclean:
	rm -rf $(BUILD_DIR)/$(GIMP-PRINT_DIR) $(GIMP-PRINT_BUILD_DIR) $(GIMP-PRINT_IPK_DIR) $(GIMP-PRINT_IPK)
