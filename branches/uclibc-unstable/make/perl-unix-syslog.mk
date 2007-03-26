###########################################################
#
# perl-unix-syslog
#
###########################################################

PERL-UNIX-SYSLOG_SITE=http://search.cpan.org/CPAN/authors/id/M/MH/MHARNISCH
PERL-UNIX-SYSLOG_VERSION=0.100
PERL-UNIX-SYSLOG_SOURCE=Unix-Syslog-$(PERL-UNIX-SYSLOG_VERSION).tar.gz
PERL-UNIX-SYSLOG_DIR=Unix-Syslog-$(PERL-UNIX-SYSLOG_VERSION)
PERL-UNIX-SYSLOG_UNZIP=zcat
PERL-UNIX-SYSLOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-UNIX-SYSLOG_DESCRIPTION=Unix-Syslog - Perl interface to the UNIX syslog(3) calls
PERL-UNIX-SYSLOG_SECTION=util
PERL-UNIX-SYSLOG_PRIORITY=optional
PERL-UNIX-SYSLOG_DEPENDS=perl
PERL-UNIX-SYSLOG_SUGGESTS=
PERL-UNIX-SYSLOG_CONFLICTS=

PERL-UNIX-SYSLOG_IPK_VERSION=1

PERL-UNIX-SYSLOG_CONFFILES=

PERL-UNIX-SYSLOG_BUILD_DIR=$(BUILD_DIR)/perl-unix-syslog
PERL-UNIX-SYSLOG_SOURCE_DIR=$(SOURCE_DIR)/perl-unix-syslog
PERL-UNIX-SYSLOG_IPK_DIR=$(BUILD_DIR)/perl-unix-syslog-$(PERL-UNIX-SYSLOG_VERSION)-ipk
PERL-UNIX-SYSLOG_IPK=$(BUILD_DIR)/perl-unix-syslog_$(PERL-UNIX-SYSLOG_VERSION)-$(PERL-UNIX-SYSLOG_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-UNIX-SYSLOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-UNIX-SYSLOG_SITE)/$(PERL-UNIX-SYSLOG_SOURCE)

perl-unix-syslog-source: $(DL_DIR)/$(PERL-UNIX-SYSLOG_SOURCE) $(PERL-UNIX-SYSLOG_PATCHES)

$(PERL-UNIX-SYSLOG_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-UNIX-SYSLOG_SOURCE) $(PERL-UNIX-SYSLOG_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-UNIX-SYSLOG_DIR) $(PERL-UNIX-SYSLOG_BUILD_DIR)
	$(PERL-UNIX-SYSLOG_UNZIP) $(DL_DIR)/$(PERL-UNIX-SYSLOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-UNIX-SYSLOG_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-UNIX-SYSLOG_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-UNIX-SYSLOG_DIR) $(PERL-UNIX-SYSLOG_BUILD_DIR)
	(cd $(PERL-UNIX-SYSLOG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-UNIX-SYSLOG_BUILD_DIR)/.configured

perl-unix-syslog-unpack: $(PERL-UNIX-SYSLOG_BUILD_DIR)/.configured

$(PERL-UNIX-SYSLOG_BUILD_DIR)/.built: $(PERL-UNIX-SYSLOG_BUILD_DIR)/.configured
	rm -f $(PERL-UNIX-SYSLOG_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-UNIX-SYSLOG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-UNIX-SYSLOG_BUILD_DIR)/.built

perl-unix-syslog: $(PERL-UNIX-SYSLOG_BUILD_DIR)/.built

$(PERL-UNIX-SYSLOG_BUILD_DIR)/.staged: $(PERL-UNIX-SYSLOG_BUILD_DIR)/.built
	rm -f $(PERL-UNIX-SYSLOG_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-UNIX-SYSLOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-UNIX-SYSLOG_BUILD_DIR)/.staged

perl-unix-syslog-stage: $(PERL-UNIX-SYSLOG_BUILD_DIR)/.staged

$(PERL-UNIX-SYSLOG_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-UNIX-SYSLOG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-unix-syslog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-UNIX-SYSLOG_PRIORITY)" >>$@
	@echo "Section: $(PERL-UNIX-SYSLOG_SECTION)" >>$@
	@echo "Version: $(PERL-UNIX-SYSLOG_VERSION)-$(PERL-UNIX-SYSLOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-UNIX-SYSLOG_MAINTAINER)" >>$@
	@echo "Source: $(PERL-UNIX-SYSLOG_SITE)/$(PERL-UNIX-SYSLOG_SOURCE)" >>$@
	@echo "Description: $(PERL-UNIX-SYSLOG_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-UNIX-SYSLOG_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-UNIX-SYSLOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-UNIX-SYSLOG_CONFLICTS)" >>$@

$(PERL-UNIX-SYSLOG_IPK): $(PERL-UNIX-SYSLOG_BUILD_DIR)/.built
	rm -rf $(PERL-UNIX-SYSLOG_IPK_DIR) $(BUILD_DIR)/perl-unix-syslog_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-UNIX-SYSLOG_BUILD_DIR) DESTDIR=$(PERL-UNIX-SYSLOG_IPK_DIR) install
	find $(PERL-UNIX-SYSLOG_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-UNIX-SYSLOG_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-UNIX-SYSLOG_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-UNIX-SYSLOG_IPK_DIR)/CONTROL/control
	echo $(PERL-UNIX-SYSLOG_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-UNIX-SYSLOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-UNIX-SYSLOG_IPK_DIR)

perl-unix-syslog-ipk: $(PERL-UNIX-SYSLOG_IPK)

perl-unix-syslog-clean:
	-$(MAKE) -C $(PERL-UNIX-SYSLOG_BUILD_DIR) clean

perl-unix-syslog-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-UNIX-SYSLOG_DIR) $(PERL-UNIX-SYSLOG_BUILD_DIR) $(PERL-UNIX-SYSLOG_IPK_DIR) $(PERL-UNIX-SYSLOG_IPK)
