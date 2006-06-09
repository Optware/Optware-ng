#############################################################
#
# zlib
#
#############################################################

ZLIB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libpng
ZLIB_VERSION:=1.2.3
ZLIB_LIB_VERSION:=1.2.3
ZLIB_SOURCE=zlib-$(ZLIB_VERSION).tar.bz2
ZLIB_DIR=zlib-$(ZLIB_VERSION)
ZLIB_UNZIP=bzcat
ZLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZLIB_DESCRIPTION=zlib is a library implementing the 'deflate' compression system.
ZLIB_SECTION=libs
ZLIB_PRIORITY=optional
ZLIB_DEPENDS=
ZLIB_CONFLICTS=

ZLIB_IPK_VERSION=1

ZLIB_CFLAGS= $(TARGET_CFLAGS) -fPIC
ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
ZLIB_CFLAGS+= -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif

ZLIB_BUILD_DIR=$(BUILD_DIR)/zlib
ZLIB_SOURCE_DIR=$(SOURCE_DIR)/zlib
ZLIB_IPK_DIR=$(BUILD_DIR)/zlib-$(ZLIB_VERSION)-ipk
ZLIB_IPK=$(BUILD_DIR)/zlib_$(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(ZLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZLIB_SITE)/$(ZLIB_SOURCE)

zlib-source: $(DL_DIR)/$(ZLIB_SOURCE)

$(ZLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(ZLIB_SOURCE)
	rm -rf $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR)
	$(ZLIB_UNZIP) $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR)
	(cd $(ZLIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--shared \
	)
	touch $(ZLIB_BUILD_DIR)/.configured

zlib-unpack: $(ZLIB_BUILD_DIR)/.configured

$(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_LIB_VERSION): $(ZLIB_BUILD_DIR)/.configured
	$(MAKE) RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR) rc" SHAREDLIB="libz.so" \
		SHAREDLIBV="libz.so.$(ZLIB_LIB_VERSION)" SHAREDLIBM="libz.so.1" \
		LDSHARED="$(TARGET_LD) -shared -soname,libz.so.1" \
		CFLAGS="$(ZLIB_CFLAGS)" CC=$(TARGET_CC) -C $(ZLIB_BUILD_DIR) all libz.so.$(ZLIB_LIB_VERSION) libz.a

zlib: $(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_LIB_VERSION)

$(STAGING_LIB_DIR)/libz.so.$(ZLIB_LIB_VERSION): $(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_LIB_VERSION)
	install -d $(STAGING_INCLUDE_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/zlib.h $(STAGING_INCLUDE_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/zconf.h $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_LIB_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/libz.a $(STAGING_LIB_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_LIB_VERSION) $(STAGING_LIB_DIR)
	cd $(STAGING_DIR)/opt/lib && ln -fs libz.so.$(ZLIB_LIB_VERSION) libz.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libz.so.$(ZLIB_LIB_VERSION) libz.so

zlib-stage: $(STAGING_DIR)/opt/lib/libz.so.$(ZLIB_LIB_VERSION)


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(ZLIB_IPK_DIR)/CONTROL/control:
	@install -d $(ZLIB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: zlib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZLIB_PRIORITY)" >>$@
	@echo "Section: $(ZLIB_SECTION)" >>$@
	@echo "Version: $(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZLIB_MAINTAINER)" >>$@
	@echo "Source: $(ZLIB_SITE)/$(ZLIB_SOURCE)" >>$@
	@echo "Description: $(ZLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(ZLIB_DEPENDS)" >>$@
	@echo "Conflicts: $(ZLIB_CONFLICTS)" >>$@

$(ZLIB_IPK): $(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_LIB_VERSION)
	rm -rf $(ZLIB_IPK_DIR) $(BUILD_DIR)/zlib_*_$(TARGET_ARCH).ipk
	install -d $(ZLIB_IPK_DIR)/opt/include
	install -m 644 $(ZLIB_BUILD_DIR)/zlib.h $(ZLIB_IPK_DIR)/opt/include
	install -m 644 $(ZLIB_BUILD_DIR)/zconf.h $(ZLIB_IPK_DIR)/opt/include
	install -d $(ZLIB_IPK_DIR)/opt/lib
	install -m 644 $(ZLIB_BUILD_DIR)/libz.so.$(ZLIB_LIB_VERSION) $(ZLIB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(ZLIB_IPK_DIR)/opt/lib/libz.so.$(ZLIB_LIB_VERSION)
	cd $(ZLIB_IPK_DIR)/opt/lib && ln -fs libz.so.$(ZLIB_LIB_VERSION) libz.so.1
	cd $(ZLIB_IPK_DIR)/opt/lib && ln -fs libz.so.$(ZLIB_LIB_VERSION) libz.so
	$(MAKE) $(ZLIB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZLIB_IPK_DIR)

zlib-ipk: $(ZLIB_IPK)

zlib-clean:
	-$(MAKE) -C $(ZLIB_BUILD_DIR) clean

zlib-dirclean:
	rm -rf $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR) $(ZLIB_IPK_DIR) $(ZLIB_IPK)
