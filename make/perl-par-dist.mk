###########################################################
#
# perl-par-dist
#
###########################################################

PERL-PAR-DIST_SITE=http://search.cpan.org/CPAN/authors/id/S/SM/SMUELLER
PERL-PAR-DIST_VERSION=0.21
PERL-PAR-DIST_SOURCE=PAR-Dist-$(PERL-PAR-DIST_VERSION).tar.gz
PERL-PAR-DIST_DIR=PAR-Dist-$(PERL-PAR-DIST_VERSION)
PERL-PAR-DIST_UNZIP=zcat
PERL-PAR-DIST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-PAR-DIST_DESCRIPTION=PAR-Dist - Create and manipulate PAR distributions.
PERL-PAR-DIST_SECTION=util
PERL-PAR-DIST_PRIORITY=optional
PERL-PAR-DIST_DEPENDS=perl
PERL-PAR-DIST_SUGGESTS=
PERL-PAR-DIST_CONFLICTS=

PERL-PAR-DIST_IPK_VERSION=2

PERL-PAR-DIST_CONFFILES=

PERL-PAR-DIST_BUILD_DIR=$(BUILD_DIR)/perl-par-dist
PERL-PAR-DIST_SOURCE_DIR=$(SOURCE_DIR)/perl-par-dist
PERL-PAR-DIST_IPK_DIR=$(BUILD_DIR)/perl-par-dist-$(PERL-PAR-DIST_VERSION)-ipk
PERL-PAR-DIST_IPK=$(BUILD_DIR)/perl-par-dist_$(PERL-PAR-DIST_VERSION)-$(PERL-PAR-DIST_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-PAR-DIST_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-PAR-DIST_SITE)/$(PERL-PAR-DIST_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PERL-PAR-DIST_SOURCE)

perl-par-dist-source: $(DL_DIR)/$(PERL-PAR-DIST_SOURCE) $(PERL-PAR-DIST_PATCHES)

$(PERL-PAR-DIST_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-PAR-DIST_SOURCE) $(PERL-PAR-DIST_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-PAR-DIST_DIR) $(PERL-PAR-DIST_BUILD_DIR)
	$(PERL-PAR-DIST_UNZIP) $(DL_DIR)/$(PERL-PAR-DIST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-PAR-DIST_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-PAR-DIST_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-PAR-DIST_DIR) $(PERL-PAR-DIST_BUILD_DIR)
	(cd $(PERL-PAR-DIST_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-PAR-DIST_BUILD_DIR)/.configured

perl-par-dist-unpack: $(PERL-PAR-DIST_BUILD_DIR)/.configured

$(PERL-PAR-DIST_BUILD_DIR)/.built: $(PERL-PAR-DIST_BUILD_DIR)/.configured
	rm -f $(PERL-PAR-DIST_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-PAR-DIST_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-PAR-DIST_BUILD_DIR)/.built

perl-par-dist: $(PERL-PAR-DIST_BUILD_DIR)/.built

$(PERL-PAR-DIST_BUILD_DIR)/.staged: $(PERL-PAR-DIST_BUILD_DIR)/.built
	rm -f $(PERL-PAR-DIST_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-PAR-DIST_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-PAR-DIST_BUILD_DIR)/.staged

perl-par-dist-stage: $(PERL-PAR-DIST_BUILD_DIR)/.staged

$(PERL-PAR-DIST_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-PAR-DIST_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-par-dist" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-PAR-DIST_PRIORITY)" >>$@
	@echo "Section: $(PERL-PAR-DIST_SECTION)" >>$@
	@echo "Version: $(PERL-PAR-DIST_VERSION)-$(PERL-PAR-DIST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-PAR-DIST_MAINTAINER)" >>$@
	@echo "Source: $(PERL-PAR-DIST_SITE)/$(PERL-PAR-DIST_SOURCE)" >>$@
	@echo "Description: $(PERL-PAR-DIST_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-PAR-DIST_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-PAR-DIST_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-PAR-DIST_CONFLICTS)" >>$@

$(PERL-PAR-DIST_IPK): $(PERL-PAR-DIST_BUILD_DIR)/.built
	rm -rf $(PERL-PAR-DIST_IPK_DIR) $(BUILD_DIR)/perl-par-dist_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-PAR-DIST_BUILD_DIR) DESTDIR=$(PERL-PAR-DIST_IPK_DIR) install
	find $(PERL-PAR-DIST_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-PAR-DIST_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-PAR-DIST_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-PAR-DIST_IPK_DIR)/CONTROL/control
	echo $(PERL-PAR-DIST_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-PAR-DIST_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-PAR-DIST_IPK_DIR)

perl-par-dist-ipk: $(PERL-PAR-DIST_IPK)

perl-par-dist-clean:
	-$(MAKE) -C $(PERL-PAR-DIST_BUILD_DIR) clean

perl-par-dist-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-PAR-DIST_DIR) $(PERL-PAR-DIST_BUILD_DIR) $(PERL-PAR-DIST_IPK_DIR) $(PERL-PAR-DIST_IPK)
