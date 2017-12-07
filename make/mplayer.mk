###########################################################
#
# mplayer
#
###########################################################
#
# MPLAYER_VERSION, MPLAYER_SITE and MPLAYER_SOURCE define
# the upstream location of the source code for the package.
# MPLAYER_DIR is the directory which is created when the source
# archive is unpacked.
# MPLAYER_UNZIP is the command used to unzip the source.
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
MPLAYER_URL=http://www.mplayerhq.hu/MPlayer/releases/$(MPLAYER_SOURCE)
MPLAYER_VERSION=1.3.0
MPLAYER_SOURCE=MPlayer-$(MPLAYER_VERSION).tar.xz
MPLAYER_DIR=MPlayer-$(MPLAYER_VERSION)
MPLAYER_UNZIP=xzcat
MPLAYER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPLAYER_DESCRIPTION=The MPlayer, without X11/GTK GUI.
MPLAYER_SECTION=media
MPLAYER_PRIORITY=optional
MPLAYER_DEPENDS=alsa-lib, esound, fontconfig, freetype, fribidi, rtmpdump, mpg123, \
	libass, libtheora, libogg, xvid, speex, lame, libmad, openjpeg, faad2, zlib, \
	bzip2, lzo, libvorbisidec, liba52, libmpeg2, libdvdnav, x264
MPLAYER_SUGGESTS=
MPLAYER_CONFLICTS=

#
# MPLAYER_IPK_VERSION should be incremented when the ipk changes.
#
MPLAYER_IPK_VERSION=3

#
# MPLAYER_CONFFILES should be a list of user-editable files
#MPLAYER_CONFFILES=$(TARGET_PREFIX)/etc/mplayer.conf $(TARGET_PREFIX)/etc/init.d/SXXmplayer

#
# MPLAYER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq (, $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
MPLAYER_PATCHES=$(MPLAYER_SOURCE_DIR)/libvo-vo_4l2.c.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPLAYER_CPPFLAGS=
MPLAYER_LDFLAGS=

#
# MPLAYER_BUILD_DIR is the directory in which the build is done.
# MPLAYER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPLAYER_IPK_DIR is the directory in which the ipk is built.
# MPLAYER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPLAYER_BUILD_DIR=$(BUILD_DIR)/mplayer
MPLAYER_SOURCE_DIR=$(SOURCE_DIR)/mplayer
MPLAYER_IPK_DIR=$(BUILD_DIR)/mplayer-$(MPLAYER_VERSION)-ipk
MPLAYER_IPK=$(BUILD_DIR)/mplayer_$(MPLAYER_VERSION)-$(MPLAYER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mplayer-source mplayer-unpack mplayer mplayer-stage mplayer-ipk mplayer-clean mplayer-dirclean mplayer-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(MPLAYER_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(MPLAYER_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(MPLAYER_SOURCE).sha512
#
$(DL_DIR)/$(MPLAYER_SOURCE):
	$(WGET) -O $@ $(MPLAYER_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mplayer-source: $(DL_DIR)/$(MPLAYER_SOURCE) $(MPLAYER_PATCHES)

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
$(MPLAYER_BUILD_DIR)/.configured: $(DL_DIR)/$(MPLAYER_SOURCE) $(MPLAYER_PATCHES) make/mplayer.mk
	$(MAKE) alsa-lib-stage esound-stage fontconfig-stage freetype-stage fribidi-stage \
		rtmpdump-stage mpg123-stage libass-stage libtheora-stage libogg-stage \
		xvid-stage speex-stage lame-stage libmad-stage openjpeg-stage faad2-stage \
		zlib-stage bzip2-stage lzo-stage libvorbisidec-stage liba52-stage \
		libmpeg2-stage libdvdnav-stage x264-stage
	rm -rf $(BUILD_DIR)/$(MPLAYER_DIR) $(@D)
	$(MPLAYER_UNZIP) $(DL_DIR)/$(MPLAYER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPLAYER_PATCHES)" ; \
		then cat $(MPLAYER_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MPLAYER_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MPLAYER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MPLAYER_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPLAYER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPLAYER_LDFLAGS)" \
		./configure \
		--enable-cross-compile \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--disable-x11 \
		--disable-gui \
		--disable-xinerama \
		--disable-smb \
		--disable-gl \
	)
	touch $@

mplayer-unpack: $(MPLAYER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPLAYER_BUILD_DIR)/.built: $(MPLAYER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mplayer: $(MPLAYER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPLAYER_BUILD_DIR)/.staged: $(MPLAYER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mplayer-stage: $(MPLAYER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mplayer
#
$(MPLAYER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mplayer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPLAYER_PRIORITY)" >>$@
	@echo "Section: $(MPLAYER_SECTION)" >>$@
	@echo "Version: $(MPLAYER_VERSION)-$(MPLAYER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPLAYER_MAINTAINER)" >>$@
	@echo "Source: $(MPLAYER_URL)" >>$@
	@echo "Description: $(MPLAYER_DESCRIPTION)" >>$@
	@echo "Depends: $(MPLAYER_DEPENDS)" >>$@
	@echo "Suggests: $(MPLAYER_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPLAYER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/mplayer/...
# Documentation files should be installed in $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/doc/mplayer/...
# Daemon startup scripts should be installed in $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mplayer
#
# You may need to patch your application to make it use these locations.
#
$(MPLAYER_IPK): $(MPLAYER_BUILD_DIR)/.built
	rm -rf $(MPLAYER_IPK_DIR) $(BUILD_DIR)/mplayer_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPLAYER_BUILD_DIR) DESTDIR=$(MPLAYER_IPK_DIR) INSTALLSTRIP="" install
	cd $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/bin; $(STRIP_COMMAND) mencoder mplayer
#	$(INSTALL) -d $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MPLAYER_SOURCE_DIR)/mplayer.conf $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/mplayer.conf
#	$(INSTALL) -d $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MPLAYER_SOURCE_DIR)/rc.mplayer $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmplayer
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MPLAYER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmplayer
	$(MAKE) $(MPLAYER_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MPLAYER_SOURCE_DIR)/postinst $(MPLAYER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MPLAYER_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MPLAYER_SOURCE_DIR)/prerm $(MPLAYER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MPLAYER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MPLAYER_IPK_DIR)/CONTROL/postinst $(MPLAYER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MPLAYER_CONFFILES) | sed -e 's/ /\n/g' > $(MPLAYER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPLAYER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MPLAYER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mplayer-ipk: $(MPLAYER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mplayer-clean:
	rm -f $(MPLAYER_BUILD_DIR)/.built
	-$(MAKE) -C $(MPLAYER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mplayer-dirclean:
	rm -rf $(BUILD_DIR)/$(MPLAYER_DIR) $(MPLAYER_BUILD_DIR) $(MPLAYER_IPK_DIR) $(MPLAYER_IPK)
#
#
# Some sanity check for the package.
#
mplayer-check: $(MPLAYER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
