###########################################################
#
# mtdaapd
#
###########################################################

MTDAAPD_DIR=$(BUILD_DIR)/mtdaapd

MTDAAPD_VERSION=0.2.0
MTDAAPD=mt-daapd-$(MTDAAPD_VERSION)
MTDAAPD_SITE=http://belnet.dl.sourceforge.net/sourceforge/mt-daapd
MTDAAPD_SOURCE=$(MTDAAPD).tar.gz
MTDAAPD_UNZIP=zcat
MTDAAPD_CFLAGS=$(TARGET_CFLAGS) -I$(STAGING_DIR)/include -fPIC
MTDAAPD_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_DIR)/lib

MTDAAPD_PATCH:=$(SOURCE_DIR)/mt-daapd.patch

MTDAAPD_IPK=$(BUILD_DIR)/mt-daapd_$(MTDAAPD_VERSION)-1_armeb.ipk
MTDAAPD_IPK_DIR=$(BUILD_DIR)/mt-daapd-$(MTDAAPD_VERSION)-ipk

$(DL_DIR)/$(MTDAAPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MTDAAPD_SITE)/$(MTDAAPD_SOURCE)

mtdaapd-source: $(DL_DIR)/$(MTDAAPD_SOURCE) $(MTDAAPD_PATCH)

$(MTDAAPD_DIR)/.source: $(DL_DIR)/$(MTDAAPD_SOURCE)
	$(MTDAAPD_UNZIP) $(DL_DIR)/$(MTDAAPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MTDAAPD_PATCH) | patch -d $(BUILD_DIR)/$(MTDAAPD) -p1
	mv $(BUILD_DIR)/$(MTDAAPD) $(MTDAAPD_DIR)
	touch $(MTDAAPD_DIR)/.source

$(MTDAAPD_DIR)/.configured: $(MTDAAPD_DIR)/.source
	(cd $(MTDAAPD_DIR); \
        export CC=$(TARGET_CC) ;\
        export CFLAGS="$(MTDAAPD_CFLAGS)" ;\
        export LDFLAGS="$(MTDAAPD_LDFLAGS)" ;\
		./configure \
        --host=arm-linux \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(STAGING_DIR) \
        LIBS="-lgdbm -lid3tag -lz -lpthread" \
        ac_cv_func_setpgrp_void=yes \
	);
	touch $(MTDAAPD_DIR)/.configured

$(STAGING_DIR)/sbin/mt-daapd: $(MTDAAPD_DIR)/.configured
	$(MAKE) LDFLAGS="$(MTDAAPD_LDFLAGS)" CC="$(TARGET_CC)" -C $(MTDAAPD_DIR) install

#mtdaapd-headers: $(STAGING_DIR)/sbin/mt-daapd

mtdaapd: zlib gdbm libid3tag $(STAGING_DIR)/sbin/mt-daapd

mtdaapd-diff: #$(MTDAAPD_DIR)/.configured
	@rm -rf $(BUILD_DIR)/$(MTDAAPD)
	$(MTDAAPD_UNZIP) $(DL_DIR)/$(MTDAAPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	-make -C $(MTDAAPD_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(MTDAAPD) mtdaapd | grep -v ^Only > $(MTDAAPD_PATCH)

$(MTDAAPD_IPK): $(STAGING_DIR)/sbin/mt-daapd
	install -d $(MTDAAPD_IPK_DIR)/CONTROL
	install -d $(MTDAAPD_IPK_DIR)/opt/sbin $(MTDAAPD_IPK_DIR)/opt/etc/init.d
	install -d $(MTDAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root
	install -d $(MTDAAPD_IPK_DIR)/opt/var/mt-daapd
	$(STRIP) --strip-unneeded $(STAGING_DIR)/sbin/mt-daapd -o $(MTDAAPD_IPK_DIR)/opt/sbin/mt-daapd
	install -m 644 $(STAGING_DIR)/share/mt-daapd/admin-root/* $(MTDAAPD_IPK_DIR)/opt/share/mt-daapd/admin-root
	install -m 755 $(SOURCE_DIR)/mt-daapd.rc        $(MTDAAPD_IPK_DIR)/opt/etc/init.d/S60mt-daapd
	install -m 644 $(SOURCE_DIR)/mt-daapd.conf      $(MTDAAPD_IPK_DIR)/opt/etc
	install -m 644 $(SOURCE_DIR)/mt-daapd.playlist  $(MTDAAPD_IPK_DIR)/opt/etc
	install -m 644 $(SOURCE_DIR)/mt-daapd.control    $(MTDAAPD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MTDAAPD_IPK_DIR)

mtdaapd-ipk: $(MTDAAPD_IPK)

mtdaapd-source: $(DL_DIR)/$(MTDAAPD_SOURCE)

mtdaapd-clean:
	-$(MAKE) -C $(MTDAAPD_DIR) uninstall
	-$(MAKE) -C $(MTDAAPD_DIR) clean

mtdaapd-dirclean: mtdaapd-clean
	rm -rf $(MTDAAPD_DIR) $(MTDAAPD_IPK_DIR)

