###########################################################
#
# iptables
#
###########################################################

IPTABLES_DIR=$(BUILD_DIR)/iptables

IPTABLES_VERSION=1.2.11
IPTABLES=iptables-$(IPTABLES_VERSION)
IPTABLES_SITE=http://www.netfilter.org/files/
IPTABLES_SOURCE=$(IPTABLES).tar.bz2
IPTABLES_UNZIP=bzcat

IPTABLES_IPK=$(BUILD_DIR)/iptables_$(IPTABLES_VERSION)-1_armeb.ipk
IPTABLES_IPK_DIR=$(BUILD_DIR)/iptables-$(IPTABLES_VERSION)-ipk

# FIXME:  This should point to where the slug's kernel source is downloaded
KERNEL_DIR=/Area51/Linksys/gpl_code_2.03/os/linux-2.4/

$(DL_DIR)/$(IPTABLES_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPTABLES_SITE)/$(IPTABLES_SOURCE)

iptables-source: $(DL_DIR)/$(IPTABLES_SOURCE)

$(IPTABLES_DIR)/.source: $(DL_DIR)/$(IPTABLES_SOURCE)
	$(IPTABLES_UNZIP) $(DL_DIR)/$(IPTABLES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/iptables-$(IPTABLES_VERSION) $(IPTABLES_DIR)
	touch $(IPTABLES_DIR)/.source

$(IPTABLES_DIR)/.configured: $(IPTABLES_DIR)/.source

$(IPTABLES_IPK_DIR): $(IPTABLES_DIR)/.configured
	$(MAKE) -C $(IPTABLES_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) KERNEL_DIR=$(KERNEL_DIR)

iptables-headers: $(IPTABLES_IPK_DIR)

iptables: $(IPTABLES_IPK_DIR)

$(IPTABLES_IPK): $(IPTABLES_IPK_DIR)
	mkdir -p $(IPTABLES_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/iptables.control $(IPTABLES_IPK_DIR)/CONTROL/control
	$(STRIP) $(IPTABLES_DIR)/src/iptables
	$(STRIP) $(IPTABLES_DIR)/src/eiptables
	$(STRIP) $(IPTABLES_DIR)/src/fiptables
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPTABLES_IPK_DIR)

iptables-ipk: $(IPTABLES_IPK)

iptables-source: $(DL_DIR)/$(IPTABLES_SOURCE)

iptables-clean:
	-$(MAKE) -C $(IPTABLES_DIR) uninstall
	-$(MAKE) -C $(IPTABLES_DIR) clean

iptables-distclean:
	-rm $(IPTABLES_DIR)/.configured
	-$(MAKE) -C $(IPTABLES_DIR) distclean

