###########################################################
#
# perl-time-hires
#
###########################################################

PERL-TIME-HIRES_SITE=http://search.cpan.org/CPAN/authors/id/J/JH/JHI
PERL-TIME-HIRES_VERSION=1.66
PERL-TIME-HIRES_SOURCE=Time-HiRes-$(PERL-TIME-HIRES_VERSION).tar.gz
PERL-TIME-HIRES_DIR=Time-HiRes-$(PERL-TIME-HIRES_VERSION)
PERL-TIME-HIRES_UNZIP=zcat

PERL-TIME-HIRES_IPK_VERSION=1

PERL-TIME-HIRES_CONFFILES=

PERL-TIME-HIRES_BUILD_DIR=$(BUILD_DIR)/perl-time-hires
PERL-TIME-HIRES_SOURCE_DIR=$(SOURCE_DIR)/perl-time-hires
PERL-TIME-HIRES_IPK_DIR=$(BUILD_DIR)/perl-time-hires-$(PERL-TIME-HIRES_VERSION)-ipk
PERL-TIME-HIRES_IPK=$(BUILD_DIR)/perl-time-hires_$(PERL-TIME-HIRES_VERSION)-$(PERL-TIME-HIRES_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-TIME-HIRES_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-TIME-HIRES_SITE)/$(PERL-TIME-HIRES_SOURCE)

perl-time-hires-source: $(DL_DIR)/$(PERL-TIME-HIRES_SOURCE) $(PERL-TIME-HIRES_PATCHES)

$(PERL-TIME-HIRES_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TIME-HIRES_SOURCE) $(PERL-TIME-HIRES_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-TIME-HIRES_DIR) $(PERL-TIME-HIRES_BUILD_DIR)
	$(PERL-TIME-HIRES_UNZIP) $(DL_DIR)/$(PERL-TIME-HIRES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-TIME-HIRES_DIR) $(PERL-TIME-HIRES_BUILD_DIR)
	(cd $(PERL-TIME-HIRES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-TIME-HIRES_BUILD_DIR)/.configured

perl-time-hires-unpack: $(PERL-TIME-HIRES_BUILD_DIR)/.configured

$(PERL-TIME-HIRES_BUILD_DIR)/.built: $(PERL-TIME-HIRES_BUILD_DIR)/.configured
	rm -f $(PERL-TIME-HIRES_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR)
	touch $(PERL-TIME-HIRES_BUILD_DIR)/.built

perl-time-hires: $(PERL-TIME-HIRES_BUILD_DIR)/.built

$(PERL-TIME-HIRES_BUILD_DIR)/.staged: $(PERL-TIME-HIRES_BUILD_DIR)/.built
	rm -f $(PERL-TIME-HIRES_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-TIME-HIRES_BUILD_DIR)/.staged

perl-time-hires-stage: $(PERL-TIME-HIRES_BUILD_DIR)/.staged

$(PERL-TIME-HIRES_IPK): $(PERL-TIME-HIRES_BUILD_DIR)/.built
	rm -rf $(PERL-TIME-HIRES_IPK_DIR) $(BUILD_DIR)/perl-time-hires_*_armeb.ipk
	$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) DESTDIR=$(PERL-TIME-HIRES_IPK_DIR) install
	find $(PERL-TIME-HIRES_IPK_DIR)/opt -name '*.pod' -exec rm {} \;
	(cd $(PERL-TIME-HIRES_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	install -d $(PERL-TIME-HIRES_IPK_DIR)/CONTROL
	install -m 644 $(PERL-TIME-HIRES_SOURCE_DIR)/control $(PERL-TIME-HIRES_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-TIME-HIRES_SOURCE_DIR)/postinst $(PERL-TIME-HIRES_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-TIME-HIRES_SOURCE_DIR)/prerm $(PERL-TIME-HIRES_IPK_DIR)/CONTROL/prerm
	echo $(PERL-TIME-HIRES_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TIME-HIRES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TIME-HIRES_IPK_DIR)

perl-time-hires-ipk: $(PERL-TIME-HIRES_IPK)

perl-time-hires-clean:
	-$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) clean

perl-time-hires-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TIME-HIRES_DIR) $(PERL-TIME-HIRES_BUILD_DIR) $(PERL-TIME-HIRES_IPK_DIR) $(PERL-TIME-HIRES_IPK)
