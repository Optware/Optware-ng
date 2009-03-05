###########################################################
#
# perl-email-simple
#
###########################################################

PERL-EMAIL-SIMPLE_SITE=http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS
PERL-EMAIL-SIMPLE_VERSION=2.005
PERL-EMAIL-SIMPLE_SOURCE=Email-Simple-$(PERL-EMAIL-SIMPLE_VERSION).tar.gz
PERL-EMAIL-SIMPLE_DIR=Email-Simple-$(PERL-EMAIL-SIMPLE_VERSION)
PERL-EMAIL-SIMPLE_UNZIP=zcat
PERL-EMAIL-SIMPLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EMAIL-SIMPLE_DESCRIPTION=simple parsing of RFC2822 message format and headers.
PERL-EMAIL-SIMPLE_SECTION=email
PERL-EMAIL-SIMPLE_PRIORITY=optional
PERL-EMAIL-SIMPLE_DEPENDS=perl
PERL-EMAIL-SIMPLE_SUGGESTS=
PERL-EMAIL-SIMPLE_CONFLICTS=

PERL-EMAIL-SIMPLE_IPK_VERSION=1

PERL-EMAIL-SIMPLE_CONFFILES=

PERL-EMAIL-SIMPLE_BUILD_DIR=$(BUILD_DIR)/perl-email-simple
PERL-EMAIL-SIMPLE_SOURCE_DIR=$(SOURCE_DIR)/perl-email-simple
PERL-EMAIL-SIMPLE_IPK_DIR=$(BUILD_DIR)/perl-email-simple-$(PERL-EMAIL-SIMPLE_VERSION)-ipk
PERL-EMAIL-SIMPLE_IPK=$(BUILD_DIR)/perl-email-simple_$(PERL-EMAIL-SIMPLE_VERSION)-$(PERL-EMAIL-SIMPLE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EMAIL-SIMPLE_SOURCE):
	$(WGET) -P $(@D) $(PERL-EMAIL-SIMPLE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-email-simple-source: $(DL_DIR)/$(PERL-EMAIL-SIMPLE_SOURCE) $(PERL-EMAIL-SIMPLE_PATCHES)

$(PERL-EMAIL-SIMPLE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EMAIL-SIMPLE_SOURCE) $(PERL-EMAIL-SIMPLE_PATCHES) make/perl-email-simple.mk
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-SIMPLE_DIR) $(@D)
	$(PERL-EMAIL-SIMPLE_UNZIP) $(DL_DIR)/$(PERL-EMAIL-SIMPLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EMAIL-SIMPLE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-EMAIL-SIMPLE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EMAIL-SIMPLE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-email-simple-unpack: $(PERL-EMAIL-SIMPLE_BUILD_DIR)/.configured

$(PERL-EMAIL-SIMPLE_BUILD_DIR)/.built: $(PERL-EMAIL-SIMPLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-email-simple: $(PERL-EMAIL-SIMPLE_BUILD_DIR)/.built

$(PERL-EMAIL-SIMPLE_BUILD_DIR)/.staged: $(PERL-EMAIL-SIMPLE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-email-simple-stage: $(PERL-EMAIL-SIMPLE_BUILD_DIR)/.staged

$(PERL-EMAIL-SIMPLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-email-simple" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EMAIL-SIMPLE_PRIORITY)" >>$@
	@echo "Section: $(PERL-EMAIL-SIMPLE_SECTION)" >>$@
	@echo "Version: $(PERL-EMAIL-SIMPLE_VERSION)-$(PERL-EMAIL-SIMPLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EMAIL-SIMPLE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EMAIL-SIMPLE_SITE)/$(PERL-EMAIL-SIMPLE_SOURCE)" >>$@
	@echo "Description: $(PERL-EMAIL-SIMPLE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EMAIL-SIMPLE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EMAIL-SIMPLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EMAIL-SIMPLE_CONFLICTS)" >>$@

$(PERL-EMAIL-SIMPLE_IPK): $(PERL-EMAIL-SIMPLE_BUILD_DIR)/.built
	rm -rf $(PERL-EMAIL-SIMPLE_IPK_DIR) $(BUILD_DIR)/perl-email-simple_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EMAIL-SIMPLE_BUILD_DIR) DESTDIR=$(PERL-EMAIL-SIMPLE_IPK_DIR) install
	find $(PERL-EMAIL-SIMPLE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-EMAIL-SIMPLE_IPK_DIR)/CONTROL/control
	echo $(PERL-EMAIL-SIMPLE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EMAIL-SIMPLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EMAIL-SIMPLE_IPK_DIR)

perl-email-simple-ipk: $(PERL-EMAIL-SIMPLE_IPK)

perl-email-simple-clean:
	-$(MAKE) -C $(PERL-EMAIL-SIMPLE_BUILD_DIR) clean

perl-email-simple-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-SIMPLE_DIR) $(PERL-EMAIL-SIMPLE_BUILD_DIR) $(PERL-EMAIL-SIMPLE_IPK_DIR) $(PERL-EMAIL-SIMPLE_IPK)
