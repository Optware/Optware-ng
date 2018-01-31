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
VLC_REPOSITORY=git://git.videolan.org/vlc.git
VLC_GIT_DATE=20150912
VLC_TREEISH=`git rev-list --max-count=1 --until=2015-09-12 HEAD`
ifdef VLC_REPOSITORY
VLC_VERSION=2.2.1-git$(VLC_GIT_DATE)
VLC_UNZIP=bzcat
VLC_SOURCE_SUFFIX=tar.bz2
else
VLC_VERSION=2.1.5
VLC_UNZIP=xzcat
VLC_SOURCE_SUFFIX=tar.xz
endif
VLC_IPK_VERSION=6
VLC_SITE=http://download.videolan.org/pub/videolan/vlc/$(VLC_VERSION)
VLC_SOURCE=vlc-$(VLC_VERSION).$(VLC_SOURCE_SUFFIX)
VLC_DIR=vlc-$(VLC_VERSION)
VLC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VLC_DESCRIPTION=VLC is a cross-platform media player and streaming server.
VLC_SECTION=video
VLC_PRIORITY=optional
VLC_DEPENDS=libstdc++, dbus, libidn, gnutls
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
VLC_DEPENDS+=, libiconv
endif
VLC_SUGGESTS=\
faad2, \
ffmpeg, \
flac, \
freetype, \
fribidi, \
liba52, \
libass, \
libdvbpsi, \
libdvdnav, \
libdvdread, \
libgcrypt, \
libid3tag, \
libmad, \
libmpcdec, \
libmpeg2, \
libogg, \
libpng, \
libshout, \
libudev, \
libupnp, \
libvorbis, \
libxml2, \
lua, \
mkvtoolnix, \
ncursesw, \
speex
ifeq (harfbuzz, $(filter harfbuzz, $(PACKAGES)))
VLC_SUGGESTS+=, harfbuzz
endif
ifeq (avahi, $(filter avahi, $(PACKAGES)))
VLC_SUGGESTS+=, avahi
endif
ifeq (x264, $(filter x264, $(PACKAGES)))
VLC_SUGGESTS+=, x264
endif
ifeq (wayland, $(filter wayland, $(PACKAGES)))
  ifeq (mesalib, $(filter mesalib, $(PACKAGES)))
  # libwayland-egl
  VLC_SUGGESTS+=, mesalib
  endif
endif
ifeq (xcb, $(filter xcb, $(PACKAGES)))
VLC_SUGGESTS+=, xcb
endif
VLC_CONFLICTS=

#
# VLC_CONFFILES should be a list of user-editable files
#VLC_CONFFILES=$(TARGET_PREFIX)/etc/vlc.conf $(TARGET_PREFIX)/etc/init.d/SXXvlc

#
# VLC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VLC_PATCHES=\
$(VLC_SOURCE_DIR)/libupnp-1.8.patch \
$(VLC_SOURCE_DIR)/vlc_filter.h.patch \
$(VLC_SOURCE_DIR)/libvlc_media.h.patch
ifeq ($(LIBC_STYLE), uclibc)
VLC_PATCHES += $(VLC_SOURCE_DIR)/uclibc-ng.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VLC_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses -I$(STAGING_INCLUDE_DIR)/glib-2.0 -D__STDC_FORMAT_MACROS=1
VLC_LDFLAGS=

