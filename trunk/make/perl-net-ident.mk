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
PERL-NET-IDENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-NET-IDENT_DESCRIPTION=Net::Ident
PERL-NET-IDENT_SECTION=util
PERL-NET-IDENT_PRIORITY=optional
PERL-NET-IDENT_DEPENDS=perl
PERL-NET-IDENT_SUGGESTS=
PERL-NET-IDENT_CONFLICTS=

PERL-NET-IDENT_IPK_VERSION=3

PERL-NET-IDENT_CONFFILES=

PERL-NET-IDENT_BUILD_DIR=$(BUILD_DIR)/perl-net-ident
PERL-NET-IDENT_SOURCE_DIR=$(SOURCE_DIR)/perl-net-ident
PERL-NET-IDENT_IPK_DIR=$(BUILD_DIR)/perl-net-ident-$(PERL-NET-IDENT_VERSION)-ipk
PERL-NET-IDENT_IPK=$(BUILD_DIR)/perl-net-ident_$(PERL-NET-IDENT_VERSION)-$(PERL-NET-IDENT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-NET-IDENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-NET-IDENT_SITE)/$(PERL-NET-IDENT_SOURCE)

perl-net-ident-source: $(DL_DIR)/$(PERL-NET-IDENT_SOURCE) $(PERL-NET-IDENT_PATCHES)

$(PERL-NET-IDENT_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-IDENT_SOURCE) $(PERL-NET-IDENT_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) $(PERL-NET-IDENT_BUILD_DIR)
	$(PERL-NET-IDENT_UNZIP) $(DL_DIR)/$(PERL-NET-IDENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-NET-IDENT_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) $(PERL-NET-IDENT_BUILD_DIR)
	(cd $(PERL-NET-IDENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
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

$(PERL-NET-IDENT_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-NET-IDENT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-net-ident" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-NET-IDENT_PRIORITY)" >>$@
	@echo "Section: $(PERL-NET-IDENT_SECTION)" >>$@
	@echo "Version: $(PERL-NET-IDENT_VERSION)-$(PERL-NET-IDENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-NET-IDENT_MAINTAINER)" >>$@
	@echo "Source: $(PERL-NET-IDENT_SITE)/$(PERL-NET-IDENT_SOURCE)" >>$@
	@echo "Description: $(PERL-NET-IDENT_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-NET-IDENT_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-NET-IDENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-NET-IDENT_CONFLICTS)" >>$@

$(PERL-NET-IDENT_IPK): $(PERL-NET-IDENT_BUILD_DIR)/.built
	rm -rf $(PERL-NET-IDENT_IPK_DIR) $(BUILD_DIR)/perl-net-ident_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-NET-IDENT_BUILD_DIR) DESTDIR=$(PERL-NET-IDENT_IPK_DIR) install
	find $(PERL-NET-IDENT_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-IDENT_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-IDENT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-NET-IDENT_IPK_DIR)/CONTROL/control
	echo $(PERL-NET-IDENT_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-IDENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-IDENT_IPK_DIR)

perl-net-ident-ipk: $(PERL-NET-IDENT_IPK)

perl-net-ident-clean:
	-$(MAKE) -C $(PERL-NET-IDENT_BUILD_DIR) clean

perl-net-ident-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-IDENT_DIR) $(PERL-NET-IDENT_BUILD_DIR) $(PERL-NET-IDENT_IPK_DIR) $(PERL-NET-IDENT_IPK)
