###########################################################
#
# perl-libxml-sax
#
###########################################################

PERL-LIBXML_SAX_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GR/GRANTM
PERL-LIBXML_SAX_VERSION=0.99
PERL-LIBXML_SAX_SOURCE=XML-SAX-$(PERL-LIBXML_SAX_VERSION).tar.gz
PERL-LIBXML_SAX_DIR=XML-SAX-$(PERL-LIBXML_SAX_VERSION)
PERL-LIBXML_SAX_UNZIP=zcat
PERL-LIBXML_SAX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBXML_SAX_DESCRIPTION=Perl module for using and building Perl SAX2 XML processors
PERL-LIBXML_SAX_SECTION=util
PERL-LIBXML_SAX_PRIORITY=optional
PERL-LIBXML_SAX_DEPENDS=perl, perl-libxml-namespacesupport, perl-libxml-sax-base
PERL-LIBXML_SAX_SUGGESTS=
PERL-LIBXML_SAX_CONFLICTS=

PERL-LIBXML_SAX_IPK_VERSION=2

PERL-LIBXML_SAX_CONFFILES=

PERL-LIBXML_SAX_PATCHES=$(PERL-LIBXML_SAX_SOURCE_DIR)/Makefile.PL.patch

PERL-LIBXML_SAX_BUILD_DIR=$(BUILD_DIR)/perl-libxml-sax
PERL-LIBXML_SAX_SOURCE_DIR=$(SOURCE_DIR)/perl-libxml-sax
PERL-LIBXML_SAX_IPK_DIR=$(BUILD_DIR)/perl-libxml-sax-$(PERL-LIBXML_SAX_VERSION)-ipk
PERL-LIBXML_SAX_IPK=$(BUILD_DIR)/perl-libxml-sax_$(PERL-LIBXML_SAX_VERSION)-$(PERL-LIBXML_SAX_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LIBXML_SAX_SOURCE):
	$(WGET) -P $(@D) $(PERL-LIBXML_SAX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-libxml-sax-source: $(DL_DIR)/$(PERL-LIBXML_SAX_SOURCE) $(PERL-LIBXML_SAX_PATCHES)

$(PERL-LIBXML_SAX_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBXML_SAX_SOURCE) $(PERL-LIBXML_SAX_PATCHES) make/perl-libxml-sax.mk
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_SAX_DIR) $(PERL-LIBXML_SAX_BUILD_DIR)
	$(PERL-LIBXML_SAX_UNZIP) $(DL_DIR)/$(PERL-LIBXML_SAX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL-LIBXML_SAX_PATCHES)" ; \
		then cat $(PERL-LIBXML_SAX_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PERL-LIBXML_SAX_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PERL-LIBXML_SAX_DIR) $(PERL-LIBXML_SAX_BUILD_DIR)
	(cd $(PERL-LIBXML_SAX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-LIBXML_SAX_BUILD_DIR)/.configured

perl-libxml-sax-unpack: $(PERL-LIBXML_SAX_BUILD_DIR)/.configured

$(PERL-LIBXML_SAX_BUILD_DIR)/.built: $(PERL-LIBXML_SAX_BUILD_DIR)/.configured
	rm -f $(PERL-LIBXML_SAX_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-LIBXML_SAX_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-LIBXML_SAX_BUILD_DIR)/.built

perl-libxml-sax: $(PERL-LIBXML_SAX_BUILD_DIR)/.built

$(PERL-LIBXML_SAX_BUILD_DIR)/.staged: $(PERL-LIBXML_SAX_BUILD_DIR)/.built
	rm -f $(PERL-LIBXML_SAX_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-LIBXML_SAX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-LIBXML_SAX_BUILD_DIR)/.staged

perl-libxml-sax-stage: $(PERL-LIBXML_SAX_BUILD_DIR)/.staged

$(PERL-LIBXML_SAX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-LIBXML_SAX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-libxml-sax" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBXML_SAX_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBXML_SAX_SECTION)" >>$@
	@echo "Version: $(PERL-LIBXML_SAX_VERSION)-$(PERL-LIBXML_SAX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBXML_SAX_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBXML_SAX_SITE)/$(PERL-LIBXML_SAX_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBXML_SAX_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBXML_SAX_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBXML_SAX_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBXML_SAX_CONFLICTS)" >>$@

$(PERL-LIBXML_SAX_IPK): $(PERL-LIBXML_SAX_BUILD_DIR)/.built
	rm -rf $(PERL-LIBXML_SAX_IPK_DIR) $(BUILD_DIR)/perl-libxml-sax_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBXML_SAX_BUILD_DIR) DESTDIR=$(PERL-LIBXML_SAX_IPK_DIR) install
	find $(PERL-LIBXML_SAX_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LIBXML_SAX_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-LIBXML_SAX_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-LIBXML_SAX_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBXML_SAX_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBXML_SAX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBXML_SAX_IPK_DIR)

perl-libxml-sax-ipk: $(PERL-LIBXML_SAX_IPK)

perl-libxml-sax-clean:
	-$(MAKE) -C $(PERL-LIBXML_SAX_BUILD_DIR) clean

perl-libxml-sax-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_SAX_DIR) $(PERL-LIBXML_SAX_BUILD_DIR) $(PERL-LIBXML_SAX_IPK_DIR) $(PERL-LIBXML_SAX_IPK)
#
#
# Some sanity check for the package.
#
perl-libxml-sax-check: $(PERL-LIBXML_SAX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
