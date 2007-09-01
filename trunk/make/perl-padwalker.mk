###########################################################
#
# perl-padwalker
#
###########################################################

PERL-PADWALKER_SITE=http://search.cpan.org/CPAN/authors/id/R/RO/ROBIN
PERL-PADWALKER_VERSION=1.5
PERL-PADWALKER_SOURCE=PadWalker-$(PERL-PADWALKER_VERSION).tar.gz
PERL-PADWALKER_DIR=PadWalker-$(PERL-PADWALKER_VERSION)
PERL-PADWALKER_UNZIP=zcat
PERL-PADWALKER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-PADWALKER_DESCRIPTION=play with other people''s lexical variables
PERL-PADWALKER_SECTION=util
PERL-PADWALKER_PRIORITY=optional
PERL-PADWALKER_DEPENDS=perl
PERL-PADWALKER_SUGGESTS=
PERL-PADWALKER_CONFLICTS=

PERL-PADWALKER_IPK_VERSION=1

PERL-PADWALKER_CONFFILES=

PERL-PADWALKER_BUILD_DIR=$(BUILD_DIR)/perl-padwalker
PERL-PADWALKER_SOURCE_DIR=$(SOURCE_DIR)/perl-padwalker
PERL-PADWALKER_IPK_DIR=$(BUILD_DIR)/perl-padwalker-$(PERL-PADWALKER_VERSION)-ipk
PERL-PADWALKER_IPK=$(BUILD_DIR)/perl-padwalker_$(PERL-PADWALKER_VERSION)-$(PERL-PADWALKER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-PADWALKER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-PADWALKER_SITE)/$(PERL-PADWALKER_SOURCE)

perl-padwalker-source: $(DL_DIR)/$(PERL-PADWALKER_SOURCE) $(PERL-PADWALKER_PATCHES)

$(PERL-PADWALKER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-PADWALKER_SOURCE) $(PERL-PADWALKER_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-PADWALKER_DIR) $(PERL-PADWALKER_BUILD_DIR)
	$(PERL-PADWALKER_UNZIP) $(DL_DIR)/$(PERL-PADWALKER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-PADWALKER_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-PADWALKER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-PADWALKER_DIR) $(PERL-PADWALKER_BUILD_DIR)
	(cd $(PERL-PADWALKER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-padwalker-unpack: $(PERL-PADWALKER_BUILD_DIR)/.configured

$(PERL-PADWALKER_BUILD_DIR)/.built: $(PERL-PADWALKER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-PADWALKER_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-padwalker: $(PERL-PADWALKER_BUILD_DIR)/.built

$(PERL-PADWALKER_BUILD_DIR)/.staged: $(PERL-PADWALKER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-PADWALKER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-padwalker-stage: $(PERL-PADWALKER_BUILD_DIR)/.staged

$(PERL-PADWALKER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-padwalker" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-PADWALKER_PRIORITY)" >>$@
	@echo "Section: $(PERL-PADWALKER_SECTION)" >>$@
	@echo "Version: $(PERL-PADWALKER_VERSION)-$(PERL-PADWALKER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-PADWALKER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-PADWALKER_SITE)/$(PERL-PADWALKER_SOURCE)" >>$@
	@echo "Description: $(PERL-PADWALKER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-PADWALKER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-PADWALKER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-PADWALKER_CONFLICTS)" >>$@

$(PERL-PADWALKER_IPK): $(PERL-PADWALKER_BUILD_DIR)/.built
	rm -rf $(PERL-PADWALKER_IPK_DIR) $(BUILD_DIR)/perl-padwalker_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-PADWALKER_BUILD_DIR) DESTDIR=$(PERL-PADWALKER_IPK_DIR) install
	find $(PERL-PADWALKER_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-PADWALKER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-PADWALKER_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-PADWALKER_IPK_DIR)/CONTROL/control
	echo $(PERL-PADWALKER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-PADWALKER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-PADWALKER_IPK_DIR)

perl-padwalker-ipk: $(PERL-PADWALKER_IPK)

perl-padwalker-clean:
	-$(MAKE) -C $(PERL-PADWALKER_BUILD_DIR) clean

perl-padwalker-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-PADWALKER_DIR) $(PERL-PADWALKER_BUILD_DIR) $(PERL-PADWALKER_IPK_DIR) $(PERL-PADWALKER_IPK)

perl-padwalker-check: $(PERL-PADWALKER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-PADWALKER_IPK)
