###########################################################
#
# miau
#
###########################################################

MIAU_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/miau
MIAU_VERSION=0.6.3
MIAU_SOURCE=miau-$(MIAU_VERSION).tar.gz
MIAU_DIR=miau-$(MIAU_VERSION)
MIAU_UNZIP=zcat
MIAU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MIAU_DESCRIPTION=The MIAU IRC Bouncer (Proxy)
MIAU_SECTION=net
MIAU_PRIORITY=optional
MIAU_DEPENDS=
MIAU_CONFLICTS=

MIAU_IPK_VERSION=1

MIAU_CONFFILES= /opt/etc/miau.conf \
		/opt/etc/init.d/S52miau \
		/opt/etc/logrotate.d/miau

#MIAU_PATCHES=$(MIAU_SOURCE_DIR)/paths.patch
MIAU_PATCHES=$(MIAU_SOURCE_DIR)/paths.patch.0.6.1

MIAU_CPPFLAGS=
MIAU_LDFLAGS=

MIAU_BUILD_DIR=$(BUILD_DIR)/miau
MIAU_SOURCE_DIR=$(SOURCE_DIR)/miau
MIAU_IPK_DIR=$(BUILD_DIR)/miau-$(MIAU_VERSION)-ipk
MIAU_IPK=$(BUILD_DIR)/miau_$(MIAU_VERSION)-$(MIAU_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: miau-source miau-unpack miau miau-stage miau-ipk miau-clean miau-dirclean miau-check

$(DL_DIR)/$(MIAU_SOURCE):
	$(WGET) -P $(DL_DIR) $(MIAU_SITE)/$(MIAU_SOURCE)

miau-source: $(DL_DIR)/$(MIAU_SOURCE) $(MIAU_PATCHES)

# ifeq ($(OPTWARE_TARGET),nslu2)
# MIAU_IPV6_FLAGS=--enable-ipv6
# else
MIAU_IPV6_FLAGS=
# endif

ifneq ($(HOSTCC), $(TARGET_CC))
MIAU_CROSS_FLAGS=\
		ac_cv_func_lstat_empty_string_bug=no \
		ac_cv_func_stat_empty_string_bug=no \
		ac_cv_func_lstat_dereferences_slashed_symlink=yes \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes
endif

$(MIAU_BUILD_DIR)/.configured: $(DL_DIR)/$(MIAU_SOURCE)
	$(MIAU_UNZIP) $(DL_DIR)/$(MIAU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MIAU_PATCHES) | patch -d $(BUILD_DIR)/$(MIAU_DIR) -p1
	mv $(BUILD_DIR)/$(MIAU_DIR) $(MIAU_BUILD_DIR)
	(cd $(MIAU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MIAU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MIAU_LDFLAGS)" \
		$(MIAU_CROSS_FLAGS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt	\
		--enable-dccbounce \
		--enable-automode \
		--enable-releasenick \
		--enable-ctcp-replies \
		--enable-mkpasswd \
		--enable-uptime \
		--enable-chanlog \
		--enable-privlog \
		--enable-onconnect \
		--enable-empty-awaymsg \
		--enable-enduserdebug \
		--enable-pingstat \
		--enable-dumpstatus \
		$(MIAU_IPV6_FLAGS) \
	)
	touch $(MIAU_BUILD_DIR)/.configured

miau-unpack: $(MIAU_BUILD_DIR)/.configured

$(MIAU_BUILD_DIR)/src/miau: $(MIAU_BUILD_DIR)/.configured
	$(MAKE) -C $(MIAU_BUILD_DIR)

miau: $(MIAU_BUILD_DIR)/src/miau

$(MIAU_IPK_DIR)/CONTROL/control:
	@install -d $(MIAU_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: miau" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MIAU_PRIORITY)" >>$@
	@echo "Section: $(MIAU_SECTION)" >>$@
	@echo "Version: $(MIAU_VERSION)-$(MIAU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MIAU_MAINTAINER)" >>$@
	@echo "Source: $(MIAU_SITE)/$(MIAU_SOURCE)" >>$@
	@echo "Description: $(MIAU_DESCRIPTION)" >>$@
	@echo "Depends: $(MIAU_DEPENDS)" >>$@
	@echo "Conflicts: $(MIAU_CONFLICTS)" >>$@

$(MIAU_IPK): $(MIAU_BUILD_DIR)/src/miau
	rm -rf $(MIAU_IPK_DIR) $(BUILD_DIR)/miau_*_$(TARGET_ARCH).ipk
	install -d $(MIAU_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(MIAU_BUILD_DIR)/src/miau -o $(MIAU_IPK_DIR)/opt/bin/miau
	install -d $(MIAU_IPK_DIR)/opt/etc
#	install -m 644 $(MIAU_SOURCE_DIR)/miau.conf $(MIAU_IPK_DIR)/opt/etc/miau.conf
	install -m 644 $(MIAU_SOURCE_DIR)/miau.conf.0.6 $(MIAU_IPK_DIR)/opt/etc/miau.conf
	install -d $(MIAU_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MIAU_SOURCE_DIR)/rc.miau $(MIAU_IPK_DIR)/opt/etc/init.d/S52miau
	install -d $(MIAU_IPK_DIR)/opt/etc/logrotate.d
	install -m 755 $(MIAU_SOURCE_DIR)/logrotate.miau $(MIAU_IPK_DIR)/opt/etc/logrotate.d/miau
	$(MAKE) $(MIAU_IPK_DIR)/CONTROL/control
	install -m 644 $(MIAU_SOURCE_DIR)/postinst $(MIAU_IPK_DIR)/CONTROL/postinst
	install -m 644 $(MIAU_SOURCE_DIR)/prerm $(MIAU_IPK_DIR)/CONTROL/prerm
	echo $(MIAU_CONFFILES) | sed -e 's/ /\n/g' > $(MIAU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MIAU_IPK_DIR)

miau-ipk: $(MIAU_IPK)

miau-clean:
	-$(MAKE) -C $(MIAU_BUILD_DIR) clean

miau-dirclean:
	rm -rf $(BUILD_DIR)/$(MIAU_DIR) $(MIAU_BUILD_DIR) $(MIAU_IPK_DIR) $(MIAU_IPK)

miau-check: $(MIAU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MIAU_IPK)
