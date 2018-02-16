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
IMAGEMAGICK_SITE=ftp://ftp.imagemagick.org/pub/ImageMagick/releases
IMAGEMAGICK_SITE2=http://ftp.sunet.se/pub/multimedia/graphics/ImageMagic
IMAGEMAGICK_VER=6.9.9
IMAGEMAGICK_REV=7
IMAGEMAGICK_SOURCE=ImageMagick-$(IMAGEMAGICK_VER)-$(IMAGEMAGICK_REV).tar.xz
IMAGEMAGICK_UNZIP=xzcat
IMAGEMAGICK_DIR=ImageMagick-$(IMAGEMAGICK_VER)-$(IMAGEMAGICK_REV)
IMAGEMAGICK_VERSION=$(IMAGEMAGICK_VER).$(IMAGEMAGICK_REV)
IMAGEMAGICK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IMAGEMAGICK_DESCRIPTION=A set of image processing utilities.
IMAGEMAGICK_SECTION=graphics
IMAGEMAGICK_PRIORITY=optional
IMAGEMAGICK_DEPENDS=zlib, freetype, libjpeg, libpng, libtiff, libstdc++, \
		libtool, bzip2, liblcms2, libxml2, pango, libjbigkit
IMAGEMAGICK_SUGGESTS=
IMAGEMAGICK_CONFLICTS=

