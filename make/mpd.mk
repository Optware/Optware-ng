###########################################################
#
# mpd
#
###########################################################
#
# MPD_VERSION, MPD_SITE and MPD_SOURCE define
# the upstream location of the source code for the package.
# MPD_DIR is the directory which is created when the source
# archive is unpacked.
# MPD_UNZIP is the command used to unzip the source.
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
MPD_SITE=http://www.musicpd.org/download/mpd/$(shell echo $(MPD_VERSION)|cut -d '.' -f 1-2)
#MPD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/musicpd
#MPD_SVN_REPO=https://svn.musicpd.org/mpd/trunk
#MPD_SVN_REV=5324
ifeq (, $(filter buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
# All except ARMv5
MPD_VERSION=0.20.15
else
# ARMv5
MPD_VERSION=0.19.13
endif
MPD_SOURCE=mpd-$(MPD_VERSION).tar.xz
MPD_DIR=mpd-$(MPD_VERSION)
MPD_UNZIP=xzcat
MPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPD_DESCRIPTION=Music Player Daemon (MPD) allows remote access for playing music.
MPD_SECTION=audio
MPD_PRIORITY=optional
MPD_DEPENDS=audiofile, faad2, ffmpeg, flac, glib, lame, libao, libcurl, icu, alsa-lib
MPD_DEPENDS+=, libid3tag, libmad, libmms, libmpcdec, libshout, wavpack, audiofile
MPD_DEPENDS+=, psmisc
MPD_DEPENDS+=, zlib, expat
ifneq (, $(filter i686, $(TARGET_ARCH)))
MPD_DEPENDS+=, libsamplerate, libvorbis
else
MPD_DEPENDS+=, libvorbisidec
endif
ifeq (avahi, $(filter avahi, $(PACKAGES)))
MPD_DEPENDS+=, libavahi-client, libavahi-common
endif
MPD_DEPENDS+=, libupnp, libmpdclient, mpg123, libsndfile, sqlite
MPD_SUGGESTS=
MPD_CONFLICTS=

#
# MPD_IPK_VERSION should be incremented when the ipk changes.
#
ifeq (, $(filter buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
# All except ARMv5
MPD_IPK_VERSION=1
else
# ARMv5
MPD_IPK_VERSION=6
endif

#
# MPD_CONFFILES should be a list of user-editable files
#MPD_CONFFILES=$(TARGET_PREFIX)/etc/mpd.conf $(TARGET_PREFIX)/etc/init.d/SXXmpd

#
# MPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (, $(filter buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
# All except ARMv5
MPD_PATCHES=\
#$(MPD_SOURCE_DIR)/fix_build_with_no_ioprio_set_syscall.patch
else
# ARMv5
MPD_PATCHES=\
$(MPD_SOURCE_DIR)/0.19.13.fix_build_with_no_ioprio_set_syscall.patch \
$(MPD_SOURCE_DIR)/0.19.13.DecodeBuffer.hxx.patch \
$(MPD_SOURCE_DIR)/0.19.13.libupnp-1.8.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPD_CPPFLAGS=
MPD_LDFLAGS=
ifneq ($(FFMPEG_OLD), yes)
MPD_CPPFLAGS += -DAVCODEC_MAX_AUDIO_FRAME_SIZE=192000
endif

ifeq (avahi, $(filter avahi, $(PACKAGES)))
MPD_CONFIGURE_OPTIONS=--with-zeroconf=avahi
else
MPD_CONFIGURE_OPTIONS=--without-zeroconf
endif

ifeq (no, $(IPV6))
MPD_CONFIGURE_OPTIONS+=--disable-ipv6
else
MPD_CONFIGURE_OPTIONS+=--enable-ipv6
endif

ifeq (, $(filter i686, $(TARGET_ARCH)))
MPD_CONFIGURE_OPTIONS+= --with-tremor=$(STAGING_PREFIX) --disable-lsr
else
MPD_CONFIGURE_OPTIONS+= --disable-libOggFLACtest --enable-lsr
endif

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
MPD_IPK=$(BUILD_DIR)/mpd_$(MPD_VERSION)-$(MPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpd-source mpd-unpack mpd mpd-stage mpd-ipk mpd-clean mpd-dirclean mpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPD_SOURCE):
ifndef MPD_SVN_REV
	$(WGET) -P $(@D) $(MPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(MPD_DIR) && \
		svn co -r$(MPD_SVN_REV) $(MPD_SVN_REPO) $(MPD_DIR) && \
		tar -cjf $@ $(MPD_DIR) && \
		rm -rf $(MPD_DIR) \
	)
endif

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(MPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MPD_SOURCE) $(MPD_PATCHES) make/mpd.mk
ifeq (avahi, $(filter avahi, $(PACKAGES)))
	$(MAKE) avahi-stage
endif
	$(MAKE) faad2-stage ffmpeg-stage flac-stage lame-stage \
	glib-stage libcurl-stage libmms-stage icu-stage \
	audiofile-stage libao-stage libid3tag-stage \
	libmad-stage libmpcdec-stage libshout-stage alsa-lib-stage \
	wavpack-stage audiofile-stage expat-stage boost-stage \
	libupnp-stage libmpdclient-stage mpg123-stage libsndfile-stage sqlite-stage
ifneq (, $(filter i686, $(TARGET_ARCH)))
	$(MAKE) libsamplerate-stage libvorbis-stage
else
	$(MAKE) libvorbisidec-stage
endif
	rm -rf $(BUILD_DIR)/$(MPD_DIR) $(@D)
	$(MPD_UNZIP) $(DL_DIR)/$(MPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPD_PATCHES)" ; \
		then cat $(MPD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MPD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MPD_DIR) $(@D) ; \
	fi
#	sed -i -e '/LIBFLAC_LIBS="$$LIBFLAC_LIBS/s|-lFLAC|-lFLAC -logg|' $(@D)/configure
ifneq (, $(filter buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
# ARMv5
	$(AUTORECONF1.15) -vif $(@D)
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPD_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		SHOUT_LIBS="$(STAGING_LDFLAGS) -lshout -lspeex" \
		ICU_CFLAGS="$(STAGING_CPPFLAGS)" \
		ICU_LIBS="$(STAGING_LDFLAGS) -licuuc -licui18n" \
		ZLIB_CFLAGS="$(STAGING_CPPFLAGS)" \
		ZLIB_LIBS="$(STAGING_LDFLAGS) -lz" \
		EXPAT_CFLAGS="$(STAGING_CPPFLAGS)" \
		EXPAT_LIBS="$(STAGING_LDFLAGS) -lexpat" \
		AUDIOFILE_CFLAGS="$(STAGING_CPPFLAGS)" \
		AUDIOFILE_LIBS="$(STAGING_LDFLAGS) -laudiofile" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		\
		--enable-alsa \
		--enable-aac \
		--enable-ao \
		--enable-audiofile \
		--enable-curl \
		--enable-ffmpeg \
		--enable-flac \
		--enable-id3 \
		--enable-lsr \
		--enable-mms \
		--enable-mpc \
		--enable-wavpack \
		--enable-expat \
		$(MPD_CONFIGURE_OPTIONS) \
		--disable-eventfd \
		--disable-epoll \
		--disable-signalfd \
		--with-faad=$(STAGING_PREFIX) \
		--with-lame=$(STAGING_PREFIX) \
	)
#		--with-ao=$(STAGING_PREFIX) \
		--with-audiofile-prefix=$(STAGING_PREFIX) \
		--with-id3tag=$(STAGING_PREFIX) \
		--with-libFLAC=$(STAGING_PREFIX) \
		--with-mad=$(STAGING_PREFIX) \
		--with-flac=$(STAGING_PREFIX) \
		--enable-mp3 \
		--enable-oggvorbis \
		--disable-lametest \
		\
		--disable-nls \
		--disable-static \
;
	sed -i -e '/^LAME_CFLAGS/s| -I$(TARGET_PREFIX)/include||g;' $(@D)/Makefile
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mpd-unpack: $(MPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPD_BUILD_DIR)/.built: $(MPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mpd: $(MPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPD_BUILD_DIR)/.staged: $(MPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mpd-stage: $(MPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpd
#
$(MPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPD_PRIORITY)" >>$@
	@echo "Section: $(MPD_SECTION)" >>$@
	@echo "Version: $(MPD_VERSION)-$(MPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPD_MAINTAINER)" >>$@
ifdef MPD_SVN_REV
	@echo "Source: $(MPD_SVN_REPO)" >>$@
else
	@echo "Source: $(MPD_SITE)" >>$@
endif
	@echo "Description: $(MPD_DESCRIPTION)" >>$@
	@echo "Depends: $(MPD_DEPENDS)" >>$@
	@echo "Suggests: $(MPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MPD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MPD_IPK_DIR)$(TARGET_PREFIX)/etc/mpd/...
# Documentation files should be installed in $(MPD_IPK_DIR)$(TARGET_PREFIX)/doc/mpd/...
# Daemon startup scripts should be installed in $(MPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mpd
#
# You may need to patch your application to make it use these locations.
#
$(MPD_IPK): $(MPD_BUILD_DIR)/.built
	rm -rf $(MPD_IPK_DIR) $(BUILD_DIR)/mpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPD_BUILD_DIR) DESTDIR=$(MPD_IPK_DIR) install-strip
#	$(INSTALL) -d $(MPD_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MPD_SOURCE_DIR)/mpd.conf $(MPD_IPK_DIR)$(TARGET_PREFIX)/etc/mpd.conf
#	$(INSTALL) -d $(MPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MPD_SOURCE_DIR)/rc.mpd $(MPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmpd
	$(MAKE) $(MPD_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MPD_SOURCE_DIR)/postinst $(MPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MPD_SOURCE_DIR)/prerm $(MPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(MPD_CONFFILES) | sed -e 's/ /\n/g' > $(MPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpd-ipk: $(MPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpd-clean:
	rm -f $(MPD_BUILD_DIR)/.built
	-$(MAKE) -C $(MPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR) $(MPD_IPK_DIR) $(MPD_IPK)
#
#
# Some sanity check for the package.
#
mpd-check: $(MPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
