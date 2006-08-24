###########################################################
#
# perl-unicode-map
#
###########################################################

PERL-UNICODE-MAP_SITE=http://search.cpan.org/CPAN/authors/id/M/MS/MSCHWARTZ
PERL-UNICODE-MAP_VERSION=0.112
PERL-UNICODE-MAP_SOURCE=Unicode-Map-$(PERL-UNICODE-MAP_VERSION).tar.gz
PERL-UNICODE-MAP_DIR=Unicode-Map-$(PERL-UNICODE-MAP_VERSION)
PERL-UNICODE-MAP_UNZIP=zcat
PERL-UNICODE-MAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-UNICODE-MAP_DESCRIPTION=Unicode-Map - V0.112 - maps charsets from and to utf16 unicode
PERL-UNICODE-MAP_SECTION=util
PERL-UNICODE-MAP_PRIORITY=optional
PERL-UNICODE-MAP_DEPENDS=perl
PERL-UNICODE-MAP_SUGGESTS=
PERL-UNICODE-MAP_CONFLICTS=

PERL-UNICODE-MAP_IPK_VERSION=1

PERL-UNICODE-MAP_CONFFILES=

PERL-UNICODE-MAP_BUILD_DIR=$(BUILD_DIR)/perl-unicode-map
PERL-UNICODE-MAP_SOURCE_DIR=$(SOURCE_DIR)/perl-unicode-map
PERL-UNICODE-MAP_IPK_DIR=$(BUILD_DIR)/perl-unicode-map-$(PERL-UNICODE-MAP_VERSION)-ipk
PERL-UNICODE-MAP_IPK=$(BUILD_DIR)/perl-unicode-map_$(PERL-UNICODE-MAP_VERSION)-$(PERL-UNICODE-MAP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-UNICODE-MAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-UNICODE-MAP_SITE)/$(PERL-UNICODE-MAP_SOURCE)

perl-unicode-map-source: $(DL_DIR)/$(PERL-UNICODE-MAP_SOURCE) $(PERL-UNICODE-MAP_PATCHES)

$(PERL-UNICODE-MAP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-UNICODE-MAP_SOURCE) $(PERL-UNICODE-MAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-UNICODE-MAP_DIR) $(PERL-UNICODE-MAP_BUILD_DIR)
	$(PERL-UNICODE-MAP_UNZIP) $(DL_DIR)/$(PERL-UNICODE-MAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-UNICODE-MAP_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-UNICODE-MAP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-UNICODE-MAP_DIR) $(PERL-UNICODE-MAP_BUILD_DIR)
	(cd $(PERL-UNICODE-MAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-UNICODE-MAP_BUILD_DIR)/.configured

perl-unicode-map-unpack: $(PERL-UNICODE-MAP_BUILD_DIR)/.configured

$(PERL-UNICODE-MAP_BUILD_DIR)/.built: $(PERL-UNICODE-MAP_BUILD_DIR)/.configured
	rm -f $(PERL-UNICODE-MAP_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-UNICODE-MAP_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-UNICODE-MAP_BUILD_DIR)/.built

perl-unicode-map: $(PERL-UNICODE-MAP_BUILD_DIR)/.built

$(PERL-UNICODE-MAP_BUILD_DIR)/.staged: $(PERL-UNICODE-MAP_BUILD_DIR)/.built
	rm -f $(PERL-UNICODE-MAP_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-UNICODE-MAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-UNICODE-MAP_BUILD_DIR)/.staged

perl-unicode-map-stage: $(PERL-UNICODE-MAP_BUILD_DIR)/.staged

$(PERL-UNICODE-MAP_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-UNICODE-MAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-unicode-map" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-UNICODE-MAP_PRIORITY)" >>$@
	@echo "Section: $(PERL-UNICODE-MAP_SECTION)" >>$@
	@echo "Version: $(PERL-UNICODE-MAP_VERSION)-$(PERL-UNICODE-MAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-UNICODE-MAP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-UNICODE-MAP_SITE)/$(PERL-UNICODE-MAP_SOURCE)" >>$@
	@echo "Description: $(PERL-UNICODE-MAP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-UNICODE-MAP_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-UNICODE-MAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-UNICODE-MAP_CONFLICTS)" >>$@

$(PERL-UNICODE-MAP_IPK): $(PERL-UNICODE-MAP_BUILD_DIR)/.built
	rm -rf $(PERL-UNICODE-MAP_IPK_DIR) $(BUILD_DIR)/perl-unicode-map_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-UNICODE-MAP_BUILD_DIR) DESTDIR=$(PERL-UNICODE-MAP_IPK_DIR) install
	find $(PERL-UNICODE-MAP_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-UNICODE-MAP_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-UNICODE-MAP_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-UNICODE-MAP_IPK_DIR)/CONTROL/control
	echo $(PERL-UNICODE-MAP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-UNICODE-MAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-UNICODE-MAP_IPK_DIR)

perl-unicode-map-ipk: $(PERL-UNICODE-MAP_IPK)

perl-unicode-map-clean:
	-$(MAKE) -C $(PERL-UNICODE-MAP_BUILD_DIR) clean

perl-unicode-map-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-UNICODE-MAP_DIR) $(PERL-UNICODE-MAP_BUILD_DIR) $(PERL-UNICODE-MAP_IPK_DIR) $(PERL-UNICODE-MAP_IPK)
