###########################################################
#
# automake14
#
###########################################################

AUTOMAKE14_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE14_VERSION=1.4-p6
AUTOMAKE14_SOURCE=automake-$(AUTOMAKE14_VERSION).tar.gz
AUTOMAKE14_DIR=automake-$(AUTOMAKE14_VERSION)
AUTOMAKE14_UNZIP=zcat
AUTOMAKE14_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE14_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE14_SECTION=util
AUTOMAKE14_PRIORITY=optional
AUTOMAKE14_DEPENDS=autoconf
AUTOMAKE14_CONFLICTS=

AUTOMAKE14_IPK_VERSION=1

AUTOMAKE14_BUILD_DIR=$(BUILD_DIR)/automake14
AUTOMAKE14_SOURCE_DIR=$(SOURCE_DIR)/automake14
AUTOMAKE14_IPK_DIR=$(BUILD_DIR)/automake14-$(AUTOMAKE14_VERSION)-ipk
AUTOMAKE14_IPK=$(BUILD_DIR)/automake14_$(AUTOMAKE14_VERSION)-$(AUTOMAKE14_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE14_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake14

.PHONY: automake14-source automake14-unpack automake14 automake14-stage automake14-ipk automake14-clean automake14-dirclean automake14-check automake14-host automake14-host-stage automake14-host-tool

$(DL_DIR)/$(AUTOMAKE14_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE14_SITE)/$(AUTOMAKE14_SOURCE)

automake14-source: $(DL_DIR)/$(AUTOMAKE14_SOURCE) $(AUTOMAKE14_PATCHES)


$(AUTOMAKE14_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE14_SOURCE) make/automake14.mk
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE14_DIR) $(@D)
	$(AUTOMAKE14_UNZIP) $(DL_DIR)/$(AUTOMAKE14_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE14_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
	)
	$(MAKE) -C $(@D)
	touch $@

automake14-host: $(AUTOMAKE14_HOST_BUILD_DIR)/.built


$(AUTOMAKE14_HOST_BUILD_DIR)/.staged: $(AUTOMAKE14_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal
	rm -f $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake14-host-stage: $(AUTOMAKE14_HOST_BUILD_DIR)/.staged


$(AUTOMAKE14_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE14_SOURCE) $(AUTOMAKE14_PATCHES) make/automake14.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE14_DIR) $(AUTOMAKE14_BUILD_DIR)
	$(AUTOMAKE14_UNZIP) $(DL_DIR)/$(AUTOMAKE14_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(AUTOMAKE14_DIR) $(AUTOMAKE14_BUILD_DIR)
	(cd $(AUTOMAKE14_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE14_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE14_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

automake14-unpack: $(AUTOMAKE14_BUILD_DIR)/.configured

$(AUTOMAKE14_BUILD_DIR)/.built: $(AUTOMAKE14_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE14_BUILD_DIR)
	touch $@

automake14: $(AUTOMAKE14_BUILD_DIR)/.built

$(AUTOMAKE14_BUILD_DIR)/.staged: $(AUTOMAKE14_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE14_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake14-stage: $(AUTOMAKE14_BUILD_DIR)/.staged

$(AUTOMAKE14_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: automake14" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE14_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE14_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE14_VERSION)-$(AUTOMAKE14_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE14_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE14_SITE)/$(AUTOMAKE14_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE14_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE14_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE14_CONFLICTS)" >>$@

$(AUTOMAKE14_IPK): $(AUTOMAKE14_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE14_IPK_DIR) $(BUILD_DIR)/automake14_*_$(TARGET_ARCH).ipk
	install -d $(AUTOMAKE14_IPK_DIR)/opt/bin
	install -d $(AUTOMAKE14_IPK_DIR)/opt/info
	install -d $(AUTOMAKE14_IPK_DIR)/opt/share/aclocal-1.4
	install -d $(AUTOMAKE14_IPK_DIR)/opt/share/automake-1.4/Automake
	install -d $(AUTOMAKE14_IPK_DIR)/opt/share/automake-1.4/am
	$(MAKE) -C $(AUTOMAKE14_BUILD_DIR) DESTDIR=$(AUTOMAKE14_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|/opt/bin/perl|g' $(AUTOMAKE14_IPK_DIR)/opt/bin/*
	$(MAKE) $(AUTOMAKE14_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE14_IPK_DIR)/opt/info/dir
	(cd $(AUTOMAKE14_IPK_DIR)/opt/bin; \
		rm automake aclocal; \
		ln -s automake-1.4 automake; \
		ln -s aclocal-1.4 aclocal; \
	)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE14_IPK_DIR)

automake14-ipk: $(AUTOMAKE14_IPK)

automake14-clean:
	-$(MAKE) -C $(AUTOMAKE14_BUILD_DIR) clean

automake14-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE14_DIR) $(AUTOMAKE14_BUILD_DIR) $(AUTOMAKE14_IPK_DIR) $(AUTOMAKE14_IPK)

#
# Some sanity check for the package.
#
automake14-check: $(AUTOMAKE14_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AUTOMAKE14_IPK)
