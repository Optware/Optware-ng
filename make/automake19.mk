###########################################################
#
# automake19
#
###########################################################

AUTOMAKE19_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE19_VERSION=1.9.6
AUTOMAKE19_SOURCE=automake-$(AUTOMAKE19_VERSION).tar.bz2
AUTOMAKE19_DIR=automake-$(AUTOMAKE19_VERSION)
AUTOMAKE19_UNZIP=bzcat
AUTOMAKE19_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE19_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE19_SECTION=util
AUTOMAKE19_PRIORITY=optional
AUTOMAKE19_DEPENDS=autoconf
AUTOMAKE19_CONFLICTS=

AUTOMAKE19_IPK_VERSION=1

AUTOMAKE19_BUILD_DIR=$(BUILD_DIR)/automake19
AUTOMAKE19_SOURCE_DIR=$(SOURCE_DIR)/automake19
AUTOMAKE19_IPK_DIR=$(BUILD_DIR)/automake19-$(AUTOMAKE19_VERSION)-ipk
AUTOMAKE19_IPK=$(BUILD_DIR)/automake19_$(AUTOMAKE19_VERSION)-$(AUTOMAKE19_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE19_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake19

.PHONY: automake19-source automake19-unpack automake19 automake19-stage automake19-ipk automake19-clean automake19-dirclean automake19-check automake19-host automake19-host-stage automake19-host-tool

$(DL_DIR)/$(AUTOMAKE19_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE19_SITE)/$(AUTOMAKE19_SOURCE)

automake19-source: $(DL_DIR)/$(AUTOMAKE19_SOURCE) $(AUTOMAKE19_PATCHES)


$(AUTOMAKE19_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE19_SOURCE) make/automake19.mk
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE19_DIR) $(@D)
	$(AUTOMAKE19_UNZIP) $(DL_DIR)/$(AUTOMAKE19_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE19_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--datarootdir=$(HOST_STAGING_PREFIX)/share \
	)
	$(MAKE) -C $(@D)
	touch $@

automake19-host: $(AUTOMAKE19_HOST_BUILD_DIR)/.built


$(AUTOMAKE19_HOST_BUILD_DIR)/.staged: $(AUTOMAKE19_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal
	rm -f $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake19-host-stage: $(AUTOMAKE19_HOST_BUILD_DIR)/.staged


$(AUTOMAKE19_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE19_SOURCE) $(AUTOMAKE19_PATCHES) make/automake19.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE19_DIR) $(AUTOMAKE19_BUILD_DIR)
	$(AUTOMAKE19_UNZIP) $(DL_DIR)/$(AUTOMAKE19_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(AUTOMAKE19_DIR) $(AUTOMAKE19_BUILD_DIR)
	(cd $(AUTOMAKE19_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE19_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE19_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

automake19-unpack: $(AUTOMAKE19_BUILD_DIR)/.configured

$(AUTOMAKE19_BUILD_DIR)/.built: $(AUTOMAKE19_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE19_BUILD_DIR)
	touch $@

automake19: $(AUTOMAKE19_BUILD_DIR)/.built

$(AUTOMAKE19_BUILD_DIR)/.staged: $(AUTOMAKE19_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE19_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake19-stage: $(AUTOMAKE19_BUILD_DIR)/.staged

$(AUTOMAKE19_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: automake19" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE19_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE19_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE19_VERSION)-$(AUTOMAKE19_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE19_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE19_SITE)/$(AUTOMAKE19_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE19_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE19_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE19_CONFLICTS)" >>$@

$(AUTOMAKE19_IPK): $(AUTOMAKE19_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE19_IPK_DIR) $(BUILD_DIR)/automake19_*_$(TARGET_ARCH).ipk
	install -d $(AUTOMAKE19_IPK_DIR)/opt/bin
	install -d $(AUTOMAKE19_IPK_DIR)/opt/info
	install -d $(AUTOMAKE19_IPK_DIR)/opt/share/aclocal-1.9
	install -d $(AUTOMAKE19_IPK_DIR)/opt/share/automake-1.9/Automake
	install -d $(AUTOMAKE19_IPK_DIR)/opt/share/automake-1.9/am
	$(MAKE) -C $(AUTOMAKE19_BUILD_DIR) DESTDIR=$(AUTOMAKE19_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|/opt/bin/perl|g' $(AUTOMAKE19_IPK_DIR)/opt/bin/*
	$(MAKE) $(AUTOMAKE19_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE19_IPK_DIR)/opt/info/dir
	(cd $(AUTOMAKE19_IPK_DIR)/opt/bin; \
		rm automake aclocal; \
		ln -s automake-1.9 automake; \
		ln -s aclocal-1.9 aclocal; \
	)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE19_IPK_DIR)

automake19-ipk: $(AUTOMAKE19_IPK)

automake19-clean:
	-$(MAKE) -C $(AUTOMAKE19_BUILD_DIR) clean

automake19-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE19_DIR) $(AUTOMAKE19_BUILD_DIR) $(AUTOMAKE19_IPK_DIR) $(AUTOMAKE19_IPK)

#
# Some sanity check for the package.
#
automake19-check: $(AUTOMAKE19_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AUTOMAKE19_IPK)
