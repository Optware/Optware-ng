###########################################################
#
# perl-text-diff
#
###########################################################

PERL-TEXT-DIFF_SITE=http://search.cpan.org/CPAN/authors/id/R/RB/RBS
PERL-TEXT-DIFF_VERSION=0.35
PERL-TEXT-DIFF_SOURCE=Text-Diff-$(PERL-TEXT-DIFF_VERSION).tar.gz
PERL-TEXT-DIFF_DIR=Text-Diff-$(PERL-TEXT-DIFF_VERSION)
PERL-TEXT-DIFF_UNZIP=zcat
PERL-TEXT-DIFF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-TEXT-DIFF_DESCRIPTION=Text-Diff - Perform diffs on files and record sets.
PERL-TEXT-DIFF_SECTION=util
PERL-TEXT-DIFF_PRIORITY=optional
PERL-TEXT-DIFF_DEPENDS=perl, perl-algorithm-diff
PERL-TEXT-DIFF_SUGGESTS=
PERL-TEXT-DIFF_CONFLICTS=

PERL-TEXT-DIFF_IPK_VERSION=1

PERL-TEXT-DIFF_CONFFILES=

PERL-TEXT-DIFF_BUILD_DIR=$(BUILD_DIR)/perl-text-diff
PERL-TEXT-DIFF_SOURCE_DIR=$(SOURCE_DIR)/perl-text-diff
PERL-TEXT-DIFF_IPK_DIR=$(BUILD_DIR)/perl-text-diff-$(PERL-TEXT-DIFF_VERSION)-ipk
PERL-TEXT-DIFF_IPK=$(BUILD_DIR)/perl-text-diff_$(PERL-TEXT-DIFF_VERSION)-$(PERL-TEXT-DIFF_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-TEXT-DIFF_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-TEXT-DIFF_SITE)/$(PERL-TEXT-DIFF_SOURCE)

perl-text-diff-source: $(DL_DIR)/$(PERL-TEXT-DIFF_SOURCE) $(PERL-TEXT-DIFF_PATCHES)

$(PERL-TEXT-DIFF_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TEXT-DIFF_SOURCE) $(PERL-TEXT-DIFF_PATCHES)
	$(MAKE) perl-algorithm-diff-stage
	rm -rf $(BUILD_DIR)/$(PERL-TEXT-DIFF_DIR) $(PERL-TEXT-DIFF_BUILD_DIR)
	$(PERL-TEXT-DIFF_UNZIP) $(DL_DIR)/$(PERL-TEXT-DIFF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-TEXT-DIFF_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-TEXT-DIFF_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-TEXT-DIFF_DIR) $(PERL-TEXT-DIFF_BUILD_DIR)
	(cd $(PERL-TEXT-DIFF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-TEXT-DIFF_BUILD_DIR)/.configured

perl-text-diff-unpack: $(PERL-TEXT-DIFF_BUILD_DIR)/.configured

$(PERL-TEXT-DIFF_BUILD_DIR)/.built: $(PERL-TEXT-DIFF_BUILD_DIR)/.configured
	rm -f $(PERL-TEXT-DIFF_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-TEXT-DIFF_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-TEXT-DIFF_BUILD_DIR)/.built

perl-text-diff: $(PERL-TEXT-DIFF_BUILD_DIR)/.built

$(PERL-TEXT-DIFF_BUILD_DIR)/.staged: $(PERL-TEXT-DIFF_BUILD_DIR)/.built
	rm -f $(PERL-TEXT-DIFF_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-TEXT-DIFF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-TEXT-DIFF_BUILD_DIR)/.staged

perl-text-diff-stage: $(PERL-TEXT-DIFF_BUILD_DIR)/.staged

$(PERL-TEXT-DIFF_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-TEXT-DIFF_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-text-diff" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-TEXT-DIFF_PRIORITY)" >>$@
	@echo "Section: $(PERL-TEXT-DIFF_SECTION)" >>$@
	@echo "Version: $(PERL-TEXT-DIFF_VERSION)-$(PERL-TEXT-DIFF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-TEXT-DIFF_MAINTAINER)" >>$@
	@echo "Source: $(PERL-TEXT-DIFF_SITE)/$(PERL-TEXT-DIFF_SOURCE)" >>$@
	@echo "Description: $(PERL-TEXT-DIFF_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-TEXT-DIFF_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-TEXT-DIFF_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-TEXT-DIFF_CONFLICTS)" >>$@

$(PERL-TEXT-DIFF_IPK): $(PERL-TEXT-DIFF_BUILD_DIR)/.built
	rm -rf $(PERL-TEXT-DIFF_IPK_DIR) $(BUILD_DIR)/perl-text-diff_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-TEXT-DIFF_BUILD_DIR) DESTDIR=$(PERL-TEXT-DIFF_IPK_DIR) install
	find $(PERL-TEXT-DIFF_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-TEXT-DIFF_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-TEXT-DIFF_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-TEXT-DIFF_IPK_DIR)/CONTROL/control
	echo $(PERL-TEXT-DIFF_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TEXT-DIFF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TEXT-DIFF_IPK_DIR)

perl-text-diff-ipk: $(PERL-TEXT-DIFF_IPK)

perl-text-diff-clean:
	-$(MAKE) -C $(PERL-TEXT-DIFF_BUILD_DIR) clean

perl-text-diff-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TEXT-DIFF_DIR) $(PERL-TEXT-DIFF_BUILD_DIR) $(PERL-TEXT-DIFF_IPK_DIR) $(PERL-TEXT-DIFF_IPK)
