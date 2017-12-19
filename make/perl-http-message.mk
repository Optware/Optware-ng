###########################################################
#
# perl-http-message
#
###########################################################

PERL-HTTP-MESSAGE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/E/ET/ETHER
PERL-HTTP-MESSAGE_VERSION=6.11
PERL-HTTP-MESSAGE_SOURCE=HTTP-Message-$(PERL-HTTP-MESSAGE_VERSION).tar.gz
PERL-HTTP-MESSAGE_DIR=HTTP-Message-$(PERL-HTTP-MESSAGE_VERSION)
PERL-HTTP-MESSAGE_UNZIP=zcat
PERL-HTTP-MESSAGE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTTP-MESSAGE_DESCRIPTION=HTTP style request message
PERL-HTTP-MESSAGE_SECTION=www
PERL-HTTP-MESSAGE_PRIORITY=optional
PERL-HTTP-MESSAGE_DEPENDS=perl-uri, perl-http-date
PERL-HTTP-MESSAGE_SUGGESTS=
PERL-HTTP-MESSAGE_CONFLICTS=

PERL-HTTP-MESSAGE_IPK_VERSION=4

PERL-HTTP-MESSAGE_CONFFILES=

PERL-HTTP-MESSAGE_BUILD_DIR=$(BUILD_DIR)/perl-http-message
PERL-HTTP-MESSAGE_SOURCE_DIR=$(SOURCE_DIR)/perl-http-message
PERL-HTTP-MESSAGE_IPK_DIR=$(BUILD_DIR)/perl-http-message-$(PERL-HTTP-MESSAGE_VERSION)-ipk
PERL-HTTP-MESSAGE_IPK=$(BUILD_DIR)/perl-http-message_$(PERL-HTTP-MESSAGE_VERSION)-$(PERL-HTTP-MESSAGE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTTP-MESSAGE_SOURCE):
	$(WGET) -P $(@D) $(PERL-HTTP-MESSAGE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-http-message-source: $(DL_DIR)/$(PERL-HTTP-MESSAGE_SOURCE) $(PERL-HTTP-MESSAGE_PATCHES)

$(PERL-HTTP-MESSAGE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTTP-MESSAGE_SOURCE) $(PERL-HTTP-MESSAGE_PATCHES) make/perl-http-message.mk
	rm -rf $(BUILD_DIR)/$(PERL-HTTP-MESSAGE_DIR) $(PERL-HTTP-MESSAGE_BUILD_DIR)
	$(PERL-HTTP-MESSAGE_UNZIP) $(DL_DIR)/$(PERL-HTTP-MESSAGE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTTP-MESSAGE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-HTTP-MESSAGE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTTP-MESSAGE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-http-message-unpack: $(PERL-HTTP-MESSAGE_BUILD_DIR)/.configured

$(PERL-HTTP-MESSAGE_BUILD_DIR)/.built: $(PERL-HTTP-MESSAGE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-http-message: $(PERL-HTTP-MESSAGE_BUILD_DIR)/.built

$(PERL-HTTP-MESSAGE_BUILD_DIR)/.staged: $(PERL-HTTP-MESSAGE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-http-message-stage: $(PERL-HTTP-MESSAGE_BUILD_DIR)/.staged

$(PERL-HTTP-MESSAGE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-http-message" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTTP-MESSAGE_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTTP-MESSAGE_SECTION)" >>$@
	@echo "Version: $(PERL-HTTP-MESSAGE_VERSION)-$(PERL-HTTP-MESSAGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTTP-MESSAGE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTTP-MESSAGE_SITE)/$(PERL-HTTP-MESSAGE_SOURCE)" >>$@
	@echo "Description: $(PERL-HTTP-MESSAGE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTTP-MESSAGE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-HTTP-MESSAGE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-HTTP-MESSAGE_CONFLICTS)" >>$@

$(PERL-HTTP-MESSAGE_IPK): $(PERL-HTTP-MESSAGE_BUILD_DIR)/.built
	rm -rf $(PERL-HTTP-MESSAGE_IPK_DIR) $(BUILD_DIR)/perl-http-message_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTTP-MESSAGE_BUILD_DIR) DESTDIR=$(PERL-HTTP-MESSAGE_IPK_DIR) install
	find $(PERL-HTTP-MESSAGE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTTP-MESSAGE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTTP-MESSAGE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTTP-MESSAGE_IPK_DIR)/CONTROL/control
	echo $(PERL-HTTP-MESSAGE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTTP-MESSAGE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTTP-MESSAGE_IPK_DIR)

perl-http-message-ipk: $(PERL-HTTP-MESSAGE_IPK)

perl-http-message-clean:
	-$(MAKE) -C $(PERL-HTTP-MESSAGE_BUILD_DIR) clean

perl-http-message-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTTP-MESSAGE_DIR) $(PERL-HTTP-MESSAGE_BUILD_DIR) $(PERL-HTTP-MESSAGE_IPK_DIR) $(PERL-HTTP-MESSAGE_IPK)
