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

$(PACKAGE_DIR)/dropbear/opt/dropbear/sbin/dropbear: $(DROPBEAR_DIR)/dropbearmulti
	install -d $(PACKAGE_DIR)/dropbear/opt/dropbear/sbin
	$(STRIP) $(DROPBEAR_DIR)/dropbearmulti -o $(PACKAGE_DIR)/dropbear/opt/dropbear/sbin/dropbear
	cd $(PACKAGE_DIR)/dropbear/opt/dropbear/sbin && ln -sf dropbear dropbearkey
	cd $(PACKAGE_DIR)/dropbear/opt/dropbear/sbin && ln -sf dropbear dropbearconvert
	$(STRIP) $(DROPBEAR_DIR)/scp -o $(PACKAGE_DIR)/dropbear/opt/dropbear/sbin/scp
	install -m 755 $(SOURCE_DIR)/dropbear.rc $(PACKAGE_DIR)/dropbear/opt/dropbear/rc.dropbear

$(PACKAGE_DIR)/dropbear_0.43_armeb.ipk: $(PACKAGE_DIR)/dropbear/opt/dropbear/sbin/dropbear
	install -d $(PACKAGE_DIR)/dropbear/CONTROL
	install -m 644 $(SOURCE_DIR)/dropbear.control $(PACKAGE_DIR)/dropbear/CONTROL/control
	install -m 644 $(SOURCE_DIR)/dropbear.postinst $(PACKAGE_DIR)/dropbear/CONTROL/postinst
	install -m 644 $(SOURCE_DIR)/dropbear.postrm $(PACKAGE_DIR)/dropbear/CONTROL/postrm
	./ipkg-build -c -o root -g root $(PACKAGE_DIR)/dropbear $(PACKAGE_DIR)

dropbear: $(DROPBEAR_DIR)/dropbearmulti

dropbear-ipk: $(PACKAGE_DIR)/dropbear_0.43_armeb.ipk

dropbear-upkg:

dropbear-clean:
	-make -C $(DROPBEAR_DIR) clean
