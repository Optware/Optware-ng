###########################################################
#
# libiconv
#
###########################################################

# You must replace "libiconv" and "LIBICONV" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBICONV_VERSION, LIBICONV_SITE and LIBICONV_SOURCE define
# the upstream location of the source code for the package.
# LIBICONV_DIR is the directory which is created when the source
# archive is unpacked.
# LIBICONV_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBICONV_SITE=http://ftp.gnu.org/pub/gnu/libiconv
LIBICONV_VERSION=1.9.1
LIBICONV_SOURCE=libiconv-$(LIBICONV_VERSION).tar.gz
LIBICONV_DIR=libiconv-$(LIBICONV_VERSION)
LIBICONV_UNZIP=zcat

#
# LIBICONV_IPK_VERSION should be incremented when the ipk changes.
#
LIBICONV_IPK_VERSION=1

#
# LIBICONV_CONFFILES should be a list of user-editable files
LIBICONV_CONFFILES=/opt/etc/libiconv.conf /opt/etc/init.d/SXXlibiconv

#
# LIBICONV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBICONV_PATCHES=$(LIBICONV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBICONV_CPPFLAGS=
LIBICONV_LDFLAGS=

#
# LIBICONV_BUILD_DIR is the directory in which the build is done.
# LIBICONV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBICONV_IPK_DIR is the directory in which the ipk is built.
# LIBICONV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBICONV_BUILD_DIR=$(BUILD_DIR)/libiconv
LIBICONV_SOURCE_DIR=$(SOURCE_DIR)/libiconv
LIBICONV_IPK_DIR=$(BUILD_DIR)/libiconv-$(LIBICONV_VERSION)-ipk
LIBICONV_IPK=$(BUILD_DIR)/libiconv_$(LIBICONV_VERSION)-$(LIBICONV_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBICONV_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBICONV_SITE)/$(LIBICONV_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libiconv-source: $(DL_DIR)/$(LIBICONV_SOURCE) $(LIBICONV_PATCHES)

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
$(LIBICONV_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBICONV_SOURCE) $(LIBICONV_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBICONV_DIR) $(LIBICONV_BUILD_DIR)
	$(LIBICONV_UNZIP) $(DL_DIR)/$(LIBICONV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBICONV_PATCHES) | patch -d $(BUILD_DIR)/$(LIBICONV_DIR) -p1
	mv $(BUILD_DIR)/$(LIBICONV_DIR) $(LIBICONV_BUILD_DIR)
	(cd $(LIBICONV_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBICONV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBICONV_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LIBICONV_BUILD_DIR)/.configured

libiconv-unpack: $(LIBICONV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBICONV_BUILD_DIR)/.built: $(LIBICONV_BUILD_DIR)/.configured
	rm -f $(LIBICONV_BUILD_DIR)/.built
	$(MAKE) -C $(LIBICONV_BUILD_DIR)
	touch $(LIBICONV_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libiconv: $(LIBICONV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libiconv.so: $(LIBICONV_BUILD_DIR)/.built
	$(MAKE) -C $(LIBICONV_BUILD_DIR) install prefix=$(STAGING_DIR)/opt

libiconv-stage: $(STAGING_DIR)/opt/lib/libiconv.so

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBICONV_IPK_DIR)/opt/sbin or $(LIBICONV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBICONV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBICONV_IPK_DIR)/opt/etc/libiconv/...
# Documentation files should be installed in $(LIBICONV_IPK_DIR)/opt/doc/libiconv/...
# Daemon startup scripts should be installed in $(LIBICONV_IPK_DIR)/opt/etc/init.d/S??libiconv
#
# You may need to patch your application to make it use these locations.
#
$(LIBICONV_IPK): $(LIBICONV_BUILD_DIR)/.built
	rm -rf $(LIBICONV_IPK_DIR) $(BUILD_DIR)/libiconv_*_armeb.ipk
	$(MAKE) -C $(LIBICONV_BUILD_DIR) install prefix=$(LIBICONV_IPK_DIR)/opt
	install -d $(LIBICONV_IPK_DIR)/CONTROL
	install -m 644 $(LIBICONV_SOURCE_DIR)/control $(LIBICONV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBICONV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libiconv-ipk: $(LIBICONV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libiconv-clean:
	-$(MAKE) -C $(LIBICONV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libiconv-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBICONV_DIR) $(LIBICONV_BUILD_DIR) $(LIBICONV_IPK_DIR) $(LIBICONV_IPK)
