###########################################################
#
# perl-class-dbi
#
###########################################################

PERL-CLASS-DBI_SITE=http://search.cpan.org/CPAN/authors/id/T/TM/TMTM
PERL-CLASS-DBI_VERSION=v3.0.14
PERL-CLASS-DBI_SOURCE=Class-DBI-$(PERL-CLASS-DBI_VERSION).tar.gz
PERL-CLASS-DBI_DIR=Class-DBI-$(PERL-CLASS-DBI_VERSION)
PERL-CLASS-DBI_UNZIP=zcat
PERL-CLASS-DBI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CLASS-DBI_DESCRIPTION=Class-DBI - Simple Database Abstraction.
PERL-CLASS-DBI_SECTION=util
PERL-CLASS-DBI_PRIORITY=optional
PERL-CLASS-DBI_DEPENDS=perl, perl-class-accessor, perl-class-data-inheritable, perl-class-trigger, perl-ima-dbi, perl-clone, perl-universal-moniker, perl-version
PERL-CLASS-DBI_SUGGESTS=
PERL-CLASS-DBI_CONFLICTS=

PERL-CLASS-DBI_IPK_VERSION=1

PERL-CLASS-DBI_CONFFILES=

PERL-CLASS-DBI_BUILD_DIR=$(BUILD_DIR)/perl-class-dbi
PERL-CLASS-DBI_SOURCE_DIR=$(SOURCE_DIR)/perl-class-dbi
PERL-CLASS-DBI_IPK_DIR=$(BUILD_DIR)/perl-class-dbi-$(PERL-CLASS-DBI_VERSION)-ipk
PERL-CLASS-DBI_IPK=$(BUILD_DIR)/perl-class-dbi_$(PERL-CLASS-DBI_VERSION)-$(PERL-CLASS-DBI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CLASS-DBI_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CLASS-DBI_SITE)/$(PERL-CLASS-DBI_SOURCE)

perl-class-dbi-source: $(DL_DIR)/$(PERL-CLASS-DBI_SOURCE) $(PERL-CLASS-DBI_PATCHES)

$(PERL-CLASS-DBI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CLASS-DBI_SOURCE) $(PERL-CLASS-DBI_PATCHES)
	$(MAKE) perl-class-accessor-stage perl-class-data-inheritable-stage perl-class-trigger-stage perl-ima-dbi-stage perl-clone-stage perl-universal-moniker-stage perl-version-stage
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-DBI_DIR) $(PERL-CLASS-DBI_BUILD_DIR)
	$(PERL-CLASS-DBI_UNZIP) $(DL_DIR)/$(PERL-CLASS-DBI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CLASS-DBI_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CLASS-DBI_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CLASS-DBI_DIR) $(PERL-CLASS-DBI_BUILD_DIR)
	(cd $(PERL-CLASS-DBI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-CLASS-DBI_BUILD_DIR)/.configured

perl-class-dbi-unpack: $(PERL-CLASS-DBI_BUILD_DIR)/.configured

$(PERL-CLASS-DBI_BUILD_DIR)/.built: $(PERL-CLASS-DBI_BUILD_DIR)/.configured
	rm -f $(PERL-CLASS-DBI_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CLASS-DBI_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CLASS-DBI_BUILD_DIR)/.built

perl-class-dbi: $(PERL-CLASS-DBI_BUILD_DIR)/.built

$(PERL-CLASS-DBI_BUILD_DIR)/.staged: $(PERL-CLASS-DBI_BUILD_DIR)/.built
	rm -f $(PERL-CLASS-DBI_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CLASS-DBI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CLASS-DBI_BUILD_DIR)/.staged

perl-class-dbi-stage: $(PERL-CLASS-DBI_BUILD_DIR)/.staged

$(PERL-CLASS-DBI_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CLASS-DBI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-class-dbi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CLASS-DBI_PRIORITY)" >>$@
	@echo "Section: $(PERL-CLASS-DBI_SECTION)" >>$@
	@echo "Version: $(PERL-CLASS-DBI_VERSION)-$(PERL-CLASS-DBI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CLASS-DBI_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CLASS-DBI_SITE)/$(PERL-CLASS-DBI_SOURCE)" >>$@
	@echo "Description: $(PERL-CLASS-DBI_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CLASS-DBI_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CLASS-DBI_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CLASS-DBI_CONFLICTS)" >>$@

$(PERL-CLASS-DBI_IPK): $(PERL-CLASS-DBI_BUILD_DIR)/.built
	rm -rf $(PERL-CLASS-DBI_IPK_DIR) $(BUILD_DIR)/perl-class-dbi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CLASS-DBI_BUILD_DIR) DESTDIR=$(PERL-CLASS-DBI_IPK_DIR) install
	find $(PERL-CLASS-DBI_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CLASS-DBI_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CLASS-DBI_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CLASS-DBI_IPK_DIR)/CONTROL/control
	echo $(PERL-CLASS-DBI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CLASS-DBI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CLASS-DBI_IPK_DIR)

perl-class-dbi-ipk: $(PERL-CLASS-DBI_IPK)

perl-class-dbi-clean:
	-$(MAKE) -C $(PERL-CLASS-DBI_BUILD_DIR) clean

perl-class-dbi-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CLASS-DBI_DIR) $(PERL-CLASS-DBI_BUILD_DIR) $(PERL-CLASS-DBI_IPK_DIR) $(PERL-CLASS-DBI_IPK)
