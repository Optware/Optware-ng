###########################################################
#
# perl-digest-sha1
#
###########################################################

PERL-DIGEST-SHA1_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-DIGEST-SHA1_VERSION=2.11
PERL-DIGEST-SHA1_SOURCE=Digest-SHA1-$(PERL-DIGEST-SHA1_VERSION).tar.gz
PERL-DIGEST-SHA1_DIR=Digest-SHA1-$(PERL-DIGEST-SHA1_VERSION)
PERL-DIGEST-SHA1_UNZIP=zcat
PERL-DIGEST-SHA1_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DIGEST-SHA1_DESCRIPTION=The module allows you to use the NIST SHA-1 message digest algorithm.
PERL-DIGEST-SHA1_SECTION=util
PERL-DIGEST-SHA1_PRIORITY=optional
PERL-DIGEST-SHA1_DEPENDS=perl
PERL-DIGEST-SHA1_SUGGESTS=
PERL-DIGEST-SHA1_CONFLICTS=

PERL-DIGEST-SHA1_IPK_VERSION=3

PERL-DIGEST-SHA1_CONFFILES=

PERL-DIGEST-SHA1_BUILD_DIR=$(BUILD_DIR)/perl-digest-sha1
PERL-DIGEST-SHA1_SOURCE_DIR=$(SOURCE_DIR)/perl-digest-sha1
PERL-DIGEST-SHA1_IPK_DIR=$(BUILD_DIR)/perl-digest-sha1-$(PERL-DIGEST-SHA1_VERSION)-ipk
PERL-DIGEST-SHA1_IPK=$(BUILD_DIR)/perl-digest-sha1_$(PERL-DIGEST-SHA1_VERSION)-$(PERL-DIGEST-SHA1_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE):
	$(WGET) -P $(@D) $(PERL-DIGEST_SHA1_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-digest-sha1-source: $(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE) $(PERL-DIGEST-SHA1_PATCHES)

$(PERL-DIGEST-SHA1_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE) $(PERL-DIGEST-SHA1_PATCHES) make/perl-digest-sha1.mk
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-SHA1_DIR) $(@D)
	$(PERL-DIGEST-SHA1_UNZIP) $(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-DIGEST-SHA1_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-digest-sha1-unpack: $(PERL-DIGEST-SHA1_BUILD_DIR)/.configured

$(PERL-DIGEST-SHA1_BUILD_DIR)/.built: $(PERL-DIGEST-SHA1_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		$(PERL_INC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-digest-sha1: $(PERL-DIGEST-SHA1_BUILD_DIR)/.built

$(PERL-DIGEST-SHA1_BUILD_DIR)/.staged: $(PERL-DIGEST-SHA1_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-digest-sha1-stage: $(PERL-DIGEST-SHA1_BUILD_DIR)/.staged

$(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-digest-sha1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DIGEST-SHA1_PRIORITY)" >>$@
	@echo "Section: $(PERL-DIGEST-SHA1_SECTION)" >>$@
	@echo "Version: $(PERL-DIGEST-SHA1_VERSION)-$(PERL-DIGEST-SHA1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DIGEST-SHA1_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DIGEST-SHA1_SITE)/$(PERL-DIGEST-SHA1_SOURCE)" >>$@
	@echo "Description: $(PERL-DIGEST-SHA1_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DIGEST-SHA1_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DIGEST-SHA1_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DIGEST-SHA1_CONFLICTS)" >>$@

$(PERL-DIGEST-SHA1_IPK): $(PERL-DIGEST-SHA1_BUILD_DIR)/.built
	rm -rf $(PERL-DIGEST-SHA1_IPK_DIR) $(BUILD_DIR)/perl-digest-sha1_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) DESTDIR=$(PERL-DIGEST-SHA1_IPK_DIR) install
	find $(PERL-DIGEST-SHA1_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DIGEST-SHA1_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DIGEST-SHA1_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/control
	echo $(PERL-DIGEST-SHA1_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DIGEST-SHA1_IPK_DIR)

perl-digest-sha1-ipk: $(PERL-DIGEST-SHA1_IPK)

perl-digest-sha1-clean:
	-$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) clean

perl-digest-sha1-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-SHA1_DIR) $(PERL-DIGEST-SHA1_BUILD_DIR) $(PERL-DIGEST-SHA1_IPK_DIR) $(PERL-DIGEST-SHA1_IPK)

perl-digest-sha1-check: $(PERL-DIGEST-SHA1_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DIGEST-SHA1_IPK)
