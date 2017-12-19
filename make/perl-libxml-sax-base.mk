###########################################################
#
# perl-libxml-sax-base
#
###########################################################

PERL-LIBXML_SAX_BASE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GR/GRANTM
PERL-LIBXML_SAX_BASE_VERSION=1.08
PERL-LIBXML_SAX_BASE_SOURCE=XML-SAX-Base-$(PERL-LIBXML_SAX_BASE_VERSION).tar.gz
PERL-LIBXML_SAX_BASE_DIR=XML-SAX-Base-$(PERL-LIBXML_SAX_BASE_VERSION)
PERL-LIBXML_SAX_BASE_UNZIP=zcat
PERL-LIBXML_SAX_BASE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBXML_SAX_BASE_DESCRIPTION=Base class for SAX drivers and filters
PERL-LIBXML_SAX_BASE_SECTION=util
PERL-LIBXML_SAX_BASE_PRIORITY=optional
PERL-LIBXML_SAX_BASE_DEPENDS=perl
PERL-LIBXML_SAX_BASE_SUGGESTS=
PERL-LIBXML_SAX_BASE_CONFLICTS=

PERL-LIBXML_SAX_BASE_IPK_VERSION=2

PERL-LIBXML_SAX_BASE_CONFFILES=

PERL-LIBXML_SAX_BASE_BUILD_DIR=$(BUILD_DIR)/perl-libxml-sax-base
PERL-LIBXML_SAX_BASE_SOURCE_DIR=$(SOURCE_DIR)/perl-libxml-sax-base
PERL-LIBXML_SAX_BASE_IPK_DIR=$(BUILD_DIR)/perl-libxml-sax-base-$(PERL-LIBXML_SAX_BASE_VERSION)-ipk
PERL-LIBXML_SAX_BASE_IPK=$(BUILD_DIR)/perl-libxml-sax-base_$(PERL-LIBXML_SAX_BASE_VERSION)-$(PERL-LIBXML_SAX_BASE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LIBXML_SAX_BASE_SOURCE):
	$(WGET) -P $(@D) $(PERL-LIBXML_SAX_BASE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-libxml-sax-base-source: $(DL_DIR)/$(PERL-LIBXML_SAX_BASE_SOURCE) $(PERL-LIBXML_SAX_BASE_PATCHES)

$(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBXML_SAX_BASE_SOURCE) $(PERL-LIBXML_SAX_BASE_PATCHES) make/perl-libxml-sax-base.mk
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_SAX_BASE_DIR) $(PERL-LIBXML_SAX_BASE_BUILD_DIR)
	$(PERL-LIBXML_SAX_BASE_UNZIP) $(DL_DIR)/$(PERL-LIBXML_SAX_BASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-LIBXML_SAX_BASE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-LIBXML_SAX_BASE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-LIBXML_SAX_BASE_DIR) $(PERL-LIBXML_SAX_BASE_BUILD_DIR)
	(cd $(PERL-LIBXML_SAX_BASE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.configured

perl-libxml-sax-base-unpack: $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.configured

$(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.built: $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.configured
	rm -f $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-LIBXML_SAX_BASE_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.built

perl-libxml-sax-base: $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.built

$(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.staged: $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.built
	rm -f $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-LIBXML_SAX_BASE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.staged

perl-libxml-sax-base-stage: $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.staged

$(PERL-LIBXML_SAX_BASE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-LIBXML_SAX_BASE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-libxml-sax-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBXML_SAX_BASE_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBXML_SAX_BASE_SECTION)" >>$@
	@echo "Version: $(PERL-LIBXML_SAX_BASE_VERSION)-$(PERL-LIBXML_SAX_BASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBXML_SAX_BASE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBXML_SAX_BASE_SITE)/$(PERL-LIBXML_SAX_BASE_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBXML_SAX_BASE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBXML_SAX_BASE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBXML_SAX_BASE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBXML_SAX_BASE_CONFLICTS)" >>$@

$(PERL-LIBXML_SAX_BASE_IPK): $(PERL-LIBXML_SAX_BASE_BUILD_DIR)/.built
	rm -rf $(PERL-LIBXML_SAX_BASE_IPK_DIR) $(BUILD_DIR)/perl-libxml-sax-base_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBXML_SAX_BASE_BUILD_DIR) DESTDIR=$(PERL-LIBXML_SAX_BASE_IPK_DIR) install
	find $(PERL-LIBXML_SAX_BASE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LIBXML_SAX_BASE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-LIBXML_SAX_BASE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-LIBXML_SAX_BASE_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBXML_SAX_BASE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBXML_SAX_BASE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBXML_SAX_BASE_IPK_DIR)

perl-libxml-sax-base-ipk: $(PERL-LIBXML_SAX_BASE_IPK)

perl-libxml-sax-base-clean:
	-$(MAKE) -C $(PERL-LIBXML_SAX_BASE_BUILD_DIR) clean

perl-libxml-sax-base-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_SAX_BASE_DIR) $(PERL-LIBXML_SAX_BASE_BUILD_DIR) $(PERL-LIBXML_SAX_BASE_IPK_DIR) $(PERL-LIBXML_SAX_BASE_IPK)
#
#
# Some sanity check for the package.
#
perl-libxml-sax-base-check: $(PERL-LIBXML_SAX_BASE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
