###########################################################
#
# minidlna-rescan
#
###########################################################

#
# MINIDLNA_RESCAN_REPOSITORY defines the upstream location of the source code
# for the package.  MINIDLNA_RESCAN_DIR is the directory which is created when
# this cvs module is checked out.
#

#MINIDLNA_RESCAN_REPOSITORY=git://git.code.sf.net/p/minidlna/git
MINIDLNA_RESCAN_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/minidlna
include make/minidlna.mk
MINIDLNA_RESCAN_VERSION=$(MINIDLNA_VERSION)
MINIDLNA_RESCAN_SOURCE=minidlna-$(MINIDLNA_RESCAN_VERSION).tar.gz
MINIDLNA_RESCAN_DIR=minidlna-$(MINIDLNA_RESCAN_VERSION)
MINIDLNA_RESCAN_UNZIP=zcat
MINIDLNA_RESCAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINIDLNA_RESCAN_DESCRIPTION=MiniDLNA (aka ReadyDLNA) is server software with the aim of being fully compliant with DLNA/UPnP-AV clients. Version with non-destructive update rescan patch.
MINIDLNA_RESCAN_THUMBNAIL_DESCRIPTION=MiniDLNA (aka ReadyDLNA) is server software with the aim of being fully compliant with DLNA/UPnP-AV clients. Version with non-destructive update rescan patch and thumbnail generation support.
MINIDLNA_RESCAN_SECTION=media
MINIDLNA_RESCAN_PRIORITY=optional
MINIDLNA_RESCAN_DEPENDS=libexif, libid3tag, libjpeg, libvorbis, e2fslibs, ffmpeg, flac, sqlite, bzip2, liblzma0, libpng
MINIDLNA_RESCAN_THUMBNAIL_DEPENDS=libexif, libid3tag, libjpeg, libvorbis, e2fslibs, ffmpeg, flac, sqlite, bzip2, liblzma0, libpng, ffmpegthumbnailer
ifneq (, $(filter libiconv, $(PACKAGES)))
MINIDLNA_RESCAN_DEPENDS +=, libiconv
MINIDLNA_RESCAN_THUMBNAIL_DEPENDS +=, libiconv
endif
ifneq (, $(filter libstdc++, $(PACKAGES)))
MINIDLNA_RESCAN_DEPENDS +=, libstdc++
MINIDLNA_RESCAN_THUMBNAIL_DEPENDS +=, libstdc++
endif
MINIDLNA_RESCAN_SUGGESTS=
MINIDLNA_RESCAN_CONFLICTS=minidlna-rescan-thumbnail, minidlna, minidlna-thumbnail
MINIDLNA_RESCAN_THUMBNAIL_CONFLICTS=minidlna-rescan, minidlna, minidlna-thumbnail

#
# MINIDLNA_RESCAN_IPK_VERSION should be incremented when the ipk changes.
#
MINIDLNA_RESCAN_IPK_VERSION=5

#
# MINIDLNA_RESCAN_CONFFILES should be a list of user-editable files
MINIDLNA_RESCAN_CONFFILES=$(TARGET_PREFIX)/etc/minidlna.conf $(TARGET_PREFIX)/etc/init.d/S98minidlna

#
# MINIDLNA_RESCAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINIDLNA_RESCAN_PATCHES=\
$(MINIDLNA_RESCAN_SOURCE_DIR)/minidlna-1.1.4-git.R.L.Horn.patch \
$(MINIDLNA_RESCAN_SOURCE_DIR)/video_thumbnail-1.1.4-R.L.Horn.patch \
$(MINIDLNA_RESCAN_SOURCE_DIR)/minidlna-1.1.4_video_album_art_samsung_f-series_fix.patch \
$(MINIDLNA_RESCAN_SOURCE_DIR)/lg_searchlim.patch \
$(MINIDLNA_RESCAN_SOURCE_DIR)/minidlna-1.1.4-git.non_destructive_update_rescan.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINIDLNA_RESCAN_CPPFLAGS=
MINIDLNA_RESCAN_LDFLAGS=

