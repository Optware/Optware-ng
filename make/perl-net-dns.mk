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

PERL-NET-DNS_IPK_VERSION=2

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
		perl Makefile.PL --no-online-tests \
		PREFIX=/opt \
	)
	touch $(PERL-NET-DNS_BUILD_DIR)/.configured

perl-net-dns-unpack: $(PERL-NET-DNS_BUILD_DIR)/.configured

$(PERL-NET-DNS_BUILD_DIR)/.built: $(PERL-NET-DNS_BUILD_DIR)/.configured
	rm -f $(PERL-NET-DNS_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-NET-DNS_BUILD_DIR)/.built

perl-net-dns: $(PERL-NET-DNS_BUILD_DIR)/.built

$(PERL-NET-DNS_BUILD_DIR)/.staged: $(PERL-NET-DNS_BUILD_DIR)/.built
	rm -f $(PERL-NET-DNS_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-NET-DNS_BUILD_DIR)/.staged

perl-net-dns-stage: $(PERL-NET-DNS_BUILD_DIR)/.staged

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
#	install -d $(PERL-NET-DNS_IPK_DIR)/opt/etc/
#	install -m 644 $(PERL-NET-DNS_SOURCE_DIR)/perl-net-dns.conf $(PERL-NET-DNS_IPK_DIR)/opt/etc/perl-net-dns.conf
#	install -d $(PERL-NET-DNS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PERL-NET-DNS_SOURCE_DIR)/rc.perl-net-dns $(PERL-NET-DNS_IPK_DIR)/opt/etc/init.d/SXXperl-net-dns
	install -d $(PERL-NET-DNS_IPK_DIR)/CONTROL
	install -m 644 $(PERL-NET-DNS_SOURCE_DIR)/control $(PERL-NET-DNS_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-NET-DNS_SOURCE_DIR)/postinst $(PERL-NET-DNS_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-NET-DNS_SOURCE_DIR)/prerm $(PERL-NET-DNS_IPK_DIR)/CONTROL/prerm
	echo $(PERL-NET-DNS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-DNS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-DNS_IPK_DIR)

perl-net-dns-ipk: $(PERL-NET-DNS_IPK)

perl-net-dns-clean:
	-$(MAKE) -C $(PERL-NET-DNS_BUILD_DIR) clean

perl-net-dns-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-DNS_DIR) $(PERL-NET-DNS_BUILD_DIR) $(PERL-NET-DNS_IPK_DIR) $(PERL-NET-DNS_IPK)
