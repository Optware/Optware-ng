###########################################################
#
# automake1.10
#
###########################################################

AUTOMAKE1.10_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE1.10_VERSION=1.10.3
AUTOMAKE1.10_SOURCE=automake-$(AUTOMAKE1.10_VERSION).tar.bz2
AUTOMAKE1.10_DIR=automake-$(AUTOMAKE1.10_VERSION)
AUTOMAKE1.10_UNZIP=bzcat
AUTOMAKE1.10_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE1.10_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE1.10_SECTION=util
AUTOMAKE1.10_PRIORITY=optional
AUTOMAKE1.10_DEPENDS=autoconf
AUTOMAKE1.10_CONFLICTS=

AUTOMAKE1.10_IPK_VERSION=4

AUTOMAKE1.10_BUILD_DIR=$(BUILD_DIR)/automake1.10
AUTOMAKE1.10_SOURCE_DIR=$(SOURCE_DIR)/automake1.10
AUTOMAKE1.10_IPK_DIR=$(BUILD_DIR)/automake1.10-$(AUTOMAKE1.10_VERSION)-ipk
AUTOMAKE1.10_IPK=$(BUILD_DIR)/automake1.10_$(AUTOMAKE1.10_VERSION)-$(AUTOMAKE1.10_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE1.10_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake1.10

.PHONY: automake1.10-source automake1.10-unpack automake1.10 automake1.10-stage automake1.10-ipk automake1.10-clean automake1.10-dirclean automake1.10-check automake1.10-host automake1.10-host-stage automake1.10-host-tool

$(DL_DIR)/$(AUTOMAKE1.10_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE1.10_SITE)/$(AUTOMAKE1.10_SOURCE)

AUTOMAKE1.10_PATCHES=\
$(AUTOMAKE1.10_SOURCE_DIR)/automake-escape_left_brace.patch \

automake1.10-source: $(DL_DIR)/$(AUTOMAKE1.10_SOURCE) $(AUTOMAKE1.10_PATCHES)


$(AUTOMAKE1.10_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE1.10_SOURCE) make/automake1.10.mk
	$(MAKE) autoconf-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE1.10_DIR) $(@D)
	$(AUTOMAKE1.10_UNZIP) $(DL_DIR)/$(AUTOMAKE1.10_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(AUTOMAKE1.10_PATCHES)" ; \
		then cat $(AUTOMAKE1.10_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(AUTOMAKE1.10_DIR) -p1 ; \
	fi
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE1.10_DIR) $(@D)
	(cd $(@D); \
		AUTOCONF="$(HOST_STAGING_PREFIX)/bin/autoconf" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--datarootdir=$(HOST_STAGING_PREFIX)/share \
	)
	$(MAKE) -C $(@D)
	touch $@

automake1.10-host: $(AUTOMAKE1.10_HOST_BUILD_DIR)/.built


$(AUTOMAKE1.10_HOST_BUILD_DIR)/.staged: $(AUTOMAKE1.10_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake1.10-host-stage: $(AUTOMAKE1.10_HOST_BUILD_DIR)/.staged


$(AUTOMAKE1.10_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE1.10_SOURCE) $(AUTOMAKE1.10_PATCHES) make/automake1.10.mk
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.10_DIR) $(AUTOMAKE1.10_BUILD_DIR)
	$(AUTOMAKE1.10_UNZIP) $(DL_DIR)/$(AUTOMAKE1.10_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AUTOMAKE1.10_PATCHES)" ; \
		then cat $(AUTOMAKE1.10_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(AUTOMAKE1.10_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(AUTOMAKE1.10_DIR) $(AUTOMAKE1.10_BUILD_DIR)
	(cd $(AUTOMAKE1.10_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE1.10_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE1.10_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $@

automake1.10-unpack: $(AUTOMAKE1.10_BUILD_DIR)/.configured

$(AUTOMAKE1.10_BUILD_DIR)/.built: $(AUTOMAKE1.10_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.10_BUILD_DIR)
	touch $@

automake1.10: $(AUTOMAKE1.10_BUILD_DIR)/.built

$(AUTOMAKE1.10_BUILD_DIR)/.staged: $(AUTOMAKE1.10_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOMAKE1.10_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

automake1.10-stage: $(AUTOMAKE1.10_BUILD_DIR)/.staged

$(AUTOMAKE1.10_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: automake1.10" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOMAKE1.10_PRIORITY)" >>$@
	@echo "Section: $(AUTOMAKE1.10_SECTION)" >>$@
	@echo "Version: $(AUTOMAKE1.10_VERSION)-$(AUTOMAKE1.10_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOMAKE1.10_MAINTAINER)" >>$@
	@echo "Source: $(AUTOMAKE1.10_SITE)/$(AUTOMAKE1.10_SOURCE)" >>$@
	@echo "Description: $(AUTOMAKE1.10_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOMAKE1.10_DEPENDS)" >>$@
	@echo "Conflicts: $(AUTOMAKE1.10_CONFLICTS)" >>$@

$(AUTOMAKE1.10_IPK): $(AUTOMAKE1.10_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE1.10_IPK_DIR) $(BUILD_DIR)/automake1.10_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/info
	$(INSTALL) -d $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/share/aclocal-1.10
	$(INSTALL) -d $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.10/Automake
	$(INSTALL) -d $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/share/automake-1.10/am
	$(MAKE) -C $(AUTOMAKE1.10_BUILD_DIR) DESTDIR=$(AUTOMAKE1.10_IPK_DIR) install
	sed -i -e 's|/usr/bin/perl|$(TARGET_PREFIX)/bin/perl|g' -e 's|$(HOST_STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		$(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(MAKE) $(AUTOMAKE1.10_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/info/dir
	rm -f $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/bin/automake $(AUTOMAKE1.10_IPK_DIR)$(TARGET_PREFIX)/bin/aclocal
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/aclocal' 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.10 30" > \
		$(AUTOMAKE1.10_IPK_DIR)/CONTROL/postinst
	echo -e "update-alternatives --install '$(TARGET_PREFIX)/bin/automake' 'automake' $(TARGET_PREFIX)/bin/automake-1.10 30" >> \
		$(AUTOMAKE1.10_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'aclocal' $(TARGET_PREFIX)/bin/aclocal-1.10" > \
		$(AUTOMAKE1.10_IPK_DIR)/CONTROL/prerm
	echo -e "update-alternatives --remove 'automake' $(TARGET_PREFIX)/bin/automake-1.10" >> \
		$(AUTOMAKE1.10_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(AUTOMAKE1.10_IPK_DIR)/CONTROL/postinst $(AUTOMAKE1.10_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(AUTOMAKE1.10_IPK_DIR)/CONTROL/postinst
	chmod 755 $(AUTOMAKE1.10_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE1.10_IPK_DIR)

automake1.10-ipk: $(AUTOMAKE1.10_IPK)

automake1.10-clean:
	-$(MAKE) -C $(AUTOMAKE1.10_BUILD_DIR) clean

automake1.10-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE1.10_DIR) $(AUTOMAKE1.10_BUILD_DIR) $(AUTOMAKE1.10_IPK_DIR) $(AUTOMAKE1.10_IPK)

#
# Some sanity check for the package.
#
automake1.10-check: $(AUTOMAKE1.10_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
