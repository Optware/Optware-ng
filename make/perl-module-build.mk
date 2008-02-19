###########################################################
#
# perl-module-build
#
###########################################################

PERL-MODULE-BUILD_SITE=http://search.cpan.org/CPAN/authors/id/K/KW/KWILLIAMS
PERL-MODULE-BUILD_VERSION=0.2808
PERL-MODULE-BUILD_SOURCE=Module-Build-$(PERL-MODULE-BUILD_VERSION).tar.gz
PERL-MODULE-BUILD_DIR=Module-Build-$(PERL-MODULE-BUILD_VERSION)
PERL-MODULE-BUILD_UNZIP=zcat
PERL-MODULE-BUILD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MODULE-BUILD_DESCRIPTION=Module-Build - Build and install Perl modules.
PERL-MODULE-BUILD_SECTION=util
PERL-MODULE-BUILD_PRIORITY=optional
PERL-MODULE-BUILD_DEPENDS=perl, perl-archive-tar, perl-extutils-cbuilder, perl-extutils-parsexs, perl-pod-readme, perl-module-signature
PERL-MODULE-BUILD_SUGGESTS=
PERL-MODULE-BUILD_CONFLICTS=

PERL-MODULE-BUILD_IPK_VERSION=1

PERL-MODULE-BUILD_CONFFILES=

PERL-MODULE-BUILD_BUILD_DIR=$(BUILD_DIR)/perl-module-build
PERL-MODULE-BUILD_SOURCE_DIR=$(SOURCE_DIR)/perl-module-build
PERL-MODULE-BUILD_IPK_DIR=$(BUILD_DIR)/perl-module-build-$(PERL-MODULE-BUILD_VERSION)-ipk
PERL-MODULE-BUILD_IPK=$(BUILD_DIR)/perl-module-build_$(PERL-MODULE-BUILD_VERSION)-$(PERL-MODULE-BUILD_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MODULE-BUILD_SITE)/$(PERL-MODULE-BUILD_SOURCE)

perl-module-build-source: $(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE) $(PERL-MODULE-BUILD_PATCHES)

$(PERL-MODULE-BUILD_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE) $(PERL-MODULE-BUILD_PATCHES)
	$(MAKE) perl-archive-tar-stage perl-extutils-cbuilder-stage perl-extutils-parsexs-stage \
		perl-pod-readme-stage perl-module-signature-stage
	rm -rf $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) $(PERL-MODULE-BUILD_BUILD_DIR)
	$(PERL-MODULE-BUILD_UNZIP) $(DL_DIR)/$(PERL-MODULE-BUILD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-MODULE-BUILD_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) $(PERL-MODULE-BUILD_BUILD_DIR)
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Build.PL \
		--config CC=$(TARGET_CC) \
	)
	touch $(PERL-MODULE-BUILD_BUILD_DIR)/.configured

perl-module-build-unpack: $(PERL-MODULE-BUILD_BUILD_DIR)/.configured

$(PERL-MODULE-BUILD_BUILD_DIR)/.built: $(PERL-MODULE-BUILD_BUILD_DIR)/.configured
	rm -f $(PERL-MODULE-BUILD_BUILD_DIR)/.built
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
		./Build \
	)
	touch $(PERL-MODULE-BUILD_BUILD_DIR)/.built

perl-module-build: $(PERL-MODULE-BUILD_BUILD_DIR)/.built

$(PERL-MODULE-BUILD_BUILD_DIR)/.staged: $(PERL-MODULE-BUILD_BUILD_DIR)/.built
	rm -f $(PERL-MODULE-BUILD_BUILD_DIR)/.staged
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
	 	./Build --prefix $(STAGING_DIR)/opt install \
	)
	touch $(PERL-MODULE-BUILD_BUILD_DIR)/.staged

perl-module-build-stage: $(PERL-MODULE-BUILD_BUILD_DIR)/.staged

$(PERL-MODULE-BUILD_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-MODULE-BUILD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-module-build" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MODULE-BUILD_PRIORITY)" >>$@
	@echo "Section: $(PERL-MODULE-BUILD_SECTION)" >>$@
	@echo "Version: $(PERL-MODULE-BUILD_VERSION)-$(PERL-MODULE-BUILD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MODULE-BUILD_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MODULE-BUILD_SITE)/$(PERL-MODULE-BUILD_SOURCE)" >>$@
	@echo "Description: $(PERL-MODULE-BUILD_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MODULE-BUILD_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MODULE-BUILD_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MODULE-BUILD_CONFLICTS)" >>$@

$(PERL-MODULE-BUILD_IPK): $(PERL-MODULE-BUILD_BUILD_DIR)/.built
	rm -rf $(PERL-MODULE-BUILD_IPK_DIR) $(BUILD_DIR)/perl-module-build_*_$(TARGET_ARCH).ipk
	(cd $(PERL-MODULE-BUILD_BUILD_DIR); \
       		./Build --prefix $(PERL-MODULE-BUILD_IPK_DIR)/opt install \
	)
	find $(PERL-MODULE-BUILD_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MODULE-BUILD_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MODULE-BUILD_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	sed -i -e 's|$(PERL_HOSTPERL)|/opt/bin/perl|g' $(PERL-MODULE-BUILD_IPK_DIR)/opt/bin/*
	$(MAKE) $(PERL-MODULE-BUILD_IPK_DIR)/CONTROL/control
	echo $(PERL-MODULE-BUILD_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MODULE-BUILD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MODULE-BUILD_IPK_DIR)

perl-module-build-ipk: $(PERL-MODULE-BUILD_IPK)

perl-module-build-clean:
	-$(MAKE) -C $(PERL-MODULE-BUILD_BUILD_DIR) clean

perl-module-build-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MODULE-BUILD_DIR) $(PERL-MODULE-BUILD_BUILD_DIR) $(PERL-MODULE-BUILD_IPK_DIR) $(PERL-MODULE-BUILD_IPK)
