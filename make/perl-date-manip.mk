###########################################################
#
# perl-date-manip
#
###########################################################

PERL-DATE-MANIP_SITE=http://search.cpan.org/CPAN/authors/id/S/SB/SBECK
PERL-DATE-MANIP_VERSION=5.48
PERL-DATE-MANIP_SOURCE=Date-Manip-$(PERL-DATE-MANIP_VERSION).tar.gz
PERL-DATE-MANIP_DIR=Date-Manip-$(PERL-DATE-MANIP_VERSION)
PERL-DATE-MANIP_UNZIP=zcat

PERL-DATE-MANIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DATE-MANIP_DESCRIPTION=date manipulation routines
PERL-DATE-MANIP_SECTION=util
PERL-DATE-MANIP_PRIORITY=optional
PERL-DATE-MANIP_DEPENDS=perl

PERL-DATE-MANIP_IPK_VERSION=1

PERL-DATE-MANIP_CONFFILES=

PERL-DATE-MANIP_PATCHES=

PERL-DATE-MANIP_BUILD_DIR=$(BUILD_DIR)/perl-date-manip
PERL-DATE-MANIP_SOURCE_DIR=$(SOURCE_DIR)/perl-date-manip
PERL-DATE-MANIP_IPK_DIR=$(BUILD_DIR)/perl-date-manip-$(PERL-DATE-MANIP_VERSION)-ipk
PERL-DATE-MANIP_IPK=$(BUILD_DIR)/perl-date-manip_$(PERL-DATE-MANIP_VERSION)-$(PERL-DATE-MANIP_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-DATE-MANIP_BUILD_DIR=$(BUILD_DIR)/perl-date-manip
PERL-DATE-MANIP_SOURCE_DIR=$(SOURCE_DIR)/perl-date-manip
PERL-DATE-MANIP_IPK_DIR=$(BUILD_DIR)/perl-date-manip-$(PERL-DATE-MANIP_VERSION)-ipk
PERL-DATE-MANIP_IPK=$(BUILD_DIR)/perl-date-manip_$(PERL-DATE-MANIP_VERSION)-$(PERL-DATE-MANIP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DATE-MANIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DATE-MANIP_SITE)/$(PERL-DATE-MANIP_SOURCE)

perl-date-manip-source: $(DL_DIR)/$(PERL-DATE-MANIP_SOURCE) $(PERL-DATE-MANIP_PATCHES)

$(PERL-DATE-MANIP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DATE-MANIP_SOURCE) $(PERL-DATE-MANIP_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) $(PERL-DATE-MANIP_BUILD_DIR)
	$(PERL-DATE-MANIP_UNZIP) $(DL_DIR)/$(PERL-DATE-MANIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DATE-MANIP_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) $(PERL-DATE-MANIP_BUILD_DIR)
	(cd $(PERL-DATE-MANIP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DATE-MANIP_BUILD_DIR)/.configured

perl-date-manip-unpack: $(PERL-DATE-MANIP_BUILD_DIR)/.configured

$(PERL-DATE-MANIP_BUILD_DIR)/.built: $(PERL-DATE-MANIP_BUILD_DIR)/.configured
	rm -f $(PERL-DATE-MANIP_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-DATE-MANIP_BUILD_DIR)/.built

perl-date-manip: $(PERL-DATE-MANIP_BUILD_DIR)/.built

$(PERL-DATE-MANIP_BUILD_DIR)/.staged: $(PERL-DATE-MANIP_BUILD_DIR)/.built
	rm -f $(PERL-DATE-MANIP_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DATE-MANIP_BUILD_DIR)/.staged

perl-date-manip-stage: $(PERL-DATE-MANIP_BUILD_DIR)/.staged

$(PERL-DATE-MANIP_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-DATE-MANIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-date-manip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DATE-MANIP_PRIORITY)" >>$@
	@echo "Section: $(PERL-DATE-MANIP_SECTION)" >>$@
	@echo "Version: $(PERL-DATE-MANIP_VERSION)-$(PERL-DATE-MANIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DATE-MANIP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DATE-MANIP_SITE)/$(PERL-DATE-MANIP_SOURCE)" >>$@
	@echo "Description: $(PERL-DATE-MANIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DATE-MANIP_DEPENDS)" >>$@

$(PERL-DATE-MANIP_IPK): $(PERL-DATE-MANIP_BUILD_DIR)/.built
	rm -rf $(PERL-DATE-MANIP_IPK_DIR) $(BUILD_DIR)/perl-date-manip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) DESTDIR=$(PERL-DATE-MANIP_IPK_DIR) install
	find $(PERL-DATE-MANIP_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DATE-MANIP_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DATE-MANIP_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-DATE-MANIP_SOURCE_DIR)/postinst $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-DATE-MANIP_SOURCE_DIR)/prerm $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DATE-MANIP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DATE-MANIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DATE-MANIP_IPK_DIR)

perl-date-manip-ipk: $(PERL-DATE-MANIP_IPK)

perl-date-manip-clean:
	-$(MAKE) -C $(PERL-DATE-MANIP_BUILD_DIR) clean

perl-date-manip-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DATE-MANIP_DIR) $(PERL-DATE-MANIP_BUILD_DIR) $(PERL-DATE-MANIP_IPK_DIR) $(PERL-DATE-MANIP_IPK)
