#############################################################
#
# inetutils
#
#############################################################

INETUTILS_VERSION:=1.4.2
INETUTILS:=inetutils-$(INETUTILS_VERSION)
INETUTILS_SITE:=ftp://ftp.gnu.org/pub/gnu/inetutils
INETUTILS_SOURCE:=$(INETUTILS).tar.gz
INETUTILS_UNZIP:=gzcat
INETUTILS_DIR=$(BUILD_DIR)/$(INETUTILS)
INETUTILS_IPK:=$(BUILD_DIR)/inetutils_$(INETUTILS_VERSION)_armeb.ipk
INETUTILS_IPK_DIR:=$(BUILD_DIR)/inetutils-$(INETUTILS_VERSION)-ipk

$(DL_DIR)/$(INETUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(INETUTILS_SITE)/$(INETUTILS_SOURCE)

inetutils-source: $(DL_DIR)/$(INETUTILS_SOURCE)

$(INETUTILS_DIR)/.configured: $(DL_DIR)/$(INETUTILS_SOURCE)
	@rm -rf $(BUILD_DIR)/$(INETUTILS)
	$(INETUTILS_UNZIP) $(DL_DIR)/$(INETUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	mv $(BUILD_DIR)/$(INETUTILS) $(INETUTILS_DIR)
	cd $(INETUTILS_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--prefix=/opt \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) && \
	touch $(INTERUTILS_DIR)/.configured

inetutils-unpack: $(INETUTILS_DIR)/.configured

inetutils: $(INETUTILS_DIR)/.configured
	cd $(INETUTILS_DIR) && \
	make

inetutils-install: inetutils
	cd $(INETUTILS_DIR) && \
	$(SUDO) make  DESTDIR=$(INETUTILS_DIR)-ipk install

$(INETUTILS_IPK): inetutils-install
	mkdir -p $(INETUTILS_IPK_DIR)/opt/etc/init.d
	install -d $(INETUTILS_IPK_DIR)/CONTROL
	install -m 644 $(SOURCE_DIR)/inetutils-1.2.4.control  $(INETUTILS_IPK_DIR)/CONTROL/control
	install -m 644 $(SOURCE_DIR)/inetutils-1.2.4.postinst  $(INETUTILS_IPK_DIR)/CONTROL/postinst 
	install -m 755 $(SOURCE_DIR)/inetutils.rc $(INETUTILS_IPK_DIR)/opt/etc/init.d/S52inetd
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INETUTILS_IPK_DIR) $(PACKAGE_DIR)
#	mv $(BUILD_DIR)/$(COREUTILS)_armeb.ipk $(PACKAGE_DIR)
inetutils-ipk: $(INETUTILS_IPK)

coreutils-clean:
	-make -C $(INETUTILS_DIR) clean

coreutils-dirclean:
	rm -rf $(INETUTILS_DIR) $(COREUTILS_IPK_DIR)
