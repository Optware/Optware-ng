###########################################################
#
# libtool
#
###########################################################

# You must replace "libtool" and "LIBTOOL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBTOOL_VERSION, LIBTOOL_SITE and LIBTOOL_SOURCE define
# the upstream location of the source code for the package.
# LIBTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTOOL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBTOOL_SITE=http://ftp.gnu.org/gnu/libtool
LIBTOOL_VERSION=1.5.10
LIBTOOL_SOURCE=libtool-$(LIBTOOL_VERSION).tar.gz
LIBTOOL_DIR=libtool-$(LIBTOOL_VERSION)
LIBTOOL_UNZIP=zcat

#
# LIBTOOL_IPK_VERSION should be incremented when the ipk changes.
#
LIBTOOL_IPK_VERSION=1

#
# LIBTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBTOOL_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTOOL_CPPFLAGS=
LIBTOOL_LDFLAGS=

#
# LIBTOOL_BUILD_DIR is the directory in which the build is done.
# LIBTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTOOL_IPK_DIR is the directory in which the ipk is built.
# LIBTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTOOL_BUILD_DIR=$(BUILD_DIR)/libtool
LIBTOOL_SOURCE_DIR=$(SOURCE_DIR)/libtool
LIBTOOL_IPK_DIR=$(BUILD_DIR)/libtool-$(LIBTOOL_VERSION)-ipk
LIBTOOL_IPK=$(BUILD_DIR)/libtool_$(LIBTOOL_VERSION)-$(LIBTOOL_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTOOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBTOOL_SITE)/$(LIBTOOL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtool-source: $(DL_DIR)/$(LIBTOOL_SOURCE) $(LIBTOOL_PATCHES)

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
$(LIBTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTOOL_SOURCE) $(LIBTOOL_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBTOOL_DIR) $(LIBTOOL_BUILD_DIR)
	$(LIBTOOL_UNZIP) $(DL_DIR)/$(LIBTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBTOOL_DIR) $(LIBTOOL_BUILD_DIR)
	(cd $(LIBTOOL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTOOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTOOL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(LIBTOOL_BUILD_DIR)/.configured

libtool-unpack: $(LIBTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBTOOL_BUILD_DIR)/libltdl/.libs/libltdl.so.3.1.0: $(LIBTOOL_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBTOOL_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libtool: $(LIBTOOL_BUILD_DIR)/libltdl/.libs/libltdl.so.3.1.0

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libltdl.so.3.1.0: $(LIBTOOL_BUILD_DIR)/libltdl/.libs/libltdl.so.3.1.0
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(LIBTOOL_BUILD_DIR)/libltdl/ltdl.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBTOOL_BUILD_DIR)/libltdl/.libs/libltdl.a $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBTOOL_BUILD_DIR)/libltdl/.libs/libltdl.so.3.1.0 $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libltdl.so.3.1.0 libltdl.so.3
	cd $(STAGING_DIR)/opt/lib && ln -fs libltdl.so.3.1.0 libltdl.so

libtool-stage: $(STAGING_DIR)/opt/lib/libltdl.so.3.1.0

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTOOL_IPK_DIR)/opt/sbin or $(LIBTOOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTOOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBTOOL_IPK_DIR)/opt/etc/libtool/...
# Documentation files should be installed in $(LIBTOOL_IPK_DIR)/opt/doc/libtool/...
# Daemon startup scripts should be installed in $(LIBTOOL_IPK_DIR)/opt/etc/init.d/S??libtool
#
# You may need to patch your application to make it use these locations.
#
$(LIBTOOL_IPK): $(LIBTOOL_BUILD_DIR)/libltdl/.libs/libltdl.so.3.1.0
	rm -rf $(LIBTOOL_IPK_DIR) $(LIBTOOL_IPK)
	$(MAKE) -C $(LIBTOOL_BUILD_DIR) DESTDIR=$(LIBTOOL_IPK_DIR) install-strip
	rm -f $(LIBTOOL_IPK_DIR)/opt/info/dir
	install -d $(LIBTOOL_IPK_DIR)/CONTROL
	install -m 644 $(LIBTOOL_SOURCE_DIR)/control $(LIBTOOL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTOOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtool-ipk: $(LIBTOOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtool-clean:
	-$(MAKE) -C $(LIBTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtool-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTOOL_DIR) $(LIBTOOL_BUILD_DIR) $(LIBTOOL_IPK_DIR) $(LIBTOOL_IPK)
