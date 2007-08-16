###########################################################
#
# perl-dbd-mysql
#
###########################################################

PERL-DBD-MYSQL_SITE=http://search.cpan.org/CPAN/authors/id/C/CA/CAPTTOFU
PERL-DBD-MYSQL_VERSION=4.005
PERL-DBD-MYSQL_SOURCE=DBD-mysql-$(PERL-DBD-MYSQL_VERSION).tar.gz
PERL-DBD-MYSQL_DIR=DBD-mysql-$(PERL-DBD-MYSQL_VERSION)
PERL-DBD-MYSQL_UNZIP=zcat
PERL-DBD-MYSQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DBD-MYSQL_DESCRIPTION=DBD-mysql - The Perl Database Driver for MySQL.
PERL-DBD-MYSQL_SECTION=util
PERL-DBD-MYSQL_PRIORITY=optional
PERL-DBD-MYSQL_DEPENDS=mysql, perl-dbi
PERL-DBD-MYSQL_SUGGESTS=
PERL-DBD-MYSQL_CONFLICTS=

PERL-DBD-MYSQL_IPK_VERSION=1

PERL-DBD-MYSQL_CPPFLAGS=-I$(STAGING_LIB_DIR)/perl5/site_perl/$(PERL_VERSION)/$(PERL_ARCH)/auto/DBI -I$(STAGING_INCLUDE_DIR)/mysql
PERL-DBD-MYSQL_LDFLAGS=-L$(STAGING_LIB_DIR)/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE -lperl -L$(STAGING_LIB_DIR)/mysql -lmysqlclient_r -Wl,-rpath=/opt/lib/mysql

PERL-DBD-MYSQL_CONFFILES=
PERL-DBD-MYSQL_PATCHES=$(PERL-DBD-MYSQL_SOURCE_DIR)/Makefile.PL.patch

PERL-DBD-MYSQL_BUILD_DIR=$(BUILD_DIR)/perl-dbd-mysql
PERL-DBD-MYSQL_SOURCE_DIR=$(SOURCE_DIR)/perl-dbd-mysql
PERL-DBD-MYSQL_IPK_DIR=$(BUILD_DIR)/perl-dbd-mysql-$(PERL-DBD-MYSQL_VERSION)-ipk
PERL-DBD-MYSQL_IPK=$(BUILD_DIR)/perl-dbd-mysql_$(PERL-DBD-MYSQL_VERSION)-$(PERL-DBD-MYSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DBD-MYSQL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DBD-MYSQL_SITE)/$(PERL-DBD-MYSQL_SOURCE)

perl-dbd-mysql-source: $(DL_DIR)/$(PERL-DBD-MYSQL_SOURCE) $(PERL-DBD-MYSQL_PATCHES)

$(PERL-DBD-MYSQL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DBD-MYSQL_SOURCE) $(PERL-DBD-MYSQL_PATCHES)
	$(MAKE) mysql-stage
	$(MAKE) perl-dbi-stage
	rm -rf $(BUILD_DIR)/$(PERL-DBD-MYSQL_DIR) $(PERL-DBD-MYSQL_BUILD_DIR)
	$(PERL-DBD-MYSQL_UNZIP) $(DL_DIR)/$(PERL-DBD-MYSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL-DBD-MYSQL_PATCHES)"; then \
		cat $(PERL-DBD-MYSQL_PATCHES) | patch -bd $(BUILD_DIR)/$(PERL-DBD-MYSQL_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(PERL-DBD-MYSQL_DIR) $(PERL-DBD-MYSQL_BUILD_DIR)
	(cd $(PERL-DBD-MYSQL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL-DBD-MYSQL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL-DBD-MYSQL_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL  \
		PREFIX=/opt \
		"--cflags=$(STAGING_CPPFLAGS) $(PERL-DBD-MYSQL_CPPFLAGS)" \
		"--libs=$(STAGING_LDFLAGS)" \
	)
	touch $(PERL-DBD-MYSQL_BUILD_DIR)/.configured

perl-dbd-mysql-unpack: $(PERL-DBD-MYSQL_BUILD_DIR)/.configured

$(PERL-DBD-MYSQL_BUILD_DIR)/.built: $(PERL-DBD-MYSQL_BUILD_DIR)/.configured
	rm -f $(PERL-DBD-MYSQL_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DBD-MYSQL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL-DBD-MYSQL_CPPFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL-DBD-MYSQL_LDFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL-DBD-MYSQL_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		DBI_DRIVER_XST="$(STAGING_LIB_DIR)/perl5/site_perl/$(PERL_VERSION)/$(PERL_ARCH)/auto/DBI/Driver.xst" \
		;
	touch $(PERL-DBD-MYSQL_BUILD_DIR)/.built

perl-dbd-mysql: $(PERL-DBD-MYSQL_BUILD_DIR)/.built

perl-dbd-mysql-test: $(PERL-DBD-MYSQL_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DBD-MYSQL_BUILD_DIR) test\
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	
$(PERL-DBD-MYSQL_BUILD_DIR)/.staged: $(PERL-DBD-MYSQL_BUILD_DIR)/.built
	rm -f $(PERL-DBD-MYSQL_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DBD-MYSQL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DBD-MYSQL_BUILD_DIR)/.staged

perl-dbd-mysql-stage: $(PERL-DBD-MYSQL_BUILD_DIR)/.staged

$(PERL-DBD-MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-DBD-MYSQL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-dbd-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DBD-MYSQL_PRIORITY)" >>$@
	@echo "Section: $(PERL-DBD-MYSQL_SECTION)" >>$@
	@echo "Version: $(PERL-DBD-MYSQL_VERSION)-$(PERL-DBD-MYSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DBD-MYSQL_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DBD-MYSQL_SITE)/$(PERL-DBD-MYSQL_SOURCE)" >>$@
	@echo "Description: $(PERL-DBD-MYSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DBD-MYSQL_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DBD-MYSQL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DBD-MYSQL_CONFLICTS)" >>$@

$(PERL-DBD-MYSQL_IPK): $(PERL-DBD-MYSQL_BUILD_DIR)/.built
	rm -rf $(PERL-DBD-MYSQL_IPK_DIR) $(BUILD_DIR)/perl-dbd-mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DBD-MYSQL_BUILD_DIR) install \
		DESTDIR=$(PERL-DBD-MYSQL_IPK_DIR) \
		DBI_DRIVER_XST="$(STAGING_LIB_DIR)/perl5/site_perl/$(PERL_VERSION)/$(PERL_ARCH)/auto/DBI/Driver.xst" \
		;
	find $(PERL-DBD-MYSQL_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DBD-MYSQL_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DBD-MYSQL_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DBD-MYSQL_IPK_DIR)/CONTROL/control
	echo $(PERL-DBD-MYSQL_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DBD-MYSQL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DBD-MYSQL_IPK_DIR)

perl-dbd-mysql-ipk: $(PERL-DBD-MYSQL_IPK)

perl-dbd-mysql-clean:
	-$(MAKE) -C $(PERL-DBD-MYSQL_BUILD_DIR) clean

perl-dbd-mysql-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DBD-MYSQL_DIR) $(PERL-DBD-MYSQL_BUILD_DIR) $(PERL-DBD-MYSQL_IPK_DIR) $(PERL-DBD-MYSQL_IPK)

perl-dbd-mysql-check: $(PERL-DBD-MYSQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DBD-MYSQL_IPK)
