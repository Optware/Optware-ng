###########################################################
#
# perl-dbd-sqlite
#
###########################################################

PERL-DBD-SQLITE_SITE=http://search.cpan.org/CPAN/authors/id/A/AD/ADAMK
PERL-DBD-SQLITE_VERSION=1.35
PERL-DBD-SQLITE_SOURCE=DBD-SQLite-$(PERL-DBD-SQLITE_VERSION).tar.gz
PERL-DBD-SQLITE_DIR=DBD-SQLite-$(PERL-DBD-SQLITE_VERSION)
PERL-DBD-SQLITE_UNZIP=zcat
PERL-DBD-SQLITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DBD-SQLITE_DESCRIPTION=The Perl Database Driver for SQLITE.
PERL-DBD-SQLITE_SECTION=util
PERL-DBD-SQLITE_PRIORITY=optional
PERL-DBD-SQLITE_DEPENDS=perl-dbi, sqlite
PERL-DBD-SQLITE_SUGGESTS=
PERL-DBD-SQLITE_CONFLICTS=

PERL-DBD-SQLITE_IPK_VERSION=1

PERL-DBD-SQLITE_PATCHES=$(PERL-DBD-SQLITE_SOURCE_DIR)/Makefile.PL.patch
PERL-DBD-SQLITE_CONFFILES=

PERL-DBD-SQLITE_BUILD_DIR=$(BUILD_DIR)/perl-dbd-sqlite
PERL-DBD-SQLITE_SOURCE_DIR=$(SOURCE_DIR)/perl-dbd-sqlite
PERL-DBD-SQLITE_IPK_DIR=$(BUILD_DIR)/perl-dbd-sqlite-$(PERL-DBD-SQLITE_VERSION)-ipk
PERL-DBD-SQLITE_IPK=$(BUILD_DIR)/perl-dbd-sqlite_$(PERL-DBD-SQLITE_VERSION)-$(PERL-DBD-SQLITE_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-DBD-SQLITE_CPPFLAGS=-fno-strict-aliasing -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64

$(DL_DIR)/$(PERL-DBD-SQLITE_SOURCE):
	$(WGET) -P $(@D) $(PERL-DBD-SQLITE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-dbd-sqlite-source: $(DL_DIR)/$(PERL-DBD-SQLITE_SOURCE) $(PERL-DBD-SQLITE_PATCHES)

$(PERL-DBD-SQLITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DBD-SQLITE_SOURCE) $(PERL-DBD-SQLITE_PATCHES) make/perl-dbd-sqlite.mk
	$(MAKE) perl-dbi-stage sqlite-stage
	rm -rf $(BUILD_DIR)/$(PERL-DBD-SQLITE_DIR) $(PERL-DBD-SQLITE_BUILD_DIR)
	$(PERL-DBD-SQLITE_UNZIP) $(DL_DIR)/$(PERL-DBD-SQLITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL-DBD-SQLITE_PATCHES)"; then \
		cat $(PERL-DBD-SQLITE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DBD-SQLITE_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(PERL-DBD-SQLITE_DIR) $(PERL-DBD-SQLITE_BUILD_DIR)
	(cd $(PERL-DBD-SQLITE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(PERL-DBD-SQLITE_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL  \
		$(TARGET_CONFIGURE_OPTS) \
		PREFIX=/opt \
		SQLITE_LOCATION=$(STAGING_PREFIX) \
		; \
		sed -e 's/~DRIVER~/SQLite/g' \
		    $(STAGING_LIB_DIR)/perl5/site_perl/$(PERL_VERSION)/$(PERL_ARCH)/auto/DBI/Driver.xst > SQLite.xsi; \
	)
	touch $@

perl-dbd-sqlite-unpack: $(PERL-DBD-SQLITE_BUILD_DIR)/.configured

$(PERL-DBD-SQLITE_BUILD_DIR)/.built: $(PERL-DBD-SQLITE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-DBD-SQLITE_BUILD_DIR) \
	    PASTHRU_INC="$(STAGING_CPPFLAGS) -I$(STAGING_LIB_DIR)/perl5/site_perl/$(PERL_VERSION)/$(PERL_ARCH)/auto/DBI" \
	    LD_RUN_PATH=/opt/lib \
	    CCFLAGS="$(PERL-DBD-SQLITE_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	    LDFLAGS="$(STAGING_LDFLAGS)" \
	    LDDLFLAGS="-shared $(STAGING_LDFLAGS)" \
	    LD="$(TARGET_CC)" \
	    $(PERL_INC) \
	    PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-dbd-sqlite: $(PERL-DBD-SQLITE_BUILD_DIR)/.built

perl-dbd-sqlite-test: $(PERL-DBD-SQLITE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DBD-SQLITE_BUILD_DIR) test\
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	
$(PERL-DBD-SQLITE_BUILD_DIR)/.staged: $(PERL-DBD-SQLITE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-DBD-SQLITE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-dbd-sqlite-stage: $(PERL-DBD-SQLITE_BUILD_DIR)/.staged

$(PERL-DBD-SQLITE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-dbd-sqlite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DBD-SQLITE_PRIORITY)" >>$@
	@echo "Section: $(PERL-DBD-SQLITE_SECTION)" >>$@
	@echo "Version: $(PERL-DBD-SQLITE_VERSION)-$(PERL-DBD-SQLITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DBD-SQLITE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DBD-SQLITE_SITE)/$(PERL-DBD-SQLITE_SOURCE)" >>$@
	@echo "Description: $(PERL-DBD-SQLITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DBD-SQLITE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DBD-SQLITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DBD-SQLITE_CONFLICTS)" >>$@

$(PERL-DBD-SQLITE_IPK): $(PERL-DBD-SQLITE_BUILD_DIR)/.built
	rm -rf $(PERL-DBD-SQLITE_IPK_DIR) $(BUILD_DIR)/perl-dbd-sqlite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DBD-SQLITE_BUILD_DIR) DESTDIR=$(PERL-DBD-SQLITE_IPK_DIR) install
	find $(PERL-DBD-SQLITE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DBD-SQLITE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DBD-SQLITE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DBD-SQLITE_IPK_DIR)/CONTROL/control
	echo $(PERL-DBD-SQLITE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DBD-SQLITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DBD-SQLITE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PERL-DBD-SQLITE_IPK_DIR)

perl-dbd-sqlite-ipk: $(PERL-DBD-SQLITE_IPK)

perl-dbd-sqlite-clean:
	-$(MAKE) -C $(PERL-DBD-SQLITE_BUILD_DIR) clean

perl-dbd-sqlite-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DBD-SQLITE_DIR) $(PERL-DBD-SQLITE_BUILD_DIR) $(PERL-DBD-SQLITE_IPK_DIR) $(PERL-DBD-SQLITE_IPK)

perl-dbd-sqlite-check: $(PERL-DBD-SQLITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
