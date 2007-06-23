###########################################################
#
# rtorrent
#
###########################################################

#
# RTORRENT_VERSION, RTORRENT_SITE and RTORRENT_SOURCE define
# the upstream location of the source code for the package.
# RTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# RTORRENT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
RTORRENT_SITE=http://libtorrent.rakshasa.no/downloads
RTORRENT_VERSION=0.7.5
RTORRENT_SOURCE=rtorrent-$(RTORRENT_VERSION).tar.gz
RTORRENT_DIR=rtorrent-$(RTORRENT_VERSION)
RTORRENT_UNZIP=zcat
RTORRENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RTORRENT_DESCRIPTION=rtorrent is a BitTorrent client for ncurses, using the libtorrent library.
RTORRENT_SECTION=net
RTORRENT_PRIORITY=optional
RTORRENT_DEPENDS=libtorrent, $(NCURSES_FOR_OPTWARE_TARGET), libcurl, zlib
RTORRENT_SUGGESTS=dtach, screen
RTORRENT_CONFLICTS=

#
# RTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
RTORRENT_IPK_VERSION=1

#
# RTORRENT_CONFFILES should be a list of user-editable files
RTORRENT_CONFFILES=/opt/etc/rtorrent.conf


#
# RTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RTORRENT_PATCHES=$(RTORRENT_SOURCE_DIR)/symlink_unlink.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RTORRENT_CPPFLAGS=-O3
RTORRENT_LDFLAGS=
RTORRENT_CONFIGURE=
ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
RTORRENT_CONFIGURE += CXX=$(TARGET_GXX)
endif
endif


#
# RTORRENT_BUILD_DIR is the directory in which the build is done.
# RTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RTORRENT_IPK_DIR is the directory in which the ipk is built.
# RTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RTORRENT_BUILD_DIR=$(BUILD_DIR)/rtorrent
RTORRENT_SOURCE_DIR=$(SOURCE_DIR)/rtorrent
RTORRENT_IPK_DIR=$(BUILD_DIR)/rtorrent-$(RTORRENT_VERSION)-ipk
RTORRENT_IPK=$(BUILD_DIR)/rtorrent_$(RTORRENT_VERSION)-$(RTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rtorrent-source rtorrent-unpack rtorrent rtorrent-stage rtorrent-ipk rtorrent-clean rtorrent-dirclean rtorrent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RTORRENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(RTORRENT_SITE)/$(RTORRENT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rtorrent-source: $(DL_DIR)/$(RTORRENT_SOURCE) $(RTORRENT_PATCHES)

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
$(RTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(RTORRENT_SOURCE) $(RTORRENT_PATCHES) make/rtorrent.mk
	$(MAKE) libtorrent-stage $(NCURSES_FOR_OPTWARE_TARGET)-stage libcurl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(RTORRENT_DIR) $(RTORRENT_BUILD_DIR)
	$(RTORRENT_UNZIP) $(DL_DIR)/$(RTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RTORRENT_PATCHES)" ; \
		then cat $(RTORRENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RTORRENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RTORRENT_DIR)" != "$(RTORRENT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RTORRENT_DIR) $(RTORRENT_BUILD_DIR) ; \
	fi
	(cd $(RTORRENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RTORRENT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/opt/lib/pkgconfig/" \
		$(RTORRENT_CONFIGURE) \
		PATH="$(PATH):$(STAGING_DIR)/opt/bin" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(RTORRENT_BUILD_DIR)/libtool
	touch $(RTORRENT_BUILD_DIR)/.configured

rtorrent-unpack: $(RTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RTORRENT_BUILD_DIR)/.built: $(RTORRENT_BUILD_DIR)/.configured
	rm -f $(RTORRENT_BUILD_DIR)/.built
	$(MAKE) -C $(RTORRENT_BUILD_DIR)
	touch $(RTORRENT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rtorrent: $(RTORRENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(RTORRENT_BUILD_DIR)/.staged: $(RTORRENT_BUILD_DIR)/.built
#	rm -f $(RTORRENT_BUILD_DIR)/.staged
#	$(MAKE) -C $(RTORRENT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(RTORRENT_BUILD_DIR)/.staged
#
#rtorrent-stage: $(RTORRENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rtorrent
#
$(RTORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(RTORRENT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rtorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RTORRENT_PRIORITY)" >>$@
	@echo "Section: $(RTORRENT_SECTION)" >>$@
	@echo "Version: $(RTORRENT_VERSION)-$(RTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(RTORRENT_SITE)/$(RTORRENT_SOURCE)" >>$@
	@echo "Description: $(RTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(RTORRENT_DEPENDS)" >>$@
	@echo "Suggests: $(RTORRENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(RTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RTORRENT_IPK_DIR)/opt/sbin or $(RTORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RTORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RTORRENT_IPK_DIR)/opt/etc/rtorrent/...
# Documentation files should be installed in $(RTORRENT_IPK_DIR)/opt/doc/rtorrent/...
# Daemon startup scripts should be installed in $(RTORRENT_IPK_DIR)/opt/etc/init.d/S??rtorrent
#
# You may need to patch your application to make it use these locations.
#
$(RTORRENT_IPK): $(RTORRENT_BUILD_DIR)/.built
	rm -rf $(RTORRENT_IPK_DIR) $(BUILD_DIR)/rtorrent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RTORRENT_BUILD_DIR) DESTDIR=$(RTORRENT_IPK_DIR) install-strip
	$(MAKE) $(RTORRENT_IPK_DIR)/CONTROL/control
	install -d $(RTORRENT_IPK_DIR)/opt/share/torrent
	install -d $(RTORRENT_IPK_DIR)/opt/share/torrent/work
	install -d $(RTORRENT_IPK_DIR)/opt/share/torrent/dl
	install -d $(RTORRENT_IPK_DIR)/opt/etc
	install -m 644 $(RTORRENT_SOURCE_DIR)/rtorrent.conf $(RTORRENT_IPK_DIR)/opt/etc/
	install -m 755 $(RTORRENT_SOURCE_DIR)/rtor $(RTORRENT_IPK_DIR)/opt/bin
	install -d $(RTORRENT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(RTORRENT_SOURCE_DIR)/rc.rtorrent $(RTORRENT_IPK_DIR)/opt/etc/init.d/S99rtorrent
	$(MAKE) $(RTORRENT_IPK_DIR)/CONTROL/control
#	install -m 755 $(RTORRENT_SOURCE_DIR)/postinst $(RTORRENT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RTORRENT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RTORRENT_SOURCE_DIR)/prerm $(RTORRENT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RTORRENT_IPK_DIR)/CONTROL/prerm
	echo $(RTORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(RTORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rtorrent-ipk: $(RTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rtorrent-clean:
	rm -f $(RTORRENT_BUILD_DIR)/.built
	-$(MAKE) -C $(RTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rtorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(RTORRENT_DIR) $(RTORRENT_BUILD_DIR) $(RTORRENT_IPK_DIR) $(RTORRENT_IPK)

#
# Some sanity check for the package.
#
rtorrent-check: $(RTORRENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RTORRENT_IPK)
