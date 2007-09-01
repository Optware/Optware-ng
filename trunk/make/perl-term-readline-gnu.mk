###########################################################
#
# perl-term-readline-gnu
#
###########################################################

PERL-TERM-READLINE-GNU_SITE=http://search.cpan.org/CPAN/authors/id/H/HA/HAYASHI
PERL-TERM-READLINE-GNU_VERSION=1.16
PERL-TERM-READLINE-GNU_SOURCE=Term-ReadLine-Gnu-$(PERL-TERM-READLINE-GNU_VERSION).tar.gz
PERL-TERM-READLINE-GNU_DIR=Term-ReadLine-Gnu-$(PERL-TERM-READLINE-GNU_VERSION)
PERL-TERM-READLINE-GNU_UNZIP=zcat
PERL-TERM-READLINE-GNU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-TERM-READLINE-GNU_DESCRIPTION=Perl extension for the GNU Readline/History Library.
PERL-TERM-READLINE-GNU_SECTION=util
PERL-TERM-READLINE-GNU_PRIORITY=optional
PERL-TERM-READLINE-GNU_DEPENDS=perl, readline
PERL-TERM-READLINE-GNU_SUGGESTS=
PERL-TERM-READLINE-GNU_CONFLICTS=

PERL-TERM-READLINE-GNU_IPK_VERSION=1

PERL-TERM-READLINE-GNU_CONFFILES=
PERL-TERM-READLINE-GNU_PATCHES=$(PERL-TERM-READLINE-GNU_SOURCE_DIR)/Makefile.PL.patch

PERL-TERM-READLINE-GNU_BUILD_DIR=$(BUILD_DIR)/perl-term-readline-gnu
PERL-TERM-READLINE-GNU_SOURCE_DIR=$(SOURCE_DIR)/perl-term-readline-gnu
PERL-TERM-READLINE-GNU_IPK_DIR=$(BUILD_DIR)/perl-term-readline-gnu-$(PERL-TERM-READLINE-GNU_VERSION)-ipk
PERL-TERM-READLINE-GNU_IPK=$(BUILD_DIR)/perl-term-readline-gnu_$(PERL-TERM-READLINE-GNU_VERSION)-$(PERL-TERM-READLINE-GNU_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-TERM-READLINE-GNU_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-TERM-READLINE-GNU_SITE)/$(PERL-TERM-READLINE-GNU_SOURCE)

perl-term-readline-gnu-source: $(DL_DIR)/$(PERL-TERM-READLINE-GNU_SOURCE) $(PERL-TERM-READLINE-GNU_PATCHES)

$(PERL-TERM-READLINE-GNU_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TERM-READLINE-GNU_SOURCE) $(PERL-TERM-READLINE-GNU_PATCHES)
	$(MAKE) termcap-stage readline-stage
	rm -rf $(BUILD_DIR)/$(PERL-TERM-READLINE-GNU_DIR) $(PERL-TERM-READLINE-GNU_BUILD_DIR)
	$(PERL-TERM-READLINE-GNU_UNZIP) $(DL_DIR)/$(PERL-TERM-READLINE-GNU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PERL-TERM-READLINE-GNU_PATCHES) | patch -bd $(BUILD_DIR)/$(PERL-TERM-READLINE-GNU_DIR) -p0
	mv $(BUILD_DIR)/$(PERL-TERM-READLINE-GNU_DIR) $(PERL-TERM-READLINE-GNU_BUILD_DIR)
	sed -i -e 's|$$Config{libpth}|"$(STAGING_LIB_DIR)"|' $(PERL-TERM-READLINE-GNU_BUILD_DIR)/Makefile.PL
	(cd $(PERL-TERM-READLINE-GNU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
		--prefix=/opt \
		--libdir=$(STAGING_LIB_DIR) \
		--includedir=$(STAGING_INCLUDE_DIR) \
	)
	touch $@

perl-term-readline-gnu-unpack: $(PERL-TERM-READLINE-GNU_BUILD_DIR)/.configured

$(PERL-TERM-READLINE-GNU_BUILD_DIR)/.built: $(PERL-TERM-READLINE-GNU_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-TERM-READLINE-GNU_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-term-readline-gnu: $(PERL-TERM-READLINE-GNU_BUILD_DIR)/.built

$(PERL-TERM-READLINE-GNU_BUILD_DIR)/.staged: $(PERL-TERM-READLINE-GNU_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-TERM-READLINE-GNU_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-term-readline-gnu-stage: $(PERL-TERM-READLINE-GNU_BUILD_DIR)/.staged

$(PERL-TERM-READLINE-GNU_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-term-readline-gnu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-TERM-READLINE-GNU_PRIORITY)" >>$@
	@echo "Section: $(PERL-TERM-READLINE-GNU_SECTION)" >>$@
	@echo "Version: $(PERL-TERM-READLINE-GNU_VERSION)-$(PERL-TERM-READLINE-GNU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-TERM-READLINE-GNU_MAINTAINER)" >>$@
	@echo "Source: $(PERL-TERM-READLINE-GNU_SITE)/$(PERL-TERM-READLINE-GNU_SOURCE)" >>$@
	@echo "Description: $(PERL-TERM-READLINE-GNU_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-TERM-READLINE-GNU_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-TERM-READLINE-GNU_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-TERM-READLINE-GNU_CONFLICTS)" >>$@

$(PERL-TERM-READLINE-GNU_IPK): $(PERL-TERM-READLINE-GNU_BUILD_DIR)/.built
	rm -rf $(PERL-TERM-READLINE-GNU_IPK_DIR) $(BUILD_DIR)/perl-term-readline-gnu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-TERM-READLINE-GNU_BUILD_DIR) DESTDIR=$(PERL-TERM-READLINE-GNU_IPK_DIR) install
	find $(PERL-TERM-READLINE-GNU_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-TERM-READLINE-GNU_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-TERM-READLINE-GNU_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-TERM-READLINE-GNU_IPK_DIR)/CONTROL/control
	echo $(PERL-TERM-READLINE-GNU_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TERM-READLINE-GNU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TERM-READLINE-GNU_IPK_DIR)

perl-term-readline-gnu-ipk: $(PERL-TERM-READLINE-GNU_IPK)

perl-term-readline-gnu-clean:
	-$(MAKE) -C $(PERL-TERM-READLINE-GNU_BUILD_DIR) clean

perl-term-readline-gnu-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TERM-READLINE-GNU_DIR) $(PERL-TERM-READLINE-GNU_BUILD_DIR) $(PERL-TERM-READLINE-GNU_IPK_DIR) $(PERL-TERM-READLINE-GNU_IPK)

perl-term-readline-gnu-check: $(PERL-TERM-READLINE-GNU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-TERM-READLINE-GNU_IPK)
