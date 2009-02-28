###########################################################
#
# perl-getopt-long
#
###########################################################

PERL-GETOPT-LONG_SITE=http://search.cpan.org/CPAN/authors/id/J/JV/JV
PERL-GETOPT-LONG_VERSION=2.37_02
PERL-GETOPT-LONG_SOURCE=Getopt-Long-$(PERL-GETOPT-LONG_VERSION).tar.gz
PERL-GETOPT-LONG_DIR=Getopt-Long-$(PERL-GETOPT-LONG_VERSION)
PERL-GETOPT-LONG_UNZIP=zcat
PERL-GETOPT-LONG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-GETOPT-LONG_DESCRIPTION=Extended processing of command line options.
PERL-GETOPT-LONG_SECTION=util
PERL-GETOPT-LONG_PRIORITY=optional
PERL-GETOPT-LONG_DEPENDS=perl
PERL-GETOPT-LONG_SUGGESTS=
PERL-GETOPT-LONG_CONFLICTS=

PERL-GETOPT-LONG_IPK_VERSION=1

PERL-GETOPT-LONG_CONFFILES=

PERL-GETOPT-LONG_BUILD_DIR=$(BUILD_DIR)/perl-getopt-long
PERL-GETOPT-LONG_SOURCE_DIR=$(SOURCE_DIR)/perl-getopt-long
PERL-GETOPT-LONG_IPK_DIR=$(BUILD_DIR)/perl-getopt-long-$(PERL-GETOPT-LONG_VERSION)-ipk
PERL-GETOPT-LONG_IPK=$(BUILD_DIR)/perl-getopt-long_$(PERL-GETOPT-LONG_VERSION)-$(PERL-GETOPT-LONG_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-GETOPT-LONG_SOURCE):
	$(WGET) -P $(@D) $(PERL-GETOPT-LONG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-getopt-long-source: $(DL_DIR)/$(PERL-GETOPT-LONG_SOURCE) $(PERL-GETOPT-LONG_PATCHES)

$(PERL-GETOPT-LONG_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-GETOPT-LONG_SOURCE) $(PERL-GETOPT-LONG_PATCHES) make/perl-getopt-long.mk
	rm -rf $(BUILD_DIR)/$(PERL-GETOPT-LONG_DIR) $(PERL-GETOPT-LONG_BUILD_DIR)
	$(PERL-GETOPT-LONG_UNZIP) $(DL_DIR)/$(PERL-GETOPT-LONG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-GETOPT-LONG_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-GETOPT-LONG_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-GETOPT-LONG_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-getopt-long-unpack: $(PERL-GETOPT-LONG_BUILD_DIR)/.configured

$(PERL-GETOPT-LONG_BUILD_DIR)/.built: $(PERL-GETOPT-LONG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-getopt-long: $(PERL-GETOPT-LONG_BUILD_DIR)/.built

$(PERL-GETOPT-LONG_BUILD_DIR)/.staged: $(PERL-GETOPT-LONG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-getopt-long-stage: $(PERL-GETOPT-LONG_BUILD_DIR)/.staged

$(PERL-GETOPT-LONG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-getopt-long" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-GETOPT-LONG_PRIORITY)" >>$@
	@echo "Section: $(PERL-GETOPT-LONG_SECTION)" >>$@
	@echo "Version: $(PERL-GETOPT-LONG_VERSION)-$(PERL-GETOPT-LONG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-GETOPT-LONG_MAINTAINER)" >>$@
	@echo "Source: $(PERL-GETOPT-LONG_SITE)/$(PERL-GETOPT-LONG_SOURCE)" >>$@
	@echo "Description: $(PERL-GETOPT-LONG_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-GETOPT-LONG_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-GETOPT-LONG_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-GETOPT-LONG_CONFLICTS)" >>$@

$(PERL-GETOPT-LONG_IPK): $(PERL-GETOPT-LONG_BUILD_DIR)/.built
	rm -rf $(PERL-GETOPT-LONG_IPK_DIR) $(BUILD_DIR)/perl-getopt-long_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-GETOPT-LONG_BUILD_DIR) DESTDIR=$(PERL-GETOPT-LONG_IPK_DIR) install
	find $(PERL-GETOPT-LONG_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-GETOPT-LONG_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-GETOPT-LONG_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-GETOPT-LONG_IPK_DIR)/CONTROL/control
	echo $(PERL-GETOPT-LONG_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-GETOPT-LONG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-GETOPT-LONG_IPK_DIR)

perl-getopt-long-ipk: $(PERL-GETOPT-LONG_IPK)

perl-getopt-long-clean:
	-$(MAKE) -C $(PERL-GETOPT-LONG_BUILD_DIR) clean

perl-getopt-long-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-GETOPT-LONG_DIR) $(PERL-GETOPT-LONG_BUILD_DIR) $(PERL-GETOPT-LONG_IPK_DIR) $(PERL-GETOPT-LONG_IPK)
