###########################################################
#
# perl-poe-xs-queue-array
#
###########################################################

PERL-POE-XS-QUEUE-ARRAY_SITE=http://search.cpan.org/CPAN/authors/id/T/TO/TONYC
PERL-POE-XS-QUEUE-ARRAY_VERSION=0.005
PERL-POE-XS-QUEUE-ARRAY_SOURCE=POE-XS-Queue-Array-$(PERL-POE-XS-QUEUE-ARRAY_VERSION).tar.gz
PERL-POE-XS-QUEUE-ARRAY_DIR=POE-XS-Queue-Array-$(PERL-POE-XS-QUEUE-ARRAY_VERSION)
PERL-POE-XS-QUEUE-ARRAY_UNZIP=zcat
PERL-POE-XS-QUEUE-ARRAY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-POE-XS-QUEUE-ARRAY_DESCRIPTION=an XS implementation of POE::Queue::Array.
PERL-POE-XS-QUEUE-ARRAY_SECTION=util
PERL-POE-XS-QUEUE-ARRAY_PRIORITY=optional
PERL-POE-XS-QUEUE-ARRAY_DEPENDS=perl
PERL-POE-XS-QUEUE-ARRAY_SUGGESTS=
PERL-POE-XS-QUEUE-ARRAY_CONFLICTS=

PERL-POE-XS-QUEUE-ARRAY_IPK_VERSION=1

PERL-POE-XS-QUEUE-ARRAY_CONFFILES=

PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR=$(BUILD_DIR)/perl-poe-xs-queue-array
PERL-POE-XS-QUEUE-ARRAY_SOURCE_DIR=$(SOURCE_DIR)/perl-poe-xs-queue-array
PERL-POE-XS-QUEUE-ARRAY_IPK_DIR=$(BUILD_DIR)/perl-poe-xs-queue-array-$(PERL-POE-XS-QUEUE-ARRAY_VERSION)-ipk
PERL-POE-XS-QUEUE-ARRAY_IPK=$(BUILD_DIR)/perl-poe-xs-queue-array_$(PERL-POE-XS-QUEUE-ARRAY_VERSION)-$(PERL-POE-XS-QUEUE-ARRAY_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_SOURCE):
	$(WGET) -P $(@D) $(PERL-POE-XS-QUEUE-ARRAY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-poe-xs-queue-array-source: $(DL_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_SOURCE) $(PERL-POE-XS-QUEUE-ARRAY_PATCHES)

$(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_SOURCE) $(PERL-POE-XS-QUEUE-ARRAY_PATCHES)
#	$(MAKE) <foo>-stage
	rm -rf $(BUILD_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_DIR) $(@D)
	$(PERL-POE-XS-QUEUE-ARRAY_UNZIP) $(DL_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-POE-XS-QUEUE-ARRAY_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-poe-xs-queue-array-unpack: $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.configured

$(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.built: $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-poe-xs-queue-array: $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.built

$(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.staged: $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-poe-xs-queue-array-stage: $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.staged

$(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-poe-xs-queue-array" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-POE-XS-QUEUE-ARRAY_PRIORITY)" >>$@
	@echo "Section: $(PERL-POE-XS-QUEUE-ARRAY_SECTION)" >>$@
	@echo "Version: $(PERL-POE-XS-QUEUE-ARRAY_VERSION)-$(PERL-POE-XS-QUEUE-ARRAY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-POE-XS-QUEUE-ARRAY_MAINTAINER)" >>$@
	@echo "Source: $(PERL-POE-XS-QUEUE-ARRAY_SITE)/$(PERL-POE-XS-QUEUE-ARRAY_SOURCE)" >>$@
	@echo "Description: $(PERL-POE-XS-QUEUE-ARRAY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-POE-XS-QUEUE-ARRAY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-POE-XS-QUEUE-ARRAY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-POE-XS-QUEUE-ARRAY_CONFLICTS)" >>$@

$(PERL-POE-XS-QUEUE-ARRAY_IPK): $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR)/.built
	rm -rf $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR) $(BUILD_DIR)/perl-poe-xs-queue-array_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR) DESTDIR=$(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR) install
	find $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)/CONTROL/control
	echo $(PERL-POE-XS-QUEUE-ARRAY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR)

perl-poe-xs-queue-array-ipk: $(PERL-POE-XS-QUEUE-ARRAY_IPK)

perl-poe-xs-queue-array-clean:
	-$(MAKE) -C $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR) clean

perl-poe-xs-queue-array-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-POE-XS-QUEUE-ARRAY_DIR) $(PERL-POE-XS-QUEUE-ARRAY_BUILD_DIR) $(PERL-POE-XS-QUEUE-ARRAY_IPK_DIR) $(PERL-POE-XS-QUEUE-ARRAY_IPK)

perl-poe-xs-queue-array-check: $(PERL-POE-XS-QUEUE-ARRAY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-POE-XS-QUEUE-ARRAY_IPK)
