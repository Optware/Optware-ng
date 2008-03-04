###########################################################
#
# perl-libnet
#
###########################################################

PERL-LIBNET_SITE=http://search.cpan.org/CPAN/authors/id/G/GB/GBARR
PERL-LIBNET_VERSION=1.22
PERL-LIBNET_SOURCE=libnet-$(PERL-LIBNET_VERSION).tar.gz
PERL-LIBNET_DIR=libnet-$(PERL-LIBNET_VERSION)
PERL-LIBNET_UNZIP=zcat
PERL-LIBNET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBNET_DESCRIPTION=A collection of Perl modules providing simple and consistent programming API to the client side of various internet protocols.
PERL-LIBNET_SECTION=util
PERL-LIBNET_PRIORITY=optional
PERL-LIBNET_DEPENDS=perl
PERL-LIBNET_SUGGESTS=
PERL-LIBNET_CONFLICTS=

PERL-LIBNET_IPK_VERSION=1

PERL-LIBNET_CONFFILES=/opt/lib/perl5/$(PERL_VERSION)/Net/libnet.cfg

PERL-LIBNET_BUILD_DIR=$(BUILD_DIR)/perl-libnet
PERL-LIBNET_SOURCE_DIR=$(SOURCE_DIR)/perl-libnet
PERL-LIBNET_IPK_DIR=$(BUILD_DIR)/perl-libnet-$(PERL-LIBNET_VERSION)-ipk
PERL-LIBNET_IPK=$(BUILD_DIR)/perl-libnet_$(PERL-LIBNET_VERSION)-$(PERL-LIBNET_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-LIBNET_PATCHES=

$(DL_DIR)/$(PERL-LIBNET_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-LIBNET_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

perl-libnet-source: $(DL_DIR)/$(PERL-LIBNET_SOURCE) $(PERL-LIBNET_PATCHES)

$(PERL-LIBNET_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBNET_SOURCE) $(PERL-LIBNET_PATCHES)
	$(MAKE) perl-hostperl
	rm -rf $(BUILD_DIR)/$(PERL-LIBNET_DIR) $(@D)
	$(PERL-LIBNET_UNZIP) $(DL_DIR)/$(PERL-LIBNET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL-LIBNET_PATCHES)"; then \
		cat $(PERL-LIBNET_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-LIBNET_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PERL-LIBNET_DIR) $(@D)
	touch $(@D)/libnet.cfg
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-libnet-unpack: $(PERL-LIBNET_BUILD_DIR)/.configured

$(PERL-LIBNET_BUILD_DIR)/.built: $(PERL-LIBNET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-libnet: $(PERL-LIBNET_BUILD_DIR)/.built

$(PERL-LIBNET_BUILD_DIR)/.staged: $(PERL-LIBNET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-libnet-stage: $(PERL-LIBNET_BUILD_DIR)/.staged

$(PERL-LIBNET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-libnet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBNET_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBNET_SECTION)" >>$@
	@echo "Version: $(PERL-LIBNET_VERSION)-$(PERL-LIBNET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBNET_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBNET_SITE)/$(PERL-LIBNET_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBNET_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBNET_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBNET_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBNET_CONFLICTS)" >>$@

$(PERL-LIBNET_IPK): $(PERL-LIBNET_BUILD_DIR)/.built
	rm -rf $(PERL-LIBNET_IPK_DIR) $(BUILD_DIR)/perl-libnet_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBNET_BUILD_DIR) DESTDIR=$(PERL-LIBNET_IPK_DIR) install
	find $(PERL-LIBNET_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LIBNET_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-LIBNET_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-LIBNET_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBNET_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBNET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBNET_IPK_DIR)

perl-libnet-ipk: $(PERL-LIBNET_IPK)

perl-libnet-clean:
	-$(MAKE) -C $(PERL-LIBNET_BUILD_DIR) clean

perl-libnet-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBNET_DIR) $(PERL-LIBNET_BUILD_DIR) $(PERL-LIBNET_IPK_DIR) $(PERL-LIBNET_IPK)
