###########################################################
#
# perl-io-interface
#
###########################################################

PERL-IO-INTERFACE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/L/LD/LDS
PERL-IO-INTERFACE_VERSION=1.09
PERL-IO-INTERFACE_SOURCE=IO-Interface-$(PERL-IO-INTERFACE_VERSION).tar.gz
PERL-IO-INTERFACE_DIR=IO-Interface-$(PERL-IO-INTERFACE_VERSION)
PERL-IO-INTERFACE_UNZIP=zcat
PERL-IO-INTERFACE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IO-INTERFACE_DESCRIPTION=Perl extension for access to network card configuration information.
PERL-IO-INTERFACE_SECTION=util
PERL-IO-INTERFACE_PRIORITY=optional
PERL-IO-INTERFACE_DEPENDS=perl
PERL-IO-INTERFACE_SUGGESTS=
PERL-IO-INTERFACE_CONFLICTS=

PERL-IO-INTERFACE_IPK_VERSION=3

PERL-IO-INTERFACE_CPPFLAGS=-I$(STAGING_LIB_DIR)/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE
PERL-IO-INTERFACE_LDFLAGS=-L$(STAGING_LIB_DIR)/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE -lperl

PERL-IO-INTERFACE_CONFFILES=
PERL-IO-INTERFACE_PATCHES=$(PERL-IO-INTERFACE_SOURCE_DIR)/Makefile.PL.patch

PERL-IO-INTERFACE_BUILD_DIR=$(BUILD_DIR)/perl-io-interface
PERL-IO-INTERFACE_SOURCE_DIR=$(SOURCE_DIR)/perl-io-interface
PERL-IO-INTERFACE_IPK_DIR=$(BUILD_DIR)/perl-io-interface-$(PERL-IO-INTERFACE_VERSION)-ipk
PERL-IO-INTERFACE_IPK=$(BUILD_DIR)/perl-io-interface_$(PERL-IO-INTERFACE_VERSION)-$(PERL-IO-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IO-INTERFACE_SOURCE):
	$(WGET) -P $(@D) $(PERL-IO-INTERFACE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-io-interface-source: $(DL_DIR)/$(PERL-IO-INTERFACE_SOURCE) $(PERL-IO-INTERFACE_PATCHES)

$(PERL-IO-INTERFACE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IO-INTERFACE_SOURCE) $(PERL-IO-INTERFACE_PATCHES) make/perl-io-interface.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-IO-INTERFACE_DIR) $(PERL-IO-INTERFACE_BUILD_DIR)
	$(PERL-IO-INTERFACE_UNZIP) $(DL_DIR)/$(PERL-IO-INTERFACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL-IO-INTERFACE_PATCHES)"; then \
		cat $(PERL-IO-INTERFACE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-IO-INTERFACE_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PERL-IO-INTERFACE_DIR) $(@D)
	mv -f $(@D)/lib/IO/Interface.xs $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL-IO-INTERFACE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL-IO-INTERFACE_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL  \
		PREFIX=$(TARGET_PREFIX) \
		"--cflags=$(STAGING_CPPFLAGS) $(PERL-IO-INTERFACE_CPPFLAGS)" \
		"--libs=$(STAGING_LDFLAGS)" \
	)
	touch $@

perl-io-interface-unpack: $(PERL-IO-INTERFACE_BUILD_DIR)/.configured

$(PERL-IO-INTERFACE_BUILD_DIR)/.built: $(PERL-IO-INTERFACE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS) $(PERL-IO-INTERFACE_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS) $(PERL-IO-INTERFACE_LDFLAGS)" \
		PASTHRU_INC="$(STAGING_CPPFLAGS) $(PERL-IO-INTERFACE_CPPFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-io-interface: $(PERL-IO-INTERFACE_BUILD_DIR)/.built

$(PERL-IO-INTERFACE_BUILD_DIR)/.staged: $(PERL-IO-INTERFACE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-io-interface-stage: $(PERL-IO-INTERFACE_BUILD_DIR)/.staged

$(PERL-IO-INTERFACE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-io-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IO-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PERL-IO-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PERL-IO-INTERFACE_VERSION)-$(PERL-IO-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IO-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IO-INTERFACE_SITE)/$(PERL-IO-INTERFACE_SOURCE)" >>$@
	@echo "Description: $(PERL-IO-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IO-INTERFACE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IO-INTERFACE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IO-INTERFACE_CONFLICTS)" >>$@

$(PERL-IO-INTERFACE_IPK): $(PERL-IO-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PERL-IO-INTERFACE_IPK_DIR) $(BUILD_DIR)/perl-io-interface_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IO-INTERFACE_BUILD_DIR) install \
		DESTDIR=$(PERL-IO-INTERFACE_IPK_DIR) \
		;
	find $(PERL-IO-INTERFACE_IPK_DIR)$(TARGET_PREFIX) -type f -name 'perllocal.pod' -exec rm -f {} \;
	find $(PERL-IO-INTERFACE_IPK_DIR)$(TARGET_PREFIX) -type f -name '.packlist' -exec rm -f {} \;
	mkdir -p $(PERL-IO-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/share
	mv -f $(PERL-IO-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/{man,share/}
	(cd $(PERL-IO-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IO-INTERFACE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IO-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PERL-IO-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IO-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IO-INTERFACE_IPK_DIR)

perl-io-interface-ipk: $(PERL-IO-INTERFACE_IPK)

perl-io-interface-clean:
	-$(MAKE) -C $(PERL-IO-INTERFACE_BUILD_DIR) clean

perl-io-interface-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IO-INTERFACE_DIR) $(PERL-IO-INTERFACE_BUILD_DIR) $(PERL-IO-INTERFACE_IPK_DIR) $(PERL-IO-INTERFACE_IPK)

perl-io-interface-check: $(PERL-IO-INTERFACE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
