###########################################################
#
# perl-carp-clan
#
###########################################################

PERL-CARP-CLAN_SITE=http://search.cpan.org/CPAN/authors/id/S/ST/STBEY
PERL-CARP-CLAN_VERSION=5.3
PERL-CARP-CLAN_SOURCE=Carp-Clan-$(PERL-CARP-CLAN_VERSION).tar.gz
PERL-CARP-CLAN_DIR=Carp-Clan-$(PERL-CARP-CLAN_VERSION)
PERL-CARP-CLAN_UNZIP=zcat

PERL-CARP-CLAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CARP-CLAN_DESCRIPTION=This module reports errors from the perspective of the caller of a "clan" of modules, similar to "Carp.pm" itself.
PERL-CARP-CLAN_SECTION=util
PERL-CARP-CLAN_PRIORITY=optional
PERL-CARP-CLAN_DEPENDS=perl

PERL-CARP-CLAN_IPK_VERSION=1

PERL-CARP-CLAN_CONFFILES=

PERL-CARP-CLAN_PATCHES=

PERL-CARP-CLAN_BUILD_DIR=$(BUILD_DIR)/perl-carp-clan
PERL-CARP-CLAN_SOURCE_DIR=$(SOURCE_DIR)/perl-carp-clan
PERL-CARP-CLAN_IPK_DIR=$(BUILD_DIR)/perl-carp-clan-$(PERL-CARP-CLAN_VERSION)-ipk
PERL-CARP-CLAN_IPK=$(BUILD_DIR)/perl-carp-clan_$(PERL-CARP-CLAN_VERSION)-$(PERL-CARP-CLAN_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-CARP-CLAN_BUILD_DIR=$(BUILD_DIR)/perl-carp-clan
PERL-CARP-CLAN_SOURCE_DIR=$(SOURCE_DIR)/perl-carp-clan
PERL-CARP-CLAN_IPK_DIR=$(BUILD_DIR)/perl-carp-clan-$(PERL-CARP-CLAN_VERSION)-ipk
PERL-CARP-CLAN_IPK=$(BUILD_DIR)/perl-carp-clan_$(PERL-CARP-CLAN_VERSION)-$(PERL-CARP-CLAN_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CARP-CLAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CARP-CLAN_SITE)/$(PERL-CARP-CLAN_SOURCE)

perl-carp-clan-source: $(DL_DIR)/$(PERL-CARP-CLAN_SOURCE) $(PERL-CARP-CLAN_PATCHES)

$(PERL-CARP-CLAN_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CARP-CLAN_SOURCE) $(PERL-CARP-CLAN_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-CARP-CLAN_DIR) $(@D)
	$(PERL-CARP-CLAN_UNZIP) $(DL_DIR)/$(PERL-CARP-CLAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CARP-CLAN_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CARP-CLAN_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CARP-CLAN_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-carp-clan-unpack: $(PERL-CARP-CLAN_BUILD_DIR)/.configured

$(PERL-CARP-CLAN_BUILD_DIR)/.built: $(PERL-CARP-CLAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-carp-clan: $(PERL-CARP-CLAN_BUILD_DIR)/.built

$(PERL-CARP-CLAN_BUILD_DIR)/.staged: $(PERL-CARP-CLAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-carp-clan-stage: $(PERL-CARP-CLAN_BUILD_DIR)/.staged

$(PERL-CARP-CLAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-carp-clan" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CARP-CLAN_PRIORITY)" >>$@
	@echo "Section: $(PERL-CARP-CLAN_SECTION)" >>$@
	@echo "Version: $(PERL-CARP-CLAN_VERSION)-$(PERL-CARP-CLAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CARP-CLAN_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CARP-CLAN_SITE)/$(PERL-CARP-CLAN_SOURCE)" >>$@
	@echo "Description: $(PERL-CARP-CLAN_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CARP-CLAN_DEPENDS)" >>$@

$(PERL-CARP-CLAN_IPK): $(PERL-CARP-CLAN_BUILD_DIR)/.built
	rm -rf $(PERL-CARP-CLAN_IPK_DIR) $(BUILD_DIR)/perl-carp-clan_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CARP-CLAN_BUILD_DIR) DESTDIR=$(PERL-CARP-CLAN_IPK_DIR) install
	find $(PERL-CARP-CLAN_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CARP-CLAN_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CARP-CLAN_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CARP-CLAN_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-CARP-CLAN_SOURCE_DIR)/postinst $(PERL-CARP-CLAN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-CARP-CLAN_SOURCE_DIR)/prerm $(PERL-CARP-CLAN_IPK_DIR)/CONTROL/prerm
	echo $(PERL-CARP-CLAN_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CARP-CLAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CARP-CLAN_IPK_DIR)

perl-carp-clan-ipk: $(PERL-CARP-CLAN_IPK)

perl-carp-clan-clean:
	-$(MAKE) -C $(PERL-CARP-CLAN_BUILD_DIR) clean

perl-carp-clan-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CARP-CLAN_DIR) $(PERL-CARP-CLAN_BUILD_DIR) $(PERL-CARP-CLAN_IPK_DIR) $(PERL-CARP-CLAN_IPK)

perl-carp-clan-check: $(PERL-CARP-CLAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-CARP-CLAN_IPK)
