###########################################################
#
# perl-b-keywords
#
###########################################################

PERL-B-KEYWORDS_SITE=http://search.cpan.org/CPAN/authors/id/J/JJ/JJORE
PERL-B-KEYWORDS_VERSION=1.08
PERL-B-KEYWORDS_SOURCE=B-Keywords-$(PERL-B-KEYWORDS_VERSION).tar.gz
PERL-B-KEYWORDS_DIR=B-Keywords-$(PERL-B-KEYWORDS_VERSION)
PERL-B-KEYWORDS_UNZIP=zcat
PERL-B-KEYWORDS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-B-KEYWORDS_DESCRIPTION=Lists of reserved barewords and symbol names.
PERL-B-KEYWORDS_SECTION=util
PERL-B-KEYWORDS_PRIORITY=optional
PERL-B-KEYWORDS_DEPENDS=perl
PERL-B-KEYWORDS_SUGGESTS=
PERL-B-KEYWORDS_CONFLICTS=

PERL-B-KEYWORDS_IPK_VERSION=1

PERL-B-KEYWORDS_CONFFILES=

PERL-B-KEYWORDS_BUILD_DIR=$(BUILD_DIR)/perl-b-keywords
PERL-B-KEYWORDS_SOURCE_DIR=$(SOURCE_DIR)/perl-b-keywords
PERL-B-KEYWORDS_IPK_DIR=$(BUILD_DIR)/perl-b-keywords-$(PERL-B-KEYWORDS_VERSION)-ipk
PERL-B-KEYWORDS_IPK=$(BUILD_DIR)/perl-b-keywords_$(PERL-B-KEYWORDS_VERSION)-$(PERL-B-KEYWORDS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-B-KEYWORDS_SOURCE):
	$(WGET) -P $(@D) $(PERL-B-KEYWORDS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-b-keywords-source: $(DL_DIR)/$(PERL-B-KEYWORDS_SOURCE) $(PERL-B-KEYWORDS_PATCHES)

$(PERL-B-KEYWORDS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-B-KEYWORDS_SOURCE) $(PERL-B-KEYWORDS_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-B-KEYWORDS_DIR) $(@D)
	$(PERL-B-KEYWORDS_UNZIP) $(DL_DIR)/$(PERL-B-KEYWORDS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-B-KEYWORDS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-B-KEYWORDS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-B-KEYWORDS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-b-keywords-unpack: $(PERL-B-KEYWORDS_BUILD_DIR)/.configured

$(PERL-B-KEYWORDS_BUILD_DIR)/.built: $(PERL-B-KEYWORDS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-b-keywords: $(PERL-B-KEYWORDS_BUILD_DIR)/.built

$(PERL-B-KEYWORDS_BUILD_DIR)/.staged: $(PERL-B-KEYWORDS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-b-keywords-stage: $(PERL-B-KEYWORDS_BUILD_DIR)/.staged

$(PERL-B-KEYWORDS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-b-keywords" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-B-KEYWORDS_PRIORITY)" >>$@
	@echo "Section: $(PERL-B-KEYWORDS_SECTION)" >>$@
	@echo "Version: $(PERL-B-KEYWORDS_VERSION)-$(PERL-B-KEYWORDS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-B-KEYWORDS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-B-KEYWORDS_SITE)/$(PERL-B-KEYWORDS_SOURCE)" >>$@
	@echo "Description: $(PERL-B-KEYWORDS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-B-KEYWORDS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-B-KEYWORDS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-B-KEYWORDS_CONFLICTS)" >>$@

$(PERL-B-KEYWORDS_IPK): $(PERL-B-KEYWORDS_BUILD_DIR)/.built
	rm -rf $(PERL-B-KEYWORDS_IPK_DIR) $(BUILD_DIR)/perl-b-keywords_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-B-KEYWORDS_BUILD_DIR) DESTDIR=$(PERL-B-KEYWORDS_IPK_DIR) install
	find $(PERL-B-KEYWORDS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-B-KEYWORDS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-B-KEYWORDS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-B-KEYWORDS_IPK_DIR)/CONTROL/control
	echo $(PERL-B-KEYWORDS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-B-KEYWORDS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-B-KEYWORDS_IPK_DIR)

perl-b-keywords-ipk: $(PERL-B-KEYWORDS_IPK)

perl-b-keywords-clean:
	-$(MAKE) -C $(PERL-B-KEYWORDS_BUILD_DIR) clean

perl-b-keywords-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-B-KEYWORDS_DIR) $(PERL-B-KEYWORDS_BUILD_DIR) $(PERL-B-KEYWORDS_IPK_DIR) $(PERL-B-KEYWORDS_IPK)
