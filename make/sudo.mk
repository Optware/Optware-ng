#
# Make file for sudo
#

SUDO_DIR:=$(BUILD_DIR)/sudo
SUDO_VERSION:=1.6.8
SUDO:=sudo-$(SUDO_VERSION)
SUDO_SITE=http://probsd.org/sudoftp
SUDO_SOURCE:=$(SUDO).tar.gz
SUDO_IPK:=$(BUILD_DIR)/sudo_$(SUDO_VERSION)_armeb.ipk
SUDO_IPK_DIR:=$(BUILD_DIR)/sudo-$(SUDO_VERSION)-ipk
SUDO_PATCH:=$(SOURCE_DIR)/$(SUDO).patch


$(DL_DIR)/$(SUDO_SOURCE):
	cd $(DL_DIR) && $(WGET) $(SUDO_SITE)/$(SUDO_SOURCE)

$(SOURCE_DIR)/$(SUDO)-patch: $(SOURCE_DIR)/$(SUDO).patch
	@echo "$(SUDO).patch is present."

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
	

sudo-build: directories $(SUDO_DIR)/.configured
	make -C $(BUILD_DIR)/sudo

$(SUDO_IPK): sudo-build
	install -d $(SUDO_IPK_DIR)/CONTROL
	install -d $(SUDO_IPK_DIR)/opt/sbin
	install -d $(SUDO_IPK_DIR)/opt/sudo/sbin
	install -d $(SUDO_IPK_DIR)/opt/etc
	$(STRIP) $(SUDO_DIR)/sudo -o $(SUDO_IPK_DIR)/opt/sudo/sbin/sudo
	$(STRIP) $(SUDO_DIR)/visudo -o $(SUDO_IPK_DIR)/opt/sudo/sbin/visudo
	sudo chown 0:0 $(SUDO_IPK_DIR)/opt/sudo/sbin/sudo
	sudo chown 0:0 $(SUDO_IPK_DIR)/opt/sudo/sbin/visudo
	sudo chmod 4555  $(SUDO_IPK_DIR)/opt/sudo/sbin/sudo
	sudo chmod 4555  $(SUDO_IPK_DIR)/opt/sudo/sbin/visudo
	install -m 644 $(SOURCE_DIR)/sudo.control $(SUDO_IPK_DIR)/CONTROL/control
	install -m 600 $(SUDO_DIR)/sudoers $(SUDO_IPK_DIR)/opt/etc/sudoers
	install -m 600 $(SUDO_DIR)/sample.sudoers $(SUDO_IPK_DIR)/opt/etc/sample.sudoers
	cd $(BUILD_DIR) && $(IPKG_BUILD) $(SUDO_IPK_DIR)


sudo-ipk: $(SUDO_IPK)

sudo-clean:
	-make -C $(BUILD_DIR)/sudo clean

sudo-dirclean:
	rm -rf $(SUDO_DIR) $(SUDO_IPK_DIR) $(SUDO_IPK)

install: sudo-install

clean: sudo-clean

sudo: sudo-build
