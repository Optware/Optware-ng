#
# Make file for sudo
#

SUDO_DIR:=$(BUILD_DIR)/sudo
SUDO_SOURCE_DIR:=$(SOURCE_DIR)/sudo
SUDO_VERSION:=1.6.8p1
SUDO:=sudo-$(SUDO_VERSION)
#SUDO_SITE=http://probsd.org/sudoftp
#SUDO_SOURCE:=$(SUDO).tar.gz
SUDO_SITE=http://ipkg.nslu2-linux.org/downloads/
SUDO_SOURCE:=$(SUDO).tar.gz

SUDO_IPK_VERSION:=3

SUDO_IPK:=$(BUILD_DIR)/sudo_$(SUDO_VERSION)-$(SUDO_IPK_VERSION)_armeb.ipk
SUDO_IPK_DIR:=$(BUILD_DIR)/sudo-$(SUDO_VERSION)-ipk
SUDO_PATCH:=$(SUDO_SOURCE_DIR)/configure.patch


$(DL_DIR)/$(SUDO_SOURCE):
	cd $(DL_DIR) && $(WGET) $(SUDO_SITE)/$(SUDO_SOURCE)

sudo-source: $(DL_DIR)/$(SUDO_SOURCE) $(SUDO_PATCH)

$(SUDO_DIR)/.configured: $(DL_DIR)/$(SUDO_SOURCE) $(SUDO_PATCH)
	@rm -rf $(SUDO_DIR)
	tar xzf $(DL_DIR)/$(SUDO_SOURCE) -C $(BUILD_DIR)
	mv $(BUILD_DIR)/$(SUDO) $(SUDO_DIR)
	patch -d $(SUDO_DIR) -p1 < $(SUDO_PATCH)
	cd $(SUDO_DIR) && \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--target=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/opt/sudo \
			--exec-prefix=/opt/sudo \
			--enable-authentication \
			--without-insults \
			--with-editor=/bin/vi \
			--sysconfdir=/opt/etc
	touch $(SUDO_DIR)/.configured

sudo-unpack: $(SUDO_DIR)/.configured

$(SUDO_DIR)/sudo: $(SUDO_DIR)/.configured
	make -C $(BUILD_DIR)/sudo

sudo: $(SUDO_DIR)/sudo

$(SUDO_IPK): $(SUDO_DIR)/sudo
	install -d $(SUDO_IPK_DIR)/opt/bin
	$(STRIP) $(SUDO_DIR)/sudo -o $(SUDO_IPK_DIR)/opt/bin/sudo
	$(STRIP) $(SUDO_DIR)/visudo -o $(SUDO_IPK_DIR)/opt/bin/visudo
	install -d $(SUDO_IPK_DIR)/opt/etc
	install -m 600 $(SUDO_DIR)/sudoers $(SUDO_IPK_DIR)/opt/etc/sudoers
	install -d $(SUDO_IPK_DIR)/opt/doc/sudo
	install -m 644 $(SUDO_DIR)/sample.sudoers $(SUDO_IPK_DIR)/opt/doc/sudo/sample.sudoers
	install -d $(SUDO_IPK_DIR)/CONTROL
	install -m 644 $(SUDO_SOURCE_DIR)/control $(SUDO_IPK_DIR)/CONTROL/control
	install -m 644 $(SUDO_SOURCE_DIR)/postinst $(SUDO_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR) && $(IPKG_BUILD) $(SUDO_IPK_DIR)


sudo-ipk: $(SUDO_IPK)

sudo-clean:
	-make -C $(BUILD_DIR)/sudo clean

sudo-dirclean:
	rm -rf $(SUDO_DIR) $(SUDO_IPK_DIR) $(SUDO_IPK)
