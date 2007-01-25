###########################################################
#
# perl-convert-uulib
#
###########################################################

PERL-CONVERT-UULIB_SITE=http://search.cpan.org/CPAN/authors/id/M/ML/MLEHMANN
PERL-CONVERT-UULIB_VERSION=1.08
PERL-CONVERT-UULIB_SOURCE=Convert-UUlib-$(PERL-CONVERT-UULIB_VERSION).tar.gz
PERL-CONVERT-UULIB_DIR=Convert-UUlib-$(PERL-CONVERT-UULIB_VERSION)
PERL-CONVERT-UULIB_UNZIP=zcat
PERL-CONVERT-UULIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-CONVERT-UULIB_DESCRIPTION=Convert-UUlib - Perl interface to the uulib library (a.k.a. uudeview/uuenview). 
PERL-CONVERT-UULIB_SECTION=util
PERL-CONVERT-UULIB_PRIORITY=optional
PERL-CONVERT-UULIB_DEPENDS=perl
PERL-CONVERT-UULIB_SUGGESTS=
PERL-CONVERT-UULIB_CONFLICTS=

PERL-CONVERT-UULIB_IPK_VERSION=1

PERL-CONVERT-UULIB_CONFFILES=

PERL-CONVERT-UULIB_BUILD_DIR=$(BUILD_DIR)/perl-convert-uulib
PERL-CONVERT-UULIB_SOURCE_DIR=$(SOURCE_DIR)/perl-convert-uulib
PERL-CONVERT-UULIB_IPK_DIR=$(BUILD_DIR)/perl-convert-uulib-$(PERL-CONVERT-UULIB_VERSION)-ipk
PERL-CONVERT-UULIB_IPK=$(BUILD_DIR)/perl-convert-uulib_$(PERL-CONVERT-UULIB_VERSION)-$(PERL-CONVERT-UULIB_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-CONVERT-UULIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-CONVERT-UULIB_SITE)/$(PERL-CONVERT-UULIB_SOURCE)

perl-convert-uulib-source: $(DL_DIR)/$(PERL-CONVERT-UULIB_SOURCE) $(PERL-CONVERT-UULIB_PATCHES)

$(PERL-CONVERT-UULIB_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-CONVERT-UULIB_SOURCE) $(PERL-CONVERT-UULIB_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-CONVERT-UULIB_DIR) $(PERL-CONVERT-UULIB_BUILD_DIR)
	$(PERL-CONVERT-UULIB_UNZIP) $(DL_DIR)/$(PERL-CONVERT-UULIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-CONVERT-UULIB_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-CONVERT-UULIB_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-CONVERT-UULIB_DIR) $(PERL-CONVERT-UULIB_BUILD_DIR)
	(cd $(PERL-CONVERT-UULIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-CONVERT-UULIB_BUILD_DIR)/.configured

perl-convert-uulib-unpack: $(PERL-CONVERT-UULIB_BUILD_DIR)/.configured

$(PERL-CONVERT-UULIB_BUILD_DIR)/.built: $(PERL-CONVERT-UULIB_BUILD_DIR)/.configured
	rm -f $(PERL-CONVERT-UULIB_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-CONVERT-UULIB_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-CONVERT-UULIB_BUILD_DIR)/.built

perl-convert-uulib: $(PERL-CONVERT-UULIB_BUILD_DIR)/.built

$(PERL-CONVERT-UULIB_BUILD_DIR)/.staged: $(PERL-CONVERT-UULIB_BUILD_DIR)/.built
	rm -f $(PERL-CONVERT-UULIB_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-CONVERT-UULIB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-CONVERT-UULIB_BUILD_DIR)/.staged

perl-convert-uulib-stage: $(PERL-CONVERT-UULIB_BUILD_DIR)/.staged

$(PERL-CONVERT-UULIB_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-CONVERT-UULIB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-convert-uulib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-CONVERT-UULIB_PRIORITY)" >>$@
	@echo "Section: $(PERL-CONVERT-UULIB_SECTION)" >>$@
	@echo "Version: $(PERL-CONVERT-UULIB_VERSION)-$(PERL-CONVERT-UULIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-CONVERT-UULIB_MAINTAINER)" >>$@
	@echo "Source: $(PERL-CONVERT-UULIB_SITE)/$(PERL-CONVERT-UULIB_SOURCE)" >>$@
	@echo "Description: $(PERL-CONVERT-UULIB_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-CONVERT-UULIB_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-CONVERT-UULIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-CONVERT-UULIB_CONFLICTS)" >>$@

$(PERL-CONVERT-UULIB_IPK): $(PERL-CONVERT-UULIB_BUILD_DIR)/.built
	rm -rf $(PERL-CONVERT-UULIB_IPK_DIR) $(BUILD_DIR)/perl-convert-uulib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-CONVERT-UULIB_BUILD_DIR) DESTDIR=$(PERL-CONVERT-UULIB_IPK_DIR) install
	find $(PERL-CONVERT-UULIB_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-CONVERT-UULIB_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-CONVERT-UULIB_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-CONVERT-UULIB_IPK_DIR)/CONTROL/control
	echo $(PERL-CONVERT-UULIB_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-CONVERT-UULIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-CONVERT-UULIB_IPK_DIR)

perl-convert-uulib-ipk: $(PERL-CONVERT-UULIB_IPK)

perl-convert-uulib-clean:
	-$(MAKE) -C $(PERL-CONVERT-UULIB_BUILD_DIR) clean

perl-convert-uulib-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-CONVERT-UULIB_DIR) $(PERL-CONVERT-UULIB_BUILD_DIR) $(PERL-CONVERT-UULIB_IPK_DIR) $(PERL-CONVERT-UULIB_IPK)
