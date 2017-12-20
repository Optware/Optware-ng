###########################################################
#
# perl-berkeleydb
#
###########################################################

PERL-BERKELEYDB_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/P/PM/PMQS
PERL-BERKELEYDB_VERSION=0.55
PERL-BERKELEYDB_SOURCE=BerkeleyDB-$(PERL-BERKELEYDB_VERSION).tar.gz
PERL-BERKELEYDB_DIR=BerkeleyDB-$(PERL-BERKELEYDB_VERSION)
PERL-BERKELEYDB_UNZIP=zcat
PERL-BERKELEYDB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-BERKELEYDB_DESCRIPTION=BerkeleyDB - Perl extension for Berkeley DB version 2, 3 or 4
PERL-BERKELEYDB_SECTION=util
PERL-BERKELEYDB_PRIORITY=optional
PERL-BERKELEYDB_DEPENDS=perl, openssl, zlib, libdb
PERL-BERKELEYDB_SUGGESTS=
PERL-BERKELEYDB_CONFLICTS=

PERL-BERKELEYDB_IPK_VERSION=1

PERL-BERKELEYDB_CONFFILES=

PERL-BERKELEYDB_BUILD_DIR=$(BUILD_DIR)/perl-berkeleydb
PERL-BERKELEYDB_SOURCE_DIR=$(SOURCE_DIR)/perl-berkeleydb
PERL-BERKELEYDB_IPK_DIR=$(BUILD_DIR)/perl-berkeleydb-$(PERL-BERKELEYDB_VERSION)-ipk
PERL-BERKELEYDB_IPK=$(BUILD_DIR)/perl-berkeleydb_$(PERL-BERKELEYDB_VERSION)-$(PERL-BERKELEYDB_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-BERKELEYDB_SOURCE):
	$(WGET) -P $(@D) $(PERL-BERKELEYDB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-berkeleydb-source: $(DL_DIR)/$(PERL-BERKELEYDB_SOURCE) $(PERL-BERKELEYDB_PATCHES)

$(PERL-BERKELEYDB_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-BERKELEYDB_SOURCE) $(PERL-BERKELEYDB_PATCHES) make/perl-berkeleydb.mk
	$(MAKE) perl-stage openssl-stage zlib-stage libdb-stage
	rm -rf $(BUILD_DIR)/$(PERL-BERKELEYDB_DIR) $(@D)
	$(PERL-BERKELEYDB_UNZIP) $(DL_DIR)/$(PERL-BERKELEYDB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-BERKELEYDB_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-BERKELEYDB_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-BERKELEYDB_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) -lpthread" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		BERKELEYDB_INCLUDE=$(STAGING_INCLUDE_DIR) \
		BERKELEYDB_LIB=$(STAGING_LIB_DIR) \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-berkeleydb-unpack: $(PERL-BERKELEYDB_BUILD_DIR)/.configured

$(PERL-BERKELEYDB_BUILD_DIR)/.built: $(PERL-BERKELEYDB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-berkeleydb: $(PERL-BERKELEYDB_BUILD_DIR)/.built

$(PERL-BERKELEYDB_BUILD_DIR)/.staged: $(PERL-BERKELEYDB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-berkeleydb-stage: $(PERL-BERKELEYDB_BUILD_DIR)/.staged

$(PERL-BERKELEYDB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-berkeleydb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-BERKELEYDB_PRIORITY)" >>$@
	@echo "Section: $(PERL-BERKELEYDB_SECTION)" >>$@
	@echo "Version: $(PERL-BERKELEYDB_VERSION)-$(PERL-BERKELEYDB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-BERKELEYDB_MAINTAINER)" >>$@
	@echo "Source: $(PERL-BERKELEYDB_SITE)/$(PERL-BERKELEYDB_SOURCE)" >>$@
	@echo "Description: $(PERL-BERKELEYDB_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-BERKELEYDB_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-BERKELEYDB_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-BERKELEYDB_CONFLICTS)" >>$@

$(PERL-BERKELEYDB_IPK): $(PERL-BERKELEYDB_BUILD_DIR)/.built
	rm -rf $(PERL-BERKELEYDB_IPK_DIR) $(BUILD_DIR)/perl-berkeleydb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-BERKELEYDB_BUILD_DIR) DESTDIR=$(PERL-BERKELEYDB_IPK_DIR) install
	find $(PERL-BERKELEYDB_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-BERKELEYDB_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-BERKELEYDB_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-BERKELEYDB_IPK_DIR)/CONTROL/control
	echo $(PERL-BERKELEYDB_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-BERKELEYDB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-BERKELEYDB_IPK_DIR)

perl-berkeleydb-ipk: $(PERL-BERKELEYDB_IPK)

perl-berkeleydb-clean:
	-$(MAKE) -C $(PERL-BERKELEYDB_BUILD_DIR) clean

perl-berkeleydb-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-BERKELEYDB_DIR) $(PERL-BERKELEYDB_BUILD_DIR) $(PERL-BERKELEYDB_IPK_DIR) $(PERL-BERKELEYDB_IPK)
