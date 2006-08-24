###########################################################
#
# perl-convert-tnef
#
###########################################################

PERL-CONVERT-TNEF_SITE=http://search.cpan.org/CPAN/authors/id/D/DO/DOUGW
PERL-CONVERT-TNEF_VERSION=0.17
PERL-CONVERT-TNEF_SOURCE=Convert-TNEF-$(PERL-CONVERT-TNEF_VERSION).tar.gz
PERL-CONVERT-TNEF_DIR=Convert-TNEF-$(PERL-CONVERT-TNEF_VERSION)
PERL-CONVERT-TNEF_UNZIP=zcat
PERL-CONVERT-TNEF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CONVERT-TNEF_DESCRIPTION=Convert-TNEF - Perl module to read TNEF files
PERL-CONVERT-TNEF_SECTION=util
PERL-CONVERT-TNEF_PRIORITY=optional
PERL-CONVERT-TNEF_DEPENDS=perl, perl-mime-tools
PERL-CONVERT-TNEF_SUGGESTS=
PERL-CONVERT-TNEF_CONFLICTS=

PERL-CONVERT-TNEF_IPK_VERSION=2

PERL-CONVERT-TNEF_CONFFILES=

PERL-CONVERT-TNEF_BUILD_DIR=$(BUILD_DIR)/perl-convert-tnef
PERL-CONVERT-TNEF_SOURCE_DIR=$(SOURCE_DIR)/perl-convert-tnef
PERL-CONVERT-TNEF_IPK_DIR=$(BUILD_DIR)/perl-convert-tnef-$(PERL-CONVERT-TNEF_VERSION)-ipk
PERL-CONVERT-TNEF_IPK=$(BUILD_DIR)/perl-convert-tnef_$(PERL-CONVERT-TNEF_VERSION)-$(PERL-CONVERT-TNEF_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CONVERT-TNEF_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CONVERT-TNEF_SITE)/$(PERL-CONVERT-TNEF_SOURCE)

perl-convert-tnef-source: $(DL_DIR)/$(PERL-CONVERT-TNEF_SOURCE) $(PERL-CONVERT-TNEF_PATCHES)

$(PERL-CONVERT-TNEF_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CONVERT-TNEF_SOURCE) $(PERL-CONVERT-TNEF_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-CONVERT-TNEF_DIR) $(PERL-CONVERT-TNEF_BUILD_DIR)
	$(PERL-CONVERT-TNEF_UNZIP) $(DL_DIR)/$(PERL-CONVERT-TNEF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CONVERT-TNEF_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CONVERT-TNEF_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CONVERT-TNEF_DIR) $(PERL-CONVERT-TNEF_BUILD_DIR)
	(cd $(PERL-CONVERT-TNEF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-CONVERT-TNEF_BUILD_DIR)/.configured

perl-convert-tnef-unpack: $(PERL-CONVERT-TNEF_BUILD_DIR)/.configured

$(PERL-CONVERT-TNEF_BUILD_DIR)/.built: $(PERL-CONVERT-TNEF_BUILD_DIR)/.configured
	rm -f $(PERL-CONVERT-TNEF_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CONVERT-TNEF_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CONVERT-TNEF_BUILD_DIR)/.built

perl-convert-tnef: $(PERL-CONVERT-TNEF_BUILD_DIR)/.built

$(PERL-CONVERT-TNEF_BUILD_DIR)/.staged: $(PERL-CONVERT-TNEF_BUILD_DIR)/.built
	rm -f $(PERL-CONVERT-TNEF_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CONVERT-TNEF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CONVERT-TNEF_BUILD_DIR)/.staged

perl-convert-tnef-stage: $(PERL-CONVERT-TNEF_BUILD_DIR)/.staged

$(PERL-CONVERT-TNEF_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CONVERT-TNEF_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-convert-tnef" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CONVERT-TNEF_PRIORITY)" >>$@
	@echo "Section: $(PERL-CONVERT-TNEF_SECTION)" >>$@
	@echo "Version: $(PERL-CONVERT-TNEF_VERSION)-$(PERL-CONVERT-TNEF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CONVERT-TNEF_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CONVERT-TNEF_SITE)/$(PERL-CONVERT-TNEF_SOURCE)" >>$@
	@echo "Description: $(PERL-CONVERT-TNEF_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CONVERT-TNEF_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CONVERT-TNEF_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CONVERT-TNEF_CONFLICTS)" >>$@

$(PERL-CONVERT-TNEF_IPK): $(PERL-CONVERT-TNEF_BUILD_DIR)/.built
	rm -rf $(PERL-CONVERT-TNEF_IPK_DIR) $(BUILD_DIR)/perl-convert-tnef_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CONVERT-TNEF_BUILD_DIR) DESTDIR=$(PERL-CONVERT-TNEF_IPK_DIR) install
	find $(PERL-CONVERT-TNEF_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CONVERT-TNEF_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CONVERT-TNEF_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CONVERT-TNEF_IPK_DIR)/CONTROL/control
	echo $(PERL-CONVERT-TNEF_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CONVERT-TNEF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CONVERT-TNEF_IPK_DIR)

perl-convert-tnef-ipk: $(PERL-CONVERT-TNEF_IPK)

perl-convert-tnef-clean:
	-$(MAKE) -C $(PERL-CONVERT-TNEF_BUILD_DIR) clean

perl-convert-tnef-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CONVERT-TNEF_DIR) $(PERL-CONVERT-TNEF_BUILD_DIR) $(PERL-CONVERT-TNEF_IPK_DIR) $(PERL-CONVERT-TNEF_IPK)
