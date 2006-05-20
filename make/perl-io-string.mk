###########################################################
#
# perl-io-string
#
###########################################################

PERL-IO-STRING_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-IO-STRING_VERSION=1.08
PERL-IO-STRING_SOURCE=IO-String-$(PERL-IO-STRING_VERSION).tar.gz
PERL-IO-STRING_DIR=IO-String-$(PERL-IO-STRING_VERSION)
PERL-IO-STRING_UNZIP=zcat
PERL-IO-STRING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IO-STRING_DESCRIPTION=IO-String - Emulate file interface for in-core strings.
PERL-IO-STRING_SECTION=util
PERL-IO-STRING_PRIORITY=optional
PERL-IO-STRING_DEPENDS=perl
PERL-IO-STRING_SUGGESTS=
PERL-IO-STRING_CONFLICTS=

PERL-IO-STRING_IPK_VERSION=1

PERL-IO-STRING_CONFFILES=

PERL-IO-STRING_BUILD_DIR=$(BUILD_DIR)/perl-io-string
PERL-IO-STRING_SOURCE_DIR=$(SOURCE_DIR)/perl-io-string
PERL-IO-STRING_IPK_DIR=$(BUILD_DIR)/perl-io-string-$(PERL-IO-STRING_VERSION)-ipk
PERL-IO-STRING_IPK=$(BUILD_DIR)/perl-io-string_$(PERL-IO-STRING_VERSION)-$(PERL-IO-STRING_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IO-STRING_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IO-STRING_SITE)/$(PERL-IO-STRING_SOURCE)

perl-io-string-source: $(DL_DIR)/$(PERL-IO-STRING_SOURCE) $(PERL-IO-STRING_PATCHES)

$(PERL-IO-STRING_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IO-STRING_SOURCE) $(PERL-IO-STRING_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PERL-IO-STRING_DIR) $(PERL-IO-STRING_BUILD_DIR)
	$(PERL-IO-STRING_UNZIP) $(DL_DIR)/$(PERL-IO-STRING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IO-STRING_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IO-STRING_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IO-STRING_DIR) $(PERL-IO-STRING_BUILD_DIR)
	(cd $(PERL-IO-STRING_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-IO-STRING_BUILD_DIR)/.configured

perl-io-string-unpack: $(PERL-IO-STRING_BUILD_DIR)/.configured

$(PERL-IO-STRING_BUILD_DIR)/.built: $(PERL-IO-STRING_BUILD_DIR)/.configured
	rm -f $(PERL-IO-STRING_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-IO-STRING_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-IO-STRING_BUILD_DIR)/.built

perl-io-string: $(PERL-IO-STRING_BUILD_DIR)/.built

$(PERL-IO-STRING_BUILD_DIR)/.staged: $(PERL-IO-STRING_BUILD_DIR)/.built
	rm -f $(PERL-IO-STRING_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-IO-STRING_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-IO-STRING_BUILD_DIR)/.staged

perl-io-string-stage: $(PERL-IO-STRING_BUILD_DIR)/.staged

$(PERL-IO-STRING_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-IO-STRING_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-io-string" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IO-STRING_PRIORITY)" >>$@
	@echo "Section: $(PERL-IO-STRING_SECTION)" >>$@
	@echo "Version: $(PERL-IO-STRING_VERSION)-$(PERL-IO-STRING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IO-STRING_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IO-STRING_SITE)/$(PERL-IO-STRING_SOURCE)" >>$@
	@echo "Description: $(PERL-IO-STRING_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IO-STRING_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IO-STRING_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IO-STRING_CONFLICTS)" >>$@

$(PERL-IO-STRING_IPK): $(PERL-IO-STRING_BUILD_DIR)/.built
	rm -rf $(PERL-IO-STRING_IPK_DIR) $(BUILD_DIR)/perl-io-string_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IO-STRING_BUILD_DIR) DESTDIR=$(PERL-IO-STRING_IPK_DIR) install
	find $(PERL-IO-STRING_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IO-STRING_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IO-STRING_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IO-STRING_IPK_DIR)/CONTROL/control
	echo $(PERL-IO-STRING_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IO-STRING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IO-STRING_IPK_DIR)

perl-io-string-ipk: $(PERL-IO-STRING_IPK)

perl-io-string-clean:
	-$(MAKE) -C $(PERL-IO-STRING_BUILD_DIR) clean

perl-io-string-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IO-STRING_DIR) $(PERL-IO-STRING_BUILD_DIR) $(PERL-IO-STRING_IPK_DIR) $(PERL-IO-STRING_IPK)
