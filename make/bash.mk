###########################################################
#
# bash
#
###########################################################

BASH_SITE=http://ftp.gnu.org/gnu/bash/
BASH_VERSION=2.05b
BASH_SOURCE=bash-$(BASH_VERSION).tar.gz
BASH_DIR=bash-$(BASH_VERSION)
BASH_UNZIP=zcat

BASH_IPK_VERSION=2

BASH_CPPFLAGS=
BASH_LDFLAGS=

BASH_BUILD_DIR=$(BUILD_DIR)/bash
BASH_SOURCE_DIR=$(SOURCE_DIR)/bash
BASH_IPK_DIR=$(BUILD_DIR)/bash-$(BASH_VERSION)-ipk
BASH_IPK=$(BUILD_DIR)/bash_$(BASH_VERSION)-$(BASH_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(BASH_SOURCE):
	$(WGET) -P $(DL_DIR) $(BASH_SITE)/$(BASH_SOURCE)

bash-source: $(DL_DIR)/$(BASH_SOURCE)

$(BASH_BUILD_DIR)/.configured: $(DL_DIR)/$(BASH_SOURCE)
	rm -rf $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR)
	$(BASH_UNZIP) $(DL_DIR)/$(BASH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR)
	(cd $(BASH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BASH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BASH_LDFLAGS)" \
		CC_FOR_BUILD=$(HOSTCC) \
		ac_cv_func_setvbuf_reversed=no \
		bash_cv_have_mbstate_t=yes \
		bash_cv_ulimit_maxfds=yes \
		bash_cv_func_sigsetjmp=present \
		bash_cv_printf_a_format=yes \
		bash_cv_job_control_missing=present \
		bash_cv_sys_named_pipes=present \
		bash_cv_unusable_rtsigs=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	touch $(BASH_BUILD_DIR)/.configured

bash-unpack: $(BASH_BUILD_DIR)/.configured

$(BASH_BUILD_DIR)/bash: $(BASH_BUILD_DIR)/.configured
	$(MAKE) -C $(BASH_BUILD_DIR)

bash: termcap-stage $(BASH_BUILD_DIR)/bash

$(BASH_IPK): $(BASH_BUILD_DIR)/bash
	rm -rf $(BASH_IPK_DIR) $(BUILD_DIR)/bash_*_armeb.ipk
	install -d $(BASH_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(BASH_BUILD_DIR)/bash -o $(BASH_IPK_DIR)/opt/bin/bash
	install -d $(BASH_IPK_DIR)/opt/etc 
	install -m 644 $(BASH_SOURCE_DIR)/profile $(BASH_IPK_DIR)/opt/etc/profile
	install -d $(BASH_IPK_DIR)/CONTROL
	install -m 644 $(BASH_SOURCE_DIR)/control $(BASH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BASH_IPK_DIR)

bash-ipk: $(BASH_IPK)

bash-clean:
	-$(MAKE) -C $(BASH_BUILD_DIR) clean

bash-dirclean:
	rm -rf $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR) $(BASH_IPK_DIR) $(BASH_IPK)
