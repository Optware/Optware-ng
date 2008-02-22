###########################################################
#
# perl-date-calc
#
###########################################################

PERL-DATE-CALC_SITE=http://search.cpan.org/CPAN/authors/id/S/ST/STBEY
PERL-DATE-CALC_VERSION=5.4
PERL-DATE-CALC_SOURCE=Date-Calc-$(PERL-DATE-CALC_VERSION).tar.gz
PERL-DATE-CALC_DIR=Date-Calc-$(PERL-DATE-CALC_VERSION)
PERL-DATE-CALC_UNZIP=zcat

PERL-DATE-CALC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DATE-CALC_DESCRIPTION=Gregorian calendar date calculations.
PERL-DATE-CALC_SECTION=util
PERL-DATE-CALC_PRIORITY=optional
PERL-DATE-CALC_DEPENDS=perl

PERL-DATE-CALC_IPK_VERSION=1

PERL-DATE-CALC_CONFFILES=

PERL-DATE-CALC_PATCHES=

PERL-DATE-CALC_BUILD_DIR=$(BUILD_DIR)/perl-date-calc
PERL-DATE-CALC_SOURCE_DIR=$(SOURCE_DIR)/perl-date-calc
PERL-DATE-CALC_IPK_DIR=$(BUILD_DIR)/perl-date-calc-$(PERL-DATE-CALC_VERSION)-ipk
PERL-DATE-CALC_IPK=$(BUILD_DIR)/perl-date-calc_$(PERL-DATE-CALC_VERSION)-$(PERL-DATE-CALC_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-DATE-CALC_BUILD_DIR=$(BUILD_DIR)/perl-date-calc
PERL-DATE-CALC_SOURCE_DIR=$(SOURCE_DIR)/perl-date-calc
PERL-DATE-CALC_IPK_DIR=$(BUILD_DIR)/perl-date-calc-$(PERL-DATE-CALC_VERSION)-ipk
PERL-DATE-CALC_IPK=$(BUILD_DIR)/perl-date-calc_$(PERL-DATE-CALC_VERSION)-$(PERL-DATE-CALC_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DATE-CALC_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DATE-CALC_SITE)/$(PERL-DATE-CALC_SOURCE)

perl-date-calc-source: $(DL_DIR)/$(PERL-DATE-CALC_SOURCE) $(PERL-DATE-CALC_PATCHES)

$(PERL-DATE-CALC_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DATE-CALC_SOURCE) $(PERL-DATE-CALC_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DATE-CALC_DIR) $(@D)
	$(PERL-DATE-CALC_UNZIP) $(DL_DIR)/$(PERL-DATE-CALC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DATE-CALC_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DATE-CALC_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DATE-CALC_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-date-calc-unpack: $(PERL-DATE-CALC_BUILD_DIR)/.configured

$(PERL-DATE-CALC_BUILD_DIR)/.built: $(PERL-DATE-CALC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-date-calc: $(PERL-DATE-CALC_BUILD_DIR)/.built

$(PERL-DATE-CALC_BUILD_DIR)/.staged: $(PERL-DATE-CALC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-date-calc-stage: $(PERL-DATE-CALC_BUILD_DIR)/.staged

$(PERL-DATE-CALC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-date-calc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DATE-CALC_PRIORITY)" >>$@
	@echo "Section: $(PERL-DATE-CALC_SECTION)" >>$@
	@echo "Version: $(PERL-DATE-CALC_VERSION)-$(PERL-DATE-CALC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DATE-CALC_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DATE-CALC_SITE)/$(PERL-DATE-CALC_SOURCE)" >>$@
	@echo "Description: $(PERL-DATE-CALC_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DATE-CALC_DEPENDS)" >>$@

$(PERL-DATE-CALC_IPK): $(PERL-DATE-CALC_BUILD_DIR)/.built
	rm -rf $(PERL-DATE-CALC_IPK_DIR) $(BUILD_DIR)/perl-date-calc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DATE-CALC_BUILD_DIR) DESTDIR=$(PERL-DATE-CALC_IPK_DIR) install
	find $(PERL-DATE-CALC_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DATE-CALC_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DATE-CALC_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DATE-CALC_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-DATE-CALC_SOURCE_DIR)/postinst $(PERL-DATE-CALC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-DATE-CALC_SOURCE_DIR)/prerm $(PERL-DATE-CALC_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DATE-CALC_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DATE-CALC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DATE-CALC_IPK_DIR)

perl-date-calc-ipk: $(PERL-DATE-CALC_IPK)

perl-date-calc-clean:
	-$(MAKE) -C $(PERL-DATE-CALC_BUILD_DIR) clean

perl-date-calc-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DATE-CALC_DIR) $(PERL-DATE-CALC_BUILD_DIR) $(PERL-DATE-CALC_IPK_DIR) $(PERL-DATE-CALC_IPK)

perl-date-calc-check: $(PERL-DATE-CALC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DATE-CALC_IPK)
