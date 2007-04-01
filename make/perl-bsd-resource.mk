###########################################################
#
# perl-bsd-resource
#
###########################################################

PERL-BSD-RESOURCE_SITE=http://search.cpan.org/CPAN/authors/id/J/JH/JHI
PERL-BSD-RESOURCE_VERSION=1.28
PERL-BSD-RESOURCE_SOURCE=BSD-Resource-$(PERL-BSD-RESOURCE_VERSION).tar.gz
PERL-BSD-RESOURCE_DIR=BSD-Resource-$(PERL-BSD-RESOURCE_VERSION)
PERL-BSD-RESOURCE_UNZIP=zcat
PERL-BSD-RESOURCE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-BSD-RESOURCE_DESCRIPTION=BSD process resource limit and priority functions.
PERL-BSD-RESOURCE_SECTION=util
PERL-BSD-RESOURCE_PRIORITY=optional
PERL-BSD-RESOURCE_DEPENDS=perl
PERL-BSD-RESOURCE_SUGGESTS=
PERL-BSD-RESOURCE_CONFLICTS=

PERL-BSD-RESOURCE_IPK_VERSION=1

PERL-BSD-RESOURCE_CONFFILES=

PERL-BSD-RESOURCE_BUILD_DIR=$(BUILD_DIR)/perl-bsd-resource
PERL-BSD-RESOURCE_SOURCE_DIR=$(SOURCE_DIR)/perl-bsd-resource
PERL-BSD-RESOURCE_IPK_DIR=$(BUILD_DIR)/perl-bsd-resource-$(PERL-BSD-RESOURCE_VERSION)-ipk
PERL-BSD-RESOURCE_IPK=$(BUILD_DIR)/perl-bsd-resource_$(PERL-BSD-RESOURCE_VERSION)-$(PERL-BSD-RESOURCE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-BSD-RESOURCE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-BSD-RESOURCE_SITE)/$(PERL-BSD-RESOURCE_SOURCE)

perl-bsd-resource-source: $(DL_DIR)/$(PERL-BSD-RESOURCE_SOURCE) $(PERL-BSD-RESOURCE_PATCHES)

$(PERL-BSD-RESOURCE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-BSD-RESOURCE_SOURCE) $(PERL-BSD-RESOURCE_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-BSD-RESOURCE_DIR) $(PERL-BSD-RESOURCE_BUILD_DIR)
	$(PERL-BSD-RESOURCE_UNZIP) $(DL_DIR)/$(PERL-BSD-RESOURCE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-BSD-RESOURCE_DIR) $(PERL-BSD-RESOURCE_BUILD_DIR)
	(cd $(PERL-BSD-RESOURCE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-BSD-RESOURCE_BUILD_DIR)/.configured

perl-bsd-resource-unpack: $(PERL-BSD-RESOURCE_BUILD_DIR)/.configured

$(PERL-BSD-RESOURCE_BUILD_DIR)/.built: $(PERL-BSD-RESOURCE_BUILD_DIR)/.configured
	rm -f $(PERL-BSD-RESOURCE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-BSD-RESOURCE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-BSD-RESOURCE_BUILD_DIR)/.built

perl-bsd-resource: $(PERL-BSD-RESOURCE_BUILD_DIR)/.built

$(PERL-BSD-RESOURCE_BUILD_DIR)/.staged: $(PERL-BSD-RESOURCE_BUILD_DIR)/.built
	rm -f $(PERL-BSD-RESOURCE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-BSD-RESOURCE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-BSD-RESOURCE_BUILD_DIR)/.staged

perl-bsd-resource-stage: $(PERL-BSD-RESOURCE_BUILD_DIR)/.staged

$(PERL-BSD-RESOURCE_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-BSD-RESOURCE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-bsd-resource" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-BSD-RESOURCE_PRIORITY)" >>$@
	@echo "Section: $(PERL-BSD-RESOURCE_SECTION)" >>$@
	@echo "Version: $(PERL-BSD-RESOURCE_VERSION)-$(PERL-BSD-RESOURCE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-BSD-RESOURCE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-BSD-RESOURCE_SITE)/$(PERL-BSD-RESOURCE_SOURCE)" >>$@
	@echo "Description: $(PERL-BSD-RESOURCE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-BSD-RESOURCE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-BSD-RESOURCE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-BSD-RESOURCE_CONFLICTS)" >>$@

$(PERL-BSD-RESOURCE_IPK): $(PERL-BSD-RESOURCE_BUILD_DIR)/.built
	rm -rf $(PERL-BSD-RESOURCE_IPK_DIR) $(BUILD_DIR)/perl-bsd-resource_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-BSD-RESOURCE_BUILD_DIR) DESTDIR=$(PERL-BSD-RESOURCE_IPK_DIR) install
	find $(PERL-BSD-RESOURCE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-BSD-RESOURCE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-BSD-RESOURCE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-BSD-RESOURCE_IPK_DIR)/CONTROL/control
	echo $(PERL-BSD-RESOURCE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-BSD-RESOURCE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-BSD-RESOURCE_IPK_DIR)

perl-bsd-resource-ipk: $(PERL-BSD-RESOURCE_IPK)

perl-bsd-resource-clean:
	-$(MAKE) -C $(PERL-BSD-RESOURCE_BUILD_DIR) clean

perl-bsd-resource-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-BSD-RESOURCE_DIR) $(PERL-BSD-RESOURCE_BUILD_DIR) $(PERL-BSD-RESOURCE_IPK_DIR) $(PERL-BSD-RESOURCE_IPK)

perl-bsd-resource-check: $(PERL-BSD-RESOURCE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-BSD-RESOURCE_IPK)
