#############################################################
#
# named server
#
#############################################################

BIND_SITE=ftp://ftp.isc.org/isc/bind9/9.3.0/
BIND_VERSION=9.3.0
BIND_SOURCE=bind-$(BIND_VERSION).tar.gz
BIND_DIR=bind-$(BIND_VERSION)
BIND_UNZIP=zcat

BIND_IPK_VERSION=1

BIND_PATCHES=$(BIND_SOURCE_DIR)/bind_configure_patch

BIND_BUILD_DIR=$(BUILD_DIR)/bind
BIND_SOURCE_DIR=$(SOURCE_DIR)/bind
BIND_IPK_DIR:=$(BUILD_DIR)/bind-$(BIND_VERSION)-ipk
BIND_IPK=$(BUILD_DIR)/bind_$(BIND_VERSION)-$(BIND_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(BIND_SOURCE):
	$(WGET) -P $(DL_DIR) $(BIND_SITE)/$(BIND_SOURCE)

bind-source: $(DL_DIR)/$(BIND_SOURCE) $(BIND_PATCHES)

$(BIND_BUILD_DIR)/.configured: $(DL_DIR)/$(BIND_SOURCE)
	rm -rf $(BUILD_DIR)/$(BIND_DIR) $(BIND_BUILD_DIR)
	$(BIND_UNZIP) $(DL_DIR)/$(BIND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(BIND_PATCHES) | patch -d $(BUILD_DIR)/$(BIND_DIR) -p1
	mv $(BUILD_DIR)/$(BIND_DIR) $(BIND_BUILD_DIR)
	{ cd $(BIND_BUILD_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libtool \
		--with-openssl=$(STAGING_PREFIX) \
		--sysconfdir=/opt/etc/named \
		--localstatedir=/opt/var \
		--with-randomdev=/dev/random \
		--disable-getifaddrs ; }
	{ cd $(BIND_BUILD_DIR) && \
	sed -i.bak -f $(BIND_SOURCE_DIR)/bind_gengen_patch lib/dns/Makefile ; }
	touch $(BIND_BUILD_DIR)/.configured

bind-unpack: $(BIND_BUILD_DIR)/.configured

$(BIND_BUILD_DIR)/.built: $(BIND_BUILD_DIR)/.configured
	$(MAKE) -C $(BIND_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) HOSTCC=$(HOSTCC)
	touch $(BIND_BUILD_DIR)/.built

bind: $(BIND_BUILD_DIR)/.built

# The extra copy of named is a hack -- the kit installer seems to be
# somewhat confused.
#
$(BIND_IPK): $(BIND_BUILD_DIR)/.built
	rm -rf $(BIND_IPK_DIR) $(BIND_IPK)
	$(MAKE) -C $(BIND_BUILD_DIR) DESTDIR=$(BIND_IPK_DIR) install
	$(STRIP) --strip-unneeded $(BIND_IPK_DIR)/opt/lib/*.so.*
	$(STRIP) --strip-unneeded $(BIND_IPK_DIR)/opt/bin/{dig,host,nslookup,nsupdate}
	$(STRIP) --strip-unneeded $(BIND_IPK_DIR)/opt/sbin/*
	cp -p $(BIND_IPK_DIR)/opt/sbin/named $(BIND_IPK_DIR)/opt/sbin/named.exe
	rm -rf $(BIND_IPK_DIR)/opt/{man,include}
	rm -f $(BIND_IPK_DIR)/opt/lib/*.{la,a}
	install -d $(BIND_IPK_DIR)/opt/etc/init.d
	install -m 755 $(BIND_SOURCE_DIR)/S09named $(BIND_IPK_DIR)/opt/etc/init.d/S09named
	install -d $(BIND_IPK_DIR)/CONTROL
	install -m 644 $(BIND_SOURCE_DIR)/control  $(BIND_IPK_DIR)/CONTROL/control
	install -m 755 $(BIND_SOURCE_DIR)/postinst $(BIND_IPK_DIR)/CONTROL/postinst
	install -m 755 $(BIND_SOURCE_DIR)/prerm    $(BIND_IPK_DIR)/CONTROL/prerm
	install -d $(BIND_IPK_DIR)/opt/etc/named
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BIND_IPK_DIR)

bind-ipk: $(BIND_IPK)

bind-clean:
	-$(MAKE) -C $(BIND_BUILD_DIR) clean

bind-dirclean:
	rm -rf $(BUILD_DIR)/$(BIND_BUILD_DIR) $(BIND_BUILD_DIR) $(BIND_IPK_DIR) $(BIND_IPK)
