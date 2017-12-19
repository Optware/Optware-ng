###########################################################
#
# perl-libxml
#
###########################################################

PERL-LIBXML_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/K/KM/KMACLEOD
PERL-LIBXML_VERSION=0.08
PERL-LIBXML_SOURCE=libxml-perl-$(PERL-LIBXML_VERSION).tar.gz
PERL-LIBXML_DIR=libxml-perl-$(PERL-LIBXML_VERSION)
PERL-LIBXML_UNZIP=zcat
PERL-LIBXML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBXML_DESCRIPTION=Collection of Perl modules for working with XML
PERL-LIBXML_SECTION=textproc
PERL-LIBXML_PRIORITY=optional
PERL-LIBXML_DEPENDS=perl-xml-parser
PERL-LIBXML_SUGGESTS=
PERL-LIBXML_CONFLICTS=

PERL-LIBXML_IPK_VERSION=3

PERL-LIBXML_CONFFILES=

PERL-LIBXML_BUILD_DIR=$(BUILD_DIR)/perl-libxml
PERL-LIBXML_SOURCE_DIR=$(SOURCE_DIR)/perl-libxml
PERL-LIBXML_IPK_DIR=$(BUILD_DIR)/perl-libxml-$(PERL-LIBXML_VERSION)-ipk
PERL-LIBXML_IPK=$(BUILD_DIR)/perl-libxml_$(PERL-LIBXML_VERSION)-$(PERL-LIBXML_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LIBXML_SOURCE):
	$(WGET) -P $(@D) $(PERL-LIBXML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-libxml-source: $(DL_DIR)/$(PERL-LIBXML_SOURCE) $(PERL-LIBXML_PATCHES)

$(PERL-LIBXML_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBXML_SOURCE) $(PERL-LIBXML_PATCHES) make/perl-libxml.mk
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_DIR) $(@D)
	$(PERL-LIBXML_UNZIP) $(DL_DIR)/$(PERL-LIBXML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-LIBXML_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-LIBXML_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-LIBXML_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-libxml-unpack: $(PERL-LIBXML_BUILD_DIR)/.configured

$(PERL-LIBXML_BUILD_DIR)/.built: $(PERL-LIBXML_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-libxml: $(PERL-LIBXML_BUILD_DIR)/.built

$(PERL-LIBXML_BUILD_DIR)/.staged: $(PERL-LIBXML_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-libxml-stage: $(PERL-LIBXML_BUILD_DIR)/.staged

$(PERL-LIBXML_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-libxml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBXML_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBXML_SECTION)" >>$@
	@echo "Version: $(PERL-LIBXML_VERSION)-$(PERL-LIBXML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBXML_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBXML_SITE)/$(PERL-LIBXML_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBXML_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBXML_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBXML_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBXML_CONFLICTS)" >>$@

$(PERL-LIBXML_IPK): $(PERL-LIBXML_BUILD_DIR)/.built
	rm -rf $(PERL-LIBXML_IPK_DIR) $(BUILD_DIR)/perl-libxml_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBXML_BUILD_DIR) DESTDIR=$(PERL-LIBXML_IPK_DIR) install
	find $(PERL-LIBXML_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-LIBXML_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBXML_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBXML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBXML_IPK_DIR)

perl-libxml-ipk: $(PERL-LIBXML_IPK)

perl-libxml-clean:
	-$(MAKE) -C $(PERL-LIBXML_BUILD_DIR) clean

perl-libxml-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_DIR) $(PERL-LIBXML_BUILD_DIR) $(PERL-LIBXML_IPK_DIR) $(PERL-LIBXML_IPK)
