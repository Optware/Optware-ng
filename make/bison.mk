###########################################################
#
# bison
#
###########################################################

BISON_DIR=$(BUILD_DIR)/bison

BISON_VERSION=1.875
BISON=bison-$(BISON_VERSION)
BISON_SITE=ftp://ftp.gnu.org/gnu/bison
BISON_SOURCE=$(BISON).tar.gz
BISON_UNZIP=zcat

BISON_IPK=$(BUILD_DIR)/bison_$(BISON_VERSION)-1_armeb.ipk
BISON_IPK_DIR=$(BUILD_DIR)/bison-$(BISON_VERSION)-ipk

$(DL_DIR)/$(BISON_SOURCE):
	$(WGET) -P $(DL_DIR) $(BISON_SITE)/$(BISON_SOURCE)

bison-source: $(DL_DIR)/$(BISON_SOURCE)

$(BISON_DIR)/.source: $(DL_DIR)/$(BISON_SOURCE)
	$(BISON_UNZIP) $(DL_DIR)/$(BISON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/bison-$(BISON_VERSION) $(BISON_DIR)
	touch $(BISON_DIR)/.source

$(BISON_DIR)/.configured: $(BISON_DIR)/.source
	(cd $(BISON_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt \
	);
	touch $(BISON_DIR)/.configured

$(BISON_DIR)/src/bison: $(BISON_DIR)/.configured
	$(MAKE) -C $(BISON_DIR)

bison: $(BISON_DIR)/src/bison

$(BISON_IPK): $(BISON_DIR)/src/bison
	mkdir -p $(BISON_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/bison.control $(BISON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BISON_IPK_DIR)

bison-ipk: $(BISON_IPK)

bison-source: $(DL_DIR)/$(BISON_SOURCE)

bison-clean:
	-$(MAKE) -C $(BISON_DIR) uninstall
	-$(MAKE) -C $(BISON_DIR) clean

bison-distclean:
	-rm $(BISON_DIR)/.configured
	-$(MAKE) -C $(BISON_DIR) distclean

