###########################################################
#
# mt-daapd
#
###########################################################

MT_DAAPD_SITE=http://unc.dl.sourceforge.net/sourceforge/mt-daapd
MT_DAAPD_VERSION=0.2.1.1
MT_DAAPD_SOURCE=mt-daapd-$(MT_DAAPD_VERSION).tar.gz
MT_DAAPD_DIR=mt-daapd-$(MT_DAAPD_VERSION)
MT_DAAPD_UNZIP=zcat

MT_DAAPD_IPK_VERSION=1

MT_DAAPD_PATCHES=

MT_DAAPD_CPPFLAGS=-DSTRSEP
MT_DAAPD_LDFLAGS=

MT_DAAPD_BUILD_DIR=$(BUILD_DIR)/mt-daapd
MT_DAAPD_SOURCE_DIR=$(SOURCE_DIR)/mt-daapd
MT_DAAPD_IPK_DIR=$(BUILD_DIR)/mt-daapd-$(MT_DAAPD_VERSION)-ipk
MT_DAAPD_IPK=$(BUILD_DIR)/mt-daapd_$(MT_DAAPD_VERSION)-$(MT_DAAPD_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(MT_DAAPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MT_DAAPD_SITE)/$(MT_DAAPD_SOURCE)

mt-daapd-source: $(DL_DIR)/$(MT_DAAPD_SOURCE)

$(MT_DAAPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MT_DAAPD_SOURCE)
	$(MAKE) zlib-stage gdbm-stage libid3tag-stage
	rm -rf $(BUILD_DIR)/$(MT_DAAPD_DIR) $(MT_DAAPD_BUILD_DIR)
	$(MT_DAAPD_UNZIP) $(DL_DIR)/$(MT_DAAPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MT_DAAPD_PATCHES) | patch -d $(BUILD_DIR)/$(MT_DAAPD_DIR) -p1
	mv $(BUILD_DIR)/$(MT_DAAPD_DIR) $(MT_DAAPD_BUILD_DIR)
	(cd $(MT_DAAPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MT_DAAPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MT_DAAPD_LDFLAGS)" \
		LIBS="-lgdbm -lid3tag -lz" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	        --with-static-libs=$(STAGING_DIR)/opt/lib \
		--with-gdbm-include=$(STAGING_DIR)/opt/include \
		--enable-nslu2 \
	)
	touch $(MT_DAAPD_BUILD_DIR)/.configured

mt-daapd-unpack: $(MT_DAAPD_BUILD_DIR)/.configured

$(MT_DAAPD_BUILD_DIR)/src/mt-daapd: $(MT_DAAPD_BUILD_DIR)/.configured
	$(MAKE) -C $(MT_DAAPD_BUILD_DIR) CFLAGS="-DSTRSEP"

#	$(MAKE) -C $(MT_DAAPD_BUILD_DIR) CFLAGS="-DSTRSEP"

mt-daapd: zlib gdbm libid3tag $(MT_DAAPD_BUILD_DIR)/src/mt-daapd

$(MT_DAAPD_IPK): $(MT_DAAPD_BUILD_DIR)/src/mt-daapd
	rm -rf $(MT_DAAPD_IPK_DIR) $(BUILD_DIR)/mt-daapd_*_$(TARGET_ARCH).ipk
	install -d $(MT_DAAPD_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(MT_DAAPD_BUILD_DIR)/src/mt-daapd -o $(MT_DAAPD_IPK_DIR)/opt/sbin/mt-daapd
	install -d $(MT_DAAPD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MT_DAAPD_SOURCE_DIR)/rc.mt-daapd $(MT_DAAPD_IPK_DIR)/opt/etc/init.d/S60mt-daapd
	install -d $(MT_DAAPD_IPK_DIR)/CONTROL
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/control $(MT_DAAPD_IPK_DIR)/CONTROL/control
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/postinst $(MT_DAAPD_IPK_DIR)/CONTROL/postinst
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/prerm $(MT_DAAPD_IPK_DIR)/CONTROL/prerm
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/conffiles $(MT_DAAPD_IPK_DIR)/CONTROL/conffiles

	install -d $(MT_DAAPD_IPK_DIR)/opt/etc/mt-daapd
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/mt-daapd.conf $(MT_DAAPD_IPK_DIR)/opt/etc/mt-daapd
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/mt-daapd.playlist $(MT_DAAPD_IPK_DIR)/opt/etc/mt-daapd

	install -d $(MT_DAAPD_IPK_DIR)/opt/doc/mt-daapd
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/mt-daapd.conf $(MT_DAAPD_IPK_DIR)/opt/doc/mt-daapd
	install -m 644 $(MT_DAAPD_SOURCE_DIR)/mt-daapd.playlist $(MT_DAAPD_IPK_DIR)/opt/doc/mt-daapd

	install -d $(MT_DAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root
	install -m 644 $(MT_DAAPD_BUILD_DIR)/admin-root/* $(MT_DAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root
	rm -f $(MT_DAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root/Makefile*
	install -d $(MT_DAAPD_IPK_DIR)/opt/var/mt-daapd

	cd $(BUILD_DIR); $(IPKG_BUILD) $(MT_DAAPD_IPK_DIR)

mt-daapd-ipk: $(MT_DAAPD_IPK)

mt-daapd-clean:
	-$(MAKE) -C $(MT_DAAPD_BUILD_DIR) clean

mt-daapd-dirclean:
	rm -rf $(BUILD_DIR)/$(MT_DAAPD_DIR) $(MT_DAAPD_BUILD_DIR) $(MT_DAAPD_IPK_DIR) $(MT_DAAPD_IPK)

