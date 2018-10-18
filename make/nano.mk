###########################################################
#
# nano
#
###########################################################

NANO_SITE=http://www.nano-editor.org/dist/v3
NANO_VERSION=3.1
NANO_SOURCE=nano-$(NANO_VERSION).tar.xz
NANO_DIR=nano-$(NANO_VERSION)
NANO_UNZIP=xzcat
NANO_MAINTAINER=Mark Donszelmann <mark@donszelmann.com>
NANO_DESCRIPTION=A pico like editor
NANO_SECTION=editor
NANO_PRIORITY=optional
NANO_DEPENDS=ncursesw, zlib, file
NANO_CONFLICTS=

NANO_IPK_VERSION=1

#NANO_CONFFILES=$(TARGET_PREFIX)/etc/nanorc

#NANO_PATCHES=$(NANO_SOURCE_DIR)/broken_regex.patch

NANO_CPPFLAGS=
NANO_LDFLAGS=

NANO_BUILD_DIR=$(BUILD_DIR)/nano
NANO_SOURCE_DIR=$(SOURCE_DIR)/nano
NANO_IPK_DIR=$(BUILD_DIR)/nano-$(NANO_VERSION)-ipk
NANO_IPK=$(BUILD_DIR)/nano_$(NANO_VERSION)-$(NANO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nano-source nano-unpack nano nano-stage nano-ipk nano-clean nano-dirclean nano-check

$(DL_DIR)/$(NANO_SOURCE):
	$(WGET) -P $(@D) $(NANO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

nano-source: $(DL_DIR)/$(NANO_SOURCE) $(NANO_PATCHES)

$(NANO_BUILD_DIR)/.configured: $(DL_DIR)/$(NANO_SOURCE) $(NANO_PATCHES) make/nano.mk
	$(MAKE) ncursesw-stage zlib-stage file-stage
	rm -rf $(BUILD_DIR)/$(NANO_DIR) $(@D)
	$(NANO_UNZIP) $(DL_DIR)/$(NANO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NANO_PATCHES)"; \
		then cat $(NANO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(NANO_DIR); \
	fi
	mv $(BUILD_DIR)/$(NANO_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NANO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NANO_LDFLAGS)" \
		ac_cv_prog_NCURSESW_CONFIG=$(STAGING_PREFIX)/bin/ncursesw5-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--without-libiconv-prefix \
		--enable-utf8 \
		--disable-nls \
	)
	touch $@

nano-unpack: $(NANO_BUILD_DIR)/.configured

$(NANO_BUILD_DIR)/.built: $(NANO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

nano: $(NANO_BUILD_DIR)/.built

$(NANO_BUILD_DIR)/.staged: $(NANO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

nano-stage: $(NANO_BUILD_DIR)/.staged

$(NANO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: nano" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NANO_PRIORITY)" >>$@
	@echo "Section: $(NANO_SECTION)" >>$@
	@echo "Version: $(NANO_VERSION)-$(NANO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NANO_MAINTAINER)" >>$@
	@echo "Source: $(NANO_SITE)/$(NANO_SOURCE)" >>$@
	@echo "Description: $(NANO_DESCRIPTION)" >>$@
	@echo "Depends: $(NANO_DEPENDS)" >>$@
	@echo "Conflicts: $(NANO_CONFLICTS)" >>$@

$(NANO_IPK): $(NANO_BUILD_DIR)/.built
	rm -rf $(NANO_IPK_DIR) $(BUILD_DIR)/nano_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NANO_BUILD_DIR) DESTDIR=$(NANO_IPK_DIR) program_transform_name="" install-strip
	$(INSTALL) -d $(NANO_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 644 $(NANO_BUILD_DIR)/doc/sample.nanorc $(NANO_IPK_DIR)$(TARGET_PREFIX)/etc/nanorc
	rm -f $(NANO_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	$(MAKE) $(NANO_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(NANO_SOURCE_DIR)/postinst $(NANO_IPK_DIR)/CONTROL/postinst
	echo $(NANO_CONFFILES) | sed -e 's/ /\n/g' > $(NANO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NANO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NANO_IPK_DIR)

nano-ipk: $(NANO_IPK)

nano-clean:
	-$(MAKE) -C $(NANO_BUILD_DIR) clean

nano-dirclean:
	rm -rf $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR) $(NANO_IPK_DIR) $(NANO_IPK)

#
# Some sanity check for the package.
#
nano-check: $(NANO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
