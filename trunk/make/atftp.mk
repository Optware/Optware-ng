###########################################################
#
# atftp
#
###########################################################

ATFTP_SITE=ftp://ftp.mamalinux.com/pub/atftp
ATFTP_VERSION=0.7
ATFTP_SOURCE=atftp-$(ATFTP_VERSION).tar.gz
ATFTP_DIR=atftp-$(ATFTP_VERSION)
ATFTP_UNZIP=zcat

ATFTP_IPK_VERSION=1

ATFTP_BUILD_DIR=$(BUILD_DIR)/atftp
ATFTP_SOURCE_DIR=$(SOURCE_DIR)/atftp
ATFTP_IPK_DIR=$(BUILD_DIR)/atftp-$(ATFTP_VERSION)-ipk
ATFTP_IPK=$(BUILD_DIR)/atftp_$(ATFTP_VERSION)-$(ATFTP_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(ATFTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(ATFTP_SITE)/$(ATFTP_SOURCE)

atftp-source: $(DL_DIR)/$(ATFTP_SOURCE) $(ATFTP_PATCHES)

$(ATFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(ATFTP_SOURCE) $(ATFTP_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(ATFTP_DIR) $(ATFTP_BUILD_DIR)
	$(ATFTP_UNZIP) $(DL_DIR)/$(ATFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ATFTP_DIR) $(ATFTP_BUILD_DIR)
	(cd $(ATFTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(ATFTP_BUILD_DIR)/.configured

atftp-unpack: $(ATFTP_BUILD_DIR)/.configured

$(ATFTP_BUILD_DIR)/atftp: $(ATFTP_BUILD_DIR)/.configured
	$(MAKE) -C $(ATFTP_BUILD_DIR)

atftp: $(ATFTP_BUILD_DIR)/atftp

$(ATFTP_IPK): $(ATFTP_BUILD_DIR)/atftp
	rm -rf $(ATFTP_IPK_DIR) $(ATFTP_IPK)
	install -d $(ATFTP_IPK_DIR)/opt/bin
	$(STRIP) $(ATFTP_BUILD_DIR)/atftp -o $(ATFTP_IPK_DIR)/opt/bin/atftp
	install -d $(ATFTP_IPK_DIR)/opt/sbin
	$(STRIP) $(ATFTP_BUILD_DIR)/atftpd -o $(ATFTP_IPK_DIR)/opt/sbin/atftpd
	install -d $(ATFTP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(ATFTP_SOURCE_DIR)/rc.atftpd $(ATFTP_IPK_DIR)/opt/etc/init.d/S60atftpd
	install -d $(ATFTP_IPK_DIR)/CONTROL
	install -m 644 $(ATFTP_SOURCE_DIR)/control $(ATFTP_IPK_DIR)/CONTROL/control
	install -m 644 $(ATFTP_SOURCE_DIR)/postinst $(ATFTP_IPK_DIR)/CONTROL/postinst
	install -m 644 $(ATFTP_SOURCE_DIR)/prerm $(ATFTP_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATFTP_IPK_DIR)

atftp-ipk: $(ATFTP_IPK)

atftp-clean:
	-$(MAKE) -C $(ATFTP_BUILD_DIR) clean

atftp-dirclean:
	rm -rf $(BUILD_DIR)/$(ATFTP_DIR) $(ATFTP_BUILD_DIR) $(ATFTP_IPK_DIR) $(ATFTP_IPK)
