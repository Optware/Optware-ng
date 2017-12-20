###########################################################
#
# perl-date-manip
#
###########################################################

PERL-DATE-MANIP_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/S/SB/SBECK
PERL-DATE-MANIP_VERSION=6.48
PERL-DATE-MANIP_SOURCE=Date-Manip-$(PERL-DATE-MANIP_VERSION).tar.gz
PERL-DATE-MANIP_DIR=Date-Manip-$(PERL-DATE-MANIP_VERSION)
PERL-DATE-MANIP_UNZIP=zcat

PERL-DATE-MANIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DATE-MANIP_DESCRIPTION=date manipulation routines
PERL-DATE-MANIP_SECTION=util
PERL-DATE-MANIP_PRIORITY=optional
PERL-DATE-MANIP_DEPENDS=perl

PERL-DATE-MANIP_IPK_VERSION=3

PERL-DATE-MANIP_CONFFILES=

PERL-DATE-MANIP_PATCHES=

PERL-DATE-MANIP_BUILD_DIR=$(BUILD_DIR)/perl-date-manip
PERL-DATE-MANIP_SOURCE_DIR=$(SOURCE_DIR)/perl-date-manip
PERL-DATE-MANIP_IPK_DIR=$(BUILD_DIR)/perl-date-manip-$(PERL-DATE-MANIP_VERSION)-ipk
PERL-DATE-MANIP_IPK=$(BUILD_DIR)/perl-date-manip_$(PERL-DATE-MANIP_VERSION)-$(PERL-DATE-MANIP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DATE-MANIP_SOURCE):
	$(WGET) -P $(@D) $(PERL-DATE-MANIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-date-manip-source: $(DL_DIR)/$(PERL-DATE-MANIP_SOURCE) $(PERL-DATE-MANIP_PATCHES)

$(PERL-DATE-MANIP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DATE-MANIP_SOURCE) $(PERL-DATE-MANIP_PATCHES) make/perl-date-manip.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) $(PERL-DATE-MANIP_BUILD_DIR)
	$(PERL-DATE-MANIP_UNZIP) $(DL_DIR)/$(PERL-DATE-MANIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DATE-MANIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) $(PERL-DATE-MANIP_BUILD_DIR)
	(cd $(PERL-DATE-MANIP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-DATE-MANIP_BUILD_DIR)/.configured

perl-date-manip-unpack: $(PERL-DATE-MANIP_BUILD_DIR)/.configured

$(PERL-DATE-MANIP_BUILD_DIR)/.built: $(PERL-DATE-MANIP_BUILD_DIR)/.configured
	rm -f $(PERL-DATE-MANIP_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-DATE-MANIP_BUILD_DIR)/.built

perl-date-manip: $(PERL-DATE-MANIP_BUILD_DIR)/.built

$(PERL-DATE-MANIP_BUILD_DIR)/.staged: $(PERL-DATE-MANIP_BUILD_DIR)/.built
	rm -f $(PERL-DATE-MANIP_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DATE-MANIP_BUILD_DIR)/.staged

perl-date-manip-stage: $(PERL-DATE-MANIP_BUILD_DIR)/.staged

$(PERL-DATE-MANIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-DATE-MANIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-date-manip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DATE-MANIP_PRIORITY)" >>$@
	@echo "Section: $(PERL-DATE-MANIP_SECTION)" >>$@
	@echo "Version: $(PERL-DATE-MANIP_VERSION)-$(PERL-DATE-MANIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DATE-MANIP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DATE-MANIP_SITE)/$(PERL-DATE-MANIP_SOURCE)" >>$@
	@echo "Description: $(PERL-DATE-MANIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DATE-MANIP_DEPENDS)" >>$@

$(PERL-DATE-MANIP_IPK): $(PERL-DATE-MANIP_BUILD_DIR)/.built
	rm -rf $(PERL-DATE-MANIP_IPK_DIR) $(BUILD_DIR)/perl-date-manip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) DESTDIR=$(PERL-DATE-MANIP_IPK_DIR) install
	find $(PERL-DATE-MANIP_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DATE-MANIP_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DATE-MANIP_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(PERL-DATE-MANIP_SOURCE_DIR)/postinst $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(PERL-DATE-MANIP_SOURCE_DIR)/prerm $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DATE-MANIP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DATE-MANIP_IPK_DIR)

perl-date-manip-ipk: $(PERL-DATE-MANIP_IPK)

perl-date-manip-clean:
	-$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) clean

perl-date-manip-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) $(PERL-DATE-MANIP_BUILD_DIR) $(PERL-DATE-MANIP_IPK_DIR) $(PERL-DATE-MANIP_IPK)
