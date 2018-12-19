###########################################################
#
# automake
#
###########################################################

AUTOMAKE_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE_VERSION=1.15
AUTOMAKE_VER=1.15
AUTOMAKE_SOURCE=automake-$(AUTOMAKE_VERSION).tar.xz
AUTOMAKE_DIR=automake-$(AUTOMAKE_VERSION)
AUTOMAKE_UNZIP=xzcat
AUTOMAKE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOMAKE_DESCRIPTION=Creates GNU standards-compliant Makefiles from template files
AUTOMAKE_SECTION=util
AUTOMAKE_PRIORITY=optional
AUTOMAKE_DEPENDS=autoconf
AUTOMAKE_CONFLICTS=

AUTOMAKE_IPK_VERSION=5

AUTOMAKE_BUILD_DIR=$(BUILD_DIR)/automake
AUTOMAKE_SOURCE_DIR=$(SOURCE_DIR)/automake
AUTOMAKE_IPK_DIR=$(BUILD_DIR)/automake-$(AUTOMAKE_VERSION)-ipk
AUTOMAKE_IPK=$(BUILD_DIR)/automake_$(AUTOMAKE_VERSION)-$(AUTOMAKE_IPK_VERSION)_$(TARGET_ARCH).ipk

AUTOMAKE_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/automake

.PHONY: automake-source automake-unpack automake automake-stage automake-ipk automake-clean automake-dirclean automake-check

$(DL_DIR)/$(AUTOMAKE_SOURCE):
	$(WGET) -P $(@D) $(AUTOMAKE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

AUTOMAKE_PATCHES=\
$(AUTOMAKE_SOURCE_DIR)/automake-escape_left_brace.patch \

automake-source: $(DL_DIR)/$(AUTOMAKE_SOURCE) $(AUTOMAKE_PATCHES)

$(AUTOMAKE_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(AUTOMAKE_SOURCE) make/automake.mk
	$(MAKE) xz-utils-host-stage autoconf-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(AUTOMAKE_DIR) $(@D)
	$(AUTOMAKE_UNZIP) $(DL_DIR)/$(AUTOMAKE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(AUTOMAKE_PATCHES)" ; \
		then cat $(AUTOMAKE_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(AUTOMAKE_DIR) -p1 ; \
	fi
	mv $(HOST_BUILD_DIR)/$(AUTOMAKE_DIR) $(@D)
	(cd $(@D); \
		AUTOCONF="$(HOST_STAGING_PREFIX)/bin/autoconf" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--datarootdir=$(HOST_STAGING_PREFIX)/share \
	)
	$(MAKE) -C $(@D)
	touch $@

automake-host: $(AUTOMAKE_HOST_BUILD_DIR)/.built

$(AUTOMAKE_HOST_BUILD_DIR)/.staged: $(AUTOMAKE_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	rm -f $(HOST_STAGING_PREFIX)/bin/aclocal $(HOST_STAGING_PREFIX)/bin/automake
	touch $@

automake-host-stage: $(AUTOMAKE_HOST_BUILD_DIR)/.staged

$(AUTOMAKE_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE_SOURCE) $(AUTOMAKE_PATCHES) make/automake.mk
	$(MAKE) xz-utils-host-stage autoconf-host-stage
	rm -rf $(BUILD_DIR)/$(AUTOMAKE_DIR) $(@D)
	$(AUTOMAKE_UNZIP) $(DL_DIR)/$(AUTOMAKE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AUTOMAKE_PATCHES)" ; \
		then cat $(AUTOMAKE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(AUTOMAKE_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(AUTOMAKE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE_LDFLAGS)" \
		AUTOCONF="$(HOST_STAGING_PREFIX)/bin/autoconf" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $@

automake-unpack: $(AUTOMAKE_BUILD_DIR)/.configured

$(AUTOMAKE_BUILD_DIR)/.built: $(AUTOMAKE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

automake: $(AUTOMAKE_BUILD_DIR)/.built

$(AUTOMAKE_BUILD_DIR)/.staged: $(AUTOMAKE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

automake-stage: $(AUTOMAKE_BUILD_DIR)/.staged

$(AUTOMAKE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
	$(INSTALL) -d $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/info
	$(INSTALL) -d $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/share/aclocal-$(AUTOMAKE_VER)
	$(INSTALL) -d $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/share/automake-$(AUTOMAKE_VER)/Automake
	$(INSTALL) -d $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/share/automake-$(AUTOMAKE_VER)/am
	$(MAKE) -C $(AUTOMAKE_BUILD_DIR) DESTDIR=$(AUTOMAKE_IPK_DIR) install
	rm -f $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	sed -i -e 's|/usr/bin/perl|$(TARGET_PREFIX)/bin/perl|g' -e 's|$(HOST_STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		$(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(MAKE) $(AUTOMAKE_IPK_DIR)/CONTROL/control
	rm -f $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/info/dir
	rm -f $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/bin/automake $(AUTOMAKE_IPK_DIR)$(TARGET_PREFIX)/bin/aclocal
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/aclocal' 'aclocal' $(TARGET_PREFIX)/bin/aclocal-$(AUTOMAKE_VER) 40" > \
		$(AUTOMAKE_IPK_DIR)/CONTROL/postinst
	echo -e "update-alternatives --install '$(TARGET_PREFIX)/bin/automake' 'automake' $(TARGET_PREFIX)/bin/automake-$(AUTOMAKE_VER) 40" >> \
		$(AUTOMAKE_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'aclocal' $(TARGET_PREFIX)/bin/aclocal-$(AUTOMAKE_VER)" > \
		$(AUTOMAKE_IPK_DIR)/CONTROL/prerm
	echo -e "update-alternatives --remove 'automake' $(TARGET_PREFIX)/bin/automake-$(AUTOMAKE_VER)" >> \
		$(AUTOMAKE_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(AUTOMAKE_IPK_DIR)/CONTROL/postinst $(AUTOMAKE_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(AUTOMAKE_IPK_DIR)/CONTROL/postinst
	chmod 755 $(AUTOMAKE_IPK_DIR)/CONTROL/prerm
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
