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
# Check http://svn.mplayerhq.hu/ffmpeg/trunk/
# Take care when upgrading for multiple targets
FFMPEG_SVN=svn://svn.mplayerhq.hu/ffmpeg/trunk
FFMPEG_SVN_DATE=20080409
FFMPEG_VERSION=0.svn$(FFMPEG_SVN_DATE)
FFMPEG_DIR=ffmpeg-$(FFMPEG_VERSION)
FFMPEG_SOURCE=$(FFMPEG_DIR).tar.bz2
FFMPEG_UNZIP=bzcat
FFMPEG_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
FFMPEG_DESCRIPTION=FFmpeg is an audio/video conversion tool.
FFMPEG_SECTION=tool
FFMPEG_PRIORITY=optional
FFMPEG_DEPENDS=
FFMPEG_SUGGESTS=
FFMPEG_CONFLICTS=

#
# FFMPEG_IPK_VERSION should be incremented when the ipk changes.
#
FFMPEG_IPK_VERSION=2

#
# FFMPEG_CONFFILES should be a list of user-editable files
#FFMPEG_CONFFILES=/opt/etc/ffmpeg.conf /opt/etc/init.d/SXXffmpeg

#
## FFMPEG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FFMPEG_PATCHES=
ifeq ($(LIBC_STYLE), uclibc)
FFMPEG_PATCHES += $(FFMPEG_SOURCE_DIR)/disable-C99-math-funcs.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FFMPEG_CPPFLAGS=
ifdef NO_BUILTIN_MATH
FFMPEG_CPPFLAGS += -fno-builtin-cos -fno-builtin-sin -fno-builtin-lrint -fno-builtin-rint
FFMPEG_PATCHES += $(FFMPEG_SOURCE_DIR)/powf-to-pow.patch
endif
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
FFMPEG_IPK=$(BUILD_DIR)/ffmpeg_$(FFMPEG_VERSION)-$(FFMPEG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(FFMPEG_SOURCE):
#	$(WGET) -P $(DL_DIR) $(FFMPEG_SITE)/$(FFMPEG_SOURCE)

$(DL_DIR)/$(FFMPEG_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(FFMPEG_DIR) && \
		svn co -r '{$(FFMPEG_SVN_DATE)}' $(FFMPEG_SVN) $(FFMPEG_DIR) && \
		tar -cjf $@ $(FFMPEG_DIR) --exclude .svn && \
		rm -rf $(FFMPEG_DIR) \
	)


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
#
FFMPEG_ARCH=$(strip \
	$(if $(filter armeb, $(TARGET_ARCH)), arm, \
	$(TARGET_ARCH)))

# Snow is know to create build problems on ds101 

$(FFMPEG_BUILD_DIR)/.configured: $(DL_DIR)/$(FFMPEG_SOURCE) $(FFMPEG_PATCHES) make/ffmpeg.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FFMPEG_DIR) $(@D)
	$(FFMPEG_UNZIP) $(DL_DIR)/$(FFMPEG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FFMPEG_PATCHES)" ; \
		then cat $(FFMPEG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FFMPEG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FFMPEG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FFMPEG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FFMPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FFMPEG_LDFLAGS)" \
		./configure \
		--enable-cross-compile \
		--cross-prefix=$(TARGET_CROSS) \
		--arch=$(FFMPEG_ARCH) \
		--disable-encoder=snow \
		--disable-decoder=snow \
		--enable-shared \
		--disable-static \
		--enable-gpl \
		--enable-postproc \
		--prefix=/opt \
	)
ifeq ($(LIBC_STYLE), uclibc)
#	No lrintf() support in uClibc 0.9.28
	sed -i -e 's/-D_ISOC9X_SOURCE//g' $(@D)/common.mak $(@D)/Makefile $(@D)/lib*/Makefile
endif
	sed -i -e '/^OPTFLAGS/s| -O3| $(TARGET_CUSTOM_FLAGS) $(FFMPEG_CPPFLAGS) $$(OPTLEVEL)|' $(@D)/config.mak
	touch $@
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
##		--disable-nls \

ffmpeg-unpack: $(FFMPEG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FFMPEG_BUILD_DIR)/.built: $(FFMPEG_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(OPTWARE_TARGET), $(filter cs05q3armel fsg3v4, $(OPTWARE_TARGET)))
	$(MAKE) -C $(@D) OPTLEVEL=-O2 ffmpeg.o
endif
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
		mandir=$(STAGING_DIR)/opt/man \
		bindir=$(STAGING_DIR)/opt/bin \
		prefix=$(STAGING_DIR)/opt \
		DESTDIR=$(STAGING_DIR)
	install -d $(STAGING_INCLUDE_DIR)/ffmpeg $(STAGING_INCLUDE_DIR)/postproc
	cp -p	$(STAGING_INCLUDE_DIR)/libavcodec/* \
		$(STAGING_INCLUDE_DIR)/libavformat/* \
		$(STAGING_INCLUDE_DIR)/libavutil/* \
		$(STAGING_INCLUDE_DIR)/ffmpeg/
	cp -p	$(STAGING_INCLUDE_DIR)/libpostproc/* \
		$(STAGING_INCLUDE_DIR)/postproc/
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/libavcodec.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libavformat.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libavutil.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libpostproc.pc
	touch $@

ffmpeg-stage: $(FFMPEG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ffmpeg
#
$(FFMPEG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ffmpeg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FFMPEG_PRIORITY)" >>$@
	@echo "Section: $(FFMPEG_SECTION)" >>$@
	@echo "Version: $(FFMPEG_VERSION)-$(FFMPEG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FFMPEG_MAINTAINER)" >>$@
	@echo "Source: $(FFMPEG_SITE)/$(FFMPEG_SOURCE)" >>$@
	@echo "Description: $(FFMPEG_DESCRIPTION)" >>$@
	@echo "Depends: $(FFMPEG_DEPENDS)" >>$@
	@echo "Suggests: $(FFMPEG_SUGGESTS)" >>$@
	@echo "Conflicts: $(FFMPEG_CONFLICTS)" >>$@

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
	rm -rf $(FFMPEG_IPK_DIR) $(BUILD_DIR)/ffmpeg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FFMPEG_BUILD_DIR) mandir=$(FFMPEG_IPK_DIR)/opt/man \
		bindir=$(FFMPEG_IPK_DIR)/opt/bin libdir=$(FFMPEG_IPK_DIR)/opt/lib \
		prefix=$(FFMPEG_IPK_DIR)/opt DESTDIR=$(FFMPEG_IPK_DIR) \
		LDCONFIG='$$(warning ldconfig disabled when building package)' install
	$(TARGET_STRIP) $(FFMPEG_IPK_DIR)/opt/bin/ffmpeg
	$(TARGET_STRIP) $(FFMPEG_IPK_DIR)/opt/bin/ffserver
	$(TARGET_STRIP) $(FFMPEG_IPK_DIR)/opt/lib/*.so
	$(TARGET_STRIP) $(FFMPEG_IPK_DIR)/opt/lib/vhook/*.so
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FFMPEG_IPK)
