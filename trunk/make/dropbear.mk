#############################################################
#
# dropbear
#
#############################################################

DROPBEAR_DIR:=$(BUILD_DIR)/dropbear
DROPBEAR_SOURCE_DIR=$(SOURCE_DIR)/dropbear
DROPBEAR_VERSION:=0.43
DROPBEAR:=dropbear-$(DROPBEAR_VERSION)
DROPBEAR_SITE:=http://matt.ucc.asn.au/dropbear/releases
DROPBEAR_SOURCE:=$(DROPBEAR).tar.bz2
DROPBEAR_UNZIP:=bzcat

DROPBEAR_PATCH:=$(DROPBEAR_SOURCE_DIR)/dropbear.patch

DROPBEAR_IPK:=$(BUILD_DIR)/dropbear_$(DROPBEAR_VERSION)-2_armeb.ipk
DROPBEAR_IPK_DIR:=$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)-ipk

$(DL_DIR)/$(DROPBEAR_SOURCE):
	$(WGET) -P $(DL_DIR) $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)

dropbear-source: $(DL_DIR)/$(DROPBEAR_SOURCE) $(DROPBEAR_PATCH)

$(DROPBEAR_DIR)/.configured: $(DL_DIR)/$(DROPBEAR_SOURCE) $(DROPBEAR_PATCH)
	@rm -rf $(BUILD_DIR)/$(DROPBEAR) $(DROPBEAR_DIR)
	$(DROPBEAR_UNZIP) $(DL_DIR)/$(DROPBEAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(DROPBEAR_PATCH) | patch -d $(BUILD_DIR)/$(DROPBEAR) -p1
	mv $(BUILD_DIR)/$(DROPBEAR) $(DROPBEAR_DIR)
	cd $(DROPBEAR_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--disable-zlib --disable-shadow \
		--disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp \
		--disable-wtmpx --disable-libutil #--disable-openpty --enable-devptmx
	touch $(DROPBEAR_DIR)/.configured

dropbear-unpack: $(DROPBEAR_DIR)/.configured

$(DROPBEAR_DIR)/dropbearmulti: $(DROPBEAR_DIR)/.configured
	make -C $(DROPBEAR_DIR) dropbearmulti scp

dropbear: $(DROPBEAR_DIR)/dropbearmulti

dropbear-diff: #$(DROPBEAR_DIR)/.configured
	@rm -rf $(BUILD_DIR)/$(DROPBEAR)
	$(DROPBEAR_UNZIP) $(DL_DIR)/$(DROPBEAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	-make -C $(DROPBEAR_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(DROPBEAR) dropbear | grep -v ^Only > $(DROPBEAR_PATCH)

$(DROPBEAR_IPK): $(DROPBEAR_DIR)/dropbearmulti
	install -d $(DROPBEAR_IPK_DIR)/CONTROL
	install -d $(DROPBEAR_IPK_DIR)/opt/sbin $(DROPBEAR_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(DROPBEAR_DIR)/dropbearmulti -o $(DROPBEAR_IPK_DIR)/opt/sbin/dropbear
	cd $(DROPBEAR_IPK_DIR)/opt/sbin && ln -sf dropbear dropbearkey
	cd $(DROPBEAR_IPK_DIR)/opt/sbin && ln -sf dropbear dropbearconvert
	$(STRIP) $(DROPBEAR_DIR)/scp -o $(DROPBEAR_IPK_DIR)/opt/sbin/scp
	install -m 755 $(DROPBEAR_SOURCE_DIR)/rc.dropbear $(DROPBEAR_IPK_DIR)/opt/etc/init.d/S51dropbear
	install -m 644 $(DROPBEAR_SOURCE_DIR)/control  $(DROPBEAR_IPK_DIR)/CONTROL/control
	install -m 644 $(DROPBEAR_SOURCE_DIR)/postinst $(DROPBEAR_IPK_DIR)/CONTROL/postinst
	install -m 644 $(DROPBEAR_SOURCE_DIR)/prerm    $(DROPBEAR_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DROPBEAR_IPK_DIR)

dropbear-ipk: $(DROPBEAR_IPK)

dropbear-clean:
	-make -C $(DROPBEAR_DIR) clean

dropbear-dirclean:
	rm -rf $(DROPBEAR_DIR) $(DROPBEAR_IPK_DIR) $(DROPBEAR_IPK)
