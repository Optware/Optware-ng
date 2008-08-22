###########################################################
#
# perl-file-next
#
###########################################################

PERL-FILE-NEXT_SITE=http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE
PERL-FILE-NEXT_VERSION=1.02
PERL-FILE-NEXT_SOURCE=File-Next-$(PERL-FILE-NEXT_VERSION).tar.gz
PERL-FILE-NEXT_DIR=File-Next-$(PERL-FILE-NEXT_VERSION)
PERL-FILE-NEXT_UNZIP=zcat
PERL-FILE-NEXT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-FILE-NEXT_DESCRIPTION=File::Next is a lightweight, taint-safe file-finding module. It is lightweight and has no non-core prerequisites.
PERL-FILE-NEXT_SECTION=util
PERL-FILE-NEXT_PRIORITY=optional
PERL-FILE-NEXT_DEPENDS=perl
PERL-FILE-NEXT_SUGGESTS=
PERL-FILE-NEXT_CONFLICTS=

PERL-FILE-NEXT_IPK_VERSION=1

PERL-FILE-NEXT_CONFFILES=

PERL-FILE-NEXT_BUILD_DIR=$(BUILD_DIR)/perl-file-next
PERL-FILE-NEXT_SOURCE_DIR=$(SOURCE_DIR)/perl-file-next
PERL-FILE-NEXT_IPK_DIR=$(BUILD_DIR)/perl-file-next-$(PERL-FILE-NEXT_VERSION)-ipk
PERL-FILE-NEXT_IPK=$(BUILD_DIR)/perl-file-next_$(PERL-FILE-NEXT_VERSION)-$(PERL-FILE-NEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-FILE-NEXT_SOURCE):
	$(WGET) -P $(@D) $(PERL-FILE-NEXT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-file-next-source: $(DL_DIR)/$(PERL-FILE-NEXT_SOURCE) $(PERL-FILE-NEXT_PATCHES)

$(PERL-FILE-NEXT_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-FILE-NEXT_SOURCE) $(PERL-FILE-NEXT_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-FILE-NEXT_DIR) $(PERL-FILE-NEXT_BUILD_DIR)
	$(PERL-FILE-NEXT_UNZIP) $(DL_DIR)/$(PERL-FILE-NEXT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-FILE-NEXT_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-FILE-NEXT_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-FILE-NEXT_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-file-next-unpack: $(PERL-FILE-NEXT_BUILD_DIR)/.configured

$(PERL-FILE-NEXT_BUILD_DIR)/.built: $(PERL-FILE-NEXT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-file-next: $(PERL-FILE-NEXT_BUILD_DIR)/.built

$(PERL-FILE-NEXT_BUILD_DIR)/.staged: $(PERL-FILE-NEXT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-file-next-stage: $(PERL-FILE-NEXT_BUILD_DIR)/.staged

$(PERL-FILE-NEXT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-file-next" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-FILE-NEXT_PRIORITY)" >>$@
	@echo "Section: $(PERL-FILE-NEXT_SECTION)" >>$@
	@echo "Version: $(PERL-FILE-NEXT_VERSION)-$(PERL-FILE-NEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-FILE-NEXT_MAINTAINER)" >>$@
	@echo "Source: $(PERL-FILE-NEXT_SITE)/$(PERL-FILE-NEXT_SOURCE)" >>$@
	@echo "Description: $(PERL-FILE-NEXT_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-FILE-NEXT_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-FILE-NEXT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-FILE-NEXT_CONFLICTS)" >>$@

$(PERL-FILE-NEXT_IPK): $(PERL-FILE-NEXT_BUILD_DIR)/.built
	rm -rf $(PERL-FILE-NEXT_IPK_DIR) $(BUILD_DIR)/perl-file-next_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-FILE-NEXT_BUILD_DIR) DESTDIR=$(PERL-FILE-NEXT_IPK_DIR) install
	find $(PERL-FILE-NEXT_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-FILE-NEXT_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-FILE-NEXT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-FILE-NEXT_IPK_DIR)/CONTROL/control
	echo $(PERL-FILE-NEXT_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-FILE-NEXT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-FILE-NEXT_IPK_DIR)

perl-file-next-ipk: $(PERL-FILE-NEXT_IPK)

perl-file-next-clean:
	-$(MAKE) -C $(PERL-FILE-NEXT_BUILD_DIR) clean

perl-file-next-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-FILE-NEXT_DIR) $(PERL-FILE-NEXT_BUILD_DIR) $(PERL-FILE-NEXT_IPK_DIR) $(PERL-FILE-NEXT_IPK)
