###########################################################
#
# perl-devel-modlist
#
###########################################################

PERL-DEVEL-MODLIST_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/R/RJ/RJRAY
PERL-DEVEL-MODLIST_VERSION=0.801
PERL-DEVEL-MODLIST_SOURCE=Devel-Modlist-$(PERL-DEVEL-MODLIST_VERSION).tar.gz
PERL-DEVEL-MODLIST_DIR=Devel-Modlist-$(PERL-DEVEL-MODLIST_VERSION)
PERL-DEVEL-MODLIST_UNZIP=zcat
PERL-DEVEL-MODLIST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DEVEL-MODLIST_DESCRIPTION=Perl extension to collect module use information
PERL-DEVEL-MODLIST_SECTION=devel
PERL-DEVEL-MODLIST_PRIORITY=optional
PERL-DEVEL-MODLIST_DEPENDS=
PERL-DEVEL-MODLIST_SUGGESTS=
PERL-DEVEL-MODLIST_CONFLICTS=

PERL-DEVEL-MODLIST_IPK_VERSION=4

PERL-DEVEL-MODLIST_CONFFILES=

PERL-DEVEL-MODLIST_BUILD_DIR=$(BUILD_DIR)/perl-devel-modlist
PERL-DEVEL-MODLIST_SOURCE_DIR=$(SOURCE_DIR)/perl-devel-modlist
PERL-DEVEL-MODLIST_IPK_DIR=$(BUILD_DIR)/perl-devel-modlist-$(PERL-DEVEL-MODLIST_VERSION)-ipk
PERL-DEVEL-MODLIST_IPK=$(BUILD_DIR)/perl-devel-modlist_$(PERL-DEVEL-MODLIST_VERSION)-$(PERL-DEVEL-MODLIST_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DEVEL-MODLIST_SOURCE):
	$(WGET) -P $(@D) $(PERL-DEVEL-MODLIST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-devel-modlist-source: $(DL_DIR)/$(PERL-DEVEL-MODLIST_SOURCE) $(PERL-DEVEL-MODLIST_PATCHES)

$(PERL-DEVEL-MODLIST_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DEVEL-MODLIST_SOURCE) $(PERL-DEVEL-MODLIST_PATCHES) make/perl-devel-modlist.mk
	rm -rf $(BUILD_DIR)/$(PERL-DEVEL-MODLIST_DIR) $(PERL-DEVEL-MODLIST_BUILD_DIR)
	$(PERL-DEVEL-MODLIST_UNZIP) $(DL_DIR)/$(PERL-DEVEL-MODLIST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DEVEL-MODLIST_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-DEVEL-MODLIST_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DEVEL-MODLIST_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-devel-modlist-unpack: $(PERL-DEVEL-MODLIST_BUILD_DIR)/.configured

$(PERL-DEVEL-MODLIST_BUILD_DIR)/.built: $(PERL-DEVEL-MODLIST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-devel-modlist: $(PERL-DEVEL-MODLIST_BUILD_DIR)/.built

$(PERL-DEVEL-MODLIST_BUILD_DIR)/.staged: $(PERL-DEVEL-MODLIST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-devel-modlist-stage: $(PERL-DEVEL-MODLIST_BUILD_DIR)/.staged

$(PERL-DEVEL-MODLIST_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-devel-modlist" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DEVEL-MODLIST_PRIORITY)" >>$@
	@echo "Section: $(PERL-DEVEL-MODLIST_SECTION)" >>$@
	@echo "Version: $(PERL-DEVEL-MODLIST_VERSION)-$(PERL-DEVEL-MODLIST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DEVEL-MODLIST_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DEVEL-MODLIST_SITE)/$(PERL-DEVEL-MODLIST_SOURCE)" >>$@
	@echo "Description: $(PERL-DEVEL-MODLIST_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DEVEL-MODLIST_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DEVEL-MODLIST_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DEVEL-MODLIST_CONFLICTS)" >>$@

$(PERL-DEVEL-MODLIST_IPK): $(PERL-DEVEL-MODLIST_BUILD_DIR)/.built
	rm -rf $(PERL-DEVEL-MODLIST_IPK_DIR) $(BUILD_DIR)/perl-devel-modlist_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DEVEL-MODLIST_BUILD_DIR) DESTDIR=$(PERL-DEVEL-MODLIST_IPK_DIR) install
	find $(PERL-DEVEL-MODLIST_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DEVEL-MODLIST_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DEVEL-MODLIST_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DEVEL-MODLIST_IPK_DIR)/CONTROL/control
	echo $(PERL-DEVEL-MODLIST_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DEVEL-MODLIST_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DEVEL-MODLIST_IPK_DIR)

perl-devel-modlist-ipk: $(PERL-DEVEL-MODLIST_IPK)

perl-devel-modlist-clean:
	-$(MAKE) -C $(PERL-DEVEL-MODLIST_BUILD_DIR) clean

perl-devel-modlist-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DEVEL-MODLIST_DIR) $(PERL-DEVEL-MODLIST_BUILD_DIR) $(PERL-DEVEL-MODLIST_IPK_DIR) $(PERL-DEVEL-MODLIST_IPK)
