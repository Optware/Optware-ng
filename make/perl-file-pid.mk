###########################################################
#
# perl-file-pid
#
###########################################################

PERL_FILE_PID_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/C/CW/CWEST
PERL_FILE_PID_VERSION=1.01
PERL_FILE_PID_SOURCE=File-Pid-$(PERL_FILE_PID_VERSION).tar.gz
PERL_FILE_PID_DIR=File-Pid-$(PERL_FILE_PID_VERSION)
PERL_FILE_PID_UNZIP=zcat
PERL_FILE_PID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_FILE_PID_DESCRIPTION=File::Pid - Pid File Manipulation
PERL_FILE_PID_SECTION=util
PERL_FILE_PID_PRIORITY=optional
PERL_FILE_PID_DEPENDS=perl, perl-class-accessor
PERL_FILE_PID_SUGGESTS=
PERL_FILE_PID_CONFLICTS=

PERL_FILE_PID_IPK_VERSION=2

PERL_FILE_PID_CONFFILES=

PERL_FILE_PID_BUILD_DIR=$(BUILD_DIR)/perl-file-pid
PERL_FILE_PID_SOURCE_DIR=$(SOURCE_DIR)/perl-file-pid
PERL_FILE_PID_IPK_DIR=$(BUILD_DIR)/perl-file-pid-$(PERL_FILE_PID_VERSION)-ipk
PERL_FILE_PID_IPK=$(BUILD_DIR)/perl-file-pid_$(PERL_FILE_PID_VERSION)-$(PERL_FILE_PID_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL_FILE_PID_SOURCE):
	$(WGET) -P $(@D) $(PERL_FILE_PID_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-file-pid-source: $(DL_DIR)/$(PERL_FILE_PID_SOURCE) $(PERL_FILE_PID_PATCHES)

$(PERL_FILE_PID_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_FILE_PID_SOURCE) $(PERL_FILE_PID_PATCHES) make/perl-file-pid.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL_FILE_PID_DIR) $(PERL_FILE_PID_BUILD_DIR)
	$(PERL_FILE_PID_UNZIP) $(DL_DIR)/$(PERL_FILE_PID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL_FILE_PID_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL_FILE_PID_DIR) -p1
	mv $(BUILD_DIR)/$(PERL_FILE_PID_DIR) $(PERL_FILE_PID_BUILD_DIR)
	(cd $(PERL_FILE_PID_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL_FILE_PID_BUILD_DIR)/.configured

perl-file-pid-unpack: $(PERL_FILE_PID_BUILD_DIR)/.configured

$(PERL_FILE_PID_BUILD_DIR)/.built: $(PERL_FILE_PID_BUILD_DIR)/.configured
	rm -f $(PERL_FILE_PID_BUILD_DIR)/.built
	$(MAKE) -C $(PERL_FILE_PID_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL_FILE_PID_BUILD_DIR)/.built

perl-file-pid: $(PERL_FILE_PID_BUILD_DIR)/.built

$(PERL_FILE_PID_BUILD_DIR)/.staged: $(PERL_FILE_PID_BUILD_DIR)/.built
	rm -f $(PERL_FILE_PID_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL_FILE_PID_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL_FILE_PID_BUILD_DIR)/.staged

perl-file-pid-stage: $(PERL_FILE_PID_BUILD_DIR)/.staged

$(PERL_FILE_PID_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL_FILE_PID_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-file-pid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_FILE_PID_PRIORITY)" >>$@
	@echo "Section: $(PERL_FILE_PID_SECTION)" >>$@
	@echo "Version: $(PERL_FILE_PID_VERSION)-$(PERL_FILE_PID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_FILE_PID_MAINTAINER)" >>$@
	@echo "Source: $(PERL_FILE_PID_SITE)/$(PERL_FILE_PID_SOURCE)" >>$@
	@echo "Description: $(PERL_FILE_PID_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_FILE_PID_DEPENDS)" >>$@
	@echo "Suggests: $(PERL_FILE_PID_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL_FILE_PID_CONFLICTS)" >>$@

$(PERL_FILE_PID_IPK): $(PERL_FILE_PID_BUILD_DIR)/.built
	rm -rf $(PERL_FILE_PID_IPK_DIR) $(BUILD_DIR)/perl-file-pid_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL_FILE_PID_BUILD_DIR) DESTDIR=$(PERL_FILE_PID_IPK_DIR) install
	find $(PERL_FILE_PID_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL_FILE_PID_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL_FILE_PID_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL_FILE_PID_IPK_DIR)/CONTROL/control
	echo $(PERL_FILE_PID_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_FILE_PID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_FILE_PID_IPK_DIR)

perl-file-pid-ipk: $(PERL_FILE_PID_IPK)

perl-file-pid-clean:
	-$(MAKE) -C $(PERL_FILE_PID_BUILD_DIR) clean

perl-file-pid-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_FILE_PID_DIR) $(PERL_FILE_PID_BUILD_DIR) $(PERL_FILE_PID_IPK_DIR) $(PERL_FILE_PID_IPK)
