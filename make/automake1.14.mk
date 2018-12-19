###########################################################
#
# automake1.14
#
###########################################################

AUTOMAKE1.14_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE1.14_VERSION=1.14.1
AUTOMAKE1.14_SOURCE=automake-$(AUTOMAKE1.14_VERSION).tar.xz
AUTOMAKE1.14_DIR=automake-$(AUTOMAKE1.14_VERSION)
AUTOMAKE1.14_UNZIP=xzcat
AUTOMAKE1.14_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE1.14_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE1.14_SECTION=util
AUTOMAKE1.14_PRIORITY=optional
AUTOMAKE1.14_DEPENDS=autoconf
AUTOMAKE1.14_CONFLICTS=

AUTOMAKE1.14_IPK_VERSION=4

AUTOMAKE1.14_BUILD_DIR=$(BUILD_DIR)/automake1.14
AUTOMAKE1.14_SOURCE_DIR=$(SOURCE_DIR)/automake1.14
AUTOMAKE1.14_IPK_DIR=$(BUILD_DIR)/automake1.14-$(AUTOMAKE1.14_VERSION)-ipk
AUTOMAKE1.14_IPK=$(BUILD_DIR)/automake1.14_$(AUTOMAKE1.14_VERSION)-$(AUTOMAKE1.14_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE1.14_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake1.14

.PHONY: automake1.14-source automake1.14-unpack automake1.14 automake1.14-stage automake1.14-ipk automake1.14-clean automake1.14-dirclean automake1.14-check automake1.14-host automake1.14-host-stage automake1.14-host-tool

$(DL_DIR)/$(AUTOMAKE1.14_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE1.14_SITE)/$(AUTOMAKE1.14_SOURCE)

AUTOMAKE1.14_PATCHES=\
$(AUTOMAKE1.14_SOURCE_DIR)/automake-escape_left_brace.patch \

automake1.14-source: $(DL_DIR)/$(AUTOMAKE1.14_SOURCE) $(AUTOMAKE1.14_PATCHES)


$(AUTOMAKE1.14_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE1.14_SOURCE) make/automake1.14.mk
	$(MAKE) autoconf-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE1.14_DIR) $(@D)
	$(AUTOMAKE1.14_UNZIP) $(DL_DIR)/$(AUTOMAKE1.14_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(AUTOMAKE1.14_PATCHES)" ; \
		then cat $(AUTOMAKE1.14_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(AUTOMAKE1.14_DIR) -p1 ; \
	fi
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE1.14_DIR) $(@D)
	(cd $(@D); \
		AUTOCONF="$(HOST_STAGING_PREFIX)/bin/autoconf" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--datarootdir=$(HOST_STAGING_PREFIX)/share \
	)
	$(MAKE) -C $(@D)
	touch $@

automake1.14-host: $(AUTOMAKE1.14_HOST_BUILD_DIR)/.built


$(AUTOMAKE1.14_HOST_BUILD_DIR)/.staged: $(AUTOMAKE1.14_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake1.14-host-stage: $(AUTOMAKE1.14_HOST_BUILD_DIR)/.staged


$(AUTOMAKE1.14_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE1.14_SOURCE) $(AUTOMAKE1.14_PATCHES) make/automake1.14.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.14_DIR) $(AUTOMAKE1.14_BUILD_DIR)
	$(AUTOMAKE1.14_UNZIP) $(DL_DIR)/$(AUTOMAKE1.14_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AUTOMAKE1.14_PATCHES)" ; \
		then cat $(AUTOMAKE1.14_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(AUTOMAKE1.14_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(AUTOMAKE1.14_DIR) $(AUTOMAKE1.14_BUILD_DIR)
	(cd $(AUTOMAKE1.14_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE1.14_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE1.14_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $@

automake1.14-unpack: $(AUTOMAKE1.14_BUILD_DIR)/.configured

$(AUTOMAKE1.14_BUILD_DIR)/.built: $(AUTOMAKE1.14_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.14_BUILD_DIR)
	touch $@

automake1.14: $(AUTOMAKE1.14_BUILD_DIR)/.built

$(AUTOMAKE1.14_BUILD_DIR)/.staged: $(AUTOMAKE1.14_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.14_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake1.14-stage: $(AUTOMAKE1.14_BUILD_DIR)/.staged

$(AUTOMAKE1.14_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: automake1.14" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE1.14_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE1.14_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE1.14_VERSION)-$(AUTOMAKE1.14_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE1.14_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE1.14_SITE)/$(AUTOMAKE1.14_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE1.14_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE1.14_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE1.14_CONFLICTS)" >>$@

$(AUTOMAKE1.14_IPK): $(AUTOMAKE1.14_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE1.14_IPK_DIR) $(BUILD_DIR)/automake1.14_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/info
	$(INSTALL) -d $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/share/aclocal-1.14
	$(INSTALL) -d $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.14/Automake
	$(INSTALL) -d $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.14/am
	$(MAKE) -C $(AUTOMAKE1.14_BUILD_DIR) DESTDIR=$(AUTOMAKE1.14_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|$(TARGET_PREFIX)/bin/perl|g' -e 's|$(HOST_STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		$(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(MAKE) $(AUTOMAKE1.14_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/info/dir
	rm -f $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/bin/automake $(AUTOMAKE1.14_IPK_DIR)$(TARGET_PREFIX)/bin/aclocal
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/aclocal' 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.14 35" > \
		$(AUTOMAKE1.14_IPK_DIR)/CONTROL/postinst
	echo -e "update-alternatives --install '$(TARGET_PREFIX)/bin/automake' 'automake' $(TARGET_PREFIX)/bin/automake-1.14 35" >> \
		$(AUTOMAKE1.14_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.14" > \
		$(AUTOMAKE1.14_IPK_DIR)/CONTROL/prerm
	echo -e "update-alternatives --remove 'automake' $(TARGET_PREFIX)/bin/automake-1.14" >> \
		$(AUTOMAKE1.14_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(AUTOMAKE1.14_IPK_DIR)/CONTROL/postinst $(AUTOMAKE1.14_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(AUTOMAKE1.14_IPK_DIR)/CONTROL/postinst
	chmod 755 $(AUTOMAKE1.14_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE1.14_IPK_DIR)

automake1.14-ipk: $(AUTOMAKE1.14_IPK)

automake1.14-clean:
	-$(MAKE) -C $(AUTOMAKE1.14_BUILD_DIR) clean

automake1.14-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.14_DIR) $(AUTOMAKE1.14_BUILD_DIR) $(AUTOMAKE1.14_IPK_DIR) $(AUTOMAKE1.14_IPK)

#
# Some sanity check for the package.
#
automake1.14-check: $(AUTOMAKE1.14_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
