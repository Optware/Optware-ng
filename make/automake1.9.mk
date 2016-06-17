###########################################################
#
# automake1.9
#
###########################################################

AUTOMAKE1.9_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE1.9_VERSION=1.9.6
AUTOMAKE1.9_SOURCE=automake-$(AUTOMAKE1.9_VERSION).tar.bz2
AUTOMAKE1.9_DIR=automake-$(AUTOMAKE1.9_VERSION)
AUTOMAKE1.9_UNZIP=bzcat
AUTOMAKE1.9_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE1.9_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE1.9_SECTION=util
AUTOMAKE1.9_PRIORITY=optional
AUTOMAKE1.9_DEPENDS=autoconf
AUTOMAKE1.9_CONFLICTS=

AUTOMAKE1.9_IPK_VERSION=3

AUTOMAKE1.9_BUILD_DIR=$(BUILD_DIR)/automake1.9
AUTOMAKE1.9_SOURCE_DIR=$(SOURCE_DIR)/automake1.9
AUTOMAKE1.9_IPK_DIR=$(BUILD_DIR)/automake1.9-$(AUTOMAKE1.9_VERSION)-ipk
AUTOMAKE1.9_IPK=$(BUILD_DIR)/automake1.9_$(AUTOMAKE1.9_VERSION)-$(AUTOMAKE1.9_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE1.9_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake1.9

.PHONY: automake1.9-source automake1.9-unpack automake1.9 automake1.9-stage automake1.9-ipk automake1.9-clean automake1.9-dirclean automake1.9-check automake1.9-host automake1.9-host-stage automake1.9-host-tool

$(DL_DIR)/$(AUTOMAKE1.9_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE1.9_SITE)/$(AUTOMAKE1.9_SOURCE)

automake1.9-source: $(DL_DIR)/$(AUTOMAKE1.9_SOURCE) $(AUTOMAKE1.9_PATCHES)


$(AUTOMAKE1.9_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE1.9_SOURCE) make/automake1.9.mk
	$(MAKE) autoconf-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE1.9_DIR) $(@D)
	$(AUTOMAKE1.9_UNZIP) $(DL_DIR)/$(AUTOMAKE1.9_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE1.9_DIR) $(@D)
	(cd $(@D); \
		AUTOCONF="$(HOST_STAGING_PREFIX)/bin/autoconf" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--datarootdir=$(HOST_STAGING_PREFIX)/share \
	)
	$(MAKE) -C $(@D)
	touch $@

automake1.9-host: $(AUTOMAKE1.9_HOST_BUILD_DIR)/.built


$(AUTOMAKE1.9_HOST_BUILD_DIR)/.staged: $(AUTOMAKE1.9_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake1.9-host-stage: $(AUTOMAKE1.9_HOST_BUILD_DIR)/.staged


$(AUTOMAKE1.9_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE1.9_SOURCE) $(AUTOMAKE1.9_PATCHES) make/automake1.9.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.9_DIR) $(AUTOMAKE1.9_BUILD_DIR)
	$(AUTOMAKE1.9_UNZIP) $(DL_DIR)/$(AUTOMAKE1.9_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(AUTOMAKE1.9_DIR) $(AUTOMAKE1.9_BUILD_DIR)
	(cd $(AUTOMAKE1.9_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE1.9_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE1.9_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $@

automake1.9-unpack: $(AUTOMAKE1.9_BUILD_DIR)/.configured

$(AUTOMAKE1.9_BUILD_DIR)/.built: $(AUTOMAKE1.9_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.9_BUILD_DIR)
	touch $@

automake1.9: $(AUTOMAKE1.9_BUILD_DIR)/.built

$(AUTOMAKE1.9_BUILD_DIR)/.staged: $(AUTOMAKE1.9_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.9_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake1.9-stage: $(AUTOMAKE1.9_BUILD_DIR)/.staged

$(AUTOMAKE1.9_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: automake1.9" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE1.9_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE1.9_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE1.9_VERSION)-$(AUTOMAKE1.9_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE1.9_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE1.9_SITE)/$(AUTOMAKE1.9_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE1.9_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE1.9_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE1.9_CONFLICTS)" >>$@

$(AUTOMAKE1.9_IPK): $(AUTOMAKE1.9_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE1.9_IPK_DIR) $(BUILD_DIR)/automake1.9_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/info
	$(INSTALL) -d $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/share/aclocal-1.9
	$(INSTALL) -d $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.9/Automake
	$(INSTALL) -d $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.9/am
	$(MAKE) -C $(AUTOMAKE1.9_BUILD_DIR) DESTDIR=$(AUTOMAKE1.9_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|$(TARGET_PREFIX)/bin/perl|g' -e 's|$(HOST_STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		$(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(MAKE) $(AUTOMAKE1.9_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/info/dir
	rm -f $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/bin/automake $(AUTOMAKE1.9_IPK_DIR)$(TARGET_PREFIX)/bin/aclocal
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/aclocal' 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.9 25" > \
		$(AUTOMAKE1.9_IPK_DIR)/CONTROL/postinst
	echo -e "update-alternatives --install '$(TARGET_PREFIX)/bin/automake' 'automake' $(TARGET_PREFIX)/bin/automake-1.9 25" >> \
		$(AUTOMAKE1.9_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.9" > \
		$(AUTOMAKE1.9_IPK_DIR)/CONTROL/prerm
	echo -e "update-alternatives --remove 'automake' $(TARGET_PREFIX)/bin/automake-1.9" >> \
		$(AUTOMAKE1.9_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(AUTOMAKE1.9_IPK_DIR)/CONTROL/postinst $(AUTOMAKE1.9_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(AUTOMAKE1.9_IPK_DIR)/CONTROL/postinst
	chmod 755 $(AUTOMAKE1.9_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE1.9_IPK_DIR)

automake1.9-ipk: $(AUTOMAKE1.9_IPK)

automake1.9-clean:
	-$(MAKE) -C $(AUTOMAKE1.9_BUILD_DIR) clean

automake1.9-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.9_DIR) $(AUTOMAKE1.9_BUILD_DIR) $(AUTOMAKE1.9_IPK_DIR) $(AUTOMAKE1.9_IPK)

#
# Some sanity check for the package.
#
automake1.9-check: $(AUTOMAKE1.9_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
