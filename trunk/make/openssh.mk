#############################################################
#
# openssh
#
#############################################################

OPENSSH_SITE=http://openbsd.mirrors.pair.com/OpenSSH/portable
OPENSSH_VERSION=3.8p1
OPENSSH_SOURCE=openssh-$(OPENSSH_VERSION).tar.gz
OPENSSH_DIR=openssh-$(OPENSSH_VERSION)
OPENSSH_UNZIP=zcat

OPENSSH_IPK_VERSION=3

OPENSSH_PATCHES=$(OPENSSH_SOURCE_DIR)/Makefile.patch \
		$(OPENSSH_SOURCE_DIR)/configure.patch

OPENSSH_BUILD_DIR=$(BUILD_DIR)/openssh
OPENSSH_SOURCE_DIR=$(SOURCE_DIR)/openssh
OPENSSH_IPK_DIR:=$(BUILD_DIR)/openssh-$(OPENSSH_VERSION)-ipk
OPENSSH_IPK=$(BUILD_DIR)/openssh_$(OPENSSH_VERSION)-$(OPENSSH_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(OPENSSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENSSH_SITE)/$(OPENSSH_SOURCE)

openssh-source: $(DL_DIR)/$(OPENSSH_SOURCE) $(OPENSSH_PATCHES)

$(OPENSSH_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSSH_SOURCE) $(OPENSSH_PATCHES)
	$(MAKE) zlib-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(OPENSSH_DIR) $(OPENSSH_BUILD_DIR)
	$(OPENSSH_UNZIP) $(DL_DIR)/$(OPENSSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(OPENSSH_PATCHES) | patch -d $(BUILD_DIR)/$(OPENSSH_DIR) -p1
	mv $(BUILD_DIR)/$(OPENSSH_DIR) $(OPENSSH_BUILD_DIR)
	(cd $(OPENSSH_BUILD_DIR); rm -rf config.cache; autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CROSS)gcc \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc/openssh \
		--with-zlib=$(STAGING_DIR)/opt \
		--with-ssl-dir=$(STAGING_DIR)/opt \
		--with-md5-passwords=yes \
		--with-default-path="/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
		--with-privsep-user=nobody \
		--disable-lastlog --disable-utmp \
		--disable-utmpx --disable-wtmp --disable-wtmpx \
		--without-x \
		--with-xauth=/opt/bin/xauth \
	);
	touch  $(OPENSSH_BUILD_DIR)/.configured

openssh-unpack: $(OPENSSH_BUILD_DIR)/.configured

$(OPENSSH_BUILD_DIR)/ssh: $(OPENSSH_BUILD_DIR)/.configured
	$(MAKE) -C $(OPENSSH_BUILD_DIR)
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/scp
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/sftp
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/sftp-server
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-add
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-agent
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-keygen
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-keyscan
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-keysign
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-rand-helper
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/sshd

openssh: openssl-stage $(OPENSSH_BUILD_DIR)/ssh

$(OPENSSH_IPK): $(OPENSSH_BUILD_DIR)/ssh
	rm -rf $(OPENSSH_IPK_DIR) $(BUILD_DIR)/openssh_*_$(TARGET_ARCH).ipk
	$(MAKE) DESTDIR=$(OPENSSH_IPK_DIR) -C $(OPENSSH_BUILD_DIR) install-files
	rm -rf $(OPENSSH_IPK_DIR)/opt/share
	install -d $(OPENSSH_IPK_DIR)/opt/etc/init.d/
	install -m 755 $(OPENSSH_SOURCE_DIR)/rc.openssh $(OPENSSH_IPK_DIR)/opt/etc/init.d/S40sshd
	install -d $(OPENSSH_IPK_DIR)/CONTROL
	install -m 644 $(OPENSSH_SOURCE_DIR)/control $(OPENSSH_IPK_DIR)/CONTROL/control
	install -m 644 $(OPENSSH_SOURCE_DIR)/postinst $(OPENSSH_IPK_DIR)/CONTROL/postinst
	install -m 644 $(OPENSSH_SOURCE_DIR)/prerm $(OPENSSH_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSH_IPK_DIR)

openssh-ipk: openssl-stage $(OPENSSH_IPK)

openssh-clean: 
	-$(MAKE) -C $(OPENSSH_BUILD_DIR) clean

openssh-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSSH_DIR) $(OPENSSH_BUILD_DIR) $(OPENSSH_IPK_DIR) $(OPENSSH_IPK)
