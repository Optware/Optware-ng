###########################################################
#
# perl-io-socket-ssl
#
###########################################################

PERL-IO-SOCKET-SSL_SITE=http://search.cpan.org/CPAN/authors/id/S/SU/SULLR
PERL-IO-SOCKET-SSL_VERSION=0.999
PERL-IO-SOCKET-SSL_SOURCE=IO-Socket-SSL-$(PERL-IO-SOCKET-SSL_VERSION).tar.gz
PERL-IO-SOCKET-SSL_DIR=IO-Socket-SSL-$(PERL-IO-SOCKET-SSL_VERSION)
PERL-IO-SOCKET-SSL_UNZIP=zcat
PERL-IO-SOCKET-SSL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IO-SOCKET-SSL_DESCRIPTION=IO-Socket-SSL - Nearly transparent SSL encapsulation for IO::Socket::INET
PERL-IO-SOCKET-SSL_SECTION=util
PERL-IO-SOCKET-SSL_PRIORITY=optional
PERL-IO-SOCKET-SSL_DEPENDS=perl, perl-net-ssleay
PERL-IO-SOCKET-SSL_SUGGESTS=
PERL-IO-SOCKET-SSL_CONFLICTS=

PERL-IO-SOCKET-SSL_IPK_VERSION=1

PERL-IO-SOCKET-SSL_CONFFILES=

PERL-IO-SOCKET-SSL_BUILD_DIR=$(BUILD_DIR)/perl-io-socket-ssl
PERL-IO-SOCKET-SSL_SOURCE_DIR=$(SOURCE_DIR)/perl-io-socket-ssl
PERL-IO-SOCKET-SSL_IPK_DIR=$(BUILD_DIR)/perl-io-socket-ssl-$(PERL-IO-SOCKET-SSL_VERSION)-ipk
PERL-IO-SOCKET-SSL_IPK=$(BUILD_DIR)/perl-io-socket-ssl_$(PERL-IO-SOCKET-SSL_VERSION)-$(PERL-IO-SOCKET-SSL_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IO-SOCKET-SSL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IO-SOCKET-SSL_SITE)/$(PERL-IO-SOCKET-SSL_SOURCE)

perl-io-socket-ssl-source: $(DL_DIR)/$(PERL-IO-SOCKET-SSL_SOURCE) $(PERL-IO-SOCKET-SSL_PATCHES)

$(PERL-IO-SOCKET-SSL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IO-SOCKET-SSL_SOURCE) $(PERL-IO-SOCKET-SSL_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-IO-SOCKET-SSL_DIR) $(PERL-IO-SOCKET-SSL_BUILD_DIR)
	$(PERL-IO-SOCKET-SSL_UNZIP) $(DL_DIR)/$(PERL-IO-SOCKET-SSL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IO-SOCKET-SSL_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IO-SOCKET-SSL_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IO-SOCKET-SSL_DIR) $(PERL-IO-SOCKET-SSL_BUILD_DIR)
	(cd $(PERL-IO-SOCKET-SSL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.configured

perl-io-socket-ssl-unpack: $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.configured

$(PERL-IO-SOCKET-SSL_BUILD_DIR)/.built: $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.configured
	rm -f $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-IO-SOCKET-SSL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.built

perl-io-socket-ssl: $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.built

$(PERL-IO-SOCKET-SSL_BUILD_DIR)/.staged: $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.built
	rm -f $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-IO-SOCKET-SSL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.staged

perl-io-socket-ssl-stage: $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.staged

$(PERL-IO-SOCKET-SSL_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-IO-SOCKET-SSL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-io-socket-ssl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IO-SOCKET-SSL_PRIORITY)" >>$@
	@echo "Section: $(PERL-IO-SOCKET-SSL_SECTION)" >>$@
	@echo "Version: $(PERL-IO-SOCKET-SSL_VERSION)-$(PERL-IO-SOCKET-SSL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IO-SOCKET-SSL_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IO-SOCKET-SSL_SITE)/$(PERL-IO-SOCKET-SSL_SOURCE)" >>$@
	@echo "Description: $(PERL-IO-SOCKET-SSL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IO-SOCKET-SSL_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IO-SOCKET-SSL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IO-SOCKET-SSL_CONFLICTS)" >>$@

$(PERL-IO-SOCKET-SSL_IPK): $(PERL-IO-SOCKET-SSL_BUILD_DIR)/.built
	rm -rf $(PERL-IO-SOCKET-SSL_IPK_DIR) $(BUILD_DIR)/perl-io-socket-ssl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IO-SOCKET-SSL_BUILD_DIR) DESTDIR=$(PERL-IO-SOCKET-SSL_IPK_DIR) install
	find $(PERL-IO-SOCKET-SSL_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IO-SOCKET-SSL_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IO-SOCKET-SSL_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IO-SOCKET-SSL_IPK_DIR)/CONTROL/control
	echo $(PERL-IO-SOCKET-SSL_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IO-SOCKET-SSL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IO-SOCKET-SSL_IPK_DIR)

perl-io-socket-ssl-ipk: $(PERL-IO-SOCKET-SSL_IPK)

perl-io-socket-ssl-clean:
	-$(MAKE) -C $(PERL-IO-SOCKET-SSL_BUILD_DIR) clean

perl-io-socket-ssl-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IO-SOCKET-SSL_DIR) $(PERL-IO-SOCKET-SSL_BUILD_DIR) $(PERL-IO-SOCKET-SSL_IPK_DIR) $(PERL-IO-SOCKET-SSL_IPK)
