###########################################################
#
# minidlna
#
###########################################################

#
# MINIDLNA_REPOSITORY defines the upstream location of the source code
# for the package.  MINIDLNA_DIR is the directory which is created when
# this cvs module is checked out.
#

ifndef MINIDLNA_SITE
#MINIDLNA_REPOSITORY=git://git.code.sf.net/p/minidlna/git
MINIDLNA_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/minidlna
ifndef MINIDLNA_REPOSITORY
MINIDLNA_VERSION=1.1.5
else
MINIDLNA_VERSION=1.1.4+git20150805
MINIDLNA_TREEISH=`git rev-list --max-count=1 --until=2015-08-05 HEAD`
endif
MINIDLNA_SOURCE=minidlna-$(MINIDLNA_VERSION).tar.gz
MINIDLNA_DIR=minidlna-$(MINIDLNA_VERSION)
MINIDLNA_UNZIP=zcat
MINIDLNA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINIDLNA_DESCRIPTION=MiniDLNA (aka ReadyDLNA) is server software with the aim of being fully compliant with DLNA/UPnP-AV clients.
MINIDLNA_THUMBNAIL_DESCRIPTION=MiniDLNA (aka ReadyDLNA) is server software with the aim of being fully compliant with DLNA/UPnP-AV clients. Version with thumbnail generation support.
MINIDLNA_SECTION=media
MINIDLNA_PRIORITY=optional
MINIDLNA_DEPENDS=libexif, libid3tag, libjpeg, libvorbis, e2fslibs, ffmpeg, flac, sqlite, bzip2, liblzma0, libpng
MINIDLNA_THUMBNAIL_DEPENDS=libexif, libid3tag, libjpeg, libvorbis, e2fslibs, ffmpeg, flac, sqlite, bzip2, liblzma0, libpng, ffmpegthumbnailer
ifneq (, $(filter libiconv, $(PACKAGES)))
MINIDLNA_DEPENDS +=, libiconv
MINIDLNA_THUMBNAIL_DEPENDS +=, libiconv
endif
ifneq (, $(filter libstdc++, $(PACKAGES)))
MINIDLNA_DEPENDS +=, libstdc++
MINIDLNA_THUMBNAIL_DEPENDS +=, libstdc++
endif
MINIDLNA_SUGGESTS=
MINIDLNA_CONFLICTS=minidlna-thumbnail, minidlna-rescan, minidlna-rescan-thumbnail
MINIDLNA_THUMBNAIL_CONFLICTS=minidlna, minidlna-rescan, minidlna-rescan-thumbnail

#
# MINIDLNA_IPK_VERSION should be incremented when the ipk changes.
#
MINIDLNA_IPK_VERSION=5

#
# MINIDLNA_CONFFILES should be a list of user-editable files
MINIDLNA_CONFFILES=$(TARGET_PREFIX)/etc/minidlna.conf $(TARGET_PREFIX)/etc/init.d/S98minidlna

#
# MINIDLNA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINIDLNA_PATCHES=\
$(MINIDLNA_SOURCE_DIR)/minidlna-1.1.4-git.R.L.Horn.patch \
$(MINIDLNA_SOURCE_DIR)/video_thumbnail-1.1.4-R.L.Horn.patch \
$(MINIDLNA_SOURCE_DIR)/minidlna-1.1.4_video_album_art_samsung_f-series_fix.patch \
$(MINIDLNA_SOURCE_DIR)/lg_searchlim.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINIDLNA_CPPFLAGS=
MINIDLNA_LDFLAGS=

#
# MINIDLNA_BUILD_DIR is the directory in which the build is done.
# MINIDLNA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINIDLNA_IPK_DIR is the directory in which the ipk is built.
# MINIDLNA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINIDLNA_BUILD_DIR=$(BUILD_DIR)/minidlna
MINIDLNA_SOURCE_DIR=$(SOURCE_DIR)/minidlna

MINIDLNA_IPK_DIR=$(BUILD_DIR)/minidlna-$(MINIDLNA_VERSION)-ipk
MINIDLNA_IPK=$(BUILD_DIR)/minidlna_$(MINIDLNA_VERSION)-$(MINIDLNA_IPK_VERSION)_$(TARGET_ARCH).ipk

