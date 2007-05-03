###########################################################
#
# atftp
#
###########################################################

ATFTP_SITE=http://downloads.openwrt.org/sources
ATFTP_VERSION=0.7
ATFTP_SOURCE=atftp-$(ATFTP_VERSION).tar.gz
ATFTP_DIR=atftp-$(ATFTP_VERSION)
ATFTP_UNZIP=zcat
ATFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ATFTP_DESCRIPTION=Advanced TFTP server and client
ATFTP_SECTION=net
ATFTP_PRIORITY=optional
ATFTP_DEPENDS=xinetd,pcre
ATFTP_CONFLICTS=

ATFTP_IPK_VERSION=7

ATFTP_CONFFILES=/opt/etc/xinetd.d/atftp

ATFTP_BUILD_DIR=$(BUILD_DIR)/atftp
ATFTP_SOURCE_DIR=$(SOURCE_DIR)/atftp
ATFTP_IPK_DIR=$(BUILD_DIR)/atftp-$(ATFTP_VERSION)-ipk
ATFTP_IPK=$(BUILD_DIR)/atftp_$(ATFTP_VERSION)-$(ATFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(ATFTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(ATFTP_SITE)/$(ATFTP_SOURCE)

atftp-source: $(DL_DIR)/$(ATFTP_SOURCE) $(ATFTP_PATCHES)

$(ATFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(ATFTP_SOURCE) $(ATFTP_PATCHES)
	$(MAKE) ncurses-stage pcre-stage
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

$(ATFTP_IPK_DIR)/CONTROL/control:
	@install -d $(ATFTP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: atftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ATFTP_PRIORITY)" >>$@
	@echo "Section: $(ATFTP_SECTION)" >>$@
	@echo "Version: $(ATFTP_VERSION)-$(ATFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ATFTP_MAINTAINER)" >>$@
	@echo "Source: $(ATFTP_SITE)/$(ATFTP_SOURCE)" >>$@
	@echo "Description: $(ATFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(ATFTP_DEPENDS)" >>$@
	@echo "Conflicts: $(ATFTP_CONFLICTS)" >>$@

$(ATFTP_IPK): $(ATFTP_BUILD_DIR)/atftp
	rm -rf $(ATFTP_IPK_DIR) $(BUILD_DIR)/atftp_*_$(TARGET_ARCH).ipk
	install -d $(ATFTP_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(ATFTP_BUILD_DIR)/atftp -o $(ATFTP_IPK_DIR)/opt/bin/atftp
	install -d $(ATFTP_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(ATFTP_BUILD_DIR)/atftpd -o $(ATFTP_IPK_DIR)/opt/sbin/atftpd
	install -d $(ATFTP_IPK_DIR)/opt/etc/xinetd.d
	install -m 644 $(ATFTP_SOURCE_DIR)/atftp $(ATFTP_IPK_DIR)/opt/etc/xinetd.d/atftp
	$(MAKE) $(ATFTP_IPK_DIR)/CONTROL/control
	install -m 644 $(ATFTP_SOURCE_DIR)/postinst $(ATFTP_IPK_DIR)/CONTROL/postinst
	echo $(ATFTP_CONFFILES) | sed -e 's/ /\n/g' > $(ATFTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATFTP_IPK_DIR)

atftp-ipk: $(ATFTP_IPK)

atftp-clean:
	-$(MAKE) -C $(ATFTP_BUILD_DIR) clean

atftp-dirclean:
	rm -rf $(BUILD_DIR)/$(ATFTP_DIR) $(ATFTP_BUILD_DIR) $(ATFTP_IPK_DIR) $(ATFTP_IPK)
