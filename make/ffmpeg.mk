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
FFMPEG_URL=http://ffmpeg.org/releases/$(FFMPEG_SOURCE)
FFMPEG_GIT=https://github.com/FFmpeg/FFmpeg.git
FFMPEG_GIT_COMMIT=01e291a592452f27b3a4e811536aaaf94096e244
#FFMPEG_GIT_DATE=20171015
ifdef FFMPEG_GIT_DATE
FFMPEG_VERSION=3.4+git$(FFMPEG_GIT_DATE)
else
FFMPEG_VERSION=3.4
endif

FFMPEG_DIR=ffmpeg-$(FFMPEG_VERSION)
FFMPEG_SOURCE=$(FFMPEG_DIR).tar.bz2
FFMPEG_UNZIP=bzcat
FFMPEG_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
FFMPEG_DESCRIPTION=FFmpeg is an audio/video conversion tool.
FFMPEG_SECTION=tool
FFMPEG_PRIORITY=optional
FFMPEG_DEPENDS=liblzma0, bzip2, zlib, openssl, alsa-lib, lame, \
		libvorbis, x264, libfdk-aac, libsoxr, libass, libopus, \
		fontconfig, openjpeg, libtheora, wavpack, libxml2, zlib, \
		libgmp
ifneq (uclibc, $(LIBC_STYLE))
FFMPEG_DEPENDS+=, freetype
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
FFMPEG_DEPENDS+=, libiconv
endif
FFMPEG_SUGGESTS=
FFMPEG_CONFLICTS=

### version for old packages that need old ffmpeg
FFMPEG_SVN=https://github.com/FFmpeg/FFmpeg.git/trunk
FFMPEG_SVN_DATE_OLD=20120308
FFMPEG_SVN_REVISION_OLD=040000
FFMPEG_VERSION_OLD=0.svn$(FFMPEG_SVN_DATE_OLD)-git-rev$(FFMPEG_SVN_REVISION_OLD)
FFMPEG_DIR_OLD=ffmpeg-$(FFMPEG_VERSION_OLD)
FFMPEG_SOURCE_OLD=$(FFMPEG_DIR_OLD).tar.bz2
FFMPEG_BUILD_DIR_OLD=$(BUILD_DIR)/ffmpeg_old

#
# FFMPEG_IPK_VERSION should be incremented when the ipk changes.
#
FFMPEG_IPK_VERSION ?= 4

#
# FFMPEG_CONFFILES should be a list of user-editable files
#FFMPEG_CONFFILES=$(TARGET_PREFIX)/etc/ffmpeg.conf $(TARGET_PREFIX)/etc/init.d/SXXffmpeg

#
## FFMPEG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FFMPEG_PATCHES=
FFMPEG_OLD_PATCHES=\
$(FFMPEG_SOURCE_DIR)/include_linux_types_h.patch \
$(FFMPEG_SOURCE_DIR)/old_visibility_hidden.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FFMPEG_CPPFLAGS= -fPIC
ifdef NO_BUILTIN_MATH
FFMPEG_CPPFLAGS += -fno-builtin-cos -fno-builtin-sin -fno-builtin-lrint -fno-builtin-rint
#FFMPEG_PATCHES += $(FFMPEG_SOURCE_DIR)/powf-to-pow.patch
endif
FFMPEG_LDFLAGS=

