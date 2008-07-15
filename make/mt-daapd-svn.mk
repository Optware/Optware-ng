###########################################################
#
# mt-daapd nightly
#
###########################################################

MT-DAAPD-SVN_SITE=http://nightlies.mt-daapd.org
MT-DAAPD-SVN_REV=1696
MT-DAAPD-SVN_SOURCE=mt-daapd-svn-$(MT-DAAPD-SVN_REV).tar.gz
MT-DAAPD-SVN_DIR=mt-daapd-svn-$(MT-DAAPD-SVN_REV)
MT-DAAPD-SVN_UNZIP=zcat
MT-DAAPD-SVN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MT-DAAPD-SVN_DESCRIPTION=A multi-threaded DAAP server for Linux and other POSIX type systems. Allows a Linux box to share audio files with iTunes users on Windows or Mac.
MT-DAAPD-SVN_SECTION=net
MT-DAAPD-SVN_PRIORITY=optional
MT-DAAPD-SVN_DEPENDS=ffmpeg, flac, libid3tag, libogg, libvorbis, sqlite, zlib
MT-DAAPD-SVN_SUGGESTS=ivorbis-tools
MT-DAAPD-SVN_CONFLICTS=mt-daapd

MT-DAAPD-SVN_IPK_VERSION=1

MT-DAAPD-SVN_CPPFLAGS=
MT-DAAPD-SVN_LDFLAGS=

MT-DAAPD-SVN_BUILD_DIR=$(BUILD_DIR)/mt-daapd-svn
MT-DAAPD-SVN_SOURCE_DIR=$(SOURCE_DIR)/mt-daapd-svn
MT-DAAPD-SVN_IPK_DIR=$(BUILD_DIR)/mt-daapd-svn-$(MT-DAAPD-SVN_REV)-ipk
MT-DAAPD-SVN_IPK=$(BUILD_DIR)/mt-daapd-svn_$(MT-DAAPD-SVN_REV)-$(MT-DAAPD-SVN_IPK_VERSION)_$(TARGET_ARCH).ipk

MT-DAAPD-SVN_CONFFILES=\
/opt/etc/mt-daapd/mt-daapd.conf \
/opt/etc/init.d/S60mt-daapd \

#MT-DAAPD-SVN_PATCHES=$(MT-DAAPD-SVN_SOURCE_DIR)/itunes5.patch

.PHONY: mt-daapd-svn-source mt-daapd-svn-unpack mt-daapd-svn mt-daapd-svn-stage mt-daapd-svn-ipk mt-daapd-svn-clean mt-daapd-svn-dirclean mt-daapd-svn-check

