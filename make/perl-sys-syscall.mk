###########################################################
#
# perl-sys-syscall
#
###########################################################

PERL-SYS-SYSCALL_SITE=http://search.cpan.org/CPAN/authors/id/B/BR/BRADFITZ
PERL-SYS-SYSCALL_VERSION=0.22
PERL-SYS-SYSCALL_SOURCE=Sys-Syscall-$(PERL-SYS-SYSCALL_VERSION).tar.gz
PERL-SYS-SYSCALL_DIR=Sys-Syscall-$(PERL-SYS-SYSCALL_VERSION)
PERL-SYS-SYSCALL_UNZIP=zcat
PERL-SYS-SYSCALL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-SYS-SYSCALL_DESCRIPTION=Access system calls that Perl does not normally provide access to.
PERL-SYS-SYSCALL_SECTION=util
PERL-SYS-SYSCALL_PRIORITY=optional
PERL-SYS-SYSCALL_DEPENDS=perl
PERL-SYS-SYSCALL_SUGGESTS=
PERL-SYS-SYSCALL_CONFLICTS=

PERL-SYS-SYSCALL_IPK_VERSION=1

PERL-SYS-SYSCALL_CONFFILES=

PERL-SYS-SYSCALL_BUILD_DIR=$(BUILD_DIR)/perl-sys-syscall
PERL-SYS-SYSCALL_SOURCE_DIR=$(SOURCE_DIR)/perl-sys-syscall
PERL-SYS-SYSCALL_IPK_DIR=$(BUILD_DIR)/perl-sys-syscall-$(PERL-SYS-SYSCALL_VERSION)-ipk
PERL-SYS-SYSCALL_IPK=$(BUILD_DIR)/perl-sys-syscall_$(PERL-SYS-SYSCALL_VERSION)-$(PERL-SYS-SYSCALL_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-SYS-SYSCALL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-SYS-SYSCALL_SITE)/$(PERL-SYS-SYSCALL_SOURCE)

perl-sys-syscall-source: $(DL_DIR)/$(PERL-SYS-SYSCALL_SOURCE) $(PERL-SYS-SYSCALL_PATCHES)

$(PERL-SYS-SYSCALL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-SYS-SYSCALL_SOURCE) $(PERL-SYS-SYSCALL_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-SYS-SYSCALL_DIR) $(PERL-SYS-SYSCALL_BUILD_DIR)
	$(PERL-SYS-SYSCALL_UNZIP) $(DL_DIR)/$(PERL-SYS-SYSCALL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-SYS-SYSCALL_DIR) $(PERL-SYS-SYSCALL_BUILD_DIR)
	(cd $(PERL-SYS-SYSCALL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-SYS-SYSCALL_BUILD_DIR)/.configured

perl-sys-syscall-unpack: $(PERL-SYS-SYSCALL_BUILD_DIR)/.configured

$(PERL-SYS-SYSCALL_BUILD_DIR)/.built: $(PERL-SYS-SYSCALL_BUILD_DIR)/.configured
	rm -f $(PERL-SYS-SYSCALL_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-SYS-SYSCALL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-SYS-SYSCALL_BUILD_DIR)/.built

perl-sys-syscall: $(PERL-SYS-SYSCALL_BUILD_DIR)/.built

$(PERL-SYS-SYSCALL_BUILD_DIR)/.staged: $(PERL-SYS-SYSCALL_BUILD_DIR)/.built
	rm -f $(PERL-SYS-SYSCALL_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-SYS-SYSCALL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-SYS-SYSCALL_BUILD_DIR)/.staged

perl-sys-syscall-stage: $(PERL-SYS-SYSCALL_BUILD_DIR)/.staged

$(PERL-SYS-SYSCALL_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-SYS-SYSCALL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-sys-syscall" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-SYS-SYSCALL_PRIORITY)" >>$@
	@echo "Section: $(PERL-SYS-SYSCALL_SECTION)" >>$@
	@echo "Version: $(PERL-SYS-SYSCALL_VERSION)-$(PERL-SYS-SYSCALL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-SYS-SYSCALL_MAINTAINER)" >>$@
	@echo "Source: $(PERL-SYS-SYSCALL_SITE)/$(PERL-SYS-SYSCALL_SOURCE)" >>$@
	@echo "Description: $(PERL-SYS-SYSCALL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-SYS-SYSCALL_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-SYS-SYSCALL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-SYS-SYSCALL_CONFLICTS)" >>$@

$(PERL-SYS-SYSCALL_IPK): $(PERL-SYS-SYSCALL_BUILD_DIR)/.built
	rm -rf $(PERL-SYS-SYSCALL_IPK_DIR) $(BUILD_DIR)/perl-sys-syscall_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-SYS-SYSCALL_BUILD_DIR) DESTDIR=$(PERL-SYS-SYSCALL_IPK_DIR) install
	find $(PERL-SYS-SYSCALL_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-SYS-SYSCALL_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-SYS-SYSCALL_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-SYS-SYSCALL_IPK_DIR)/CONTROL/control
	echo $(PERL-SYS-SYSCALL_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-SYS-SYSCALL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-SYS-SYSCALL_IPK_DIR)

perl-sys-syscall-ipk: $(PERL-SYS-SYSCALL_IPK)

perl-sys-syscall-clean:
	-$(MAKE) -C $(PERL-SYS-SYSCALL_BUILD_DIR) clean

perl-sys-syscall-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-SYS-SYSCALL_DIR) $(PERL-SYS-SYSCALL_BUILD_DIR) $(PERL-SYS-SYSCALL_IPK_DIR) $(PERL-SYS-SYSCALL_IPK)

perl-sys-syscall-check: $(PERL-SYS-SYSCALL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-SYS-SYSCALL_IPK)
