#############################################################
#
# inetutils
#
#############################################################

INETUTILS_DIR:=$(BUILD_DIR)/inetutils

INETUTILS_VERSION:=1.4.2
INETUTILS:=inetutils-$(INETUTILS_VERSION)
INETUTILS_SITE:=ftp://ftp.gnu.org/pub/gnu/inetutils
INETUTILS_SOURCE:=$(INETUTILS).tar.gz
INETUTILS_UNZIP:=zcat

INETUTILS_IPK_VERSION=3
INETUTILS_SOURCE_DIR=$(SOURCE_DIR)/inetutils

INETUTILS_IPK:=$(BUILD_DIR)/inetutils_$(INETUTILS_VERSION)-$(INETUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk
INETUTILS_IPK_DIR:=$(BUILD_DIR)/inetutils-$(INETUTILS_VERSION)-ipk

$(DL_DIR)/$(INETUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(INETUTILS_SITE)/$(INETUTILS_SOURCE)

inetutils-source: $(DL_DIR)/$(INETUTILS_SOURCE)

$(INETUTILS_DIR)/.configured: $(DL_DIR)/$(INETUTILS_SOURCE)
	@rm -rf $(BUILD_DIR)/$(INETUTILS) $(INETUTILS_DIR)
	$(INETUTILS_UNZIP) $(DL_DIR)/$(INETUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(INETUTILS) $(INETUTILS_DIR)
	(cd $(INETUTILS_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--infodir=/opt/doc/inetutils \
	)
	touch $(INETUTILS_DIR)/.configured

inetutils-unpack: $(INETUTILS_DIR)/.configured

$(INETUTILS_DIR)/inetd/inetd: $(INETUTILS_DIR)/.configured
	make -C $(INETUTILS_DIR)

inetutils: $(INETUTILS_DIR)/inetd/inetd

$(INETUTILS_IPK): $(INETUTILS_DIR)/inetd/inetd
	# Setuid stuff doesn't work as non-root, but we fix in in the postinst script.
	make -C $(INETUTILS_DIR) DESTDIR=$(INETUTILS_IPK_DIR) install
	install -d $(INETUTILS_IPK_DIR)/CONTROL $(INETUTILS_IPK_DIR)/opt/etc/init.d
	install -m 644 $(INETUTILS_SOURCE_DIR)/control  $(INETUTILS_IPK_DIR)/CONTROL/control
	install -m 644 $(INETUTILS_SOURCE_DIR)/postinst  $(INETUTILS_IPK_DIR)/CONTROL/postinst 
	install -m 755 $(INETUTILS_SOURCE_DIR)/rc.inetutils $(INETUTILS_IPK_DIR)/opt/etc/init.d/S52inetd
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INETUTILS_IPK_DIR)

inetutils-ipk: $(INETUTILS_IPK)

inetutils-clean:
	-make -C $(INETUTILS_DIR) clean

inetutils-dirclean:
	rm -rf $(INETUTILS_DIR) $(INETUTILS_IPK_DIR) $(INETUTILS_IPK)
