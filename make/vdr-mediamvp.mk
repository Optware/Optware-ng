###########################################################
#
# vdr-mediamvp
#
###########################################################

VDR_MEDIAMVP_DIR=$(BUILD_DIR)/mediamvp

VDR_MEDIAMVP_VERSION=0.1.4
VDR_MEDIAMVP=mediamvp-$(VDR_MEDIAMVP_VERSION)
VDR_MEDIAMVP_SITE=http://www.rst38.org.uk/vdr/mediamvp
VDR_MEDIAMVP_SOURCE=vdr-$(VDR_MEDIAMVP).tgz
VDR_MEDIAMVP_UNZIP=zcat
VDR_MEDIAMVP_IPK=$(BUILD_DIR)/vdr-mediamvp_$(VDR_MEDIAMVP_VERSION)-1_armeb.ipk
VDR_MEDIAMVP_IPK_DIR=$(BUILD_DIR)/vdr-mediamvp-$(VDR_MEDIAMVP_VERSION)-ipk

$(DL_DIR)/$(VDR_MEDIAMVP_SOURCE):
	$(WGET) -P $(DL_DIR) $(VDR_MEDIAMVP_SITE)/$(VDR_MEDIAMVP_SOURCE)

vdr-mediamvp-source: $(DL_DIR)/$(VDR_MEDIAMVP_SOURCE) $(VDR_MEDIAMVP_PATCH)

$(VDR_MEDIAMVP_DIR)/.source: $(DL_DIR)/$(VDR_MEDIAMVP_SOURCE)
	$(VDR_MEDIAMVP_UNZIP) $(DL_DIR)/$(VDR_MEDIAMVP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(VDR_MEDIAMVP) $(VDR_MEDIAMVP_DIR)
	touch $(VDR_MEDIAMVP_DIR)/.source

$(VDR_MEDIAMVP_DIR)/console/mediamvp: $(VDR_MEDIAMVP_DIR)/.source
	echo "EXTRA_INCLUDES=-I$(STAGING_DIR)/opt/include" > $(VDR_MEDIAMVP_DIR)/config.mak
	echo "EXTRA_LIBS=-L$(STAGING_DIR)/opt/lib " >> $(VDR_MEDIAMVP_DIR)/config.mak
	echo "HAVE_LIBID3TAG=1" >> $(VDR_MEDIAMVP_DIR)/config.mak
	$(MAKE) -C $(VDR_MEDIAMVP_DIR)/console RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR)" CC="$(TARGET_CC)" 

vdr-mediamvp: zlib libevent libid3tag $(VDR_MEDIAMVP_DIR)/src/vdr-mediamvp

$(VDR_MEDIAMVP_IPK): $(VDR_MEDIAMVP_DIR)/console/mediamvp
	-mkdir -p $(VDR_MEDIAMVP_IPK_DIR)	
	mkdir -p $(VDR_MEDIAMVP_IPK_DIR)/opt/sbin
	mkdir -p $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/mediamvp
	mkdir -p $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/init.d
	install -d $(VDR_MEDIAMVP_IPK_DIR)/CONTROL
	$(STRIP) --strip-unneeded $(VDR_MEDIAMVP_DIR)/console/mediamvp -o $(VDR_MEDIAMVP_IPK_DIR)/opt/sbin/mediamvp
	install -m 644 $(SOURCE_DIR)/vdr-mediamvp.conf $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/mediamvp/mediamvp.conf
	install -m 644 $(SOURCE_DIR)/vdr-mediamvp.radio $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/mediamvp/mediamvp.radio
	install -m 755 $(SOURCE_DIR)/vdr-mediamvp.rc $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/init.d/S60mediamvp
	install -m 644 $(SOURCE_DIR)/vdr-mediamvp.control $(VDR_MEDIAMVP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VDR_MEDIAMVP_IPK_DIR)

vdr-mediamvp-ipk: $(VDR_MEDIAMVP_IPK)

vdr-mediamvp-clean:
	-$(MAKE) -C $(VDR_MEDIAMVP_DIR) uninstall
	-$(MAKE) -C $(VDR_MEDIAMVP_DIR) clean

vdr-mediamvp-dirclean: vdr-mediamvp-clean
	rm -rf $(VDR_MEDIAMVP_DIR) $(VDR_MEDIAMVP_IPK_DIR) $(VDR_MEDIAMVP_IPK)

