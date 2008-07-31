###########################################################
#
# perl-digest-sha
#
###########################################################

PERL-DIGEST-SHA_SITE=http://search.cpan.org/CPAN/authors/id//M/MS/MSHELOR
PERL-DIGEST-SHA_VERSION=5.47
PERL-DIGEST-SHA_SOURCE=Digest-SHA-$(PERL-DIGEST-SHA_VERSION).tar.gz
PERL-DIGEST-SHA_DIR=Digest-SHA-$(PERL-DIGEST-SHA_VERSION)
PERL-DIGEST-SHA_UNZIP=zcat
PERL-DIGEST-SHA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DIGEST-SHA_DESCRIPTION=Digest-SHA - Perl extension for SHA-1/224/256/384/512.
PERL-DIGEST-SHA_SECTION=util
PERL-DIGEST-SHA_PRIORITY=optional
PERL-DIGEST-SHA_DEPENDS=perl
PERL-DIGEST-SHA_SUGGESTS=
PERL-DIGEST-SHA_CONFLICTS=

PERL-DIGEST-SHA_IPK_VERSION=1

PERL-DIGEST-SHA_CONFFILES=

PERL-DIGEST-SHA_BUILD_DIR=$(BUILD_DIR)/perl-digest-sha
PERL-DIGEST-SHA_SOURCE_DIR=$(SOURCE_DIR)/perl-digest-sha
PERL-DIGEST-SHA_IPK_DIR=$(BUILD_DIR)/perl-digest-sha-$(PERL-DIGEST-SHA_VERSION)-ipk
PERL-DIGEST-SHA_IPK=$(BUILD_DIR)/perl-digest-sha_$(PERL-DIGEST-SHA_VERSION)-$(PERL-DIGEST-SHA_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DIGEST-SHA_SOURCE):
	$(WGET) -P $(@D) $(PERL-DIGEST-SHA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-digest-sha-source: $(DL_DIR)/$(PERL-DIGEST-SHA_SOURCE) $(PERL-DIGEST-SHA_PATCHES)

$(PERL-DIGEST-SHA_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DIGEST-SHA_SOURCE) $(PERL-DIGEST-SHA_PATCHES) make/perl-digest-sha.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-SHA_DIR) $(@D)
	$(PERL-DIGEST-SHA_UNZIP) $(DL_DIR)/$(PERL-DIGEST-SHA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DIGEST-SHA_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DIGEST-SHA_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DIGEST-SHA_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-digest-sha-unpack: $(PERL-DIGEST-SHA_BUILD_DIR)/.configured

$(PERL-DIGEST-SHA_BUILD_DIR)/.built: $(PERL-DIGEST-SHA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		$(PERL_INC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-digest-sha: $(PERL-DIGEST-SHA_BUILD_DIR)/.built

$(PERL-DIGEST-SHA_BUILD_DIR)/.staged: $(PERL-DIGEST-SHA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-DIGEST-SHA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-digest-sha-stage: $(PERL-DIGEST-SHA_BUILD_DIR)/.staged

$(PERL-DIGEST-SHA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-digest-sha" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DIGEST-SHA_PRIORITY)" >>$@
	@echo "Section: $(PERL-DIGEST-SHA_SECTION)" >>$@
	@echo "Version: $(PERL-DIGEST-SHA_VERSION)-$(PERL-DIGEST-SHA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DIGEST-SHA_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DIGEST-SHA_SITE)/$(PERL-DIGEST-SHA_SOURCE)" >>$@
	@echo "Description: $(PERL-DIGEST-SHA_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DIGEST-SHA_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DIGEST-SHA_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DIGEST-SHA_CONFLICTS)" >>$@

$(PERL-DIGEST-SHA_IPK): $(PERL-DIGEST-SHA_BUILD_DIR)/.built
	rm -rf $(PERL-DIGEST-SHA_IPK_DIR) $(BUILD_DIR)/perl-digest-sha_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DIGEST-SHA_BUILD_DIR) DESTDIR=$(PERL-DIGEST-SHA_IPK_DIR) install
	find $(PERL-DIGEST-SHA_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DIGEST-SHA_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DIGEST-SHA_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DIGEST-SHA_IPK_DIR)/CONTROL/control
	echo $(PERL-DIGEST-SHA_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DIGEST-SHA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DIGEST-SHA_IPK_DIR)

perl-digest-sha-ipk: $(PERL-DIGEST-SHA_IPK)

perl-digest-sha-clean:
	-$(MAKE) -C $(PERL-DIGEST-SHA_BUILD_DIR) clean

perl-digest-sha-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-SHA_DIR) $(PERL-DIGEST-SHA_BUILD_DIR) $(PERL-DIGEST-SHA_IPK_DIR) $(PERL-DIGEST-SHA_IPK)

perl-digest-sha-check: $(PERL-DIGEST-SHA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DIGEST-SHA_IPK)