$(DL_DIR)/$(MT-DAAPD-SVN_SOURCE):
	$(WGET) -P $(@D) $(MT-DAAPD-SVN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

mt-daapd-svn-source: $(DL_DIR)/$(MT-DAAPD-SVN_SOURCE)

$(MT-DAAPD-SVN_BUILD_DIR)/.configured: $(DL_DIR)/$(MT-DAAPD-SVN_SOURCE) # make/mt-daapd-svn.mk
	$(MAKE) sqlite-stage libid3tag-stage zlib-stage
	$(MAKE) ffmpeg-stage flac-stage libogg-stage libvorbis-stage
	rm -rf $(BUILD_DIR)/$(MT-DAAPD-SVN_DIR) $(@D)
	$(MT-DAAPD-SVN_UNZIP) $(DL_DIR)/$(MT-DAAPD-SVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MT-DAAPD-SVN_PATCHES)"; then \
		cat $(MT-DAAPD-SVN_PATCHES) | patch -d $(BUILD_DIR)/$(MT-DAAPD-SVN_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(MT-DAAPD-SVN_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MT-DAAPD-SVN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MT-DAAPD-SVN_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-nslu2 \
		--enable-sqlite3 \
		--enable-flac \
		--enable-oggvorbis \
		--enable-ffmpeg \
		--with-ffmpeg-includes=$(STAGING_INCLUDE_DIR)/ffmpeg \
		--enable-browse \
		--enable-query \
		--enable-mdns \
		--enable-shared \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mt-daapd-svn-unpack: $(MT-DAAPD-SVN_BUILD_DIR)/.configured

$(MT-DAAPD-SVN_BUILD_DIR)/.built: $(MT-DAAPD-SVN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

mt-daapd-svn: $(MT-DAAPD-SVN_BUILD_DIR)/.built

#
# This rule creates a control file for iipkg.  It is no longer
# necessary to create a seperate control file under sources/mt-daapd-svn
#
$(MT-DAAPD-SVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mt-daapd-svn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MT-DAAPD-SVN_PRIORITY)" >>$@
	@echo "Section: $(MT-DAAPD-SVN_SECTION)" >>$@
	@echo "Version: $(MT-DAAPD-SVN_REV)-$(MT-DAAPD-SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MT-DAAPD-SVN_MAINTAINER)" >>$@
	@echo "Source: $(MT-DAAPD-SVN_SITE)/$(MT-DAAPD-SVN_SOURCE)" >>$@
	@echo "Description: $(MT-DAAPD-SVN_DESCRIPTION)" >>$@
	@echo "Depends: $(MT-DAAPD-SVN_DEPENDS)" >>$@
	@echo "Suggests: $(MT-DAAPD-SVN_SUGGESTS)" >>$@
	@echo "Conflicts: $(MT-DAAPD-SVN_CONFLICTS)" >>$@

$(MT-DAAPD-SVN_IPK): $(MT-DAAPD-SVN_BUILD_DIR)/.built
	rm -rf $(MT-DAAPD-SVN_IPK_DIR) $(BUILD_DIR)/mt-daapd-svn_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MT-DAAPD-SVN_BUILD_DIR) DESTDIR=$(MT-DAAPD-SVN_IPK_DIR) install-strip
	$(MAKE) $(MT-DAAPD-SVN_IPK_DIR)/CONTROL/control
	install -d $(MT-DAAPD-SVN_IPK_DIR)/opt/var/log
	install -d $(MT-DAAPD-SVN_IPK_DIR)/opt/etc/init.d
	install -m 644 $(MT-DAAPD-SVN_BUILD_DIR)/contrib/mt-daapd.conf $(MT-DAAPD-SVN_IPK_DIR)/opt/etc/mt-daapd/mt-daapd.conf
	sed -i -e '/^db_type/s/=.*/= sqlite3/' $(MT-DAAPD-SVN_IPK_DIR)/opt/etc/mt-daapd/mt-daapd.conf
	install -d $(MT-DAAPD-SVN_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MT-DAAPD-SVN_SOURCE_DIR)/rc.mt-daapd $(MT-DAAPD-SVN_IPK_DIR)/opt/etc/init.d/S60mt-daapd
	install -m 644 $(MT-DAAPD-SVN_SOURCE_DIR)/postinst $(MT-DAAPD-SVN_IPK_DIR)/CONTROL/postinst
	install -m 644 $(MT-DAAPD-SVN_SOURCE_DIR)/prerm $(MT-DAAPD-SVN_IPK_DIR)/CONTROL/prerm
	echo $(MT-DAAPD-SVN_CONFFILES) | sed -e 's/ /\n/g' > $(MT-DAAPD-SVN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MT-DAAPD-SVN_IPK_DIR)

mt-daapd-svn-ipk: $(MT-DAAPD-SVN_IPK)

mt-daapd-svn-clean:
	-$(MAKE) -C $(MT-DAAPD-SVN_BUILD_DIR) clean

mt-daapd-svn-dirclean:
	rm -rf $(BUILD_DIR)/$(MT-DAAPD-SVN_DIR) $(MT-DAAPD-SVN_BUILD_DIR) $(MT-DAAPD-SVN_IPK_DIR) $(MT-DAAPD-SVN_IPK)

mt-daapd-svn-check: $(MT-DAAPD-SVN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MT-DAAPD-SVN_IPK)
