###########################################################
#
# perl-encode-locale
#
###########################################################

PERL-ENCODE-LOCALE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GA/GAAS
PERL-ENCODE-LOCALE_VERSION=1.05
PERL-ENCODE-LOCALE_SOURCE=Encode-Locale-$(PERL-ENCODE-LOCALE_VERSION).tar.gz
PERL-ENCODE-LOCALE_DIR=Encode-Locale-$(PERL-ENCODE-LOCALE_VERSION)
PERL-ENCODE-LOCALE_UNZIP=zcat
PERL-ENCODE-LOCALE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-ENCODE-LOCALE_DESCRIPTION=Determine the locale encoding
PERL-ENCODE-LOCALE_SECTION=util
PERL-ENCODE-LOCALE_PRIORITY=optional
PERL-ENCODE-LOCALE_DEPENDS=
PERL-ENCODE-LOCALE_SUGGESTS=
PERL-ENCODE-LOCALE_CONFLICTS=

PERL-ENCODE-LOCALE_IPK_VERSION=4

PERL-ENCODE-LOCALE_CONFFILES=

PERL-ENCODE-LOCALE_BUILD_DIR=$(BUILD_DIR)/perl-encode-locale
PERL-ENCODE-LOCALE_SOURCE_DIR=$(SOURCE_DIR)/perl-encode-locale
PERL-ENCODE-LOCALE_IPK_DIR=$(BUILD_DIR)/perl-encode-locale-$(PERL-ENCODE-LOCALE_VERSION)-ipk
PERL-ENCODE-LOCALE_IPK=$(BUILD_DIR)/perl-encode-locale_$(PERL-ENCODE-LOCALE_VERSION)-$(PERL-ENCODE-LOCALE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-ENCODE-LOCALE_SOURCE):
	$(WGET) -P $(@D) $(PERL-ENCODE-LOCALE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-encode-locale-source: $(DL_DIR)/$(PERL-ENCODE-LOCALE_SOURCE) $(PERL-ENCODE-LOCALE_PATCHES)

$(PERL-ENCODE-LOCALE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-ENCODE-LOCALE_SOURCE) $(PERL-ENCODE-LOCALE_PATCHES) make/perl-encode-locale.mk
	rm -rf $(BUILD_DIR)/$(PERL-ENCODE-LOCALE_DIR) $(PERL-ENCODE-LOCALE_BUILD_DIR)
	$(PERL-ENCODE-LOCALE_UNZIP) $(DL_DIR)/$(PERL-ENCODE-LOCALE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-ENCODE-LOCALE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-ENCODE-LOCALE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-ENCODE-LOCALE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-encode-locale-unpack: $(PERL-ENCODE-LOCALE_BUILD_DIR)/.configured

$(PERL-ENCODE-LOCALE_BUILD_DIR)/.built: $(PERL-ENCODE-LOCALE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-encode-locale: $(PERL-ENCODE-LOCALE_BUILD_DIR)/.built

$(PERL-ENCODE-LOCALE_BUILD_DIR)/.staged: $(PERL-ENCODE-LOCALE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-encode-locale-stage: $(PERL-ENCODE-LOCALE_BUILD_DIR)/.staged

$(PERL-ENCODE-LOCALE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-encode-locale" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-ENCODE-LOCALE_PRIORITY)" >>$@
	@echo "Section: $(PERL-ENCODE-LOCALE_SECTION)" >>$@
	@echo "Version: $(PERL-ENCODE-LOCALE_VERSION)-$(PERL-ENCODE-LOCALE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-ENCODE-LOCALE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-ENCODE-LOCALE_SITE)/$(PERL-ENCODE-LOCALE_SOURCE)" >>$@
	@echo "Description: $(PERL-ENCODE-LOCALE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-ENCODE-LOCALE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-ENCODE-LOCALE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-ENCODE-LOCALE_CONFLICTS)" >>$@

$(PERL-ENCODE-LOCALE_IPK): $(PERL-ENCODE-LOCALE_BUILD_DIR)/.built
	rm -rf $(PERL-ENCODE-LOCALE_IPK_DIR) $(BUILD_DIR)/perl-encode-locale_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-ENCODE-LOCALE_BUILD_DIR) DESTDIR=$(PERL-ENCODE-LOCALE_IPK_DIR) install
	find $(PERL-ENCODE-LOCALE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-ENCODE-LOCALE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-ENCODE-LOCALE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-ENCODE-LOCALE_IPK_DIR)/CONTROL/control
	echo $(PERL-ENCODE-LOCALE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-ENCODE-LOCALE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-ENCODE-LOCALE_IPK_DIR)

perl-encode-locale-ipk: $(PERL-ENCODE-LOCALE_IPK)

perl-encode-locale-clean:
	-$(MAKE) -C $(PERL-ENCODE-LOCALE_BUILD_DIR) clean

perl-encode-locale-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-ENCODE-LOCALE_DIR) $(PERL-ENCODE-LOCALE_BUILD_DIR) $(PERL-ENCODE-LOCALE_IPK_DIR) $(PERL-ENCODE-LOCALE_IPK)
