#############################################################
#
# portmap
#
#############################################################

PORTMAP_DIR:=$(BUILD_DIR)/portmap

PORTMAP_VERSION=4
PORTMAP=portmap_$(PORTMAP_VERSION)
PORTMAP_SITE=http://ftp.surfnet.nl/security/tcpwrappers
PORTMAP_SOURCE:=$(PORTMAP).tar.gz
PORTMAP_UNZIP=zcat
PORTMAP_PATCH:=$(SOURCE_DIR)/portmap.patch
PORTMAP_IPK=$(BUILD_DIR)/portmap_$(PORTMAP_VERSION)-1_armeb.ipk
PORTMAP_IPK_DIR:=$(BUILD_DIR)/portmap-$(PORTMAP_VERSION)-ipk

$(DL_DIR)/$(PORTMAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PORTMAP_SITE)/$(PORTMAP_SOURCE)

portmap-source: $(DL_DIR)/$(PORTMAP_SOURCE) $(PORTMAP_PATCH)

$(PORTMAP_DIR)/.configured: $(DL_DIR)/$(PORTMAP_SOURCE) $(PORTMAP_PATCH)
	@rm -rf $(BUILD_DIR)/$(PORTMAP) $(PORTMAP_DIR)
	$(PORTMAP_UNZIP) $(DL_DIR)/$(PORTMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	patch -d $(BUILD_DIR)/$(PORTMAP) -p1 < $(PORTMAP_PATCH)
	mv $(BUILD_DIR)/$(PORTMAP) $(PORTMAP_DIR)
	touch $(PORTMAP_DIR)/.configured

portmap-unpack: $(PORTMAP_DIR)/.configured

$(PORTMAP_DIR)/portmap: $(PORTMAP_DIR)/.configured
	make -C $(PORTMAP_DIR) \
		CC=$(TARGET_CC) LD=$(TARGET_LD) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)

portmap: $(PORTMAP_DIR)/portmap

portmap-diff: #$(PORTMAP_DIR)/config.h
	@rm -rf $(BUILD_DIR)/$(PORTMAP)
	$(PORTMAP_UNZIP) $(DL_DIR)/$(PORTMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	-make -C $(PORTMAP_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(PORTMAP) portmap | grep -v ^Only > $(PORTMAP_PATCH)

$(PORTMAP_IPK): $(PORTMAP_DIR)/portmap
	install -d $(PORTMAP_IPK_DIR)/CONTROL
	install -d $(PORTMAP_IPK_DIR)/opt/sbin $(PORTMAP_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(PORTMAP_DIR)/portmap -o $(PORTMAP_IPK_DIR)/opt/sbin/portmap
	install -m 755 $(SOURCE_DIR)/portmap.rc $(PORTMAP_IPK_DIR)/opt/etc/init.d/S55portmap
	install -m 644 $(SOURCE_DIR)/portmap.control  $(PORTMAP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PORTMAP_IPK_DIR)

portmap-ipk: $(PORTMAP_IPK)

portmap-clean:
	-make -C $(PORTMAP_DIR) clean

portmap-dirclean:
	rm -rf $(PORTMAP_DIR) $(PORTMAP_IPK_DIR)
