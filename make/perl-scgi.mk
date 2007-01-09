###########################################################
#
# perl-scgi
#
###########################################################

PERL-SCGI_SITE=http://search.cpan.org/CPAN/authors/id/V/VI/VIPERCODE
PERL-SCGI_VERSION=0.6
PERL-SCGI_SOURCE=SCGI-$(PERL-SCGI_VERSION).tar.gz
PERL-SCGI_DIR=SCGI-$(PERL-SCGI_VERSION)
PERL-SCGI_UNZIP=zcat
PERL-SCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-SCGI_DESCRIPTION=The Perl SCGI server library.
PERL-SCGI_SECTION=web
PERL-SCGI_PRIORITY=optional
PERL-SCGI_DEPENDS=perl
PERL-SCGI_SUGGESTS=
PERL-SCGI_CONFLICTS=

PERL-SCGI_IPK_VERSION=1

PERL-SCGI_CONFFILES=

PERL-SCGI_BUILD_DIR=$(BUILD_DIR)/perl-scgi
PERL-SCGI_SOURCE_DIR=$(SOURCE_DIR)/perl-scgi
PERL-SCGI_IPK_DIR=$(BUILD_DIR)/perl-scgi-$(PERL-SCGI_VERSION)-ipk
PERL-SCGI_IPK=$(BUILD_DIR)/perl-scgi_$(PERL-SCGI_VERSION)-$(PERL-SCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-SCGI_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-SCGI_SITE)/$(PERL-SCGI_SOURCE)

perl-scgi-source: $(DL_DIR)/$(PERL-SCGI_SOURCE) $(PERL-SCGI_PATCHES)

$(PERL-SCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-SCGI_SOURCE) $(PERL-SCGI_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-SCGI_DIR) $(PERL-SCGI_BUILD_DIR)
	$(PERL-SCGI_UNZIP) $(DL_DIR)/$(PERL-SCGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-SCGI_DIR) $(PERL-SCGI_BUILD_DIR)
	(cd $(PERL-SCGI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-SCGI_BUILD_DIR)/.configured

perl-scgi-unpack: $(PERL-SCGI_BUILD_DIR)/.configured

$(PERL-SCGI_BUILD_DIR)/.built: $(PERL-SCGI_BUILD_DIR)/.configured
	rm -f $(PERL-SCGI_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-SCGI_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-SCGI_BUILD_DIR)/.built

perl-scgi: $(PERL-SCGI_BUILD_DIR)/.built

$(PERL-SCGI_BUILD_DIR)/.staged: $(PERL-SCGI_BUILD_DIR)/.built
	rm -f $(PERL-SCGI_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-SCGI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-SCGI_BUILD_DIR)/.staged

perl-scgi-stage: $(PERL-SCGI_BUILD_DIR)/.staged

$(PERL-SCGI_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-SCGI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-scgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-SCGI_PRIORITY)" >>$@
	@echo "Section: $(PERL-SCGI_SECTION)" >>$@
	@echo "Version: $(PERL-SCGI_VERSION)-$(PERL-SCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-SCGI_MAINTAINER)" >>$@
	@echo "Source: $(PERL-SCGI_SITE)/$(PERL-SCGI_SOURCE)" >>$@
	@echo "Description: $(PERL-SCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-SCGI_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-SCGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-SCGI_CONFLICTS)" >>$@

$(PERL-SCGI_IPK): $(PERL-SCGI_BUILD_DIR)/.built
	rm -rf $(PERL-SCGI_IPK_DIR) $(BUILD_DIR)/perl-scgi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-SCGI_BUILD_DIR) DESTDIR=$(PERL-SCGI_IPK_DIR) install
	find $(PERL-SCGI_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-SCGI_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-SCGI_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-SCGI_IPK_DIR)/CONTROL/control
	echo $(PERL-SCGI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-SCGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-SCGI_IPK_DIR)

perl-scgi-ipk: $(PERL-SCGI_IPK)

perl-scgi-clean:
	-$(MAKE) -C $(PERL-SCGI_BUILD_DIR) clean

perl-scgi-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-SCGI_DIR) $(PERL-SCGI_BUILD_DIR) $(PERL-SCGI_IPK_DIR) $(PERL-SCGI_IPK)
