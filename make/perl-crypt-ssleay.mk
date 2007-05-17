###########################################################
#
# perl-crypt-ssleay
#
###########################################################

PERL-CRYPT-SSLEAY_SITE=http://search.cpan.org/CPAN/authors/id/D/DL/DLAND
PERL-CRYPT-SSLEAY_VERSION=0.54
PERL-CRYPT-SSLEAY_SOURCE=Crypt-SSLeay-$(PERL-CRYPT-SSLEAY_VERSION).tar.gz
PERL-CRYPT-SSLEAY_DIR=Crypt-SSLeay-$(PERL-CRYPT-SSLEAY_VERSION)
PERL-CRYPT-SSLEAY_UNZIP=zcat
PERL-CRYPT-SSLEAY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CRYPT-SSLEAY_DESCRIPTION=OpenSSL glue that provides LWP https support.
PERL-CRYPT-SSLEAY_SECTION=util
PERL-CRYPT-SSLEAY_PRIORITY=optional
PERL-CRYPT-SSLEAY_DEPENDS=perl, openssl
PERL-CRYPT-SSLEAY_SUGGESTS=
PERL-CRYPT-SSLEAY_CONFLICTS=

PERL-CRYPT-SSLEAY_IPK_VERSION=1

PERL-CRYPT-SSLEAY_CONFFILES=
PERL-CRYPT-SSLEAY_PATCHES=$(PERL-CRYPT-SSLEAY_SOURCE_DIR)/Makefile.PL.patch

PERL-CRYPT-SSLEAY_BUILD_DIR=$(BUILD_DIR)/perl-crypt-ssleay
PERL-CRYPT-SSLEAY_SOURCE_DIR=$(SOURCE_DIR)/perl-crypt-ssleay
PERL-CRYPT-SSLEAY_IPK_DIR=$(BUILD_DIR)/perl-crypt-ssleay-$(PERL-CRYPT-SSLEAY_VERSION)-ipk
PERL-CRYPT-SSLEAY_IPK=$(BUILD_DIR)/perl-crypt-ssleay_$(PERL-CRYPT-SSLEAY_VERSION)-$(PERL-CRYPT-SSLEAY_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CRYPT-SSLEAY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CRYPT-SSLEAY_SITE)/$(PERL-CRYPT-SSLEAY_SOURCE)

perl-crypt-ssleay-source: $(DL_DIR)/$(PERL-CRYPT-SSLEAY_SOURCE) $(PERL-CRYPT-SSLEAY_PATCHES)

$(PERL-CRYPT-SSLEAY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CRYPT-SSLEAY_SOURCE) $(PERL-CRYPT-SSLEAY_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PERL-CRYPT-SSLEAY_DIR) $(PERL-CRYPT-SSLEAY_BUILD_DIR)
	$(PERL-CRYPT-SSLEAY_UNZIP) $(DL_DIR)/$(PERL-CRYPT-SSLEAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PERL-CRYPT-SSLEAY_PATCHES) | patch -bd $(BUILD_DIR)/$(PERL-CRYPT-SSLEAY_DIR) -p0
	mv $(BUILD_DIR)/$(PERL-CRYPT-SSLEAY_DIR) $(PERL-CRYPT-SSLEAY_BUILD_DIR)
	(cd $(PERL-CRYPT-SSLEAY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
                -lib=$(STAGING_PREFIX) \
		PREFIX=/opt \
	)
	touch $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.configured

perl-crypt-ssleay-unpack: $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.configured

$(PERL-CRYPT-SSLEAY_BUILD_DIR)/.built: $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.configured
	rm -f $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CRYPT-SSLEAY_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LD_RUN_PATH=/opt/lib \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.built

perl-crypt-ssleay: $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.built

$(PERL-CRYPT-SSLEAY_BUILD_DIR)/.staged: $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.built
	rm -f $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CRYPT-SSLEAY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.staged

perl-crypt-ssleay-stage: $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.staged

$(PERL-CRYPT-SSLEAY_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CRYPT-SSLEAY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-crypt-ssleay" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CRYPT-SSLEAY_PRIORITY)" >>$@
	@echo "Section: $(PERL-CRYPT-SSLEAY_SECTION)" >>$@
	@echo "Version: $(PERL-CRYPT-SSLEAY_VERSION)-$(PERL-CRYPT-SSLEAY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CRYPT-SSLEAY_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CRYPT-SSLEAY_SITE)/$(PERL-CRYPT-SSLEAY_SOURCE)" >>$@
	@echo "Description: $(PERL-CRYPT-SSLEAY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CRYPT-SSLEAY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CRYPT-SSLEAY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CRYPT-SSLEAY_CONFLICTS)" >>$@

$(PERL-CRYPT-SSLEAY_IPK): $(PERL-CRYPT-SSLEAY_BUILD_DIR)/.built
	rm -rf $(PERL-CRYPT-SSLEAY_IPK_DIR) $(BUILD_DIR)/perl-crypt-ssleay_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CRYPT-SSLEAY_BUILD_DIR) DESTDIR=$(PERL-CRYPT-SSLEAY_IPK_DIR) install
	find $(PERL-CRYPT-SSLEAY_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CRYPT-SSLEAY_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CRYPT-SSLEAY_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CRYPT-SSLEAY_IPK_DIR)/CONTROL/control
	echo $(PERL-CRYPT-SSLEAY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CRYPT-SSLEAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CRYPT-SSLEAY_IPK_DIR)

perl-crypt-ssleay-ipk: $(PERL-CRYPT-SSLEAY_IPK)

perl-crypt-ssleay-clean:
	-$(MAKE) -C $(PERL-CRYPT-SSLEAY_BUILD_DIR) clean

perl-crypt-ssleay-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CRYPT-SSLEAY_DIR) $(PERL-CRYPT-SSLEAY_BUILD_DIR) $(PERL-CRYPT-SSLEAY_IPK_DIR) $(PERL-CRYPT-SSLEAY_IPK)

perl-crypt-ssleay-check: $(PERL-CRYPT-SSLEAY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-CRYPT-SSLEAY_IPK)
