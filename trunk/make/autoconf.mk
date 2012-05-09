###########################################################
#
# autoconf
#
###########################################################

AUTOCONF_SITE=http://ftp.gnu.org/gnu/autoconf
AUTOCONF_VERSION=2.69
AUTOCONF_SOURCE=autoconf-$(AUTOCONF_VERSION).tar.xz
AUTOCONF_DIR=autoconf-$(AUTOCONF_VERSION)
AUTOCONF_UNZIP=$(HOST_STAGING_PREFIX)/bin/xzcat
AUTOCONF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOCONF_DESCRIPTION=Creating scripts to configure source code packages using templates
AUTOCONF_SECTION=util
AUTOCONF_PRIORITY=optional
AUTOCONF_DEPENDS=make, m4
AUTOCONF_CONFLICTS=

AUTOCONF_IPK_VERSION=1

AUTOCONF_BUILD_DIR=$(BUILD_DIR)/autoconf
AUTOCONF_SOURCE_DIR=$(SOURCE_DIR)/autoconf
AUTOCONF_IPK_DIR=$(BUILD_DIR)/autoconf-$(AUTOCONF_VERSION)-ipk
AUTOCONF_IPK=$(BUILD_DIR)/autoconf_$(AUTOCONF_VERSION)-$(AUTOCONF_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOCONF_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/autoconf

.PHONY: autoconf-source autoconf-unpack autoconf autoconf-stage autoconf-ipk autoconf-clean autoconf-dirclean autoconf-check autoconf-host autoconf-host-stage

$(DL_DIR)/$(AUTOCONF_SOURCE):
	$(WGET) -P $(@D) $(AUTOCONF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

autoconf-source: $(DL_DIR)/$(AUTOCONF_SOURCE) $(AUTOCONF_PATCHES)


$(AUTOCONF_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOCONF_SOURCE) make/autoconf.mk
	$(MAKE) xz-utils-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(AUTOCONF_DIR) $(@D)
	$(AUTOCONF_UNZIP) $(DL_DIR)/$(AUTOCONF_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(AUTOCONF_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--datarootdir=$(HOST_STAGING_PREFIX)/share \
	)
	$(MAKE) -C $(@D)
	touch $@

autoconf-host: $(AUTOCONF_HOST_BUILD_DIR)/.built


$(AUTOCONF_HOST_BUILD_DIR)/.staged: $(AUTOCONF_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	touch $@

autoconf-host-stage: $(AUTOCONF_HOST_BUILD_DIR)/.staged


$(AUTOCONF_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOCONF_SOURCE) $(AUTOCONF_PATCHES) make/autoconf.mk
	$(MAKE) xz-utils-host-stage
	rm -rf $(BUILD_DIR)/$(AUTOCONF_DIR) $(@D)
	$(AUTOCONF_UNZIP) $(DL_DIR)/$(AUTOCONF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(AUTOCONF_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

autoconf-unpack: $(AUTOCONF_BUILD_DIR)/.configured

$(AUTOCONF_BUILD_DIR)/.built: $(AUTOCONF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

autoconf: $(AUTOCONF_BUILD_DIR)/.built

$(AUTOCONF_BUILD_DIR)/.staged: $(AUTOCONF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

autoconf-stage: $(AUTOCONF_BUILD_DIR)/.staged

$(AUTOCONF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: autoconf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOCONF_PRIORITY)" >>$@
	@echo "Section: $(AUTOCONF_SECTION)" >>$@
	@echo "Version: $(AUTOCONF_VERSION)-$(AUTOCONF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOCONF_MAINTAINER)" >>$@
	@echo "Source: $(AUTOCONF_SITE)/$(AUTOCONF_SOURCE)" >>$@
	@echo "Description: $(AUTOCONF_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOCONF_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOCONF_CONFLICTS)" >>$@

$(AUTOCONF_IPK): $(AUTOCONF_BUILD_DIR)/.built
	rm -rf $(AUTOCONF_IPK_DIR) $(BUILD_DIR)/autoconf_*_$(TARGET_ARCH).ipk
	install -d $(AUTOCONF_IPK_DIR)/opt/bin
	install -d $(AUTOCONF_IPK_DIR)/opt/info
	install -d $(AUTOCONF_IPK_DIR)/opt/man/man1
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/Autom4te
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/autoconf
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/autoscan
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/autotest
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/m4sugar
	$(MAKE) -C $(AUTOCONF_BUILD_DIR) DESTDIR=$(AUTOCONF_IPK_DIR) install
	sed -i -e 's|/usr/bin/m4|/opt/bin/m4|g' $(AUTOCONF_IPK_DIR)/opt/bin/*
	sed -i -e 's|/usr/bin/perl|/opt/bin/perl|g' $(AUTOCONF_IPK_DIR)/opt/bin/*
	$(MAKE) $(AUTOCONF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOCONF_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(AUTOCONF_IPK_DIR)

autoconf-ipk: $(AUTOCONF_IPK)

autoconf-clean:
	-$(MAKE) -C $(AUTOCONF_BUILD_DIR) clean

autoconf-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOCONF_DIR) $(AUTOCONF_BUILD_DIR) $(AUTOCONF_IPK_DIR) $(AUTOCONF_IPK)

autoconf-check: $(AUTOCONF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
