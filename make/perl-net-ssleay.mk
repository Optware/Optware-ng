###########################################################
#
# perl-net-ssleay
#
###########################################################

PERL-NET-SSLEAY_SITE=http://search.cpan.org/CPAN/authors/id/F/FL/FLORA
PERL-NET-SSLEAY_VERSION=1.30
PERL-NET-SSLEAY_SOURCE=Net_SSLeay.pm-$(PERL-NET-SSLEAY_VERSION).tar.gz
PERL-NET-SSLEAY_DIR=Net_SSLeay.pm-$(PERL-NET-SSLEAY_VERSION)
PERL-NET-SSLEAY_UNZIP=zcat
PERL-NET-SSLEAY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-NET-SSLEAY_DESCRIPTION=Net_SSLeay - Perl extension for using OpenSSL 
PERL-NET-SSLEAY_SECTION=util
PERL-NET-SSLEAY_PRIORITY=optional
PERL-NET-SSLEAY_DEPENDS=perl, openssl
PERL-NET-SSLEAY_SUGGESTS=
PERL-NET-SSLEAY_CONFLICTS=

PERL-NET-SSLEAY_IPK_VERSION=1

PERL-NET-SSLEAY_CONFFILES=

PERL-NET-SSLEAY_BUILD_DIR=$(BUILD_DIR)/perl-net-ssleay
PERL-NET-SSLEAY_SOURCE_DIR=$(SOURCE_DIR)/perl-net-ssleay
PERL-NET-SSLEAY_IPK_DIR=$(BUILD_DIR)/perl-net-ssleay-$(PERL-NET-SSLEAY_VERSION)-ipk
PERL-NET-SSLEAY_IPK=$(BUILD_DIR)/perl-net-ssleay_$(PERL-NET-SSLEAY_VERSION)-$(PERL-NET-SSLEAY_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-NET-SSLEAY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-NET-SSLEAY_SITE)/$(PERL-NET-SSLEAY_SOURCE)

perl-net-ssleay-source: $(DL_DIR)/$(PERL-NET-SSLEAY_SOURCE) $(PERL-NET-SSLEAY_PATCHES)

$(PERL-NET-SSLEAY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-SSLEAY_SOURCE) $(PERL-NET-SSLEAY_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PERL-NET-SSLEAY_DIR) $(PERL-NET-SSLEAY_BUILD_DIR)
	$(PERL-NET-SSLEAY_UNZIP) $(DL_DIR)/$(PERL-NET-SSLEAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-NET-SSLEAY_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-NET-SSLEAY_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-NET-SSLEAY_DIR) $(PERL-NET-SSLEAY_BUILD_DIR)
	(cd $(PERL-NET-SSLEAY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
                $(STAGING_DIR)/opt -- \
		PREFIX=/opt \
	)
	touch $(PERL-NET-SSLEAY_BUILD_DIR)/.configured

perl-net-ssleay-unpack: $(PERL-NET-SSLEAY_BUILD_DIR)/.configured

$(PERL-NET-SSLEAY_BUILD_DIR)/.built: $(PERL-NET-SSLEAY_BUILD_DIR)/.configured
	rm -f $(PERL-NET-SSLEAY_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-NET-SSLEAY_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-NET-SSLEAY_BUILD_DIR)/.built

perl-net-ssleay: $(PERL-NET-SSLEAY_BUILD_DIR)/.built

$(PERL-NET-SSLEAY_BUILD_DIR)/.staged: $(PERL-NET-SSLEAY_BUILD_DIR)/.built
	rm -f $(PERL-NET-SSLEAY_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-NET-SSLEAY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-NET-SSLEAY_BUILD_DIR)/.staged

perl-net-ssleay-stage: $(PERL-NET-SSLEAY_BUILD_DIR)/.staged

$(PERL-NET-SSLEAY_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-NET-SSLEAY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-net-ssleay" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-NET-SSLEAY_PRIORITY)" >>$@
	@echo "Section: $(PERL-NET-SSLEAY_SECTION)" >>$@
	@echo "Version: $(PERL-NET-SSLEAY_VERSION)-$(PERL-NET-SSLEAY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-NET-SSLEAY_MAINTAINER)" >>$@
	@echo "Source: $(PERL-NET-SSLEAY_SITE)/$(PERL-NET-SSLEAY_SOURCE)" >>$@
	@echo "Description: $(PERL-NET-SSLEAY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-NET-SSLEAY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-NET-SSLEAY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-NET-SSLEAY_CONFLICTS)" >>$@

$(PERL-NET-SSLEAY_IPK): $(PERL-NET-SSLEAY_BUILD_DIR)/.built
	rm -rf $(PERL-NET-SSLEAY_IPK_DIR) $(BUILD_DIR)/perl-net-ssleay_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-NET-SSLEAY_BUILD_DIR) DESTDIR=$(PERL-NET-SSLEAY_IPK_DIR) install
	find $(PERL-NET-SSLEAY_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-SSLEAY_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-SSLEAY_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-NET-SSLEAY_IPK_DIR)/CONTROL/control
	echo $(PERL-NET-SSLEAY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-SSLEAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-SSLEAY_IPK_DIR)

perl-net-ssleay-ipk: $(PERL-NET-SSLEAY_IPK)

perl-net-ssleay-clean:
	-$(MAKE) -C $(PERL-NET-SSLEAY_BUILD_DIR) clean

perl-net-ssleay-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-SSLEAY_DIR) $(PERL-NET-SSLEAY_BUILD_DIR) $(PERL-NET-SSLEAY_IPK_DIR) $(PERL-NET-SSLEAY_IPK)
