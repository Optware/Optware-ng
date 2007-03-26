###########################################################
#
# perl-mime-tools
#
###########################################################

PERL-MIME-TOOLS_SITE=http://search.cpan.org/CPAN/authors/id/D/DS/DSKOLL
PERL-MIME-TOOLS_VERSION=5.420
PERL-MIME-TOOLS_SOURCE=MIME-tools-$(PERL-MIME-TOOLS_VERSION).tar.gz
PERL-MIME-TOOLS_DIR=MIME-tools-$(PERL-MIME-TOOLS_VERSION)
PERL-MIME-TOOLS_UNZIP=zcat
PERL-MIME-TOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MIME-TOOLS_DESCRIPTION=MIME-tools - modules for parsing (and creating!) MIME entities
PERL-MIME-TOOLS_SECTION=util
PERL-MIME-TOOLS_PRIORITY=optional
PERL-MIME-TOOLS_DEPENDS=perl, perl-io-stringy, perl-mailtools, \
 perl-unicode-map, perl-unicode-string, perl-convert-binhex
PERL-MIME-TOOLS_SUGGESTS=
PERL-MIME-TOOLS_CONFLICTS=

PERL-MIME-TOOLS_IPK_VERSION=1

PERL-MIME-TOOLS_CONFFILES=

PERL-MIME-TOOLS_BUILD_DIR=$(BUILD_DIR)/perl-mime-tools
PERL-MIME-TOOLS_SOURCE_DIR=$(SOURCE_DIR)/perl-mime-tools
PERL-MIME-TOOLS_IPK_DIR=$(BUILD_DIR)/perl-mime-tools-$(PERL-MIME-TOOLS_VERSION)-ipk
PERL-MIME-TOOLS_IPK=$(BUILD_DIR)/perl-mime-tools_$(PERL-MIME-TOOLS_VERSION)-$(PERL-MIME-TOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MIME-TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MIME-TOOLS_SITE)/$(PERL-MIME-TOOLS_SOURCE)

perl-mime-tools-source: $(DL_DIR)/$(PERL-MIME-TOOLS_SOURCE) $(PERL-MIME-TOOLS_PATCHES)

$(PERL-MIME-TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MIME-TOOLS_SOURCE) $(PERL-MIME-TOOLS_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-MIME-TOOLS_DIR) $(PERL-MIME-TOOLS_BUILD_DIR)
	$(PERL-MIME-TOOLS_UNZIP) $(DL_DIR)/$(PERL-MIME-TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-MIME-TOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-MIME-TOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MIME-TOOLS_DIR) $(PERL-MIME-TOOLS_BUILD_DIR)
	(cd $(PERL-MIME-TOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-MIME-TOOLS_BUILD_DIR)/.configured

perl-mime-tools-unpack: $(PERL-MIME-TOOLS_BUILD_DIR)/.configured

$(PERL-MIME-TOOLS_BUILD_DIR)/.built: $(PERL-MIME-TOOLS_BUILD_DIR)/.configured
	rm -f $(PERL-MIME-TOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-MIME-TOOLS_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-MIME-TOOLS_BUILD_DIR)/.built

perl-mime-tools: $(PERL-MIME-TOOLS_BUILD_DIR)/.built

$(PERL-MIME-TOOLS_BUILD_DIR)/.staged: $(PERL-MIME-TOOLS_BUILD_DIR)/.built
	rm -f $(PERL-MIME-TOOLS_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-MIME-TOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-MIME-TOOLS_BUILD_DIR)/.staged

perl-mime-tools-stage: $(PERL-MIME-TOOLS_BUILD_DIR)/.staged

$(PERL-MIME-TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-MIME-TOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-mime-tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MIME-TOOLS_PRIORITY)" >>$@
	@echo "Section: $(PERL-MIME-TOOLS_SECTION)" >>$@
	@echo "Version: $(PERL-MIME-TOOLS_VERSION)-$(PERL-MIME-TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MIME-TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MIME-TOOLS_SITE)/$(PERL-MIME-TOOLS_SOURCE)" >>$@
	@echo "Description: $(PERL-MIME-TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MIME-TOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MIME-TOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MIME-TOOLS_CONFLICTS)" >>$@

$(PERL-MIME-TOOLS_IPK): $(PERL-MIME-TOOLS_BUILD_DIR)/.built
	rm -rf $(PERL-MIME-TOOLS_IPK_DIR) $(BUILD_DIR)/perl-mime-tools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MIME-TOOLS_BUILD_DIR) DESTDIR=$(PERL-MIME-TOOLS_IPK_DIR) install
	find $(PERL-MIME-TOOLS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MIME-TOOLS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MIME-TOOLS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-MIME-TOOLS_IPK_DIR)/CONTROL/control
	echo $(PERL-MIME-TOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MIME-TOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MIME-TOOLS_IPK_DIR)

perl-mime-tools-ipk: $(PERL-MIME-TOOLS_IPK)

perl-mime-tools-clean:
	-$(MAKE) -C $(PERL-MIME-TOOLS_BUILD_DIR) clean

perl-mime-tools-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MIME-TOOLS_DIR) $(PERL-MIME-TOOLS_BUILD_DIR) $(PERL-MIME-TOOLS_IPK_DIR) $(PERL-MIME-TOOLS_IPK)
