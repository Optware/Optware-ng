###########################################################
#
# colordiff
#
###########################################################

COLORDIFF_SITE=http://colordiff.sourceforge.net
COLORDIFF_VERSION=1.0.9
COLORDIFF_SOURCE=colordiff-$(COLORDIFF_VERSION).tar.gz
COLORDIFF_DIR=colordiff-$(COLORDIFF_VERSION)
COLORDIFF_UNZIP=zcat
COLORDIFF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COLORDIFF_DESCRIPTION=Colour-highlighted 'diff' output.
COLORDIFF_SECTION=util
COLORDIFF_PRIORITY=optional
COLORDIFF_DEPENDS=perl
COLORDIFF_SUGGESTS=
COLORDIFF_CONFLICTS=

COLORDIFF_IPK_VERSION=1

COLORDIFF_CONFFILES=

COLORDIFF_BUILD_DIR=$(BUILD_DIR)/colordiff
COLORDIFF_SOURCE_DIR=$(SOURCE_DIR)/colordiff
COLORDIFF_IPK_DIR=$(BUILD_DIR)/colordiff-$(COLORDIFF_VERSION)-ipk
COLORDIFF_IPK=$(BUILD_DIR)/colordiff_$(COLORDIFF_VERSION)-$(COLORDIFF_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(COLORDIFF_SOURCE):
	$(WGET) -P $(@D) $(COLORDIFF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

colordiff-source: $(DL_DIR)/$(COLORDIFF_SOURCE) $(COLORDIFF_PATCHES)

$(COLORDIFF_BUILD_DIR)/.configured: $(DL_DIR)/$(COLORDIFF_SOURCE) $(COLORDIFF_PATCHES) make/colordiff.mk
	make perl-stage
	rm -rf $(BUILD_DIR)/$(COLORDIFF_DIR) $(@D)
	$(COLORDIFF_UNZIP) $(DL_DIR)/$(COLORDIFF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(COLORDIFF_DIR) $(@D)
	sed -i -e '/chown/s/^/#/' -e '/cdiff\.1/d' $(@D)/Makefile
	sed -i -e 's|/etc/colordiffrc|/opt&|' $(@D)/colordiff.1
#	(cd $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

colordiff-unpack: $(COLORDIFF_BUILD_DIR)/.configured

$(COLORDIFF_BUILD_DIR)/.built: $(COLORDIFF_BUILD_DIR)/.configured
	rm -f $@
	touch $@

colordiff: $(COLORDIFF_BUILD_DIR)/.built

#$(COLORDIFF_BUILD_DIR)/.staged: $(COLORDIFF_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#colordiff-stage: $(COLORDIFF_BUILD_DIR)/.staged

$(COLORDIFF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: colordiff" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COLORDIFF_PRIORITY)" >>$@
	@echo "Section: $(COLORDIFF_SECTION)" >>$@
	@echo "Version: $(COLORDIFF_VERSION)-$(COLORDIFF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COLORDIFF_MAINTAINER)" >>$@
	@echo "Source: $(COLORDIFF_SITE)/$(COLORDIFF_SOURCE)" >>$@
	@echo "Description: $(COLORDIFF_DESCRIPTION)" >>$@
	@echo "Depends: $(COLORDIFF_DEPENDS)" >>$@
	@echo "Suggests: $(COLORDIFF_SUGGESTS)" >>$@
	@echo "Conflicts: $(COLORDIFF_CONFLICTS)" >>$@

$(COLORDIFF_IPK): $(COLORDIFF_BUILD_DIR)/.built
	rm -rf $(COLORDIFF_IPK_DIR) $(BUILD_DIR)/colordiff_*_$(TARGET_ARCH).ipk
	install -d $(COLORDIFF_IPK_DIR)/opt/etc
	$(MAKE) -C $(COLORDIFF_BUILD_DIR) install \
		DESTDIR=$(COLORDIFF_IPK_DIR) \
		INSTALL_DIR=/opt/bin \
		MAN_DIR=/opt/man/man1 \
		ETC_DIR=/opt/etc \
		;
	sed -i -e '/^#!/s|/usr/bin/perl|/opt/bin/perl|' $(COLORDIFF_IPK_DIR)/opt/bin/colordiff
	$(MAKE) $(COLORDIFF_IPK_DIR)/CONTROL/control
	echo $(COLORDIFF_CONFFILES) | sed -e 's/ /\n/g' > $(COLORDIFF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COLORDIFF_IPK_DIR)

colordiff-ipk: $(COLORDIFF_IPK)

colordiff-clean:
	-$(MAKE) -C $(COLORDIFF_BUILD_DIR) clean

colordiff-dirclean:
	rm -rf $(BUILD_DIR)/$(COLORDIFF_DIR) $(COLORDIFF_BUILD_DIR) $(COLORDIFF_IPK_DIR) $(COLORDIFF_IPK)

colordiff-check: $(COLORDIFF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
