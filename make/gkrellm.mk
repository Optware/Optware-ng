###########################################################
#
# gkrellm
#
###########################################################

GKRELLM_DIR=$(BUILD_DIR)/gkrellm

GKRELLM_VERSION=2.2.4
GKRELLM=gkrellm-$(GKRELLM_VERSION)
GKRELLM_SITE=http://web.wt.net/~billw/gkrellm/
GKRELLM_SOURCE=$(GKRELLM).tar.gz
GKRELLM_UNZIP=zcat

GKRELLM_IPK=$(BUILD_DIR)/gkrellm_$(GKRELLM_VERSION)-1_armeb.ipk
GKRELLM_IPK_DIR=$(BUILD_DIR)/gkrellm-$(GKRELLM_VERSION)-ipk

SYSLIBS="-I $(STAGING_INCLUDE_DIR)/glib-2.0 \
	-I $(STAGING_INCLUDE_DIR)/gmodule-2.0 \
	-L $(STAGING_LIB_DIR) \
	-lz \
	-lgmodule-2.0 \
	-lglib-2.0 \
	-lgthread-2.0 \
	-Wl \
	--export-dynamic \
	-pthread"

$(DL_DIR)/$(GKRELLM_SOURCE):
	$(WGET) -P $(DL_DIR) $(GKRELLM_SITE)/$(GKRELLM_SOURCE)

gkrellm-source: $(DL_DIR)/$(GKRELLM_SOURCE)

$(GKRELLM_DIR)/.source: $(DL_DIR)/$(GKRELLM_SOURCE)
	$(GKRELLM_UNZIP) $(DL_DIR)/$(GKRELLM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/gkrellm-$(GKRELLM_VERSION) $(GKRELLM_DIR)
	touch $(GKRELLM_DIR)/.source

$(GKRELLM_DIR)/.configured: $(GKRELLM_DIR)/.source
	$(MAKE) glib-stage
	touch $(GKRELLM_DIR)/.configured

$(GKRELLM_IPK_DIR): $(GKRELLM_DIR)/.configured
	$(MAKE) -C $(GKRELLM_DIR)/server CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) SYS_LIBS=$(SYSLIBS) 

gkrellm-headers: $(GKRELLM_IPK_DIR)

gkrellm: $(GKRELLM_IPK_DIR)

$(GKRELLM_IPK): $(GKRELLM_IPK_DIR)
	mkdir -p $(GKRELLM_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/gkrellmd/control $(GKRELLM_IPK_DIR)/CONTROL/control
	install -d $(GKRELLM_IPK_DIR)/opt/sbin $(GKRELLM_IPK_DIR)/opt/etc/init.d
	$(TARGET_STRIP) $(GKRELLM_DIR)/server/gkrellmd -o $(GKRELLM_IPK_DIR)/opt/sbin/gkrellmd
	install -m 755 $(SOURCE_DIR)/gkrellmd/rc.gkrellmd $(GKRELLM_IPK_DIR)/opt/etc/init.d/S60gkrellmd
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GKRELLM_IPK_DIR)

gkrellm-ipk: $(GKRELLM_IPK) 

gkrellm-source: $(DL_DIR)/$(GKRELLM_SOURCE)

gkrellm-clean:
	-$(MAKE) -C $(GKRELLM_DIR) uninstall
	-$(MAKE) -C $(GKRELLM_DIR) clean

gkrellm-distclean:
	-rm $(GKRELLM_DIR)/.configured
	-$(MAKE) -C $(GKRELLM_DIR) distclean

gkrellm-dirclean:
	rm -rf $(GKRELLM_DIR) $(GKRELLM_IPK_DIR) $(GKRELLM_IPK)
