###########################################################
#
# perl-mozilla-ca
#
###########################################################

PERL-MOZILLA-CA_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/A/AB/ABH
PERL-MOZILLA-CA_VERSION=20160104
PERL-MOZILLA-CA_SOURCE=Mozilla-CA-$(PERL-MOZILLA-CA_VERSION).tar.gz
PERL-MOZILLA-CA_DIR=Mozilla-CA-$(PERL-MOZILLA-CA_VERSION)
PERL-MOZILLA-CA_UNZIP=zcat
PERL-MOZILLA-CA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MOZILLA-CA_DESCRIPTION=Mozillas CA cert bundle in PEM format
PERL-MOZILLA-CA_SECTION=util
PERL-MOZILLA-CA_PRIORITY=optional
PERL-MOZILLA-CA_DEPENDS=
PERL-MOZILLA-CA_SUGGESTS=
PERL-MOZILLA-CA_CONFLICTS=

PERL-MOZILLA-CA_IPK_VERSION=1

PERL-MOZILLA-CA_CONFFILES=

PERL-MOZILLA-CA_BUILD_DIR=$(BUILD_DIR)/perl-mozilla-ca
PERL-MOZILLA-CA_SOURCE_DIR=$(SOURCE_DIR)/perl-mozilla-ca
PERL-MOZILLA-CA_IPK_DIR=$(BUILD_DIR)/perl-mozilla-ca-$(PERL-MOZILLA-CA_VERSION)-ipk
PERL-MOZILLA-CA_IPK=$(BUILD_DIR)/perl-mozilla-ca_$(PERL-MOZILLA-CA_VERSION)-$(PERL-MOZILLA-CA_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MOZILLA-CA_SOURCE):
	$(WGET) -P $(@D) $(PERL-MOZILLA-CA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-mozilla-ca-source: $(DL_DIR)/$(PERL-MOZILLA-CA_SOURCE) $(PERL-MOZILLA-CA_PATCHES)

$(PERL-MOZILLA-CA_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MOZILLA-CA_SOURCE) $(PERL-MOZILLA-CA_PATCHES) make/perl-mozilla-ca.mk
	rm -rf $(BUILD_DIR)/$(PERL-MOZILLA-CA_DIR) $(PERL-MOZILLA-CA_BUILD_DIR)
	$(PERL-MOZILLA-CA_UNZIP) $(DL_DIR)/$(PERL-MOZILLA-CA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-MOZILLA-CA_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-MOZILLA-CA_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MOZILLA-CA_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-mozilla-ca-unpack: $(PERL-MOZILLA-CA_BUILD_DIR)/.configured

$(PERL-MOZILLA-CA_BUILD_DIR)/.built: $(PERL-MOZILLA-CA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-mozilla-ca: $(PERL-MOZILLA-CA_BUILD_DIR)/.built

$(PERL-MOZILLA-CA_BUILD_DIR)/.staged: $(PERL-MOZILLA-CA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-mozilla-ca-stage: $(PERL-MOZILLA-CA_BUILD_DIR)/.staged

$(PERL-MOZILLA-CA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-mozilla-ca" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MOZILLA-CA_PRIORITY)" >>$@
	@echo "Section: $(PERL-MOZILLA-CA_SECTION)" >>$@
	@echo "Version: $(PERL-MOZILLA-CA_VERSION)-$(PERL-MOZILLA-CA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MOZILLA-CA_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MOZILLA-CA_SITE)/$(PERL-MOZILLA-CA_SOURCE)" >>$@
	@echo "Description: $(PERL-MOZILLA-CA_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MOZILLA-CA_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MOZILLA-CA_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MOZILLA-CA_CONFLICTS)" >>$@

$(PERL-MOZILLA-CA_IPK): $(PERL-MOZILLA-CA_BUILD_DIR)/.built
	rm -rf $(PERL-MOZILLA-CA_IPK_DIR) $(BUILD_DIR)/perl-mozilla-ca_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MOZILLA-CA_BUILD_DIR) DESTDIR=$(PERL-MOZILLA-CA_IPK_DIR) install
	find $(PERL-MOZILLA-CA_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MOZILLA-CA_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MOZILLA-CA_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-MOZILLA-CA_IPK_DIR)/CONTROL/control
	echo $(PERL-MOZILLA-CA_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MOZILLA-CA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MOZILLA-CA_IPK_DIR)

perl-mozilla-ca-ipk: $(PERL-MOZILLA-CA_IPK)

perl-mozilla-ca-clean:
	-$(MAKE) -C $(PERL-MOZILLA-CA_BUILD_DIR) clean

perl-mozilla-ca-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MOZILLA-CA_DIR) $(PERL-MOZILLA-CA_BUILD_DIR) $(PERL-MOZILLA-CA_IPK_DIR) $(PERL-MOZILLA-CA_IPK)
