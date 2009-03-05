###########################################################
#
# perl-email-address
#
###########################################################

PERL-EMAIL-ADDRESS_SITE=http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS
PERL-EMAIL-ADDRESS_VERSION=1.889
PERL-EMAIL-ADDRESS_SOURCE=Email-Address-$(PERL-EMAIL-ADDRESS_VERSION).tar.gz
PERL-EMAIL-ADDRESS_DIR=Email-Address-$(PERL-EMAIL-ADDRESS_VERSION)
PERL-EMAIL-ADDRESS_UNZIP=zcat
PERL-EMAIL-ADDRESS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EMAIL-ADDRESS_DESCRIPTION=RFC 2822 Address Parsing and Creation.
PERL-EMAIL-ADDRESS_SECTION=email
PERL-EMAIL-ADDRESS_PRIORITY=optional
PERL-EMAIL-ADDRESS_DEPENDS=perl
PERL-EMAIL-ADDRESS_SUGGESTS=
PERL-EMAIL-ADDRESS_CONFLICTS=

PERL-EMAIL-ADDRESS_IPK_VERSION=1

PERL-EMAIL-ADDRESS_CONFFILES=

PERL-EMAIL-ADDRESS_BUILD_DIR=$(BUILD_DIR)/perl-email-address
PERL-EMAIL-ADDRESS_SOURCE_DIR=$(SOURCE_DIR)/perl-email-address
PERL-EMAIL-ADDRESS_IPK_DIR=$(BUILD_DIR)/perl-email-address-$(PERL-EMAIL-ADDRESS_VERSION)-ipk
PERL-EMAIL-ADDRESS_IPK=$(BUILD_DIR)/perl-email-address_$(PERL-EMAIL-ADDRESS_VERSION)-$(PERL-EMAIL-ADDRESS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EMAIL-ADDRESS_SOURCE):
	$(WGET) -P $(@D) $(PERL-EMAIL-ADDRESS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-email-address-source: $(DL_DIR)/$(PERL-EMAIL-ADDRESS_SOURCE) $(PERL-EMAIL-ADDRESS_PATCHES)

$(PERL-EMAIL-ADDRESS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EMAIL-ADDRESS_SOURCE) $(PERL-EMAIL-ADDRESS_PATCHES) make/perl-email-address.mk
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-ADDRESS_DIR) $(@D)
	$(PERL-EMAIL-ADDRESS_UNZIP) $(DL_DIR)/$(PERL-EMAIL-ADDRESS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EMAIL-ADDRESS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-EMAIL-ADDRESS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EMAIL-ADDRESS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-email-address-unpack: $(PERL-EMAIL-ADDRESS_BUILD_DIR)/.configured

$(PERL-EMAIL-ADDRESS_BUILD_DIR)/.built: $(PERL-EMAIL-ADDRESS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-email-address: $(PERL-EMAIL-ADDRESS_BUILD_DIR)/.built

$(PERL-EMAIL-ADDRESS_BUILD_DIR)/.staged: $(PERL-EMAIL-ADDRESS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-email-address-stage: $(PERL-EMAIL-ADDRESS_BUILD_DIR)/.staged

$(PERL-EMAIL-ADDRESS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-email-address" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EMAIL-ADDRESS_PRIORITY)" >>$@
	@echo "Section: $(PERL-EMAIL-ADDRESS_SECTION)" >>$@
	@echo "Version: $(PERL-EMAIL-ADDRESS_VERSION)-$(PERL-EMAIL-ADDRESS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EMAIL-ADDRESS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EMAIL-ADDRESS_SITE)/$(PERL-EMAIL-ADDRESS_SOURCE)" >>$@
	@echo "Description: $(PERL-EMAIL-ADDRESS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EMAIL-ADDRESS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EMAIL-ADDRESS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EMAIL-ADDRESS_CONFLICTS)" >>$@

$(PERL-EMAIL-ADDRESS_IPK): $(PERL-EMAIL-ADDRESS_BUILD_DIR)/.built
	rm -rf $(PERL-EMAIL-ADDRESS_IPK_DIR) $(BUILD_DIR)/perl-email-address_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EMAIL-ADDRESS_BUILD_DIR) DESTDIR=$(PERL-EMAIL-ADDRESS_IPK_DIR) install
	find $(PERL-EMAIL-ADDRESS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-EMAIL-ADDRESS_IPK_DIR)/CONTROL/control
	echo $(PERL-EMAIL-ADDRESS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EMAIL-ADDRESS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EMAIL-ADDRESS_IPK_DIR)

perl-email-address-ipk: $(PERL-EMAIL-ADDRESS_IPK)

perl-email-address-clean:
	-$(MAKE) -C $(PERL-EMAIL-ADDRESS_BUILD_DIR) clean

perl-email-address-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-ADDRESS_DIR) $(PERL-EMAIL-ADDRESS_BUILD_DIR) $(PERL-EMAIL-ADDRESS_IPK_DIR) $(PERL-EMAIL-ADDRESS_IPK)
