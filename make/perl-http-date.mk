###########################################################
#
# perl-http-date
#
###########################################################

PERL-HTTP-DATE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GA/GAAS
PERL-HTTP-DATE_VERSION=6.02
PERL-HTTP-DATE_SOURCE=HTTP-Date-$(PERL-HTTP-DATE_VERSION).tar.gz
PERL-HTTP-DATE_DIR=HTTP-Date-$(PERL-HTTP-DATE_VERSION)
PERL-HTTP-DATE_UNZIP=zcat
PERL-HTTP-DATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTTP-DATE_DESCRIPTION=date conversion routines
PERL-HTTP-DATE_SECTION=www
PERL-HTTP-DATE_PRIORITY=optional
PERL-HTTP-DATE_DEPENDS=perl-uri
PERL-HTTP-DATE_SUGGESTS=
PERL-HTTP-DATE_CONFLICTS=

PERL-HTTP-DATE_IPK_VERSION=4

PERL-HTTP-DATE_CONFFILES=

PERL-HTTP-DATE_BUILD_DIR=$(BUILD_DIR)/perl-http-date
PERL-HTTP-DATE_SOURCE_DIR=$(SOURCE_DIR)/perl-http-date
PERL-HTTP-DATE_IPK_DIR=$(BUILD_DIR)/perl-http-date-$(PERL-HTTP-DATE_VERSION)-ipk
PERL-HTTP-DATE_IPK=$(BUILD_DIR)/perl-http-date_$(PERL-HTTP-DATE_VERSION)-$(PERL-HTTP-DATE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTTP-DATE_SOURCE):
	$(WGET) -P $(@D) $(PERL-HTTP-DATE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-http-date-source: $(DL_DIR)/$(PERL-HTTP-DATE_SOURCE) $(PERL-HTTP-DATE_PATCHES)

$(PERL-HTTP-DATE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTTP-DATE_SOURCE) $(PERL-HTTP-DATE_PATCHES) make/perl-http-date.mk
	rm -rf $(BUILD_DIR)/$(PERL-HTTP-DATE_DIR) $(PERL-HTTP-DATE_BUILD_DIR)
	$(PERL-HTTP-DATE_UNZIP) $(DL_DIR)/$(PERL-HTTP-DATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTTP-DATE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-HTTP-DATE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTTP-DATE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-http-date-unpack: $(PERL-HTTP-DATE_BUILD_DIR)/.configured

$(PERL-HTTP-DATE_BUILD_DIR)/.built: $(PERL-HTTP-DATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-http-date: $(PERL-HTTP-DATE_BUILD_DIR)/.built

$(PERL-HTTP-DATE_BUILD_DIR)/.staged: $(PERL-HTTP-DATE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-http-date-stage: $(PERL-HTTP-DATE_BUILD_DIR)/.staged

$(PERL-HTTP-DATE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-http-date" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTTP-DATE_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTTP-DATE_SECTION)" >>$@
	@echo "Version: $(PERL-HTTP-DATE_VERSION)-$(PERL-HTTP-DATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTTP-DATE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTTP-DATE_SITE)/$(PERL-HTTP-DATE_SOURCE)" >>$@
	@echo "Description: $(PERL-HTTP-DATE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTTP-DATE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-HTTP-DATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-HTTP-DATE_CONFLICTS)" >>$@

$(PERL-HTTP-DATE_IPK): $(PERL-HTTP-DATE_BUILD_DIR)/.built
	rm -rf $(PERL-HTTP-DATE_IPK_DIR) $(BUILD_DIR)/perl-http-date_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTTP-DATE_BUILD_DIR) DESTDIR=$(PERL-HTTP-DATE_IPK_DIR) install
	find $(PERL-HTTP-DATE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTTP-DATE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTTP-DATE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTTP-DATE_IPK_DIR)/CONTROL/control
	echo $(PERL-HTTP-DATE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTTP-DATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTTP-DATE_IPK_DIR)

perl-http-date-ipk: $(PERL-HTTP-DATE_IPK)

perl-http-date-clean:
	-$(MAKE) -C $(PERL-HTTP-DATE_BUILD_DIR) clean

perl-http-date-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTTP-DATE_DIR) $(PERL-HTTP-DATE_BUILD_DIR) $(PERL-HTTP-DATE_IPK_DIR) $(PERL-HTTP-DATE_IPK)