VLC_CONFIG_OPTS = $(if $(filter avahi, $(PACKAGES)),--enable-bonjour,--disable-bonjour)
VLC_CONFIG_OPTS += $(if $(filter x264, $(PACKAGES)),--enable-x264,--disable-x264)
ifeq ($(OPTWARE_TARGET), $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
VLC_CONFIG_OPTS += --disable-altivec
endif
ifeq ($(OPTWARE_TARGET), $(filter dns323 ts101, $(OPTWARE_TARGET)))
VLC_CONFIG_OPTS += --disable-dvbpsi
else
VLC_CONFIG_OPTS += --enable-dvbpsi
endif
ifeq (wayland, $(filter wayland, $(PACKAGES)))
  ifeq (mesalib, $(filter mesalib, $(PACKAGES)))
  # libwayland-egl
  VLC_CONFIG_OPTS += --enable-wayland
  else
  VLC_CONFIG_OPTS += --disable-wayland
  endif
else
  VLC_CONFIG_OPTS += --disable-wayland
endif
ifeq (xcb, $(filter xcb, $(PACKAGES)))
VLC_CONFIG_OPTS += --with-x --enable-xcb
else
VLC_CONFIG_OPTS += --without-x --disable-xcb
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
ifdef VLC_REPOSITORY
	(cd $(BUILD_DIR) ; \
		rm -rf $(VLC_DIR) && \
		git clone $(VLC_REPOSITORY) $(VLC_DIR) && \
		(cd $(VLC_DIR) && \
		git checkout $(VLC_TREEISH) && \
		git describe --tags --long --match '?.*.*' --always > src/revision.txt) && \
		tar -cjvf $@ --exclude .git --exclude "*.log" $(VLC_DIR) && \
		rm -rf $(VLC_DIR) ; \
	)
else
	$(WGET) -P $(@D) $(VLC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

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
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) dbus-stage libidn-stage gnutls-stage \
	faad2-stage ffmpeg-stage flac-stage \
	freetype-stage \
	fribidi-stage \
	liba52-stage \
	libdvbpsi-stage \
	libdvdnav-stage libdvdread-stage \
	libid3tag-stage \
	libmad-stage \
	libmpcdec-stage \
	libmpeg2-stage \
	libogg-stage \
	libpng-stage \
	libshout-stage \
	libupnp-stage \
	libvorbis-stage \
	libxml2-stage \
	ncurses-stage ncursesw-stage \
	speex-stage \
	lua-stage lua-host-stage \
	libgcrypt-stage mkvtoolnix-stage \
	udev-stage libass-stage
ifeq (harfbuzz, $(filter harfbuzz, $(PACKAGES)))
	$(MAKE) harfbuzz-stage
endif
ifeq (x264, $(filter x264, $(PACKAGES)))
	$(MAKE) x264-stage
endif
ifeq (wayland, $(filter wayland, $(PACKAGES)))
  ifeq (mesalib, $(filter mesalib, $(PACKAGES)))
  # libwayland-egl
	$(MAKE) mesalib-stage
  endif
endif
ifeq (xcb, $(filter xcb, $(PACKAGES)))
	$(MAKE) xcb-stage
endif
	rm -rf $(BUILD_DIR)/$(VLC_DIR) $(@D)
	$(VLC_UNZIP) $(DL_DIR)/$(VLC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VLC_PATCHES)" ; \
		then cat $(VLC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(VLC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(VLC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(VLC_DIR) $(@D) ; \
	fi
	sed -i -e '/modules\/gui\//s/.*//' $(@D)/configure.ac
	$(AUTORECONF1.14) -vif $(@D)
	sed -i 	-e '/LIBEXT=/s/=.*/=".so"/' \
		-e '/GCRYPT_CFLAGS=/s|=.*|="$(shell $(STAGING_PREFIX)/bin/libgcrypt-config --cflags)"|' \
		-e '/GCRYPT_LIBS=/s|=.*|="$(shell $(STAGING_PREFIX)/bin/libgcrypt-config --libs)"|' \
												$(@D)/configure
ifeq (uclibc, $(LIBC_STYLE))
	sed -i -e '/# *if.*_POSIX_SPIN_LOCKS/s/.*/#if 0/' $(@D)/include/vlc_threads.h
endif
ifeq (no,$(IPV6))
	sed -i -e 's/#ifdef *AF_INET6/#if 0/' $(@D)/src/network/udp.c
endif
	(cd $(@D); \
		PATH=$$PATH:$(HOST_STAGING_PREFIX)/bin \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="-I$(TARGET_INCDIR) $(STAGING_CPPFLAGS) $(VLC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VLC_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_header_sysfs_libsysfs_h=no \
		ac_cv_linux_dvb_5_1=no \
		NCURSES_CFLAGS="$(STAGING_CPPFLAGS)" \
		NCURSES_LIBS="$(STAGING_LDFLAGS) -lncursesw" \
		WAYLAND_SCANNER=$(HOST_STAGING_PREFIX)/bin/wayland-scanner \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-v4l \
		--disable-v4l2 \
		$(VLC_CONFIG_OPTS) \
		--enable-a52 \
		--enable-dvdnav \
		--with-dvdnav-config-path=$(STAGING_PREFIX)/bin \
		--enable-faad \
		--enable-flac \
		--enable-gnutls \
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
		--disable-nls \
		--disable-jpeg \
		--disable-linsys \
		--disable-macosx \
		--disable-minimal-macosx \
		--disable-macosx-dialog-provider \
		--disable-static \
	)
	find $(@D) -type f -name Makefile -exec sed -i -e 's|-L$(TARGET_PREFIX)/lib|-L$(STAGING_LIB_DIR)|g' \
	       -e 's;-I$(TARGET_PREFIX)/include\|-I/usr/include;-I$(STAGING_INCLUDE_DIR);g' {} \;
	sed -i -e '/^#define HAVE_SCHED_GETAFFINITY/s|^|//|' $(@D)/config.h
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

vlc-unpack: $(VLC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VLC_BUILD_DIR)/.built: $(VLC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) vlc_LDFLAGS="-L../src/.libs -lvlccore" \
			vlc_cache_gen_LDADD="-L../src/.libs -L../lib/.libs -lvlccore -lvlc" \
			LUAC=$(HOST_STAGING_PREFIX)/bin/luac
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
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: vlc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VLC_PRIORITY)" >>$@
	@echo "Section: $(VLC_SECTION)" >>$@
	@echo "Version: $(VLC_VERSION)-$(VLC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VLC_MAINTAINER)" >>$@