FFMPEG_CONFIG_OPTS ?=

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
FFMPEG_IPK=$(BUILD_DIR)/ffmpeg_$(FFMPEG_VERSION)-$(FFMPEG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#

ifdef FFMPEG_GIT_DATE
$(DL_DIR)/$(FFMPEG_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf ffmpeg && \
		git clone --bare $(FFMPEG_GIT) ffmpeg && \
		(cd ffmpeg && \
		git archive --format=tar --prefix=$(FFMPEG_DIR)/ $(FFMPEG_GIT_COMMIT) | bzip2 > $@) && \
		rm -rf ffmpeg ; \
	)
else
$(DL_DIR)/$(FFMPEG_SOURCE):
	$(WGET) -O $@ $(FFMPEG_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

$(DL_DIR)/$(FFMPEG_SOURCE_OLD):
	( cd $(BUILD_DIR) ; \
		rm -rf $(FFMPEG_DIR_OLD) && \
		svn co -r $(FFMPEG_SVN_REVISION_OLD) $(FFMPEG_SVN) $(FFMPEG_DIR_OLD) && \
		rm -f $(FFMPEG_DIR_OLD)/.gitattributes $(FFMPEG_DIR_OLD)/.gitignore && \
		tar -cjf $@ $(FFMPEG_DIR_OLD) --exclude .svn && \
		rm -rf $(FFMPEG_DIR_OLD) \
	)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ffmpeg-source: $(DL_DIR)/$(FFMPEG_SOURCE) $(DL_DIR)/$(FFMPEG_SOURCE_OLD) $(FFMPEG_PATCHES)

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
#
FFMPEG_ARCH=$(strip \
	$(if $(filter armeb, $(TARGET_ARCH)), arm, \
	$(TARGET_ARCH)))

$(FFMPEG_BUILD_DIR)/.configured: $(DL_DIR)/$(FFMPEG_SOURCE) $(FFMPEG_PATCHES) make/ffmpeg.mk
	$(MAKE) xz-utils-stage bzip2-stage zlib-stage openssl-stage libsoxr-stage libass-stage \
		alsa-lib-stage lame-stage libvorbis-stage x264-stage libfdk-aac-stage \
		libopus-stage fontconfig-stage openjpeg-stage libtheora-stage \
		wavpack-stage libxml2-stage zlib-stage libgmp-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifneq (uclibc, $(LIBC_STYLE))
	$(MAKE) freetype-stage
endif
	rm -rf $(BUILD_DIR)/$(FFMPEG_DIR) $(@D)
	$(FFMPEG_UNZIP) $(DL_DIR)/$(FFMPEG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FFMPEG_PATCHES)" ; \
		then cat $(FFMPEG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FFMPEG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FFMPEG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FFMPEG_DIR) $(@D) ; \
	fi
	sed -i -e 's/cpuflags=".*"/cpuflags=""/' $(@D)/configure
ifdef NO_BUILTIN_MATH
	find $(@D) -type f -name '*.[hc]' -exec sed -i -e 's/powf/pow/g' {} \;
endif
	sed -i -e 's|/etc/ffserver\.conf|$(TARGET_PREFIX)/etc/ffserver.conf|' $(@D)/fftools/ffserver.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FFMPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FFMPEG_LDFLAGS)" \
		./configure \
		--enable-cross-compile \
		--cross-prefix=$(TARGET_CROSS) \
		--arch=$(FFMPEG_ARCH) \
		--target-os=linux \
		--pkg-config=$(OPTWARE_TOP)/scripts/pkg-config.sh \
		$(FFMPEG_CONFIG_OPTS) \
		--enable-version3 \
		--enable-gpl \
		--enable-nonfree \
		--disable-libxcb \
		--disable-libxcb-shm \
		--disable-libxcb-xfixes \
		--disable-libxcb-shape \
		--enable-openssl \
		--enable-libmp3lame \
		--enable-libopus \
		--enable-libvorbis \
		--enable-libx264 \
		--enable-libfdk-aac \
		--enable-libsoxr \
		--enable-libass \
		--enable-fontconfig \
		--enable-iconv \
		$(strip $(if $(filter uclibc, $(LIBC_STYLE)), \
			--disable-libfreetype, \
			--enable-libfreetype)) \
		--enable-libopenjpeg \
		--enable-libtheora \
		--enable-libwavpack \
		--enable-libxml2 \
		--enable-lzma \
		--enable-zlib \
		--enable-gmp \
		--enable-shared \
		--disable-static \
		--enable-postproc \
		--prefix=$(TARGET_PREFIX) \
	)
ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
	sed -i -e 's/#define CONFIG_LINUX_PERF 1/#define CONFIG_LINUX_PERF 0/' $(@D)/config.h
	sed -i -e 's/CONFIG_LINUX_PERF=yes/CONFIG_LINUX_PERF=no/' $(@D)/ffbuild/config.mak
endif
	sed -i -e '/^OPTFLAGS/s| -O3| $(TARGET_CUSTOM_FLAGS) $(FFMPEG_CPPFLAGS) $$(OPTLEVEL)|' $(@D)/ffbuild/config.mak
	touch $@

ffmpeg-unpack: $(FFMPEG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FFMPEG_BUILD_DIR)/.built: $(FFMPEG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) OPTLEVEL=-O3
	touch $@

#
# This is the build convenience target.
#
ffmpeg: $(FFMPEG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FFMPEG_BUILD_DIR)/.staged: $(FFMPEG_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_INCLUDE_DIR)/ffmpeg $(STAGING_INCLUDE_DIR)/postproc
	$(MAKE) -C $(@D) install \
		mandir=$(STAGING_PREFIX)/share/man \
		bindir=$(STAGING_PREFIX)/bin \
		prefix=$(STAGING_PREFIX)
	if [ -f $(STAGING_INCLUDE_DIR)/libavutil/time.h ]; then \
		mv -f $(STAGING_INCLUDE_DIR)/libavutil/time.h $(STAGING_INCLUDE_DIR)/libavutil/time.h_; \
	fi
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)/ffmpeg $(STAGING_INCLUDE_DIR)/postproc
#	cp -p	$(STAGING_INCLUDE_DIR)/libavcodec/* \
		$(STAGING_INCLUDE_DIR)/libavformat/* \
		$(STAGING_INCLUDE_DIR)/libavutil/* \
		$(STAGING_INCLUDE_DIR)/ffmpeg/
	cp -p	$(STAGING_INCLUDE_DIR)/libavcodec/* \
		$(STAGING_INCLUDE_DIR)/ffmpeg/
	cp -p	$(STAGING_INCLUDE_DIR)/libavformat/* \
		$(STAGING_INCLUDE_DIR)/ffmpeg/
	cp -p	$(STAGING_INCLUDE_DIR)/libavutil/* \
		$(STAGING_INCLUDE_DIR)/ffmpeg/
	cp -p 	$(STAGING_INCLUDE_DIR)/libpostproc/* \
		$(STAGING_INCLUDE_DIR)/postproc/
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/libavcodec.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libavformat.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libavutil.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libpostproc.pc
	touch $@

ffmpeg-stage: $(FFMPEG_BUILD_DIR)/.staged

$(FFMPEG_BUILD_DIR_OLD)/.staged: $(DL_DIR)/$(FFMPEG_SOURCE_OLD)
	rm -rf $(BUILD_DIR)/$(FFMPEG_DIR) $(@D) $(STAGING_PREFIX)/ffmpeg_old
	$(FFMPEG_UNZIP) $(DL_DIR)/$(FFMPEG_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FFMPEG_OLD_PATCHES)" ; \
		then cat $(FFMPEG_OLD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FFMPEG_DIR_OLD) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FFMPEG_DIR_OLD)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FFMPEG_DIR_OLD) $(@D) ; \
	fi
	sed -i -e 's/cpuflags=".*"/cpuflags=""/' $(@D)/configure
ifdef NO_BUILTIN_MATH
	find $(@D) -type f -name '*.[hc]' -exec sed -i -e 's/powf/pow/g' {} \;
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FFMPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FFMPEG_LDFLAGS)" \
		./configure \
		--enable-cross-compile \
		--cross-prefix=$(TARGET_CROSS) \
		--arch=$(FFMPEG_ARCH) \
		--target-os=linux \
		$(FFMPEG_OLD_CONFIG_OPTS) \
		--disable-encoder=snow \
		--disable-decoder=snow \
		--disable-shared \
		--enable-static \
		--enable-gpl \
		--prefix=$(STAGING_PREFIX)/ffmpeg_old \
	)
ifneq (, $(filter glibc shibby-tomato-arm, $(LIBC_STYLE) $(OPTWARE_TARGET)))
	for lib in CBRT CBRTF RINT LRINT LRINTF ROUND ROUNDF TRUNC TRUNCF ISINF ISNAN; do \
		sed -i -e "s/^#define HAVE_$${lib} .*/#define HAVE_$${lib} 1/" $(@D)/config.h; \
	done
