###########################################################
#
# libpng
#
###########################################################

# You must replace "libpng" and "LIBPNG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBPNG_VERSION, LIBPNG_SITE and LIBPNG_SOURCE define
# the upstream location of the source code for the package.
# LIBPNG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPNG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBPNG_SITE=http://download.sourceforge.net/libpng
LIBPNG_VERSION=1.2.8
LIBPNG_SOURCE=libpng-$(LIBPNG_VERSION)-config.tar.gz
LIBPNG_DIR=libpng-$(LIBPNG_VERSION)
LIBPNG_UNZIP=zcat

#
# LIBPNG_IPK_VERSION should be incremented when the ipk changes.
#
LIBPNG_IPK_VERSION=1

#
# LIBPNG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBPNG_PATCHES=$(LIBPNG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPNG_CPPFLAGS=
LIBPNG_LDFLAGS=

#
# LIBPNG_BUILD_DIR is the directory in which the build is done.
# LIBPNG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPNG_IPK_DIR is the directory in which the ipk is built.
# LIBPNG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPNG_BUILD_DIR=$(BUILD_DIR)/libpng
LIBPNG_SOURCE_DIR=$(SOURCE_DIR)/libpng
LIBPNG_IPK_DIR=$(BUILD_DIR)/libpng-$(LIBPNG_VERSION)-ipk
LIBPNG_IPK=$(BUILD_DIR)/libpng_$(LIBPNG_VERSION)-$(LIBPNG_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPNG_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBPNG_SITE)/$(LIBPNG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpng-source: $(DL_DIR)/$(LIBPNG_SOURCE) $(LIBPNG_PATCHES)

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
$(LIBPNG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPNG_SOURCE) $(LIBPNG_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBPNG_DIR) $(LIBPNG_BUILD_DIR)
	$(LIBPNG_UNZIP) $(DL_DIR)/$(LIBPNG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBPNG_PATCHES) | patch -d $(BUILD_DIR)/$(LIBPNG_DIR) -p1
	mv $(BUILD_DIR)/$(LIBPNG_DIR)-config $(LIBPNG_BUILD_DIR)
	(cd $(LIBPNG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPNG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPNG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LIBPNG_BUILD_DIR)/.configured

libpng-unpack: $(LIBPNG_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBPNG_BUILD_DIR)/.built: $(LIBPNG_BUILD_DIR)/.configured
	rm -f $(LIBPNG_BUILD_DIR)/.built
	$(MAKE) -C $(LIBPNG_BUILD_DIR)
	touch $(LIBPNG_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libpng: $(LIBPNG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/liblibpng.so.$(LIBPNG_VERSION): $(LIBPNG_BUILD_DIR)/.built
	$(MAKE) -C $(LIBPNG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-exec-am
	$(MAKE) -C $(LIBPNG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-includeHEADERS
	$(STRIP_COMMAND) $(STAGING_DIR)/opt/lib/libpng.a
	$(STRIP_COMMAND) $(STAGING_DIR)/opt/lib/libpng.so.3.0.0
	$(STRIP_COMMAND) $(STAGING_DIR)/opt/lib/libpng12.so.0.0.0
#	install -d $(STAGING_DIR)/opt/include
#	install -m 644 $(LIBPNG_BUILD_DIR)/libpng.h $(STAGING_DIR)/opt/include
#	install -d $(STAGING_DIR)/opt/lib
#	install -m 644 $(LIBPNG_BUILD_DIR)/liblibpng.a $(STAGING_DIR)/opt/lib
#	install -m 644 $(LIBPNG_BUILD_DIR)/liblibpng.so.$(LIBPNG_VERSION) $(STAGING_DIR)/opt/lib
#	cd $(STAGING_DIR)/opt/lib && ln -fs liblibpng.so.$(LIBPNG_VERSION) liblibpng.so.1
#	cd $(STAGING_DIR)/opt/lib && ln -fs liblibpng.so.$(LIBPNG_VERSION) liblibpng.so

libpng-stage: $(STAGING_DIR)/opt/lib/liblibpng.so.$(LIBPNG_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPNG_IPK_DIR)/opt/sbin or $(LIBPNG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPNG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBPNG_IPK_DIR)/opt/etc/libpng/...
# Documentation files should be installed in $(LIBPNG_IPK_DIR)/opt/doc/libpng/...
# Daemon startup scripts should be installed in $(LIBPNG_IPK_DIR)/opt/etc/init.d/S??libpng
#
# You may need to patch your application to make it use these locations.
#
$(LIBPNG_IPK): $(LIBPNG_BUILD_DIR)/.built
	rm -rf $(LIBPNG_IPK_DIR) $(LIBPNG_IPK)
	install -d $(LIBPNG_IPK_DIR)/opt/bin
	$(MAKE) -C $(LIBPNG_BUILD_DIR) DESTDIR=$(LIBPNG_IPK_DIR) install-exec-am
	$(MAKE) -C $(LIBPNG_BUILD_DIR) DESTDIR=$(LIBPNG_IPK_DIR) install-includeHEADERS
	rm -f $(LIBPNG_IPK_DIR)/opt/bin/libpng-config
	rm -f $(LIBPNG_IPK_DIR)/opt/bin/libpng12-config
	$(STRIP_COMMAND) --strip-unneeded $(LIBPNG_IPK_DIR)/opt/lib/libpng.a
	$(STRIP_COMMAND) --strip-unneeded $(LIBPNG_IPK_DIR)/opt/lib/libpng.so.3.0.0
	$(STRIP_COMMAND) --strip-unneeded $(LIBPNG_IPK_DIR)/opt/lib/libpng12.so.0.0.0
#	$(STRIP_COMMAND) $(LIBPNG_BUILD_DIR)/libpng -o $(LIBPNG_IPK_DIR)/opt/bin/libpng
#	install -d $(LIBPNG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBPNG_SOURCE_DIR)/rc.libpng $(LIBPNG_IPK_DIR)/opt/etc/init.d/SXXlibpng
	install -d $(LIBPNG_IPK_DIR)/CONTROL
	install -m 644 $(LIBPNG_SOURCE_DIR)/control $(LIBPNG_IPK_DIR)/CONTROL/control
#	install -m 644 $(LIBPNG_SOURCE_DIR)/postinst $(LIBPNG_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(LIBPNG_SOURCE_DIR)/prerm $(LIBPNG_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPNG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpng-ipk: $(LIBPNG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpng-clean:
	-$(MAKE) -C $(LIBPNG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpng-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPNG_DIR) $(LIBPNG_BUILD_DIR) $(LIBPNG_IPK_DIR) $(LIBPNG_IPK)
