###########################################################
#
# perl-net-cidr-lite
#
###########################################################

PERL-NET-CIDR-LITE_SITE=http://search.cpan.org/CPAN/authors/id/D/DO/DOUGW
PERL-NET-CIDR-LITE_VERSION=0.20
PERL-NET-CIDR-LITE_SOURCE=Net-CIDR-Lite-$(PERL-NET-CIDR-LITE_VERSION).tar.gz
PERL-NET-CIDR-LITE_DIR=Net-CIDR-Lite-$(PERL-NET-CIDR-LITE_VERSION)
PERL-NET-CIDR-LITE_UNZIP=zcat
PERL-NET-CIDR-LITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-NET-CIDR-LITE_DESCRIPTION=Net-CIDR-Lite - Perl extension for merging IPv4 or IPv6 CIDR addresses
PERL-NET-CIDR-LITE_SECTION=util
PERL-NET-CIDR-LITE_PRIORITY=optional
PERL-NET-CIDR-LITE_DEPENDS=perl
PERL-NET-CIDR-LITE_SUGGESTS=
PERL-NET-CIDR-LITE_CONFLICTS=

PERL-NET-CIDR-LITE_IPK_VERSION=1

PERL-NET-CIDR-LITE_CONFFILES=

PERL-NET-CIDR-LITE_BUILD_DIR=$(BUILD_DIR)/perl-net-cidr-lite
PERL-NET-CIDR-LITE_SOURCE_DIR=$(SOURCE_DIR)/perl-net-cidr-lite
PERL-NET-CIDR-LITE_IPK_DIR=$(BUILD_DIR)/perl-net-cidr-lite-$(PERL-NET-CIDR-LITE_VERSION)-ipk
PERL-NET-CIDR-LITE_IPK=$(BUILD_DIR)/perl-net-cidr-lite_$(PERL-NET-CIDR-LITE_VERSION)-$(PERL-NET-CIDR-LITE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-NET-CIDR-LITE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-NET-CIDR-LITE_SITE)/$(PERL-NET-CIDR-LITE_SOURCE)

perl-net-cidr-lite-source: $(DL_DIR)/$(PERL-NET-CIDR-LITE_SOURCE) $(PERL-NET-CIDR-LITE_PATCHES)

$(PERL-NET-CIDR-LITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-CIDR-LITE_SOURCE) $(PERL-NET-CIDR-LITE_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-NET-CIDR-LITE_DIR) $(PERL-NET-CIDR-LITE_BUILD_DIR)
	$(PERL-NET-CIDR-LITE_UNZIP) $(DL_DIR)/$(PERL-NET-CIDR-LITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-NET-CIDR-LITE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-NET-CIDR-LITE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-NET-CIDR-LITE_DIR) $(PERL-NET-CIDR-LITE_BUILD_DIR)
	(cd $(PERL-NET-CIDR-LITE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
                $(STAGING_DIR)/opt -- \
		PREFIX=/opt \
	)
	touch $(PERL-NET-CIDR-LITE_BUILD_DIR)/.configured

perl-net-cidr-lite-unpack: $(PERL-NET-CIDR-LITE_BUILD_DIR)/.configured

$(PERL-NET-CIDR-LITE_BUILD_DIR)/.built: $(PERL-NET-CIDR-LITE_BUILD_DIR)/.configured
	rm -f $(PERL-NET-CIDR-LITE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-NET-CIDR-LITE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-NET-CIDR-LITE_BUILD_DIR)/.built

perl-net-cidr-lite: $(PERL-NET-CIDR-LITE_BUILD_DIR)/.built

$(PERL-NET-CIDR-LITE_BUILD_DIR)/.staged: $(PERL-NET-CIDR-LITE_BUILD_DIR)/.built
	rm -f $(PERL-NET-CIDR-LITE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-NET-CIDR-LITE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-NET-CIDR-LITE_BUILD_DIR)/.staged

perl-net-cidr-lite-stage: $(PERL-NET-CIDR-LITE_BUILD_DIR)/.staged

$(PERL-NET-CIDR-LITE_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-NET-CIDR-LITE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-net-cidr-lite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-NET-CIDR-LITE_PRIORITY)" >>$@
	@echo "Section: $(PERL-NET-CIDR-LITE_SECTION)" >>$@
	@echo "Version: $(PERL-NET-CIDR-LITE_VERSION)-$(PERL-NET-CIDR-LITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-NET-CIDR-LITE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-NET-CIDR-LITE_SITE)/$(PERL-NET-CIDR-LITE_SOURCE)" >>$@
	@echo "Description: $(PERL-NET-CIDR-LITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-NET-CIDR-LITE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-NET-CIDR-LITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-NET-CIDR-LITE_CONFLICTS)" >>$@

$(PERL-NET-CIDR-LITE_IPK): $(PERL-NET-CIDR-LITE_BUILD_DIR)/.built
	rm -rf $(PERL-NET-CIDR-LITE_IPK_DIR) $(BUILD_DIR)/perl-net-cidr-lite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-NET-CIDR-LITE_BUILD_DIR) DESTDIR=$(PERL-NET-CIDR-LITE_IPK_DIR) install
	find $(PERL-NET-CIDR-LITE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-CIDR-LITE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-CIDR-LITE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-NET-CIDR-LITE_IPK_DIR)/CONTROL/control
	echo $(PERL-NET-CIDR-LITE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-CIDR-LITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-CIDR-LITE_IPK_DIR)

perl-net-cidr-lite-ipk: $(PERL-NET-CIDR-LITE_IPK)

perl-net-cidr-lite-clean:
	-$(MAKE) -C $(PERL-NET-CIDR-LITE_BUILD_DIR) clean

perl-net-cidr-lite-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-CIDR-LITE_DIR) $(PERL-NET-CIDR-LITE_BUILD_DIR) $(PERL-NET-CIDR-LITE_IPK_DIR) $(PERL-NET-CIDR-LITE_IPK)
