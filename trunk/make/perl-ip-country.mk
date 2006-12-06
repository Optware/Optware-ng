###########################################################
#
# perl-ip-country
#
###########################################################

PERL-IP-COUNTRY_SITE=http://search.cpan.org/CPAN/authors/id/N/NW/NWETTERS
PERL-IP-COUNTRY_VERSION=2.21
PERL-IP-COUNTRY_SOURCE=IP-Country-$(PERL-IP-COUNTRY_VERSION).tar.gz
PERL-IP-COUNTRY_DIR=IP-Country-$(PERL-IP-COUNTRY_VERSION)
PERL-IP-COUNTRY_UNZIP=zcat
PERL-IP-COUNTRY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IP-COUNTRY_DESCRIPTION=IP-Country - fast lookup of country codes by IP address
PERL-IP-COUNTRY_SECTION=util
PERL-IP-COUNTRY_PRIORITY=optional
PERL-IP-COUNTRY_DEPENDS=perl
PERL-IP-COUNTRY_SUGGESTS=
PERL-IP-COUNTRY_CONFLICTS=

PERL-IP-COUNTRY_IPK_VERSION=1

PERL-IP-COUNTRY_CONFFILES=

PERL-IP-COUNTRY_BUILD_DIR=$(BUILD_DIR)/perl-ip-country
PERL-IP-COUNTRY_SOURCE_DIR=$(SOURCE_DIR)/perl-ip-country
PERL-IP-COUNTRY_IPK_DIR=$(BUILD_DIR)/perl-ip-country-$(PERL-IP-COUNTRY_VERSION)-ipk
PERL-IP-COUNTRY_IPK=$(BUILD_DIR)/perl-ip-country_$(PERL-IP-COUNTRY_VERSION)-$(PERL-IP-COUNTRY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-ip-country-source perl-ip-country-unpack perl-ip-country perl-ip-country-stage perl-ip-country-ipk perl-ip-country-clean perl-ip-country-dirclean perl-ip-country-check

$(DL_DIR)/$(PERL-IP-COUNTRY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IP-COUNTRY_SITE)/$(PERL-IP-COUNTRY_SOURCE)

perl-ip-country-source: $(DL_DIR)/$(PERL-IP-COUNTRY_SOURCE) $(PERL-IP-COUNTRY_PATCHES)

$(PERL-IP-COUNTRY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IP-COUNTRY_SOURCE) $(PERL-IP-COUNTRY_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PERL-IP-COUNTRY_DIR) $(PERL-IP-COUNTRY_BUILD_DIR)
	$(PERL-IP-COUNTRY_UNZIP) $(DL_DIR)/$(PERL-IP-COUNTRY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IP-COUNTRY_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IP-COUNTRY_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IP-COUNTRY_DIR) $(PERL-IP-COUNTRY_BUILD_DIR)
	(cd $(PERL-IP-COUNTRY_BUILD_DIR); \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-IP-COUNTRY_BUILD_DIR)/.configured

perl-ip-country-unpack: $(PERL-IP-COUNTRY_BUILD_DIR)/.configured

$(PERL-IP-COUNTRY_BUILD_DIR)/.built: $(PERL-IP-COUNTRY_BUILD_DIR)/.configured
	rm -f $(PERL-IP-COUNTRY_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-IP-COUNTRY_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" 
	touch $(PERL-IP-COUNTRY_BUILD_DIR)/.built

perl-ip-country: $(PERL-IP-COUNTRY_BUILD_DIR)/.built

$(PERL-IP-COUNTRY_BUILD_DIR)/.staged: $(PERL-IP-COUNTRY_BUILD_DIR)/.built
	rm -f $(PERL-IP-COUNTRY_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-IP-COUNTRY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-IP-COUNTRY_BUILD_DIR)/.staged

perl-ip-country-stage: $(PERL-IP-COUNTRY_BUILD_DIR)/.staged

$(PERL-IP-COUNTRY_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-IP-COUNTRY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-ip-country" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IP-COUNTRY_PRIORITY)" >>$@
	@echo "Section: $(PERL-IP-COUNTRY_SECTION)" >>$@
	@echo "Version: $(PERL-IP-COUNTRY_VERSION)-$(PERL-IP-COUNTRY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IP-COUNTRY_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IP-COUNTRY_SITE)/$(PERL-IP-COUNTRY_SOURCE)" >>$@
	@echo "Description: $(PERL-IP-COUNTRY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IP-COUNTRY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IP-COUNTRY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IP-COUNTRY_CONFLICTS)" >>$@

$(PERL-IP-COUNTRY_IPK): $(PERL-IP-COUNTRY_BUILD_DIR)/.built
	rm -rf $(PERL-IP-COUNTRY_IPK_DIR) $(BUILD_DIR)/perl-ip-country_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IP-COUNTRY_BUILD_DIR) DESTDIR=$(PERL-IP-COUNTRY_IPK_DIR) install
	find $(PERL-IP-COUNTRY_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IP-COUNTRY_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IP-COUNTRY_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IP-COUNTRY_IPK_DIR)/CONTROL/control
	echo $(PERL-IP-COUNTRY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IP-COUNTRY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IP-COUNTRY_IPK_DIR)

perl-ip-country-ipk: $(PERL-IP-COUNTRY_IPK)

perl-ip-country-clean:
	-$(MAKE) -C $(PERL-IP-COUNTRY_BUILD_DIR) clean

perl-ip-country-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IP-COUNTRY_DIR) $(PERL-IP-COUNTRY_BUILD_DIR) $(PERL-IP-COUNTRY_IPK_DIR) $(PERL-IP-COUNTRY_IPK)
#
#
# Some sanity check for the package.
#
#
perl-ip-country-check: $(PERL-IP-COUNTRY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-IP-COUNTRY_IPK)

