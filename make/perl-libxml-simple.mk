###########################################################
#
# perl-libxml-simple
#
###########################################################

PERL-LIBXML_SIMPLE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GR/GRANTM
PERL-LIBXML_SIMPLE_VERSION=2.22
PERL-LIBXML_SIMPLE_SOURCE=XML-Simple-$(PERL-LIBXML_SIMPLE_VERSION).tar.gz
PERL-LIBXML_SIMPLE_DIR=XML-Simple-$(PERL-LIBXML_SIMPLE_VERSION)
PERL-LIBXML_SIMPLE_UNZIP=zcat
PERL-LIBXML_SIMPLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBXML_SIMPLE_DESCRIPTION=Perl module for reading and writing XML
PERL-LIBXML_SIMPLE_SECTION=util
PERL-LIBXML_SIMPLE_PRIORITY=optional
PERL-LIBXML_SIMPLE_DEPENDS=perl, perl-libxml-libxml, perl-libxml-sax
PERL-LIBXML_SIMPLE_SUGGESTS=
PERL-LIBXML_SIMPLE_CONFLICTS=

PERL-LIBXML_SIMPLE_IPK_VERSION=3

PERL-LIBXML_SIMPLE_CONFFILES=

PERL-LIBXML_SIMPLE_BUILD_DIR=$(BUILD_DIR)/perl-libxml-simple
PERL-LIBXML_SIMPLE_SOURCE_DIR=$(SOURCE_DIR)/perl-libxml-simple
PERL-LIBXML_SIMPLE_IPK_DIR=$(BUILD_DIR)/perl-libxml-simple-$(PERL-LIBXML_SIMPLE_VERSION)-ipk
PERL-LIBXML_SIMPLE_IPK=$(BUILD_DIR)/perl-libxml-simple_$(PERL-LIBXML_SIMPLE_VERSION)-$(PERL-LIBXML_SIMPLE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LIBXML_SIMPLE_SOURCE):
	$(WGET) -P $(@D) $(PERL-LIBXML_SIMPLE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-libxml-simple-source: $(DL_DIR)/$(PERL-LIBXML_SIMPLE_SOURCE) $(PERL-LIBXML_SIMPLE_PATCHES)

$(PERL-LIBXML_SIMPLE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBXML_SIMPLE_SOURCE) $(PERL-LIBXML_SIMPLE_PATCHES) make/perl-libxml-simple.mk
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_SIMPLE_DIR) $(PERL-LIBXML_SIMPLE_BUILD_DIR)
	$(PERL-LIBXML_SIMPLE_UNZIP) $(DL_DIR)/$(PERL-LIBXML_SIMPLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-LIBXML_SIMPLE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-LIBXML_SIMPLE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-LIBXML_SIMPLE_DIR) $(PERL-LIBXML_SIMPLE_BUILD_DIR)
	(cd $(PERL-LIBXML_SIMPLE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.configured

perl-libxml-simple-unpack: $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.configured

$(PERL-LIBXML_SIMPLE_BUILD_DIR)/.built: $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.configured
	rm -f $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-LIBXML_SIMPLE_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.built

perl-libxml-simple: $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.built

$(PERL-LIBXML_SIMPLE_BUILD_DIR)/.staged: $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.built
	rm -f $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-LIBXML_SIMPLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.staged

perl-libxml-simple-stage: $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.staged

$(PERL-LIBXML_SIMPLE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-LIBXML_SIMPLE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-libxml-simple" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBXML_SIMPLE_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBXML_SIMPLE_SECTION)" >>$@
	@echo "Version: $(PERL-LIBXML_SIMPLE_VERSION)-$(PERL-LIBXML_SIMPLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBXML_SIMPLE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBXML_SIMPLE_SITE)/$(PERL-LIBXML_SIMPLE_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBXML_SIMPLE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBXML_SIMPLE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBXML_SIMPLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBXML_SIMPLE_CONFLICTS)" >>$@

$(PERL-LIBXML_SIMPLE_IPK): $(PERL-LIBXML_SIMPLE_BUILD_DIR)/.built
	rm -rf $(PERL-LIBXML_SIMPLE_IPK_DIR) $(BUILD_DIR)/perl-libxml-simple_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBXML_SIMPLE_BUILD_DIR) DESTDIR=$(PERL-LIBXML_SIMPLE_IPK_DIR) install
	find $(PERL-LIBXML_SIMPLE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LIBXML_SIMPLE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-LIBXML_SIMPLE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-LIBXML_SIMPLE_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBXML_SIMPLE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBXML_SIMPLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBXML_SIMPLE_IPK_DIR)

perl-libxml-simple-ipk: $(PERL-LIBXML_SIMPLE_IPK)

perl-libxml-simple-clean:
	-$(MAKE) -C $(PERL-LIBXML_SIMPLE_BUILD_DIR) clean

perl-libxml-simple-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_SIMPLE_DIR) $(PERL-LIBXML_SIMPLE_BUILD_DIR) $(PERL-LIBXML_SIMPLE_IPK_DIR) $(PERL-LIBXML_SIMPLE_IPK)
#
#
# Some sanity check for the package.
#
perl-libxml-simple-check: $(PERL-LIBXML_SIMPLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
