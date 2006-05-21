###########################################################
#
# perl-ima-dbi
#
###########################################################

PERL-IMA-DBI_SITE=http://search.cpan.org/CPAN/authors/id/T/TM/TMTM
PERL-IMA-DBI_VERSION=0.34
PERL-IMA-DBI_SOURCE=Ima-DBI-$(PERL-IMA-DBI_VERSION).tar.gz
PERL-IMA-DBI_DIR=Ima-DBI-$(PERL-IMA-DBI_VERSION)
PERL-IMA-DBI_UNZIP=zcat
PERL-IMA-DBI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IMA-DBI_DESCRIPTION=Ima-DBI - Database connection caching and organization.
PERL-IMA-DBI_SECTION=util
PERL-IMA-DBI_PRIORITY=optional
PERL-IMA-DBI_DEPENDS=perl, perl-dbi, perl-class-data-inheritable, perl-dbix-contextualfetch
PERL-IMA-DBI_SUGGESTS=
PERL-IMA-DBI_CONFLICTS=

PERL-IMA-DBI_IPK_VERSION=1

PERL-IMA-DBI_CONFFILES=

PERL-IMA-DBI_BUILD_DIR=$(BUILD_DIR)/perl-ima-dbi
PERL-IMA-DBI_SOURCE_DIR=$(SOURCE_DIR)/perl-ima-dbi
PERL-IMA-DBI_IPK_DIR=$(BUILD_DIR)/perl-ima-dbi-$(PERL-IMA-DBI_VERSION)-ipk
PERL-IMA-DBI_IPK=$(BUILD_DIR)/perl-ima-dbi_$(PERL-IMA-DBI_VERSION)-$(PERL-IMA-DBI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IMA-DBI_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IMA-DBI_SITE)/$(PERL-IMA-DBI_SOURCE)

perl-ima-dbi-source: $(DL_DIR)/$(PERL-IMA-DBI_SOURCE) $(PERL-IMA-DBI_PATCHES)

$(PERL-IMA-DBI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IMA-DBI_SOURCE) $(PERL-IMA-DBI_PATCHES)
	$(MAKE) perl-dbi-stage perl-class-data-inheritable-stage perl-dbix-contextualfetch-stage
	rm -rf $(BUILD_DIR)/$(PERL-IMA-DBI_DIR) $(PERL-IMA-DBI_BUILD_DIR)
	$(PERL-IMA-DBI_UNZIP) $(DL_DIR)/$(PERL-IMA-DBI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IMA-DBI_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IMA-DBI_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IMA-DBI_DIR) $(PERL-IMA-DBI_BUILD_DIR)
	(cd $(PERL-IMA-DBI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-IMA-DBI_BUILD_DIR)/.configured

perl-ima-dbi-unpack: $(PERL-IMA-DBI_BUILD_DIR)/.configured

$(PERL-IMA-DBI_BUILD_DIR)/.built: $(PERL-IMA-DBI_BUILD_DIR)/.configured
	rm -f $(PERL-IMA-DBI_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-IMA-DBI_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-IMA-DBI_BUILD_DIR)/.built

perl-ima-dbi: $(PERL-IMA-DBI_BUILD_DIR)/.built

$(PERL-IMA-DBI_BUILD_DIR)/.staged: $(PERL-IMA-DBI_BUILD_DIR)/.built
	rm -f $(PERL-IMA-DBI_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-IMA-DBI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-IMA-DBI_BUILD_DIR)/.staged

perl-ima-dbi-stage: $(PERL-IMA-DBI_BUILD_DIR)/.staged

$(PERL-IMA-DBI_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-IMA-DBI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-ima-dbi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IMA-DBI_PRIORITY)" >>$@
	@echo "Section: $(PERL-IMA-DBI_SECTION)" >>$@
	@echo "Version: $(PERL-IMA-DBI_VERSION)-$(PERL-IMA-DBI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IMA-DBI_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IMA-DBI_SITE)/$(PERL-IMA-DBI_SOURCE)" >>$@
	@echo "Description: $(PERL-IMA-DBI_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IMA-DBI_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IMA-DBI_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IMA-DBI_CONFLICTS)" >>$@

$(PERL-IMA-DBI_IPK): $(PERL-IMA-DBI_BUILD_DIR)/.built
	rm -rf $(PERL-IMA-DBI_IPK_DIR) $(BUILD_DIR)/perl-ima-dbi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IMA-DBI_BUILD_DIR) DESTDIR=$(PERL-IMA-DBI_IPK_DIR) install
	find $(PERL-IMA-DBI_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IMA-DBI_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IMA-DBI_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IMA-DBI_IPK_DIR)/CONTROL/control
	echo $(PERL-IMA-DBI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IMA-DBI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IMA-DBI_IPK_DIR)

perl-ima-dbi-ipk: $(PERL-IMA-DBI_IPK)

perl-ima-dbi-clean:
	-$(MAKE) -C $(PERL-IMA-DBI_BUILD_DIR) clean

perl-ima-dbi-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IMA-DBI_DIR) $(PERL-IMA-DBI_BUILD_DIR) $(PERL-IMA-DBI_IPK_DIR) $(PERL-IMA-DBI_IPK)
