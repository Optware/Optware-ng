###########################################################
#
# rsync
#
###########################################################

RSYNC_SITE=http://rsync.samba.org/ftp/rsync
RSYNC_VERSION=2.6.3
RSYNC_SOURCE=rsync-$(RSYNC_VERSION).tar.gz
RSYNC_DIR=rsync-$(RSYNC_VERSION)
RSYNC_UNZIP=zcat

RSYNC_IPK_VERSION=6

RSYNC_CONFFILES=/opt/etc/rsyncd.conf /opt/etc/init.d/S57rsyncd

RSYNC_PATCHES=$(RSYNC_SOURCE_DIR)/rsync.patch

RSYNC_CPPFLAGS=
RSYNC_LDFLAGS=

RSYNC_BUILD_DIR=$(BUILD_DIR)/rsync
RSYNC_SOURCE_DIR=$(SOURCE_DIR)/rsync
RSYNC_IPK_DIR=$(BUILD_DIR)/rsync-$(RSYNC_VERSION)-ipk
RSYNC_IPK=$(BUILD_DIR)/rsync_$(RSYNC_VERSION)-$(RSYNC_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(RSYNC_SOURCE):
	$(WGET) -P $(DL_DIR) $(RSYNC_SITE)/$(RSYNC_SOURCE)

rsync-source: $(DL_DIR)/$(RSYNC_SOURCE) $(RSYNC_PATCHES)

$(RSYNC_BUILD_DIR)/.configured: $(DL_DIR)/$(RSYNC_SOURCE) $(RSYNC_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RSYNC_DIR) $(RSYNC_BUILD_DIR)
	$(RSYNC_UNZIP) $(DL_DIR)/$(RSYNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(RSYNC_PATCHES) | patch -d $(BUILD_DIR)/$(RSYNC_DIR) -p1
	mv $(BUILD_DIR)/$(RSYNC_DIR) $(RSYNC_BUILD_DIR)
	(cd $(RSYNC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RSYNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RSYNC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-included-popt \
		--with-rsyncd-conf=/opt/etc/rsyncd.conf \
		--disable-nls \
	)
	touch $(RSYNC_BUILD_DIR)/.configured

rsync-unpack: $(RSYNC_BUILD_DIR)/.configured

$(RSYNC_BUILD_DIR)/.built: $(RSYNC_BUILD_DIR)/.configured
	rm -f $(RSYNC_BUILD_DIR)/.built
	$(MAKE) -C $(RSYNC_BUILD_DIR)
	touch $(RSYNC_BUILD_DIR)/.built

rsync: $(RSYNC_BUILD_DIR)/.built

$(RSYNC_BUILD_DIR)/.staged: $(RSYNC_BUILD_DIR)/.built
	rm -f $(RSYNC_BUILD_DIR)/.staged
	$(MAKE) -C $(RSYNC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	$(STRIP_COMMAND) $(STAGING_DIR)/opt/bin/rsync
	touch $(RSYNC_BUILD_DIR)/.staged

rsync-stage: $(RSYNC_BUILD_DIR)/.staged

$(RSYNC_IPK): $(RSYNC_BUILD_DIR)/.built
	rm -rf $(RSYNC_IPK_DIR) $(BUILD_DIR)/rsync_*_armeb.ipk
	$(MAKE) -C $(RSYNC_BUILD_DIR) DESTDIR=$(RSYNC_IPK_DIR) install
	$(STRIP_COMMAND) $(RSYNC_IPK_DIR)/opt/bin/rsync
	find $(RSYNC_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	install -d $(RSYNC_IPK_DIR)/opt/etc
	install -m 644 $(RSYNC_SOURCE_DIR)/rsyncd.conf $(RSYNC_IPK_DIR)/opt/etc/rsyncd.conf
	touch $(RSYNC_IPK_DIR)/opt/etc/rsyncd.secrets
	chmod 600 $(RSYNC_IPK_DIR)/opt/etc/rsyncd.secrets
	install -d $(RSYNC_IPK_DIR)/opt/etc/init.d
	install -m 755 $(RSYNC_SOURCE_DIR)/rc.rsyncd $(RSYNC_IPK_DIR)/opt/etc/init.d/S57rsyncd
	install -d $(RSYNC_IPK_DIR)/CONTROL
	install -m 644 $(RSYNC_SOURCE_DIR)/control $(RSYNC_IPK_DIR)/CONTROL/control
	install -m 755 $(RSYNC_SOURCE_DIR)/postinst $(RSYNC_IPK_DIR)/CONTROL/postinst
	install -m 755 $(RSYNC_SOURCE_DIR)/prerm $(RSYNC_IPK_DIR)/CONTROL/prerm
	echo $(RSYNC_CONFFILES) | sed -e 's/ /\n/g' > $(RSYNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RSYNC_IPK_DIR)

rsync-ipk: $(RSYNC_IPK)

rsync-clean:
	-$(MAKE) -C $(RSYNC_BUILD_DIR) clean

rsync-dirclean:
	rm -rf $(BUILD_DIR)/$(RSYNC_DIR) $(RSYNC_BUILD_DIR) $(RSYNC_IPK_DIR) $(RSYNC_IPK)
