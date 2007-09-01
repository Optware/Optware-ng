###########################################################
#
# perlconsole
#
###########################################################

PERLCONSOLE_SITE=http://www.sukria.net
PERLCONSOLE_VERSION=0.3
PERLCONSOLE_SOURCE=perlconsole-$(PERLCONSOLE_VERSION).tar.gz
PERLCONSOLE_DIR=perlconsole-$(PERLCONSOLE_VERSION)
PERLCONSOLE_UNZIP=zcat
PERLCONSOLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERLCONSOLE_DESCRIPTION=Perl Console is a small program that implements a Read-eval-print loop: it lets you evaluate Perl code interactively.
PERLCONSOLE_SECTION=util
PERLCONSOLE_PRIORITY=optional
PERLCONSOLE_DEPENDS=perl-module-refresh, perl-lexical-persistence
PERLCONSOLE_SUGGESTS=perl-term-readline-gnu
PERLCONSOLE_CONFLICTS=

PERLCONSOLE_IPK_VERSION=1

PERLCONSOLE_CONFFILES=

PERLCONSOLE_BUILD_DIR=$(BUILD_DIR)/perlconsole
PERLCONSOLE_SOURCE_DIR=$(SOURCE_DIR)/perlconsole
PERLCONSOLE_IPK_DIR=$(BUILD_DIR)/perlconsole-$(PERLCONSOLE_VERSION)-ipk
PERLCONSOLE_IPK=$(BUILD_DIR)/perlconsole_$(PERLCONSOLE_VERSION)-$(PERLCONSOLE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERLCONSOLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERLCONSOLE_SITE)/$(PERLCONSOLE_SOURCE)

perlconsole-source: $(DL_DIR)/$(PERLCONSOLE_SOURCE) $(PERLCONSOLE_PATCHES)

$(PERLCONSOLE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERLCONSOLE_SOURCE) $(PERLCONSOLE_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERLCONSOLE_DIR) $(PERLCONSOLE_BUILD_DIR)
	$(PERLCONSOLE_UNZIP) $(DL_DIR)/$(PERLCONSOLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERLCONSOLE_PATCHES) | patch -d $(BUILD_DIR)/$(PERLCONSOLE_DIR) -p1
	mv $(BUILD_DIR)/$(PERLCONSOLE_DIR) $(PERLCONSOLE_BUILD_DIR)
	(cd $(PERLCONSOLE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERLCONSOLE_BUILD_DIR)/.configured

perlconsole-unpack: $(PERLCONSOLE_BUILD_DIR)/.configured

$(PERLCONSOLE_BUILD_DIR)/.built: $(PERLCONSOLE_BUILD_DIR)/.configured
	rm -f $(PERLCONSOLE_BUILD_DIR)/.built
	$(MAKE) -C $(PERLCONSOLE_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERLCONSOLE_BUILD_DIR)/.built

perlconsole: $(PERLCONSOLE_BUILD_DIR)/.built

$(PERLCONSOLE_BUILD_DIR)/.staged: $(PERLCONSOLE_BUILD_DIR)/.built
	rm -f $(PERLCONSOLE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERLCONSOLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERLCONSOLE_BUILD_DIR)/.staged

perlconsole-stage: $(PERLCONSOLE_BUILD_DIR)/.staged

$(PERLCONSOLE_IPK_DIR)/CONTROL/control:
	@install -d $(PERLCONSOLE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perlconsole" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERLCONSOLE_PRIORITY)" >>$@
	@echo "Section: $(PERLCONSOLE_SECTION)" >>$@
	@echo "Version: $(PERLCONSOLE_VERSION)-$(PERLCONSOLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERLCONSOLE_MAINTAINER)" >>$@
	@echo "Source: $(PERLCONSOLE_SITE)/$(PERLCONSOLE_SOURCE)" >>$@
	@echo "Description: $(PERLCONSOLE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERLCONSOLE_DEPENDS)" >>$@
	@echo "Suggests: $(PERLCONSOLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERLCONSOLE_CONFLICTS)" >>$@

$(PERLCONSOLE_IPK): $(PERLCONSOLE_BUILD_DIR)/.built
	rm -rf $(PERLCONSOLE_IPK_DIR) $(BUILD_DIR)/perlconsole_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERLCONSOLE_BUILD_DIR) DESTDIR=$(PERLCONSOLE_IPK_DIR) install
	find $(PERLCONSOLE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERLCONSOLE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERLCONSOLE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERLCONSOLE_IPK_DIR)/CONTROL/control
	echo $(PERLCONSOLE_CONFFILES) | sed -e 's/ /\n/g' > $(PERLCONSOLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERLCONSOLE_IPK_DIR)

perlconsole-ipk: $(PERLCONSOLE_IPK)

perlconsole-clean:
	-$(MAKE) -C $(PERLCONSOLE_BUILD_DIR) clean

perlconsole-dirclean:
	rm -rf $(BUILD_DIR)/$(PERLCONSOLE_DIR) $(PERLCONSOLE_BUILD_DIR) $(PERLCONSOLE_IPK_DIR) $(PERLCONSOLE_IPK)
