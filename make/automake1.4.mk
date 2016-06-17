###########################################################
#
# automake1.4
#
###########################################################

AUTOMAKE1.4_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE1.4_VERSION=1.4-p6
AUTOMAKE1.4_SOURCE=automake-$(AUTOMAKE1.4_VERSION).tar.gz
AUTOMAKE1.4_DIR=automake-$(AUTOMAKE1.4_VERSION)
AUTOMAKE1.4_UNZIP=zcat
AUTOMAKE1.4_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE1.4_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE1.4_SECTION=util
AUTOMAKE1.4_PRIORITY=optional
AUTOMAKE1.4_DEPENDS=autoconf
AUTOMAKE1.4_CONFLICTS=

AUTOMAKE1.4_IPK_VERSION=3

AUTOMAKE1.4_BUILD_DIR=$(BUILD_DIR)/automake1.4
AUTOMAKE1.4_SOURCE_DIR=$(SOURCE_DIR)/automake1.4
AUTOMAKE1.4_IPK_DIR=$(BUILD_DIR)/automake1.4-$(AUTOMAKE1.4_VERSION)-ipk
AUTOMAKE1.4_IPK=$(BUILD_DIR)/automake1.4_$(AUTOMAKE1.4_VERSION)-$(AUTOMAKE1.4_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE1.4_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake1.4

.PHONY: automake1.4-source automake1.4-unpack automake1.4 automake1.4-stage automake1.4-ipk automake1.4-clean automake1.4-dirclean automake1.4-check automake1.4-host automake1.4-host-stage automake1.4-host-tool

$(DL_DIR)/$(AUTOMAKE1.4_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE1.4_SITE)/$(AUTOMAKE1.4_SOURCE)

automake1.4-source: $(DL_DIR)/$(AUTOMAKE1.4_SOURCE) $(AUTOMAKE1.4_PATCHES)


$(AUTOMAKE1.4_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE1.4_SOURCE) make/automake1.4.mk
	$(MAKE) autoconf-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE1.4_DIR) $(@D)
	$(AUTOMAKE1.4_UNZIP) $(DL_DIR)/$(AUTOMAKE1.4_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE1.4_DIR) $(@D)
	(cd $(@D); \
		AUTOCONF="$(HOST_STAGING_PREFIX)/bin/autoconf" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
	)
	$(MAKE) -C $(@D)
	touch $@

automake1.4-host: $(AUTOMAKE1.4_HOST_BUILD_DIR)/.built


$(AUTOMAKE1.4_HOST_BUILD_DIR)/.staged: $(AUTOMAKE1.4_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake1.4-host-stage: $(AUTOMAKE1.4_HOST_BUILD_DIR)/.staged


$(AUTOMAKE1.4_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE1.4_SOURCE) $(AUTOMAKE1.4_PATCHES) make/automake1.4.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.4_DIR) $(AUTOMAKE1.4_BUILD_DIR)
	$(AUTOMAKE1.4_UNZIP) $(DL_DIR)/$(AUTOMAKE1.4_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(AUTOMAKE1.4_DIR) $(AUTOMAKE1.4_BUILD_DIR)
	(cd $(AUTOMAKE1.4_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE1.4_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE1.4_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $@

automake1.4-unpack: $(AUTOMAKE1.4_BUILD_DIR)/.configured

$(AUTOMAKE1.4_BUILD_DIR)/.built: $(AUTOMAKE1.4_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.4_BUILD_DIR)
	touch $@

automake1.4: $(AUTOMAKE1.4_BUILD_DIR)/.built

$(AUTOMAKE1.4_BUILD_DIR)/.staged: $(AUTOMAKE1.4_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.4_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake1.4-stage: $(AUTOMAKE1.4_BUILD_DIR)/.staged

$(AUTOMAKE1.4_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: automake1.4" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE1.4_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE1.4_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE1.4_VERSION)-$(AUTOMAKE1.4_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE1.4_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE1.4_SITE)/$(AUTOMAKE1.4_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE1.4_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE1.4_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE1.4_CONFLICTS)" >>$@

$(AUTOMAKE1.4_IPK): $(AUTOMAKE1.4_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE1.4_IPK_DIR) $(BUILD_DIR)/automake1.4_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/info
	$(INSTALL) -d $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/share/aclocal-1.4
	$(INSTALL) -d $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.4/Automake
	$(INSTALL) -d $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.4/am
	$(MAKE) -C $(AUTOMAKE1.4_BUILD_DIR) DESTDIR=$(AUTOMAKE1.4_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|$(TARGET_PREFIX)/bin/perl|g' -e 's|$(HOST_STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		$(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(MAKE) $(AUTOMAKE1.4_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/info/dir
	rm -f $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/bin/automake $(AUTOMAKE1.4_IPK_DIR)$(TARGET_PREFIX)/bin/aclocal
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/aclocal' 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.4 20" > \
		$(AUTOMAKE1.4_IPK_DIR)/CONTROL/postinst
	echo -e "update-alternatives --install '$(TARGET_PREFIX)/bin/automake' 'automake' $(TARGET_PREFIX)/bin/automake-1.4 20" >> \
		$(AUTOMAKE1.4_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.4" > \
		$(AUTOMAKE1.4_IPK_DIR)/CONTROL/prerm
	echo -e "update-alternatives --remove 'automake' $(TARGET_PREFIX)/bin/automake-1.4" >> \
		$(AUTOMAKE1.4_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(AUTOMAKE1.4_IPK_DIR)/CONTROL/postinst $(AUTOMAKE1.4_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(AUTOMAKE1.4_IPK_DIR)/CONTROL/postinst
	chmod 755 $(AUTOMAKE1.4_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE1.4_IPK_DIR)

automake1.4-ipk: $(AUTOMAKE1.4_IPK)

automake1.4-clean:
	-$(MAKE) -C $(AUTOMAKE1.4_BUILD_DIR) clean

automake1.4-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.4_DIR) $(AUTOMAKE1.4_BUILD_DIR) $(AUTOMAKE1.4_IPK_DIR) $(AUTOMAKE1.4_IPK)

#
# Some sanity check for the package.
#
automake1.4-check: $(AUTOMAKE1.4_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
