###########################################################
#
# perl-xml-regexp
#
###########################################################

PERL-XML-REGEXP_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/T/TJ/TJMATHER
PERL-XML-REGEXP_VERSION=0.03
PERL-XML-REGEXP_SOURCE=XML-RegExp-$(PERL-XML-REGEXP_VERSION).tar.gz
PERL-XML-REGEXP_DIR=XML-RegExp-$(PERL-XML-REGEXP_VERSION)
PERL-XML-REGEXP_UNZIP=zcat
PERL-XML-REGEXP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-XML-REGEXP_DESCRIPTION=Regular expressions for XML tokens
PERL-XML-REGEXP_SECTION=textproc
PERL-XML-REGEXP_PRIORITY=optional
PERL-XML-REGEXP_DEPENDS=perl
PERL-XML-REGEXP_SUGGESTS=
PERL-XML-REGEXP_CONFLICTS=

PERL-XML-REGEXP_IPK_VERSION=3

PERL-XML-REGEXP_CONFFILES=

PERL-XML-REGEXP_BUILD_DIR=$(BUILD_DIR)/perl-xml-regexp
PERL-XML-REGEXP_SOURCE_DIR=$(SOURCE_DIR)/perl-xml-regexp
PERL-XML-REGEXP_IPK_DIR=$(BUILD_DIR)/perl-xml-regexp-$(PERL-XML-REGEXP_VERSION)-ipk
PERL-XML-REGEXP_IPK=$(BUILD_DIR)/perl-xml-regexp_$(PERL-XML-REGEXP_VERSION)-$(PERL-XML-REGEXP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-XML-REGEXP_SOURCE):
	$(WGET) -P $(@D) $(PERL-XML-REGEXP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-xml-regexp-source: $(DL_DIR)/$(PERL-XML-REGEXP_SOURCE) $(PERL-XML-REGEXP_PATCHES)

$(PERL-XML-REGEXP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-XML-REGEXP_SOURCE) $(PERL-XML-REGEXP_PATCHES) make/perl-xml-regexp.mk
	rm -rf $(BUILD_DIR)/$(PERL-XML-REGEXP_DIR) $(@D)
	$(PERL-XML-REGEXP_UNZIP) $(DL_DIR)/$(PERL-XML-REGEXP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-XML-REGEXP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-XML-REGEXP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-XML-REGEXP_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-xml-regexp-unpack: $(PERL-XML-REGEXP_BUILD_DIR)/.configured

$(PERL-XML-REGEXP_BUILD_DIR)/.built: $(PERL-XML-REGEXP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-xml-regexp: $(PERL-XML-REGEXP_BUILD_DIR)/.built

$(PERL-XML-REGEXP_BUILD_DIR)/.staged: $(PERL-XML-REGEXP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-xml-regexp-stage: $(PERL-XML-REGEXP_BUILD_DIR)/.staged

$(PERL-XML-REGEXP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-xml-regexp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-XML-REGEXP_PRIORITY)" >>$@
	@echo "Section: $(PERL-XML-REGEXP_SECTION)" >>$@
	@echo "Version: $(PERL-XML-REGEXP_VERSION)-$(PERL-XML-REGEXP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-XML-REGEXP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-XML-REGEXP_SITE)/$(PERL-XML-REGEXP_SOURCE)" >>$@
	@echo "Description: $(PERL-XML-REGEXP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-XML-REGEXP_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-XML-REGEXP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-XML-REGEXP_CONFLICTS)" >>$@

$(PERL-XML-REGEXP_IPK): $(PERL-XML-REGEXP_BUILD_DIR)/.built
	rm -rf $(PERL-XML-REGEXP_IPK_DIR) $(BUILD_DIR)/perl-xml-regexp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-XML-REGEXP_BUILD_DIR) DESTDIR=$(PERL-XML-REGEXP_IPK_DIR) install
	find $(PERL-XML-REGEXP_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-XML-REGEXP_IPK_DIR)/CONTROL/control
	echo $(PERL-XML-REGEXP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-XML-REGEXP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-XML-REGEXP_IPK_DIR)

perl-xml-regexp-ipk: $(PERL-XML-REGEXP_IPK)

perl-xml-regexp-clean:
	-$(MAKE) -C $(PERL-XML-REGEXP_BUILD_DIR) clean

perl-xml-regexp-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-XML-REGEXP_DIR) $(PERL-XML-REGEXP_BUILD_DIR) $(PERL-XML-REGEXP_IPK_DIR) $(PERL-XML-REGEXP_IPK)
