###########################################################
#
# perl-io-multiplex
#
###########################################################

PERL-IO-MULTIPLEX_SITE=http://search.cpan.org/CPAN/authors/id/B/BB/BBB
PERL-IO-MULTIPLEX_VERSION=1.09
PERL-IO-MULTIPLEX_SOURCE=IO-Multiplex-$(PERL-IO-MULTIPLEX_VERSION).tar.gz
PERL-IO-MULTIPLEX_DIR=IO-Multiplex-$(PERL-IO-MULTIPLEX_VERSION)
PERL-IO-MULTIPLEX_UNZIP=zcat
PERL-IO-MULTIPLEX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-IO-MULTIPLEX_DESCRIPTION=IO-Multiplex - Manage IO on many file handles
PERL-IO-MULTIPLEX_SECTION=util
PERL-IO-MULTIPLEX_PRIORITY=optional
PERL-IO-MULTIPLEX_DEPENDS=perl
PERL-IO-MULTIPLEX_SUGGESTS=
PERL-IO-MULTIPLEX_CONFLICTS=

PERL-IO-MULTIPLEX_IPK_VERSION=1

PERL-IO-MULTIPLEX_CONFFILES=

PERL-IO-MULTIPLEX_BUILD_DIR=$(BUILD_DIR)/perl-io-multiplex
PERL-IO-MULTIPLEX_SOURCE_DIR=$(SOURCE_DIR)/perl-io-multiplex
PERL-IO-MULTIPLEX_IPK_DIR=$(BUILD_DIR)/perl-io-multiplex-$(PERL-IO-MULTIPLEX_VERSION)-ipk
PERL-IO-MULTIPLEX_IPK=$(BUILD_DIR)/perl-io-multiplex_$(PERL-IO-MULTIPLEX_VERSION)-$(PERL-IO-MULTIPLEX_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-IO-MULTIPLEX_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-IO-MULTIPLEX_SITE)/$(PERL-IO-MULTIPLEX_SOURCE)

perl-io-multiplex-source: $(DL_DIR)/$(PERL-IO-MULTIPLEX_SOURCE) $(PERL-IO-MULTIPLEX_PATCHES)

$(PERL-IO-MULTIPLEX_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-IO-MULTIPLEX_SOURCE) $(PERL-IO-MULTIPLEX_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-IO-MULTIPLEX_DIR) $(@D)
	$(PERL-IO-MULTIPLEX_UNZIP) $(DL_DIR)/$(PERL-IO-MULTIPLEX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-IO-MULTIPLEX_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-IO-MULTIPLEX_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-IO-MULTIPLEX_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $@

perl-io-multiplex-unpack: $(PERL-IO-MULTIPLEX_BUILD_DIR)/.configured

$(PERL-IO-MULTIPLEX_BUILD_DIR)/.built: $(PERL-IO-MULTIPLEX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-io-multiplex: $(PERL-IO-MULTIPLEX_BUILD_DIR)/.built

$(PERL-IO-MULTIPLEX_BUILD_DIR)/.staged: $(PERL-IO-MULTIPLEX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-io-multiplex-stage: $(PERL-IO-MULTIPLEX_BUILD_DIR)/.staged

$(PERL-IO-MULTIPLEX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-io-multiplex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-IO-MULTIPLEX_PRIORITY)" >>$@
	@echo "Section: $(PERL-IO-MULTIPLEX_SECTION)" >>$@
	@echo "Version: $(PERL-IO-MULTIPLEX_VERSION)-$(PERL-IO-MULTIPLEX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-IO-MULTIPLEX_MAINTAINER)" >>$@
	@echo "Source: $(PERL-IO-MULTIPLEX_SITE)/$(PERL-IO-MULTIPLEX_SOURCE)" >>$@
	@echo "Description: $(PERL-IO-MULTIPLEX_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-IO-MULTIPLEX_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-IO-MULTIPLEX_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-IO-MULTIPLEX_CONFLICTS)" >>$@

$(PERL-IO-MULTIPLEX_IPK): $(PERL-IO-MULTIPLEX_BUILD_DIR)/.built
	rm -rf $(PERL-IO-MULTIPLEX_IPK_DIR) $(BUILD_DIR)/perl-io-multiplex_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-IO-MULTIPLEX_BUILD_DIR) DESTDIR=$(PERL-IO-MULTIPLEX_IPK_DIR) install
	find $(PERL-IO-MULTIPLEX_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-IO-MULTIPLEX_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-IO-MULTIPLEX_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-IO-MULTIPLEX_IPK_DIR)/CONTROL/control
	echo $(PERL-IO-MULTIPLEX_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-IO-MULTIPLEX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-IO-MULTIPLEX_IPK_DIR)

perl-io-multiplex-ipk: $(PERL-IO-MULTIPLEX_IPK)

perl-io-multiplex-clean:
	-$(MAKE) -C $(PERL-IO-MULTIPLEX_BUILD_DIR) clean

perl-io-multiplex-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-IO-MULTIPLEX_DIR) $(PERL-IO-MULTIPLEX_BUILD_DIR) $(PERL-IO-MULTIPLEX_IPK_DIR) $(PERL-IO-MULTIPLEX_IPK)
