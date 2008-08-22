###########################################################
#
# perl-compress-zlib
#
###########################################################

PERL-COMPRESS-ZLIB_SITE=http://search.cpan.org/CPAN/authors/id/P/PM/PMQS
PERL-COMPRESS-ZLIB_VERSION=1.42
PERL-COMPRESS-ZLIB_SOURCE=Compress-Zlib-$(PERL-COMPRESS-ZLIB_VERSION).tar.gz
PERL-COMPRESS-ZLIB_DIR=Compress-Zlib-$(PERL-COMPRESS-ZLIB_VERSION)
PERL-COMPRESS-ZLIB_UNZIP=zcat
PERL-COMPRESS-ZLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-COMPRESS-ZLIB_DESCRIPTION=Compress-Zlib - Interface to zlib compression library.
PERL-COMPRESS-ZLIB_SECTION=util
PERL-COMPRESS-ZLIB_PRIORITY=optional
PERL-COMPRESS-ZLIB_DEPENDS=zlib, perl
PERL-COMPRESS-ZLIB_SUGGESTS=
PERL-COMPRESS-ZLIB_CONFLICTS=

PERL-COMPRESS-ZLIB_IPK_VERSION=3

PERL-COMPRESS-ZLIB_CONFFILES=

PERL-COMPRESS-ZLIB_BUILD_DIR=$(BUILD_DIR)/perl-compress-zlib
PERL-COMPRESS-ZLIB_SOURCE_DIR=$(SOURCE_DIR)/perl-compress-zlib
PERL-COMPRESS-ZLIB_IPK_DIR=$(BUILD_DIR)/perl-compress-zlib-$(PERL-COMPRESS-ZLIB_VERSION)-ipk
PERL-COMPRESS-ZLIB_IPK=$(BUILD_DIR)/perl-compress-zlib_$(PERL-COMPRESS-ZLIB_VERSION)-$(PERL-COMPRESS-ZLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-COMPRESS-ZLIB_SOURCE):
	$(WGET) -P $(@D) $(PERL-COMPRESS-ZLIB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-compress-zlib-source: $(DL_DIR)/$(PERL-COMPRESS-ZLIB_SOURCE) $(PERL-COMPRESS-ZLIB_PATCHES)

$(PERL-COMPRESS-ZLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-COMPRESS-ZLIB_SOURCE) $(PERL-COMPRESS-ZLIB_PATCHES)
	$(MAKE) perl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(PERL-COMPRESS-ZLIB_DIR) $(PERL-COMPRESS-ZLIB_BUILD_DIR)
	$(PERL-COMPRESS-ZLIB_UNZIP) $(DL_DIR)/$(PERL-COMPRESS-ZLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-COMPRESS-ZLIB_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-COMPRESS-ZLIB_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-COMPRESS-ZLIB_DIR) $(PERL-COMPRESS-ZLIB_BUILD_DIR)
	(cd $(PERL-COMPRESS-ZLIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-compress-zlib-unpack: $(PERL-COMPRESS-ZLIB_BUILD_DIR)/.configured

$(PERL-COMPRESS-ZLIB_BUILD_DIR)/.built: $(PERL-COMPRESS-ZLIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-COMPRESS-ZLIB_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-compress-zlib: $(PERL-COMPRESS-ZLIB_BUILD_DIR)/.built

$(PERL-COMPRESS-ZLIB_BUILD_DIR)/.staged: $(PERL-COMPRESS-ZLIB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-COMPRESS-ZLIB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-compress-zlib-stage: $(PERL-COMPRESS-ZLIB_BUILD_DIR)/.staged

$(PERL-COMPRESS-ZLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-compress-zlib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-COMPRESS-ZLIB_PRIORITY)" >>$@
	@echo "Section: $(PERL-COMPRESS-ZLIB_SECTION)" >>$@
	@echo "Version: $(PERL-COMPRESS-ZLIB_VERSION)-$(PERL-COMPRESS-ZLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-COMPRESS-ZLIB_MAINTAINER)" >>$@
	@echo "Source: $(PERL-COMPRESS-ZLIB_SITE)/$(PERL-COMPRESS-ZLIB_SOURCE)" >>$@
	@echo "Description: $(PERL-COMPRESS-ZLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-COMPRESS-ZLIB_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-COMPRESS-ZLIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-COMPRESS-ZLIB_CONFLICTS)" >>$@

$(PERL-COMPRESS-ZLIB_IPK): $(PERL-COMPRESS-ZLIB_BUILD_DIR)/.built
	rm -rf $(PERL-COMPRESS-ZLIB_IPK_DIR) $(BUILD_DIR)/perl-compress-zlib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-COMPRESS-ZLIB_BUILD_DIR) DESTDIR=$(PERL-COMPRESS-ZLIB_IPK_DIR) install
ifeq (5.10, $(PERL_MAJOR_VER))
	rm -f $(PERL-COMPRESS-ZLIB_IPK_DIR)/opt/man/man3/Compress::Zlib.3
endif
	find $(PERL-COMPRESS-ZLIB_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-COMPRESS-ZLIB_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-COMPRESS-ZLIB_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-COMPRESS-ZLIB_IPK_DIR)/CONTROL/control
	echo $(PERL-COMPRESS-ZLIB_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-COMPRESS-ZLIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-COMPRESS-ZLIB_IPK_DIR)

perl-compress-zlib-ipk: $(PERL-COMPRESS-ZLIB_IPK)

perl-compress-zlib-clean:
	-$(MAKE) -C $(PERL-COMPRESS-ZLIB_BUILD_DIR) clean

perl-compress-zlib-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-COMPRESS-ZLIB_DIR) $(PERL-COMPRESS-ZLIB_BUILD_DIR) $(PERL-COMPRESS-ZLIB_IPK_DIR) $(PERL-COMPRESS-ZLIB_IPK)
