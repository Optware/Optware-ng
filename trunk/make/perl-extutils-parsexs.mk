###########################################################
#
# perl-extutils-parsexs
#
###########################################################

PERL-EXTUTILS-PARSEXS_SITE=http://search.cpan.org/CPAN/authors/id/K/KW/KWILLIAMS
PERL-EXTUTILS-PARSEXS_VERSION=2.19
PERL-EXTUTILS-PARSEXS_SOURCE=ExtUtils-ParseXS-$(PERL-EXTUTILS-PARSEXS_VERSION).tar.gz
PERL-EXTUTILS-PARSEXS_DIR=ExtUtils-ParseXS-$(PERL-EXTUTILS-PARSEXS_VERSION)
PERL-EXTUTILS-PARSEXS_UNZIP=zcat
PERL-EXTUTILS-PARSEXS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EXTUTILS-PARSEXS_DESCRIPTION=ExtUtils-ParseXS - converts Perl XS code into C code.
PERL-EXTUTILS-PARSEXS_SECTION=util
PERL-EXTUTILS-PARSEXS_PRIORITY=optional
PERL-EXTUTILS-PARSEXS_DEPENDS=perl, perl-extutils-cbuilder
PERL-EXTUTILS-PARSEXS_SUGGESTS=
PERL-EXTUTILS-PARSEXS_CONFLICTS=

PERL-EXTUTILS-PARSEXS_IPK_VERSION=1

PERL-EXTUTILS-PARSEXS_CONFFILES=

PERL-EXTUTILS-PARSEXS_BUILD_DIR=$(BUILD_DIR)/perl-extutils-parsexs
PERL-EXTUTILS-PARSEXS_SOURCE_DIR=$(SOURCE_DIR)/perl-extutils-parsexs
PERL-EXTUTILS-PARSEXS_IPK_DIR=$(BUILD_DIR)/perl-extutils-parsexs-$(PERL-EXTUTILS-PARSEXS_VERSION)-ipk
PERL-EXTUTILS-PARSEXS_IPK=$(BUILD_DIR)/perl-extutils-parsexs_$(PERL-EXTUTILS-PARSEXS_VERSION)-$(PERL-EXTUTILS-PARSEXS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EXTUTILS-PARSEXS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-EXTUTILS-PARSEXS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

perl-extutils-parsexs-source: $(DL_DIR)/$(PERL-EXTUTILS-PARSEXS_SOURCE) $(PERL-EXTUTILS-PARSEXS_PATCHES)

$(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EXTUTILS-PARSEXS_SOURCE) $(PERL-EXTUTILS-PARSEXS_PATCHES)
	$(MAKE) perl-extutils-cbuilder-stage
	rm -rf $(BUILD_DIR)/$(PERL-EXTUTILS-PARSEXS_DIR) $(@D)
	$(PERL-EXTUTILS-PARSEXS_UNZIP) $(DL_DIR)/$(PERL-EXTUTILS-PARSEXS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EXTUTILS-PARSEXS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-EXTUTILS-PARSEXS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EXTUTILS-PARSEXS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
		INSTALLDIRS=site \
	)
	touch $@

perl-extutils-parsexs-unpack: $(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.configured

$(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.built: $(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-extutils-parsexs: $(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.built

$(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.staged: $(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-extutils-parsexs-stage: $(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.staged

$(PERL-EXTUTILS-PARSEXS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-extutils-parsexs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EXTUTILS-PARSEXS_PRIORITY)" >>$@
	@echo "Section: $(PERL-EXTUTILS-PARSEXS_SECTION)" >>$@
	@echo "Version: $(PERL-EXTUTILS-PARSEXS_VERSION)-$(PERL-EXTUTILS-PARSEXS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EXTUTILS-PARSEXS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EXTUTILS-PARSEXS_SITE)/$(PERL-EXTUTILS-PARSEXS_SOURCE)" >>$@
	@echo "Description: $(PERL-EXTUTILS-PARSEXS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EXTUTILS-PARSEXS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EXTUTILS-PARSEXS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EXTUTILS-PARSEXS_CONFLICTS)" >>$@

$(PERL-EXTUTILS-PARSEXS_IPK): $(PERL-EXTUTILS-PARSEXS_BUILD_DIR)/.built
	rm -rf $(PERL-EXTUTILS-PARSEXS_IPK_DIR) $(BUILD_DIR)/perl-extutils-parsexs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EXTUTILS-PARSEXS_BUILD_DIR) DESTDIR=$(PERL-EXTUTILS-PARSEXS_IPK_DIR) install
	find $(PERL-EXTUTILS-PARSEXS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-EXTUTILS-PARSEXS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-EXTUTILS-PARSEXS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-EXTUTILS-PARSEXS_IPK_DIR)/CONTROL/control
	echo $(PERL-EXTUTILS-PARSEXS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EXTUTILS-PARSEXS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EXTUTILS-PARSEXS_IPK_DIR)

perl-extutils-parsexs-ipk: $(PERL-EXTUTILS-PARSEXS_IPK)

perl-extutils-parsexs-clean:
	-$(MAKE) -C $(PERL-EXTUTILS-PARSEXS_BUILD_DIR) clean

perl-extutils-parsexs-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EXTUTILS-PARSEXS_DIR) $(PERL-EXTUTILS-PARSEXS_BUILD_DIR) $(PERL-EXTUTILS-PARSEXS_IPK_DIR) $(PERL-EXTUTILS-PARSEXS_IPK)
