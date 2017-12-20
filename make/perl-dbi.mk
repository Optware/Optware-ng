###########################################################
#
# perl-dbi
#
###########################################################

PERL-DBI_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/T/TI/TIMB
PERL-DBI_VERSION=1.632
PERL-DBI_SOURCE=DBI-$(PERL-DBI_VERSION).tar.gz
PERL-DBI_DIR=DBI-$(PERL-DBI_VERSION)
PERL-DBI_UNZIP=zcat
PERL-DBI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DBI_DESCRIPTION=DBI - The Perl Database Interface by Tim Bunce.
PERL-DBI_SECTION=util
PERL-DBI_PRIORITY=optional
PERL-DBI_DEPENDS=perl
PERL-DBI_SUGGESTS=
PERL-DBI_CONFLICTS=

PERL-DBI_IPK_VERSION=3

PERL-DBI_CONFFILES=

PERL-DBI_BUILD_DIR=$(BUILD_DIR)/perl-dbi
PERL-DBI_SOURCE_DIR=$(SOURCE_DIR)/perl-dbi
PERL-DBI_IPK_DIR=$(BUILD_DIR)/perl-dbi-$(PERL-DBI_VERSION)-ipk
PERL-DBI_IPK=$(BUILD_DIR)/perl-dbi_$(PERL-DBI_VERSION)-$(PERL-DBI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DBI_SOURCE):
	$(WGET) -P $(@D) $(PERL-DBI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-dbi-source: $(DL_DIR)/$(PERL-DBI_SOURCE) $(PERL-DBI_PATCHES)

$(PERL-DBI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DBI_SOURCE) $(PERL-DBI_PATCHES) make/perl-dbi.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DBI_DIR) $(@D)
	$(PERL-DBI_UNZIP) $(DL_DIR)/$(PERL-DBI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DBI_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-DBI_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DBI_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-dbi-unpack: $(PERL-DBI_BUILD_DIR)/.configured

$(PERL-DBI_BUILD_DIR)/.built: $(PERL-DBI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-dbi: $(PERL-DBI_BUILD_DIR)/.built

$(PERL-DBI_BUILD_DIR)/.staged: $(PERL-DBI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-dbi-stage: $(PERL-DBI_BUILD_DIR)/.staged

$(PERL-DBI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-dbi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DBI_PRIORITY)" >>$@
	@echo "Section: $(PERL-DBI_SECTION)" >>$@
	@echo "Version: $(PERL-DBI_VERSION)-$(PERL-DBI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DBI_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DBI_SITE)/$(PERL-DBI_SOURCE)" >>$@
	@echo "Description: $(PERL-DBI_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DBI_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DBI_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DBI_CONFLICTS)" >>$@

$(PERL-DBI_IPK): $(PERL-DBI_BUILD_DIR)/.built
	rm -rf $(PERL-DBI_IPK_DIR) $(BUILD_DIR)/perl-dbi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DBI_BUILD_DIR) DESTDIR=$(PERL-DBI_IPK_DIR) install
	find $(PERL-DBI_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DBI_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DBI_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DBI_IPK_DIR)/CONTROL/control
	echo $(PERL-DBI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DBI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DBI_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PERL-DBI_IPK_DIR)

perl-dbi-ipk: $(PERL-DBI_IPK)

perl-dbi-clean:
	-$(MAKE) -C $(PERL-DBI_BUILD_DIR) clean

perl-dbi-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DBI_DIR) $(PERL-DBI_BUILD_DIR) $(PERL-DBI_IPK_DIR) $(PERL-DBI_IPK)

perl-dbi-check: $(PERL-DBI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
