###########################################################
#
# perl-html-parser
#
###########################################################

PERL-HTML-PARSER_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-HTML-PARSER_VERSION=3.45
PERL-HTML-PARSER_SOURCE=HTML-Parser-$(PERL-HTML-PARSER_VERSION).tar.gz
PERL-HTML-PARSER_DIR=HTML-Parser-$(PERL-HTML-PARSER_VERSION)
PERL-HTML-PARSER_UNZIP=zcat

PERL-HTML-PARSER_IPK_VERSION=1

PERL-HTML-PARSER_CONFFILES=

PERL-HTML-PARSER_BUILD_DIR=$(BUILD_DIR)/perl-html-parser
PERL-HTML-PARSER_SOURCE_DIR=$(SOURCE_DIR)/perl-html-parser
PERL-HTML-PARSER_IPK_DIR=$(BUILD_DIR)/perl-html-parser-$(PERL-HTML-PARSER_VERSION)-ipk
PERL-HTML-PARSER_IPK=$(BUILD_DIR)/perl-html-parser_$(PERL-HTML-PARSER_VERSION)-$(PERL-HTML-PARSER_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-HTML-PARSER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-HTML-PARSER_SITE)/$(PERL-HTML-PARSER_SOURCE)

perl-html-parser-source: $(DL_DIR)/$(PERL-HTML-PARSER_SOURCE) $(PERL-HTML-PARSER_PATCHES)

$(PERL-HTML-PARSER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTML-PARSER_SOURCE) $(PERL-HTML-PARSER_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) $(PERL-HTML-PARSER_BUILD_DIR)
	$(PERL-HTML-PARSER_UNZIP) $(DL_DIR)/$(PERL-HTML-PARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTML-PARSER_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) $(PERL-HTML-PARSER_BUILD_DIR)
	(cd $(PERL-HTML-PARSER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-HTML-PARSER_BUILD_DIR)/.configured

perl-html-parser-unpack: $(PERL-HTML-PARSER_BUILD_DIR)/.configured

$(PERL-HTML-PARSER_BUILD_DIR)/.built: $(PERL-HTML-PARSER_BUILD_DIR)/.configured
	rm -f $(PERL-HTML-PARSER_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-HTML-PARSER_BUILD_DIR)
	touch $(PERL-HTML-PARSER_BUILD_DIR)/.built

perl-html-parser: $(PERL-HTML-PARSER_BUILD_DIR)/.built

$(PERL-HTML-PARSER_BUILD_DIR)/.staged: $(PERL-HTML-PARSER_BUILD_DIR)/.built
	rm -f $(PERL-HTML-PARSER_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-HTML-PARSER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-HTML-PARSER_BUILD_DIR)/.staged

perl-html-parser-stage: $(PERL-HTML-PARSER_BUILD_DIR)/.staged

$(PERL-HTML-PARSER_IPK): $(PERL-HTML-PARSER_BUILD_DIR)/.built
	rm -rf $(PERL-HTML-PARSER_IPK_DIR) $(BUILD_DIR)/perl-html-parser_*_armeb.ipk
	$(MAKE) -C $(PERL-HTML-PARSER_BUILD_DIR) DESTDIR=$(PERL-HTML-PARSER_IPK_DIR) install
	find $(PERL-HTML-PARSER_IPK_DIR)/opt -name '*.pod' -exec rm {} \;
	(cd $(PERL-HTML-PARSER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	install -d $(PERL-HTML-PARSER_IPK_DIR)/CONTROL
	install -m 644 $(PERL-HTML-PARSER_SOURCE_DIR)/control $(PERL-HTML-PARSER_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-HTML-PARSER_SOURCE_DIR)/postinst $(PERL-HTML-PARSER_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-HTML-PARSER_SOURCE_DIR)/prerm $(PERL-HTML-PARSER_IPK_DIR)/CONTROL/prerm
	echo $(PERL-HTML-PARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTML-PARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTML-PARSER_IPK_DIR)

perl-html-parser-ipk: $(PERL-HTML-PARSER_IPK)

perl-html-parser-clean:
	-$(MAKE) -C $(PERL-HTML-PARSER_BUILD_DIR) clean

perl-html-parser-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) $(PERL-HTML-PARSER_BUILD_DIR) $(PERL-HTML-PARSER_IPK_DIR) $(PERL-HTML-PARSER_IPK)
