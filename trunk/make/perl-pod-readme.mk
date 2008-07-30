###########################################################
#
# perl-pod-readme
#
###########################################################

PERL-POD-README_SITE=http://search.cpan.org/CPAN/authors/id/R/RR/RRWO
# Yes, there is a newer, but Module::Build requires only 0.04 and the newer
# version of Pod::Readme requires Pod::Text 3.0 and version 2.21 is installed
PERL-POD-README_VERSION=0.081
PERL-POD-README_SOURCE=Pod-Readme-$(PERL-POD-README_VERSION).tar.gz
PERL-POD-README_DIR=Pod-Readme-$(PERL-POD-README_VERSION)
PERL-POD-README_UNZIP=zcat
PERL-POD-README_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-POD-README_DESCRIPTION=Pod-Readme - Convert POD to README file.
PERL-POD-README_SECTION=util
PERL-POD-README_PRIORITY=optional
PERL-POD-README_DEPENDS=perl
PERL-POD-README_SUGGESTS=
PERL-POD-README_CONFLICTS=

PERL-POD-README_IPK_VERSION=2

PERL-POD-README_CONFFILES=

PERL-POD-README_BUILD_DIR=$(BUILD_DIR)/perl-pod-readme
PERL-POD-README_SOURCE_DIR=$(SOURCE_DIR)/perl-pod-readme
PERL-POD-README_IPK_DIR=$(BUILD_DIR)/perl-pod-readme-$(PERL-POD-README_VERSION)-ipk
PERL-POD-README_IPK=$(BUILD_DIR)/perl-pod-readme_$(PERL-POD-README_VERSION)-$(PERL-POD-README_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-POD-README_SOURCE):
	$(WGET) -P $(@D) $(PERL-POD-README_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-pod-readme-source: $(DL_DIR)/$(PERL-POD-README_SOURCE) $(PERL-POD-README_PATCHES)

$(PERL-POD-README_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-POD-README_SOURCE) $(PERL-POD-README_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-POD-README_DIR) $(PERL-POD-README_BUILD_DIR)
	$(PERL-POD-README_UNZIP) $(DL_DIR)/$(PERL-POD-README_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-POD-README_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-POD-README_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-POD-README_DIR) $(PERL-POD-README_BUILD_DIR)
	(cd $(PERL-POD-README_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-POD-README_BUILD_DIR)/.configured

perl-pod-readme-unpack: $(PERL-POD-README_BUILD_DIR)/.configured

$(PERL-POD-README_BUILD_DIR)/.built: $(PERL-POD-README_BUILD_DIR)/.configured
	rm -f $(PERL-POD-README_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-POD-README_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-POD-README_BUILD_DIR)/.built

perl-pod-readme: $(PERL-POD-README_BUILD_DIR)/.built

$(PERL-POD-README_BUILD_DIR)/.staged: $(PERL-POD-README_BUILD_DIR)/.built
	rm -f $(PERL-POD-README_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-POD-README_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-POD-README_BUILD_DIR)/.staged

perl-pod-readme-stage: $(PERL-POD-README_BUILD_DIR)/.staged

$(PERL-POD-README_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-POD-README_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-pod-readme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-POD-README_PRIORITY)" >>$@
	@echo "Section: $(PERL-POD-README_SECTION)" >>$@
	@echo "Version: $(PERL-POD-README_VERSION)-$(PERL-POD-README_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-POD-README_MAINTAINER)" >>$@
	@echo "Source: $(PERL-POD-README_SITE)/$(PERL-POD-README_SOURCE)" >>$@
	@echo "Description: $(PERL-POD-README_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-POD-README_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-POD-README_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-POD-README_CONFLICTS)" >>$@

$(PERL-POD-README_IPK): $(PERL-POD-README_BUILD_DIR)/.built
	rm -rf $(PERL-POD-README_IPK_DIR) $(BUILD_DIR)/perl-pod-readme_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-POD-README_BUILD_DIR) DESTDIR=$(PERL-POD-README_IPK_DIR) install
	find $(PERL-POD-README_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-POD-README_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-POD-README_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-POD-README_IPK_DIR)/CONTROL/control
	echo $(PERL-POD-README_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-POD-README_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-POD-README_IPK_DIR)

perl-pod-readme-ipk: $(PERL-POD-README_IPK)

perl-pod-readme-clean:
	-$(MAKE) -C $(PERL-POD-README_BUILD_DIR) clean

perl-pod-readme-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-POD-README_DIR) $(PERL-POD-README_BUILD_DIR) $(PERL-POD-README_IPK_DIR) $(PERL-POD-README_IPK)
