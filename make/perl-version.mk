###########################################################
#
# perl-version
#
###########################################################

PERL-VERSION_SITE=http://search.cpan.org/CPAN/authors/id/J/JP/JPEACOCK
PERL-VERSION_VERSION=0.74
PERL-VERSION_SOURCE=version-$(PERL-VERSION_VERSION).tar.gz
PERL-VERSION_DIR=version-$(PERL-VERSION_VERSION)
PERL-VERSION_UNZIP=zcat
PERL-VERSION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-VERSION_DESCRIPTION=version - Perl extension for Version Objects.
PERL-VERSION_SECTION=util
PERL-VERSION_PRIORITY=optional
PERL-VERSION_DEPENDS=perl, perl-module-build
PERL-VERSION_SUGGESTS=
PERL-VERSION_CONFLICTS=

PERL-VERSION_IPK_VERSION=1

PERL-VERSION_CONFFILES=

PERL-VERSION_BUILD_DIR=$(BUILD_DIR)/perl-version
PERL-VERSION_SOURCE_DIR=$(SOURCE_DIR)/perl-version
PERL-VERSION_IPK_DIR=$(BUILD_DIR)/perl-version-$(PERL-VERSION_VERSION)-ipk
PERL-VERSION_IPK=$(BUILD_DIR)/perl-version_$(PERL-VERSION_VERSION)-$(PERL-VERSION_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-VERSION_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-VERSION_SITE)/$(PERL-VERSION_SOURCE)

perl-version-source: $(DL_DIR)/$(PERL-VERSION_SOURCE) $(PERL-VERSION_PATCHES)

$(PERL-VERSION_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-VERSION_SOURCE) $(PERL-VERSION_PATCHES)
	$(MAKE) perl-module-build-stage
	rm -rf $(BUILD_DIR)/$(PERL-VERSION_DIR) $(PERL-VERSION_BUILD_DIR)
	$(PERL-VERSION_UNZIP) $(DL_DIR)/$(PERL-VERSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-VERSION_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-VERSION_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-VERSION_DIR) $(PERL-VERSION_BUILD_DIR)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Build.PL \
		--config cc=$(TARGET_CC) \
		--config ld=$(TARGET_CC) \
	)
	touch $@

perl-version-unpack: $(PERL-VERSION_BUILD_DIR)/.configured

$(PERL-VERSION_BUILD_DIR)/.built: $(PERL-VERSION_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		./Build \
	)
	touch $@

perl-version: $(PERL-VERSION_BUILD_DIR)/.built

$(PERL-VERSION_BUILD_DIR)/.staged: $(PERL-VERSION_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D); \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		./Build --prefix $(STAGING_DIR)/opt install \
	)
	touch $@

perl-version-stage: $(PERL-VERSION_BUILD_DIR)/.staged

$(PERL-VERSION_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-version" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-VERSION_PRIORITY)" >>$@
	@echo "Section: $(PERL-VERSION_SECTION)" >>$@
	@echo "Version: $(PERL-VERSION_VERSION)-$(PERL-VERSION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-VERSION_MAINTAINER)" >>$@
	@echo "Source: $(PERL-VERSION_SITE)/$(PERL-VERSION_SOURCE)" >>$@
	@echo "Description: $(PERL-VERSION_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-VERSION_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-VERSION_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-VERSION_CONFLICTS)" >>$@

$(PERL-VERSION_IPK): $(PERL-VERSION_BUILD_DIR)/.built
	rm -rf $(PERL-VERSION_IPK_DIR) $(BUILD_DIR)/perl-version_*_$(TARGET_ARCH).ipk
	(cd $(PERL-VERSION_BUILD_DIR); \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		./Build --prefix $(PERL-VERSION_IPK_DIR)/opt install \
	)
	find $(PERL-VERSION_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-VERSION_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-VERSION_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-VERSION_IPK_DIR)/CONTROL/control
	echo $(PERL-VERSION_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-VERSION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-VERSION_IPK_DIR)

perl-version-ipk: $(PERL-VERSION_IPK)

perl-version-clean:
	-$(MAKE) -C $(PERL-VERSION_BUILD_DIR) clean

perl-version-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-VERSION_DIR) $(PERL-VERSION_BUILD_DIR) $(PERL-VERSION_IPK_DIR) $(PERL-VERSION_IPK)
