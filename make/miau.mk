###########################################################
#
# miau
#
###########################################################

MIAU_SITE=http://aleron.dl.sourceforge.net/sourceforge/miau
MIAU_VERSION=0.5.3
MIAU_SOURCE=miau-$(MIAU_VERSION).tar.gz
MIAU_DIR=miau-$(MIAU_VERSION)
MIAU_UNZIP=zcat

MIAU_IPK_VERSION=3

MIAU_CPPFLAGS=
MIAU_LDFLAGS=

MIAU_BUILD_DIR=$(BUILD_DIR)/miau
MIAU_SOURCE_DIR=$(SOURCE_DIR)/miau
MIAU_IPK_DIR=$(BUILD_DIR)/miau-$(MIAU_VERSION)-ipk
MIAU_IPK=$(BUILD_DIR)/miau_$(MIAU_VERSION)-$(MIAU_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(MIAU_SOURCE):
	$(WGET) -P $(DL_DIR) $(MIAU_SITE)/$(MIAU_SOURCE)

miau-source: $(DL_DIR)/$(MIAU_SOURCE)

$(MIAU_BUILD_DIR)/.configured: $(DL_DIR)/$(MIAU_SOURCE)
	$(MIAU_UNZIP) $(DL_DIR)/$(MIAU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(MIAU_DIR) $(MIAU_BUILD_DIR)
	(cd $(MIAU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MIAU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MIAU_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt	\
		--enable-dccbounce \
		--enable-automode \
		--enable-releasenick \
		--enable-ctcp-replies \
		--enable-mkpasswd \
		--enable-uptime \
		--enable-chanlog \
		--enable-privlog \
		--enable-onconnect \
		--enable-empty-awaymsg \
		--enable-enduserdebug \
		--enable-pingstat \
		--enable-dumpstatus \
	)
	touch $(MIAU_BUILD_DIR)/.configured

miau-unpack: $(MIAU_BUILD_DIR)/.configured

$(MIAU_BUILD_DIR)/src/miau: $(MIAU_BUILD_DIR)/.configured
	$(MAKE) -C $(MIAU_BUILD_DIR)

miau: $(MIAU_BUILD_DIR)/src/miau

$(MIAU_IPK): $(MIAU_BUILD_DIR)/src/miau
	install -d $(MIAU_IPK_DIR)/opt/bin
	$(STRIP) $(MIAU_BUILD_DIR)/src/miau -o $(MIAU_IPK_DIR)/opt/bin/miau
	install -d $(MIAU_IPK_DIR)/opt/doc/miau
	install -m 644 $(MIAU_BUILD_DIR)/misc/miaurc $(MIAU_IPK_DIR)/opt/doc/miau/miaurc
	install -d $(MIAU_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MIAU_SOURCE_DIR)/rc.miau $(MIAU_IPK_DIR)/opt/etc/init.d/S52miau
	install -d $(MIAU_IPK_DIR)/CONTROL
	install -m 644 $(MIAU_SOURCE_DIR)/control $(MIAU_IPK_DIR)/CONTROL/control
	install -m 644 $(MIAU_SOURCE_DIR)/postinst $(MIAU_IPK_DIR)/CONTROL/postinst
	install -m 644 $(MIAU_SOURCE_DIR)/prerm $(MIAU_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MIAU_IPK_DIR)

miau-ipk: $(MIAU_IPK)

miau-clean:
	-$(MAKE) -C $(MIAU_BUILD_DIR) clean

miau-dirclean: miau-clean
	rm -rf $(MIAU_BUILD_DIR) $(MIAU_IPK_DIR) $(MIAU_IPK)
