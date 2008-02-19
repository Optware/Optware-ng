###########################################################
#
# perl-mailtools
#
###########################################################

PERL-MAILTOOLS_SITE=http://search.cpan.org/CPAN/authors/id/M/MA/MARKOV
PERL-MAILTOOLS_VERSION=1.77
PERL-MAILTOOLS_SOURCE=MailTools-$(PERL-MAILTOOLS_VERSION).tar.gz
PERL-MAILTOOLS_DIR=MailTools-$(PERL-MAILTOOLS_VERSION)
PERL-MAILTOOLS_UNZIP=zcat
PERL-MAILTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MAILTOOLS_DESCRIPTION=MailTools - Base class for manipulation of mail header fields
PERL-MAILTOOLS_SECTION=util
PERL-MAILTOOLS_PRIORITY=optional
PERL-MAILTOOLS_DEPENDS=perl
PERL-MAILTOOLS_SUGGESTS=
PERL-MAILTOOLS_CONFLICTS=

PERL-MAILTOOLS_IPK_VERSION=1

PERL-MAILTOOLS_CONFFILES=

PERL-MAILTOOLS_BUILD_DIR=$(BUILD_DIR)/perl-mailtools
PERL-MAILTOOLS_SOURCE_DIR=$(SOURCE_DIR)/perl-mailtools
PERL-MAILTOOLS_IPK_DIR=$(BUILD_DIR)/perl-mailtools-$(PERL-MAILTOOLS_VERSION)-ipk
PERL-MAILTOOLS_IPK=$(BUILD_DIR)/perl-mailtools_$(PERL-MAILTOOLS_VERSION)-$(PERL-MAILTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MAILTOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MAILTOOLS_SITE)/$(PERL-MAILTOOLS_SOURCE)

perl-mailtools-source: $(DL_DIR)/$(PERL-MAILTOOLS_SOURCE) $(PERL-MAILTOOLS_PATCHES)

$(PERL-MAILTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MAILTOOLS_SOURCE) $(PERL-MAILTOOLS_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-MAILTOOLS_DIR) $(PERL-MAILTOOLS_BUILD_DIR)
	$(PERL-MAILTOOLS_UNZIP) $(DL_DIR)/$(PERL-MAILTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-MAILTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-MAILTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MAILTOOLS_DIR) $(PERL-MAILTOOLS_BUILD_DIR)
	(cd $(PERL-MAILTOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-MAILTOOLS_BUILD_DIR)/.configured

perl-mailtools-unpack: $(PERL-MAILTOOLS_BUILD_DIR)/.configured

$(PERL-MAILTOOLS_BUILD_DIR)/.built: $(PERL-MAILTOOLS_BUILD_DIR)/.configured
	rm -f $(PERL-MAILTOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-MAILTOOLS_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-MAILTOOLS_BUILD_DIR)/.built

perl-mailtools: $(PERL-MAILTOOLS_BUILD_DIR)/.built

$(PERL-MAILTOOLS_BUILD_DIR)/.staged: $(PERL-MAILTOOLS_BUILD_DIR)/.built
	rm -f $(PERL-MAILTOOLS_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-MAILTOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-MAILTOOLS_BUILD_DIR)/.staged

perl-mailtools-stage: $(PERL-MAILTOOLS_BUILD_DIR)/.staged

$(PERL-MAILTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-MAILTOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-mailtools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MAILTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PERL-MAILTOOLS_SECTION)" >>$@
	@echo "Version: $(PERL-MAILTOOLS_VERSION)-$(PERL-MAILTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MAILTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MAILTOOLS_SITE)/$(PERL-MAILTOOLS_SOURCE)" >>$@
	@echo "Description: $(PERL-MAILTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MAILTOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MAILTOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MAILTOOLS_CONFLICTS)" >>$@

$(PERL-MAILTOOLS_IPK): $(PERL-MAILTOOLS_BUILD_DIR)/.built
	rm -rf $(PERL-MAILTOOLS_IPK_DIR) $(BUILD_DIR)/perl-mailtools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MAILTOOLS_BUILD_DIR) DESTDIR=$(PERL-MAILTOOLS_IPK_DIR) install
	find $(PERL-MAILTOOLS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MAILTOOLS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MAILTOOLS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-MAILTOOLS_IPK_DIR)/CONTROL/control
	echo $(PERL-MAILTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MAILTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MAILTOOLS_IPK_DIR)

perl-mailtools-ipk: $(PERL-MAILTOOLS_IPK)

perl-mailtools-clean:
	-$(MAKE) -C $(PERL-MAILTOOLS_BUILD_DIR) clean

perl-mailtools-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MAILTOOLS_DIR) $(PERL-MAILTOOLS_BUILD_DIR) $(PERL-MAILTOOLS_IPK_DIR) $(PERL-MAILTOOLS_IPK)
