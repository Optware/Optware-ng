DROPBEAR=dropbear-0.43
DROPBEAR_SITE=http://matt.ucc.asn.au/dropbear/releases

$(DL_DIR)/$(DROPBEAR).tar.bz2:
	cd $(DL_DIR) && $(WGET) $(DROPBEAR_SITE)/$(DROPBEAR).tar.bz2

$(BUILD_DIR)/dropbear/config.h: $(DL_DIR)/$(DROPBEAR).tar.bz2 $(SOURCE_DIR)/dropbear.patch
	@rm -rf $(BUILD_DIR)/$(DROPBEAR) $(BUILD_DIR)/dropbear
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
	mv $(BUILD_DIR)/$(DROPBEAR) $(BUILD_DIR)/dropbear

dropbear: $(BUILD_DIR)/dropbear/config.h
	make -C $(BUILD_DIR)/dropbear dropbearmulti scp

dropbear-diff: #$(BUILD_DIR)/dropbear/config.h
	@rm -rf $(BUILD_DIR)/$(DROPBEAR)
	tar xjf $(DL_DIR)/$(DROPBEAR).tar.bz2 -C $(BUILD_DIR)
	-make -C $(BUILD_DIR)/dropbear distclean
	-cd $(BUILD_DIR) && diff -BurN $(DROPBEAR) dropbear | grep -v ^Only > $(SOURCE_DIR)/dropbear.patch

dropbear-upkg: dropbear
	install -d $(TARGET_DIR)/dropbear/sbin
	$(STRIP) $(BUILD_DIR)/dropbear/dropbearmulti -o $(TARGET_DIR)/dropbear/sbin/dropbear
	cd $(TARGET_DIR)/dropbear/sbin && ln -sf dropbear dropbearkey
	cd $(TARGET_DIR)/dropbear/sbin && ln -sf dropbear dropbearconvert
	$(STRIP) $(BUILD_DIR)/dropbear/scp -o $(TARGET_DIR)/dropbear/sbin/scp
	install -m 755 $(SOURCE_DIR)/dropbear.install $(TARGET_DIR)/dropbear/install
	install -m 755 $(SOURCE_DIR)/dropbear.rc $(TARGET_DIR)/dropbear/rc.dropbear
	tar cvf $(PACKAGE_DIR)/$(DROPBEAR).upkg --group root -C $(TARGET_DIR) dropbear

dropbear-clean:
	-make -C $(BUILD_DIR)/dropbear clean
