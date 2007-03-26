###########################################################
#
# perl-gd-barcode
#
###########################################################

PERL-GD-BARCODE_SITE=http://search.cpan.org/CPAN/authors/id/K/KW/KWITKNR
PERL-GD-BARCODE_VERSION=1.15
PERL-GD-BARCODE_SOURCE=GD-Barcode-$(PERL-GD-BARCODE_VERSION).tar.gz
PERL-GD-BARCODE_DIR=GD-Barcode-$(PERL-GD-BARCODE_VERSION)
PERL-GD-BARCODE_UNZIP=zcat
PERL-GD-BARCODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-GD-BARCODE_DESCRIPTION=GD-Barcode - Create barcode image with GD 
PERL-GD-BARCODE_SECTION=util
PERL-GD-BARCODE_PRIORITY=optional
PERL-GD-BARCODE_DEPENDS=perl, perl-gd
PERL-GD-BARCODE_SUGGESTS=
PERL-GD-BARCODE_CONFLICTS=

PERL-GD-BARCODE_IPK_VERSION=2

PERL-GD-BARCODE_CONFFILES=

PERL-GD-BARCODE_BUILD_DIR=$(BUILD_DIR)/perl-gd-barcode
PERL-GD-BARCODE_SOURCE_DIR=$(SOURCE_DIR)/perl-gd-barcode
PERL-GD-BARCODE_IPK_DIR=$(BUILD_DIR)/perl-gd-barcode-$(PERL-GD-BARCODE_VERSION)-ipk
PERL-GD-BARCODE_IPK=$(BUILD_DIR)/perl-gd-barcode_$(PERL-GD-BARCODE_VERSION)-$(PERL-GD-BARCODE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-GD-BARCODE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-GD-BARCODE_SITE)/$(PERL-GD-BARCODE_SOURCE)

perl-gd-barcode-source: $(DL_DIR)/$(PERL-GD-BARCODE_SOURCE) $(PERL-GD-BARCODE_PATCHES)

$(PERL-GD-BARCODE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-GD-BARCODE_SOURCE) $(PERL-GD-BARCODE_PATCHES)
	$(MAKE) perl-gd-stage
	rm -rf $(BUILD_DIR)/$(PERL-GD-BARCODE_DIR) $(PERL-GD-BARCODE_BUILD_DIR)
	$(PERL-GD-BARCODE_UNZIP) $(DL_DIR)/$(PERL-GD-BARCODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-GD-BARCODE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-GD-BARCODE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-GD-BARCODE_DIR) $(PERL-GD-BARCODE_BUILD_DIR)
	(cd $(PERL-GD-BARCODE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-GD-BARCODE_BUILD_DIR)/.configured

perl-gd-barcode-unpack: $(PERL-GD-BARCODE_BUILD_DIR)/.configured

$(PERL-GD-BARCODE_BUILD_DIR)/.built: $(PERL-GD-BARCODE_BUILD_DIR)/.configured
	rm -f $(PERL-GD-BARCODE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-GD-BARCODE_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-GD-BARCODE_BUILD_DIR)/.built

perl-gd-barcode: $(PERL-GD-BARCODE_BUILD_DIR)/.built

$(PERL-GD-BARCODE_BUILD_DIR)/.staged: $(PERL-GD-BARCODE_BUILD_DIR)/.built
	rm -f $(PERL-GD-BARCODE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-GD-BARCODE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-GD-BARCODE_BUILD_DIR)/.staged

perl-gd-barcode-stage: $(PERL-GD-BARCODE_BUILD_DIR)/.staged

$(PERL-GD-BARCODE_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-GD-BARCODE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-gd-barcode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-GD-BARCODE_PRIORITY)" >>$@
	@echo "Section: $(PERL-GD-BARCODE_SECTION)" >>$@
	@echo "Version: $(PERL-GD-BARCODE_VERSION)-$(PERL-GD-BARCODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-GD-BARCODE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-GD-BARCODE_SITE)/$(PERL-GD-BARCODE_SOURCE)" >>$@
	@echo "Description: $(PERL-GD-BARCODE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-GD-BARCODE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-GD-BARCODE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-GD-BARCODE_CONFLICTS)" >>$@

$(PERL-GD-BARCODE_IPK): $(PERL-GD-BARCODE_BUILD_DIR)/.built
	rm -rf $(PERL-GD-BARCODE_IPK_DIR) $(BUILD_DIR)/perl-gd-barcode_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-GD-BARCODE_BUILD_DIR) DESTDIR=$(PERL-GD-BARCODE_IPK_DIR) install
	find $(PERL-GD-BARCODE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-GD-BARCODE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-GD-BARCODE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-GD-BARCODE_IPK_DIR)/CONTROL/control
	echo $(PERL-GD-BARCODE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-GD-BARCODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-GD-BARCODE_IPK_DIR)

perl-gd-barcode-ipk: $(PERL-GD-BARCODE_IPK)

perl-gd-barcode-clean:
	-$(MAKE) -C $(PERL-GD-BARCODE_BUILD_DIR) clean

perl-gd-barcode-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-GD-BARCODE_DIR) $(PERL-GD-BARCODE_BUILD_DIR) $(PERL-GD-BARCODE_IPK_DIR) $(PERL-GD-BARCODE_IPK)
