###########################################################
#
# perl-danga-socket
#
###########################################################

PERL-DANGA-SOCKET_SITE=http://search.cpan.org/CPAN/authors/id/B/BR/BRADFITZ
# perlbal neeeds specifically 1.44
PERL-DANGA-SOCKET_VERSION=1.44
PERL-DANGA-SOCKET_SOURCE=Danga-Socket-$(PERL-DANGA-SOCKET_VERSION).tar.gz
PERL-DANGA-SOCKET_DIR=Danga-Socket-$(PERL-DANGA-SOCKET_VERSION)
PERL-DANGA-SOCKET_UNZIP=zcat
PERL-DANGA-SOCKET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DANGA-SOCKET_DESCRIPTION=Event loop and event-driven async socket base class.
PERL-DANGA-SOCKET_SECTION=net
PERL-DANGA-SOCKET_PRIORITY=optional
PERL-DANGA-SOCKET_DEPENDS=perl
PERL-DANGA-SOCKET_SUGGESTS=
PERL-DANGA-SOCKET_CONFLICTS=

PERL-DANGA-SOCKET_IPK_VERSION=1

PERL-DANGA-SOCKET_CONFFILES=

PERL-DANGA-SOCKET_BUILD_DIR=$(BUILD_DIR)/perl-danga-socket
PERL-DANGA-SOCKET_SOURCE_DIR=$(SOURCE_DIR)/perl-danga-socket
PERL-DANGA-SOCKET_IPK_DIR=$(BUILD_DIR)/perl-danga-socket-$(PERL-DANGA-SOCKET_VERSION)-ipk
PERL-DANGA-SOCKET_IPK=$(BUILD_DIR)/perl-danga-socket_$(PERL-DANGA-SOCKET_VERSION)-$(PERL-DANGA-SOCKET_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DANGA-SOCKET_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DANGA-SOCKET_SITE)/$(PERL-DANGA-SOCKET_SOURCE)

perl-danga-socket-source: $(DL_DIR)/$(PERL-DANGA-SOCKET_SOURCE) $(PERL-DANGA-SOCKET_PATCHES)

$(PERL-DANGA-SOCKET_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DANGA-SOCKET_SOURCE) $(PERL-DANGA-SOCKET_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DANGA-SOCKET_DIR) $(PERL-DANGA-SOCKET_BUILD_DIR)
	$(PERL-DANGA-SOCKET_UNZIP) $(DL_DIR)/$(PERL-DANGA-SOCKET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-DANGA-SOCKET_DIR) $(PERL-DANGA-SOCKET_BUILD_DIR)
	(cd $(PERL-DANGA-SOCKET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DANGA-SOCKET_BUILD_DIR)/.configured

perl-danga-socket-unpack: $(PERL-DANGA-SOCKET_BUILD_DIR)/.configured

$(PERL-DANGA-SOCKET_BUILD_DIR)/.built: $(PERL-DANGA-SOCKET_BUILD_DIR)/.configured
	rm -f $(PERL-DANGA-SOCKET_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DANGA-SOCKET_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-DANGA-SOCKET_BUILD_DIR)/.built

perl-danga-socket: $(PERL-DANGA-SOCKET_BUILD_DIR)/.built

$(PERL-DANGA-SOCKET_BUILD_DIR)/.staged: $(PERL-DANGA-SOCKET_BUILD_DIR)/.built
	rm -f $(PERL-DANGA-SOCKET_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DANGA-SOCKET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DANGA-SOCKET_BUILD_DIR)/.staged

perl-danga-socket-stage: $(PERL-DANGA-SOCKET_BUILD_DIR)/.staged

$(PERL-DANGA-SOCKET_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-DANGA-SOCKET_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-danga-socket" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DANGA-SOCKET_PRIORITY)" >>$@
	@echo "Section: $(PERL-DANGA-SOCKET_SECTION)" >>$@
	@echo "Version: $(PERL-DANGA-SOCKET_VERSION)-$(PERL-DANGA-SOCKET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DANGA-SOCKET_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DANGA-SOCKET_SITE)/$(PERL-DANGA-SOCKET_SOURCE)" >>$@
	@echo "Description: $(PERL-DANGA-SOCKET_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DANGA-SOCKET_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DANGA-SOCKET_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DANGA-SOCKET_CONFLICTS)" >>$@

$(PERL-DANGA-SOCKET_IPK): $(PERL-DANGA-SOCKET_BUILD_DIR)/.built
	rm -rf $(PERL-DANGA-SOCKET_IPK_DIR) $(BUILD_DIR)/perl-danga-socket_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DANGA-SOCKET_BUILD_DIR) DESTDIR=$(PERL-DANGA-SOCKET_IPK_DIR) install
	find $(PERL-DANGA-SOCKET_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DANGA-SOCKET_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DANGA-SOCKET_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DANGA-SOCKET_IPK_DIR)/CONTROL/control
	echo $(PERL-DANGA-SOCKET_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DANGA-SOCKET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DANGA-SOCKET_IPK_DIR)

perl-danga-socket-ipk: $(PERL-DANGA-SOCKET_IPK)

perl-danga-socket-clean:
	-$(MAKE) -C $(PERL-DANGA-SOCKET_BUILD_DIR) clean

perl-danga-socket-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DANGA-SOCKET_DIR) $(PERL-DANGA-SOCKET_BUILD_DIR) $(PERL-DANGA-SOCKET_IPK_DIR) $(PERL-DANGA-SOCKET_IPK)

perl-danga-socket-check: $(PERL-DANGA-SOCKET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DANGA-SOCKET_IPK)
