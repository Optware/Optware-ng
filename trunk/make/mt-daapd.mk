###########################################################
#
# mt-daapd
#
###########################################################

MT_DAAPD_DIR=$(BUILD_DIR)/mt-daapd

MT_DAAPD_VERSION=0.2.0
MT_DAAPD=mt-daapd-$(MT_DAAPD_VERSION)
MT_DAAPD_SITE=http://belnet.dl.sourceforge.net/sourceforge/mt-daapd
MT_DAAPD_SOURCE=$(MT_DAAPD).tar.gz
MT_DAAPD_UNZIP=zcat
MT_DAAPD_CFLAGS=$(TARGET_CFLAGS) -I$(STAGING_DIR)/include -fPIC
MT_DAAPD_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_DIR)/lib

MT_DAAPD_PATCH:=$(SOURCE_DIR)/mt-daapd.patch

MT_DAAPD_IPK=$(BUILD_DIR)/mt-daapd_$(MT_DAAPD_VERSION)-1_armeb.ipk
MT_DAAPD_IPK_DIR=$(BUILD_DIR)/mt-daapd-$(MT_DAAPD_VERSION)-ipk

$(DL_DIR)/$(MT_DAAPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MT_DAAPD_SITE)/$(MT_DAAPD_SOURCE)

mt-daapd-source: $(DL_DIR)/$(MT_DAAPD_SOURCE) $(MT_DAAPD_PATCH)

$(MT_DAAPD_DIR)/.source: $(DL_DIR)/$(MT_DAAPD_SOURCE)
	$(MT_DAAPD_UNZIP) $(DL_DIR)/$(MT_DAAPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MT_DAAPD_PATCH) | patch -d $(BUILD_DIR)/$(MT_DAAPD) -p1
	mv $(BUILD_DIR)/$(MT_DAAPD) $(MT_DAAPD_DIR)
	touch $(MT_DAAPD_DIR)/.source

$(MT_DAAPD_DIR)/.configured: $(MT_DAAPD_DIR)/.source
	(cd $(MT_DAAPD_DIR); \
        export CC=$(TARGET_CC) ;\
        export CFLAGS="$(MT_DAAPD_CFLAGS)" ;\
        export LDFLAGS="$(MT_DAAPD_LDFLAGS)" ;\
		./configure \
        --host=arm-linux \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(STAGING_DIR) \
        LIBS="-lgdbm -lid3tag -lz -lpthread" \
        ac_cv_func_setpgrp_void=yes \
	);
	touch $(MT_DAAPD_DIR)/.configured

$(STAGING_DIR)/sbin/mt-daapd: $(MT_DAAPD_DIR)/.configured
	$(MAKE) LDFLAGS="$(MT_DAAPD_LDFLAGS)" CC="$(TARGET_CC)" -C $(MT_DAAPD_DIR) install

#mt-daapd-headers: $(STAGING_DIR)/sbin/mt-daapd

mt-daapd: zlib gdbm libid3tag $(STAGING_DIR)/sbin/mt-daapd

mt-daapd-diff: #$(MT_DAAPD_DIR)/.configured
	@rm -rf $(BUILD_DIR)/$(MT_DAAPD)
	$(MT_DAAPD_UNZIP) $(DL_DIR)/$(MT_DAAPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	-make -C $(MT_DAAPD_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(MT_DAAPD) mt-daapd | grep -v ^Only > $(MT_DAAPD_PATCH)

$(MT_DAAPD_IPK): $(STAGING_DIR)/sbin/mt-daapd
	install -d $(MT_DAAPD_IPK_DIR)/CONTROL
	install -d $(MT_DAAPD_IPK_DIR)/opt/sbin $(MT_DAAPD_IPK_DIR)/opt/etc/init.d
	install -d $(MT_DAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root
	install -d $(MT_DAAPD_IPK_DIR)/opt/var/mt-daapd
	$(STRIP) --strip-unneeded $(STAGING_DIR)/sbin/mt-daapd -o $(MT_DAAPD_IPK_DIR)/opt/sbin/mt-daapd
	install -m 644 $(STAGING_DIR)/share/mt-daapd/admin-root/* $(MT_DAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root
	install -m 755 $(SOURCE_DIR)/mt-daapd.rc        $(MT_DAAPD_IPK_DIR)/opt/etc/init.d/S60mt-daapd
	install -m 644 $(SOURCE_DIR)/mt-daapd.conf      $(MT_DAAPD_IPK_DIR)/opt/etc
	install -m 644 $(SOURCE_DIR)/mt-daapd.playlist  $(MT_DAAPD_IPK_DIR)/opt/etc
	install -m 644 $(SOURCE_DIR)/mt-daapd.control    $(MT_DAAPD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MT_DAAPD_IPK_DIR)

mt-daapd-ipk: $(MT_DAAPD_IPK)

mt-daapd-source: $(DL_DIR)/$(MT_DAAPD_SOURCE)

mt-daapd-clean:
	-$(MAKE) -C $(MT_DAAPD_DIR) uninstall
	-$(MAKE) -C $(MT_DAAPD_DIR) clean

mt-daapd-dirclean: mt-daapd-clean
	rm -rf $(MT_DAAPD_DIR) $(MT_DAAPD_IPK_DIR) $(MT_DAAPD_IPK)

