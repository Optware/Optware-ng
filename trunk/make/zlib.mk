#############################################################
#
# zlib
#
#############################################################

ZLIB_DIR=$(BUILD_DIR)/zlib
ZLIB_SOURCE_DIR=$(SOURCE_DIR)/zlib

ZLIB_VERSION:=1.2.1
ZLIB_SITE=http://aleron.dl.sourceforge.net/sourceforge/libpng
ZLIB_SOURCE=zlib-$(ZLIB_VERSION).tar.bz2
ZLIB_CFLAGS= $(TARGET_CFLAGS) -fPIC
ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
ZLIB_CFLAGS+= -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif

ZLIB_IPK_DIR=$(BUILD_DIR)/zlib-$(ZLIB_VERSION)-ipk
ZLIB_IPK=$(BUILD_DIR)/zlib_$(ZLIB_VERSION)-1_armeb.ipk

$(DL_DIR)/$(ZLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZLIB_SITE)/$(ZLIB_SOURCE)

$(ZLIB_DIR)/.source: $(DL_DIR)/$(ZLIB_SOURCE)
	bzcat $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/zlib-$(ZLIB_VERSION) $(ZLIB_DIR)
	touch $(ZLIB_DIR)/.source

$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.source
	(cd $(ZLIB_DIR); \
		./configure \
		--shared \
		--prefix=/opt \
		--exec-prefix=$(STAGING_DIR)/usr/bin \
		--libdir=$(STAGING_DIR)/lib \
		--includedir=$(STAGING_DIR)/include \
	);
	touch $(ZLIB_DIR)/.configured;

$(ZLIB_DIR)/libz.so.$(ZLIB_VERSION): $(ZLIB_DIR)/.configured
	$(MAKE) RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR) rc" SHAREDLIB="libz.so" \
		SHAREDLIBV="libz.so.$(ZLIB_VERSION)" SHAREDLIBM="libz.so.1" \
		LDSHARED="$(TARGET_CROSS)ld -shared -soname,libz.so.1" \
		CFLAGS="$(ZLIB_CFLAGS)" CC=$(TARGET_CC) -C $(ZLIB_DIR) all libz.so.$(ZLIB_VERSION) libz.a
	touch -c $(ZLIB_DIR)/libz.so.$(ZLIB_VERSION)

$(STAGING_DIR)/lib/libz.so.$(ZLIB_VERSION): $(ZLIB_DIR)/libz.so.$(ZLIB_VERSION)
	cp -dpf $(ZLIB_DIR)/libz.a $(STAGING_DIR)/lib
	cp -dpf $(ZLIB_DIR)/zlib.h $(STAGING_DIR)/include
	cp -dpf $(ZLIB_DIR)/zconf.h $(STAGING_DIR)/include
	cp -dpf $(ZLIB_DIR)/libz.so* $(STAGING_DIR)/lib
	(cd $(STAGING_DIR)/lib; ln -fs libz.so.$(ZLIB_VERSION) libz.so.1)
	chmod a-x $(STAGING_DIR)/lib/libz.so.$(ZLIB_VERSION)
	touch -c $(STAGING_DIR)/lib/libz.so.$(ZLIB_VERSION)

zlib-headers: $(STAGING_DIR)/lib/libz.so.$(ZLIB_VERSION)

zlib: $(STAGING_DIR)/lib/libz.so.$(ZLIB_VERSION)

$(ZLIB_IPK): $(STAGING_DIR)/lib/libz.so.$(ZLIB_VERSION)
	mkdir -p $(ZLIB_IPK_DIR)/CONTROL
	cp $(ZLIB_SOURCE_DIR)/control $(ZLIB_IPK_DIR)/CONTROL/control
	mkdir -p $(ZLIB_IPK_DIR)/opt/include
	cp -dpf $(STAGING_DIR)/include/zlib.h $(ZLIB_IPK_DIR)/opt/include
	cp -dpf $(STAGING_DIR)/include/zconf.h $(ZLIB_IPK_DIR)/opt/include
	mkdir -p $(ZLIB_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/lib/libz.a $(ZLIB_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/lib/libz.so* $(ZLIB_IPK_DIR)/opt/lib
	-$(STRIP) --strip-unneeded $(ZLIB_IPK_DIR)/opt/lib/libz.so*
	touch -c $(ZLIB_IPK_DIR)/opt/lib/libz.so.$(ZLIB_VERSION)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZLIB_IPK_DIR)

zlib-ipk: $(ZLIB_IPK)

zlib-source: $(DL_DIR)/$(ZLIB_SOURCE)

zlib-clean:
	rm -f $(STAGING_DIR)/lib/libz.*
	rm -f $(STAGING_DIR)/include/zlib.h
	rm -f $(STAGING_DIR)/include/zconf.h
	-$(MAKE) -C $(ZLIB_DIR) clean

zlib-dirclean:
	rm -rf $(ZLIB_DIR) $(ZLIB_IPK_DIR) $(ZLIB_IPK)
