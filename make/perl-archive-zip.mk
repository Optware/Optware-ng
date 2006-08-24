###########################################################
#
# perl-archive-zip
#
###########################################################

PERL-ARCHIVE-ZIP_SITE=http://search.cpan.org/CPAN/authors/id/S/SM/SMPETERS
PERL-ARCHIVE-ZIP_VERSION=1.16
PERL-ARCHIVE-ZIP_SOURCE=Archive-Zip-$(PERL-ARCHIVE-ZIP_VERSION).tar.gz
PERL-ARCHIVE-ZIP_DIR=Archive-Zip-$(PERL-ARCHIVE-ZIP_VERSION)
PERL-ARCHIVE-ZIP_UNZIP=zcat
PERL-ARCHIVE-ZIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-ARCHIVE-ZIP_DESCRIPTION=Archive-Zip - Provide an interface to ZIP archive files. 
PERL-ARCHIVE-ZIP_SECTION=util
PERL-ARCHIVE-ZIP_PRIORITY=optional
PERL-ARCHIVE-ZIP_DEPENDS=perl, perl-compress-zlib
PERL-ARCHIVE-ZIP_SUGGESTS=
PERL-ARCHIVE-ZIP_CONFLICTS=

PERL-ARCHIVE-ZIP_IPK_VERSION=2

PERL-ARCHIVE-ZIP_CONFFILES=

PERL-ARCHIVE-ZIP_BUILD_DIR=$(BUILD_DIR)/perl-archive-zip
PERL-ARCHIVE-ZIP_SOURCE_DIR=$(SOURCE_DIR)/perl-archive-zip
PERL-ARCHIVE-ZIP_IPK_DIR=$(BUILD_DIR)/perl-archive-zip-$(PERL-ARCHIVE-ZIP_VERSION)-ipk
PERL-ARCHIVE-ZIP_IPK=$(BUILD_DIR)/perl-archive-zip_$(PERL-ARCHIVE-ZIP_VERSION)-$(PERL-ARCHIVE-ZIP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-ARCHIVE-ZIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-ARCHIVE-ZIP_SITE)/$(PERL-ARCHIVE-ZIP_SOURCE)

perl-archive-zip-source: $(DL_DIR)/$(PERL-ARCHIVE-ZIP_SOURCE) $(PERL-ARCHIVE-ZIP_PATCHES)

$(PERL-ARCHIVE-ZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-ARCHIVE-ZIP_SOURCE) $(PERL-ARCHIVE-ZIP_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-ARCHIVE-ZIP_DIR) $(PERL-ARCHIVE-ZIP_BUILD_DIR)
	$(PERL-ARCHIVE-ZIP_UNZIP) $(DL_DIR)/$(PERL-ARCHIVE-ZIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-ARCHIVE-ZIP_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-ARCHIVE-ZIP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-ARCHIVE-ZIP_DIR) $(PERL-ARCHIVE-ZIP_BUILD_DIR)
	(cd $(PERL-ARCHIVE-ZIP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.configured

perl-archive-zip-unpack: $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.configured

$(PERL-ARCHIVE-ZIP_BUILD_DIR)/.built: $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.configured
	rm -f $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-ARCHIVE-ZIP_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.built

perl-archive-zip: $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.built

$(PERL-ARCHIVE-ZIP_BUILD_DIR)/.staged: $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.built
	rm -f $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-ARCHIVE-ZIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.staged

perl-archive-zip-stage: $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.staged

$(PERL-ARCHIVE-ZIP_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-ARCHIVE-ZIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-archive-zip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-ARCHIVE-ZIP_PRIORITY)" >>$@
	@echo "Section: $(PERL-ARCHIVE-ZIP_SECTION)" >>$@
	@echo "Version: $(PERL-ARCHIVE-ZIP_VERSION)-$(PERL-ARCHIVE-ZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-ARCHIVE-ZIP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-ARCHIVE-ZIP_SITE)/$(PERL-ARCHIVE-ZIP_SOURCE)" >>$@
	@echo "Description: $(PERL-ARCHIVE-ZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-ARCHIVE-ZIP_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-ARCHIVE-ZIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-ARCHIVE-ZIP_CONFLICTS)" >>$@

$(PERL-ARCHIVE-ZIP_IPK): $(PERL-ARCHIVE-ZIP_BUILD_DIR)/.built
	rm -rf $(PERL-ARCHIVE-ZIP_IPK_DIR) $(BUILD_DIR)/perl-archive-zip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-ARCHIVE-ZIP_BUILD_DIR) DESTDIR=$(PERL-ARCHIVE-ZIP_IPK_DIR) install
	find $(PERL-ARCHIVE-ZIP_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-ARCHIVE-ZIP_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-ARCHIVE-ZIP_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-ARCHIVE-ZIP_IPK_DIR)/CONTROL/control
	echo $(PERL-ARCHIVE-ZIP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-ARCHIVE-ZIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-ARCHIVE-ZIP_IPK_DIR)

perl-archive-zip-ipk: $(PERL-ARCHIVE-ZIP_IPK)

perl-archive-zip-clean:
	-$(MAKE) -C $(PERL-ARCHIVE-ZIP_BUILD_DIR) clean

perl-archive-zip-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-ARCHIVE-ZIP_DIR) $(PERL-ARCHIVE-ZIP_BUILD_DIR) $(PERL-ARCHIVE-ZIP_IPK_DIR) $(PERL-ARCHIVE-ZIP_IPK)