#
# MINIDLNA_RESCAN_BUILD_DIR is the directory in which the build is done.
# MINIDLNA_RESCAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINIDLNA_RESCAN_IPK_DIR is the directory in which the ipk is built.
# MINIDLNA_RESCAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINIDLNA_RESCAN_BUILD_DIR=$(BUILD_DIR)/minidlna-rescan
MINIDLNA_RESCAN_SOURCE_DIR=$(SOURCE_DIR)/minidlna

MINIDLNA_RESCAN_IPK_DIR=$(BUILD_DIR)/minidlna-rescan-$(MINIDLNA_RESCAN_VERSION)-ipk
MINIDLNA_RESCAN_IPK=$(BUILD_DIR)/minidlna-rescan_$(MINIDLNA_RESCAN_VERSION)-$(MINIDLNA_RESCAN_IPK_VERSION)_$(TARGET_ARCH).ipk

MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR=$(BUILD_DIR)/minidlna-rescan-thumbnail-$(MINIDLNA_RESCAN_VERSION)-ipk
MINIDLNA_RESCAN_THUMBNAIL_IPK=$(BUILD_DIR)/minidlna-rescan-thumbnail_$(MINIDLNA_RESCAN_VERSION)-$(MINIDLNA_RESCAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: minidlna-rescan-unpack minidlna-rescan minidlna-rescan-stage minidlna-rescan-ipk minidlna-rescan-clean minidlna-rescan-dirclean minidlna-rescan-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
minidlna-rescan-source: $(MINIDLNA_RESCAN_PATCHES)
	$(MAKE) minidlna-source

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
$(MINIDLNA_RESCAN_BUILD_DIR)/.configured: $(MINIDLNA_RESCAN_PATCHES) make/minidlna-rescan.mk
	$(MAKE) minidlna-source
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifneq (, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) libexif-stage libid3tag-stage libjpeg-stage libvorbis-stage bzip2-stage xz-utils-stage \
		e2fsprogs-stage ffmpeg-stage flac-stage sqlite-stage ffmpegthumbnailer-stage libpng-stage \
		gettext-host-stage
	rm -rf $(BUILD_DIR)/$(MINIDLNA_RESCAN_DIR) $(@D)
	$(INSTALL) -d $(@D)
	tar -C $(@D) -xzf $(DL_DIR)/minidlna-$(MINIDLNA_RESCAN_VERSION).tar.gz
	if test -n "$(MINIDLNA_RESCAN_PATCHES)" ; \
		then cat $(MINIDLNA_RESCAN_PATCHES) | \
		$(PATCH) -bd $(@D)/$(MINIDLNA_RESCAN_DIR) -p1 ; \
	fi
	mv $(@D)/$(MINIDLNA_RESCAN_DIR) $(@D)/nothumbs
	tar -C $(@D) -xzf $(DL_DIR)/minidlna-$(MINIDLNA_RESCAN_VERSION).tar.gz
	if test -n "$(MINIDLNA_RESCAN_PATCHES)" ; \
		then cat $(MINIDLNA_RESCAN_PATCHES) | \
		$(PATCH) -bd $(@D)/$(MINIDLNA_RESCAN_DIR) -p1 ; \
	fi
	mv $(@D)/$(MINIDLNA_RESCAN_DIR) $(@D)/thumbs
	### configure version without thumbnails
	sed -i -e 's/AM_GNU_GETTEXT_VERSION(.*)/AM_GNU_GETTEXT_VERSION($(GETTEXT_VERSION))/' $(@D)/nothumbs/configure.ac
	$(AUTORECONF1.14) -vif $(@D)/nothumbs
	(cd $(@D)/nothumbs; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_RESCAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_RESCAN_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		XGETTEXT=$(HOST_STAGING_PREFIX)/bin/xgettext \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--program-prefix='' \
	)
	if ! $(TARGET_CC) -E sources/common/test_sendfile.c >/dev/null 2>&1; then \
		sed -i -e 's/-D_FILE_OFFSET_BITS=64 //' $(@D)/nothumbs/Makefile; \
	fi
	sed -i -e 's|-rpath -Wl,[^ \t]*|-rpath -Wl,$(TARGET_PREFIX)/lib|g' $(@D)/nothumbs/Makefile
	sed -i.orig \
		 -e 's|/etc/|$(TARGET_PREFIX)&|' \
		 -e 's|/usr/|$(TARGET_PREFIX)/|' \
		$(@D)/nothumbs/minidlna.c
	### configure version with thumbnails
	sed -i -e 's/AM_GNU_GETTEXT_VERSION(.*)/AM_GNU_GETTEXT_VERSION($(GETTEXT_VERSION))/' $(@D)/thumbs/configure.ac
	$(AUTORECONF1.14) -vif $(@D)/thumbs
	(cd $(@D)/thumbs; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_RESCAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_RESCAN_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		XGETTEXT=$(HOST_STAGING_PREFIX)/bin/xgettext \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--enable-thumbnail \
		--program-prefix='' \
	)
	if ! $(TARGET_CC) -E sources/common/test_sendfile.c >/dev/null 2>&1; then \
		sed -i -e 's/-D_FILE_OFFSET_BITS=64 //' $(@D)/thumbs/Makefile; \
	fi
	sed -i -e 's|-rpath -Wl,[^ \t]*|-rpath -Wl,$(TARGET_PREFIX)/lib|g' $(@D)/thumbs/Makefile
	sed -i.orig \
		 -e 's|/etc/|$(TARGET_PREFIX)&|' \
		 -e 's|/usr/|$(TARGET_PREFIX)/|' \
		$(@D)/thumbs/minidlna.c
	touch $@

minidlna-rescan-unpack: $(MINIDLNA_RESCAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINIDLNA_RESCAN_BUILD_DIR)/.built: $(MINIDLNA_RESCAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/nothumbs \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_RESCAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_RESCAN_LDFLAGS)" \
		;
	$(MAKE) -C $(@D)/thumbs \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_RESCAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_RESCAN_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
minidlna-rescan: $(MINIDLNA_RESCAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINIDLNA_RESCAN_BUILD_DIR)/.staged: $(MINIDLNA_RESCAN_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

minidlna-rescan-stage: $(MINIDLNA_RESCAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/minidlna-rescan
#
$(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: minidlna-rescan" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIDLNA_RESCAN_PRIORITY)" >>$@
	@echo "Section: $(MINIDLNA_RESCAN_SECTION)" >>$@
	@echo "Version: $(MINIDLNA_RESCAN_VERSION)-$(MINIDLNA_RESCAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIDLNA_RESCAN_MAINTAINER)" >>$@
ifndef MINIDLNA_RESCAN_REPOSITORY
	@echo "Source: $(MINIDLNA_RESCAN_SITE)/$(MINIDLNA_RESCAN_SOURCE)" >>$@
else
	@echo "Source: $(MINIDLNA_RESCAN_REPOSITORY)" >>$@
endif
	@echo "Description: $(MINIDLNA_RESCAN_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIDLNA_RESCAN_DEPENDS)" >>$@
	@echo "Suggests: $(MINIDLNA_RESCAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINIDLNA_RESCAN_CONFLICTS)" >>$@

$(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: minidlna-rescan-thumbnail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIDLNA_RESCAN_PRIORITY)" >>$@
	@echo "Section: $(MINIDLNA_RESCAN_SECTION)" >>$@
	@echo "Version: $(MINIDLNA_RESCAN_VERSION)-$(MINIDLNA_RESCAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIDLNA_RESCAN_MAINTAINER)" >>$@
ifndef MINIDLNA_RESCAN_REPOSITORY
	@echo "Source: $(MINIDLNA_RESCAN_SITE)/$(MINIDLNA_RESCAN_SOURCE)" >>$@
else
	@echo "Source: $(MINIDLNA_RESCAN_REPOSITORY)" >>$@
endif
	@echo "Description: $(MINIDLNA_RESCAN_THUMBNAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIDLNA_RESCAN_THUMBNAIL_DEPENDS)" >>$@
	@echo "Suggests: $(MINIDLNA_RESCAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINIDLNA_RESCAN_THUMBNAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna-rescan/...
# Documentation files should be installed in $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/doc/minidlna-rescan/...
# Daemon startup scripts should be installed in $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??minidlna-rescan
#
# You may need to patch your application to make it use these locations.
#
$(MINIDLNA_RESCAN_IPK): $(MINIDLNA_RESCAN_BUILD_DIR)/.built
	rm -rf $(MINIDLNA_RESCAN_IPK_DIR) $(BUILD_DIR)/minidlna-rescan_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIDLNA_RESCAN_BUILD_DIR)/nothumbs install \
		DESTDIR=$(MINIDLNA_RESCAN_IPK_DIR) \
		PREFIX=$(MINIDLNA_RESCAN_IPK_DIR) \
		INSTALLPREFIX=$(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX) \
		ETCINSTALLDIR=$(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc \
		;
	$(STRIP_COMMAND) $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(INSTALL) -d $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna-rescan
	$(INSTALL) -m 644 $(MINIDLNA_RESCAN_SOURCE_DIR)/minidlna.conf $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna.conf
	$(INSTALL) -m 755 $(MINIDLNA_RESCAN_SOURCE_DIR)/rc.minidlna-rescan $(MINIDLNA_RESCAN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S98minidlna
	$(MAKE) $(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MINIDLNA_RESCAN_SOURCE_DIR)/postinst $(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MINIDLNA_RESCAN_SOURCE_DIR)/prerm $(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/prerm
	echo $(MINIDLNA_RESCAN_CONFFILES) | sed -e 's/ /\n/g' > $(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIDLNA_RESCAN_IPK_DIR)

$(MINIDLNA_RESCAN_THUMBNAIL_IPK): $(MINIDLNA_RESCAN_BUILD_DIR)/.built
	rm -rf $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR) $(BUILD_DIR)/minidlna-rescan-thumbnail_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIDLNA_RESCAN_BUILD_DIR)/thumbs install \
		DESTDIR=$(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR) \
		PREFIX=$(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR) \
		INSTALLPREFIX=$(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX) \
		ETCINSTALLDIR=$(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc \
		;
	$(STRIP_COMMAND) $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(INSTALL) -d $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 644 $(MINIDLNA_RESCAN_SOURCE_DIR)/minidlna.thumbs.conf $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna.conf
	$(INSTALL) -m 755 $(MINIDLNA_RESCAN_SOURCE_DIR)/rc.minidlna-rescan $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S98minidlna
	$(MAKE) $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MINIDLNA_RESCAN_SOURCE_DIR)/postinst $(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MINIDLNA_RESCAN_SOURCE_DIR)/prerm $(MINIDLNA_RESCAN_IPK_DIR)/CONTROL/prerm
	echo $(MINIDLNA_RESCAN_CONFFILES) | sed -e 's/ /\n/g' > $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
minidlna-rescan-ipk: $(MINIDLNA_RESCAN_IPK) $(MINIDLNA_RESCAN_THUMBNAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
minidlna-rescan-clean:
	rm -f $(MINIDLNA_RESCAN_BUILD_DIR)/.built
	-$(MAKE) -C $(MINIDLNA_RESCAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
minidlna-rescan-dirclean:
	rm -rf $(BUILD_DIR)/$(MINIDLNA_RESCAN_DIR) $(MINIDLNA_RESCAN_BUILD_DIR) \
		$(MINIDLNA_RESCAN_IPK_DIR) $(MINIDLNA_RESCAN_IPK) \
		$(MINIDLNA_RESCAN_THUMBNAIL_IPK_DIR) $(MINIDLNA_RESCAN_THUMBNAIL_IPK)

#
# Some sanity check for the package.
#
minidlna-rescan-check: $(MINIDLNA_RESCAN_IPK) $(MINIDLNA_RESCAN_THUMBNAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
