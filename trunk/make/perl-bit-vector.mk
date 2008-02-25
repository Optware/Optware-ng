###########################################################
#
# perl-bit-vector
#
###########################################################

PERL-BIT-VECTOR_SITE=http://search.cpan.org/CPAN/authors/id/S/ST/STBEY
PERL-BIT-VECTOR_VERSION=6.4
PERL-BIT-VECTOR_SOURCE=Bit-Vector-$(PERL-BIT-VECTOR_VERSION).tar.gz
PERL-BIT-VECTOR_DIR=Bit-Vector-$(PERL-BIT-VECTOR_VERSION)
PERL-BIT-VECTOR_UNZIP=zcat

PERL-BIT-VECTOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-BIT-VECTOR_DESCRIPTION=This package implements bit vectors of arbitrary size and provides efficient methods for handling them.
PERL-BIT-VECTOR_SECTION=util
PERL-BIT-VECTOR_PRIORITY=optional
PERL-BIT-VECTOR_DEPENDS=perl-carp-clan

PERL-BIT-VECTOR_IPK_VERSION=1

PERL-BIT-VECTOR_CONFFILES=

PERL-BIT-VECTOR_PATCHES=

PERL-BIT-VECTOR_BUILD_DIR=$(BUILD_DIR)/perl-bit-vector
PERL-BIT-VECTOR_SOURCE_DIR=$(SOURCE_DIR)/perl-bit-vector
PERL-BIT-VECTOR_IPK_DIR=$(BUILD_DIR)/perl-bit-vector-$(PERL-BIT-VECTOR_VERSION)-ipk
PERL-BIT-VECTOR_IPK=$(BUILD_DIR)/perl-bit-vector_$(PERL-BIT-VECTOR_VERSION)-$(PERL-BIT-VECTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-BIT-VECTOR_BUILD_DIR=$(BUILD_DIR)/perl-bit-vector
PERL-BIT-VECTOR_SOURCE_DIR=$(SOURCE_DIR)/perl-bit-vector
PERL-BIT-VECTOR_IPK_DIR=$(BUILD_DIR)/perl-bit-vector-$(PERL-BIT-VECTOR_VERSION)-ipk
PERL-BIT-VECTOR_IPK=$(BUILD_DIR)/perl-bit-vector_$(PERL-BIT-VECTOR_VERSION)-$(PERL-BIT-VECTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-BIT-VECTOR_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-BIT-VECTOR_SITE)/$(PERL-BIT-VECTOR_SOURCE)

perl-bit-vector-source: $(DL_DIR)/$(PERL-BIT-VECTOR_SOURCE) $(PERL-BIT-VECTOR_PATCHES)

$(PERL-BIT-VECTOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-BIT-VECTOR_SOURCE) $(PERL-BIT-VECTOR_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-BIT-VECTOR_DIR) $(@D)
	$(PERL-BIT-VECTOR_UNZIP) $(DL_DIR)/$(PERL-BIT-VECTOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-BIT-VECTOR_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-BIT-VECTOR_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-BIT-VECTOR_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-bit-vector-unpack: $(PERL-BIT-VECTOR_BUILD_DIR)/.configured

$(PERL-BIT-VECTOR_BUILD_DIR)/.built: $(PERL-BIT-VECTOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-bit-vector: $(PERL-BIT-VECTOR_BUILD_DIR)/.built

$(PERL-BIT-VECTOR_BUILD_DIR)/.staged: $(PERL-BIT-VECTOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-bit-vector-stage: $(PERL-BIT-VECTOR_BUILD_DIR)/.staged

$(PERL-BIT-VECTOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-bit-vector" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-BIT-VECTOR_PRIORITY)" >>$@
	@echo "Section: $(PERL-BIT-VECTOR_SECTION)" >>$@
	@echo "Version: $(PERL-BIT-VECTOR_VERSION)-$(PERL-BIT-VECTOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-BIT-VECTOR_MAINTAINER)" >>$@
	@echo "Source: $(PERL-BIT-VECTOR_SITE)/$(PERL-BIT-VECTOR_SOURCE)" >>$@
	@echo "Description: $(PERL-BIT-VECTOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-BIT-VECTOR_DEPENDS)" >>$@

$(PERL-BIT-VECTOR_IPK): $(PERL-BIT-VECTOR_BUILD_DIR)/.built
	rm -rf $(PERL-BIT-VECTOR_IPK_DIR) $(BUILD_DIR)/perl-bit-vector_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-BIT-VECTOR_BUILD_DIR) DESTDIR=$(PERL-BIT-VECTOR_IPK_DIR) install
	find $(PERL-BIT-VECTOR_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-BIT-VECTOR_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-BIT-VECTOR_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-BIT-VECTOR_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-BIT-VECTOR_SOURCE_DIR)/postinst $(PERL-BIT-VECTOR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-BIT-VECTOR_SOURCE_DIR)/prerm $(PERL-BIT-VECTOR_IPK_DIR)/CONTROL/prerm
	echo $(PERL-BIT-VECTOR_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-BIT-VECTOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-BIT-VECTOR_IPK_DIR)

perl-bit-vector-ipk: $(PERL-BIT-VECTOR_IPK)

perl-bit-vector-clean:
	-$(MAKE) -C $(PERL-BIT-VECTOR_BUILD_DIR) clean

perl-bit-vector-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-BIT-VECTOR_DIR) $(PERL-BIT-VECTOR_BUILD_DIR) $(PERL-BIT-VECTOR_IPK_DIR) $(PERL-BIT-VECTOR_IPK)

perl-bit-vector-check: $(PERL-BIT-VECTOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-BIT-VECTOR_IPK)
