###########################################################
#
# perl-storable
#
###########################################################

PERL-STORABLE_SITE=http://search.cpan.org/CPAN/authors/id/A/AM/AMS
PERL-STORABLE_VERSION=2.13
PERL-STORABLE_SOURCE=Storable-$(PERL-STORABLE_VERSION).tar.gz
PERL-STORABLE_DIR=Storable-$(PERL-STORABLE_VERSION)
PERL-STORABLE_UNZIP=zcat

PERL-STORABLE_IPK_VERSION=2

PERL-STORABLE_CONFFILES=

PERL-STORABLE_BUILD_DIR=$(BUILD_DIR)/perl-storable
PERL-STORABLE_SOURCE_DIR=$(SOURCE_DIR)/perl-storable
PERL-STORABLE_IPK_DIR=$(BUILD_DIR)/perl-storable-$(PERL-STORABLE_VERSION)-ipk
PERL-STORABLE_IPK=$(BUILD_DIR)/perl-storable_$(PERL-STORABLE_VERSION)-$(PERL-STORABLE_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-STORABLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-STORABLE_SITE)/$(PERL-STORABLE_SOURCE)

perl-storable-source: $(DL_DIR)/$(PERL-STORABLE_SOURCE) $(PERL-STORABLE_PATCHES)

$(PERL-STORABLE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-STORABLE_SOURCE) $(PERL-STORABLE_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-STORABLE_DIR) $(PERL-STORABLE_BUILD_DIR)
	$(PERL-STORABLE_UNZIP) $(DL_DIR)/$(PERL-STORABLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-STORABLE_DIR) $(PERL-STORABLE_BUILD_DIR)
	(cd $(PERL-STORABLE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-STORABLE_BUILD_DIR)/.configured

perl-storable-unpack: $(PERL-STORABLE_BUILD_DIR)/.configured

$(PERL-STORABLE_BUILD_DIR)/.built: $(PERL-STORABLE_BUILD_DIR)/.configured
	rm -f $(PERL-STORABLE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-STORABLE_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-STORABLE_BUILD_DIR)/.built

perl-storable: $(PERL-STORABLE_BUILD_DIR)/.built

$(PERL-STORABLE_BUILD_DIR)/.staged: $(PERL-STORABLE_BUILD_DIR)/.built
	rm -f $(PERL-STORABLE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-STORABLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-STORABLE_BUILD_DIR)/.staged

perl-storable-stage: $(PERL-STORABLE_BUILD_DIR)/.staged

$(PERL-STORABLE_IPK): $(PERL-STORABLE_BUILD_DIR)/.built
	rm -rf $(PERL-STORABLE_IPK_DIR) $(BUILD_DIR)/perl-storable_*_armeb.ipk
	$(MAKE) -C $(PERL-STORABLE_BUILD_DIR) DESTDIR=$(PERL-STORABLE_IPK_DIR) install
	find $(PERL-STORABLE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-STORABLE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-STORABLE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	install -d $(PERL-STORABLE_IPK_DIR)/CONTROL
	install -m 644 $(PERL-STORABLE_SOURCE_DIR)/control $(PERL-STORABLE_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-STORABLE_SOURCE_DIR)/postinst $(PERL-STORABLE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-STORABLE_SOURCE_DIR)/prerm $(PERL-STORABLE_IPK_DIR)/CONTROL/prerm
	echo $(PERL-STORABLE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-STORABLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-STORABLE_IPK_DIR)

perl-storable-ipk: $(PERL-STORABLE_IPK)

perl-storable-clean:
	-$(MAKE) -C $(PERL-STORABLE_BUILD_DIR) clean

perl-storable-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-STORABLE_DIR) $(PERL-STORABLE_BUILD_DIR) $(PERL-STORABLE_IPK_DIR) $(PERL-STORABLE_IPK)
