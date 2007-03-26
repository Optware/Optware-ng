###########################################################
#
# perl-io-stringy
#
###########################################################

PERL-IO-STRINGY_SITE=http://search.cpan.org/CPAN/authors/id/D/DS/DSKOLL
PERL-IO-STRINGY_VERSION=2.110
PERL-IO-STRINGY_SOURCE=IO-stringy-$(PERL-IO-STRINGY_VERSION).tar.gz
PERL-IO-STRINGY_DIR=IO-stringy-$(PERL-IO-STRINGY_VERSION)
PERL-IO-STRINGY_UNZIP=zcat
PERL-IO-STRINGY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IO-STRINGY_DESCRIPTION=IO-stringy - I/O on in-core objects like strings and arrays 
PERL-IO-STRINGY_SECTION=util
PERL-IO-STRINGY_PRIORITY=optional
PERL-IO-STRINGY_DEPENDS=
PERL-IO-STRINGY_SUGGESTS=
PERL-IO-STRINGY_CONFLICTS=

PERL-IO-STRINGY_IPK_VERSION=2

PERL-IO-STRINGY_CONFFILES=

PERL-IO-STRINGY_BUILD_DIR=$(BUILD_DIR)/perl-io-stringy
PERL-IO-STRINGY_SOURCE_DIR=$(SOURCE_DIR)/perl-io-stringy
PERL-IO-STRINGY_IPK_DIR=$(BUILD_DIR)/perl-io-stringy-$(PERL-IO-STRINGY_VERSION)-ipk
PERL-IO-STRINGY_IPK=$(BUILD_DIR)/perl-io-stringy_$(PERL-IO-STRINGY_VERSION)-$(PERL-IO-STRINGY_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IO-STRINGY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IO-STRINGY_SITE)/$(PERL-IO-STRINGY_SOURCE)

perl-io-stringy-source: $(DL_DIR)/$(PERL-IO-STRINGY_SOURCE) $(PERL-IO-STRINGY_PATCHES)

$(PERL-IO-STRINGY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IO-STRINGY_SOURCE) $(PERL-IO-STRINGY_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-IO-STRINGY_DIR) $(PERL-IO-STRINGY_BUILD_DIR)
	$(PERL-IO-STRINGY_UNZIP) $(DL_DIR)/$(PERL-IO-STRINGY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IO-STRINGY_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IO-STRINGY_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IO-STRINGY_DIR) $(PERL-IO-STRINGY_BUILD_DIR)
	(cd $(PERL-IO-STRINGY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-IO-STRINGY_BUILD_DIR)/.configured

perl-io-stringy-unpack: $(PERL-IO-STRINGY_BUILD_DIR)/.configured

$(PERL-IO-STRINGY_BUILD_DIR)/.built: $(PERL-IO-STRINGY_BUILD_DIR)/.configured
	rm -f $(PERL-IO-STRINGY_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-IO-STRINGY_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-IO-STRINGY_BUILD_DIR)/.built

perl-io-stringy: $(PERL-IO-STRINGY_BUILD_DIR)/.built

$(PERL-IO-STRINGY_BUILD_DIR)/.staged: $(PERL-IO-STRINGY_BUILD_DIR)/.built
	rm -f $(PERL-IO-STRINGY_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-IO-STRINGY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-IO-STRINGY_BUILD_DIR)/.staged

perl-io-stringy-stage: $(PERL-IO-STRINGY_BUILD_DIR)/.staged

$(PERL-IO-STRINGY_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-IO-STRINGY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-io-stringy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IO-STRINGY_PRIORITY)" >>$@
	@echo "Section: $(PERL-IO-STRINGY_SECTION)" >>$@
	@echo "Version: $(PERL-IO-STRINGY_VERSION)-$(PERL-IO-STRINGY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IO-STRINGY_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IO-STRINGY_SITE)/$(PERL-IO-STRINGY_SOURCE)" >>$@
	@echo "Description: $(PERL-IO-STRINGY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IO-STRINGY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IO-STRINGY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IO-STRINGY_CONFLICTS)" >>$@

$(PERL-IO-STRINGY_IPK): $(PERL-IO-STRINGY_BUILD_DIR)/.built
	rm -rf $(PERL-IO-STRINGY_IPK_DIR) $(BUILD_DIR)/perl-io-stringy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IO-STRINGY_BUILD_DIR) DESTDIR=$(PERL-IO-STRINGY_IPK_DIR) install
	find $(PERL-IO-STRINGY_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IO-STRINGY_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IO-STRINGY_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IO-STRINGY_IPK_DIR)/CONTROL/control
	echo $(PERL-IO-STRINGY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IO-STRINGY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IO-STRINGY_IPK_DIR)

perl-io-stringy-ipk: $(PERL-IO-STRINGY_IPK)

perl-io-stringy-clean:
	-$(MAKE) -C $(PERL-IO-STRINGY_BUILD_DIR) clean

perl-io-stringy-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IO-STRINGY_DIR) $(PERL-IO-STRINGY_BUILD_DIR) $(PERL-IO-STRINGY_IPK_DIR) $(PERL-IO-STRINGY_IPK)
