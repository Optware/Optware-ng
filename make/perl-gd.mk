###########################################################
#
# perl-gd
#
###########################################################

PERL-GD_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/L/LD/LDS
PERL-GD_VERSION=2.56
PERL-GD_SOURCE=GD-$(PERL-GD_VERSION).tar.gz
PERL-GD_DIR=GD-$(PERL-GD_VERSION)
PERL-GD_UNZIP=zcat
PERL-GD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-GD_DESCRIPTION=GD - Interface to Gd Graphics Library 
PERL-GD_SECTION=util
PERL-GD_PRIORITY=optional
# other depends are taken care of by libgd
PERL-GD_DEPENDS=perl, libgd, zlib
PERL-GD_SUGGESTS=
PERL-GD_CONFLICTS=

PERL-GD_IPK_VERSION=4

PERL-GD_CONFFILES=

PERL-GD_BUILD_DIR=$(BUILD_DIR)/perl-gd
PERL-GD_SOURCE_DIR=$(SOURCE_DIR)/perl-gd
PERL-GD_IPK_DIR=$(BUILD_DIR)/perl-gd-$(PERL-GD_VERSION)-ipk
PERL-GD_IPK=$(BUILD_DIR)/perl-gd_$(PERL-GD_VERSION)-$(PERL-GD_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-GD_SOURCE):
	$(WGET) -P $(@D) $(PERL-GD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-gd-source: $(DL_DIR)/$(PERL-GD_SOURCE) $(PERL-GD_PATCHES)

$(PERL-GD_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-GD_SOURCE) $(PERL-GD_PATCHES) make/perl-gd.mk
	$(MAKE) perl-stage libgd-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(PERL-GD_DIR) $(PERL-GD_BUILD_DIR)
	$(PERL-GD_UNZIP) $(DL_DIR)/$(PERL-GD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-GD_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-GD_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-GD_DIR) $(PERL-GD_BUILD_DIR)
	find $(@D) -type f -exec chmod +w {} \;
#	some very odd bug workaround
	sed -i -e '/unless (try_to_autoconfigure(/,/Build options passed in to script/s/^/#/' -e \
	'/unless (\$$result) {/s|^|\$$lib_gd_path = "$(STAGING_PREFIX)";\n\$$lib_ft_path = "$(STAGING_PREFIX)";\n\$$lib_png_path = "$(STAGING_PREFIX)";\n\$$lib_jpeg_path = "$(STAGING_PREFIX)";\n\$$lib_zlib_path = "$(STAGING_PREFIX)";\n\$$options = "JPEG,FT,PNG,GIF,ANIMGIF,FONTCONFIG";\n|' $(@D)/Makefile.PL
	(cd $(PERL-GD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
			-options "JPEG,FT,PNG,GIF,ANIMGIF,FONTCONFIG" \
			-lib_gd_path $(STAGING_PREFIX) \
			-lib_ft_path $(STAGING_PREFIX) \
			-lib_png_path  $(STAGING_PREFIX) \
			-lib_jpeg_path $(STAGING_PREFIX) \
		     	-lib_zlib_path $(STAGING_PREFIX) \
			INC="$(STAGING_CPPFLAGS)" \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-GD_BUILD_DIR)/.configured

perl-gd-unpack: $(PERL-GD_BUILD_DIR)/.configured

$(PERL-GD_BUILD_DIR)/.built: $(PERL-GD_BUILD_DIR)/.configured
	rm -f $(PERL-GD_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-GD_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS)" \
		LDLOADLIBS="`$(STAGING_PREFIX)/bin/gdlib-config --libs` -lgd" \
		LD_RUN_PATH=$(TARGET_PREFIX)/lib \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-GD_BUILD_DIR)/.built

perl-gd: $(PERL-GD_BUILD_DIR)/.built

$(PERL-GD_BUILD_DIR)/.staged: $(PERL-GD_BUILD_DIR)/.built
	rm -f $(PERL-GD_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-GD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-GD_BUILD_DIR)/.staged

perl-gd-stage: $(PERL-GD_BUILD_DIR)/.staged

$(PERL-GD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-GD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-gd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-GD_PRIORITY)" >>$@
	@echo "Section: $(PERL-GD_SECTION)" >>$@
	@echo "Version: $(PERL-GD_VERSION)-$(PERL-GD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-GD_MAINTAINER)" >>$@
	@echo "Source: $(PERL-GD_SITE)/$(PERL-GD_SOURCE)" >>$@
	@echo "Description: $(PERL-GD_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-GD_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-GD_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-GD_CONFLICTS)" >>$@

$(PERL-GD_IPK): $(PERL-GD_BUILD_DIR)/.built
	rm -rf $(PERL-GD_IPK_DIR) $(BUILD_DIR)/perl-gd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-GD_BUILD_DIR) DESTDIR=$(PERL-GD_IPK_DIR) install
	find $(PERL-GD_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-GD_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-GD_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-GD_IPK_DIR)/CONTROL/control
	echo $(PERL-GD_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-GD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-GD_IPK_DIR)

perl-gd-ipk: $(PERL-GD_IPK)

perl-gd-clean:
	-$(MAKE) -C $(PERL-GD_BUILD_DIR) clean

perl-gd-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-GD_DIR) $(PERL-GD_BUILD_DIR) $(PERL-GD_IPK_DIR) $(PERL-GD_IPK)
