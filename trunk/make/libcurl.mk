###########################################################
#
# libcurl
#
###########################################################

# You must replace "libcurl" and "LIBCURL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBCURL_VERSION, LIBCURL_SITE and LIBCURL_SOURCE define
# the upstream location of the source code for the package.
# LIBCURL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCURL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBCURL_SITE= http://curl.haxx.se/download
LIBCURL_VERSION=7.12.2
LIBCURL_SO_VERSION=3.0.0
LIBCURL_SOURCE=curl-$(LIBCURL_VERSION).tar.gz
LIBCURL_DIR=curl-$(LIBCURL_VERSION)
LIBCURL_UNZIP=zcat

#
# LIBCURL_IPK_VERSION should be incremented when the ipk changes.
#
LIBCURL_IPK_VERSION=1

#
# LIBCURL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBCURL_PATCHES=$(LIBCURL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCURL_CPPFLAGS=
LIBCURL_LDFLAGS=

#
# LIBCURL_BUILD_DIR is the directory in which the build is done.
# LIBCURL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCURL_IPK_DIR is the directory in which the ipk is built.
# LIBCURL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCURL_BUILD_DIR=$(BUILD_DIR)/libcurl
LIBCURL_SOURCE_DIR=$(SOURCE_DIR)/libcurl
LIBCURL_IPK_DIR=$(BUILD_DIR)/libcurl-$(LIBCURL_VERSION)-ipk
LIBCURL_IPK=$(BUILD_DIR)/libcurl_$(LIBCURL_VERSION)-$(LIBCURL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBCURL_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBCURL_SITE)/$(LIBCURL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libcurl-source: $(DL_DIR)/$(LIBCURL_SOURCE) $(LIBCURL_PATCHES)

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
$(LIBCURL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCURL_SOURCE) $(LIBCURL_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBCURL_DIR) $(LIBCURL_BUILD_DIR)
	$(LIBCURL_UNZIP) $(DL_DIR)/$(LIBCURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBCURL_DIR) $(LIBCURL_BUILD_DIR)
	(cd $(LIBCURL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCURL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCURL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-random="/dev/urandom" \
		--prefix=/opt \
	)
	touch $(LIBCURL_BUILD_DIR)/.configured

libcurl-unpack: $(LIBCURL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBCURL_BUILD_DIR)/lib/.libs/libcurl.la: $(LIBCURL_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBCURL_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libcurl: $(LIBCURL_BUILD_DIR)/lib/.libs/libcurl.la

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libcurl.so.$(LIBCURL_SO_VERSION): $(LIBCURL_BUILD_DIR)/lib/.libs/libcurl.la
	install -d $(STAGING_DIR)/opt/include/curl
	install -m 644 $(LIBCURL_BUILD_DIR)/include/curl/*.h $(STAGING_DIR)/opt/include/curl
	install -d $(STAGING_DIR)/bin
	install -m 755 $(LIBCURL_BUILD_DIR)/curl-config $(STAGING_DIR)/bin
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBCURL_BUILD_DIR)/lib/.libs/libcurl.a $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBCURL_BUILD_DIR)/lib/libcurl.la $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBCURL_BUILD_DIR)/lib/.libs/libcurl.so.$(LIBCURL_SO_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libcurl.so.$(LIBCURL_SO_VERSION) libcurl.so.3
	cd $(STAGING_DIR)/opt/lib && ln -fs libcurl.so.$(LIBCURL_SO_VERSION) libcurl.so

libcurl-stage: $(STAGING_DIR)/opt/lib/libcurl.so.$(LIBCURL_SO_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCURL_IPK_DIR)/opt/sbin or $(LIBCURL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCURL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBCURL_IPK_DIR)/opt/etc/libcurl/...
# Documentation files should be installed in $(LIBCURL_IPK_DIR)/opt/doc/libcurl/...
# Daemon startup scripts should be installed in $(LIBCURL_IPK_DIR)/opt/etc/init.d/S??libcurl
#
# You may need to patch your application to make it use these locations.
#
$(LIBCURL_IPK): $(LIBCURL_BUILD_DIR)/lib/.libs/libcurl.la
	rm -rf $(LIBCURL_IPK_DIR) $(LIBCURL_IPK)
	$(MAKE) -C $(LIBCURL_BUILD_DIR) DESTDIR=$(LIBCURL_IPK_DIR) install
	rm -rf $(LIBCURL_IPK_DIR)/opt/lib/lib*.a
	mkdir -p $(LIBCURL_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/libcurl/control $(LIBCURL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCURL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libcurl-ipk: $(LIBCURL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libcurl-clean:
	-$(MAKE) -C $(LIBCURL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libcurl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCURL_DIR) $(LIBCURL_BUILD_DIR) $(LIBCURL_IPK_DIR) $(LIBCURL_IPK)
