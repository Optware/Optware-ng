#############################################################
#
# lsof
#
#############################################################

LSOF_DIR:=$(BUILD_DIR)/lsof
LSOF_SOURCE_DIR:=$(SOURCE_DIR)/lsof
LSOF_VERSION:=4.74.dfsg.3
LSOF:=lsof-$(LSOF_VERSION).orig
LSOF_FILE:=lsof_$(LSOF_VERSION).orig
LSOF_DSC=lsof_$(LSOF_VERSION)-2.dsc
LSOF_SITE=http://http.us.debian.org/debian/pool/main/l/lsof
LSOF_SOURCE:=$(LSOF_FILE).tar.gz
LSOF_IPK_VERSION=1
LSOF_IPK:=$(BUILD_DIR)/lsof_$(LSOF_VERSION)-$(LSOF_IPK_VERSION)_$(TARGET_ARCH).ipk
LSOF_IPK_DIR:=$(BUILD_DIR)/lsof-$(LSOF_VERSION)-ipk
LSOF_PATCH:=$(LSOF_SOURCE_DIR)/Makefile-lib.patch
LSOF_UNZIP:=gunzip

$(DL_DIR)/$(LSOF_SOURCE):
	$(WGET) -P $(DL_DIR) $(LSOF_SITE)/$(LSOF_SOURCE)

$(DL_DIR)/$(LSOF_DSC):
	$(WGET) -P $(DL_DIR) $(LSOF_SITE)/$(LSOF_DSC)

lsof-source: $(DL_DIR)/$(LSOF_SOURCE) $(DL_DIR)/$(LSOF_DSC) $(LSOF_PATCH)

$(LSOF_DIR)/.configured: $(DL_DIR)/$(LSOF_SOURCE) $(DL_DIR)/$(LSOF_DSC) $(LSOF_PATCHES)
	@rm -rf $(BUILD_DIR)/$(LSOF) $(LSOF_DIR)
	cd $(DL_DIR) && \
		if [ `grep $(LSOF_SOURCE) $(LSOF_DSC) | cut -f 2 -d " "` != \
			`md5sum $(DL_DIR)/$(LSOF_SOURCE) | cut -f $(if $MD5FIELD == ppc_darwin,4,1)  -d " "` ] ; then \
			echo "md5sum is not a match, aborting." ; \
			exit 2; \
		else \
			echo "md5sum verified." ; \
		fi
	cd $(BUILD_DIR) && tar zxf $(DL_DIR)/$(LSOF_SOURCE)	
	cd $(BUILD_DIR)/$(LSOF) && echo "n\ny\ny\ny\nn\nn\ny\n" | ./Configure linux
	cat $(LSOF_PATCH) | patch -d $(BUILD_DIR)/$(LSOF) -p1
	mv $(BUILD_DIR)/$(LSOF) $(LSOF_DIR)
	touch $(LSOF_DIR)/.configured

lsof-unpack: $(LSOF_DIR)/.configured

$(LSOF_DIR)/lsof: $(LSOF_DIR)/.configured
	make -C $(LSOF_DIR) $(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS)"

lsof: $(LSOF_DIR)/lsof

$(LSOF_IPK): $(LSOF_DIR)/lsof
	rm -rf $(LSOF_IPK_DIR) $(BUILD_DIR)/lsof_*_$(TARGET_ARCH).ipk
	install -d $(LSOF_IPK_DIR)/CONTROL
	install -d $(LSOF_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(LSOF_DIR)/lsof -o $(LSOF_IPK_DIR)/opt/sbin/lsof
	install -m 644 $(LSOF_SOURCE_DIR)/control  $(LSOF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LSOF_IPK_DIR)

lsof-ipk: $(LSOF_IPK)

lsof-clean:
	-make -C $(LSOF_DIR) clean

lsof-dirclean:
	rm -rf $(LSOF_DIR) $(LSOF_IPK_DIR) $(LSOF_IPK)
