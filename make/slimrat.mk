###########################################################
#
# slimrat
#
###########################################################

SLIMRAT_SITE=http://slimrat.googlecode.com/files
SLIMRAT_VERSION=0.9.4
SLIMRAT_SOURCE=slimrat-$(SLIMRAT_VERSION).tar.bz2
SLIMRAT_DIR=slimrat-$(SLIMRAT_VERSION)
SLIMRAT_UNZIP=bzcat
SLIMRAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLIMRAT_DESCRIPTION=Utility for downloading files from Rapidshare (free) and a few other servers.
SLIMRAT_SECTION=util
SLIMRAT_PRIORITY=optional
SLIMRAT_DEPENDS=perl-libwww, perl-www-mechanize, wget-ssl
SLIMRAT_SUGGESTS=
SLIMRAT_CONFLICTS=

SLIMRAT_IPK_VERSION=1

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
#	cat $(SLIMRAT_PATCHES) | patch -d $(BUILD_DIR)/$(SLIMRAT_DIR) -p1
	mv $(BUILD_DIR)/$(SLIMRAT_DIR) $(@D)
	sed -i -e '1s|#!.*|#!/opt/bin/perl|' $(@D)/slimrat
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

slimrat-unpack: $(SLIMRAT_BUILD_DIR)/.configured

$(SLIMRAT_BUILD_DIR)/.built: $(SLIMRAT_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

slimrat: $(SLIMRAT_BUILD_DIR)/.built

$(SLIMRAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
	install -d $(SLIMRAT_IPK_DIR)/opt/share
	cp -rp $(SLIMRAT_BUILD_DIR) $(SLIMRAT_IPK_DIR)/opt/share/
	cd $(SLIMRAT_IPK_DIR)/opt/share/slimrat && rm -f .[bc]* slimrat-gui slimrat.glade
	install -d $(SLIMRAT_IPK_DIR)/opt/bin
	cd $(SLIMRAT_IPK_DIR)/opt/bin; ln -s ../share/slimrat/slimrat .
	$(MAKE) $(SLIMRAT_IPK_DIR)/CONTROL/control
	echo $(SLIMRAT_CONFFILES) | sed -e 's/ /\n/g' > $(SLIMRAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLIMRAT_IPK_DIR)

slimrat-ipk: $(SLIMRAT_IPK)

slimrat-clean:
	-$(MAKE) -C $(SLIMRAT_BUILD_DIR) clean

slimrat-dirclean:
	rm -rf $(BUILD_DIR)/$(SLIMRAT_DIR) $(SLIMRAT_BUILD_DIR) $(SLIMRAT_IPK_DIR) $(SLIMRAT_IPK)
