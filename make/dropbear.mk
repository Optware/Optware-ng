DROPBEAR_DIR:=$(BUILD_DIR)/dropbear

DROPBEAR=dropbear-0.43
DROPBEAR_SITE=http://matt.ucc.asn.au/dropbear/releases

$(DL_DIR)/$(DROPBEAR).tar.bz2:
	cd $(DL_DIR) && $(WGET) $(DROPBEAR_SITE)/$(DROPBEAR).tar.bz2

dropbear-source: $(DL_DIR)/$(DROPBEAR).tar.bz2 $(SOURCE_DIR)/dropbear.patch

$(DROPBEAR_DIR)/config.h: $(DL_DIR)/$(DROPBEAR).tar.bz2 $(SOURCE_DIR)/dropbear.patch
	@rm -rf $(BUILD_DIR)/$(DROPBEAR) $(DROPBEAR_DIR)
	tar xjf $(DL_DIR)/$(DROPBEAR).tar.bz2 -C $(BUILD_DIR)
	patch -d $(BUILD_DIR)/$(DROPBEAR) -p1 < $(SOURCE_DIR)/dropbear.patch
	cd $(BUILD_DIR)/$(DROPBEAR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--disable-zlib --disable-shadow \
		--disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp \
		--disable-wtmpx --disable-libutil #--disable-openpty --enable-devptmx
	mv $(BUILD_DIR)/$(DROPBEAR) $(DROPBEAR_DIR)

$(DROPBEAR_DIR)/dropbearmulti: $(DROPBEAR_DIR)/config.h
	make -C $(DROPBEAR_DIR) dropbearmulti scp

dropbear-diff: #$(DROPBEAR_DIR)/config.h
	@rm -rf $(BUILD_DIR)/$(DROPBEAR)
	tar xjf $(DL_DIR)/$(DROPBEAR).tar.bz2 -C $(BUILD_DIR)
	-make -C $(DROPBEAR_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(DROPBEAR) dropbear | grep -v ^Only > $(SOURCE_DIR)/dropbear.patch

$(TARGET_DIR)/dropbear/sbin/dropbear: $(DROPBEAR_DIR)/dropbearmulti
	install -d $(TARGET_DIR)/dropbear/sbin
	$(STRIP) $(DROPBEAR_DIR)/dropbearmulti -o $(TARGET_DIR)/dropbear/sbin/dropbear
	cd $(TARGET_DIR)/dropbear/sbin && ln -sf dropbear dropbearkey
	cd $(TARGET_DIR)/dropbear/sbin && ln -sf dropbear dropbearconvert
	$(STRIP) $(DROPBEAR_DIR)/scp -o $(TARGET_DIR)/dropbear/sbin/scp
	install -m 755 $(SOURCE_DIR)/dropbear.install $(TARGET_DIR)/dropbear/install
	install -m 755 $(SOURCE_DIR)/dropbear.rc $(TARGET_DIR)/dropbear/rc.dropbear

$(PACKAGE_DIR)/$(DROPBEAR).upkg: $(TARGET_DIR)/dropbear/sbin/dropbear
	tar cvf $(PACKAGE_DIR)/$(DROPBEAR).upkg --group root -C $(TARGET_DIR) dropbear

dropbear: $(DROPBEAR_DIR)/dropbearmulti

dropbear-upkg: $(PACKAGE_DIR)/$(DROPBEAR).upkg

dropbear-clean:
	-make -C $(DROPBEAR_DIR) clean
