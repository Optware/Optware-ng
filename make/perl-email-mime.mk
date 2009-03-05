###########################################################
#
# perl-email-mime
#
###########################################################

PERL-EMAIL-MIME_SITE=http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS
PERL-EMAIL-MIME_VERSION=1.863
PERL-EMAIL-MIME_SOURCE=Email-MIME-$(PERL-EMAIL-MIME_VERSION).tar.gz
PERL-EMAIL-MIME_DIR=Email-MIME-$(PERL-EMAIL-MIME_VERSION)
PERL-EMAIL-MIME_UNZIP=zcat
PERL-EMAIL-MIME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-EMAIL-MIME_DESCRIPTION=Easy MIME message parsing.
PERL-EMAIL-MIME_SECTION=email
PERL-EMAIL-MIME_PRIORITY=optional
PERL-EMAIL-MIME_DEPENDS=perl-mime-contenttype, perl-mime-encodings, perl-email-simple
PERL-EMAIL-MIME_SUGGESTS=
PERL-EMAIL-MIME_CONFLICTS=

PERL-EMAIL-MIME_IPK_VERSION=2

PERL-EMAIL-MIME_CONFFILES=

PERL-EMAIL-MIME_BUILD_DIR=$(BUILD_DIR)/perl-email-mime
PERL-EMAIL-MIME_SOURCE_DIR=$(SOURCE_DIR)/perl-email-mime
PERL-EMAIL-MIME_IPK_DIR=$(BUILD_DIR)/perl-email-mime-$(PERL-EMAIL-MIME_VERSION)-ipk
PERL-EMAIL-MIME_IPK=$(BUILD_DIR)/perl-email-mime_$(PERL-EMAIL-MIME_VERSION)-$(PERL-EMAIL-MIME_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-EMAIL-MIME_SOURCE):
	$(WGET) -P $(@D) $(PERL-EMAIL-MIME_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-email-mime-source: $(DL_DIR)/$(PERL-EMAIL-MIME_SOURCE) $(PERL-EMAIL-MIME_PATCHES)

$(PERL-EMAIL-MIME_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-EMAIL-MIME_SOURCE) $(PERL-EMAIL-MIME_PATCHES) make/perl-email-mime.mk
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-MIME_DIR) $(@D)
	$(PERL-EMAIL-MIME_UNZIP) $(DL_DIR)/$(PERL-EMAIL-MIME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-EMAIL-MIME_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-EMAIL-MIME_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-EMAIL-MIME_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-email-mime-unpack: $(PERL-EMAIL-MIME_BUILD_DIR)/.configured

$(PERL-EMAIL-MIME_BUILD_DIR)/.built: $(PERL-EMAIL-MIME_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-email-mime: $(PERL-EMAIL-MIME_BUILD_DIR)/.built

$(PERL-EMAIL-MIME_BUILD_DIR)/.staged: $(PERL-EMAIL-MIME_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-email-mime-stage: $(PERL-EMAIL-MIME_BUILD_DIR)/.staged

$(PERL-EMAIL-MIME_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-email-mime" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-EMAIL-MIME_PRIORITY)" >>$@
	@echo "Section: $(PERL-EMAIL-MIME_SECTION)" >>$@
	@echo "Version: $(PERL-EMAIL-MIME_VERSION)-$(PERL-EMAIL-MIME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-EMAIL-MIME_MAINTAINER)" >>$@
	@echo "Source: $(PERL-EMAIL-MIME_SITE)/$(PERL-EMAIL-MIME_SOURCE)" >>$@
	@echo "Description: $(PERL-EMAIL-MIME_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-EMAIL-MIME_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-EMAIL-MIME_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-EMAIL-MIME_CONFLICTS)" >>$@

$(PERL-EMAIL-MIME_IPK): $(PERL-EMAIL-MIME_BUILD_DIR)/.built
	rm -rf $(PERL-EMAIL-MIME_IPK_DIR) $(BUILD_DIR)/perl-email-mime_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-EMAIL-MIME_BUILD_DIR) DESTDIR=$(PERL-EMAIL-MIME_IPK_DIR) install
	find $(PERL-EMAIL-MIME_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-EMAIL-MIME_IPK_DIR)/CONTROL/control
	echo $(PERL-EMAIL-MIME_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-EMAIL-MIME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-EMAIL-MIME_IPK_DIR)

perl-email-mime-ipk: $(PERL-EMAIL-MIME_IPK)

perl-email-mime-clean:
	-$(MAKE) -C $(PERL-EMAIL-MIME_BUILD_DIR) clean

perl-email-mime-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-EMAIL-MIME_DIR) $(PERL-EMAIL-MIME_BUILD_DIR) $(PERL-EMAIL-MIME_IPK_DIR) $(PERL-EMAIL-MIME_IPK)
