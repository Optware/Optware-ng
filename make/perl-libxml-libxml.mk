###########################################################
#
# perl-libxml-libxml
#
###########################################################

PERL-LIBXML_LIBXML_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/S/SH/SHLOMIF
PERL-LIBXML_LIBXML_VERSION=2.0124
PERL-LIBXML_LIBXML_SOURCE=XML-LibXML-$(PERL-LIBXML_LIBXML_VERSION).tar.gz
PERL-LIBXML_LIBXML_DIR=XML-LibXML-$(PERL-LIBXML_LIBXML_VERSION)
PERL-LIBXML_LIBXML_UNZIP=zcat
PERL-LIBXML_LIBXML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBXML_LIBXML_DESCRIPTION=Perl interface to the libxml2 library
PERL-LIBXML_LIBXML_SECTION=textproc
PERL-LIBXML_LIBXML_PRIORITY=optional
PERL-LIBXML_LIBXML_DEPENDS=perl, libxml2, perl-libxml-namespacesupport, perl-libxml-sax
PERL-LIBXML_LIBXML_SUGGESTS=
PERL-LIBXML_LIBXML_CONFLICTS=

PERL-LIBXML_LIBXML_IPK_VERSION=2

PERL-LIBXML_LIBXML_CONFFILES=

PERL-LIBXML_LIBXML_BUILD_DIR=$(BUILD_DIR)/perl-libxml-libxml
PERL-LIBXML_LIBXML_SOURCE_DIR=$(SOURCE_DIR)/perl-libxml-libxml
PERL-LIBXML_LIBXML_IPK_DIR=$(BUILD_DIR)/perl-libxml-libxml-$(PERL-LIBXML_LIBXML_VERSION)-ipk
PERL-LIBXML_LIBXML_IPK=$(BUILD_DIR)/perl-libxml-libxml_$(PERL-LIBXML_LIBXML_VERSION)-$(PERL-LIBXML_LIBXML_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LIBXML_LIBXML_SOURCE):
	$(WGET) -P $(@D) $(PERL-LIBXML_LIBXML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-libxml-libxml-source: $(DL_DIR)/$(PERL-LIBXML_LIBXML_SOURCE) $(PERL-LIBXML_LIBXML_PATCHES)

$(PERL-LIBXML_LIBXML_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBXML_LIBXML_SOURCE) $(PERL-LIBXML_LIBXML_PATCHES) make/perl-libxml-libxml.mk
	$(MAKE) libxml2-stage perl-hostperl
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_LIBXML_DIR) $(@D)
	$(PERL-LIBXML_LIBXML_UNZIP) $(DL_DIR)/$(PERL-LIBXML_LIBXML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-LIBXML_LIBXML_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-LIBXML_LIBXML_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-LIBXML_LIBXML_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	sed -i -e 's|-I/usr/include|-I$(STAGING_INCLUDE_DIR)|g' $(@D)/Makefile
	touch $@

perl-libxml-libxml-unpack: $(PERL-LIBXML_LIBXML_BUILD_DIR)/.configured

$(PERL-LIBXML_LIBXML_BUILD_DIR)/.built: $(PERL-LIBXML_LIBXML_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-libxml-libxml: $(PERL-LIBXML_LIBXML_BUILD_DIR)/.built

$(PERL-LIBXML_LIBXML_BUILD_DIR)/.staged: $(PERL-LIBXML_LIBXML_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-libxml-libxml-stage: $(PERL-LIBXML_LIBXML_BUILD_DIR)/.staged

$(PERL-LIBXML_LIBXML_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-libxml-libxml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBXML_LIBXML_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBXML_LIBXML_SECTION)" >>$@
	@echo "Version: $(PERL-LIBXML_LIBXML_VERSION)-$(PERL-LIBXML_LIBXML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBXML_LIBXML_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBXML_LIBXML_SITE)/$(PERL-LIBXML_LIBXML_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBXML_LIBXML_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBXML_LIBXML_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBXML_LIBXML_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBXML_LIBXML_CONFLICTS)" >>$@

$(PERL-LIBXML_LIBXML_IPK): $(PERL-LIBXML_LIBXML_BUILD_DIR)/.built
	rm -rf $(PERL-LIBXML_LIBXML_IPK_DIR) $(BUILD_DIR)/perl-libxml-libxml_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBXML_LIBXML_BUILD_DIR) DESTDIR=$(PERL-LIBXML_LIBXML_IPK_DIR) install
	find $(PERL-LIBXML_LIBXML_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LIBXML_LIBXML_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PERL-LIBXML_LIBXML_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBXML_LIBXML_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBXML_LIBXML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBXML_LIBXML_IPK_DIR)

perl-libxml-libxml-ipk: $(PERL-LIBXML_LIBXML_IPK)

perl-libxml-libxml-clean:
	-$(MAKE) -C $(PERL-LIBXML_LIBXML_BUILD_DIR) clean

perl-libxml-libxml-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBXML_LIBXML_DIR) $(PERL-LIBXML_LIBXML_BUILD_DIR) $(PERL-LIBXML_LIBXML_IPK_DIR) $(PERL-LIBXML_LIBXML_IPK)
#
#
# Some sanity check for the package.
#
perl-libxml-libxml-check: $(PERL-LIBXML_LIBXML_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
