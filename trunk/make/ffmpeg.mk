###########################################################
#
# ffmpeg
#
###########################################################

# You must replace "ffmpeg" and "FFMPEG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FFMPEG_VERSION, FFMPEG_SITE and FFMPEG_SOURCE define
# the upstream location of the source code for the package.
# FFMPEG_DIR is the directory which is created when the source
# archive is unpacked.
# FFMPEG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
FFMPEG_SITE=http://unc.dl.sourceforge.net/sourceforge/ffmpeg
FFMPEG_VERSION=0.4.9-pre1
FFMPEG_SOURCE=ffmpeg-$(FFMPEG_VERSION).tar.gz
FFMPEG_DIR=ffmpeg-$(FFMPEG_VERSION)
FFMPEG_UNZIP=zcat

#
# FFMPEG_IPK_VERSION should be incremented when the ipk changes.
#
FFMPEG_IPK_VERSION=1

#
# FFMPEG_CONFFILES should be a list of user-editable files
FFMPEG_CONFFILES=/opt/etc/ffmpeg.conf /opt/etc/init.d/SXXffmpeg

#
## FFMPEG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FFMPEG_PATCHES=$(FFMPEG_SOURCE_DIR)/patch.strip

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FFMPEG_CPPFLAGS=
FFMPEG_LDFLAGS=

#
# FFMPEG_BUILD_DIR is the directory in which the build is done.
# FFMPEG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FFMPEG_IPK_DIR is the directory in which the ipk is built.
# FFMPEG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FFMPEG_BUILD_DIR=$(BUILD_DIR)/ffmpeg
FFMPEG_SOURCE_DIR=$(SOURCE_DIR)/ffmpeg
FFMPEG_IPK_DIR=$(BUILD_DIR)/ffmpeg-$(FFMPEG_VERSION)-ipk
FFMPEG_IPK=$(BUILD_DIR)/ffmpeg_$(FFMPEG_VERSION)-$(FFMPEG_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FFMPEG_SOURCE):
	$(WGET) -P $(DL_DIR) $(FFMPEG_SITE)/$(FFMPEG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ffmpeg-source: $(DL_DIR)/$(FFMPEG_SOURCE) $(FFMPEG_PATCHES)

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
$(FFMPEG_BUILD_DIR)/.configured: $(DL_DIR)/$(FFMPEG_SOURCE) $(FFMPEG_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FFMPEG_DIR) $(FFMPEG_BUILD_DIR)
	$(FFMPEG_UNZIP) $(DL_DIR)/$(FFMPEG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(FFMPEG_PATCHES) | patch -d $(BUILD_DIR)/$(FFMPEG_DIR) -p1
	mv $(BUILD_DIR)/$(FFMPEG_DIR) $(FFMPEG_BUILD_DIR)
	(cd $(FFMPEG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FFMPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FFMPEG_LDFLAGS)" \
		./configure \
		--cross-prefix=$(TARGET_CROSS) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--cpu=armv5b \
		--enable-shared \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(FFMPEG_BUILD_DIR)/.configured

ffmpeg-unpack: $(FFMPEG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FFMPEG_BUILD_DIR)/.built: $(FFMPEG_BUILD_DIR)/.configured
	rm -f $(FFMPEG_BUILD_DIR)/.built
	$(MAKE) -C $(FFMPEG_BUILD_DIR)
	touch $(FFMPEG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ffmpeg: $(FFMPEG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FFMPEG_BUILD_DIR)/.staged: $(FFMPEG_BUILD_DIR)/.built
	rm -f $(FFMPEG_BUILD_DIR)/.staged
	$(MAKE) -C $(FFMPEG_BUILD_DIR) bindir=$(STAGING_DIR)/opt/bin prefix=$(STAGING_DIR)/opt DESTDIR=$(STAGING_DIR) install
	touch $(FFMPEG_BUILD_DIR)/.staged

ffmpeg-stage: $(FFMPEG_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(FFMPEG_IPK_DIR)/opt/sbin or $(FFMPEG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FFMPEG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FFMPEG_IPK_DIR)/opt/etc/ffmpeg/...
# Documentation files should be installed in $(FFMPEG_IPK_DIR)/opt/doc/ffmpeg/...
# Daemon startup scripts should be installed in $(FFMPEG_IPK_DIR)/opt/etc/init.d/S??ffmpeg
#
# You may need to patch your application to make it use these locations.
#
$(FFMPEG_IPK): $(FFMPEG_BUILD_DIR)/.built
	rm -rf $(FFMPEG_IPK_DIR) $(BUILD_DIR)/ffmpeg_*_armeb.ipk
	$(MAKE) -C $(FFMPEG_BUILD_DIR) bindir=$(FFMPEG_IPK_DIR)/opt/bin prefix=$(FFMPEG_IPK_DIR)/opt DESTDIR=$(FFMPEG_IPK_DIR) install
	install -d $(FFMPEG_IPK_DIR)/CONTROL
	install -m 644 $(FFMPEG_SOURCE_DIR)/control $(FFMPEG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FFMPEG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ffmpeg-ipk: $(FFMPEG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ffmpeg-clean:
	-$(MAKE) -C $(FFMPEG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ffmpeg-dirclean:
	rm -rf $(BUILD_DIR)/$(FFMPEG_DIR) $(FFMPEG_BUILD_DIR) $(FFMPEG_IPK_DIR) $(FFMPEG_IPK)
