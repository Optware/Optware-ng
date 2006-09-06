###########################################################
#
# perl-wakeonlan
#
###########################################################

PERL-WAKEONLAN_SITE=http://gsd.di.uminho.pt/jpo/software/wakeonlan/downloads
PERL-WAKEONLAN_VERSION=0.41
PERL-WAKEONLAN_SOURCE=wakeonlan-$(PERL-WAKEONLAN_VERSION).tar.gz
PERL-WAKEONLAN_DIR=wakeonlan-$(PERL-WAKEONLAN_VERSION)
PERL-WAKEONLAN_UNZIP=zcat
PERL-WAKEONLAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-WAKEONLAN_DESCRIPTION=A Perl script that sends 'magic packets' to wake-on-LAN enabled ethernet adapters and motherboards, in order to switch on remote computers.
PERL-WAKEONLAN_SECTION=util
PERL-WAKEONLAN_PRIORITY=optional
PERL-WAKEONLAN_DEPENDS=perl
PERL-WAKEONLAN_SUGGESTS=
PERL-WAKEONLAN_CONFLICTS=

PERL-WAKEONLAN_IPK_VERSION=1

PERL-WAKEONLAN_CONFFILES=

PERL-WAKEONLAN_BUILD_DIR=$(BUILD_DIR)/perl-wakeonlan
PERL-WAKEONLAN_SOURCE_DIR=$(SOURCE_DIR)/perl-wakeonlan
PERL-WAKEONLAN_IPK_DIR=$(BUILD_DIR)/perl-wakeonlan-$(PERL-WAKEONLAN_VERSION)-ipk
PERL-WAKEONLAN_IPK=$(BUILD_DIR)/perl-wakeonlan_$(PERL-WAKEONLAN_VERSION)-$(PERL-WAKEONLAN_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-WAKEONLAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-WAKEONLAN_SITE)/$(PERL-WAKEONLAN_SOURCE)

perl-wakeonlan-source: $(DL_DIR)/$(PERL-WAKEONLAN_SOURCE) $(PERL-WAKEONLAN_PATCHES)

$(PERL-WAKEONLAN_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-WAKEONLAN_SOURCE) $(PERL-WAKEONLAN_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-WAKEONLAN_DIR) $(PERL-WAKEONLAN_BUILD_DIR)
	$(PERL-WAKEONLAN_UNZIP) $(DL_DIR)/$(PERL-WAKEONLAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-WAKEONLAN_DIR) $(PERL-WAKEONLAN_BUILD_DIR)
	(cd $(PERL-WAKEONLAN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-WAKEONLAN_BUILD_DIR)/.configured

perl-wakeonlan-unpack: $(PERL-WAKEONLAN_BUILD_DIR)/.configured

$(PERL-WAKEONLAN_BUILD_DIR)/.built: $(PERL-WAKEONLAN_BUILD_DIR)/.configured
	rm -f $(PERL-WAKEONLAN_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-WAKEONLAN_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-WAKEONLAN_BUILD_DIR)/.built

perl-wakeonlan: $(PERL-WAKEONLAN_BUILD_DIR)/.built

$(PERL-WAKEONLAN_BUILD_DIR)/.staged: $(PERL-WAKEONLAN_BUILD_DIR)/.built
	rm -f $(PERL-WAKEONLAN_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-WAKEONLAN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-WAKEONLAN_BUILD_DIR)/.staged

perl-wakeonlan-stage: $(PERL-WAKEONLAN_BUILD_DIR)/.staged

$(PERL-WAKEONLAN_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-WAKEONLAN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-wakeonlan" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-WAKEONLAN_PRIORITY)" >>$@
	@echo "Section: $(PERL-WAKEONLAN_SECTION)" >>$@
	@echo "Version: $(PERL-WAKEONLAN_VERSION)-$(PERL-WAKEONLAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-WAKEONLAN_MAINTAINER)" >>$@
	@echo "Source: $(PERL-WAKEONLAN_SITE)/$(PERL-WAKEONLAN_SOURCE)" >>$@
	@echo "Description: $(PERL-WAKEONLAN_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-WAKEONLAN_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-WAKEONLAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-WAKEONLAN_CONFLICTS)" >>$@

$(PERL-WAKEONLAN_IPK): $(PERL-WAKEONLAN_BUILD_DIR)/.built
	rm -rf $(PERL-WAKEONLAN_IPK_DIR) $(BUILD_DIR)/perl-wakeonlan_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-WAKEONLAN_BUILD_DIR) DESTDIR=$(PERL-WAKEONLAN_IPK_DIR) install
	find $(PERL-WAKEONLAN_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-WAKEONLAN_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-WAKEONLAN_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-WAKEONLAN_IPK_DIR)/CONTROL/control
	echo $(PERL-WAKEONLAN_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-WAKEONLAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-WAKEONLAN_IPK_DIR)

perl-wakeonlan-ipk: $(PERL-WAKEONLAN_IPK)

perl-wakeonlan-clean:
	-$(MAKE) -C $(PERL-WAKEONLAN_BUILD_DIR) clean

perl-wakeonlan-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-WAKEONLAN_DIR) $(PERL-WAKEONLAN_BUILD_DIR) $(PERL-WAKEONLAN_IPK_DIR) $(PERL-WAKEONLAN_IPK)
