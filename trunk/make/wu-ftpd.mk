#############################################################
#
# wu-ftpd
#
#############################################################

WU_FTPD_DIR:=$(BUILD_DIR)/wu-ftpd

WU_FTPD_VERSION:=2.6.2
WU_FTPD:=wu-ftpd-$(WU_FTPD_VERSION)
WU_FTPD_SITE:=ftp://ftp.wu-ftpd.org/pub/wu-ftpd
WU_FTPD_SOURCE:=$(WU_FTPD).tar.gz
WU_FTPD_UNZIP:=zcat

WU_FTPD_PATCHES:=$(SOURCE_DIR)/wu-ftpd-realpath.patch $(SOURCE_DIR)/wu-ftpd-connect-dos.patch

WU_FTPD_IPK:=$(BUILD_DIR)/wu-ftpd_$(WU_FTPD_VERSION)_armeb.ipk
WU_FTPD_IPK_DIR:=$(BUILD_DIR)/wu-ftpd-$(WU_FTPD_VERSION)-ipk

$(DL_DIR)/$(WU_FTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(WU_FTPD_SITE)/$(WU_FTPD_SOURCE)

wu-ftpd-source: $(DL_DIR)/$(WU_FTPD_SOURCE) $(WU_FTPD_PATCHES)

$(WU_FTPD_DIR)/.configured: $(DL_DIR)/$(WU_FTPD_SOURCE) $(WU_FTPD_PATCHES)
	@rm -rf $(BUILD_DIR)/$(WU_FTPD) $(WU_FTPD_DIR)
	$(WU_FTPD_UNZIP) $(DL_DIR)/$(WU_FTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(WU_FTPD_PATCHES) | patch -d $(BUILD_DIR)/$(WU_FTPD) -p0
	mv $(BUILD_DIR)/$(WU_FTPD) $(WU_FTPD_DIR)
	cd $(WU_FTPD_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--target=$(GNU_SHORT_TARGET_NAME) \
		--host=$(GNU_SHORT_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--sysconfdir=/opt/etc
	touch $(WU_FTPD_DIR)/.configured

wu-ftpd-unpack: $(WU_FTPD_DIR)/.configured

$(WU_FTPD_DIR)/wu-ftpd: $(WU_FTPD_DIR)/.configured
	make -C $(WU_FTPD_DIR)

wu-ftpd: $(WU_FTPD_DIR)/wu-ftpd

$(WU_FTPD_IPK): $(WU_FTPD_DIR)/wu-ftpd
	install -d $(WU_FTPD_IPK_DIR)/CONTROL
	install -d $(WU_FTPD_IPK_DIR)/opt/sbin $(WU_FTPD_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(WU_FTPD_DIR)/wu-ftpd -o $(WU_FTPD_IPK_DIR)/opt/sbin/wu-ftpd
	install -m 755 $(SOURCE_DIR)/wu-ftpd.rc $(WU_FTPD_IPK_DIR)/opt/etc/init.d/S51wu-ftpd
	install -m 644 $(SOURCE_DIR)/wu-ftpd.control  $(WU_FTPD_IPK_DIR)/CONTROL/control
	install -m 644 $(SOURCE_DIR)/wu-ftpd.postinst $(WU_FTPD_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SOURCE_DIR)/wu-ftpd.prerm    $(WU_FTPD_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WU_FTPD_IPK_DIR)

wu-ftpd-ipk: $(WU_FTPD_IPK)

wu-ftpd-clean:
	-make -C $(WU_FTPD_DIR) clean

wu-ftpd-dirclean:
	rm -rf $(WU_FTPD_DIR) $(WU_FTPD_IPK_DIR)
