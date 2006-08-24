###########################################################
#
# perl-digest-hmac
#
###########################################################

PERL-DIGEST-HMAC_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-DIGEST-HMAC_VERSION=1.01
PERL-DIGEST-HMAC_SOURCE=Digest-HMAC-$(PERL-DIGEST-HMAC_VERSION).tar.gz
PERL-DIGEST-HMAC_DIR=Digest-HMAC-$(PERL-DIGEST-HMAC_VERSION)
PERL-DIGEST-HMAC_UNZIP=zcat
PERL-DIGEST-HMAC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DIGEST-HMAC_DESCRIPTION=The module allows you to use the NIST SHA-1 message digest algorithm.
PERL-DIGEST-HMAC_SECTION=util
PERL-DIGEST-HMAC_PRIORITY=optional
PERL-DIGEST-HMAC_DEPENDS=perl, perl-digest-sha1
PERL-DIGEST-HMAC_SUGGESTS=
PERL-DIGEST-HMAC_CONFLICTS=

PERL-DIGEST-HMAC_IPK_VERSION=4

PERL-DIGEST-HMAC_CONFFILES=

PERL-DIGEST-HMAC_BUILD_DIR=$(BUILD_DIR)/perl-digest-hmac
PERL-DIGEST-HMAC_SOURCE_DIR=$(SOURCE_DIR)/perl-digest-hmac
PERL-DIGEST-HMAC_IPK_DIR=$(BUILD_DIR)/perl-digest-hmac-$(PERL-DIGEST-HMAC_VERSION)-ipk
PERL-DIGEST-HMAC_IPK=$(BUILD_DIR)/perl-digest-hmac_$(PERL-DIGEST-HMAC_VERSION)-$(PERL-DIGEST-HMAC_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DIGEST-HMAC_SITE)/$(PERL-DIGEST-HMAC_SOURCE)

perl-digest-hmac-source: $(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE) $(PERL-DIGEST-HMAC_PATCHES)

$(PERL-DIGEST-HMAC_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE) $(PERL-DIGEST-HMAC_PATCHES)
	$(MAKE) perl-digest-sha1-stage
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-HMAC_DIR) $(PERL-DIGEST-HMAC_BUILD_DIR)
	$(PERL-DIGEST-HMAC_UNZIP) $(DL_DIR)/$(PERL-DIGEST-HMAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-DIGEST-HMAC_DIR) $(PERL-DIGEST-HMAC_BUILD_DIR)
	(cd $(PERL-DIGEST-HMAC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DIGEST-HMAC_BUILD_DIR)/.configured

perl-digest-hmac-unpack: $(PERL-DIGEST-HMAC_BUILD_DIR)/.configured

$(PERL-DIGEST-HMAC_BUILD_DIR)/.built: $(PERL-DIGEST-HMAC_BUILD_DIR)/.configured
	rm -f $(PERL-DIGEST-HMAC_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-DIGEST-HMAC_BUILD_DIR)/.built

perl-digest-hmac: $(PERL-DIGEST-HMAC_BUILD_DIR)/.built

$(PERL-DIGEST-HMAC_BUILD_DIR)/.staged: $(PERL-DIGEST-HMAC_BUILD_DIR)/.built
	rm -f $(PERL-DIGEST-HMAC_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DIGEST-HMAC_BUILD_DIR)/.staged

perl-digest-hmac-stage: $(PERL-DIGEST-HMAC_BUILD_DIR)/.staged

$(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-digest-hmac" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DIGEST-HMAC_PRIORITY)" >>$@
	@echo "Section: $(PERL-DIGEST-HMAC_SECTION)" >>$@
	@echo "Version: $(PERL-DIGEST-HMAC_VERSION)-$(PERL-DIGEST-HMAC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DIGEST-HMAC_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DIGEST-HMAC_SITE)/$(PERL-DIGEST-HMAC_SOURCE)" >>$@
	@echo "Description: $(PERL-DIGEST-HMAC_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DIGEST-HMAC_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DIGEST-HMAC_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DIGEST-HMAC_CONFLICTS)" >>$@

$(PERL-DIGEST-HMAC_IPK): $(PERL-DIGEST-HMAC_BUILD_DIR)/.built
	rm -rf $(PERL-DIGEST-HMAC_IPK_DIR) $(BUILD_DIR)/perl-digest-hmac_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) DESTDIR=$(PERL-DIGEST-HMAC_IPK_DIR) install
	find $(PERL-DIGEST-HMAC_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DIGEST-HMAC_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DIGEST-HMAC_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/control
	echo $(PERL-DIGEST-HMAC_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DIGEST-HMAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DIGEST-HMAC_IPK_DIR)

perl-digest-hmac-ipk: $(PERL-DIGEST-HMAC_IPK)

perl-digest-hmac-clean:
	-$(MAKE) -C $(PERL-DIGEST-HMAC_BUILD_DIR) clean

perl-digest-hmac-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-HMAC_DIR) $(PERL-DIGEST-HMAC_BUILD_DIR) $(PERL-DIGEST-HMAC_IPK_DIR) $(PERL-DIGEST-HMAC_IPK)
