###########################################################
#
# transcode
#
###########################################################

# You must replace "transcode" and "TRANSCODE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TRANSCODE_VERSION, TRANSCODE_SITE and TRANSCODE_SOURCE define
# the upstream location of the source code for the package.
# TRANSCODE_DIR is the directory which is created when the source
# archive is unpacked.
# TRANSCODE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
TRANSCODE_SITE=http://www.jakemsr.com/transcode
TRANSCODE_VERSION=1.0.0beta2
TRANSCODE_SOURCE=transcode-$(TRANSCODE_VERSION).tar.gz
TRANSCODE_DIR=transcode-$(TRANSCODE_VERSION)
TRANSCODE_UNZIP=zcat

#
# TRANSCODE_IPK_VERSION should be incremented when the ipk changes.
#
TRANSCODE_IPK_VERSION=1

#
# TRANSCODE_CONFFILES should be a list of user-editable files
TRANSCODE_CONFFILES=/opt/etc/transcode.conf /opt/etc/init.d/SXXtranscode

#
## TRANSCODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TRANSCODE_PATCHES=$(TRANSCODE_SOURCE_DIR)/patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRANSCODE_CPPFLAGS=-DO_LARGEFILE -DSYS_BSD
TRANSCODE_LDFLAGS=

#
# TRANSCODE_BUILD_DIR is the directory in which the build is done.
# TRANSCODE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSCODE_IPK_DIR is the directory in which the ipk is built.
# TRANSCODE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSCODE_BUILD_DIR=$(BUILD_DIR)/transcode
TRANSCODE_SOURCE_DIR=$(SOURCE_DIR)/transcode
TRANSCODE_IPK_DIR=$(BUILD_DIR)/transcode-$(TRANSCODE_VERSION)-ipk
TRANSCODE_IPK=$(BUILD_DIR)/transcode_$(TRANSCODE_VERSION)-$(TRANSCODE_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TRANSCODE_SOURCE):
	$(WGET) -P $(DL_DIR) $(TRANSCODE_SITE)/$(TRANSCODE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
transcode-source: $(DL_DIR)/$(TRANSCODE_SOURCE) $(TRANSCODE_PATCHES)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(TRANSCODE_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSCODE_SOURCE) $(TRANSCODE_PATCHES)
	$(MAKE) ffmpeg-stage lame-stage
	rm -rf $(BUILD_DIR)/$(TRANSCODE_DIR) $(TRANSCODE_BUILD_DIR)
	$(TRANSCODE_UNZIP) $(DL_DIR)/$(TRANSCODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(TRANSCODE_PATCHES) | patch -d $(BUILD_DIR)/$(TRANSCODE_DIR) -p1
	mv $(BUILD_DIR)/$(TRANSCODE_DIR) $(TRANSCODE_BUILD_DIR)
	(cd $(TRANSCODE_BUILD_DIR); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSCODE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSCODE_LDFLAGS)" \
		./configure -C \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ffmpeg_libs-includes=$(STAGING_DIR)/opt \
		--with-avifile-includes=$(STAGING_DIR)/opt \
		--with-lame-includes=$(STAGING_DIR)/opt \
		--with-ogg-includes=$(STAGING_DIR)/opt \
		--with-vorbis-includes=$(STAGING_DIR)/opt \
		--with-theora-includes=$(STAGING_DIR)/opt \
		--with-libdvdread-includes=$(STAGING_DIR)/opt \
		--with-libdv-includes=$(STAGING_DIR)/opt \
		--with-libquicktime-includes=$(STAGING_DIR)/opt \
		--with-lzo-includes=$(STAGING_DIR)/opt \
		--with-a52-includes=$(STAGING_DIR)/opt \
		--with-libmpeg3-includes=$(STAGING_DIR)/opt \
		--with-libxml2-includes=$(STAGING_DIR)/opt \
		--with-mjpegtools-includes=$(STAGING_DIR)/opt \
		--with-gtk-includes=$(STAGING_DIR)/opt \
		--with-imagemagick-includes=$(STAGING_DIR)/opt \
		--with-libiconv-includes=$(STAGING_DIR)/opt \
		--with-ffmpeg_libs-libs=$(STAGING_DIR)/opt \
		--with-avifile-libs=$(STAGING_DIR)/opt \
		--with-lame-libs=$(STAGING_DIR)/opt \
		--with-ogg-libs=$(STAGING_DIR)/opt \
		--with-vorbis-libs=$(STAGING_DIR)/opt \
		--with-theora-libs=$(STAGING_DIR)/opt \
		--with-libdvdread-libs=$(STAGING_DIR)/opt \
		--with-libdv-libs=$(STAGING_DIR)/opt \
		--with-libquicktime-libs=$(STAGING_DIR)/opt \
		--with-lzo-libs=$(STAGING_DIR)/opt \
		--with-a52-libs=$(STAGING_DIR)/opt \
		--with-libmpeg3-libs=$(STAGING_DIR)/opt \
		--with-libxml2-libs=$(STAGING_DIR)/opt \
		--with-mjpegtools-libs=$(STAGING_DIR)/opt \
		--with-gtk-libs=$(STAGING_DIR)/opt \
		--with-imagemagick-libs=$(STAGING_DIR)/opt \
		--with-libiconv-libs=$(STAGING_DIR)/opt \
		--enable-ogg \
		--enable-vorbis \
		--disable-libdvdread \
		--disable-freetype2 \
		--prefix=/opt \
		--disable-nls \
		; sed -i 's/#define malloc rpl_malloc/\/* #define malloc rpl_malloc *\//' $(TRANSCODE_BUILD_DIR)/config.h \
	)
	touch $(TRANSCODE_BUILD_DIR)/.configured

transcode-unpack: $(TRANSCODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRANSCODE_BUILD_DIR)/.built: $(TRANSCODE_BUILD_DIR)/.configured
	rm -f $(TRANSCODE_BUILD_DIR)/.built
#	$(MAKE) 'CFLAGS=-Umalloc' -C $(TRANSCODE_BUILD_DIR)
	$(MAKE) -C $(TRANSCODE_BUILD_DIR)
	touch $(TRANSCODE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
transcode: $(TRANSCODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TRANSCODE_BUILD_DIR)/.staged: $(TRANSCODE_BUILD_DIR)/.built
	rm -f $(TRANSCODE_BUILD_DIR)/.staged
	$(MAKE) -C $(TRANSCODE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TRANSCODE_BUILD_DIR)/.staged

transcode-stage: $(TRANSCODE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRANSCODE_IPK_DIR)/opt/sbin or $(TRANSCODE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRANSCODE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TRANSCODE_IPK_DIR)/opt/etc/transcode/...
# Documentation files should be installed in $(TRANSCODE_IPK_DIR)/opt/doc/transcode/...
# Daemon startup scripts should be installed in $(TRANSCODE_IPK_DIR)/opt/etc/init.d/S??transcode
#
# You may need to patch your application to make it use these locations.
#
$(TRANSCODE_IPK): $(TRANSCODE_BUILD_DIR)/.built
	rm -rf $(TRANSCODE_IPK_DIR) $(BUILD_DIR)/transcode_*_armeb.ipk
	$(MAKE) -C $(TRANSCODE_BUILD_DIR) DESTDIR=$(TRANSCODE_IPK_DIR) install-strip
	install -d $(TRANSCODE_IPK_DIR)/CONTROL
	install -m 644 $(TRANSCODE_SOURCE_DIR)/control $(TRANSCODE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRANSCODE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
transcode-ipk: $(TRANSCODE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
transcode-clean:
	-$(MAKE) -C $(TRANSCODE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
transcode-dirclean:
	rm -rf $(BUILD_DIR)/$(TRANSCODE_DIR) $(TRANSCODE_BUILD_DIR) $(TRANSCODE_IPK_DIR) $(TRANSCODE_IPK)
