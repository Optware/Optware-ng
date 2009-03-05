###########################################################
#
# perl-return-value
#
###########################################################

PERL-RETURN-VALUE_SITE=http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS
PERL-RETURN-VALUE_VERSION=1.302
PERL-RETURN-VALUE_SOURCE=Return-Value-$(PERL-RETURN-VALUE_VERSION).tar.gz
PERL-RETURN-VALUE_DIR=Return-Value-$(PERL-RETURN-VALUE_VERSION)
PERL-RETURN-VALUE_UNZIP=zcat
PERL-RETURN-VALUE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-RETURN-VALUE_DESCRIPTION=Polymorphic Return Values
PERL-RETURN-VALUE_SECTION=utils
PERL-RETURN-VALUE_PRIORITY=optional
PERL-RETURN-VALUE_DEPENDS=perl
PERL-RETURN-VALUE_SUGGESTS=
PERL-RETURN-VALUE_CONFLICTS=

PERL-RETURN-VALUE_IPK_VERSION=1

PERL-RETURN-VALUE_CONFFILES=

PERL-RETURN-VALUE_BUILD_DIR=$(BUILD_DIR)/perl-return-value
PERL-RETURN-VALUE_SOURCE_DIR=$(SOURCE_DIR)/perl-return-value
PERL-RETURN-VALUE_IPK_DIR=$(BUILD_DIR)/perl-return-value-$(PERL-RETURN-VALUE_VERSION)-ipk
PERL-RETURN-VALUE_IPK=$(BUILD_DIR)/perl-return-value_$(PERL-RETURN-VALUE_VERSION)-$(PERL-RETURN-VALUE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-RETURN-VALUE_SOURCE):
	$(WGET) -P $(@D) $(PERL-RETURN-VALUE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-return-value-source: $(DL_DIR)/$(PERL-RETURN-VALUE_SOURCE) $(PERL-RETURN-VALUE_PATCHES)

$(PERL-RETURN-VALUE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-RETURN-VALUE_SOURCE) $(PERL-RETURN-VALUE_PATCHES) make/perl-return-value.mk
	rm -rf $(BUILD_DIR)/$(PERL-RETURN-VALUE_DIR) $(@D)
	$(PERL-RETURN-VALUE_UNZIP) $(DL_DIR)/$(PERL-RETURN-VALUE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-RETURN-VALUE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-RETURN-VALUE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-RETURN-VALUE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-return-value-unpack: $(PERL-RETURN-VALUE_BUILD_DIR)/.configured

$(PERL-RETURN-VALUE_BUILD_DIR)/.built: $(PERL-RETURN-VALUE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-return-value: $(PERL-RETURN-VALUE_BUILD_DIR)/.built

$(PERL-RETURN-VALUE_BUILD_DIR)/.staged: $(PERL-RETURN-VALUE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-return-value-stage: $(PERL-RETURN-VALUE_BUILD_DIR)/.staged

$(PERL-RETURN-VALUE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-return-value" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-RETURN-VALUE_PRIORITY)" >>$@
	@echo "Section: $(PERL-RETURN-VALUE_SECTION)" >>$@
	@echo "Version: $(PERL-RETURN-VALUE_VERSION)-$(PERL-RETURN-VALUE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-RETURN-VALUE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-RETURN-VALUE_SITE)/$(PERL-RETURN-VALUE_SOURCE)" >>$@
	@echo "Description: $(PERL-RETURN-VALUE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-RETURN-VALUE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-RETURN-VALUE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-RETURN-VALUE_CONFLICTS)" >>$@

$(PERL-RETURN-VALUE_IPK): $(PERL-RETURN-VALUE_BUILD_DIR)/.built
	rm -rf $(PERL-RETURN-VALUE_IPK_DIR) $(BUILD_DIR)/perl-return-value_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-RETURN-VALUE_BUILD_DIR) DESTDIR=$(PERL-RETURN-VALUE_IPK_DIR) install
	find $(PERL-RETURN-VALUE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-RETURN-VALUE_IPK_DIR)/CONTROL/control
	echo $(PERL-RETURN-VALUE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-RETURN-VALUE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-RETURN-VALUE_IPK_DIR)

perl-return-value-ipk: $(PERL-RETURN-VALUE_IPK)

perl-return-value-clean:
	-$(MAKE) -C $(PERL-RETURN-VALUE_BUILD_DIR) clean

perl-return-value-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-RETURN-VALUE_DIR) $(PERL-RETURN-VALUE_BUILD_DIR) $(PERL-RETURN-VALUE_IPK_DIR) $(PERL-RETURN-VALUE_IPK)
