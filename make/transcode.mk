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
#TRANSCODE_REPOSITORY=:pserver:cvs@cvs.exit1.org:/cvstc
TRANSCODE_SITE=https://launchpad.net/ubuntu/+archive/primary/+files
TRANSCODE_VERSION=1.1.7
TRANSCODE_SOURCE=transcode_$(TRANSCODE_VERSION).orig.tar.bz2
#TRANSCODE_TAG=-D 2005-02-13
#TRANSCODE_MODULE=transcode
TRANSCODE_DIR=transcode-$(TRANSCODE_VERSION)
TRANSCODE_UNZIP=bzcat
TRANSCODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TRANSCODE_DESCRIPTION=Transcode is a suite of tools, all of which are command line utilities, for transcoding various video, audio, and container formats, running on a platform that supports shared libraries and threads.
TRANSCODE_SECTION=tool
TRANSCODE_PRIORITY=optional
TRANSCODE_DEPENDS=freetype, lame, liba52, libdvdread, libmpeg2, libogg, libvorbis, lzo, ffmpeg, libjpeg, libxml2
TRANSCODE_SUGGESTS=
TRANSCODE_CONFLICTS=

#
# TRANSCODE_IPK_VERSION should be incremented when the ipk changes.
#
TRANSCODE_IPK_VERSION=4

#
# TRANSCODE_CONFFILES should be a list of user-editable files
TRANSCODE_CONFFILES=$(TARGET_PREFIX)/etc/transcode.conf $(TARGET_PREFIX)/etc/init.d/SXXtranscode

#
## TRANSCODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TRANSCODE_PATCHES=$(TRANSCODE_SOURCE_DIR)/01_filter_pv.c.diff \
$(TRANSCODE_SOURCE_DIR)/03_libav-api-fixes.diff \
$(TRANSCODE_SOURCE_DIR)/04_ffmpeg_options.patch \
$(TRANSCODE_SOURCE_DIR)/ac3-audio-track-number.patch \
$(TRANSCODE_SOURCE_DIR)/05-libav9-gentoo.patch \
$(TRANSCODE_SOURCE_DIR)/06_libav9-jmm.patch \
$(TRANSCODE_SOURCE_DIR)/07_libav9-preset.patch \
$(TRANSCODE_SOURCE_DIR)/08_libav9-opt.patch \
$(TRANSCODE_SOURCE_DIR)/09_libav9-arch.patch \
$(TRANSCODE_SOURCE_DIR)/10_freetype.patch \
$(TRANSCODE_SOURCE_DIR)/11_libav10.patch \
$(TRANSCODE_SOURCE_DIR)/12_underlinkage.patch \
$(TRANSCODE_SOURCE_DIR)/13-fix-cross-configure.in.patch \
$(TRANSCODE_SOURCE_DIR)/14-libavresample-conditional.patch \
$(TRANSCODE_SOURCE_DIR)/ffmpeg29.patch \
$(TRANSCODE_SOURCE_DIR)/transcode_h_include_time_h.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRANSCODE_CPPFLAGS=-DO_LARGEFILE -DSYS_BSD -I$(STAGING_INCLUDE_DIR)/freetype2
TRANSCODE_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
TRANSCODE_CONFIG_ENV=ac_cv_func_malloc_0_nonnull=yes
else
TRANSCODE_CONFIG_ENV=
endif

ifeq ($(OPTWARE_TARGET), ds101g)
TRANSCODE_CONFIG_ARG=--enable-altivec
else
TRANSCODE_CONFIG_ARG=--disable-iconv
endif

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
TRANSCODE_IPK=$(BUILD_DIR)/transcode_$(TRANSCODE_VERSION)-$(TRANSCODE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: transcode-source transcode-unpack transcode transcode-stage transcode-ipk transcode-clean transcode-dirclean transcode-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TRANSCODE_SOURCE):
#	cd $(DL_DIR) ; $(CVS) -z3 -d $(TRANSCODE_REPOSITORY) co $(TRANSCODE_TAG) $(TRANSCODE_MODULE)
#	mv $(DL_DIR)/$(TRANSCODE_MODULE) $(DL_DIR)/$(TRANSCODE_DIR)
#	cd $(DL_DIR) ; tar zcvf $(TRANSCODE_SOURCE) $(TRANSCODE_DIR)
#	rm -rf $(DL_DIR)/$(TRANSCODE_DIR)
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
$(TRANSCODE_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSCODE_SOURCE) $(TRANSCODE_PATCHES) make/transcode.mk
	$(MAKE) ffmpeg-stage \
		freetype-stage lame-stage \
		liba52-stage libdvdread-stage \
		libjpeg-stage libmpeg2-stage \
		libogg-stage libvorbis-stage \
		libxml2-stage lzo-stage
	rm -rf $(BUILD_DIR)/$(TRANSCODE_DIR) $(TRANSCODE_BUILD_DIR)
	$(TRANSCODE_UNZIP) $(DL_DIR)/$(TRANSCODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSCODE_PATCHES)"; \
		then cat $(TRANSCODE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(TRANSCODE_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(TRANSCODE_DIR) $(TRANSCODE_BUILD_DIR)
