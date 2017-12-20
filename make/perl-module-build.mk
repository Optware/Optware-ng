###########################################################
#
# perl-module-build
#
###########################################################

PERL-MODULE-BUILD_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/L/LE/LEONT
PERL-MODULE-BUILD_VERSION_UPSTREAM=0.42_26
PERL-MODULE-BUILD_VERSION=0.4226
PERL-MODULE-BUILD_SOURCE=Module-Build-$(PERL-MODULE-BUILD_VERSION_UPSTREAM).tar.gz
PERL-MODULE-BUILD_DIR=Module-Build-$(PERL-MODULE-BUILD_VERSION_UPSTREAM)
PERL-MODULE-BUILD_UNZIP=zcat
PERL-MODULE-BUILD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MODULE-BUILD_DESCRIPTION=Module-Build - Build and install Perl modules.
PERL-MODULE-BUILD_SECTION=util
PERL-MODULE-BUILD_PRIORITY=optional
PERL-MODULE-BUILD_DEPENDS=perl
PERL-MODULE-BUILD_SUGGESTS=
PERL-MODULE-BUILD_CONFLICTS=

PERL-MODULE-BUILD_IPK_VERSION=1

PERL-MODULE-BUILD_CONFFILES=

PERL-MODULE-BUILD_BUILD_DIR=$(BUILD_DIR)/perl-module-build
PERL-MODULE-BUILD_SOURCE_DIR=$(SOURCE_DIR)/perl-module-build
PERL-MODULE-BUILD_IPK_DIR=$(BUILD_DIR)/perl-module-build-$(PERL-MODULE-BUILD_VERSION)-ipk
PERL-MODULE-BUILD_IPK=$(BUILD_DIR)/perl-module-build_$(PERL-MODULE-BUILD_VERSION)-$(PERL-MODULE-BUILD_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE):
	$(WGET) -P $(@D) $(PERL-MODULE-BUILD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-module-build-source: $(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE) $(PERL-MODULE-BUILD_PATCHES)

$(PERL-MODULE-BUILD_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE) $(PERL-MODULE-BUILD_PATCHES) make/perl-module-build.mk
	$(MAKE) perl-archive-tar-stage perl-extutils-cbuilder-stage perl-extutils-parsexs-stage \
		perl-pod-readme-stage perl-module-signature-stage
	rm -rf $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) $(PERL-MODULE-BUILD_BUILD_DIR)
	$(PERL-MODULE-BUILD_UNZIP) $(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-MODULE-BUILD_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) $(PERL-MODULE-BUILD_BUILD_DIR)
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Build.PL \
		--config CC=$(TARGET_CC) \
	)
	touch $(PERL-MODULE-BUILD_BUILD_DIR)/.configured

perl-module-build-unpack: $(PERL-MODULE-BUILD_BUILD_DIR)/.configured

$(PERL-MODULE-BUILD_BUILD_DIR)/.built: $(PERL-MODULE-BUILD_BUILD_DIR)/.configured
	rm -f $(PERL-MODULE-BUILD_BUILD_DIR)/.built
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
		./Build \
	)
	touch $(PERL-MODULE-BUILD_BUILD_DIR)/.built

perl-module-build: $(PERL-MODULE-BUILD_BUILD_DIR)/.built

$(PERL-MODULE-BUILD_BUILD_DIR)/.staged: $(PERL-MODULE-BUILD_BUILD_DIR)/.built
	rm -f $(PERL-MODULE-BUILD_BUILD_DIR)/.staged
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
	 	./Build --prefix $(STAGING_PREFIX) install \
	)
	touch $(PERL-MODULE-BUILD_BUILD_DIR)/.staged

perl-module-build-stage: $(PERL-MODULE-BUILD_BUILD_DIR)/.staged

$(PERL-MODULE-BUILD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-MODULE-BUILD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-module-build" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MODULE-BUILD_PRIORITY)" >>$@
	@echo "Section: $(PERL-MODULE-BUILD_SECTION)" >>$@
	@echo "Version: $(PERL-MODULE-BUILD_VERSION)-$(PERL-MODULE-BUILD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MODULE-BUILD_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MODULE-BUILD_SITE)/$(PERL-MODULE-BUILD_SOURCE)" >>$@
	@echo "Description: $(PERL-MODULE-BUILD_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MODULE-BUILD_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MODULE-BUILD_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MODULE-BUILD_CONFLICTS)" >>$@

$(PERL-MODULE-BUILD_IPK): $(PERL-MODULE-BUILD_BUILD_DIR)/.built
	rm -rf $(PERL-MODULE-BUILD_IPK_DIR) $(BUILD_DIR)/perl-module-build_*_$(TARGET_ARCH).ipk
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
       		./Build --prefix $(PERL-MODULE-BUILD_IPK_DIR)$(TARGET_PREFIX) install \
	)
	find $(PERL-MODULE-BUILD_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MODULE-BUILD_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MODULE-BUILD_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	sed -i -e 's|$(PERL_HOSTPERL)|$(TARGET_PREFIX)/bin/perl|g' $(PERL-MODULE-BUILD_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(MAKE) $(PERL-MODULE-BUILD_IPK_DIR)/CONTROL/control
	echo $(PERL-MODULE-BUILD_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MODULE-BUILD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MODULE-BUILD_IPK_DIR)

perl-module-build-ipk: $(PERL-MODULE-BUILD_IPK)

perl-module-build-clean:
	-$(MAKE) -C $(PERL-MODULE-BUILD_BUILD_DIR) clean

perl-module-build-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) $(PERL-MODULE-BUILD_BUILD_DIR) $(PERL-MODULE-BUILD_IPK_DIR) $(PERL-MODULE-BUILD_IPK)
