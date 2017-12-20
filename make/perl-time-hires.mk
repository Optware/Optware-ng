###########################################################
#
# perl-time-hires
#
###########################################################

PERL-TIME-HIRES_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/Z/ZE/ZEFRAM
PERL-TIME-HIRES_VERSION=1.9726
PERL-TIME-HIRES_SOURCE=Time-HiRes-$(PERL-TIME-HIRES_VERSION).tar.gz
PERL-TIME-HIRES_DIR=Time-HiRes-$(PERL-TIME-HIRES_VERSION)
PERL-TIME-HIRES_UNZIP=zcat
PERL-TIME-HIRES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-TIME-HIRES_DESCRIPTION=Implement usleep, ualarm, and gettimeofday for Perl, as well as wrappers to implement time, sleep, and alarm that know about non-integral seconds.
PERL-TIME-HIRES_SECTION=util
PERL-TIME-HIRES_PRIORITY=optional
PERL-TIME-HIRES_DEPENDS=perl
PERL-TIME-HIRES_SUGGESTS=
PERL-TIME-HIRES_CONFLICTS=

PERL-TIME-HIRES_IPK_VERSION=4

PERL-TIME-HIRES_CONFFILES=

PERL-TIME-HIRES_BUILD_DIR=$(BUILD_DIR)/perl-time-hires
PERL-TIME-HIRES_SOURCE_DIR=$(SOURCE_DIR)/perl-time-hires
PERL-TIME-HIRES_IPK_DIR=$(BUILD_DIR)/perl-time-hires-$(PERL-TIME-HIRES_VERSION)-ipk
PERL-TIME-HIRES_IPK=$(BUILD_DIR)/perl-time-hires_$(PERL-TIME-HIRES_VERSION)-$(PERL-TIME-HIRES_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-TIME-HIRES_SOURCE):
	$(WGET) -P $(@D) $(PERL-TIME-HIRES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-time-hires-source: $(DL_DIR)/$(PERL-TIME-HIRES_SOURCE) $(PERL-TIME-HIRES_PATCHES)

$(PERL-TIME-HIRES_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TIME-HIRES_SOURCE) $(PERL-TIME-HIRES_PATCHES) make/perl-time-hires.mk
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-TIME-HIRES_DIR) $(PERL-TIME-HIRES_BUILD_DIR)
	$(PERL-TIME-HIRES_UNZIP) $(DL_DIR)/$(PERL-TIME-HIRES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-TIME-HIRES_DIR) $(PERL-TIME-HIRES_BUILD_DIR)
	(cd $(PERL-TIME-HIRES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-TIME-HIRES_BUILD_DIR)/.configured

perl-time-hires-unpack: $(PERL-TIME-HIRES_BUILD_DIR)/.configured

$(PERL-TIME-HIRES_BUILD_DIR)/.built: $(PERL-TIME-HIRES_BUILD_DIR)/.configured
	rm -f $(PERL-TIME-HIRES_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-TIME-HIRES_BUILD_DIR)/.built

perl-time-hires: $(PERL-TIME-HIRES_BUILD_DIR)/.built

$(PERL-TIME-HIRES_BUILD_DIR)/.staged: $(PERL-TIME-HIRES_BUILD_DIR)/.built
	rm -f $(PERL-TIME-HIRES_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-TIME-HIRES_BUILD_DIR)/.staged

perl-time-hires-stage: $(PERL-TIME-HIRES_BUILD_DIR)/.staged

$(PERL-TIME-HIRES_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-TIME-HIRES_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-time-hires" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-TIME-HIRES_PRIORITY)" >>$@
	@echo "Section: $(PERL-TIME-HIRES_SECTION)" >>$@
	@echo "Version: $(PERL-TIME-HIRES_VERSION)-$(PERL-TIME-HIRES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-TIME-HIRES_MAINTAINER)" >>$@
	@echo "Source: $(PERL-TIME-HIRES_SITE)/$(PERL-TIME-HIRES_SOURCE)" >>$@
	@echo "Description: $(PERL-TIME-HIRES_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-TIME-HIRES_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-TIME-HIRES_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-TIME-HIRES_CONFLICTS)" >>$@

$(PERL-TIME-HIRES_IPK): $(PERL-TIME-HIRES_BUILD_DIR)/.built
	rm -rf $(PERL-TIME-HIRES_IPK_DIR) $(BUILD_DIR)/perl-time-hires_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) DESTDIR=$(PERL-TIME-HIRES_IPK_DIR) install
	find $(PERL-TIME-HIRES_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-TIME-HIRES_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-TIME-HIRES_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-TIME-HIRES_IPK_DIR)/CONTROL/control
	echo $(PERL-TIME-HIRES_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TIME-HIRES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TIME-HIRES_IPK_DIR)

perl-time-hires-ipk: $(PERL-TIME-HIRES_IPK)

perl-time-hires-clean:
	-$(MAKE) -C $(PERL-TIME-HIRES_BUILD_DIR) clean

perl-time-hires-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TIME-HIRES_DIR) $(PERL-TIME-HIRES_BUILD_DIR) $(PERL-TIME-HIRES_IPK_DIR) $(PERL-TIME-HIRES_IPK)
