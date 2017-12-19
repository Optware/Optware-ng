###########################################################
#
# perl-net-http
#
###########################################################

PERL-NET-HTTP_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/E/ET/ETHER
PERL-NET-HTTP_VERSION=6.09
PERL-NET-HTTP_SOURCE=Net-HTTP-$(PERL-NET-HTTP_VERSION).tar.gz
PERL-NET-HTTP_DIR=Net-HTTP-$(PERL-NET-HTTP_VERSION)
PERL-NET-HTTP_UNZIP=zcat
PERL-NET-HTTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-NET-HTTP_DESCRIPTION=Low-level HTTP connection (client)
PERL-NET-HTTP_SECTION=util
PERL-NET-HTTP_PRIORITY=optional
PERL-NET-HTTP_DEPENDS=
PERL-NET-HTTP_SUGGESTS=
PERL-NET-HTTP_CONFLICTS=

PERL-NET-HTTP_IPK_VERSION=4

PERL-NET-HTTP_CONFFILES=

PERL-NET-HTTP_BUILD_DIR=$(BUILD_DIR)/perl-net-http
PERL-NET-HTTP_SOURCE_DIR=$(SOURCE_DIR)/perl-net-http
PERL-NET-HTTP_IPK_DIR=$(BUILD_DIR)/perl-net-http-$(PERL-NET-HTTP_VERSION)-ipk
PERL-NET-HTTP_IPK=$(BUILD_DIR)/perl-net-http_$(PERL-NET-HTTP_VERSION)-$(PERL-NET-HTTP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-NET-HTTP_SOURCE):
	$(WGET) -P $(@D) $(PERL-NET-HTTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-net-http-source: $(DL_DIR)/$(PERL-NET-HTTP_SOURCE) $(PERL-NET-HTTP_PATCHES)

$(PERL-NET-HTTP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-HTTP_SOURCE) $(PERL-NET-HTTP_PATCHES) make/perl-net-http.mk
	rm -rf $(BUILD_DIR)/$(PERL-NET-HTTP_DIR) $(PERL-NET-HTTP_BUILD_DIR)
	$(PERL-NET-HTTP_UNZIP) $(DL_DIR)/$(PERL-NET-HTTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-NET-HTTP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-NET-HTTP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-NET-HTTP_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-net-http-unpack: $(PERL-NET-HTTP_BUILD_DIR)/.configured

$(PERL-NET-HTTP_BUILD_DIR)/.built: $(PERL-NET-HTTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-net-http: $(PERL-NET-HTTP_BUILD_DIR)/.built

$(PERL-NET-HTTP_BUILD_DIR)/.staged: $(PERL-NET-HTTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-net-http-stage: $(PERL-NET-HTTP_BUILD_DIR)/.staged

$(PERL-NET-HTTP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-net-http" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-NET-HTTP_PRIORITY)" >>$@
	@echo "Section: $(PERL-NET-HTTP_SECTION)" >>$@
	@echo "Version: $(PERL-NET-HTTP_VERSION)-$(PERL-NET-HTTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-NET-HTTP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-NET-HTTP_SITE)/$(PERL-NET-HTTP_SOURCE)" >>$@
	@echo "Description: $(PERL-NET-HTTP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-NET-HTTP_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-NET-HTTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-NET-HTTP_CONFLICTS)" >>$@

$(PERL-NET-HTTP_IPK): $(PERL-NET-HTTP_BUILD_DIR)/.built
	rm -rf $(PERL-NET-HTTP_IPK_DIR) $(BUILD_DIR)/perl-net-http_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-NET-HTTP_BUILD_DIR) DESTDIR=$(PERL-NET-HTTP_IPK_DIR) install
	find $(PERL-NET-HTTP_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-HTTP_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-HTTP_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-NET-HTTP_IPK_DIR)/CONTROL/control
	echo $(PERL-NET-HTTP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-HTTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-HTTP_IPK_DIR)

perl-net-http-ipk: $(PERL-NET-HTTP_IPK)

perl-net-http-clean:
	-$(MAKE) -C $(PERL-NET-HTTP_BUILD_DIR) clean

perl-net-http-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-HTTP_DIR) $(PERL-NET-HTTP_BUILD_DIR) $(PERL-NET-HTTP_IPK_DIR) $(PERL-NET-HTTP_IPK)
