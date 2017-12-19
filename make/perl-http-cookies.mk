###########################################################
#
# perl-http-cookies
#
###########################################################

PERL-HTTP-COOKIES_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GA/GAAS
PERL-HTTP-COOKIES_VERSION=6.01
PERL-HTTP-COOKIES_SOURCE=HTTP-Cookies-$(PERL-HTTP-COOKIES_VERSION).tar.gz
PERL-HTTP-COOKIES_DIR=HTTP-Cookies-$(PERL-HTTP-COOKIES_VERSION)
PERL-HTTP-COOKIES_UNZIP=zcat
PERL-HTTP-COOKIES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTTP-COOKIES_DESCRIPTION=HTTP cookie jars
PERL-HTTP-COOKIES_SECTION=www
PERL-HTTP-COOKIES_PRIORITY=optional
PERL-HTTP-COOKIES_DEPENDS=
PERL-HTTP-COOKIES_SUGGESTS=
PERL-HTTP-COOKIES_CONFLICTS=

PERL-HTTP-COOKIES_IPK_VERSION=4

PERL-HTTP-COOKIES_CONFFILES=

PERL-HTTP-COOKIES_BUILD_DIR=$(BUILD_DIR)/perl-http-cookies
PERL-HTTP-COOKIES_SOURCE_DIR=$(SOURCE_DIR)/perl-http-cookies
PERL-HTTP-COOKIES_IPK_DIR=$(BUILD_DIR)/perl-http-cookies-$(PERL-HTTP-COOKIES_VERSION)-ipk
PERL-HTTP-COOKIES_IPK=$(BUILD_DIR)/perl-http-cookies_$(PERL-HTTP-COOKIES_VERSION)-$(PERL-HTTP-COOKIES_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTTP-COOKIES_SOURCE):
	$(WGET) -P $(@D) $(PERL-HTTP-COOKIES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-http-cookies-source: $(DL_DIR)/$(PERL-HTTP-COOKIES_SOURCE) $(PERL-HTTP-COOKIES_PATCHES)

$(PERL-HTTP-COOKIES_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTTP-COOKIES_SOURCE) $(PERL-HTTP-COOKIES_PATCHES) make/perl-http-cookies.mk
	rm -rf $(BUILD_DIR)/$(PERL-HTTP-COOKIES_DIR) $(PERL-HTTP-COOKIES_BUILD_DIR)
	$(PERL-HTTP-COOKIES_UNZIP) $(DL_DIR)/$(PERL-HTTP-COOKIES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTTP-COOKIES_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-HTTP-COOKIES_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTTP-COOKIES_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-http-cookies-unpack: $(PERL-HTTP-COOKIES_BUILD_DIR)/.configured

$(PERL-HTTP-COOKIES_BUILD_DIR)/.built: $(PERL-HTTP-COOKIES_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-http-cookies: $(PERL-HTTP-COOKIES_BUILD_DIR)/.built

$(PERL-HTTP-COOKIES_BUILD_DIR)/.staged: $(PERL-HTTP-COOKIES_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-http-cookies-stage: $(PERL-HTTP-COOKIES_BUILD_DIR)/.staged

$(PERL-HTTP-COOKIES_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-http-cookies" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTTP-COOKIES_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTTP-COOKIES_SECTION)" >>$@
	@echo "Version: $(PERL-HTTP-COOKIES_VERSION)-$(PERL-HTTP-COOKIES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTTP-COOKIES_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTTP-COOKIES_SITE)/$(PERL-HTTP-COOKIES_SOURCE)" >>$@
	@echo "Description: $(PERL-HTTP-COOKIES_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTTP-COOKIES_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-HTTP-COOKIES_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-HTTP-COOKIES_CONFLICTS)" >>$@

$(PERL-HTTP-COOKIES_IPK): $(PERL-HTTP-COOKIES_BUILD_DIR)/.built
	rm -rf $(PERL-HTTP-COOKIES_IPK_DIR) $(BUILD_DIR)/perl-http-cookies_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTTP-COOKIES_BUILD_DIR) DESTDIR=$(PERL-HTTP-COOKIES_IPK_DIR) install
	find $(PERL-HTTP-COOKIES_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTTP-COOKIES_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTTP-COOKIES_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTTP-COOKIES_IPK_DIR)/CONTROL/control
	echo $(PERL-HTTP-COOKIES_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTTP-COOKIES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTTP-COOKIES_IPK_DIR)

perl-http-cookies-ipk: $(PERL-HTTP-COOKIES_IPK)

perl-http-cookies-clean:
	-$(MAKE) -C $(PERL-HTTP-COOKIES_BUILD_DIR) clean

perl-http-cookies-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTTP-COOKIES_DIR) $(PERL-HTTP-COOKIES_BUILD_DIR) $(PERL-HTTP-COOKIES_IPK_DIR) $(PERL-HTTP-COOKIES_IPK)
