###########################################################
#
# rsync
#
###########################################################

RSYNC_DIR=$(BUILD_DIR)/rsync
RSYNC_SOURCE_DIR=$(SOURCE_DIR)/rsync

RSYNC_VERSION=2.6.3
RSYNC=rsync-$(RSYNC_VERSION)
RSYNC_SITE=http://rsync.samba.org/ftp/rsync/
RSYNC_SOURCE=$(RSYNC).tar.gz
RSYNC_PATCH:=$(RSYNC_SOURCE_DIR)/rsync.patch
RSYNC_UNZIP=zcat

RSYNC_IPK_VERSION=5

RSYNC_IPK=$(BUILD_DIR)/rsync_$(RSYNC_VERSION)-$(RSYNC_IPK_VERSION)_armeb.ipk
RSYNC_IPK_DIR=$(BUILD_DIR)/rsync-$(RSYNC_VERSION)-ipk

$(DL_DIR)/$(RSYNC_SOURCE):
	$(WGET) -P $(DL_DIR) $(RSYNC_SITE)/$(RSYNC_SOURCE)

rsync-source: $(DL_DIR)/$(RSYNC_SOURCE)

$(RSYNC_DIR)/.source: $(DL_DIR)/$(RSYNC_SOURCE) $(RSYNC_PATCH)
	$(RSYNC_UNZIP) $(DL_DIR)/$(RSYNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	patch -d $(BUILD_DIR)/$(RSYNC) -p1 < $(RSYNC_PATCH)
	mv $(BUILD_DIR)/rsync-$(RSYNC_VERSION) $(RSYNC_DIR)
	touch $(RSYNC_DIR)/.source

$(RSYNC_DIR)/.configured: $(RSYNC_DIR)/.source
	(cd $(RSYNC_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt \
		--with-included-popt \
		--with-rsyncd-conf=/opt/etc/rsyncd.conf \
	);
	touch $(RSYNC_DIR)/.configured

$(RSYNC_DIR)/rsync: $(RSYNC_DIR)/.configured
	$(MAKE) -C $(RSYNC_DIR)

rsync: $(RSYNC_DIR)/rsync

$(RSYNC_IPK): $(RSYNC_DIR)/rsync
	rm -rf $(RSYNC_IPK_DIR) $(BUILD_DIR)/rsync_*_armeb.ipk
	mkdir -p $(RSYNC_IPK_DIR)/CONTROL
	mkdir -p $(RSYNC_IPK_DIR)/opt/etc/init.d
	install -d $(RSYNC_IPK_DIR)/opt/bin
	cp $(RSYNC_SOURCE_DIR)/control $(RSYNC_IPK_DIR)/CONTROL/control
	cp $(RSYNC_SOURCE_DIR)/postinst $(RSYNC_IPK_DIR)/CONTROL/postinst
	cp $(RSYNC_SOURCE_DIR)/prerm $(RSYNC_IPK_DIR)/CONTROL/prerm
	$(STRIP_COMMAND) $(RSYNC_DIR)/rsync -o $(RSYNC_IPK_DIR)/opt/bin/rsync
#	install -m 755 -D $(RSYNC_DIR)/rsync $(RSYNC_IPK_DIR)/opt/bin/rsync
	touch $(RSYNC_IPK_DIR)/opt/etc/rsyncd.secrets
	chmod 600 $(RSYNC_IPK_DIR)/opt/etc/rsyncd.secrets
	install -m 644 -D $(RSYNC_SOURCE_DIR)/rsyncd.conf $(RSYNC_IPK_DIR)/opt/etc/rsyncd.conf
	install -m 755 -D $(RSYNC_SOURCE_DIR)/rc.rsyncd $(RSYNC_IPK_DIR)/opt/etc/init.d/S57rsyncd
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RSYNC_IPK_DIR)

rsync-ipk: $(RSYNC_IPK)

rsync-source: $(DL_DIR)/$(RSYNC_SOURCE)

rsync-clean:
	-$(MAKE) -C $(RSYNC_DIR) uninstall
	-$(MAKE) -C $(RSYNC_DIR) clean

rsync-distclean:
	-rm $(RSYNC_DIR)/.configured
	-$(MAKE) -C $(RSYNC_DIR) distclean

rsync-dirclean:
	rm -rf $(RSYNC_DIR) $(RSYNC_IPK_DIR) $(RSYNC_IPK)
