###########################################################
#
# imagemagick
#
###########################################################

# You must replace "imagemagick" and "IMAGEMAGICK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IMAGEMAGICK_VERSION, IMAGEMAGICK_SITE and IMAGEMAGICK_SOURCE define
# the upstream location of the source code for the package.
# IMAGEMAGICK_DIR is the directory which is created when the source
# archive is unpacked.
# IMAGEMAGICK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
#http://optusnet.dl.sourceforge.net/sourceforge/imagemagick/ImageMagick-6.1.7-5.tar.gz
IMAGEMAGICK_SITE=http://optusnet.dl.sourceforge.net/sourceforge/imagemagick
IMAGEMAGICK_VERSION=6.1.7
IMAGEMAGICK_REV=5
IMAGEMAGICK_SOURCE=ImageMagick-$(IMAGEMAGICK_VERSION)-$(IMAGEMAGICK_REV).tar.gz
IMAGEMAGICK_DIR=ImageMagick-$(IMAGEMAGICK_VERSION)
IMAGEMAGICK_UNZIP=zcat

#
# IMAGEMAGICK_IPK_VERSION should be incremented when the ipk changes.
#
IMAGEMAGICK_IPK_VERSION=4

#
# IMAGEMAGICK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IMAGEMAGICK_PATCHES=$(IMAGEMAGICK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IMAGEMAGICK_CPPFLAGS=-I$(STAGING_DIR)/opt/include
IMAGEMAGICK_LDFLAGS=

