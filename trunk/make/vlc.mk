###########################################################
#
# vlc
#
###########################################################
#
# VLC_VERSION, VLC_SITE and VLC_SOURCE define
# the upstream location of the source code for the package.
# VLC_DIR is the directory which is created when the source
# archive is unpacked.
# VLC_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
VLC_VERSION=0.9.9a
VLC_IPK_VERSION=2
VLC_SITE=http://download.videolan.org/pub/videolan/vlc/$(VLC_VERSION)
VLC_SOURCE=vlc-$(VLC_VERSION).tar.bz2
VLC_DIR=vlc-$(VLC_VERSION)
VLC_UNZIP=bzcat
VLC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VLC_DESCRIPTION=VLC is a cross-platform media player and streaming server.
VLC_SECTION=video
VLC_PRIORITY=optional
VLC_DEPENDS=dbus
VLC_SUGGESTS=\
faad2, \
ffmpeg, \
flac, \
freetype, \
fribidi, \
liba52, \
libdvbpsi, \
libdvdnav, \
libdvdread, \
libid3tag, \
libmad, \
libmpcdec, \
libmpeg2, \
libogg, \
libpng, \
libshout, \
libupnp, \
libvorbis, \
libxml2, \
ncursesw, \
speex
ifeq (avahi, $(filter avahi, $(PACKAGES)))
VLC_SUGGESTS+=, avahi
endif
ifeq (x264, $(filter x264, $(PACKAGES)))
VLC_SUGGESTS+=, x264
endif
VLC_CONFLICTS=

#
# VLC_CONFFILES should be a list of user-editable files
#VLC_CONFFILES=/opt/etc/vlc.conf /opt/etc/init.d/SXXvlc

#
# VLC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#VLC_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VLC_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
VLC_LDFLAGS=

VLC_CONFIG_OPTS = $(if $(filter avahi, $(PACKAGES)),--enable-bonjour,--disable-bonjour)
VLC_CONFIG_OPTS += $(if $(filter x264, $(PACKAGES)),--enable-x264,--disable-x264)
ifeq ($(OPTWARE_TARGET), $(filter syno-e500, $(OPTWARE_TARGET)))
VLC_CONFIG_OPTS += --disable-altivec
endif
ifeq ($(OPTWARE_TARGET), $(filter dns323 ts101, $(OPTWARE_TARGET)))
VLC_CONFIG_OPTS += --disable-dvbpsi
else
VLC_CONFIG_OPTS += --enable-dvbpsi
endif

