###########################################################
#
# vdr-mediamvp
#
###########################################################

VDR_MEDIAMVP_DIR=$(BUILD_DIR)/mediamvp

VDR_MEDIAMVP_VERSION=0.1.4
VDR_MEDIAMVP=mediamvp-$(VDR_MEDIAMVP_VERSION)
VDR_MEDIAMVP_SITE=http://www.rst38.org.uk/vdr/mediamvp
VDR_MEDIAMVP_SOURCE=vdr-$(VDR_MEDIAMVP).tgz
VDR_MEDIAMVP_UNZIP=zcat
VDR_MEDIAMVP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VDR_MEDIAMVP_DESCRIPTION=A media server for the Hauppauge MediaMVP
VDR_MEDIAMVP_SECTION=net
VDR_MEDIAMVP_PRIORITY=optional
VDR_MEDIAMVP_DEPENDS=zlib, libid3tag, libevent (>=1.4)
VDR_MEDIAMVP_SUGGESTS=
VDR_MEDIAMVP_CONFLICTS=

VDR_MEDIAMVP_IPK_VERSION=6
VDR_MEDIAMVP_IPK=$(BUILD_DIR)/vdr-mediamvp_$(VDR_MEDIAMVP_VERSION)-$(VDR_MEDIAMVP_IPK_VERSION)_$(TARGET_ARCH).ipk
VDR_MEDIAMVP_IPK_DIR=$(BUILD_DIR)/vdr-mediamvp-$(VDR_MEDIAMVP_VERSION)-ipk

$(DL_DIR)/$(VDR_MEDIAMVP_SOURCE):
	$(WGET) -P $(@D) $(VDR_MEDIAMVP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

vdr-mediamvp-source: $(DL_DIR)/$(VDR_MEDIAMVP_SOURCE) $(VDR_MEDIAMVP_PATCH)

$(VDR_MEDIAMVP_DIR)/.source: $(DL_DIR)/$(VDR_MEDIAMVP_SOURCE)
	$(VDR_MEDIAMVP_UNZIP) $(DL_DIR)/$(VDR_MEDIAMVP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(VDR_MEDIAMVP) $(VDR_MEDIAMVP_DIR)
	touch $@

$(VDR_MEDIAMVP_DIR)/console/mediamvp: $(VDR_MEDIAMVP_DIR)/.source make/vdr-mediamvp.mk
	$(MAKE) libid3tag-stage libevent-stage
	echo "EXTRA_INCLUDES=$(STAGING_CPPFLAGS)" > $(VDR_MEDIAMVP_DIR)/config.mak
	echo "EXTRA_LIBS=$(STAGING_LDFLAGS) " >> $(VDR_MEDIAMVP_DIR)/config.mak
	echo "HAVE_LIBID3TAG=1" >> $(VDR_MEDIAMVP_DIR)/config.mak
	$(MAKE) -C $(VDR_MEDIAMVP_DIR)/console RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR)" CC="$(TARGET_CC)" 

vdr-mediamvp: $(VDR_MEDIAMVP_DIR)/console/mediamvp

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vdr-mediamvp
#
$(VDR_MEDIAMVP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: vdr-mediamvp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VDR_MEDIAMVP_PRIORITY)" >>$@
	@echo "Section: $(VDR_MEDIAMVP_SECTION)" >>$@
	@echo "Version: $(VDR_MEDIAMVP_VERSION)-$(VDR_MEDIAMVP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VDR_MEDIAMVP_MAINTAINER)" >>$@
	@echo "Source: $(VDR_MEDIAMVP_SITE)/$(VDR_MEDIAMVP_SOURCE)" >>$@
	@echo "Description: $(VDR_MEDIAMVP_DESCRIPTION)" >>$@
	@echo "Depends: $(VDR_MEDIAMVP_DEPENDS)" >>$@
	@echo "Suggests: $(VDR_MEDIAMVP_SUGGESTS)" >>$@
	@echo "Conflicts: $(VDR_MEDIAMVP_CONFLICTS)" >>$@


$(VDR_MEDIAMVP_IPK): $(VDR_MEDIAMVP_DIR)/console/mediamvp
	rm -rf $(VDR_MEDIAMVP_IPK_DIR) $(BUILD_DIR)/vdr-mediavp_*_$(TARGET_ARCH).ipk
	-mkdir -p $(VDR_MEDIAMVP_IPK_DIR)	
	mkdir -p $(VDR_MEDIAMVP_IPK_DIR)/opt/sbin
	mkdir -p $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/mediamvp
	mkdir -p $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/init.d
	$(STRIP_COMMAND) $(VDR_MEDIAMVP_DIR)/console/mediamvp -o $(VDR_MEDIAMVP_IPK_DIR)/opt/sbin/mediamvp
	install -m 644 $(SOURCE_DIR)/vdr-mediamvp.conf $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/mediamvp/mediamvp.conf
	install -m 644 $(SOURCE_DIR)/vdr-mediamvp.radio $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/mediamvp/mediamvp.radio
	install -m 755 $(SOURCE_DIR)/vdr-mediamvp.rc $(VDR_MEDIAMVP_IPK_DIR)/opt/etc/init.d/S60mediamvp
	$(MAKE) $(VDR_MEDIAMVP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VDR_MEDIAMVP_IPK_DIR)

vdr-mediamvp-ipk: $(VDR_MEDIAMVP_IPK)

vdr-mediamvp-clean:
	-$(MAKE) -C $(VDR_MEDIAMVP_DIR) uninstall
	-$(MAKE) -C $(VDR_MEDIAMVP_DIR) clean

vdr-mediamvp-dirclean:
	rm -rf $(BUILD_DIR)/$(VDR_MEDIAMVP) $(VDR_MEDIAMVP_DIR) $(VDR_MEDIAMVP_IPK_DIR) $(VDR_MEDIAMVP_IPK)

vdr-mediamvp-check: $(VDR_MEDIAMVP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VDR_MEDIAMVP_IPK)