#
# IMAGEMAGICK_BUILD_DIR is the directory in which the build is done.
# IMAGEMAGICK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IMAGEMAGICK_IPK_DIR is the directory in which the ipk is built.
# IMAGEMAGICK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IMAGEMAGICK_BUILD_DIR=$(BUILD_DIR)/imagemagick
IMAGEMAGICK_SOURCE_DIR=$(SOURCE_DIR)/imagemagick
IMAGEMAGICK_IPK_DIR=$(BUILD_DIR)/imagemagick-$(IMAGEMAGICK_VERSION)-ipk
IMAGEMAGICK_IPK=$(BUILD_DIR)/imagemagick_$(IMAGEMAGICK_VERSION)-$(IMAGEMAGICK_REV)-$(IMAGEMAGICK_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IMAGEMAGICK_SOURCE):
	$(WGET) -P $(DL_DIR) $(IMAGEMAGICK_SITE)/$(IMAGEMAGICK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
imagemagick-source: $(DL_DIR)/$(IMAGEMAGICK_SOURCE) $(IMAGEMAGICK_PATCHES)

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
$(IMAGEMAGICK_BUILD_DIR)/.configured: $(DL_DIR)/$(IMAGEMAGICK_SOURCE) $(IMAGEMAGICK_PATCHES)
	$(MAKE) zlib-stage libjpeg-stage libpng-stage libtiff-stage bzip2-stage
	rm -rf $(BUILD_DIR)/$(IMAGEMAGICK_DIR) $(IMAGEMAGICK_BUILD_DIR)
	$(IMAGEMAGICK_UNZIP) $(DL_DIR)/$(IMAGEMAGICK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IMAGEMAGICK_PATCHES) | patch -d $(BUILD_DIR)/$(IMAGEMAGICK_DIR) -p1
	mv $(BUILD_DIR)/$(IMAGEMAGICK_DIR) $(IMAGEMAGICK_BUILD_DIR)
	(cd $(IMAGEMAGICK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IMAGEMAGICK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IMAGEMAGICK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-perl \
		--without-x \
		--with-zlib \
		--with-jpeg \
		--with-png \
		--with-tiff \
		--without-gslib \
	)
	touch $(IMAGEMAGICK_BUILD_DIR)/.configured

imagemagick-unpack: $(IMAGEMAGICK_BUILD_DIR)/.configured

#
# If you are building a library, then you need to stage it too.
#
#$(STAGING_DIR)/opt/lib/libimagemagick.so.$(IMAGEMAGICK_VERSION): $(IMAGEMAGICK_BUILD_DIR)/libimagemagick.so.$(IMAGEMAGICK_VERSION)
#	install -d $(STAGING_DIR)/opt/include
#	install -m 644 $(IMAGEMAGICK_BUILD_DIR)/imagemagick.h $(STAGING_DIR)/opt/include
#	install -d $(STAGING_DIR)/opt/lib
#	install -m 644 $(IMAGEMAGICK_BUILD_DIR)/libimagemagick.a $(STAGING_DIR)/opt/lib
#	install -m 644 $(IMAGEMAGICK_BUILD_DIR)/libimagemagick.so.$(IMAGEMAGICK_VERSION) $(STAGING_DIR)/opt/lib
#	cd $(STAGING_DIR)/opt/lib && ln -fs libimagemagick.so.$(IMAGEMAGICK_VERSION) libimagemagick.so.1
#	cd $(STAGING_DIR)/opt/lib && ln -fs libimagemagick.so.$(IMAGEMAGICK_VERSION) libimagemagick.so
# 
#imagemagick-stage: $(STAGING_DIR)/opt/lib/libimagemagick.so.$(IMAGEMAGICK_VERSION)

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(IMAGEMAGICK_BUILD_DIR)/.built: $(IMAGEMAGICK_BUILD_DIR)/.configured
	rm -f $(IMAGEMAGICK_BUILD_DIR)/.built
	$(MAKE) -C $(IMAGEMAGICK_BUILD_DIR)
	touch $(IMAGEMAGICK_BUILD_DIR)/.built


#
# You should change the dependency to refer directly to the main binary
# which is built.
#
imagemagick: $(IMAGEMAGICK_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(IMAGEMAGICK_IPK_DIR)/opt/sbin or $(IMAGEMAGICK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IMAGEMAGICK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IMAGEMAGICK_IPK_DIR)/opt/etc/imagemagick/...
# Documentation files should be installed in $(IMAGEMAGICK_IPK_DIR)/opt/doc/imagemagick/...
# Daemon startup scripts should be installed in $(IMAGEMAGICK_IPK_DIR)/opt/etc/init.d/S??imagemagick
#
# You may need to patch your application to make it use these locations.
#
$(IMAGEMAGICK_IPK): $(IMAGEMAGICK_BUILD_DIR)/.built
	rm -rf $(IMAGEMAGICK_IPK_DIR) $(BUILD_DIR)/imagemagick_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IMAGEMAGICK_BUILD_DIR) DESTDIR=$(IMAGEMAGICK_IPK_DIR) install-am
	rm -f $(IMAGEMAGICK_IPK_DIR)/opt/bin/*
	rm -f $(IMAGEMAGICK_IPK_DIR)/opt/lib/libltdl*
	rm -f $(IMAGEMAGICK_IPK_DIR)/opt/lib/*.la
	$(STRIP_COMMAND) $(IMAGEMAGICK_IPK_DIR)/opt/lib/*.so.*
	$(STRIP_COMMAND) $(IMAGEMAGICK_IPK_DIR)/opt/lib/*.a
	cp $(IMAGEMAGICK_BUILD_DIR)/Magick++/bin/Magick++-config $(IMAGEMAGICK_IPK_DIR)/opt/bin
	cp $(IMAGEMAGICK_BUILD_DIR)/magick/Magick-config $(IMAGEMAGICK_IPK_DIR)/opt/bin
	cp $(IMAGEMAGICK_BUILD_DIR)/wand/Wand-config $(IMAGEMAGICK_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/animate -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/animate
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/compare -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/compare
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/composite -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/composite
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/conjure -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/conjure
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/convert -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/convert
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/display -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/display
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/identify -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/identify
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/import -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/import
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/mogrify -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/mogrify
	$(STRIP_COMMAND) $(IMAGEMAGICK_BUILD_DIR)/utilities/.libs/montage -o $(IMAGEMAGICK_IPK_DIR)/opt/bin/montage
	rm -rf $(IMAGEMAGICK_IPK_DIR)/opt/share/ImageMagick-$(IMAGEMAGICK_VERSION)/www
	rm -rf $(IMAGEMAGICK_IPK_DIR)/opt/share/ImageMagick-$(IMAGEMAGICK_VERSION)/images
	rm -rf $(IMAGEMAGICK_IPK_DIR)/opt/man
	install -d $(IMAGEMAGICK_IPK_DIR)/CONTROL
	install -m 644 $(IMAGEMAGICK_SOURCE_DIR)/control $(IMAGEMAGICK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IMAGEMAGICK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
imagemagick-ipk: $(IMAGEMAGICK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
imagemagick-clean:
	-$(MAKE) -C $(IMAGEMAGICK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
imagemagick-dirclean:
	rm -rf $(BUILD_DIR)/$(IMAGEMAGICK_DIR) $(IMAGEMAGICK_BUILD_DIR) $(IMAGEMAGICK_IPK_DIR) $(IMAGEMAGICK_IPK)
