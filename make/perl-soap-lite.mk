###########################################################
#
# perl-soap-lite
#
###########################################################

PERL-SOAP-LITE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/P/PH/PHRED
PERL-SOAP-LITE_VERSION=1.19
PERL-SOAP-LITE_SOURCE=SOAP-Lite-$(PERL-SOAP-LITE_VERSION).tar.gz
PERL-SOAP-LITE_DIR=SOAP-Lite-$(PERL-SOAP-LITE_VERSION)
PERL-SOAP-LITE_UNZIP=zcat
PERL-SOAP-LITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-SOAP-LITE_DESCRIPTION=Perls Web Services Toolkit
PERL-SOAP-LITE_SECTION=util
PERL-SOAP-LITE_PRIORITY=optional
PERL-SOAP-LITE_DEPENDS=perl-class-inspector, perl-xml-parser-lite, perl-mime-tools
PERL-SOAP-LITE_SUGGESTS=
PERL-SOAP-LITE_CONFLICTS=

PERL-SOAP-LITE_IPK_VERSION=3

PERL-SOAP-LITE_CONFFILES=

PERL-SOAP-LITE_BUILD_DIR=$(BUILD_DIR)/perl-soap-lite
PERL-SOAP-LITE_SOURCE_DIR=$(SOURCE_DIR)/perl-soap-lite
PERL-SOAP-LITE_IPK_DIR=$(BUILD_DIR)/perl-soap-lite-$(PERL-SOAP-LITE_VERSION)-ipk
PERL-SOAP-LITE_IPK=$(BUILD_DIR)/perl-soap-lite_$(PERL-SOAP-LITE_VERSION)-$(PERL-SOAP-LITE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-SOAP-LITE_SOURCE):
	$(WGET) -P $(@D) $(PERL-SOAP-LITE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-soap-lite-source: $(DL_DIR)/$(PERL-SOAP-LITE_SOURCE) $(PERL-SOAP-LITE_PATCHES)

$(PERL-SOAP-LITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-SOAP-LITE_SOURCE) $(PERL-SOAP-LITE_PATCHES) make/perl-soap-lite.mk
	rm -rf $(BUILD_DIR)/$(PERL-SOAP-LITE_DIR) $(PERL-SOAP-LITE_BUILD_DIR)
	$(PERL-SOAP-LITE_UNZIP) $(DL_DIR)/$(PERL-SOAP-LITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-SOAP-LITE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-SOAP-LITE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-SOAP-LITE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-soap-lite-unpack: $(PERL-SOAP-LITE_BUILD_DIR)/.configured

$(PERL-SOAP-LITE_BUILD_DIR)/.built: $(PERL-SOAP-LITE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-soap-lite: $(PERL-SOAP-LITE_BUILD_DIR)/.built

$(PERL-SOAP-LITE_BUILD_DIR)/.staged: $(PERL-SOAP-LITE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-soap-lite-stage: $(PERL-SOAP-LITE_BUILD_DIR)/.staged

$(PERL-SOAP-LITE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-soap-lite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-SOAP-LITE_PRIORITY)" >>$@
	@echo "Section: $(PERL-SOAP-LITE_SECTION)" >>$@
	@echo "Version: $(PERL-SOAP-LITE_VERSION)-$(PERL-SOAP-LITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-SOAP-LITE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-SOAP-LITE_SITE)/$(PERL-SOAP-LITE_SOURCE)" >>$@
	@echo "Description: $(PERL-SOAP-LITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-SOAP-LITE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-SOAP-LITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-SOAP-LITE_CONFLICTS)" >>$@

$(PERL-SOAP-LITE_IPK): $(PERL-SOAP-LITE_BUILD_DIR)/.built
	rm -rf $(PERL-SOAP-LITE_IPK_DIR) $(BUILD_DIR)/perl-soap-lite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-SOAP-LITE_BUILD_DIR) DESTDIR=$(PERL-SOAP-LITE_IPK_DIR) install
	find $(PERL-SOAP-LITE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-SOAP-LITE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-SOAP-LITE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-SOAP-LITE_IPK_DIR)/CONTROL/control
	echo $(PERL-SOAP-LITE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-SOAP-LITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-SOAP-LITE_IPK_DIR)

perl-soap-lite-ipk: $(PERL-SOAP-LITE_IPK)

perl-soap-lite-clean:
	-$(MAKE) -C $(PERL-SOAP-LITE_BUILD_DIR) clean

perl-soap-lite-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-SOAP-LITE_DIR) $(PERL-SOAP-LITE_BUILD_DIR) $(PERL-SOAP-LITE_IPK_DIR) $(PERL-SOAP-LITE_IPK)
