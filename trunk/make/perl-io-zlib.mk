###########################################################
#
# perl-io-zlib
#
###########################################################

PERL-IO-ZLIB_SITE=http://search.cpan.org/CPAN/authors/id/T/TO/TOMHUGHES
PERL-IO-ZLIB_VERSION=1.09
PERL-IO-ZLIB_SOURCE=IO-Zlib-$(PERL-IO-ZLIB_VERSION).tar.gz
PERL-IO-ZLIB_DIR=IO-Zlib-$(PERL-IO-ZLIB_VERSION)
PERL-IO-ZLIB_UNZIP=zcat
PERL-IO-ZLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IO-ZLIB_DESCRIPTION=IO-Zlib - IO:: style interface to Compress::Zlib.
PERL-IO-ZLIB_SECTION=util
PERL-IO-ZLIB_PRIORITY=optional
PERL-IO-ZLIB_DEPENDS=perl, perl-compress-zlib
PERL-IO-ZLIB_SUGGESTS=
PERL-IO-ZLIB_CONFLICTS=

PERL-IO-ZLIB_IPK_VERSION=1

PERL-IO-ZLIB_CONFFILES=

PERL-IO-ZLIB_BUILD_DIR=$(BUILD_DIR)/perl-io-zlib
PERL-IO-ZLIB_SOURCE_DIR=$(SOURCE_DIR)/perl-io-zlib
PERL-IO-ZLIB_IPK_DIR=$(BUILD_DIR)/perl-io-zlib-$(PERL-IO-ZLIB_VERSION)-ipk
PERL-IO-ZLIB_IPK=$(BUILD_DIR)/perl-io-zlib_$(PERL-IO-ZLIB_VERSION)-$(PERL-IO-ZLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IO-ZLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IO-ZLIB_SITE)/$(PERL-IO-ZLIB_SOURCE)

perl-io-zlib-source: $(DL_DIR)/$(PERL-IO-ZLIB_SOURCE) $(PERL-IO-ZLIB_PATCHES)

$(PERL-IO-ZLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IO-ZLIB_SOURCE) $(PERL-IO-ZLIB_PATCHES)
	$(MAKE) perl-compress-zlib-stage
	rm -rf $(BUILD_DIR)/$(PERL-IO-ZLIB_DIR) $(PERL-IO-ZLIB_BUILD_DIR)
	$(PERL-IO-ZLIB_UNZIP) $(DL_DIR)/$(PERL-IO-ZLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IO-ZLIB_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IO-ZLIB_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IO-ZLIB_DIR) $(PERL-IO-ZLIB_BUILD_DIR)
	(cd $(PERL-IO-ZLIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-IO-ZLIB_BUILD_DIR)/.configured

perl-io-zlib-unpack: $(PERL-IO-ZLIB_BUILD_DIR)/.configured

$(PERL-IO-ZLIB_BUILD_DIR)/.built: $(PERL-IO-ZLIB_BUILD_DIR)/.configured
	rm -f $(PERL-IO-ZLIB_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-IO-ZLIB_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-IO-ZLIB_BUILD_DIR)/.built

perl-io-zlib: $(PERL-IO-ZLIB_BUILD_DIR)/.built

$(PERL-IO-ZLIB_BUILD_DIR)/.staged: $(PERL-IO-ZLIB_BUILD_DIR)/.built
	rm -f $(PERL-IO-ZLIB_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-IO-ZLIB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-IO-ZLIB_BUILD_DIR)/.staged

perl-io-zlib-stage: $(PERL-IO-ZLIB_BUILD_DIR)/.staged

$(PERL-IO-ZLIB_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-IO-ZLIB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-io-zlib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IO-ZLIB_PRIORITY)" >>$@
	@echo "Section: $(PERL-IO-ZLIB_SECTION)" >>$@
	@echo "Version: $(PERL-IO-ZLIB_VERSION)-$(PERL-IO-ZLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IO-ZLIB_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IO-ZLIB_SITE)/$(PERL-IO-ZLIB_SOURCE)" >>$@
	@echo "Description: $(PERL-IO-ZLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IO-ZLIB_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IO-ZLIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IO-ZLIB_CONFLICTS)" >>$@

$(PERL-IO-ZLIB_IPK): $(PERL-IO-ZLIB_BUILD_DIR)/.built
	rm -rf $(PERL-IO-ZLIB_IPK_DIR) $(BUILD_DIR)/perl-io-zlib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IO-ZLIB_BUILD_DIR) DESTDIR=$(PERL-IO-ZLIB_IPK_DIR) install
	find $(PERL-IO-ZLIB_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IO-ZLIB_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IO-ZLIB_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IO-ZLIB_IPK_DIR)/CONTROL/control
	echo $(PERL-IO-ZLIB_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IO-ZLIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IO-ZLIB_IPK_DIR)

perl-io-zlib-ipk: $(PERL-IO-ZLIB_IPK)

perl-io-zlib-clean:
	-$(MAKE) -C $(PERL-IO-ZLIB_BUILD_DIR) clean

perl-io-zlib-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IO-ZLIB_DIR) $(PERL-IO-ZLIB_BUILD_DIR) $(PERL-IO-ZLIB_IPK_DIR) $(PERL-IO-ZLIB_IPK)
