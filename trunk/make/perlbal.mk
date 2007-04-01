###########################################################
#
# perlbal
#
###########################################################

PERLBAL_SITE=http://search.cpan.org/CPAN/authors/id/B/BR/BRADFITZ
PERLBAL_VERSION=1.55
PERLBAL_SOURCE=Perlbal-$(PERLBAL_VERSION).tar.gz
PERLBAL_DIR=Perlbal-$(PERLBAL_VERSION)
PERLBAL_UNZIP=zcat
PERLBAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERLBAL_DESCRIPTION=Reverse-proxy load balancer and webserver.
PERLBAL_SECTION=net
PERLBAL_PRIORITY=optional
PERLBAL_DEPENDS=perl-bsd-resource, perl-danga-socket, perl-libwww, perl-sys-syscall
PERLBAL_SUGGESTS=
PERLBAL_CONFLICTS=

PERLBAL_IPK_VERSION=1

PERLBAL_CONFFILES=

PERLBAL_BUILD_DIR=$(BUILD_DIR)/perlbal
PERLBAL_SOURCE_DIR=$(SOURCE_DIR)/perlbal
PERLBAL_IPK_DIR=$(BUILD_DIR)/perlbal-$(PERLBAL_VERSION)-ipk
PERLBAL_IPK=$(BUILD_DIR)/perlbal_$(PERLBAL_VERSION)-$(PERLBAL_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERLBAL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERLBAL_SITE)/$(PERLBAL_SOURCE)

perlbal-source: $(DL_DIR)/$(PERLBAL_SOURCE) $(PERLBAL_PATCHES)

$(PERLBAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERLBAL_SOURCE) $(PERLBAL_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERLBAL_DIR) $(PERLBAL_BUILD_DIR)
	$(PERLBAL_UNZIP) $(DL_DIR)/$(PERLBAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERLBAL_DIR) $(PERLBAL_BUILD_DIR)
	(cd $(PERLBAL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERLBAL_BUILD_DIR)/.configured

perlbal-unpack: $(PERLBAL_BUILD_DIR)/.configured

$(PERLBAL_BUILD_DIR)/.built: $(PERLBAL_BUILD_DIR)/.configured
	$(MAKE) perl-bsd-resource-stage
	$(MAKE) perl-danga-socket-stage
	$(MAKE) perl-libwww-stage
	$(MAKE) perl-sys-syscall-stage
	rm -f $(PERLBAL_BUILD_DIR)/.built
	$(MAKE) -C $(PERLBAL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERLBAL_BUILD_DIR)/.built

perlbal: $(PERLBAL_BUILD_DIR)/.built

$(PERLBAL_BUILD_DIR)/.staged: $(PERLBAL_BUILD_DIR)/.built
	rm -f $(PERLBAL_BUILD_DIR)/.staged
	$(MAKE) -C $(PERLBAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERLBAL_BUILD_DIR)/.staged

perlbal-stage: $(PERLBAL_BUILD_DIR)/.staged

$(PERLBAL_IPK_DIR)/CONTROL/control:
	@install -d $(PERLBAL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perlbal" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERLBAL_PRIORITY)" >>$@
	@echo "Section: $(PERLBAL_SECTION)" >>$@
	@echo "Version: $(PERLBAL_VERSION)-$(PERLBAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERLBAL_MAINTAINER)" >>$@
	@echo "Source: $(PERLBAL_SITE)/$(PERLBAL_SOURCE)" >>$@
	@echo "Description: $(PERLBAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERLBAL_DEPENDS)" >>$@
	@echo "Suggests: $(PERLBAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERLBAL_CONFLICTS)" >>$@

$(PERLBAL_IPK): $(PERLBAL_BUILD_DIR)/.built
	rm -rf $(PERLBAL_IPK_DIR) $(BUILD_DIR)/perlbal_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERLBAL_BUILD_DIR) DESTDIR=$(PERLBAL_IPK_DIR) install
	find $(PERLBAL_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERLBAL_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERLBAL_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERLBAL_IPK_DIR)/CONTROL/control
	echo $(PERLBAL_CONFFILES) | sed -e 's/ /\n/g' > $(PERLBAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERLBAL_IPK_DIR)

perlbal-ipk: $(PERLBAL_IPK)

perlbal-clean:
	-$(MAKE) -C $(PERLBAL_BUILD_DIR) clean

perlbal-dirclean:
	rm -rf $(BUILD_DIR)/$(PERLBAL_DIR) $(PERLBAL_BUILD_DIR) $(PERLBAL_IPK_DIR) $(PERLBAL_IPK)

perlbal-check: $(PERLBAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERLBAL_IPK)
