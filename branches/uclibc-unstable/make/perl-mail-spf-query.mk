###########################################################
#
# perl-mail-spf-query
#
###########################################################

PERL-MAIL-SPF-QUERY_SITE=http://search.cpan.org/CPAN/authors/id/J/JM/JMEHNLE/mail-spf-query
PERL-MAIL-SPF-QUERY_VERSION=1.999.1
PERL-MAIL-SPF-QUERY_SOURCE=Mail-SPF-Query-$(PERL-MAIL-SPF-QUERY_VERSION).tar.gz
PERL-MAIL-SPF-QUERY_DIR=Mail-SPF-Query-$(PERL-MAIL-SPF-QUERY_VERSION)
PERL-MAIL-SPF-QUERY_UNZIP=zcat
PERL-MAIL-SPF-QUERY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MAIL-SPF-QUERY_DESCRIPTION=Mail-SPF-Query - query Sender Policy Framework for an IP,email,helo
PERL-MAIL-SPF-QUERY_SECTION=util
PERL-MAIL-SPF-QUERY_PRIORITY=optional
PERL-MAIL-SPF-QUERY_DEPENDS=perl, perl-net-cidr-lite, perl-net-dns, \
  perl-sys-hostname-long, perl-uri
PERL-MAIL-SPF-QUERY_SUGGESTS=
PERL-MAIL-SPF-QUERY_CONFLICTS=

PERL-MAIL-SPF-QUERY_IPK_VERSION=1

PERL-MAIL-SPF-QUERY_CONFFILES=

PERL-MAIL-SPF-QUERY_BUILD_DIR=$(BUILD_DIR)/perl-mail-spf-query
PERL-MAIL-SPF-QUERY_SOURCE_DIR=$(SOURCE_DIR)/perl-mail-spf-query
PERL-MAIL-SPF-QUERY_IPK_DIR=$(BUILD_DIR)/perl-mail-spf-query-$(PERL-MAIL-SPF-QUERY_VERSION)-ipk
PERL-MAIL-SPF-QUERY_IPK=$(BUILD_DIR)/perl-mail-spf-query_$(PERL-MAIL-SPF-QUERY_VERSION)-$(PERL-MAIL-SPF-QUERY_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MAIL-SPF-QUERY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MAIL-SPF-QUERY_SITE)/$(PERL-MAIL-SPF-QUERY_SOURCE)

perl-mail-spf-query-source: $(DL_DIR)/$(PERL-MAIL-SPF-QUERY_SOURCE) $(PERL-MAIL-SPF-QUERY_PATCHES)

$(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MAIL-SPF-QUERY_SOURCE) $(PERL-MAIL-SPF-QUERY_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-MAIL-SPF-QUERY_DIR) $(PERL-MAIL-SPF-QUERY_BUILD_DIR)
	$(PERL-MAIL-SPF-QUERY_UNZIP) $(DL_DIR)/$(PERL-MAIL-SPF-QUERY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-MAIL-SPF-QUERY_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-MAIL-SPF-QUERY_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MAIL-SPF-QUERY_DIR) $(PERL-MAIL-SPF-QUERY_BUILD_DIR)
	(cd $(PERL-MAIL-SPF-QUERY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
                $(STAGING_DIR)/opt -- \
		PREFIX=/opt \
	)
	touch $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.configured

perl-mail-spf-query-unpack: $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.configured

$(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.built: $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.configured
	rm -f $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-MAIL-SPF-QUERY_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.built

perl-mail-spf-query: $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.built

$(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.staged: $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.built
	rm -f $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-MAIL-SPF-QUERY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.staged

perl-mail-spf-query-stage: $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.staged

$(PERL-MAIL-SPF-QUERY_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-MAIL-SPF-QUERY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-mail-spf-query" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MAIL-SPF-QUERY_PRIORITY)" >>$@
	@echo "Section: $(PERL-MAIL-SPF-QUERY_SECTION)" >>$@
	@echo "Version: $(PERL-MAIL-SPF-QUERY_VERSION)-$(PERL-MAIL-SPF-QUERY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MAIL-SPF-QUERY_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MAIL-SPF-QUERY_SITE)/$(PERL-MAIL-SPF-QUERY_SOURCE)" >>$@
	@echo "Description: $(PERL-MAIL-SPF-QUERY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MAIL-SPF-QUERY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MAIL-SPF-QUERY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MAIL-SPF-QUERY_CONFLICTS)" >>$@

$(PERL-MAIL-SPF-QUERY_IPK): $(PERL-MAIL-SPF-QUERY_BUILD_DIR)/.built
	rm -rf $(PERL-MAIL-SPF-QUERY_IPK_DIR) $(BUILD_DIR)/perl-mail-spf-query_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MAIL-SPF-QUERY_BUILD_DIR) DESTDIR=$(PERL-MAIL-SPF-QUERY_IPK_DIR) install
	find $(PERL-MAIL-SPF-QUERY_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MAIL-SPF-QUERY_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MAIL-SPF-QUERY_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-MAIL-SPF-QUERY_IPK_DIR)/CONTROL/control
	echo $(PERL-MAIL-SPF-QUERY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MAIL-SPF-QUERY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MAIL-SPF-QUERY_IPK_DIR)

perl-mail-spf-query-ipk: $(PERL-MAIL-SPF-QUERY_IPK)

perl-mail-spf-query-clean:
	-$(MAKE) -C $(PERL-MAIL-SPF-QUERY_BUILD_DIR) clean

perl-mail-spf-query-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MAIL-SPF-QUERY_DIR) $(PERL-MAIL-SPF-QUERY_BUILD_DIR) $(PERL-MAIL-SPF-QUERY_IPK_DIR) $(PERL-MAIL-SPF-QUERY_IPK)
