###########################################################
#
# atftp
#
###########################################################

ATFTP_SITE=http://downloads.openwrt.org/sources
ATFTP_VERSION=0.7
ATFTP_SOURCE=atftp-$(ATFTP_VERSION).tar.gz
ATFTP_DIR=atftp-$(ATFTP_VERSION)
ATFTP_UNZIP=zcat
ATFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ATFTP_DESCRIPTION=Advanced TFTP server and client
ATFTP_SECTION=net
ATFTP_PRIORITY=optional
ATFTP_DEPENDS=xinetd,pcre
ATFTP_CONFLICTS=

ATFTP_IPK_VERSION=11

ATFTP_CONFFILES=$(TARGET_PREFIX)/etc/xinetd.d/atftp

ATFTP_PATCHES = $(ATFTP_SOURCE_DIR)/CLK_TCK.patch
ifeq ($(OPTWARE_TARGET), $(filter buildroot-i686 buildroot-ppc-603e buildroot-x86_64 ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
ATFTP_PATCHES += $(ATFTP_SOURCE_DIR)/argz.h.patch
endif
ifdef ATFTP_EXTRA_PATCHES
ATFTP_PATCHES += $(ATFTP_EXTRA_PATCHES)
endif

ATFTP_BUILD_DIR=$(BUILD_DIR)/atftp
ATFTP_SOURCE_DIR=$(SOURCE_DIR)/atftp
ATFTP_IPK_DIR=$(BUILD_DIR)/atftp-$(ATFTP_VERSION)-ipk
ATFTP_IPK=$(BUILD_DIR)/atftp_$(ATFTP_VERSION)-$(ATFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(ATFTP_SOURCE):
	$(WGET) -P $(@D) $(ATFTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

atftp-source: $(DL_DIR)/$(ATFTP_SOURCE) $(ATFTP_PATCHES)

$(ATFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(ATFTP_SOURCE) $(ATFTP_PATCHES) make/atftp.mk
	$(MAKE) ncurses-stage pcre-stage
	rm -rf $(BUILD_DIR)/$(ATFTP_DIR) $(@D)
	$(ATFTP_UNZIP) $(DL_DIR)/$(ATFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ATFTP_PATCHES)" ; then \
		cat $(ATFTP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(ATFTP_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(ATFTP_DIR) $(@D)
ifeq ($(OPTWARE_TARGET), $(filter buildroot-armeabihf, $(OPTWARE_TARGET)))
	sed -i -e 's/#ifdef __USE_EXTERN_INLINES/#if 0/' $(@D)/argz.h
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -std=gnu89" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
	)
	touch $@

atftp-unpack: $(ATFTP_BUILD_DIR)/.configured

$(ATFTP_BUILD_DIR)/.built: $(ATFTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

atftp: $(ATFTP_BUILD_DIR)/.built

$(ATFTP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: atftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ATFTP_PRIORITY)" >>$@
	@echo "Section: $(ATFTP_SECTION)" >>$@
	@echo "Version: $(ATFTP_VERSION)-$(ATFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ATFTP_MAINTAINER)" >>$@
	@echo "Source: $(ATFTP_SITE)/$(ATFTP_SOURCE)" >>$@
	@echo "Description: $(ATFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(ATFTP_DEPENDS)" >>$@
	@echo "Conflicts: $(ATFTP_CONFLICTS)" >>$@

$(ATFTP_IPK): $(ATFTP_BUILD_DIR)/.built
	rm -rf $(ATFTP_IPK_DIR) $(BUILD_DIR)/atftp_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ATFTP_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(ATFTP_BUILD_DIR)/atftp -o $(ATFTP_IPK_DIR)$(TARGET_PREFIX)/bin/atftp
	$(INSTALL) -d $(ATFTP_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(STRIP_COMMAND) $(ATFTP_BUILD_DIR)/atftpd -o $(ATFTP_IPK_DIR)$(TARGET_PREFIX)/sbin/atftpd
	$(INSTALL) -d $(ATFTP_IPK_DIR)$(TARGET_PREFIX)/etc/xinetd.d
	$(INSTALL) -m 644 $(ATFTP_SOURCE_DIR)/atftp $(ATFTP_IPK_DIR)$(TARGET_PREFIX)/etc/xinetd.d/atftp
	$(MAKE) $(ATFTP_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(ATFTP_SOURCE_DIR)/postinst $(ATFTP_IPK_DIR)/CONTROL/postinst
	echo $(ATFTP_CONFFILES) | sed -e 's/ /\n/g' > $(ATFTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATFTP_IPK_DIR)

atftp-ipk: $(ATFTP_IPK)

atftp-clean:
	-$(MAKE) -C $(ATFTP_BUILD_DIR) clean

atftp-dirclean:
	rm -rf $(BUILD_DIR)/$(ATFTP_DIR) $(ATFTP_BUILD_DIR) $(ATFTP_IPK_DIR) $(ATFTP_IPK)

atftp-check: $(ATFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
