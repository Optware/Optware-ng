###########################################################
#
# perl-class-trigger
#
###########################################################
http://search.cpan.org/CPAN/authors/id/M/MI/MIYAGAWA/Class-Trigger-0.10.tar.gz
	
PERL-CLASS-TRIGGER_SITE=http://search.cpan.org/CPAN/authors/id/M/MI/MIYAGAWA
PERL-CLASS-TRIGGER_VERSION=0.10
PERL-CLASS-TRIGGER_SOURCE=Class-Trigger-$(PERL-CLASS-TRIGGER_VERSION).tar.gz
PERL-CLASS-TRIGGER_DIR=Class-Trigger-$(PERL-CLASS-TRIGGER_VERSION)
PERL-CLASS-TRIGGER_UNZIP=zcat
PERL-CLASS-TRIGGER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CLASS-TRIGGER_DESCRIPTION=Class-Trigger - Mixin to add / call inheritable triggers.
PERL-CLASS-TRIGGER_SECTION=util
PERL-CLASS-TRIGGER_PRIORITY=optional
PERL-CLASS-TRIGGER_DEPENDS=perl, perl-class-data-inheritable, perl-io-stringy
PERL-CLASS-TRIGGER_SUGGESTS=
PERL-CLASS-TRIGGER_CONFLICTS=

PERL-CLASS-TRIGGER_IPK_VERSION=1

PERL-CLASS-TRIGGER_CONFFILES=

PERL-CLASS-TRIGGER_BUILD_DIR=$(BUILD_DIR)/perl-class-trigger
PERL-CLASS-TRIGGER_SOURCE_DIR=$(SOURCE_DIR)/perl-class-trigger
PERL-CLASS-TRIGGER_IPK_DIR=$(BUILD_DIR)/perl-class-trigger-$(PERL-CLASS-TRIGGER_VERSION)-ipk
PERL-CLASS-TRIGGER_IPK=$(BUILD_DIR)/perl-class-trigger_$(PERL-CLASS-TRIGGER_VERSION)-$(PERL-CLASS-TRIGGER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CLASS-TRIGGER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CLASS-TRIGGER_SITE)/$(PERL-CLASS-TRIGGER_SOURCE)

perl-class-trigger-source: $(DL_DIR)/$(PERL-CLASS-TRIGGER_SOURCE) $(PERL-CLASS-TRIGGER_PATCHES)

$(PERL-CLASS-TRIGGER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CLASS-TRIGGER_SOURCE) $(PERL-CLASS-TRIGGER_PATCHES)
	$(MAKE) perl-class-data-inheritable-stage perl-io-stringy-stage
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-TRIGGER_DIR) $(PERL-CLASS-TRIGGER_BUILD_DIR)
	$(PERL-CLASS-TRIGGER_UNZIP) $(DL_DIR)/$(PERL-CLASS-TRIGGER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CLASS-TRIGGER_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CLASS-TRIGGER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CLASS-TRIGGER_DIR) $(PERL-CLASS-TRIGGER_BUILD_DIR)
	(cd $(PERL-CLASS-TRIGGER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-CLASS-TRIGGER_BUILD_DIR)/.configured

perl-class-trigger-unpack: $(PERL-CLASS-TRIGGER_BUILD_DIR)/.configured

$(PERL-CLASS-TRIGGER_BUILD_DIR)/.built: $(PERL-CLASS-TRIGGER_BUILD_DIR)/.configured
	rm -f $(PERL-CLASS-TRIGGER_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CLASS-TRIGGER_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CLASS-TRIGGER_BUILD_DIR)/.built

perl-class-trigger: $(PERL-CLASS-TRIGGER_BUILD_DIR)/.built

$(PERL-CLASS-TRIGGER_BUILD_DIR)/.staged: $(PERL-CLASS-TRIGGER_BUILD_DIR)/.built
	rm -f $(PERL-CLASS-TRIGGER_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CLASS-TRIGGER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CLASS-TRIGGER_BUILD_DIR)/.staged

perl-class-trigger-stage: $(PERL-CLASS-TRIGGER_BUILD_DIR)/.staged

$(PERL-CLASS-TRIGGER_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CLASS-TRIGGER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-class-trigger" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CLASS-TRIGGER_PRIORITY)" >>$@
	@echo "Section: $(PERL-CLASS-TRIGGER_SECTION)" >>$@
	@echo "Version: $(PERL-CLASS-TRIGGER_VERSION)-$(PERL-CLASS-TRIGGER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CLASS-TRIGGER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CLASS-TRIGGER_SITE)/$(PERL-CLASS-TRIGGER_SOURCE)" >>$@
	@echo "Description: $(PERL-CLASS-TRIGGER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CLASS-TRIGGER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CLASS-TRIGGER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CLASS-TRIGGER_CONFLICTS)" >>$@

$(PERL-CLASS-TRIGGER_IPK): $(PERL-CLASS-TRIGGER_BUILD_DIR)/.built
	rm -rf $(PERL-CLASS-TRIGGER_IPK_DIR) $(BUILD_DIR)/perl-class-trigger_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CLASS-TRIGGER_BUILD_DIR) DESTDIR=$(PERL-CLASS-TRIGGER_IPK_DIR) install
	find $(PERL-CLASS-TRIGGER_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CLASS-TRIGGER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CLASS-TRIGGER_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CLASS-TRIGGER_IPK_DIR)/CONTROL/control
	echo $(PERL-CLASS-TRIGGER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CLASS-TRIGGER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CLASS-TRIGGER_IPK_DIR)

perl-class-trigger-ipk: $(PERL-CLASS-TRIGGER_IPK)

perl-class-trigger-clean:
	-$(MAKE) -C $(PERL-CLASS-TRIGGER_BUILD_DIR) clean

perl-class-trigger-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-TRIGGER_DIR) $(PERL-CLASS-TRIGGER_BUILD_DIR) $(PERL-CLASS-TRIGGER_IPK_DIR) $(PERL-CLASS-TRIGGER_IPK)