#	sed -ie '/extern int verbose/d' $(TRANSCODE_BUILD_DIR)/src/transcode.h
#	sed -ie '/static int verbose/d' $(TRANSCODE_BUILD_DIR)/import/dvd_reader.c
#	sed -ie 's/static int verbose/extern int verbose/' $(TRANSCODE_BUILD_DIR)/import/tcextract.c
	$(AUTORECONF1.10) -vif $(@D)
	sed -ie 's|="-I/usr/include"|=""|g' $(TRANSCODE_BUILD_DIR)/configure
	(cd $(TRANSCODE_BUILD_DIR); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		FT2_CONFIG="$(STAGING_PREFIX)/bin/freetype-config";export FT2_CONFIG; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSCODE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSCODE_LDFLAGS)" \
		$(TRANSCODE_CONFIG_ENV) \
		./configure -C \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--without-x \
		--with-a52-prefix=$(STAGING_PREFIX) \
		--with-avifile-prefix=$(STAGING_PREFIX) \
		--with-freetype2-prefix=$(STAGING_PREFIX) \
		--with-lame-prefix=$(STAGING_PREFIX) \
		--with-libdv-prefix=$(STAGING_PREFIX) \
		--with-libdvdread-prefix=$(STAGING_PREFIX) \
		--with-libjpeg-prefix=$(STAGING_PREFIX) \
		--with-libmpeg2-prefix=$(STAGING_PREFIX) \
		--with-libxml2-prefix=$(STAGING_PREFIX) \
		--with-ogg-prefix=$(STAGING_PREFIX) \
		--with-vorbis-prefix=$(STAGING_PREFIX) \
		\
		--enable-a52 \
		--enable-freetype2 \
		--enable-libxml2 \
		--enable-lzo \
		--enable-ogg \
		--enable-vorbis \
		--disable-libavresample \
		--disable-nls \
		$(TRANSCODE_CONFIG_ARG) \
		; \
	)
	sed -i -e "/#define TC_LAME_VERSION/s/$$/ `echo $(LAME_VERSION) | sed s:[.]:: | sed s:[.].*::`/" \
		 $(TRANSCODE_BUILD_DIR)/config.h
	$(PATCH_LIBTOOL) $(TRANSCODE_BUILD_DIR)/libtool
	touch $@

transcode-unpack: $(TRANSCODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRANSCODE_BUILD_DIR)/.built: $(TRANSCODE_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) 'CFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2' -C $(TRANSCODE_BUILD_DIR)
	$(MAKE) -C $(TRANSCODE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
transcode: $(TRANSCODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TRANSCODE_BUILD_DIR)/.staged: $(TRANSCODE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TRANSCODE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

transcode-stage: $(TRANSCODE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/transcode
#
$(TRANSCODE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(TRANSCODE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: transcode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRANSCODE_PRIORITY)" >>$@
	@echo "Section: $(TRANSCODE_SECTION)" >>$@
	@echo "Version: $(TRANSCODE_VERSION)-$(TRANSCODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TRANSCODE_MAINTAINER)" >>$@
	@echo "Source: $(TRANSCODE_SITE)/$(TRANSCODE_SOURCE)" >>$@
	@echo "Description: $(TRANSCODE_DESCRIPTION)" >>$@
	@echo "Depends: $(TRANSCODE_DEPENDS)" >>$@
	@echo "Suggests: $(TRANSCODE_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRANSCODE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRANSCODE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(TRANSCODE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRANSCODE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(TRANSCODE_IPK_DIR)$(TARGET_PREFIX)/etc/transcode/...
# Documentation files should be installed in $(TRANSCODE_IPK_DIR)$(TARGET_PREFIX)/doc/transcode/...
# Daemon startup scripts should be installed in $(TRANSCODE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??transcode
#
# You may need to patch your application to make it use these locations.
#
$(TRANSCODE_IPK): $(TRANSCODE_BUILD_DIR)/.built
	rm -rf $(TRANSCODE_IPK_DIR) $(BUILD_DIR)/transcode_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TRANSCODE_BUILD_DIR) DESTDIR=$(TRANSCODE_IPK_DIR) program_transform_name="" install-strip
	$(MAKE) $(TRANSCODE_IPK_DIR)/CONTROL/control
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

#
# Some sanity check for the package.
#
transcode-check: $(TRANSCODE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TRANSCODE_IPK)
