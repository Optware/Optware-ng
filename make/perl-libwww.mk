###########################################################
#
# perl-libwww
#
###########################################################

PERL-LIBWWW_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-LIBWWW_VERSION=5.825
PERL-LIBWWW_SOURCE=libwww-perl-$(PERL-LIBWWW_VERSION).tar.gz
PERL-LIBWWW_DIR=libwww-perl-$(PERL-LIBWWW_VERSION)
PERL-LIBWWW_UNZIP=zcat
PERL-LIBWWW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-LIBWWW_DESCRIPTION=libwww-perl - The World-Wide Web library for Perl 
PERL-LIBWWW_SECTION=util
PERL-LIBWWW_PRIORITY=optional
PERL-LIBWWW_DEPENDS=perl, perl-uri, perl-compress-zlib, perl-html-parser
PERL-LIBWWW_SUGGESTS=
PERL-LIBWWW_CONFLICTS=

PERL-LIBWWW_IPK_VERSION=1

PERL-LIBWWW_CONFFILES=

PERL-LIBWWW_BUILD_DIR=$(BUILD_DIR)/perl-libwww
PERL-LIBWWW_SOURCE_DIR=$(SOURCE_DIR)/perl-libwww
PERL-LIBWWW_IPK_DIR=$(BUILD_DIR)/perl-libwww-$(PERL-LIBWWW_VERSION)-ipk
PERL-LIBWWW_IPK=$(BUILD_DIR)/perl-libwww_$(PERL-LIBWWW_VERSION)-$(PERL-LIBWWW_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-LIBWWW_SOURCE):
	$(WGET) -P $(@D) $(PERL-LIBWWW_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-libwww-source: $(DL_DIR)/$(PERL-LIBWWW_SOURCE) $(PERL-LIBWWW_PATCHES)

$(PERL-LIBWWW_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-LIBWWW_SOURCE) $(PERL-LIBWWW_PATCHES) make/perl-libwww.mk
	$(MAKE) perl-uri-stage perl-compress-zlib-stage perl-html-parser-stage
	rm -rf $(BUILD_DIR)/$(PERL-LIBWWW_DIR) $(PERL-LIBWWW_BUILD_DIR)
	$(PERL-LIBWWW_UNZIP) $(DL_DIR)/$(PERL-LIBWWW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-LIBWWW_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-LIBWWW_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-LIBWWW_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-libwww-unpack: $(PERL-LIBWWW_BUILD_DIR)/.configured

$(PERL-LIBWWW_BUILD_DIR)/.built: $(PERL-LIBWWW_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-libwww: $(PERL-LIBWWW_BUILD_DIR)/.built

$(PERL-LIBWWW_BUILD_DIR)/.staged: $(PERL-LIBWWW_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-libwww-stage: $(PERL-LIBWWW_BUILD_DIR)/.staged

$(PERL-LIBWWW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-libwww" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-LIBWWW_PRIORITY)" >>$@
	@echo "Section: $(PERL-LIBWWW_SECTION)" >>$@
	@echo "Version: $(PERL-LIBWWW_VERSION)-$(PERL-LIBWWW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-LIBWWW_MAINTAINER)" >>$@
	@echo "Source: $(PERL-LIBWWW_SITE)/$(PERL-LIBWWW_SOURCE)" >>$@
	@echo "Description: $(PERL-LIBWWW_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-LIBWWW_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-LIBWWW_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-LIBWWW_CONFLICTS)" >>$@

$(PERL-LIBWWW_IPK): $(PERL-LIBWWW_BUILD_DIR)/.built
	rm -rf $(PERL-LIBWWW_IPK_DIR) $(BUILD_DIR)/perl-libwww_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-LIBWWW_BUILD_DIR) DESTDIR=$(PERL-LIBWWW_IPK_DIR) install
	find $(PERL-LIBWWW_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-LIBWWW_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-LIBWWW_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-LIBWWW_IPK_DIR)/CONTROL/control
	echo $(PERL-LIBWWW_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-LIBWWW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-LIBWWW_IPK_DIR)

perl-libwww-ipk: $(PERL-LIBWWW_IPK)

perl-libwww-clean:
	-$(MAKE) -C $(PERL-LIBWWW_BUILD_DIR) clean

perl-libwww-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-LIBWWW_DIR) $(PERL-LIBWWW_BUILD_DIR) $(PERL-LIBWWW_IPK_DIR) $(PERL-LIBWWW_IPK)
