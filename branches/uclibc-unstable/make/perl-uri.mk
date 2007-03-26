###########################################################
#
# perl-uri
#
###########################################################

PERL-URI_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-URI_VERSION=1.35
PERL-URI_SOURCE=URI-$(PERL-URI_VERSION).tar.gz
PERL-URI_DIR=URI-$(PERL-URI_VERSION)
PERL-URI_UNZIP=zcat
PERL-URI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-URI_DESCRIPTION=URI - <module_description>
PERL-URI_SECTION=util
PERL-URI_PRIORITY=optional
PERL-URI_DEPENDS=perl
PERL-URI_SUGGESTS=
PERL-URI_CONFLICTS=

PERL-URI_IPK_VERSION=3

PERL-URI_CONFFILES=

PERL-URI_BUILD_DIR=$(BUILD_DIR)/perl-uri
PERL-URI_SOURCE_DIR=$(SOURCE_DIR)/perl-uri
PERL-URI_IPK_DIR=$(BUILD_DIR)/perl-uri-$(PERL-URI_VERSION)-ipk
PERL-URI_IPK=$(BUILD_DIR)/perl-uri_$(PERL-URI_VERSION)-$(PERL-URI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-URI_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-URI_SITE)/$(PERL-URI_SOURCE)

perl-uri-source: $(DL_DIR)/$(PERL-URI_SOURCE) $(PERL-URI_PATCHES)

$(PERL-URI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-URI_SOURCE) $(PERL-URI_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-URI_DIR) $(PERL-URI_BUILD_DIR)
	$(PERL-URI_UNZIP) $(DL_DIR)/$(PERL-URI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-URI_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-URI_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-URI_DIR) $(PERL-URI_BUILD_DIR)
	(cd $(PERL-URI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-URI_BUILD_DIR)/.configured

perl-uri-unpack: $(PERL-URI_BUILD_DIR)/.configured

$(PERL-URI_BUILD_DIR)/.built: $(PERL-URI_BUILD_DIR)/.configured
	rm -f $(PERL-URI_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-URI_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-URI_BUILD_DIR)/.built

perl-uri: $(PERL-URI_BUILD_DIR)/.built

$(PERL-URI_BUILD_DIR)/.staged: $(PERL-URI_BUILD_DIR)/.built
	rm -f $(PERL-URI_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-URI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-URI_BUILD_DIR)/.staged

perl-uri-stage: $(PERL-URI_BUILD_DIR)/.staged

$(PERL-URI_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-URI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-uri" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-URI_PRIORITY)" >>$@
	@echo "Section: $(PERL-URI_SECTION)" >>$@
	@echo "Version: $(PERL-URI_VERSION)-$(PERL-URI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-URI_MAINTAINER)" >>$@
	@echo "Source: $(PERL-URI_SITE)/$(PERL-URI_SOURCE)" >>$@
	@echo "Description: $(PERL-URI_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-URI_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-URI_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-URI_CONFLICTS)" >>$@

$(PERL-URI_IPK): $(PERL-URI_BUILD_DIR)/.built
	rm -rf $(PERL-URI_IPK_DIR) $(BUILD_DIR)/perl-uri_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-URI_BUILD_DIR) DESTDIR=$(PERL-URI_IPK_DIR) install
	find $(PERL-URI_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-URI_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-URI_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-URI_IPK_DIR)/CONTROL/control
	echo $(PERL-URI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-URI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-URI_IPK_DIR)

perl-uri-ipk: $(PERL-URI_IPK)

perl-uri-clean:
	-$(MAKE) -C $(PERL-URI_BUILD_DIR) clean

perl-uri-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-URI_DIR) $(PERL-URI_BUILD_DIR) $(PERL-URI_IPK_DIR) $(PERL-URI_IPK)
