###########################################################
#
# perl-crypt-openssl-random
#
###########################################################

PERL-CRYPT-OPENSSL-RANDOM_SITE=http://search.cpan.org/CPAN/authors/id/I/IR/IROBERTS
PERL-CRYPT-OPENSSL-RANDOM_VERSION=0.03
PERL-CRYPT-OPENSSL-RANDOM_SOURCE=Crypt-OpenSSL-Random-$(PERL-CRYPT-OPENSSL-RANDOM_VERSION).tar.gz
PERL-CRYPT-OPENSSL-RANDOM_DIR=Crypt-OpenSSL-Random-$(PERL-CRYPT-OPENSSL-RANDOM_VERSION)
PERL-CRYPT-OPENSSL-RANDOM_UNZIP=zcat
PERL-CRYPT-OPENSSL-RANDOM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CRYPT-OPENSSL-RANDOM_DESCRIPTION=Crypt-OpenSSL-Random - Routines for accessing the OpenSSL pseudo-random number generator
PERL-CRYPT-OPENSSL-RANDOM_SECTION=util
PERL-CRYPT-OPENSSL-RANDOM_PRIORITY=optional
PERL-CRYPT-OPENSSL-RANDOM_DEPENDS=perl, openssl
PERL-CRYPT-OPENSSL-RANDOM_SUGGESTS=
PERL-CRYPT-OPENSSL-RANDOM_CONFLICTS=

PERL-CRYPT-OPENSSL-RANDOM_IPK_VERSION=1

PERL-CRYPT-OPENSSL-RANDOM_CONFFILES=

PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR=$(BUILD_DIR)/perl-crypt-openssl-random
PERL-CRYPT-OPENSSL-RANDOM_SOURCE_DIR=$(SOURCE_DIR)/perl-crypt-openssl-random
PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR=$(BUILD_DIR)/perl-crypt-openssl-random-$(PERL-CRYPT-OPENSSL-RANDOM_VERSION)-ipk
PERL-CRYPT-OPENSSL-RANDOM_IPK=$(BUILD_DIR)/perl-crypt-openssl-random_$(PERL-CRYPT-OPENSSL-RANDOM_VERSION)-$(PERL-CRYPT-OPENSSL-RANDOM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-crypt-openssl-random-source perl-crypt-openssl-random-unpack perl-crypt-openssl-random perl-crypt-openssl-random-stage perl-crypt-openssl-random-ipk perl-crypt-openssl-random-clean perl-crypt-openssl-random-dirclean perl-crypt-openssl-random-check

$(DL_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CRYPT-OPENSSL-RANDOM_SITE)/$(PERL-CRYPT-OPENSSL-RANDOM_SOURCE)

perl-crypt-openssl-random-source: $(DL_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_SOURCE) $(PERL-CRYPT-OPENSSL-RANDOM_PATCHES)

$(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_SOURCE) $(PERL-CRYPT-OPENSSL-RANDOM_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_DIR) $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)
	$(PERL-CRYPT-OPENSSL-RANDOM_UNZIP) $(DL_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CRYPT-OPENSSL-RANDOM_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_DIR) $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)
	(cd $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR); \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
		INC="-I$(STAGING_INCLUDE_DIR)" \
		LIBS="$(STAGING_LDFLAGS) -lssl -lcrypto" \
	)
	touch $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.configured

perl-crypt-openssl-random-unpack: $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.configured

$(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.built: $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.configured
	rm -f $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS)" \
        LDDLFLAGS="-shared -rpath=/opt/lib" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" 
	touch $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.built

perl-crypt-openssl-random: $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.built

$(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.staged: $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.built
	rm -f $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.staged

perl-crypt-openssl-random-stage: $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.staged

$(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-crypt-openssl-random" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CRYPT-OPENSSL-RANDOM_PRIORITY)" >>$@
	@echo "Section: $(PERL-CRYPT-OPENSSL-RANDOM_SECTION)" >>$@
	@echo "Version: $(PERL-CRYPT-OPENSSL-RANDOM_VERSION)-$(PERL-CRYPT-OPENSSL-RANDOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CRYPT-OPENSSL-RANDOM_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CRYPT-OPENSSL-RANDOM_SITE)/$(PERL-CRYPT-OPENSSL-RANDOM_SOURCE)" >>$@
	@echo "Description: $(PERL-CRYPT-OPENSSL-RANDOM_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CRYPT-OPENSSL-RANDOM_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CRYPT-OPENSSL-RANDOM_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CRYPT-OPENSSL-RANDOM_CONFLICTS)" >>$@

$(PERL-CRYPT-OPENSSL-RANDOM_IPK): $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR)/.built
	rm -rf $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR) $(BUILD_DIR)/perl-crypt-openssl-random_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR) DESTDIR=$(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR) install
	find $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/CONTROL/control
	echo $(PERL-CRYPT-OPENSSL-RANDOM_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR)

perl-crypt-openssl-random-ipk: $(PERL-CRYPT-OPENSSL-RANDOM_IPK)

perl-crypt-openssl-random-clean:
	-$(MAKE) -C $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR) clean

perl-crypt-openssl-random-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CRYPT-OPENSSL-RANDOM_DIR) $(PERL-CRYPT-OPENSSL-RANDOM_BUILD_DIR) $(PERL-CRYPT-OPENSSL-RANDOM_IPK_DIR) $(PERL-CRYPT-OPENSSL-RANDOM_IPK)
#
#
# Some sanity check for the package.
#
#
perl-crypt-openssl-random-check: $(PERL-CRYPT-OPENSSL-RANDOM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-CRYPT-OPENSSL-RANDOM_IPK)

