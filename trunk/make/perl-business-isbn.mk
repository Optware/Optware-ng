###########################################################
#
# perl-business-isbn
#
###########################################################

PERL-BUSINESS-ISBN_SITE=http://search.cpan.org/CPAN/authors/id/B/BD/BDFOY
PERL-BUSINESS-ISBN_VERSION=1.84
PERL-BUSINESS-ISBN_SOURCE=Business-ISBN-$(PERL-BUSINESS-ISBN_VERSION).tar.gz
PERL-BUSINESS-ISBN_DIR=Business-ISBN-$(PERL-BUSINESS-ISBN_VERSION)
PERL-BUSINESS-ISBN_UNZIP=zcat
PERL-BUSINESS-ISBN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-BUSINESS-ISBN_DESCRIPTION=Business-ISBN - work with International Standard Book Numbers
PERL-BUSINESS-ISBN_SECTION=util
PERL-BUSINESS-ISBN_PRIORITY=optional
PERL-BUSINESS-ISBN_DEPENDS=perl, perl-gd-barcode, perl-business-isbn-data
PERL-BUSINESS-ISBN_SUGGESTS=
PERL-BUSINESS-ISBN_CONFLICTS=

PERL-BUSINESS-ISBN_IPK_VERSION=1

PERL-BUSINESS-ISBN_CONFFILES=

PERL-BUSINESS-ISBN_BUILD_DIR=$(BUILD_DIR)/perl-business-isbn
PERL-BUSINESS-ISBN_SOURCE_DIR=$(SOURCE_DIR)/perl-business-isbn
PERL-BUSINESS-ISBN_IPK_DIR=$(BUILD_DIR)/perl-business-isbn-$(PERL-BUSINESS-ISBN_VERSION)-ipk
PERL-BUSINESS-ISBN_IPK=$(BUILD_DIR)/perl-business-isbn_$(PERL-BUSINESS-ISBN_VERSION)-$(PERL-BUSINESS-ISBN_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-BUSINESS-ISBN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-BUSINESS-ISBN_SITE)/$(PERL-BUSINESS-ISBN_SOURCE)

perl-business-isbn-source: $(DL_DIR)/$(PERL-BUSINESS-ISBN_SOURCE) $(PERL-BUSINESS-ISBN_PATCHES)

$(PERL-BUSINESS-ISBN_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-BUSINESS-ISBN_SOURCE) $(PERL-BUSINESS-ISBN_PATCHES)
	$(MAKE) perl-gd-barcode-stage perl-business-isbn-data-stage
	rm -rf $(BUILD_DIR)/$(PERL-BUSINESS-ISBN_DIR) $(PERL-BUSINESS-ISBN_BUILD_DIR)
	$(PERL-BUSINESS-ISBN_UNZIP) $(DL_DIR)/$(PERL-BUSINESS-ISBN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-BUSINESS-ISBN_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-BUSINESS-ISBN_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-BUSINESS-ISBN_DIR) $(PERL-BUSINESS-ISBN_BUILD_DIR)
	(cd $(PERL-BUSINESS-ISBN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-BUSINESS-ISBN_BUILD_DIR)/.configured

perl-business-isbn-unpack: $(PERL-BUSINESS-ISBN_BUILD_DIR)/.configured

$(PERL-BUSINESS-ISBN_BUILD_DIR)/.built: $(PERL-BUSINESS-ISBN_BUILD_DIR)/.configured
	rm -f $(PERL-BUSINESS-ISBN_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-BUSINESS-ISBN_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-BUSINESS-ISBN_BUILD_DIR)/.built

perl-business-isbn: $(PERL-BUSINESS-ISBN_BUILD_DIR)/.built

$(PERL-BUSINESS-ISBN_BUILD_DIR)/.staged: $(PERL-BUSINESS-ISBN_BUILD_DIR)/.built
	rm -f $(PERL-BUSINESS-ISBN_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-BUSINESS-ISBN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-BUSINESS-ISBN_BUILD_DIR)/.staged

perl-business-isbn-stage: $(PERL-BUSINESS-ISBN_BUILD_DIR)/.staged

$(PERL-BUSINESS-ISBN_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-BUSINESS-ISBN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-business-isbn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-BUSINESS-ISBN_PRIORITY)" >>$@
	@echo "Section: $(PERL-BUSINESS-ISBN_SECTION)" >>$@
	@echo "Version: $(PERL-BUSINESS-ISBN_VERSION)-$(PERL-BUSINESS-ISBN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-BUSINESS-ISBN_MAINTAINER)" >>$@
	@echo "Source: $(PERL-BUSINESS-ISBN_SITE)/$(PERL-BUSINESS-ISBN_SOURCE)" >>$@
	@echo "Description: $(PERL-BUSINESS-ISBN_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-BUSINESS-ISBN_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-BUSINESS-ISBN_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-BUSINESS-ISBN_CONFLICTS)" >>$@

$(PERL-BUSINESS-ISBN_IPK): $(PERL-BUSINESS-ISBN_BUILD_DIR)/.built
	rm -rf $(PERL-BUSINESS-ISBN_IPK_DIR) $(BUILD_DIR)/perl-business-isbn_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-BUSINESS-ISBN_BUILD_DIR) DESTDIR=$(PERL-BUSINESS-ISBN_IPK_DIR) install
	find $(PERL-BUSINESS-ISBN_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-BUSINESS-ISBN_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-BUSINESS-ISBN_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-BUSINESS-ISBN_IPK_DIR)/CONTROL/control
	echo $(PERL-BUSINESS-ISBN_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-BUSINESS-ISBN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-BUSINESS-ISBN_IPK_DIR)

perl-business-isbn-ipk: $(PERL-BUSINESS-ISBN_IPK)

perl-business-isbn-clean:
	-$(MAKE) -C $(PERL-BUSINESS-ISBN_BUILD_DIR) clean

perl-business-isbn-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-BUSINESS-ISBN_DIR) $(PERL-BUSINESS-ISBN_BUILD_DIR) $(PERL-BUSINESS-ISBN_IPK_DIR) $(PERL-BUSINESS-ISBN_IPK)
