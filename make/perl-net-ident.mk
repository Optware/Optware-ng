###########################################################
#
# perl-net-ident
#
###########################################################

PERL-NET-IDENT_SITE=http://search.cpan.org/CPAN/authors/id/J/JP/JPC
PERL-NET-IDENT_VERSION=1.20
PERL-NET-IDENT_SOURCE=Net-Ident-$(PERL-NET-IDENT_VERSION).tar.gz
PERL-NET-IDENT_DIR=Net-Ident-$(PERL-NET-IDENT_VERSION)
PERL-NET-IDENT_UNZIP=zcat

PERL-NET-IDENT_IPK_VERSION=2

PERL-NET-IDENT_CONFFILES=

PERL-NET-IDENT_BUILD_DIR=$(BUILD_DIR)/perl-net-ident
PERL-NET-IDENT_SOURCE_DIR=$(SOURCE_DIR)/perl-net-ident
PERL-NET-IDENT_IPK_DIR=$(BUILD_DIR)/perl-net-ident-$(PERL-NET-IDENT_VERSION)-ipk
PERL-NET-IDENT_IPK=$(BUILD_DIR)/perl-net-ident_$(PERL-NET-IDENT_VERSION)-$(PERL-NET-IDENT_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-NET-IDENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-NET-IDENT_SITE)/$(PERL-NET-IDENT_SOURCE)

perl-net-ident-source: $(DL_DIR)/$(PERL-NET-IDENT_SOURCE) $(PERL-NET-IDENT_PATCHES)

$(PERL-NET-IDENT_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-IDENT_SOURCE) $(PERL-NET-IDENT_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) $(PERL-NET-IDENT_BUILD_DIR)
	$(PERL-NET-IDENT_UNZIP) $(DL_DIR)/$(PERL-NET-IDENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-NET-IDENT_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) $(PERL-NET-IDENT_BUILD_DIR)
	(cd $(PERL-NET-IDENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-NET-IDENT_BUILD_DIR)/.configured

perl-net-ident-unpack: $(PERL-NET-IDENT_BUILD_DIR)/.configured

$(PERL-NET-IDENT_BUILD_DIR)/.built: $(PERL-NET-IDENT_BUILD_DIR)/.configured
	rm -f $(PERL-NET-IDENT_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-NET-IDENT_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-NET-IDENT_BUILD_DIR)/.built

perl-net-ident: $(PERL-NET-IDENT_BUILD_DIR)/.built

$(PERL-NET-IDENT_BUILD_DIR)/.staged: $(PERL-NET-IDENT_BUILD_DIR)/.built
	rm -f $(PERL-NET-IDENT_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-NET-IDENT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-NET-IDENT_BUILD_DIR)/.staged

perl-net-ident-stage: $(PERL-NET-IDENT_BUILD_DIR)/.staged

$(PERL-NET-IDENT_IPK): $(PERL-NET-IDENT_BUILD_DIR)/.built
	rm -rf $(PERL-NET-IDENT_IPK_DIR) $(BUILD_DIR)/perl-net-ident_*_armeb.ipk
	$(MAKE) -C $(PERL-NET-IDENT_BUILD_DIR) DESTDIR=$(PERL-NET-IDENT_IPK_DIR) install
	find $(PERL-NET-IDENT_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-IDENT_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-IDENT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
#	install -d $(PERL-NET-IDENT_IPK_DIR)/opt/etc/
#	install -m 644 $(PERL-NET-IDENT_SOURCE_DIR)/perl-net-ident.conf $(PERL-NET-IDENT_IPK_DIR)/opt/etc/perl-net-ident.conf
#	install -d $(PERL-NET-IDENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PERL-NET-IDENT_SOURCE_DIR)/rc.perl-net-ident $(PERL-NET-IDENT_IPK_DIR)/opt/etc/init.d/SXXperl-net-ident
	install -d $(PERL-NET-IDENT_IPK_DIR)/CONTROL
	install -m 644 $(PERL-NET-IDENT_SOURCE_DIR)/control $(PERL-NET-IDENT_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-NET-IDENT_SOURCE_DIR)/postinst $(PERL-NET-IDENT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-NET-IDENT_SOURCE_DIR)/prerm $(PERL-NET-IDENT_IPK_DIR)/CONTROL/prerm
	echo $(PERL-NET-IDENT_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-IDENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-IDENT_IPK_DIR)

perl-net-ident-ipk: $(PERL-NET-IDENT_IPK)

perl-net-ident-clean:
	-$(MAKE) -C $(PERL-NET-IDENT_BUILD_DIR) clean

perl-net-ident-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) $(PERL-NET-IDENT_BUILD_DIR) $(PERL-NET-IDENT_IPK_DIR) $(PERL-NET-IDENT_IPK)
