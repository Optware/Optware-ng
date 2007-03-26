#############################################################
#
# unfs3
#
#############################################################

UNFS3_DIR:=$(BUILD_DIR)/unfs3

UNFS3_VERSION=0.9.17
UNFS3=unfs3-$(UNFS3_VERSION)
UNFS3_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/unfs3
UNFS3_SOURCE:=$(UNFS3).tar.gz
UNFS3_UNZIP=zcat
# UNFS3_PATCH:=$(SOURCE_DIR)/unfs3.patch
UNFS3_IPK_VERSION=1
UNFS3_IPK=$(BUILD_DIR)/unfs3_$(UNFS3_VERSION)-$(UNFS3_IPK_VERSION)_$(TARGET_ARCH).ipk
UNFS3_IPK_DIR:=$(BUILD_DIR)/unfs3-$(UNFS3_VERSION)-ipk
UNFS3_MAINTAINER=Christopher Blunck <christopher.blunck@gmail.com>
UNFS3_SECTION=net
UNFS3_PRIORITY=optional
UNFS3_DESCRIPTION=Version 3 NFS server (not recommended, use nfs-utils instead)

.PHONY: unfs3-source unfs3-unpack unfs3 unfs3-stage unfs3-ipk unfs3-clean unfs3-dirclean unfs3-check

$(DL_DIR)/$(UNFS3_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNFS3_SITE)/$(UNFS3_SOURCE)

unfs3-source: $(DL_DIR)/$(UNFS3_SOURCE) # $(UNFS3_PATCH)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unfs3
#
$(UNFS3_IPK_DIR)/CONTROL/control:
	@install -d $(UNFS3_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: unfs3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNFS3_PRIORITY)" >>$@
	@echo "Section: $(UNFS3_SECTION)" >>$@
	@echo "Version: $(UNFS3_VERSION)-$(UNFS3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNFS3_MAINTAINER)" >>$@
	@echo "Source: $(UNFS3_SITE)/$(UNFS3_SOURCE)" >>$@
	@echo "Description: $(UNFS3_DESCRIPTION)" >>$@
	@echo "Depends: $(UNFS3_DEPENDS)" >>$@
	@echo "Conflicts: $(UNFS3_CONFLICTS)" >>$@

# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(UNFS3_DIR)/.configured: $(DL_DIR)/$(UNFS3_SOURCE)
	$(MAKE) flex-stage
	@rm -rf $(BUILD_DIR)/$(UNFS3) $(UNFS3_DIR)
	$(UNFS3_UNZIP) $(DL_DIR)/$(UNFS3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	(cd $(BUILD_DIR)/$(UNFS3) && \
   ./configure)
#	patch -d $(BUILD_DIR)/$(UNFS3) -p1 < $(UNFS3_PATCH)
	mv $(BUILD_DIR)/$(UNFS3) $(UNFS3_DIR)
	touch $(UNFS3_DIR)/.configured

unfs3-unpack: $(UNFS3_DIR)/.configured

$(UNFS3_DIR)/unfsd: $(UNFS3_DIR)/.configured
	make -C $(UNFS3_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) LDFLAGS="-L$(STAGING_DIR)/opt/lib -lfl"

unfs3: $(UNFS3_DIR)/unfsd

$(UNFS3_IPK): $(UNFS3_DIR)/unfsd
	rm -rf $(UNFS3_IPK_DIR) $(UNFS3_IPK)
	$(MAKE) $(UNFS3_IPK_DIR)/CONTROL/control
	install -d $(UNFS3_IPK_DIR)/opt/sbin $(UNFS3_IPK_DIR)/opt/etc/init.d
	$(STRIP_COMMAND) $(UNFS3_DIR)/unfsd -o $(UNFS3_IPK_DIR)/opt/sbin/unfsd
	install -m 755 $(SOURCE_DIR)/unfs3.rc $(UNFS3_IPK_DIR)/opt/etc/init.d/S56unfsd
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNFS3_IPK_DIR)

unfs3-ipk: $(UNFS3_IPK)

unfs3-clean:
	-make -C $(UNFS3_DIR) clean

unfs3-dirclean:
	rm -rf $(UNFS3_DIR) $(UNFS3_IPK_DIR) $(UNFS3_IPK)

unfs3-check: $(UNFS3_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UNFS3_IPK)
