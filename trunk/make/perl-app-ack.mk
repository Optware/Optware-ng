###########################################################
#
# perl-app-ack
#
###########################################################

PERL-APP-ACK_SITE=http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE
PERL-APP-ACK_VERSION=1.64
PERL-APP-ACK_SOURCE=ack-$(PERL-APP-ACK_VERSION).tar.gz
PERL-APP-ACK_DIR=ack-$(PERL-APP-ACK_VERSION)
PERL-APP-ACK_UNZIP=zcat
PERL-APP-ACK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-APP-ACK_DESCRIPTION=ack is a grep-like tool tailored to working with large trees of source code.
PERL-APP-ACK_SECTION=util
PERL-APP-ACK_PRIORITY=optional
PERL-APP-ACK_DEPENDS=perl-file-next
PERL-APP-ACK_SUGGESTS=
PERL-APP-ACK_CONFLICTS=

PERL-APP-ACK_IPK_VERSION=1

PERL-APP-ACK_CONFFILES=

PERL-APP-ACK_BUILD_DIR=$(BUILD_DIR)/perl-app-ack
PERL-APP-ACK_SOURCE_DIR=$(SOURCE_DIR)/perl-app-ack
PERL-APP-ACK_IPK_DIR=$(BUILD_DIR)/perl-app-ack-$(PERL-APP-ACK_VERSION)-ipk
PERL-APP-ACK_IPK=$(BUILD_DIR)/perl-app-ack_$(PERL-APP-ACK_VERSION)-$(PERL-APP-ACK_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-APP-ACK_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-APP-ACK_SITE)/$(PERL-APP-ACK_SOURCE)

perl-app-ack-source: $(DL_DIR)/$(PERL-APP-ACK_SOURCE) $(PERL-APP-ACK_PATCHES)

$(PERL-APP-ACK_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-APP-ACK_SOURCE) $(PERL-APP-ACK_PATCHES)
	$(MAKE) perl-file-next-stage
	rm -rf $(BUILD_DIR)/$(PERL-APP-ACK_DIR) $(PERL-APP-ACK_BUILD_DIR)
	$(PERL-APP-ACK_UNZIP) $(DL_DIR)/$(PERL-APP-ACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-APP-ACK_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-APP-ACK_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-APP-ACK_DIR) $(PERL-APP-ACK_BUILD_DIR)
	(cd $(PERL-APP-ACK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-APP-ACK_BUILD_DIR)/.configured

perl-app-ack-unpack: $(PERL-APP-ACK_BUILD_DIR)/.configured

$(PERL-APP-ACK_BUILD_DIR)/.built: $(PERL-APP-ACK_BUILD_DIR)/.configured
	rm -f $(PERL-APP-ACK_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-APP-ACK_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-APP-ACK_BUILD_DIR)/.built

perl-app-ack: $(PERL-APP-ACK_BUILD_DIR)/.built

$(PERL-APP-ACK_BUILD_DIR)/.staged: $(PERL-APP-ACK_BUILD_DIR)/.built
	rm -f $(PERL-APP-ACK_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-APP-ACK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-APP-ACK_BUILD_DIR)/.staged

perl-app-ack-stage: $(PERL-APP-ACK_BUILD_DIR)/.staged

$(PERL-APP-ACK_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-APP-ACK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-app-ack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-APP-ACK_PRIORITY)" >>$@
	@echo "Section: $(PERL-APP-ACK_SECTION)" >>$@
	@echo "Version: $(PERL-APP-ACK_VERSION)-$(PERL-APP-ACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-APP-ACK_MAINTAINER)" >>$@
	@echo "Source: $(PERL-APP-ACK_SITE)/$(PERL-APP-ACK_SOURCE)" >>$@
	@echo "Description: $(PERL-APP-ACK_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-APP-ACK_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-APP-ACK_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-APP-ACK_CONFLICTS)" >>$@

$(PERL-APP-ACK_IPK): $(PERL-APP-ACK_BUILD_DIR)/.built
	rm -rf $(PERL-APP-ACK_IPK_DIR) $(BUILD_DIR)/perl-app-ack_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-APP-ACK_BUILD_DIR) DESTDIR=$(PERL-APP-ACK_IPK_DIR) install
	find $(PERL-APP-ACK_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-APP-ACK_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-APP-ACK_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-APP-ACK_IPK_DIR)/CONTROL/control
	echo $(PERL-APP-ACK_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-APP-ACK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-APP-ACK_IPK_DIR)

perl-app-ack-ipk: $(PERL-APP-ACK_IPK)

perl-app-ack-clean:
	-$(MAKE) -C $(PERL-APP-ACK_BUILD_DIR) clean

perl-app-ack-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-APP-ACK_DIR) $(PERL-APP-ACK_BUILD_DIR) $(PERL-APP-ACK_IPK_DIR) $(PERL-APP-ACK_IPK)
