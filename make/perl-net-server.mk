###########################################################
#
# perl-net-server
#
###########################################################

PERL-NET-SERVER_SITE=http://search.cpan.org/CPAN/authors/id/R/RH/RHANDOM
PERL-NET-SERVER_VERSION=0.97
PERL-NET-SERVER_SOURCE=Net-Server-$(PERL-NET-SERVER_VERSION).tar.gz
PERL-NET-SERVER_DIR=Net-Server-$(PERL-NET-SERVER_VERSION)
PERL-NET-SERVER_UNZIP=zcat
PERL-NET-SERVER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-NET-SERVER_DESCRIPTION=Net-Server - Extensible, general Perl server engine
PERL-NET-SERVER_SECTION=util
PERL-NET-SERVER_PRIORITY=optional
PERL-NET-SERVER_DEPENDS=perl
PERL-NET-SERVER_SUGGESTS=
PERL-NET-SERVER_CONFLICTS=

PERL-NET-SERVER_IPK_VERSION=1

PERL-NET-SERVER_CONFFILES=

PERL-NET-SERVER_BUILD_DIR=$(BUILD_DIR)/perl-net-server
PERL-NET-SERVER_SOURCE_DIR=$(SOURCE_DIR)/perl-net-server
PERL-NET-SERVER_IPK_DIR=$(BUILD_DIR)/perl-net-server-$(PERL-NET-SERVER_VERSION)-ipk
PERL-NET-SERVER_IPK=$(BUILD_DIR)/perl-net-server_$(PERL-NET-SERVER_VERSION)-$(PERL-NET-SERVER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-NET-SERVER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-NET-SERVER_SITE)/$(PERL-NET-SERVER_SOURCE)

perl-net-server-source: $(DL_DIR)/$(PERL-NET-SERVER_SOURCE) $(PERL-NET-SERVER_PATCHES)

$(PERL-NET-SERVER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-NET-SERVER_SOURCE) $(PERL-NET-SERVER_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-NET-SERVER_DIR) $(@D)
	$(PERL-NET-SERVER_UNZIP) $(DL_DIR)/$(PERL-NET-SERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-NET-SERVER_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-NET-SERVER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-NET-SERVER_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $@

perl-net-server-unpack: $(PERL-NET-SERVER_BUILD_DIR)/.configured

$(PERL-NET-SERVER_BUILD_DIR)/.built: $(PERL-NET-SERVER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-net-server: $(PERL-NET-SERVER_BUILD_DIR)/.built

$(PERL-NET-SERVER_BUILD_DIR)/.staged: $(PERL-NET-SERVER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-net-server-stage: $(PERL-NET-SERVER_BUILD_DIR)/.staged

$(PERL-NET-SERVER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-net-server" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-NET-SERVER_PRIORITY)" >>$@
	@echo "Section: $(PERL-NET-SERVER_SECTION)" >>$@
	@echo "Version: $(PERL-NET-SERVER_VERSION)-$(PERL-NET-SERVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-NET-SERVER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-NET-SERVER_SITE)/$(PERL-NET-SERVER_SOURCE)" >>$@
	@echo "Description: $(PERL-NET-SERVER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-NET-SERVER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-NET-SERVER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-NET-SERVER_CONFLICTS)" >>$@

$(PERL-NET-SERVER_IPK): $(PERL-NET-SERVER_BUILD_DIR)/.built
	rm -rf $(PERL-NET-SERVER_IPK_DIR) $(BUILD_DIR)/perl-net-server_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-NET-SERVER_BUILD_DIR) DESTDIR=$(PERL-NET-SERVER_IPK_DIR) install
	find $(PERL-NET-SERVER_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-NET-SERVER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-NET-SERVER_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-NET-SERVER_IPK_DIR)/CONTROL/control
	echo $(PERL-NET-SERVER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-NET-SERVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-NET-SERVER_IPK_DIR)

perl-net-server-ipk: $(PERL-NET-SERVER_IPK)

perl-net-server-clean:
	-$(MAKE) -C $(PERL-NET-SERVER_BUILD_DIR) clean

perl-net-server-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-NET-SERVER_DIR) $(PERL-NET-SERVER_BUILD_DIR) $(PERL-NET-SERVER_IPK_DIR) $(PERL-NET-SERVER_IPK)
