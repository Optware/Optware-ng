###########################################################
#
# perl-class-inspector
#
###########################################################

PERL-CLASS-INSPECTOR_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/A/AD/ADAMK
PERL-CLASS-INSPECTOR_VERSION=1.28
PERL-CLASS-INSPECTOR_SOURCE=Class-Inspector-$(PERL-CLASS-INSPECTOR_VERSION).tar.gz
PERL-CLASS-INSPECTOR_DIR=Class-Inspector-$(PERL-CLASS-INSPECTOR_VERSION)
PERL-CLASS-INSPECTOR_UNZIP=zcat
PERL-CLASS-INSPECTOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CLASS-INSPECTOR_DESCRIPTION=Get information about a class and its structure
PERL-CLASS-INSPECTOR_SECTION=util
PERL-CLASS-INSPECTOR_PRIORITY=optional
PERL-CLASS-INSPECTOR_DEPENDS=
PERL-CLASS-INSPECTOR_SUGGESTS=
PERL-CLASS-INSPECTOR_CONFLICTS=

PERL-CLASS-INSPECTOR_IPK_VERSION=3

PERL-CLASS-INSPECTOR_CONFFILES=

PERL-CLASS-INSPECTOR_BUILD_DIR=$(BUILD_DIR)/perl-class-inspector
PERL-CLASS-INSPECTOR_SOURCE_DIR=$(SOURCE_DIR)/perl-class-inspector
PERL-CLASS-INSPECTOR_IPK_DIR=$(BUILD_DIR)/perl-class-inspector-$(PERL-CLASS-INSPECTOR_VERSION)-ipk
PERL-CLASS-INSPECTOR_IPK=$(BUILD_DIR)/perl-class-inspector_$(PERL-CLASS-INSPECTOR_VERSION)-$(PERL-CLASS-INSPECTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CLASS-INSPECTOR_SOURCE):
	$(WGET) -P $(@D) $(PERL-CLASS-INSPECTOR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-class-inspector-source: $(DL_DIR)/$(PERL-CLASS-INSPECTOR_SOURCE) $(PERL-CLASS-INSPECTOR_PATCHES)

$(PERL-CLASS-INSPECTOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CLASS-INSPECTOR_SOURCE) $(PERL-CLASS-INSPECTOR_PATCHES) make/perl-class-inspector.mk
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-INSPECTOR_DIR) $(PERL-CLASS-INSPECTOR_BUILD_DIR)
	$(PERL-CLASS-INSPECTOR_UNZIP) $(DL_DIR)/$(PERL-CLASS-INSPECTOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CLASS-INSPECTOR_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-CLASS-INSPECTOR_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CLASS-INSPECTOR_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl:$(@D)" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-class-inspector-unpack: $(PERL-CLASS-INSPECTOR_BUILD_DIR)/.configured

$(PERL-CLASS-INSPECTOR_BUILD_DIR)/.built: $(PERL-CLASS-INSPECTOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-class-inspector: $(PERL-CLASS-INSPECTOR_BUILD_DIR)/.built

$(PERL-CLASS-INSPECTOR_BUILD_DIR)/.staged: $(PERL-CLASS-INSPECTOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-class-inspector-stage: $(PERL-CLASS-INSPECTOR_BUILD_DIR)/.staged

$(PERL-CLASS-INSPECTOR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-class-inspector" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CLASS-INSPECTOR_PRIORITY)" >>$@
	@echo "Section: $(PERL-CLASS-INSPECTOR_SECTION)" >>$@
	@echo "Version: $(PERL-CLASS-INSPECTOR_VERSION)-$(PERL-CLASS-INSPECTOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CLASS-INSPECTOR_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CLASS-INSPECTOR_SITE)/$(PERL-CLASS-INSPECTOR_SOURCE)" >>$@
	@echo "Description: $(PERL-CLASS-INSPECTOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CLASS-INSPECTOR_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CLASS-INSPECTOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CLASS-INSPECTOR_CONFLICTS)" >>$@

$(PERL-CLASS-INSPECTOR_IPK): $(PERL-CLASS-INSPECTOR_BUILD_DIR)/.built
	rm -rf $(PERL-CLASS-INSPECTOR_IPK_DIR) $(BUILD_DIR)/perl-class-inspector_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CLASS-INSPECTOR_BUILD_DIR) DESTDIR=$(PERL-CLASS-INSPECTOR_IPK_DIR) install
	find $(PERL-CLASS-INSPECTOR_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CLASS-INSPECTOR_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CLASS-INSPECTOR_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CLASS-INSPECTOR_IPK_DIR)/CONTROL/control
	echo $(PERL-CLASS-INSPECTOR_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CLASS-INSPECTOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CLASS-INSPECTOR_IPK_DIR)

perl-class-inspector-ipk: $(PERL-CLASS-INSPECTOR_IPK)

perl-class-inspector-clean:
	-$(MAKE) -C $(PERL-CLASS-INSPECTOR_BUILD_DIR) clean

perl-class-inspector-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-INSPECTOR_DIR) $(PERL-CLASS-INSPECTOR_BUILD_DIR) $(PERL-CLASS-INSPECTOR_IPK_DIR) $(PERL-CLASS-INSPECTOR_IPK)
