###########################################################
#
# mpd
#
###########################################################

# You must replace "mpd" and "MPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MPD_VERSION, MPD_SITE and MPD_SOURCE define
# the upstream location of the source code for the package.
# MPD_DIR is the directory which is created when the source
# archive is unpacked.
# MPD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MPD_SITE=http://mercury.chem.pitt.edu/~shank
MPD_VERSION=0.11.5
MPD_SOURCE=mpd-$(MPD_VERSION).tar.gz
MPD_DIR=mpd-$(MPD_VERSION)
MPD_UNZIP=zcat

#
# MPD_IPK_VERSION should be incremented when the ipk changes.
#
MPD_IPK_VERSION=1

#
# MPD_CONFFILES should be a list of user-editable files
MPD_CONFFILES=

#
# MPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MPD_PATCHES=/dev/null

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPD_CPPFLAGS=
MPD_LDFLAGS=

#
# MPD_BUILD_DIR is the directory in which the build is done.
# MPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPD_IPK_DIR is the directory in which the ipk is built.
# MPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPD_BUILD_DIR=$(BUILD_DIR)/mpd
MPD_SOURCE_DIR=$(SOURCE_DIR)/mpd
MPD_IPK_DIR=$(BUILD_DIR)/mpd-$(MPD_VERSION)-ipk
MPD_IPK=$(BUILD_DIR)/mpd_$(MPD_VERSION)-$(MPD_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPD_SITE)/$(MPD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpd-source: $(DL_DIR)/$(MPD_SOURCE) $(MPD_PATCHES)

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
$(MPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MPD_SOURCE) $(MPD_PATCHES)
	$(MAKE) libao-stage libid3tag-stage libmad-stage libvorbis-stage libogg-stage
	rm -rf $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR)
	$(MPD_UNZIP) $(DL_DIR)/$(MPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MPD_PATCHES) | patch -d $(BUILD_DIR)/$(MPD_DIR) -p1
	mv $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR)
	(cd $(MPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-ipv6 \
		--disable-flac \
		--disable-aac \
		--disable-audiofile \
		--disable-mod \
		--disable-nls \
		--disable-aotest \
		--disable-oggtest \
		--disable-vorbistest \
		--disable-libFLACtest \
		--disable-audiofiletest \
		--disable-libmikmodtest \
		--enable-mpd-mad \
		--enable-mpd-id3tag \
		--with-ao=$(STAGING_DIR)/opt \
		--with-iconv=$(STAGING_DIR)/opt \
		--with-id3tag=$(STAGING_DIR)/opt \
		--with-mad=$(STAGING_DIR)/opt \
		--with-ao=$(STAGING_DIR)/opt \
		--with-ogg=$(STAGING_DIR)/opt \
		--with-vorbis=$(STAGING_DIR)/opt \
	)
	touch $(MPD_BUILD_DIR)/.configured

mpd-unpack: $(MPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPD_BUILD_DIR)/.built: $(MPD_BUILD_DIR)/.configured
	rm -f $(MPD_BUILD_DIR)/.built
	$(MAKE) -C $(MPD_BUILD_DIR)
	touch $(MPD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mpd: $(MPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPD_BUILD_DIR)/.staged: $(MPD_BUILD_DIR)/.built
	rm -f $(MPD_BUILD_DIR)/.staged
	$(MAKE) -C $(MPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MPD_BUILD_DIR)/.staged

mpd-stage: $(MPD_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPD_IPK_DIR)/opt/sbin or $(MPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPD_IPK_DIR)/opt/etc/mpd/...
# Documentation files should be installed in $(MPD_IPK_DIR)/opt/doc/mpd/...
# Daemon startup scripts should be installed in $(MPD_IPK_DIR)/opt/etc/init.d/S??mpd
#
# You may need to patch your application to make it use these locations.
#
$(MPD_IPK): $(MPD_BUILD_DIR)/.built
	rm -rf $(MPD_IPK_DIR) $(BUILD_DIR)/mpd_*_armeb.ipk
	$(MAKE) -C $(MPD_BUILD_DIR) DESTDIR=$(MPD_IPK_DIR) install
	install -d $(MPD_IPK_DIR)/opt/etc/
	install -m 644 $(MPD_SOURCE_DIR)/mpd.conf $(MPD_IPK_DIR)/opt/etc/mpd.conf
	install -d $(MPD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MPD_SOURCE_DIR)/rc.mpd $(MPD_IPK_DIR)/opt/etc/init.d/S61mpd
	install -d $(MPD_IPK_DIR)/CONTROL
	install -m 644 $(MPD_SOURCE_DIR)/control $(MPD_IPK_DIR)/CONTROL/control
	install -m 755 $(MPD_SOURCE_DIR)/postinst $(MPD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(MPD_SOURCE_DIR)/prerm $(MPD_IPK_DIR)/CONTROL/prerm
	echo $(MPD_CONFFILES) | sed -e 's/ /\n/g' > $(MPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpd-ipk: $(MPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpd-clean:
	-$(MAKE) -C $(MPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR) $(MPD_IPK_DIR) $(MPD_IPK)
