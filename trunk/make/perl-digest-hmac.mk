###########################################################
#
# perl-digest-hmac
#
###########################################################

PERL-DIGEST-HMAC_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-DIGEST-HMAC_VERSION=1.01
PERL-DIGEST-HMAC_SOURCE=Digest-HMAC-$(PERL-DIGEST-HMAC_VERSION).tar.gz
PERL-DIGEST-HMAC_DIR=Digest-HMAC-$(PERL-DIGEST-HMAC_VERSION)
PERL-DIGEST-HMAC_UNZIP=zcat

PERL-DIGEST-HMAC_IPK_VERSION=1

PERL-DIGEST-HMAC_CONFFILES=

PERL-DIGEST-HMAC_BUILD_DIR=$(BUILD_DIR)/perl-digest-hmac
PERL-DIGEST-HMAC_SOURCE_DIR=$(SOURCE_DIR)/perl-digest-hmac
PERL-DIGEST-HMAC_IPK_DIR=$(BUILD_DIR)/perl-digest-hmac-$(PERL-DIGEST-HMAC_VERSION)-ipk
PERL-DIGEST-HMAC_IPK=$(BUILD_DIR)/perl-digest-hmac_$(PERL-DIGEST-HMAC_VERSION)-$(PERL-DIGEST-HMAC_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DIGEST-HMAC_SITE)/$(PERL-DIGEST-HMAC_SOURCE)

perl-digest-hmac-source: $(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE) $(PERL-DIGEST-HMAC_PATCHES)

$(PERL-DIGEST-HMAC_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE) $(PERL-DIGEST-HMAC_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-HMAC_DIR) $(PERL-DIGEST-HMAC_BUILD_DIR)
	$(PERL-DIGEST-HMAC_UNZIP) $(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-DIGEST-HMAC_DIR) $(PERL-DIGEST-HMAC_BUILD_DIR)
	(cd $(PERL-DIGEST-HMAC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DIGEST-HMAC_BUILD_DIR)/.configured

perl-digest-hmac-unpack: $(PERL-DIGEST-HMAC_BUILD_DIR)/.configured

$(PERL-DIGEST-HMAC_BUILD_DIR)/.built: $(PERL-DIGEST-HMAC_BUILD_DIR)/.configured
	rm -f $(PERL-DIGEST-HMAC_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR)
	touch $(PERL-DIGEST-HMAC_BUILD_DIR)/.built

perl-digest-hmac: $(PERL-DIGEST-HMAC_BUILD_DIR)/.built

$(PERL-DIGEST-HMAC_BUILD_DIR)/.staged: $(PERL-DIGEST-HMAC_BUILD_DIR)/.built
	rm -f $(PERL-DIGEST-HMAC_BUILD_DIR)/.staged
#	$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DIGEST-HMAC_BUILD_DIR)/.staged

perl-digest-hmac-stage: $(PERL-DIGEST-HMAC_BUILD_DIR)/.staged

$(PERL-DIGEST-HMAC_IPK): $(PERL-DIGEST-HMAC_BUILD_DIR)/.built
	rm -rf $(PERL-DIGEST-HMAC_IPK_DIR) $(BUILD_DIR)/perl-digest-hmac_*_armeb.ipk
	$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) DESTDIR=$(PERL-DIGEST-HMAC_IPK_DIR) install
	find $(PERL-DIGEST-HMAC_IPK_DIR)/opt -name '*.pod' -exec rm {} \;
	(cd $(PERL-DIGEST-HMAC_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	install -d $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL
	install -m 644 $(PERL-DIGEST-HMAC_SOURCE_DIR)/control $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-DIGEST-HMAC_SOURCE_DIR)/postinst $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-DIGEST-HMAC_SOURCE_DIR)/prerm $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DIGEST-HMAC_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DIGEST-HMAC_IPK_DIR)

perl-digest-hmac-ipk: $(PERL-DIGEST-HMAC_IPK)

perl-digest-hmac-clean:
	-$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) clean

perl-digest-hmac-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-HMAC_DIR) $(PERL-DIGEST-HMAC_BUILD_DIR) $(PERL-DIGEST-HMAC_IPK_DIR) $(PERL-DIGEST-HMAC_IPK)
