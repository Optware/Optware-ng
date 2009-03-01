###########################################################
#
# perl-www-mechanize
#
###########################################################

PERL-WWW-MECHANIZE_SITE=http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE
PERL-WWW-MECHANIZE_VERSION=1.54
PERL-WWW-MECHANIZE_SOURCE=WWW-Mechanize-$(PERL-WWW-MECHANIZE_VERSION).tar.gz
PERL-WWW-MECHANIZE_DIR=WWW-Mechanize-$(PERL-WWW-MECHANIZE_VERSION)
PERL-WWW-MECHANIZE_UNZIP=zcat
PERL-WWW-MECHANIZE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-WWW-MECHANIZE_DESCRIPTION=Handy web browsing in a Perl object.
PERL-WWW-MECHANIZE_SECTION=www
PERL-WWW-MECHANIZE_PRIORITY=optional
PERL-WWW-MECHANIZE_DEPENDS=perl-http-response-encoding
PERL-WWW-MECHANIZE_SUGGESTS=
PERL-WWW-MECHANIZE_CONFLICTS=

PERL-WWW-MECHANIZE_IPK_VERSION=2

PERL-WWW-MECHANIZE_CONFFILES=

PERL-WWW-MECHANIZE_BUILD_DIR=$(BUILD_DIR)/perl-www-mechanize
PERL-WWW-MECHANIZE_SOURCE_DIR=$(SOURCE_DIR)/perl-www-mechanize
PERL-WWW-MECHANIZE_IPK_DIR=$(BUILD_DIR)/perl-www-mechanize-$(PERL-WWW-MECHANIZE_VERSION)-ipk
PERL-WWW-MECHANIZE_IPK=$(BUILD_DIR)/perl-www-mechanize_$(PERL-WWW-MECHANIZE_VERSION)-$(PERL-WWW-MECHANIZE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-WWW-MECHANIZE_SOURCE):
	$(WGET) -P $(@D) $(PERL-WWW-MECHANIZE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-www-mechanize-source: $(DL_DIR)/$(PERL-WWW-MECHANIZE_SOURCE) $(PERL-WWW-MECHANIZE_PATCHES)

$(PERL-WWW-MECHANIZE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-WWW-MECHANIZE_SOURCE) $(PERL-WWW-MECHANIZE_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-WWW-MECHANIZE_DIR) $(PERL-WWW-MECHANIZE_BUILD_DIR)
	$(PERL-WWW-MECHANIZE_UNZIP) $(DL_DIR)/$(PERL-WWW-MECHANIZE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-WWW-MECHANIZE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-WWW-MECHANIZE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-WWW-MECHANIZE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-www-mechanize-unpack: $(PERL-WWW-MECHANIZE_BUILD_DIR)/.configured

$(PERL-WWW-MECHANIZE_BUILD_DIR)/.built: $(PERL-WWW-MECHANIZE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-www-mechanize: $(PERL-WWW-MECHANIZE_BUILD_DIR)/.built

$(PERL-WWW-MECHANIZE_BUILD_DIR)/.staged: $(PERL-WWW-MECHANIZE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-www-mechanize-stage: $(PERL-WWW-MECHANIZE_BUILD_DIR)/.staged

$(PERL-WWW-MECHANIZE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-www-mechanize" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-WWW-MECHANIZE_PRIORITY)" >>$@
	@echo "Section: $(PERL-WWW-MECHANIZE_SECTION)" >>$@
	@echo "Version: $(PERL-WWW-MECHANIZE_VERSION)-$(PERL-WWW-MECHANIZE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-WWW-MECHANIZE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-WWW-MECHANIZE_SITE)/$(PERL-WWW-MECHANIZE_SOURCE)" >>$@
	@echo "Description: $(PERL-WWW-MECHANIZE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-WWW-MECHANIZE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-WWW-MECHANIZE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-WWW-MECHANIZE_CONFLICTS)" >>$@

$(PERL-WWW-MECHANIZE_IPK): $(PERL-WWW-MECHANIZE_BUILD_DIR)/.built
	rm -rf $(PERL-WWW-MECHANIZE_IPK_DIR) $(BUILD_DIR)/perl-www-mechanize_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-WWW-MECHANIZE_BUILD_DIR) DESTDIR=$(PERL-WWW-MECHANIZE_IPK_DIR) install
	find $(PERL-WWW-MECHANIZE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-WWW-MECHANIZE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-WWW-MECHANIZE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-WWW-MECHANIZE_IPK_DIR)/CONTROL/control
	echo $(PERL-WWW-MECHANIZE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-WWW-MECHANIZE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-WWW-MECHANIZE_IPK_DIR)

perl-www-mechanize-ipk: $(PERL-WWW-MECHANIZE_IPK)

perl-www-mechanize-clean:
	-$(MAKE) -C $(PERL-WWW-MECHANIZE_BUILD_DIR) clean

perl-www-mechanize-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-WWW-MECHANIZE_DIR) $(PERL-WWW-MECHANIZE_BUILD_DIR) $(PERL-WWW-MECHANIZE_IPK_DIR) $(PERL-WWW-MECHANIZE_IPK)
