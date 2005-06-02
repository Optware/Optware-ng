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
BASH_MAINTAINER=Christopher Blunck <christopher.blunck@gmail.com>
BASH_DESCRIPTION=A bourne style shell
BASH_SECTION=shell
BASH_PRIORITY=optional
BASH_DEPENDS=ncurses
BASH_CONFLICTS=

BASH_IPK_VERSION=5

BASH_CPPFLAGS=
BASH_LDFLAGS=

BASH_BUILD_DIR=$(BUILD_DIR)/bash
BASH_SOURCE_DIR=$(SOURCE_DIR)/bash
BASH_IPK_DIR=$(BUILD_DIR)/bash-$(BASH_VERSION)-ipk
BASH_IPK=$(BUILD_DIR)/bash_$(BASH_VERSION)-$(BASH_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(BASH_SOURCE):
	$(WGET) -P $(DL_DIR) $(BASH_SITE)/$(BASH_SOURCE)

bash-source: $(DL_DIR)/$(BASH_SOURCE)

$(BASH_BUILD_DIR)/.configured: $(DL_DIR)/$(BASH_SOURCE)
	$(MAKE) termcap-stage
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
		bash_cv_sys_siglist=yes \
		bash_cv_under_sys_siglist=yes \
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

bash: $(BASH_BUILD_DIR)/bash

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bash
#
$(BASH_IPK_DIR)/CONTROL/control:
	@install -d $(BASH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bash" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BASH_PRIORITY)" >>$@
	@echo "Section: $(BASH_SECTION)" >>$@
	@echo "Version: $(BASH_VERSION)-$(BASH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BASH_MAINTAINER)" >>$@
	@echo "Source: $(BASH_SITE)/$(BASH_SOURCE)" >>$@
	@echo "Description: $(BASH_DESCRIPTION)" >>$@
	@echo "Depends: $(BASH_DEPENDS)" >>$@
	@echo "Conflicts: $(BASH_CONFLICTS)" >>$@

$(BASH_IPK): $(BASH_BUILD_DIR)/bash
	rm -rf $(BASH_IPK_DIR) $(BUILD_DIR)/bash_*_$(TARGET_ARCH).ipk
	install -d $(BASH_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(BASH_BUILD_DIR)/bash -o $(BASH_IPK_DIR)/opt/bin/bash
	install -d $(BASH_IPK_DIR)/opt/etc 
	install -m 644 $(BASH_SOURCE_DIR)/profile $(BASH_IPK_DIR)/opt/etc/profile
	install -d $(BASH_IPK_DIR)/opt/etc/init.d
	install -m 755 $(BASH_SOURCE_DIR)/rc.bash $(BASH_IPK_DIR)/opt/etc/init.d/S05bash
	install -d $(BASH_IPK_DIR)/bin
	ln -s /opt/bin/bash $(BASH_IPK_DIR)/bin/bash
	$(MAKE) $(BASH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BASH_IPK_DIR)

bash-ipk: $(BASH_IPK)

bash-clean:
	-$(MAKE) -C $(BASH_BUILD_DIR) clean

bash-dirclean:
	rm -rf $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR) $(BASH_IPK_DIR) $(BASH_IPK)
