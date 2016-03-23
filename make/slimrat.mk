###########################################################
#
# slimrat
#
###########################################################

SLIMRAT_SITE=http://slimrat.googlecode.com/files
SLIMRAT_VERSION=1.0
SLIMRAT_SOURCE=slimrat-$(SLIMRAT_VERSION).tar.bz2
SLIMRAT_DIR=slimrat-$(SLIMRAT_VERSION)
SLIMRAT_UNZIP=bzcat
SLIMRAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLIMRAT_DESCRIPTION=Utility for downloading files from Rapidshare (free) and a few other servers.
SLIMRAT_SECTION=util
SLIMRAT_PRIORITY=optional
SLIMRAT_DEPENDS=perl-libwww, perl-www-mechanize, wget-ssl
SLIMRAT_SUGGESTS=tesseract-ocr, imagemagick
SLIMRAT_CONFLICTS=

SLIMRAT_IPK_VERSION=3

SLIMRAT_CONFFILES=

SLIMRAT_BUILD_DIR=$(BUILD_DIR)/slimrat
SLIMRAT_SOURCE_DIR=$(SOURCE_DIR)/slimrat
SLIMRAT_IPK_DIR=$(BUILD_DIR)/slimrat-$(SLIMRAT_VERSION)-ipk
SLIMRAT_IPK=$(BUILD_DIR)/slimrat_$(SLIMRAT_VERSION)-$(SLIMRAT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(SLIMRAT_SOURCE):
	$(WGET) -P $(@D) $(SLIMRAT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

slimrat-source: $(DL_DIR)/$(SLIMRAT_SOURCE) $(SLIMRAT_PATCHES)

$(SLIMRAT_BUILD_DIR)/.configured: $(DL_DIR)/$(SLIMRAT_SOURCE) $(SLIMRAT_PATCHES) make/slimrat.mk
	rm -rf $(BUILD_DIR)/$(SLIMRAT_DIR) $(SLIMRAT_BUILD_DIR)
	$(SLIMRAT_UNZIP) $(DL_DIR)/$(SLIMRAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(SLIMRAT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(SLIMRAT_DIR) -p1
	mv $(BUILD_DIR)/$(SLIMRAT_DIR) $(@D)
	sed -i -e '1s|#!.*|#!$(TARGET_PREFIX)/bin/perl|' $(@D)/src/slimrat
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

slimrat-unpack: $(SLIMRAT_BUILD_DIR)/.configured

$(SLIMRAT_BUILD_DIR)/.built: $(SLIMRAT_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

slimrat: $(SLIMRAT_BUILD_DIR)/.built

$(SLIMRAT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: slimrat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SLIMRAT_PRIORITY)" >>$@
	@echo "Section: $(SLIMRAT_SECTION)" >>$@
	@echo "Version: $(SLIMRAT_VERSION)-$(SLIMRAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SLIMRAT_MAINTAINER)" >>$@
	@echo "Source: $(SLIMRAT_SITE)/$(SLIMRAT_SOURCE)" >>$@
	@echo "Description: $(SLIMRAT_DESCRIPTION)" >>$@
	@echo "Depends: $(SLIMRAT_DEPENDS)" >>$@
	@echo "Suggests: $(SLIMRAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SLIMRAT_CONFLICTS)" >>$@

$(SLIMRAT_IPK): $(SLIMRAT_BUILD_DIR)/.built
	rm -rf $(SLIMRAT_IPK_DIR) $(BUILD_DIR)/slimrat_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(SLIMRAT_BUILD_DIR) DESTDIR=$(SLIMRAT_IPK_DIR) install
	$(INSTALL) -d $(SLIMRAT_IPK_DIR)$(TARGET_PREFIX)/share
	cp -rp $(SLIMRAT_BUILD_DIR) $(SLIMRAT_IPK_DIR)$(TARGET_PREFIX)/share/
	rm -f $(SLIMRAT_IPK_DIR)$(TARGET_PREFIX)/share/slimrat/.[bc]*
	cd $(SLIMRAT_IPK_DIR)$(TARGET_PREFIX)/share/slimrat/src && rm -f .[bc]* slimrat-gui slimrat.glade
	$(INSTALL) -d $(SLIMRAT_IPK_DIR)$(TARGET_PREFIX)/bin
	cd $(SLIMRAT_IPK_DIR)$(TARGET_PREFIX)/bin; ln -s ../share/slimrat/src/slimrat .
	$(MAKE) $(SLIMRAT_IPK_DIR)/CONTROL/control
	echo $(SLIMRAT_CONFFILES) | sed -e 's/ /\n/g' > $(SLIMRAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLIMRAT_IPK_DIR)

slimrat-ipk: $(SLIMRAT_IPK)

slimrat-clean:
	-$(MAKE) -C $(SLIMRAT_BUILD_DIR) clean

slimrat-dirclean:
	rm -rf $(BUILD_DIR)/$(SLIMRAT_DIR) $(SLIMRAT_BUILD_DIR) $(SLIMRAT_IPK_DIR) $(SLIMRAT_IPK)
