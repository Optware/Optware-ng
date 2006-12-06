###########################################################
#
# perl-crypt-openssl-rsa
#
###########################################################

PERL-CRYPT-OPENSSL-RSA_SITE=http://search.cpan.org/CPAN/authors/id/I/IR/IROBERTS
PERL-CRYPT-OPENSSL-RSA_VERSION=0.24
PERL-CRYPT-OPENSSL-RSA_SOURCE=Crypt-OpenSSL-RSA-$(PERL-CRYPT-OPENSSL-RSA_VERSION).tar.gz
PERL-CRYPT-OPENSSL-RSA_DIR=Crypt-OpenSSL-RSA-$(PERL-CRYPT-OPENSSL-RSA_VERSION)
PERL-CRYPT-OPENSSL-RSA_UNZIP=zcat
PERL-CRYPT-OPENSSL-RSA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CRYPT-OPENSSL-RSA_DESCRIPTION=Crypt-OpenSSL-RSA - RSA encoding and decoding, using the openSSL libraries
PERL-CRYPT-OPENSSL-RSA_SECTION=util
PERL-CRYPT-OPENSSL-RSA_PRIORITY=optional
PERL-CRYPT-OPENSSL-RSA_DEPENDS=perl, openssl, perl-crypt-openssl-random
PERL-CRYPT-OPENSSL-RSA_SUGGESTS=
PERL-CRYPT-OPENSSL-RSA_CONFLICTS=

PERL-CRYPT-OPENSSL-RSA_IPK_VERSION=1

PERL-CRYPT-OPENSSL-RSA_CONFFILES=

PERL-CRYPT-OPENSSL-RSA_BUILD_DIR=$(BUILD_DIR)/perl-crypt-openssl-rsa
PERL-CRYPT-OPENSSL-RSA_SOURCE_DIR=$(SOURCE_DIR)/perl-crypt-openssl-rsa
PERL-CRYPT-OPENSSL-RSA_IPK_DIR=$(BUILD_DIR)/perl-crypt-openssl-rsa-$(PERL-CRYPT-OPENSSL-RSA_VERSION)-ipk
PERL-CRYPT-OPENSSL-RSA_IPK=$(BUILD_DIR)/perl-crypt-openssl-rsa_$(PERL-CRYPT-OPENSSL-RSA_VERSION)-$(PERL-CRYPT-OPENSSL-RSA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-crypt-openssl-rsa-source perl-crypt-openssl-rsa-unpack perl-crypt-openssl-rsa perl-crypt-openssl-rsa-stage perl-crypt-openssl-rsa-ipk perl-crypt-openssl-rsa-clean perl-crypt-openssl-rsa-dirclean perl-crypt-openssl-rsa-check

$(DL_DIR)/$(PERL-CRYPT-OPENSSL-RSA_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CRYPT-OPENSSL-RSA_SITE)/$(PERL-CRYPT-OPENSSL-RSA_SOURCE)

perl-crypt-openssl-rsa-source: $(DL_DIR)/$(PERL-CRYPT-OPENSSL-RSA_SOURCE) $(PERL-CRYPT-OPENSSL-RSA_PATCHES)

$(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CRYPT-OPENSSL-RSA_SOURCE) $(PERL-CRYPT-OPENSSL-RSA_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RSA_DIR) $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)
	$(PERL-CRYPT-OPENSSL-RSA_UNZIP) $(DL_DIR)/$(PERL-CRYPT-OPENSSL-RSA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CRYPT-OPENSSL-RSA_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RSA_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RSA_DIR) $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)
	(cd $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR); \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
		INC="-I$(STAGING_INCLUDE_DIR)" \
		LIBS="$(STAGING_LDFLAGS) -lssl -lcrypto" \
	)
	touch $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.configured

perl-crypt-openssl-rsa-unpack: $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.configured

$(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.built: $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.configured
	rm -f $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS)" \
	LDDLFLAGS="-shared -rpath=/opt/lib" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" 
	touch $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.built

perl-crypt-openssl-rsa: $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.built

$(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.staged: $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.built
	rm -f $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.staged

perl-crypt-openssl-rsa-stage: $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.staged

$(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-crypt-openssl-rsa" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CRYPT-OPENSSL-RSA_PRIORITY)" >>$@
	@echo "Section: $(PERL-CRYPT-OPENSSL-RSA_SECTION)" >>$@
	@echo "Version: $(PERL-CRYPT-OPENSSL-RSA_VERSION)-$(PERL-CRYPT-OPENSSL-RSA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CRYPT-OPENSSL-RSA_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CRYPT-OPENSSL-RSA_SITE)/$(PERL-CRYPT-OPENSSL-RSA_SOURCE)" >>$@
	@echo "Description: $(PERL-CRYPT-OPENSSL-RSA_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CRYPT-OPENSSL-RSA_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CRYPT-OPENSSL-RSA_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CRYPT-OPENSSL-RSA_CONFLICTS)" >>$@

$(PERL-CRYPT-OPENSSL-RSA_IPK): $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR)/.built
	rm -rf $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR) $(BUILD_DIR)/perl-crypt-openssl-rsa_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR) DESTDIR=$(PERL-CRYPT-OPENSSL-RSA_IPK_DIR) install
	find $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/CONTROL/control
	echo $(PERL-CRYPT-OPENSSL-RSA_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR)

perl-crypt-openssl-rsa-ipk: $(PERL-CRYPT-OPENSSL-RSA_IPK)

perl-crypt-openssl-rsa-clean:
	-$(MAKE) -C $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR) clean

perl-crypt-openssl-rsa-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RSA_DIR) $(PERL-CRYPT-OPENSSL-RSA_BUILD_DIR) $(PERL-CRYPT-OPENSSL-RSA_IPK_DIR) $(PERL-CRYPT-OPENSSL-RSA_IPK)
#
#
# Some sanity check for the package.
#
#
perl-crypt-openssl-rsa-check: $(PERL-CRYPT-OPENSSL-RSA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-CRYPT-OPENSSL-RSA_IPK)

