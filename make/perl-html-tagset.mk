###########################################################
#
# perl-html-tagset
#
###########################################################

PERL-HTML-TAGSET_SITE=http://search.cpan.org/CPAN/authors/id/S/SB/SBURKE
PERL-HTML-TAGSET_VERSION=3.04
PERL-HTML-TAGSET_SOURCE=HTML-Tagset-$(PERL-HTML-TAGSET_VERSION).tar.gz
PERL-HTML-TAGSET_DIR=HTML-Tagset-$(PERL-HTML-TAGSET_VERSION)
PERL-HTML-TAGSET_UNZIP=zcat

PERL-HTML-TAGSET_IPK_VERSION=2

PERL-HTML-TAGSET_CONFFILES=

PERL-HTML-TAGSET_BUILD_DIR=$(BUILD_DIR)/perl-html-tagset
PERL-HTML-TAGSET_SOURCE_DIR=$(SOURCE_DIR)/perl-html-tagset
PERL-HTML-TAGSET_IPK_DIR=$(BUILD_DIR)/perl-html-tagset-$(PERL-HTML-TAGSET_VERSION)-ipk
PERL-HTML-TAGSET_IPK=$(BUILD_DIR)/perl-html-tagset_$(PERL-HTML-TAGSET_VERSION)-$(PERL-HTML-TAGSET_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-HTML-TAGSET_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-HTML-TAGSET_SITE)/$(PERL-HTML-TAGSET_SOURCE)

perl-html-tagset-source: $(DL_DIR)/$(PERL-HTML-TAGSET_SOURCE) $(PERL-HTML-TAGSET_PATCHES)

$(PERL-HTML-TAGSET_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTML-TAGSET_SOURCE) $(PERL-HTML-TAGSET_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-HTML-TAGSET_DIR) $(PERL-HTML-TAGSET_BUILD_DIR)
	$(PERL-HTML-TAGSET_UNZIP) $(DL_DIR)/$(PERL-HTML-TAGSET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-HTML-TAGSET_DIR) $(PERL-HTML-TAGSET_BUILD_DIR)
	(cd $(PERL-HTML-TAGSET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-HTML-TAGSET_BUILD_DIR)/.configured

perl-html-tagset-unpack: $(PERL-HTML-TAGSET_BUILD_DIR)/.configured

$(PERL-HTML-TAGSET_BUILD_DIR)/.built: $(PERL-HTML-TAGSET_BUILD_DIR)/.configured
	rm -f $(PERL-HTML-TAGSET_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-HTML-TAGSET_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-HTML-TAGSET_BUILD_DIR)/.built

perl-html-tagset: $(PERL-HTML-TAGSET_BUILD_DIR)/.built

$(PERL-HTML-TAGSET_BUILD_DIR)/.staged: $(PERL-HTML-TAGSET_BUILD_DIR)/.built
	rm -f $(PERL-HTML-TAGSET_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-HTML-TAGSET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-HTML-TAGSET_BUILD_DIR)/.staged

perl-html-tagset-stage: $(PERL-HTML-TAGSET_BUILD_DIR)/.staged

$(PERL-HTML-TAGSET_IPK): $(PERL-HTML-TAGSET_BUILD_DIR)/.built
	rm -rf $(PERL-HTML-TAGSET_IPK_DIR) $(BUILD_DIR)/perl-html-tagset_*_armeb.ipk
	$(MAKE) -C $(PERL-HTML-TAGSET_BUILD_DIR) DESTDIR=$(PERL-HTML-TAGSET_IPK_DIR) install
	find $(PERL-HTML-TAGSET_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTML-TAGSET_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTML-TAGSET_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	install -d $(PERL-HTML-TAGSET_IPK_DIR)/CONTROL
	install -m 644 $(PERL-HTML-TAGSET_SOURCE_DIR)/control $(PERL-HTML-TAGSET_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-HTML-TAGSET_SOURCE_DIR)/postinst $(PERL-HTML-TAGSET_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-HTML-TAGSET_SOURCE_DIR)/prerm $(PERL-HTML-TAGSET_IPK_DIR)/CONTROL/prerm
	echo $(PERL-HTML-TAGSET_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTML-TAGSET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTML-TAGSET_IPK_DIR)

perl-html-tagset-ipk: $(PERL-HTML-TAGSET_IPK)

perl-html-tagset-clean:
	-$(MAKE) -C $(PERL-HTML-TAGSET_BUILD_DIR) clean

perl-html-tagset-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTML-TAGSET_DIR) $(PERL-HTML-TAGSET_BUILD_DIR) $(PERL-HTML-TAGSET_IPK_DIR) $(PERL-HTML-TAGSET_IPK)
