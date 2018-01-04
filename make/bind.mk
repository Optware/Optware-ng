#############################################################
#
# named server
#
#############################################################

#BIND_UPSTREAM_VERSION=9.11.1-P3
BIND_UPSTREAM_VERSION=9.11.2
#BIND_VERSION=9.11.1.3
BIND_VERSION=9.11.2
BIND_SITE=ftp://ftp.isc.org/isc/bind9/$(BIND_UPSTREAM_VERSION)
BIND_SOURCE=bind-$(BIND_UPSTREAM_VERSION).tar.gz
BIND_DIR=bind-$(BIND_UPSTREAM_VERSION)
BIND_UNZIP=zcat
BIND_MAINTAINER=Louis Lagendijk <louis.lagendijk@gmail.com>
BIND_DESCRIPTION=Bind provides a full name server package, including zone masters, slaves, zone transfers, security multiple views.  This is THE reference implementation from ISC, which has roots all the way back to the TOPS-20 original.  It is over-kill, unless you have a complex environment.  Other utilities (for debugging, remote management) are also included.  Full documentation and developers' files are included in this kit, though you may wish they weren't.
BIND_SECTION=net
BIND_PRIORITY=optional
BIND_DEPENDS=openssl, libcap, busybox-base

BIND_IPK_VERSION=3

BIND_PATCHES=$(BIND_SOURCE_DIR)/libtool.patch

ifeq ($(OPTWARE_TARGET), $(filter vt4, $(OPTWARE_TARGET)))
BIND_LDFLAGS=-ldl
endif

BIND_CONFIG_ARGS ?= $(strip \
$(if $(filter cs05q1armel cs05q3armel syno-e500, $(OPTWARE_TARGET)), --disable-epoll, \
$(if $(filter module-init-tools, $(PACKAGES)), --enable-epoll, \
--disable-epoll)))

BIND_BUILD_DIR=$(BUILD_DIR)/bind
BIND_SOURCE_DIR=$(SOURCE_DIR)/bind
BIND_IPK_DIR:=$(BUILD_DIR)/bind-$(BIND_VERSION)-ipk
BIND_IPK=$(BUILD_DIR)/bind_$(BIND_VERSION)-$(BIND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bind-source bind-unpack bind bind-stage bind-ipk bind-clean bind-dirclean bind-check

$(DL_DIR)/$(BIND_SOURCE):
	$(WGET) -P $(@D) $(BIND_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

bind-source: $(DL_DIR)/$(BIND_SOURCE) $(BIND_PATCHES)

$(BIND_BUILD_DIR)/.configured: $(DL_DIR)/$(BIND_SOURCE) make/bind.mk
	$(MAKE) openssl-stage libcap-stage
	rm -rf $(BUILD_DIR)/$(BIND_DIR) $(@D)
	$(BIND_UNZIP) $(DL_DIR)/$(BIND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BIND_PATCHES)"; then \
		cat $(BIND_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(BIND_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(BIND_DIR) $(@D)
	{ cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BIND_LDFLAGS)" \
		BUILD_CC=$(HOSTCC) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		$(BIND_CONFIG_ARGS) \
		--prefix=$(TARGET_PREFIX) \
		--with-libtool \
		--with-openssl=$(STAGING_PREFIX) \
		--with-ecdsa \
		--with-gost \
		--without-libxml2 \
		--sysconfdir=$(TARGET_PREFIX)/etc/named \
		--localstatedir=$(TARGET_PREFIX)/var \
		--with-randomdev=/dev/random \
		--disable-getifaddrs \
		--enable-filter-aaaa ; }
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bind-unpack: $(BIND_BUILD_DIR)/.configured

$(BIND_BUILD_DIR)/.built: $(BIND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) BUILD_CC=$(HOSTCC) EXT_CFLAGS="$(STAGING_CPPFLAGS)"
	touch $@

bind: $(BIND_BUILD_DIR)/.built

$(BIND_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: bind" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BIND_PRIORITY)" >>$@
	@echo "Section: $(BIND_SECTION)" >>$@
	@echo "Version: $(BIND_VERSION)-$(BIND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BIND_MAINTAINER)" >>$@
	@echo "Source: $(BIND_SITE)/$(BIND_SOURCE)" >>$@
	@echo "Description: $(BIND_DESCRIPTION)" >>$@
	@echo "Depends: $(BIND_DEPENDS)" >>$@

# The extra copy of named is a hack -- the kit installer seems to be
# somewhat confused.
#
$(BIND_IPK): $(BIND_BUILD_DIR)/.built
	rm -rf $(BIND_IPK_DIR) $(BUILD_DIR)/bind_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BIND_BUILD_DIR) DESTDIR=$(BIND_IPK_DIR) install
	$(STRIP_COMMAND) $(BIND_IPK_DIR)$(TARGET_PREFIX)/lib/*.so.*
	$(STRIP_COMMAND) \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/dig \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/host \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/nslookup \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/nsupdate \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/arpaname \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/delv \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/mdig \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/bin/named-rrchecker \
		$(BIND_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	# cp -p $(BIND_IPK_DIR)$(TARGET_PREFIX)/sbin/named $(BIND_IPK_DIR)$(TARGET_PREFIX)/sbin/named.exe
	rm -rf $(BIND_IPK_DIR)$(TARGET_PREFIX)/{man,include}
	rm -f $(BIND_IPK_DIR)$(TARGET_PREFIX)/lib/*.la $(BIND_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(INSTALL) -d $(BIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(BIND_SOURCE_DIR)/S09named $(BIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S09named
	$(MAKE) $(BIND_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(BIND_SOURCE_DIR)/postinst $(BIND_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(BIND_SOURCE_DIR)/prerm    $(BIND_IPK_DIR)/CONTROL/prerm
	$(INSTALL) -d $(BIND_IPK_DIR)$(TARGET_PREFIX)/etc/named
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BIND_IPK_DIR)

bind-ipk: $(BIND_IPK)

bind-clean:
	-$(MAKE) -C $(BIND_BUILD_DIR) clean

bind-dirclean:
	rm -rf $(BUILD_DIR)/$(BIND_BUILD_DIR) $(BIND_BUILD_DIR) $(BIND_IPK_DIR) $(BIND_IPK)

bind-check: $(BIND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
