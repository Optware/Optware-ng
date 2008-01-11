###########################################################
#
# libtiff
#
###########################################################

# You must replace "libtiff" and "LIBTIFF" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBTIFF_VERSION, LIBTIFF_SITE and LIBTIFF_SOURCE define
# the upstream location of the source code for the package.
# LIBTIFF_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTIFF_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBTIFF_SITE=ftp://ftp.remotesensing.org/libtiff
LIBTIFF_VERSION=3.8.2
LIBTIFF_SOURCE=tiff-$(LIBTIFF_VERSION).tar.gz
LIBTIFF_DIR=tiff-$(LIBTIFF_VERSION)
LIBTIFF_UNZIP=zcat
LIBTIFF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTIFF_DESCRIPTION=Tag Image File Format Libraries
LIBTIFF_SECTION=lib
LIBTIFF_PRIORITY=optional
LIBTIFF_DEPENDS=zlib, libstdc++
LIBTIFF_SUGGESTS=
LIBTIFF_CONFLICTS=

#
# LIBTIFF_IPK_VERSION should be incremented when the ipk changes.
#
LIBTIFF_IPK_VERSION=1

#
# LIBTIFF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBTIFF_PATCHES=$(LIBTIFF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq (syno-x07, $(OPTWARE_TARGET))
LIBTIFF_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)
else
LIBTIFF_CPPFLAGS=$(STAGING_CPPFLAGS)
endif
LIBTIFF_LDFLAGS=

