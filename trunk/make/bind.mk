#############################################################
#
# named server
#
#############################################################

BIND_VERSION=9.5.0-P2
BIND_SITE=ftp://ftp.isc.org/isc/bind9/$(BIND_VERSION)
BIND_SOURCE=bind-$(BIND_VERSION).tar.gz
BIND_DIR=bind-$(BIND_VERSION)
BIND_UNZIP=zcat
BIND_MAINTAINER=Louis Lagendijk <louis.lagendijk@gmail.com>
BIND_DESCRIPTION=Bind provides a full name server package, including zone masters, slaves, zone transfers, security multiple views.  This is THE reference implementation from ISC, which has roots all the way back to the TOPS-20 original.  It is over-kill, unless you have a complex environment.  Other utilities (for debugging, remote management) are also included.  Full documentation and developers' files are included in this kit, though you may wish they weren't.
BIND_SECTION=net
BIND_PRIORITY=optional
BIND_DEPENDS=openssl

BIND_IPK_VERSION=1

# BIND_PATCHES=$(BIND_SOURCE_DIR)/bind_configure_patch

ifeq ($(OPTWARE_TARGET), $(filter vt4, $(OPTWARE_TARGET)))
BIND_LDFLAGS=-ldl
endif

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
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(BIND_DIR) $(@D)
	$(BIND_UNZIP) $(DL_DIR)/$(BIND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BIND_PATCHES)"; then \
		cat $(BIND_PATCHES) | patch -d $(BUILD_DIR)/$(BIND_DIR) -p1; \
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
		--prefix=/opt \
		--with-libtool \
		--with-openssl=$(STAGING_PREFIX) \
		--sysconfdir=/opt/etc/named \
		--localstatedir=/opt/var \
		--with-randomdev=/dev/random \
		--disable-getifaddrs ; }
	touch $@

bind-unpack: $(BIND_BUILD_DIR)/.configured

$(BIND_BUILD_DIR)/.built: $(BIND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) BUILD_CC=$(HOSTCC)
	touch $@

bind: $(BIND_BUILD_DIR)/.built

$(BIND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
	rm -rf $(BIND_IPK_DIR) $(BIND_IPK)
	$(MAKE) -C $(BIND_BUILD_DIR) DESTDIR=$(BIND_IPK_DIR) install
	$(STRIP_COMMAND) $(BIND_IPK_DIR)/opt/lib/*.so.*
	$(STRIP_COMMAND) \
		$(BIND_IPK_DIR)/opt/bin/dig \
		$(BIND_IPK_DIR)/opt/bin/host \
		$(BIND_IPK_DIR)/opt/bin/nslookup \
		$(BIND_IPK_DIR)/opt/bin/nsupdate \
		$(BIND_IPK_DIR)/opt/sbin/*
	# cp -p $(BIND_IPK_DIR)/opt/sbin/named $(BIND_IPK_DIR)/opt/sbin/named.exe
	rm -rf $(BIND_IPK_DIR)/opt/{man,include}
	rm -f $(BIND_IPK_DIR)/opt/lib/*.la $(BIND_IPK_DIR)/opt/lib/*.a
	install -d $(BIND_IPK_DIR)/opt/etc/init.d
	install -m 755 $(BIND_SOURCE_DIR)/S09named $(BIND_IPK_DIR)/opt/etc/init.d/S09named
	$(MAKE) $(BIND_IPK_DIR)/CONTROL/control
	install -m 755 $(BIND_SOURCE_DIR)/postinst $(BIND_IPK_DIR)/CONTROL/postinst
	install -m 755 $(BIND_SOURCE_DIR)/prerm    $(BIND_IPK_DIR)/CONTROL/prerm
	install -d $(BIND_IPK_DIR)/opt/etc/named
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BIND_IPK_DIR)

bind-ipk: $(BIND_IPK)

bind-clean:
	-$(MAKE) -C $(BIND_BUILD_DIR) clean

bind-dirclean:
	rm -rf $(BUILD_DIR)/$(BIND_BUILD_DIR) $(BIND_BUILD_DIR) $(BIND_IPK_DIR) $(BIND_IPK)

bind-check: $(BIND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BIND_IPK)