#
# VLC_BUILD_DIR is the directory in which the build is done.
# VLC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VLC_IPK_DIR is the directory in which the ipk is built.
# VLC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VLC_BUILD_DIR=$(BUILD_DIR)/vlc
VLC_SOURCE_DIR=$(SOURCE_DIR)/vlc
VLC_IPK_DIR=$(BUILD_DIR)/vlc-$(VLC_VERSION)-ipk
VLC_IPK=$(BUILD_DIR)/vlc_$(VLC_VERSION)-$(VLC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vlc-source vlc-unpack vlc vlc-stage vlc-ipk vlc-clean vlc-dirclean vlc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VLC_SOURCE):
	$(WGET) -P $(@D) $(VLC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vlc-source: $(DL_DIR)/$(VLC_SOURCE) $(VLC_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(VLC_BUILD_DIR)/.configured: $(DL_DIR)/$(VLC_SOURCE) $(VLC_PATCHES) make/vlc.mk
ifeq (avahi, $(filter avahi, $(PACKAGES)))
	$(MAKE) avahi-stage
endif
	$(MAKE) dbus-stage
	$(MAKE) faad2-stage ffmpeg-stage flac-stage
	$(MAKE) freetype-stage
	$(MAKE) fribidi-stage
	$(MAKE) liba52-stage
	$(MAKE) libdvbpsi-stage
	$(MAKE) libdvdnav-stage libdvdread-stage
	$(MAKE) libid3tag-stage
	$(MAKE) libmad-stage
	$(MAKE) libmpcdec-stage
	$(MAKE) libmpeg2-stage
	$(MAKE) libogg-stage
	$(MAKE) libpng-stage
	$(MAKE) libshout-stage
	$(MAKE) libupnp-stage
	$(MAKE) libvorbis-stage
	$(MAKE) libxml2-stage
	$(MAKE) ncurses-stage ncursesw-stage
	$(MAKE) speex-stage
ifeq (x264, $(filter x264, $(PACKAGES)))
	$(MAKE) x264-stage
endif
	rm -rf $(BUILD_DIR)/$(VLC_DIR) $(@D)
	$(VLC_UNZIP) $(DL_DIR)/$(VLC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VLC_PATCHES)" ; \
		then cat $(VLC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VLC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(VLC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(VLC_DIR) $(@D) ; \
	fi
	sed -i -e '/LIBEXT=/s/=.*/=".so"/' $(@D)/configure
ifeq (uclibc, $(LIBC_STYLE))
	sed -i -e '/# *if.*_POSIX_SPIN_LOCKS/s/.*/#if 0/' $(@D)/include/vlc_threads.h
endif
ifeq (no,$(IPV6))
	sed -i -e 's/#ifdef *AF_INET6/#if 0/' $(@D)/src/network/udp.c
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VLC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VLC_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_header_sysfs_libsysfs_h=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-v4l \
		--disable-v4l2 \
		$(VLC_CONFIG_OPTS) \
		--enable-a52 \
		--enable-dvdnav \
		--with-dvdnav-config-path=$(STAGING_PREFIX)/bin \
		--enable-faad \
		--enable-flac \
		--disable-gnutls \
		--enable-mpc \
		--enable-ncurses \
		--enable-ogg \
		--enable-png \
		--disable-remoteosd \
		--enable-shout \
		--enable-speex \
		--enable-vorbis \
		--disable-alsa \
		--disable-dca \
		--disable-glx \
		--disable-gnomevfs \
		--disable-libcdio \
		--disable-libcddb \
		--disable-screen \
		--disable-sdl \
		--disable-wxwidgets --disable-skins2 \
		--disable-x11 \
		--disable-nls \
		--disable-static \
	)
	sed -i -e 's|-I$$[^ ]*/include|-I$(STAGING_INCLUDE_DIR)|g' \
	       -e 's|-I/usr/include|-I$(STAGING_INCLUDE_DIR)|g' \
	       -e 's|-I/opt/include|-I$(STAGING_INCLUDE_DIR)|g' \
	       $(@D)/vlc-config
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

vlc-unpack: $(VLC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VLC_BUILD_DIR)/.built: $(VLC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
vlc: $(VLC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VLC_BUILD_DIR)/.staged: $(VLC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

vlc-stage: $(VLC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vlc
#
$(VLC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: vlc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VLC_PRIORITY)" >>$@
	@echo "Section: $(VLC_SECTION)" >>$@
	@echo "Version: $(VLC_VERSION)-$(VLC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VLC_MAINTAINER)" >>$@
	@echo "Source: $(VLC_SITE)/$(VLC_SOURCE)" >>$@
	@echo "Description: $(VLC_DESCRIPTION)" >>$@
	@echo "Depends: $(VLC_DEPENDS)" >>$@
	@echo "Suggests: $(VLC_SUGGESTS)" >>$@
	@echo "Conflicts: $(VLC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VLC_IPK_DIR)/opt/sbin or $(VLC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VLC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VLC_IPK_DIR)/opt/etc/vlc/...
# Documentation files should be installed in $(VLC_IPK_DIR)/opt/doc/vlc/...
# Daemon startup scripts should be installed in $(VLC_IPK_DIR)/opt/etc/init.d/S??vlc
#
# You may need to patch your application to make it use these locations.
#
$(VLC_IPK): $(VLC_BUILD_DIR)/.built
	rm -rf $(VLC_IPK_DIR) $(BUILD_DIR)/vlc_*_$(TARGET_ARCH).ipk
	env STRIPPROG=$(TARGET_STRIP) \
	$(MAKE) -C $(VLC_BUILD_DIR) DESTDIR=$(VLC_IPK_DIR) install-strip program_transform_name=""
#	install -d $(VLC_IPK_DIR)/opt/etc/
#	install -m 644 $(VLC_SOURCE_DIR)/vlc.conf $(VLC_IPK_DIR)/opt/etc/vlc.conf
#	install -d $(VLC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(VLC_SOURCE_DIR)/rc.vlc $(VLC_IPK_DIR)/opt/etc/init.d/SXXvlc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXvlc
	$(MAKE) $(VLC_IPK_DIR)/CONTROL/control
#	install -m 755 $(VLC_SOURCE_DIR)/postinst $(VLC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(VLC_SOURCE_DIR)/prerm $(VLC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(VLC_CONFFILES) | sed -e 's/ /\n/g' > $(VLC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VLC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(VLC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vlc-ipk: $(VLC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vlc-clean:
	rm -f $(VLC_BUILD_DIR)/.built
	-$(MAKE) -C $(VLC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vlc-dirclean:
	rm -rf $(BUILD_DIR)/$(VLC_DIR) $(VLC_BUILD_DIR) $(VLC_IPK_DIR) $(VLC_IPK)
#
#
# Some sanity check for the package.
#
vlc-check: $(VLC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
