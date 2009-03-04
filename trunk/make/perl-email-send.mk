###########################################################
#
# perl-email-send
#
###########################################################

PERL-EMAIL-SEND_SITE=http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS
PERL-EMAIL-SEND_VERSION=2.194
PERL-EMAIL-SEND_SOURCE=Email-Send-$(PERL-EMAIL-SEND_VERSION).tar.gz
PERL-EMAIL-SEND_DIR=Email-Send-$(PERL-EMAIL-SEND_VERSION)
PERL-EMAIL-SEND_UNZIP=zcat
PERL-EMAIL-SEND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EMAIL-SEND_DESCRIPTION=Simply Sending Email.
PERL-EMAIL-SEND_SECTION=email
PERL-EMAIL-SEND_PRIORITY=optional
PERL-EMAIL-SEND_DEPENDS=perl
PERL-EMAIL-SEND_SUGGESTS=
PERL-EMAIL-SEND_CONFLICTS=

PERL-EMAIL-SEND_IPK_VERSION=1

PERL-EMAIL-SEND_CONFFILES=

PERL-EMAIL-SEND_BUILD_DIR=$(BUILD_DIR)/perl-email-send
PERL-EMAIL-SEND_SOURCE_DIR=$(SOURCE_DIR)/perl-email-send
PERL-EMAIL-SEND_IPK_DIR=$(BUILD_DIR)/perl-email-send-$(PERL-EMAIL-SEND_VERSION)-ipk
PERL-EMAIL-SEND_IPK=$(BUILD_DIR)/perl-email-send_$(PERL-EMAIL-SEND_VERSION)-$(PERL-EMAIL-SEND_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EMAIL-SEND_SOURCE):
	$(WGET) -P $(@D) $(PERL-EMAIL-SEND_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-email-send-source: $(DL_DIR)/$(PERL-EMAIL-SEND_SOURCE) $(PERL-EMAIL-SEND_PATCHES)

$(PERL-EMAIL-SEND_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EMAIL-SEND_SOURCE) $(PERL-EMAIL-SEND_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-SEND_DIR) $(@D)
	$(PERL-EMAIL-SEND_UNZIP) $(DL_DIR)/$(PERL-EMAIL-SEND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EMAIL-SEND_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-EMAIL-SEND_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EMAIL-SEND_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-email-send-unpack: $(PERL-EMAIL-SEND_BUILD_DIR)/.configured

$(PERL-EMAIL-SEND_BUILD_DIR)/.built: $(PERL-EMAIL-SEND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-email-send: $(PERL-EMAIL-SEND_BUILD_DIR)/.built

$(PERL-EMAIL-SEND_BUILD_DIR)/.staged: $(PERL-EMAIL-SEND_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-email-send-stage: $(PERL-EMAIL-SEND_BUILD_DIR)/.staged

$(PERL-EMAIL-SEND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-email-send" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EMAIL-SEND_PRIORITY)" >>$@
	@echo "Section: $(PERL-EMAIL-SEND_SECTION)" >>$@
	@echo "Version: $(PERL-EMAIL-SEND_VERSION)-$(PERL-EMAIL-SEND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EMAIL-SEND_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EMAIL-SEND_SITE)/$(PERL-EMAIL-SEND_SOURCE)" >>$@
	@echo "Description: $(PERL-EMAIL-SEND_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EMAIL-SEND_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EMAIL-SEND_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EMAIL-SEND_CONFLICTS)" >>$@

$(PERL-EMAIL-SEND_IPK): $(PERL-EMAIL-SEND_BUILD_DIR)/.built
	rm -rf $(PERL-EMAIL-SEND_IPK_DIR) $(BUILD_DIR)/perl-email-send_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EMAIL-SEND_BUILD_DIR) DESTDIR=$(PERL-EMAIL-SEND_IPK_DIR) install
	$(MAKE) $(PERL-EMAIL-SEND_IPK_DIR)/CONTROL/control
	echo $(PERL-EMAIL-SEND_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EMAIL-SEND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EMAIL-SEND_IPK_DIR)

perl-email-send-ipk: $(PERL-EMAIL-SEND_IPK)

perl-email-send-clean:
	-$(MAKE) -C $(PERL-EMAIL-SEND_BUILD_DIR) clean

perl-email-send-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-SEND_DIR) $(PERL-EMAIL-SEND_BUILD_DIR) $(PERL-EMAIL-SEND_IPK_DIR) $(PERL-EMAIL-SEND_IPK)
