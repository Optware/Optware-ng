###########################################################
#
# perl-timedate
#
###########################################################

PERL-TIMEDATE_SITE=http://search.cpan.org/CPAN/authors/id/G/GB/GBARR
PERL-TIMEDATE_VERSION=1.16
PERL-TIMEDATE_SOURCE=TimeDate-$(PERL-TIMEDATE_VERSION).tar.gz
PERL-TIMEDATE_DIR=TimeDate-$(PERL-TIMEDATE_VERSION)
PERL-TIMEDATE_UNZIP=zcat
PERL-TIMEDATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-TIMEDATE_DESCRIPTION=A date and time module for perl.
PERL-TIMEDATE_SECTION=util
PERL-TIMEDATE_PRIORITY=optional
PERL-TIMEDATE_DEPENDS=perl
PERL-TIMEDATE_SUGGESTS=
PERL-TIMEDATE_CONFLICTS=

PERL-TIMEDATE_IPK_VERSION=1

PERL-TIMEDATE_CONFFILES=

PERL-TIMEDATE_BUILD_DIR=$(BUILD_DIR)/perl-timedate
PERL-TIMEDATE_SOURCE_DIR=$(SOURCE_DIR)/perl-timedate
PERL-TIMEDATE_IPK_DIR=$(BUILD_DIR)/perl-timedate-$(PERL-TIMEDATE_VERSION)-ipk
PERL-TIMEDATE_IPK=$(BUILD_DIR)/perl-timedate_$(PERL-TIMEDATE_VERSION)-$(PERL-TIMEDATE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-TIMEDATE_SOURCE):
	$(WGET) -P $(@D) $(PERL-TIMEDATE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-timedate-source: $(DL_DIR)/$(PERL-TIMEDATE_SOURCE) $(PERL-TIMEDATE_PATCHES)

$(PERL-TIMEDATE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TIMEDATE_SOURCE) $(PERL-TIMEDATE_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-TIMEDATE_DIR) $(@D)
	$(PERL-TIMEDATE_UNZIP) $(DL_DIR)/$(PERL-TIMEDATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-TIMEDATE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-TIMEDATE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-TIMEDATE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-timedate-unpack: $(PERL-TIMEDATE_BUILD_DIR)/.configured

$(PERL-TIMEDATE_BUILD_DIR)/.built: $(PERL-TIMEDATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-timedate: $(PERL-TIMEDATE_BUILD_DIR)/.built

$(PERL-TIMEDATE_BUILD_DIR)/.staged: $(PERL-TIMEDATE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-timedate-stage: $(PERL-TIMEDATE_BUILD_DIR)/.staged

$(PERL-TIMEDATE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-timedate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-TIMEDATE_PRIORITY)" >>$@
	@echo "Section: $(PERL-TIMEDATE_SECTION)" >>$@
	@echo "Version: $(PERL-TIMEDATE_VERSION)-$(PERL-TIMEDATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-TIMEDATE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-TIMEDATE_SITE)/$(PERL-TIMEDATE_SOURCE)" >>$@
	@echo "Description: $(PERL-TIMEDATE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-TIMEDATE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-TIMEDATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-TIMEDATE_CONFLICTS)" >>$@

$(PERL-TIMEDATE_IPK): $(PERL-TIMEDATE_BUILD_DIR)/.built
	rm -rf $(PERL-TIMEDATE_IPK_DIR) $(BUILD_DIR)/perl-timedate_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-TIMEDATE_BUILD_DIR) DESTDIR=$(PERL-TIMEDATE_IPK_DIR) install
	$(MAKE) $(PERL-TIMEDATE_IPK_DIR)/CONTROL/control
	echo $(PERL-TIMEDATE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TIMEDATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TIMEDATE_IPK_DIR)

perl-timedate-ipk: $(PERL-TIMEDATE_IPK)

perl-timedate-clean:
	-$(MAKE) -C $(PERL-TIMEDATE_BUILD_DIR) clean

perl-timedate-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TIMEDATE_DIR) $(PERL-TIMEDATE_BUILD_DIR) $(PERL-TIMEDATE_IPK_DIR) $(PERL-TIMEDATE_IPK)