#
# LIBTIFF_BUILD_DIR is the directory in which the build is done.
# LIBTIFF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTIFF_IPK_DIR is the directory in which the ipk is built.
# LIBTIFF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTIFF_BUILD_DIR=$(BUILD_DIR)/libtiff
LIBTIFF_SOURCE_DIR=$(SOURCE_DIR)/libtiff
LIBTIFF_IPK_DIR=$(BUILD_DIR)/libtiff-$(LIBTIFF_VERSION)-ipk
LIBTIFF_IPK=$(BUILD_DIR)/libtiff_$(LIBTIFF_VERSION)-$(LIBTIFF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTIFF_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBTIFF_SITE)/$(LIBTIFF_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(LIBTIFF_SITE)/old/$(LIBTIFF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#libtiff-source: $(DL_DIR)/$(LIBTIFF_SOURCE) $(LIBTIFF_PATCHES)

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
$(LIBTIFF_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTIFF_SOURCE) $(LIBTIFF_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBTIFF_DIR) $(@D)
	$(LIBTIFF_UNZIP) $(DL_DIR)/$(LIBTIFF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBTIFF_PATCHES) | patch -d $(BUILD_DIR)/$(LIBTIFF_DIR) -p1
	mv $(BUILD_DIR)/$(LIBTIFF_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(LIBTIFF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTIFF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
ifeq (syno-x07, $(OPTWARE_TARGET))
	sed -i -e 's| -O2||' $(@D)/libtiff/Makefile
endif
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtiff-unpack: $(LIBTIFF_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBTIFF_BUILD_DIR)/.built: $(LIBTIFF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBTIFF_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libtiff: $(LIBTIFF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTIFF_BUILD_DIR)/.staged: $(LIBTIFF_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiff.h $(STAGING_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffio.h $(STAGING_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffconf.h $(STAGING_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffvers.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/.libs/libtiff.so.$(LIBTIFF_VERSION) $(STAGING_DIR)/opt/lib
	rm -f $(STAGING_DIR)/opt/lib/libtiff*.la
	cd $(STAGING_DIR)/opt/lib && ln -fs libtiff.so.$(LIBTIFF_VERSION) libtiff.so.3
	cd $(STAGING_DIR)/opt/lib && ln -fs libtiff.so.$(LIBTIFF_VERSION) libtiff.so
	touch -f $@

libtiff-stage: $(LIBTIFF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtiff
#
$(LIBTIFF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libtiff" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTIFF_PRIORITY)" >>$@
	@echo "Section: $(LIBTIFF_SECTION)" >>$@
	@echo "Version: $(LIBTIFF_VERSION)-$(LIBTIFF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTIFF_MAINTAINER)" >>$@
	@echo "Source: $(LIBTIFF_SITE)/$(LIBTIFF_SOURCE)" >>$@
	@echo "Description: $(LIBTIFF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTIFF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTIFF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTIFF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTIFF_IPK_DIR)/opt/sbin or $(LIBTIFF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTIFF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBTIFF_IPK_DIR)/opt/etc/libtiff/...
# Documentation files should be installed in $(LIBTIFF_IPK_DIR)/opt/doc/libtiff/...
# Daemon startup scripts should be installed in $(LIBTIFF_IPK_DIR)/opt/etc/init.d/S??libtiff
#
# You may need to patch your application to make it use these locations.
#
$(LIBTIFF_IPK): $(LIBTIFF_BUILD_DIR)/.built
	rm -rf $(LIBTIFF_IPK_DIR) $(LIBTIFF_IPK)
	install -d $(LIBTIFF_IPK_DIR)/opt/bin
	$(MAKE) -C $(LIBTIFF_BUILD_DIR) DESTDIR=$(LIBTIFF_IPK_DIR) install-exec
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-bmp2tiff -o $(LIBTIFF_IPK_DIR)/opt/bin/bmp2tiff
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-fax2ps -o $(LIBTIFF_IPK_DIR)/opt/bin/fax2ps
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-fax2tiff -o $(LIBTIFF_IPK_DIR)/opt/bin/fax2tiff
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-gif2tiff -o $(LIBTIFF_IPK_DIR)/opt/bin/gif2tiff
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-pal2rgb -o $(LIBTIFF_IPK_DIR)/opt/bin/pal2rgb
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-ppm2tiff -o $(LIBTIFF_IPK_DIR)/opt/bin/ppm2tiff
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-ras2tiff -o $(LIBTIFF_IPK_DIR)/opt/bin/ras2tiff
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-raw2tiff -o $(LIBTIFF_IPK_DIR)/opt/bin/raw2tiff
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-rgb2ycbcr -o $(LIBTIFF_IPK_DIR)/opt/bin/rgb2ycbcr
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-thumbnail -o $(LIBTIFF_IPK_DIR)/opt/bin/thumbnail
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2bw -o $(LIBTIFF_IPK_DIR)/opt/bin/tiff2bw
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2pdf -o $(LIBTIFF_IPK_DIR)/opt/bin/tiff2pdf*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2ps -o $(LIBTIFF_IPK_DIR)/opt/bin/tiff2ps*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2rgba -o $(LIBTIFF_IPK_DIR)/opt/bin/tiff2rgba*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffcmp -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffcmp*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffcp -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffcp*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffdither -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffdither*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffdump -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffdump*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffinfo -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffinfo*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffmedian -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffmedian*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffset -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffset*
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffsplit -o $(LIBTIFF_IPK_DIR)/opt/bin/tiffsplit*
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-bmp2tiff
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-fax2ps
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-fax2tiff
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-gif2tiff
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-pal2rgb
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-ppm2tiff
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-ras2tiff
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-raw2tiff
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-rgb2ycbcr
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-thumbnail
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2bw
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2pdf
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2ps
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiff2rgba
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffcmp
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffcp
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffdither
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffdump
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffinfo
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffmedian
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffset
	rm -f $(LIBTIFF_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-tiffsplit

	install -d $(LIBTIFF_IPK_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiff.h $(LIBTIFF_IPK_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffio.h $(LIBTIFF_IPK_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffconf.h $(LIBTIFF_IPK_DIR)/opt/include
	install -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffvers.h $(LIBTIFF_IPK_DIR)/opt/include

	rm -f $(LIBTIFF_IPK_DIR)/opt/lib/lib*.a
	rm -f $(LIBTIFF_IPK_DIR)/opt/lib/lib*.la
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)/opt/lib/lib*.so
	$(MAKE) $(LIBTIFF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTIFF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtiff-ipk: $(LIBTIFF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtiff-clean:
	-$(MAKE) -C $(LIBTIFF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtiff-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTIFF_DIR) $(LIBTIFF_BUILD_DIR) $(LIBTIFF_IPK_DIR) $(LIBTIFF_IPK)

