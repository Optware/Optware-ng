###########################################################
#
# perl-dbi
#
###########################################################

PERL-DBI_SITE=http://search.cpan.org/CPAN/authors/id/T/TI/TIMB
PERL-DBI_VERSION=1.47
PERL-DBI_SOURCE=DBI-$(PERL-DBI_VERSION).tar.gz
PERL-DBI_DIR=DBI-$(PERL-DBI_VERSION)
PERL-DBI_UNZIP=zcat

PERL-DBI_IPK_VERSION=1

PERL-DBI_CONFFILES=

PERL-DBI_BUILD_DIR=$(BUILD_DIR)/perl-dbi
PERL-DBI_SOURCE_DIR=$(SOURCE_DIR)/perl-dbi
PERL-DBI_IPK_DIR=$(BUILD_DIR)/perl-dbi-$(PERL-DBI_VERSION)-ipk
PERL-DBI_IPK=$(BUILD_DIR)/perl-dbi_$(PERL-DBI_VERSION)-$(PERL-DBI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DBI_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DBI_SITE)/$(PERL-DBI_SOURCE)

perl-dbi-source: $(DL_DIR)/$(PERL-DBI_SOURCE) $(PERL-DBI_PATCHES)

$(PERL-DBI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DBI_SOURCE) $(PERL-DBI_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PERL-DBI_DIR) $(PERL-DBI_BUILD_DIR)
	$(PERL-DBI_UNZIP) $(DL_DIR)/$(PERL-DBI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DBI_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DBI_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DBI_DIR) $(PERL-DBI_BUILD_DIR)
	(cd $(PERL-DBI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DBI_BUILD_DIR)/.configured

perl-dbi-unpack: $(PERL-DBI_BUILD_DIR)/.configured

$(PERL-DBI_BUILD_DIR)/.built: $(PERL-DBI_BUILD_DIR)/.configured
	rm -f $(PERL-DBI_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DBI_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-DBI_BUILD_DIR)/.built

perl-dbi: $(PERL-DBI_BUILD_DIR)/.built

$(PERL-DBI_BUILD_DIR)/.staged: $(PERL-DBI_BUILD_DIR)/.built
	rm -f $(PERL-DBI_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DBI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DBI_BUILD_DIR)/.staged

perl-dbi-stage: $(PERL-DBI_BUILD_DIR)/.staged

$(PERL-DBI_IPK): $(PERL-DBI_BUILD_DIR)/.built
	rm -rf $(PERL-DBI_IPK_DIR) $(BUILD_DIR)/perl-dbi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DBI_BUILD_DIR) DESTDIR=$(PERL-DBI_IPK_DIR) install
	find $(PERL-DBI_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DBI_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DBI_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
#	install -d $(PERL-DBI_IPK_DIR)/opt/etc/
#	install -m 644 $(PERL-DBI_SOURCE_DIR)/perl-dbi.conf $(PERL-DBI_IPK_DIR)/opt/etc/perl-dbi.conf
#	install -d $(PERL-DBI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PERL-DBI_SOURCE_DIR)/rc.perl-dbi $(PERL-DBI_IPK_DIR)/opt/etc/init.d/SXXperl-dbi
	install -d $(PERL-DBI_IPK_DIR)/CONTROL
	install -m 644 $(PERL-DBI_SOURCE_DIR)/control $(PERL-DBI_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-DBI_SOURCE_DIR)/postinst $(PERL-DBI_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-DBI_SOURCE_DIR)/prerm $(PERL-DBI_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DBI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DBI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DBI_IPK_DIR)

perl-dbi-ipk: $(PERL-DBI_IPK)

perl-dbi-clean:
	-$(MAKE) -C $(PERL-DBI_BUILD_DIR) clean

perl-dbi-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DBI_DIR) $(PERL-DBI_BUILD_DIR) $(PERL-DBI_IPK_DIR) $(PERL-DBI_IPK)
