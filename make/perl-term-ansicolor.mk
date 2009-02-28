###########################################################
#
# perl-term-ansicolor
#
###########################################################

PERL-TERM-ANSICOLOR_SITE=http://search.cpan.org/CPAN/authors/id/R/RR/RRA
PERL-TERM-ANSICOLOR_VERSION=1.12
PERL-TERM-ANSICOLOR_SOURCE=ANSIColor-$(PERL-TERM-ANSICOLOR_VERSION).tar.gz
PERL-TERM-ANSICOLOR_DIR=ANSIColor-$(PERL-TERM-ANSICOLOR_VERSION)
PERL-TERM-ANSICOLOR_UNZIP=zcat
PERL-TERM-ANSICOLOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-TERM-ANSICOLOR_DESCRIPTION=Color screen output using ANSI escape sequences.
PERL-TERM-ANSICOLOR_SECTION=util
PERL-TERM-ANSICOLOR_PRIORITY=optional
PERL-TERM-ANSICOLOR_DEPENDS=perl
PERL-TERM-ANSICOLOR_SUGGESTS=
PERL-TERM-ANSICOLOR_CONFLICTS=

PERL-TERM-ANSICOLOR_IPK_VERSION=1

PERL-TERM-ANSICOLOR_CONFFILES=

PERL-TERM-ANSICOLOR_BUILD_DIR=$(BUILD_DIR)/perl-term-ansicolor
PERL-TERM-ANSICOLOR_SOURCE_DIR=$(SOURCE_DIR)/perl-term-ansicolor
PERL-TERM-ANSICOLOR_IPK_DIR=$(BUILD_DIR)/perl-term-ansicolor-$(PERL-TERM-ANSICOLOR_VERSION)-ipk
PERL-TERM-ANSICOLOR_IPK=$(BUILD_DIR)/perl-term-ansicolor_$(PERL-TERM-ANSICOLOR_VERSION)-$(PERL-TERM-ANSICOLOR_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-TERM-ANSICOLOR_SOURCE):
	$(WGET) -P $(@D) $(PERL-TERM-ANSICOLOR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-term-ansicolor-source: $(DL_DIR)/$(PERL-TERM-ANSICOLOR_SOURCE) $(PERL-TERM-ANSICOLOR_PATCHES)

$(PERL-TERM-ANSICOLOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TERM-ANSICOLOR_SOURCE) $(PERL-TERM-ANSICOLOR_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-TERM-ANSICOLOR_DIR) $(PERL-TERM-ANSICOLOR_BUILD_DIR)
	$(PERL-TERM-ANSICOLOR_UNZIP) $(DL_DIR)/$(PERL-TERM-ANSICOLOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-TERM-ANSICOLOR_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-TERM-ANSICOLOR_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-TERM-ANSICOLOR_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-term-ansicolor-unpack: $(PERL-TERM-ANSICOLOR_BUILD_DIR)/.configured

$(PERL-TERM-ANSICOLOR_BUILD_DIR)/.built: $(PERL-TERM-ANSICOLOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-term-ansicolor: $(PERL-TERM-ANSICOLOR_BUILD_DIR)/.built

$(PERL-TERM-ANSICOLOR_BUILD_DIR)/.staged: $(PERL-TERM-ANSICOLOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-term-ansicolor-stage: $(PERL-TERM-ANSICOLOR_BUILD_DIR)/.staged

$(PERL-TERM-ANSICOLOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-term-ansicolor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-TERM-ANSICOLOR_PRIORITY)" >>$@
	@echo "Section: $(PERL-TERM-ANSICOLOR_SECTION)" >>$@
	@echo "Version: $(PERL-TERM-ANSICOLOR_VERSION)-$(PERL-TERM-ANSICOLOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-TERM-ANSICOLOR_MAINTAINER)" >>$@
	@echo "Source: $(PERL-TERM-ANSICOLOR_SITE)/$(PERL-TERM-ANSICOLOR_SOURCE)" >>$@
	@echo "Description: $(PERL-TERM-ANSICOLOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-TERM-ANSICOLOR_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-TERM-ANSICOLOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-TERM-ANSICOLOR_CONFLICTS)" >>$@

$(PERL-TERM-ANSICOLOR_IPK): $(PERL-TERM-ANSICOLOR_BUILD_DIR)/.built
	rm -rf $(PERL-TERM-ANSICOLOR_IPK_DIR) $(BUILD_DIR)/perl-term-ansicolor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-TERM-ANSICOLOR_BUILD_DIR) DESTDIR=$(PERL-TERM-ANSICOLOR_IPK_DIR) install
	find $(PERL-TERM-ANSICOLOR_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-TERM-ANSICOLOR_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-TERM-ANSICOLOR_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-TERM-ANSICOLOR_IPK_DIR)/CONTROL/control
	echo $(PERL-TERM-ANSICOLOR_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TERM-ANSICOLOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TERM-ANSICOLOR_IPK_DIR)

perl-term-ansicolor-ipk: $(PERL-TERM-ANSICOLOR_IPK)

perl-term-ansicolor-clean:
	-$(MAKE) -C $(PERL-TERM-ANSICOLOR_BUILD_DIR) clean

perl-term-ansicolor-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TERM-ANSICOLOR_DIR) $(PERL-TERM-ANSICOLOR_BUILD_DIR) $(PERL-TERM-ANSICOLOR_IPK_DIR) $(PERL-TERM-ANSICOLOR_IPK)
