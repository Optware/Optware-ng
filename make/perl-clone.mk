###########################################################
#
# perl-clone
#
###########################################################

PERL-CLONE_SITE=http://search.cpan.org/CPAN/authors/id/R/RD/RDF
PERL-CLONE_VERSION=0.29
PERL-CLONE_SOURCE=Clone-$(PERL-CLONE_VERSION).tar.gz
PERL-CLONE_DIR=Clone-$(PERL-CLONE_VERSION)
PERL-CLONE_UNZIP=zcat
PERL-CLONE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CLONE_DESCRIPTION=Clone - recursively copy Perl datatypes.
PERL-CLONE_SECTION=util
PERL-CLONE_PRIORITY=optional
PERL-CLONE_DEPENDS=perl
PERL-CLONE_SUGGESTS=
PERL-CLONE_CONFLICTS=

PERL-CLONE_IPK_VERSION=1

PERL-CLONE_CONFFILES=

PERL-CLONE_BUILD_DIR=$(BUILD_DIR)/perl-clone
PERL-CLONE_SOURCE_DIR=$(SOURCE_DIR)/perl-clone
PERL-CLONE_IPK_DIR=$(BUILD_DIR)/perl-clone-$(PERL-CLONE_VERSION)-ipk
PERL-CLONE_IPK=$(BUILD_DIR)/perl-clone_$(PERL-CLONE_VERSION)-$(PERL-CLONE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CLONE_SOURCE):
	$(WGET) -P $(@D) $(PERL-CLONE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-clone-source: $(DL_DIR)/$(PERL-CLONE_SOURCE) $(PERL-CLONE_PATCHES)

$(PERL-CLONE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CLONE_SOURCE) $(PERL-CLONE_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-CLONE_DIR) $(@D)
	$(PERL-CLONE_UNZIP) $(DL_DIR)/$(PERL-CLONE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CLONE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CLONE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CLONE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-clone-unpack: $(PERL-CLONE_BUILD_DIR)/.configured

$(PERL-CLONE_BUILD_DIR)/.built: $(PERL-CLONE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-clone: $(PERL-CLONE_BUILD_DIR)/.built

$(PERL-CLONE_BUILD_DIR)/.staged: $(PERL-CLONE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-clone-stage: $(PERL-CLONE_BUILD_DIR)/.staged

$(PERL-CLONE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-clone" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CLONE_PRIORITY)" >>$@
	@echo "Section: $(PERL-CLONE_SECTION)" >>$@
	@echo "Version: $(PERL-CLONE_VERSION)-$(PERL-CLONE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CLONE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CLONE_SITE)/$(PERL-CLONE_SOURCE)" >>$@
	@echo "Description: $(PERL-CLONE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CLONE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CLONE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CLONE_CONFLICTS)" >>$@

$(PERL-CLONE_IPK): $(PERL-CLONE_BUILD_DIR)/.built
	rm -rf $(PERL-CLONE_IPK_DIR) $(BUILD_DIR)/perl-clone_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CLONE_BUILD_DIR) DESTDIR=$(PERL-CLONE_IPK_DIR) install
	find $(PERL-CLONE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CLONE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CLONE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CLONE_IPK_DIR)/CONTROL/control
	echo $(PERL-CLONE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CLONE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CLONE_IPK_DIR)

perl-clone-ipk: $(PERL-CLONE_IPK)

perl-clone-clean:
	-$(MAKE) -C $(PERL-CLONE_BUILD_DIR) clean

perl-clone-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CLONE_DIR) $(PERL-CLONE_BUILD_DIR) $(PERL-CLONE_IPK_DIR) $(PERL-CLONE_IPK)
