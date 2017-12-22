###########################################################
#
# perl-mozilla-ca
#
###########################################################

PERL_MOZILLA_CA_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/A/AB/ABH
PERL_MOZILLA_CA_UPSTREAM_VERSION=20160104
PERL_MOZILLA_CA_CERTS_VERSION=20171222
PERL_MOZILLA_CA_VERSION=$(PERL_MOZILLA_CA_UPSTREAM_VERSION)-certs$(PERL_MOZILLA_CA_CERTS_VERSION)
PERL_MOZILLA_CA_SOURCE=Mozilla-CA-$(PERL_MOZILLA_CA_UPSTREAM_VERSION).tar.gz
PERL_MOZILLA_CA_DIR=Mozilla-CA-$(PERL_MOZILLA_CA_UPSTREAM_VERSION)
PERL_MOZILLA_CA_UNZIP=zcat
PERL_MOZILLA_CA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_MOZILLA_CA_DESCRIPTION=Mozillas CA cert bundle in PEM format
PERL_MOZILLA_CA_SECTION=util
PERL_MOZILLA_CA_PRIORITY=optional
PERL_MOZILLA_CA_DEPENDS=
PERL_MOZILLA_CA_SUGGESTS=perl, perl-libwww
PERL_MOZILLA_CA_CONFLICTS=

PERL_MOZILLA_CA_IPK_VERSION=1

PERL_MOZILLA_CA_CONFFILES=

PERL_MOZILLA_CA_BUILD_DIR=$(BUILD_DIR)/perl-mozilla-ca
PERL_MOZILLA_CA_SOURCE_DIR=$(SOURCE_DIR)/perl-mozilla-ca
PERL_MOZILLA_CA_IPK_DIR=$(BUILD_DIR)/perl-mozilla-ca-$(PERL_MOZILLA_CA_VERSION)-ipk
PERL_MOZILLA_CA_IPK=$(BUILD_DIR)/perl-mozilla-ca_$(PERL_MOZILLA_CA_VERSION)-$(PERL_MOZILLA_CA_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL_MOZILLA_CA_SOURCE):
	$(WGET) -P $(@D) $(PERL_MOZILLA_CA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-mozilla-ca-source: $(DL_DIR)/$(PERL_MOZILLA_CA_SOURCE) $(PERL_MOZILLA_CA_PATCHES)

$(PERL_MOZILLA_CA_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_MOZILLA_CA_SOURCE) \
		$(PERL_MOZILLA_CA_PATCHES) make/perl-mozilla-ca.mk \
		$(PERL_MOZILLA_CA_SOURCE_DIR)/cacert.pem
	rm -rf $(BUILD_DIR)/$(PERL_MOZILLA_CA_DIR) $(@D)
	$(PERL_MOZILLA_CA_UNZIP) $(DL_DIR)/$(PERL_MOZILLA_CA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL_MOZILLA_CA_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL_MOZILLA_CA_DIR) -p1
	mv $(BUILD_DIR)/$(PERL_MOZILLA_CA_DIR) $(@D)
	cp -f $(PERL_MOZILLA_CA_SOURCE_DIR)/cacert.pem $(@D)/lib/Mozilla/CA/cacert.pem
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-mozilla-ca-unpack: $(PERL_MOZILLA_CA_BUILD_DIR)/.configured

$(PERL_MOZILLA_CA_BUILD_DIR)/.built: $(PERL_MOZILLA_CA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-mozilla-ca: $(PERL_MOZILLA_CA_BUILD_DIR)/.built

$(PERL_MOZILLA_CA_BUILD_DIR)/.staged: $(PERL_MOZILLA_CA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-mozilla-ca-stage: $(PERL_MOZILLA_CA_BUILD_DIR)/.staged

$(PERL_MOZILLA_CA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-mozilla-ca" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_MOZILLA_CA_PRIORITY)" >>$@
	@echo "Section: $(PERL_MOZILLA_CA_SECTION)" >>$@
	@echo "Version: $(PERL_MOZILLA_CA_VERSION)-$(PERL_MOZILLA_CA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_MOZILLA_CA_MAINTAINER)" >>$@
	@echo "Source: $(PERL_MOZILLA_CA_SITE)/$(PERL_MOZILLA_CA_SOURCE)" >>$@
	@echo "Description: $(PERL_MOZILLA_CA_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_MOZILLA_CA_DEPENDS)" >>$@
	@echo "Suggests: $(PERL_MOZILLA_CA_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL_MOZILLA_CA_CONFLICTS)" >>$@

$(PERL_MOZILLA_CA_IPK): $(PERL_MOZILLA_CA_BUILD_DIR)/.built
	rm -rf $(PERL_MOZILLA_CA_IPK_DIR) $(BUILD_DIR)/perl-mozilla-ca_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL_MOZILLA_CA_BUILD_DIR) DESTDIR=$(PERL_MOZILLA_CA_IPK_DIR) install
	find $(PERL_MOZILLA_CA_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	find $(PERL_MOZILLA_CA_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL_MOZILLA_CA_IPK_DIR)/CONTROL/control
	echo $(PERL_MOZILLA_CA_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_MOZILLA_CA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_MOZILLA_CA_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PERL_MOZILLA_CA_IPK_DIR)

perl-mozilla-ca-ipk: $(PERL_MOZILLA_CA_IPK)

perl-mozilla-ca-clean:
	-$(MAKE) -C $(PERL_MOZILLA_CA_BUILD_DIR) clean

perl-mozilla-ca-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_MOZILLA_CA_DIR) $(PERL_MOZILLA_CA_BUILD_DIR) $(PERL_MOZILLA_CA_IPK_DIR) $(PERL_MOZILLA_CA_IPK)
#
#
# Some sanity check for the package.
#
perl-mozilla-ca-check: $(PERL_MOZILLA_CA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
