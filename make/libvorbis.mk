###########################################################
#
# libvorbis
#
###########################################################

# You must replace "libvorbis" and "LIBVORBIS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBVORBIS_VERSION, LIBVORBIS_SITE and LIBVORBIS_SOURCE define
# the upstream location of the source code for the package.
# LIBVORBIS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBVORBIS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBVORBIS_SITE=http://www.xiph.org/ogg/vorbis/download
LIBVORBIS_VERSION=1.0
LIBVORBIS_VERSION_LIB=0.2.0
LIBVORBIS_FILE_VERSION_LIB=3.0.0
LIBVORBIS_SOURCE=libvorbis-$(LIBVORBIS_VERSION).tar.gz
LIBVORBIS_DIR=libvorbis-$(LIBVORBIS_VERSION)
LIBVORBIS_UNZIP=zcat

#
# LIBVORBIS_IPK_VERSION should be incremented when the ipk changes.
#
LIBVORBIS_IPK_VERSION=1

#
# LIBVORBIS_CONFFILES should be a list of user-editable files
LIBVORBIS_CONFFILES=/opt/etc/libvorbis.conf /opt/etc/init.d/SXXlibvorbis

#
# LIBVORBIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBVORBIS_PATCHES=$(LIBVORBIS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBVORBIS_CPPFLAGS=
LIBVORBIS_LDFLAGS=

#
# LIBVORBIS_BUILD_DIR is the directory in which the build is done.
# LIBVORBIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBVORBIS_IPK_DIR is the directory in which the ipk is built.
# LIBVORBIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBVORBIS_BUILD_DIR=$(BUILD_DIR)/libvorbis
LIBVORBIS_SOURCE_DIR=$(SOURCE_DIR)/libvorbis
LIBVORBIS_IPK_DIR=$(BUILD_DIR)/libvorbis-$(LIBVORBIS_VERSION)-ipk
LIBVORBIS_IPK=$(BUILD_DIR)/libvorbis_$(LIBVORBIS_VERSION)-$(LIBVORBIS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBVORBIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBVORBIS_SITE)/$(LIBVORBIS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libvorbis-source: $(DL_DIR)/$(LIBVORBIS_SOURCE) $(LIBVORBIS_PATCHES)

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
$(LIBVORBIS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBVORBIS_SOURCE) $(LIBVORBIS_PATCHES)
	$(MAKE) libogg-stage
	rm -rf $(BUILD_DIR)/$(LIBVORBIS_DIR) $(LIBVORBIS_BUILD_DIR)
	$(LIBVORBIS_UNZIP) $(DL_DIR)/$(LIBVORBIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBVORBIS_PATCHES) | patch -d $(BUILD_DIR)/$(LIBVORBIS_DIR) -p1
	mv $(BUILD_DIR)/$(LIBVORBIS_DIR) $(LIBVORBIS_BUILD_DIR)
	(cd $(LIBVORBIS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBVORBIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBVORBIS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LIBVORBIS_BUILD_DIR)/.configured

libvorbis-unpack: $(LIBVORBIS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.so.$(LIBVORBIS_VERSION_LIB): $(LIBVORBIS_BUILD_DIR)/.configured
	rm -f $(LIBVORBIS_BUILD_DIR)/.built
	$(MAKE) -C $(LIBVORBIS_BUILD_DIR)
	touch $(LIBVORBIS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libvorbis: $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.so.$(LIBVORBIS_VERSION_LIB)

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libvorbisfile.so.$(LIBVORBIS_VERSION_LIB): $(LIBVORBIS_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include/vorbis
	install -m 644 $(LIBVORBIS_BUILD_DIR)/include/vorbis/vorbisfile.h $(STAGING_DIR)/opt/include/vorbis
	install -m 644 $(LIBVORBIS_BUILD_DIR)/include/vorbis/codec.h $(STAGING_DIR)/opt/include/vorbis
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.a $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbisfile.a $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbisfile.so.$(LIBVORBIS_FILE_VERSION_LIB) $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.so.$(LIBVORBIS_VERSION_LIB) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libvorbis.so.$(LIBVORBIS_VERSION_LIB) libvorbisfile.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libvorbisfile.so.$(LIBVORBIS_FILE_VERSION_LIB) libvorbisfile.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libvorbis.so.$(LIBVORBIS_VERSION_LIB) libvorbisfile.so
	cd $(STAGING_DIR)/opt/lib && ln -fs libvorbisfile.so.$(LIBVORBIS_FILE_VERSION_LIB) libvorbisfile.so

libvorbis-stage: $(STAGING_DIR)/opt/lib/libvorbisfile.so.$(LIBVORBIS_VERSION_LIB)

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBVORBIS_IPK_DIR)/opt/sbin or $(LIBVORBIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBVORBIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBVORBIS_IPK_DIR)/opt/etc/libvorbis/...
# Documentation files should be installed in $(LIBVORBIS_IPK_DIR)/opt/doc/libvorbis/...
# Daemon startup scripts should be installed in $(LIBVORBIS_IPK_DIR)/opt/etc/init.d/S??libvorbis
#
# You may need to patch your application to make it use these locations.
#
$(LIBVORBIS_IPK): $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.so.$(LIBVORBIS_VERSION_LIB)
	rm -rf $(LIBVORBIS_IPK_DIR) $(BUILD_DIR)/libvorbis_*_armeb.ipk
	install -d $(LIBVORBIS_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.a -o $(LIBVORBIS_IPK_DIR)/opt/lib/libvorbis.a
	$(STRIP_COMMAND) $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbis.so.$(LIBVORBIS_VERSION_LIB) -o $(LIBVORBIS_IPK_DIR)/opt/lib/libvorbis.so.$(LIBVORBIS_VERSION_LIB)
	$(STRIP_COMMAND) $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbisfile.a -o $(LIBVORBIS_IPK_DIR)/opt/lib/libvorbisfile.a
	$(STRIP_COMMAND) $(LIBVORBIS_BUILD_DIR)/lib/.libs/libvorbisfile.so.$(LIBVORBIS_FILE_VERSION_LIB) -o $(LIBVORBIS_IPK_DIR)/opt/lib/libvorbisfile.so.$(LIBVORBIS_FILE_VERSION_LIB)
	install -d $(LIBVORBIS_IPK_DIR)/CONTROL
	install -m 644 $(LIBVORBIS_SOURCE_DIR)/control $(LIBVORBIS_IPK_DIR)/CONTROL/control
	cd $(LIBVORBIS_IPK_DIR)/opt/lib && ln -fs libvorbisfile.so.$(LIBVORBIS_FILE_VERSION_LIB) libvorbisfile.so.3
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBVORBIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libvorbis-ipk: $(LIBVORBIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libvorbis-clean:
	-$(MAKE) -C $(LIBVORBIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libvorbis-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBVORBIS_DIR) $(LIBVORBIS_BUILD_DIR) $(LIBVORBIS_IPK_DIR) $(LIBVORBIS_IPK)
