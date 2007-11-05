###########################################################
#
# automake
#
###########################################################

AUTOMAKE_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE_VERSION=1.10
AUTOMAKE_SOURCE=automake-$(AUTOMAKE_VERSION).tar.bz2
AUTOMAKE_DIR=automake-$(AUTOMAKE_VERSION)
AUTOMAKE_UNZIP=bzcat
AUTOMAKE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE_SECTION=util
AUTOMAKE_PRIORITY=optional
AUTOMAKE_DEPENDS=autoconf
AUTOMAKE_CONFLICTS=

AUTOMAKE_IPK_VERSION=2

AUTOMAKE_BUILD_DIR=$(BUILD_DIR)/automake
AUTOMAKE_SOURCE_DIR=$(SOURCE_DIR)/automake
AUTOMAKE_IPK_DIR=$(BUILD_DIR)/automake-$(AUTOMAKE_VERSION)-ipk
AUTOMAKE_IPK=$(BUILD_DIR)/automake_$(AUTOMAKE_VERSION)-$(AUTOMAKE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: automake-source automake-unpack automake automake-stage automake-ipk automake-clean automake-dirclean automake-check

$(DL_DIR)/$(AUTOMAKE_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE_SITE)/$(AUTOMAKE_SOURCE)

automake-source: $(DL_DIR)/$(AUTOMAKE_SOURCE) $(AUTOMAKE_PATCHES)

$(AUTOMAKE_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE_SOURCE) $(AUTOMAKE_PATCHES) make/automake.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE_DIR) $(AUTOMAKE_BUILD_DIR)
	$(AUTOMAKE_UNZIP) $(DL_DIR)/$(AUTOMAKE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(AUTOMAKE_DIR) $(AUTOMAKE_BUILD_DIR)
	(cd $(AUTOMAKE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

automake-unpack: $(AUTOMAKE_BUILD_DIR)/.configured

$(AUTOMAKE_BUILD_DIR)/.built: $(AUTOMAKE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE_BUILD_DIR)
	touch $@

automake: $(AUTOMAKE_BUILD_DIR)/.built

$(AUTOMAKE_BUILD_DIR)/.staged: $(AUTOMAKE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake-stage: $(AUTOMAKE_BUILD_DIR)/.staged

$(AUTOMAKE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: automake" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE_VERSION)-$(AUTOMAKE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE_SITE)/$(AUTOMAKE_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE_CONFLICTS)" >>$@

$(AUTOMAKE_IPK): $(AUTOMAKE_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE_IPK_DIR) $(BUILD_DIR)/automake_*_$(TARGET_ARCH).ipk
	install -d $(AUTOMAKE_IPK_DIR)/opt/bin
	install -d $(AUTOMAKE_IPK_DIR)/opt/info
	install -d $(AUTOMAKE_IPK_DIR)/opt/share/aclocal-1.10
	install -d $(AUTOMAKE_IPK_DIR)/opt/share/automake-1.10/Automake
	install -d $(AUTOMAKE_IPK_DIR)/opt/share/automake-1.10/am
	$(MAKE) -C $(AUTOMAKE_BUILD_DIR) DESTDIR=$(AUTOMAKE_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|/opt/bin/perl|g' $(AUTOMAKE_IPK_DIR)/opt/bin/*
	$(MAKE) $(AUTOMAKE_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE_IPK_DIR)/opt/info/dir
	(cd $(AUTOMAKE_IPK_DIR)/opt/bin; \
		rm automake aclocal; \
		ln -s automake-1.10 automake; \
		ln -s aclocal-1.10 aclocal; \
	)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE_IPK_DIR)

automake-ipk: $(AUTOMAKE_IPK)

automake-clean:
	-$(MAKE) -C $(AUTOMAKE_BUILD_DIR) clean

automake-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE_DIR) $(AUTOMAKE_BUILD_DIR) $(AUTOMAKE_IPK_DIR) $(AUTOMAKE_IPK)

#
# Some sanity check for the package.
#
automake-check: $(AUTOMAKE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AUTOMAKE_IPK)
