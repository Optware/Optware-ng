###########################################################
#
# bash
#
###########################################################

BASH_DIR=$(BUILD_DIR)/bash

BASH_VERSION=2.05b
BASH=bash-$(BASH_VERSION)
BASH_SITE=http://ftp.gnu.org/gnu/bash/
BASH_SOURCE=$(BASH).tar.gz
BASH_UNZIP=zcat

BASH_IPK=$(BUILD_DIR)/bash_$(BASH_VERSION)-1_armeb.ipk
BASH_IPK_DIR=$(BUILD_DIR)/bash-$(BASH_VERSION)-ipk

CFLAGS="-I $(STAGING_DIR)/include/ncurses -I $(STAGING_DIR)/include/"
LDFLAGS="-L $(STAGING_DIR)/lib"

$(DL_DIR)/$(BASH_SOURCE):
	$(WGET) -P $(DL_DIR) $(BASH_SITE)/$(BASH_SOURCE)

bash-source: $(DL_DIR)/$(BASH_SOURCE)

$(BASH_DIR)/.source: $(DL_DIR)/$(BASH_SOURCE)
	$(BASH_UNZIP) $(DL_DIR)/$(BASH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/bash-$(BASH_VERSION) $(BASH_DIR)
	touch $(BASH_DIR)/.source

$(BASH_DIR)/.configured: $(BASH_DIR)/.source
	(cd $(BASH_DIR); \
		./configure \
		--prefix=$(BASH_IPK_DIR)/opt \
	);
	touch $(BASH_DIR)/.configured

$(BASH_IPK_DIR): $(BASH_DIR)/.configured
	$(MAKE) \
	  -C $(BASH_DIR) \
	  CC_FOR_BUILD=$(CC) \
	  CC=$(TARGET_CC) \
	  CFLAGS=$(CFLAGS) \
	  LDFLAGS=$(LDFLAGS) \
	  RANLIB=$(TARGET_RANLIB) \
	  AR=$(TARGET_AR) \
	  LD=$(TARGET_LD)

bash-headers: $(BASH_IPK_DIR)

bash: $(BASH_IPK_DIR)

$(BASH_IPK): $(BASH_IPK_DIR)
	mkdir -p $(BASH_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/bash.control $(BASH_IPK_DIR)/CONTROL/control
	$(STRIP) $(BASH_DIR)/src/bash
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BASH_IPK_DIR)

bash-ipk: $(BASH_IPK)

bash-source: $(DL_DIR)/$(BASH_SOURCE)

bash-clean:
	-$(MAKE) -C $(BASH_DIR) uninstall
	-$(MAKE) -C $(BASH_DIR) clean

bash-distclean:
	-rm $(BASH_DIR)/.configured
	-$(MAKE) -C $(BASH_DIR) distclean