endif
ifeq ($(LIBC_STYLE), uclibc)
#	No lrintf() support in uClibc 0.9.28
	sed -i -e 's/-D_ISOC9X_SOURCE//g' $(@D)/common.mak $(@D)/Makefile $(@D)/lib*/Makefile
endif
	sed -i -e '/^OPTFLAGS/s| -O3| $(TARGET_CUSTOM_FLAGS) $(FFMPEG_CPPFLAGS) $$(OPTLEVEL)|' $(@D)/config.mak
ifeq ($(OPTWARE_TARGET), $(filter cs05q1armel cs05q3armel fsg3v4, $(OPTWARE_TARGET)))
	$(MAKE) -C $(@D) OPTLEVEL=-O2 ffmpeg.o
endif
	$(MAKE) -C $(@D) OPTLEVEL=-O3 install
	$(INSTALL) -d $(STAGING_PREFIX)/ffmpeg_old/include/ffmpeg
	cp -p	$(STAGING_PREFIX)/ffmpeg_old/include/libavcodec/* \
		$(STAGING_PREFIX)/ffmpeg_old/include/ffmpeg/
	cp -p	$(STAGING_PREFIX)/ffmpeg_old/include/libavformat/* \
		$(STAGING_PREFIX)/ffmpeg_old/include/ffmpeg/
	cp -p	$(STAGING_PREFIX)/ffmpeg_old/include/libavutil/* \
		$(STAGING_PREFIX)/ffmpeg_old/include/ffmpeg/
	touch $@

ffmpeg-old-stage: $(FFMPEG_BUILD_DIR_OLD)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ffmpeg
#
$(FFMPEG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ffmpeg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FFMPEG_PRIORITY)" >>$@
	@echo "Section: $(FFMPEG_SECTION)" >>$@
	@echo "Version: $(FFMPEG_VERSION)-$(FFMPEG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FFMPEG_MAINTAINER)" >>$@
ifdef FFMPEG_GIT_DATE
	@echo "Source: $(FFMPEG_GIT)" >>$@
else
	@echo "Source: $(FFMPEG_URL)" >>$@
endif
	@echo "Description: $(FFMPEG_DESCRIPTION)" >>$@
	@echo "Depends: $(FFMPEG_DEPENDS)" >>$@
	@echo "Suggests: $(FFMPEG_SUGGESTS)" >>$@
	@echo "Conflicts: $(FFMPEG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/etc/ffmpeg/...
# Documentation files should be installed in $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/doc/ffmpeg/...
# Daemon startup scripts should be installed in $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ffmpeg
#
# You may need to patch your application to make it use these locations.
#
$(FFMPEG_IPK): $(FFMPEG_BUILD_DIR)/.built
	rm -rf $(FFMPEG_IPK_DIR) $(BUILD_DIR)/ffmpeg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FFMPEG_BUILD_DIR) mandir=$(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/share/man \
		bindir=$(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/bin libdir=$(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/lib \
		prefix=$(FFMPEG_IPK_DIR)$(TARGET_PREFIX) \
		LDCONFIG='$$(warning ldconfig disabled when building package)' install
	if [ -f $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/include/libavutil/time.h ]; then \
		mv -f $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/include/libavutil/time.h $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/include/libavutil/time.h_; \
	fi
	$(STRIP_COMMAND) $(FFMPEG_IPK_DIR)$(TARGET_PREFIX)/bin/*
	find $(FFMPEG_IPK_DIR) -type f -name "*.so" -exec $(STRIP_COMMAND) {} \;
	$(MAKE) $(FFMPEG_IPK_DIR)/CONTROL/control
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

#
# Some sanity check for the package.
#
ffmpeg-check: $(FFMPEG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
