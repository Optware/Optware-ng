###########################################################
#
# perl-encode-detect
#
###########################################################

PERL-ENCODE-DETECT_SITE=http://search.cpan.org/CPAN/authors/id/J/JG/JGMYERS
PERL-ENCODE-DETECT_VERSION=1.00
PERL-ENCODE-DETECT_SOURCE=Encode-Detect-$(PERL-ENCODE-DETECT_VERSION).tar.gz
PERL-ENCODE-DETECT_DIR=Encode-Detect-$(PERL-ENCODE-DETECT_VERSION)
PERL-ENCODE-DETECT_UNZIP=zcat
PERL-ENCODE-DETECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-ENCODE-DETECT_DESCRIPTION=Detects the encoding of data.
PERL-ENCODE-DETECT_SECTION=util
PERL-ENCODE-DETECT_PRIORITY=optional
PERL-ENCODE-DETECT_DEPENDS=
PERL-ENCODE-DETECT_SUGGESTS=
PERL-ENCODE-DETECT_CONFLICTS=

PERL-ENCODE-DETECT_IPK_VERSION=1

PERL-ENCODE-DETECT_CONFFILES=

PERL-ENCODE-DETECT_BUILD_DIR=$(BUILD_DIR)/perl-encode-detect
PERL-ENCODE-DETECT_SOURCE_DIR=$(SOURCE_DIR)/perl-encode-detect
PERL-ENCODE-DETECT_IPK_DIR=$(BUILD_DIR)/perl-encode-detect-$(PERL-ENCODE-DETECT_VERSION)-ipk
PERL-ENCODE-DETECT_IPK=$(BUILD_DIR)/perl-encode-detect_$(PERL-ENCODE-DETECT_VERSION)-$(PERL-ENCODE-DETECT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-ENCODE-DETECT_SOURCE):
	$(WGET) -P $(@D) $(PERL-ENCODE-DETECT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-encode-detect-source: $(DL_DIR)/$(PERL-ENCODE-DETECT_SOURCE) $(PERL-ENCODE-DETECT_PATCHES)

$(PERL-ENCODE-DETECT_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-ENCODE-DETECT_SOURCE) $(PERL-ENCODE-DETECT_PATCHES)
	$(MAKE) perl-module-build-stage
	rm -rf $(BUILD_DIR)/$(PERL-ENCODE-DETECT_DIR) $(@D)
	$(PERL-ENCODE-DETECT_UNZIP) $(DL_DIR)/$(PERL-ENCODE-DETECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-ENCODE-DETECT_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-ENCODE-DETECT_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-ENCODE-DETECT_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Build.PL \
		--config cc=$(TARGET_CC) \
		--config ld=$(TARGET_CC) \
	)
	touch $@

perl-encode-detect-unpack: $(PERL-ENCODE-DETECT_BUILD_DIR)/.configured

$(PERL-ENCODE-DETECT_BUILD_DIR)/.built: $(PERL-ENCODE-DETECT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		./Build \
	)
	touch $@

perl-encode-detect: $(PERL-ENCODE-DETECT_BUILD_DIR)/.built

$(PERL-ENCODE-DETECT_BUILD_DIR)/.staged: $(PERL-ENCODE-DETECT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-encode-detect-stage: $(PERL-ENCODE-DETECT_BUILD_DIR)/.staged

$(PERL-ENCODE-DETECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-encode-detect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-ENCODE-DETECT_PRIORITY)" >>$@
	@echo "Section: $(PERL-ENCODE-DETECT_SECTION)" >>$@
	@echo "Version: $(PERL-ENCODE-DETECT_VERSION)-$(PERL-ENCODE-DETECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-ENCODE-DETECT_MAINTAINER)" >>$@
	@echo "Source: $(PERL-ENCODE-DETECT_SITE)/$(PERL-ENCODE-DETECT_SOURCE)" >>$@
	@echo "Description: $(PERL-ENCODE-DETECT_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-ENCODE-DETECT_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-ENCODE-DETECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-ENCODE-DETECT_CONFLICTS)" >>$@

$(PERL-ENCODE-DETECT_IPK): $(PERL-ENCODE-DETECT_BUILD_DIR)/.built
	rm -rf $(PERL-ENCODE-DETECT_IPK_DIR) $(BUILD_DIR)/perl-encode-detect_*_$(TARGET_ARCH).ipk
	(cd $(PERL-ENCODE-DETECT_BUILD_DIR); \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		./Build --prefix $(PERL-ENCODE-DETECT_IPK_DIR)/opt install \
	)
	find $(PERL-ENCODE-DETECT_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-ENCODE-DETECT_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-ENCODE-DETECT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-ENCODE-DETECT_IPK_DIR)/CONTROL/control
	echo $(PERL-ENCODE-DETECT_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-ENCODE-DETECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-ENCODE-DETECT_IPK_DIR)

perl-encode-detect-ipk: $(PERL-ENCODE-DETECT_IPK)

perl-encode-detect-clean:
	-$(MAKE) -C $(PERL-ENCODE-DETECT_BUILD_DIR) clean

perl-encode-detect-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-ENCODE-DETECT_DIR) $(PERL-ENCODE-DETECT_BUILD_DIR) $(PERL-ENCODE-DETECT_IPK_DIR) $(PERL-ENCODE-DETECT_IPK)

perl-encode-detect-check: $(PERL-ENCODE-DETECT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-ENCODE-DETECT_IPK)