MINIDLNA_THUMBNAIL_IPK_DIR=$(BUILD_DIR)/minidlna-thumbnail-$(MINIDLNA_VERSION)-ipk
MINIDLNA_THUMBNAIL_IPK=$(BUILD_DIR)/minidlna-thumbnail_$(MINIDLNA_VERSION)-$(MINIDLNA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: minidlna-source minidlna-unpack minidlna minidlna-stage minidlna-ipk minidlna-clean minidlna-dirclean minidlna-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINIDLNA_SOURCE):
ifndef MINIDLNA_REPOSITORY
	$(WGET) -P $(@D) $(MINIDLNA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	(cd $(BUILD_DIR) ; \
		rm -rf minidlna && \
		git clone --bare $(MINIDLNA_REPOSITORY) minidlna && \
		(cd minidlna && \
		git archive --format=tar --prefix=$(MINIDLNA_DIR)/ $(MINIDLNA_TREEISH) | gzip > $@) && \
		rm -rf minidlna ; \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
minidlna-source: $(DL_DIR)/$(MINIDLNA_SOURCE) $(MINIDLNA_PATCHES)

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
$(MINIDLNA_BUILD_DIR)/.configured: $(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz $(MINIDLNA_PATCHES) make/minidlna.mk
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifneq (, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) libexif-stage libid3tag-stage libjpeg-stage libvorbis-stage bzip2-stage xz-utils-stage \
		e2fsprogs-stage ffmpeg-stage flac-stage sqlite-stage ffmpegthumbnailer-stage libpng-stage \
		gettext-host-stage
	rm -rf $(BUILD_DIR)/$(MINIDLNA_DIR) $(@D)
	$(INSTALL) -d $(@D)
	tar -C $(@D) -xzf $(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz
	if test -n "$(MINIDLNA_PATCHES)" ; \
		then cat $(MINIDLNA_PATCHES) | \
		$(PATCH) -bd $(@D)/$(MINIDLNA_DIR) -p1 ; \
	fi
	mv $(@D)/$(MINIDLNA_DIR) $(@D)/nothumbs
	tar -C $(@D) -xzf $(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz
	if test -n "$(MINIDLNA_PATCHES)" ; \
		then cat $(MINIDLNA_PATCHES) | \
		$(PATCH) -bd $(@D)/$(MINIDLNA_DIR) -p1 ; \
	fi
	mv $(@D)/$(MINIDLNA_DIR) $(@D)/thumbs
	### configure version without thumbnails
	sed -i -e 's/AM_GNU_GETTEXT_VERSION(.*)/AM_GNU_GETTEXT_VERSION($(GETTEXT_VERSION))/' $(@D)/nothumbs/configure.ac
	$(AUTORECONF1.14) -vif $(@D)/nothumbs
	(cd $(@D)/nothumbs; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_LDFLAGS)" \
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
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_LDFLAGS)" \
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

minidlna-unpack: $(MINIDLNA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINIDLNA_BUILD_DIR)/.built: $(MINIDLNA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/nothumbs \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_LDFLAGS)" \
		;
	$(MAKE) -C $(@D)/thumbs \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
minidlna: $(MINIDLNA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINIDLNA_BUILD_DIR)/.staged: $(MINIDLNA_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

minidlna-stage: $(MINIDLNA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/minidlna
#
$(MINIDLNA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: minidlna" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIDLNA_PRIORITY)" >>$@
	@echo "Section: $(MINIDLNA_SECTION)" >>$@
	@echo "Version: $(MINIDLNA_VERSION)-$(MINIDLNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIDLNA_MAINTAINER)" >>$@
ifndef MINIDLNA_REPOSITORY
	@echo "Source: $(MINIDLNA_SITE)/$(MINIDLNA_SOURCE)" >>$@
else
	@echo "Source: $(MINIDLNA_REPOSITORY)" >>$@
endif
	@echo "Description: $(MINIDLNA_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIDLNA_DEPENDS)" >>$@
	@echo "Suggests: $(MINIDLNA_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINIDLNA_CONFLICTS)" >>$@

$(MINIDLNA_THUMBNAIL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: minidlna-thumbnail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIDLNA_PRIORITY)" >>$@
	@echo "Section: $(MINIDLNA_SECTION)" >>$@
	@echo "Version: $(MINIDLNA_VERSION)-$(MINIDLNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIDLNA_MAINTAINER)" >>$@
ifndef MINIDLNA_REPOSITORY
	@echo "Source: $(MINIDLNA_SITE)/$(MINIDLNA_SOURCE)" >>$@
else
	@echo "Source: $(MINIDLNA_REPOSITORY)" >>$@
endif
	@echo "Description: $(MINIDLNA_THUMBNAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIDLNA_THUMBNAIL_DEPENDS)" >>$@
	@echo "Suggests: $(MINIDLNA_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINIDLNA_THUMBNAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna/...
# Documentation files should be installed in $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/doc/minidlna/...
# Daemon startup scripts should be installed in $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??minidlna
#
# You may need to patch your application to make it use these locations.
#
$(MINIDLNA_IPK): $(MINIDLNA_BUILD_DIR)/.built
	rm -rf $(MINIDLNA_IPK_DIR) $(BUILD_DIR)/minidlna_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIDLNA_BUILD_DIR)/nothumbs install \
		DESTDIR=$(MINIDLNA_IPK_DIR) \
		PREFIX=$(MINIDLNA_IPK_DIR) \
		INSTALLPREFIX=$(MINIDLNA_IPK_DIR)$(TARGET_PREFIX) \
		ETCINSTALLDIR=$(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc \
		;
	$(STRIP_COMMAND) $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(INSTALL) -d $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna
	$(INSTALL) -m 644 $(MINIDLNA_SOURCE_DIR)/minidlna.conf $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna.conf
	$(INSTALL) -m 755 $(MINIDLNA_SOURCE_DIR)/rc.minidlna $(MINIDLNA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S98minidlna
	$(MAKE) $(MINIDLNA_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MINIDLNA_SOURCE_DIR)/postinst $(MINIDLNA_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MINIDLNA_SOURCE_DIR)/prerm $(MINIDLNA_IPK_DIR)/CONTROL/prerm
	echo $(MINIDLNA_CONFFILES) | sed -e 's/ /\n/g' > $(MINIDLNA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIDLNA_IPK_DIR)

$(MINIDLNA_THUMBNAIL_IPK): $(MINIDLNA_BUILD_DIR)/.built
	rm -rf $(MINIDLNA_THUMBNAIL_IPK_DIR) $(BUILD_DIR)/minidlna-thumbnail_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIDLNA_BUILD_DIR)/thumbs install \
		DESTDIR=$(MINIDLNA_THUMBNAIL_IPK_DIR) \
		PREFIX=$(MINIDLNA_THUMBNAIL_IPK_DIR) \
		INSTALLPREFIX=$(MINIDLNA_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX) \
		ETCINSTALLDIR=$(MINIDLNA_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc \
		;
	$(STRIP_COMMAND) $(MINIDLNA_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(INSTALL) -d $(MINIDLNA_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 644 $(MINIDLNA_SOURCE_DIR)/minidlna.thumbs.conf $(MINIDLNA_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc/minidlna.conf
	$(INSTALL) -m 755 $(MINIDLNA_SOURCE_DIR)/rc.minidlna $(MINIDLNA_THUMBNAIL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S98minidlna
	$(MAKE) $(MINIDLNA_THUMBNAIL_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MINIDLNA_SOURCE_DIR)/postinst $(MINIDLNA_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MINIDLNA_SOURCE_DIR)/prerm $(MINIDLNA_IPK_DIR)/CONTROL/prerm
	echo $(MINIDLNA_CONFFILES) | sed -e 's/ /\n/g' > $(MINIDLNA_THUMBNAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIDLNA_THUMBNAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
minidlna-ipk: $(MINIDLNA_IPK) $(MINIDLNA_THUMBNAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
minidlna-clean:
	rm -f $(MINIDLNA_BUILD_DIR)/.built
	-$(MAKE) -C $(MINIDLNA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
minidlna-dirclean:
	rm -rf $(BUILD_DIR)/$(MINIDLNA_DIR) $(MINIDLNA_BUILD_DIR) \
		$(MINIDLNA_IPK_DIR) $(MINIDLNA_IPK) \
		$(MINIDLNA_THUMBNAIL_IPK_DIR) $(MINIDLNA_THUMBNAIL_IPK)

#
# Some sanity check for the package.
#
minidlna-check: $(MINIDLNA_IPK) $(MINIDLNA_THUMBNAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
endif
