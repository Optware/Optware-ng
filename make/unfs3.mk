#############################################################
#
# unfs3
#
#############################################################

UNFS3_DIR:=$(BUILD_DIR)/unfs3

UNFS3_VERSION=0.9.10
UNFS3=unfs3-$(UNFS3_VERSION)
UNFS3_SITE=http://aleron.dl.sourceforge.net/sourceforge/unfs3
UNFS3_SOURCE:=$(UNFS3).tar.gz
UNFS3_UNZIP=zcat
UNFS3_PATCH:=$(SOURCE_DIR)/unfs3.patch
UNFS3_IPK_VERSION=1
UNFS3_IPK=$(BUILD_DIR)/unfs3_$(UNFS3_VERSION)-$(UNFS3_IPK_VERSION)_armeb.ipk
UNFS3_IPK_DIR:=$(BUILD_DIR)/unfs3-$(UNFS3_VERSION)-ipk

$(DL_DIR)/$(UNFS3_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNFS3_SITE)/$(UNFS3_SOURCE)

unfs3-source: $(DL_DIR)/$(UNFS3_SOURCE) $(UNFS3_PATCH)


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
	install -d $(UNFS3_IPK_DIR)/CONTROL
	install -d $(UNFS3_IPK_DIR)/opt/sbin $(UNFS3_IPK_DIR)/opt/etc/init.d
	$(STRIP_COMMAND) $(UNFS3_DIR)/unfsd -o $(UNFS3_IPK_DIR)/opt/sbin/unfsd
	install -m 755 $(SOURCE_DIR)/unfs3.rc $(UNFS3_IPK_DIR)/opt/etc/init.d/S56unfsd
	install -m 644 $(SOURCE_DIR)/unfs3.control  $(UNFS3_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNFS3_IPK_DIR)

unfs3-ipk: $(UNFS3_IPK)

unfs3-clean:
	-make -C $(UNFS3_DIR) clean

unfs3-dirclean:
	rm -rf $(UNFS3_DIR) $(UNFS3_IPK_DIR) $(UNFS3_IPK)
