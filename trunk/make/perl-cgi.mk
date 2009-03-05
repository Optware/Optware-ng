###########################################################
#
# perl-cgi
#
###########################################################

PERL-CGI_SITE=http://search.cpan.org/CPAN/authors/id/L/LD/LDS
PERL-CGI_VERSION=3.42
PERL-CGI_SOURCE=CGI.pm-$(PERL-CGI_VERSION).tar.gz
PERL-CGI_DIR=CGI.pm-$(PERL-CGI_VERSION)
PERL-CGI_UNZIP=zcat
PERL-CGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CGI_DESCRIPTION=Perl module for CGI.
PERL-CGI_SECTION=web
PERL-CGI_PRIORITY=optional
PERL-CGI_DEPENDS=perl
PERL-CGI_SUGGESTS=
PERL-CGI_CONFLICTS=

PERL-CGI_IPK_VERSION=1

PERL-CGI_CONFFILES=

PERL-CGI_BUILD_DIR=$(BUILD_DIR)/perl-cgi
PERL-CGI_SOURCE_DIR=$(SOURCE_DIR)/perl-cgi
PERL-CGI_IPK_DIR=$(BUILD_DIR)/perl-cgi-$(PERL-CGI_VERSION)-ipk
PERL-CGI_IPK=$(BUILD_DIR)/perl-cgi_$(PERL-CGI_VERSION)-$(PERL-CGI_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CGI_SOURCE):
	$(WGET) -P $(@D) $(PERL-CGI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-cgi-source: $(DL_DIR)/$(PERL-CGI_SOURCE) $(PERL-CGI_PATCHES)

$(PERL-CGI_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CGI_SOURCE) $(PERL-CGI_PATCHES) make/perl-cgi.mk
	rm -rf $(BUILD_DIR)/$(PERL-CGI_DIR) $(@D)
	$(PERL-CGI_UNZIP) $(DL_DIR)/$(PERL-CGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CGI_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CGI_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CGI_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-cgi-unpack: $(PERL-CGI_BUILD_DIR)/.configured

$(PERL-CGI_BUILD_DIR)/.built: $(PERL-CGI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-cgi: $(PERL-CGI_BUILD_DIR)/.built

$(PERL-CGI_BUILD_DIR)/.staged: $(PERL-CGI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-cgi-stage: $(PERL-CGI_BUILD_DIR)/.staged

$(PERL-CGI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-cgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CGI_PRIORITY)" >>$@
	@echo "Section: $(PERL-CGI_SECTION)" >>$@
	@echo "Version: $(PERL-CGI_VERSION)-$(PERL-CGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CGI_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CGI_SITE)/$(PERL-CGI_SOURCE)" >>$@
	@echo "Description: $(PERL-CGI_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CGI_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CGI_CONFLICTS)" >>$@

$(PERL-CGI_IPK): $(PERL-CGI_BUILD_DIR)/.built
	rm -rf $(PERL-CGI_IPK_DIR) $(BUILD_DIR)/perl-cgi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CGI_BUILD_DIR) DESTDIR=$(PERL-CGI_IPK_DIR) install
	find $(PERL-CGI_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	$(MAKE) $(PERL-CGI_IPK_DIR)/CONTROL/control
	echo $(PERL-CGI_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CGI_IPK_DIR)

perl-cgi-ipk: $(PERL-CGI_IPK)

perl-cgi-clean:
	-$(MAKE) -C $(PERL-CGI_BUILD_DIR) clean

perl-cgi-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CGI_DIR) $(PERL-CGI_BUILD_DIR) $(PERL-CGI_IPK_DIR) $(PERL-CGI_IPK)