ifdef VLC_REPOSITORY
	@echo "Source: $(VLC_REPOSITORY)" >>$@
else
	@echo "Source: $(VLC_SITE)/$(VLC_SOURCE)" >>$@
endif
	@echo "Description: $(VLC_DESCRIPTION)" >>$@
	@echo "Depends: $(VLC_DEPENDS)" >>$@
	@echo "Suggests: $(VLC_SUGGESTS)" >>$@
	@echo "Conflicts: $(VLC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VLC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(VLC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VLC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(VLC_IPK_DIR)$(TARGET_PREFIX)/etc/vlc/...
# Documentation files should be installed in $(VLC_IPK_DIR)$(TARGET_PREFIX)/doc/vlc/...
# Daemon startup scripts should be installed in $(VLC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??vlc
#
# You may need to patch your application to make it use these locations.
#
$(VLC_IPK): $(VLC_BUILD_DIR)/.built
	rm -rf $(VLC_IPK_DIR) $(BUILD_DIR)/vlc_*_$(TARGET_ARCH).ipk
	env STRIPPROG=$(TARGET_STRIP) \
	$(MAKE) -C $(VLC_BUILD_DIR) DESTDIR=$(VLC_IPK_DIR) install-strip program_transform_name=""
#	$(INSTALL) -d $(VLC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(VLC_SOURCE_DIR)/vlc.conf $(VLC_IPK_DIR)$(TARGET_PREFIX)/etc/vlc.conf
#	$(INSTALL) -d $(VLC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(VLC_SOURCE_DIR)/rc.vlc $(VLC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXvlc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXvlc
	$(MAKE) $(VLC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(VLC_SOURCE_DIR)/postinst $(VLC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(VLC_SOURCE_DIR)/prerm $(VLC_IPK_DIR)/CONTROL/prerm
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
