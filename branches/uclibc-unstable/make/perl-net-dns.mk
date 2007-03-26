###########################################################
#
# perl-net-dns
#
###########################################################

PERL-NET-DNS_SITE=http://search.cpan.org/CPAN/authors/id/C/CR/CREIN
PERL-NET-DNS_VERSION=0.48
PERL-NET-DNS_SOURCE=Net-DNS-$(PERL-NET-DNS_VERSION).tar.gz
PERL-NET-DNS_DIR=Net-DNS-$(PERL-NET-DNS_VERSION)
PERL-NET-DNS_UNZIP=zcat
PERL-NET-DNS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-NET-DNS_DESCRIPTION=Perl DNS Resolver Module.
PERL-NET-DNS_SECTION=util
PERL-NET-DNS_PRIORITY=optional
PERL-NET-DNS_DEPENDS=perl, perl-digest-hmac
PERL-NET-DNS_SUGGESTS=
PERL-NET-DNS_CONFLICTS=

PERL-NET-DNS_IPK_VERSION=4

PERL-NET-DNS_CONFFILES=

PERL-NET-DNS_BUILD_DIR=$(BUILD_DIR)/perl-net-dns
PERL-NET-DNS_SOURCE_DIR=$(SOURCE_DIR)/perl-net-dns
PERL-NET-DNS_IPK_DIR=$(BUILD_DIR)/perl-net-dns-$(PERL-NET-DNS_VERSION)-ipk
PERL-NET-DNS_IPK=$(BUILD_DIR)/perl-net-dns_$(PERL-NET-DNS_VERSION)-$(PERL-NET-DNS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-NET-DNS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-NET-DNS_SITE)/$(PERL-NET-DNS_SOURCE)

perl-net-dns-source: $(DL_DIR)/$(PERL-NET-DNS_SOURCE) $(PERL-NET-DNS_PATCHES)

$(PERL-NET-DNS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-DNS_SOURCE) $(PERL-NET-DNS_PATCHES)
	$(MAKE) perl-digest-hmac-stage
	rm -rf $(BUILD_DIR)/$(PERL-NET-DNS_DIR) $(PERL-NET-DNS_BUILD_DIR)
	$(PERL-NET-DNS_UNZIP) $(DL_DIR)/$(PERL-NET-DNS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-NET-DNS_DIR) $(PERL-NET-DNS_BUILD_DIR)
	(cd $(PERL-NET-DNS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL --no-online-tests \
		LD_RUN_PATH=/opt/lib \
		PREFIX=/opt \
	)
	touch $(PERL-NET-DNS_BUILD_DIR)/.configured

perl-net-dns-unpack: $(PERL-NET-DNS_BUILD_DIR)/.configured

$(PERL-NET-DNS_BUILD_DIR)/.built: $(PERL-NET-DNS_BUILD_DIR)/.configured
	rm -f $(PERL-NET-DNS_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LD_RUN_PATH=/opt/lib \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-NET-DNS_BUILD_DIR)/.built

perl-net-dns: $(PERL-NET-DNS_BUILD_DIR)/.built

$(PERL-NET-DNS_BUILD_DIR)/.staged: $(PERL-NET-DNS_BUILD_DIR)/.built
	rm -f $(PERL-NET-DNS_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-NET-DNS_BUILD_DIR)/.staged

perl-net-dns-stage: $(PERL-NET-DNS_BUILD_DIR)/.staged

$(PERL-NET-DNS_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-NET-DNS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-net-dns" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-NET-DNS_PRIORITY)" >>$@
	@echo "Section: $(PERL-NET-DNS_SECTION)" >>$@
	@echo "Version: $(PERL-NET-DNS_VERSION)-$(PERL-NET-DNS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-NET-DNS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-NET-DNS_SITE)/$(PERL-NET-DNS_SOURCE)" >>$@
	@echo "Description: $(PERL-NET-DNS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-NET-DNS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-NET-DNS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-NET-DNS_CONFLICTS)" >>$@

$(PERL-NET-DNS_IPK): $(PERL-NET-DNS_BUILD_DIR)/.built
	rm -rf $(PERL-NET-DNS_IPK_DIR) $(BUILD_DIR)/perl-net-dns_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) DESTDIR=$(PERL-NET-DNS_IPK_DIR) install
	find $(PERL-NET-DNS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-DNS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-DNS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-NET-DNS_IPK_DIR)/CONTROL/control
	echo $(PERL-NET-DNS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-DNS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-DNS_IPK_DIR)

perl-net-dns-ipk: $(PERL-NET-DNS_IPK)

perl-net-dns-clean:
	-$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) clean

perl-net-dns-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-DNS_DIR) $(PERL-NET-DNS_BUILD_DIR) $(PERL-NET-DNS_IPK_DIR) $(PERL-NET-DNS_IPK)