#
# IMAGEMAGICK_IPK_VERSION should be incremented when the ipk changes.
#
IMAGEMAGICK_IPK_VERSION=3

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IMAGEMAGICK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
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
IMAGEMAGICK_IPK=$(BUILD_DIR)/imagemagick_$(IMAGEMAGICK_VERSION)-$(IMAGEMAGICK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: imagemagick-source imagemagick-unpack imagemagick imagemagick-stage imagemagick-ipk imagemagick-clean imagemagick-dirclean imagemagick-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IMAGEMAGICK_SOURCE):
	$(WGET) -P $(@D) $(IMAGEMAGICK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(IMAGEMAGICK_SITE2)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(IMAGEMAGICK_BUILD_DIR)/.configured: $(DL_DIR)/$(IMAGEMAGICK_SOURCE) $(IMAGEMAGICK_PATCHES) make/imagemagick.mk
	$(MAKE) zlib-stage freetype-stage libjpeg-stage libpng-stage bzip2-stage libtiff-stage pango-stage \
		liblcms2-stage libxml2-stage libjbigkit-stage
	rm -rf $(BUILD_DIR)/$(IMAGEMAGICK_DIR) $(@D)
	$(IMAGEMAGICK_UNZIP) $(DL_DIR)/$(IMAGEMAGICK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IMAGEMAGICK_PATCHES)" ; \
		then cat $(IMAGEMAGICK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(IMAGEMAGICK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IMAGEMAGICK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IMAGEMAGICK_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IMAGEMAGICK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IMAGEMAGICK_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-openmp \
		--without-perl \
		--without-x \
		--with-zlib \
		--with-jpeg \
		--with-png \
		--with-tiff \
		--with-freetype \
		--without-gslib \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

imagemagick-unpack: $(IMAGEMAGICK_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(IMAGEMAGICK_BUILD_DIR)/.built: $(IMAGEMAGICK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	$(MAKE) -C $(@D) DESTDIR=$(@D)/install transform='' install-am
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' -e \
		  '/^includearchdir=/s/=.*/=\$${includedir}/' \
				$(@D)/install/$(TARGET_PREFIX)/lib/pkgconfig/*.pc
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(@D)/install/$(TARGET_PREFIX)/bin/*-config
	touch $@


#
# You should change the dependency to refer directly to the main binary
# which is built.
#
imagemagick: $(IMAGEMAGICK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IMAGEMAGICK_BUILD_DIR)/.staged: $(IMAGEMAGICK_BUILD_DIR)/.built
	rm -f $@
	# libs
	mkdir -p $(STAGING_LIB_DIR)
	cp -af $(@D)/install/$(TARGET_PREFIX)/lib/*.so* $(STAGING_LIB_DIR)
	# headers
	mkdir -p $(STAGING_INCLUDE_DIR)
	rm -rf $(STAGING_INCLUDE_DIR)/ImageMagick-6
	cp -af $(@D)/install/$(TARGET_PREFIX)/include/ImageMagick-6 $(STAGING_INCLUDE_DIR)
	# pkgconfig files
	mkdir -p $(STAGING_LIB_DIR)/pkgconfig
	cp -af $(@D)/install/$(TARGET_PREFIX)/lib/pkgconfig/*.pc $(STAGING_LIB_DIR)/pkgconfig
	# *-config files
	mkdir -p $(STAGING_DIR)/bin
	cp -af $(@D)/install/$(TARGET_PREFIX)/bin/*-config $(STAGING_DIR)/bin
	touch $@

imagemagick-stage: $(IMAGEMAGICK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/imagemagick
#
$(IMAGEMAGICK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: imagemagick" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IMAGEMAGICK_PRIORITY)" >>$@
	@echo "Section: $(IMAGEMAGICK_SECTION)" >>$@
	@echo "Version: $(IMAGEMAGICK_VERSION)-$(IMAGEMAGICK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IMAGEMAGICK_MAINTAINER)" >>$@
	@echo "Source: $(IMAGEMAGICK_SITE)/$(IMAGEMAGICK_SOURCE)" >>$@
	@echo "Description: $(IMAGEMAGICK_DESCRIPTION)" >>$@
	@echo "Depends: $(IMAGEMAGICK_DEPENDS)" >>$@
	@echo "Suggests: $(IMAGEMAGICK_SUGGESTS)" >>$@
	@echo "Conflicts: $(IMAGEMAGICK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/imagemagick/...
# Documentation files should be installed in $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/doc/imagemagick/...
# Daemon startup scripts should be installed in $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??imagemagick
#
# You may need to patch your application to make it use these locations.
#
$(IMAGEMAGICK_IPK): $(IMAGEMAGICK_BUILD_DIR)/.built
	rm -rf $(IMAGEMAGICK_IPK_DIR) $(BUILD_DIR)/imagemagick_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IMAGEMAGICK_BUILD_DIR) DESTDIR=$(IMAGEMAGICK_IPK_DIR) transform='' install-am
	cd $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/bin; \
		for f in `ls | egrep -v -- '-config$$'`; do \
			$(STRIP_COMMAND) $$f; \
			mv -f "$$f" "imagemagick-$$f"; \
		done
	sed -i -e 's|$(OPTWARE_TOP)/scripts/pkg-config.sh|$(TARGET_PREFIX)/bin/pkg-config|g' \
		$(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/bin/*-config
	rm -f $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/libltdl*
#	rm -f $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	find $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/ \
		-name '*.a' \
		-exec rm -f {} \;
#	find $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/ \
		-name '*.la' \
		-exec rm -f {} \;
	find $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/ \
		-name '*.so' \
		-exec chmod +w {} \; \
		-exec $(STRIP_COMMAND) {} \; \
		-exec chmod -w {} \;
	for f in $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/*.so.*; \
		do \
		exec chmod +w $$f; \
		$(STRIP_COMMAND) $$f; \
		exec chmod +w $$f; \
		done
	rm -rf $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/share/ImageMagick-$(IMAGEMAGICK_VER)/www
	rm -rf $(IMAGEMAGICK_IPK_DIR)$(TARGET_PREFIX)/share/ImageMagick-$(IMAGEMAGICK_VER)/images
	$(MAKE) $(IMAGEMAGICK_IPK_DIR)/CONTROL/control
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

#
# Some sanity check for the package.
#
imagemagick-check: $(IMAGEMAGICK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
