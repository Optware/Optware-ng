#############################################################
#
# named server
#
#############################################################

## So far, untested, unproven.
## Add the --with-libtool to the configure call to 
## provoke the build error.

BIND_DIR:=$(BUILD_DIR)/bind

BIND_VERSION=9.3.0
BIND=bind-$(BIND_VERSION)
BIND_SITE=ftp://ftp.isc.org/isc/bind9/9.3.0/
#BIND_SITE=ipkg.nslu2-linux.org/downloads
BIND_SOURCE:=$(BIND).tar.gz
BIND_UNZIP=zcat
BIND_IPK=$(BUILD_DIR)/bind_$(BIND_VERSION)-1_armeb.ipk
BIND_IPK_DIR:=$(BUILD_DIR)/bind-$(BIND_VERSION)-ipk

$(DL_DIR)/$(BIND_SOURCE):
	$(WGET) -P $(DL_DIR) $(BIND_SITE)/$(BIND_SOURCE)

bind-source: $(DL_DIR)/$(BIND_SOURCE) $(BIND_PATCH)


# make changes to the BUILD options below.  
# We really want shared libraries, but the package environment isn't
# setup right for libtool. Shame on a small memory system...
# Another day.  
#--with-libtool 

$(BIND_DIR)/.configured: $(DL_DIR)/$(BIND_SOURCE)
	@rm -rf $(BUILD_DIR)/$(BIND) $(BIND_DIR)
	$(BIND_UNZIP) $(DL_DIR)/$(BIND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BIND) $(BIND_DIR)
	{ cd $(BIND_DIR) && \
	patch -b ./configure $(SOURCE_DIR)/bind/bind_configure_patch ; }
	{ cd $(BIND_DIR) && \
	./configure --prefix=$(BIND_DIR)/opt --with-openssl=$(STAGING_PREFIX) --without-libtool --sysconfdir=/opt/etc/named --localstatedir=/opt/var --with-randomdev=/dev/random --host=arm-linux --disable-getifaddrs ; }
	{ cd $(BIND_DIR) && \
	sed -i.bak -f $(SOURCE_DIR)/bind/bind_gengen_patch lib/dns/Makefile ; }
	touch $(BIND_DIR)/.configured

bind-unpack: $(BIND_DIR)/.configured

$(BIND_DIR)/.built: $(BIND_DIR)/.configured
	make -C $(BIND_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) HOSTCC=$(HOSTCC)
	touch $(BIND_DIR)/.built

bind: $(BIND_DIR)/.built

$(BIND_IPK): $(BIND_DIR)/.built
	install -d $(BIND_IPK_DIR)/CONTROL
	make -C $(BIND_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) install
	install -d $(BIND_DIR)/opt/bin $(BIND_IPK_DIR)/opt/bin
	install    $(BIND_DIR)/opt/bin/* $(BIND_IPK_DIR)/opt/bin
	install -d $(BIND_DIR)/opt/sbin $(BIND_IPK_DIR)/opt/sbin
	install    $(BIND_DIR)/opt/sbin/* $(BIND_IPK_DIR)/opt/sbin
	install -d $(BIND_DIR)/opt/lib $(BIND_IPK_DIR)/opt/lib
	install    $(BIND_DIR)/opt/lib/* $(BIND_IPK_DIR)/opt/lib
	install -d $(BIND_DIR)/opt/man $(BIND_IPK_DIR)/opt/man/man1
	install    $(BIND_DIR)/opt/man/man1/* $(BIND_IPK_DIR)/opt/man/man1
	install -d $(BIND_DIR)/opt/man $(BIND_IPK_DIR)/opt/man/man3
	install    $(BIND_DIR)/opt/man/man3/* $(BIND_IPK_DIR)/opt/man/man3
	install -d $(BIND_DIR)/opt/man $(BIND_IPK_DIR)/opt/man/man5
	install    $(BIND_DIR)/opt/man/man5/* $(BIND_IPK_DIR)/opt/man/man5
	install -d $(BIND_DIR)/opt/man $(BIND_IPK_DIR)/opt/man/man8
	install    $(BIND_DIR)/opt/man/man8/* $(BIND_IPK_DIR)/opt/man/man8
	install -d $(BIND_DIR)/opt/include/bind9 $(BIND_IPK_DIR)/opt/include/bind9
	install    $(BIND_DIR)/opt/include/bind9/* $(BIND_IPK_DIR)/opt/include/bind9
	install -d $(BIND_DIR)/opt/include/dns $(BIND_IPK_DIR)/opt/include/dns
	install    $(BIND_DIR)/opt/include/dns/* $(BIND_IPK_DIR)/opt/include/dns
	install -d $(BIND_DIR)/opt/include/dst $(BIND_IPK_DIR)/opt/include/dst
	install    $(BIND_DIR)/opt/include/dst/* $(BIND_IPK_DIR)/opt/include/dst
	install -d $(BIND_DIR)/opt/include/isc $(BIND_IPK_DIR)/opt/include/isc
	install    $(BIND_DIR)/opt/include/isc/* $(BIND_IPK_DIR)/opt/include/isc
	install -d $(BIND_DIR)/opt/include/isccc $(BIND_IPK_DIR)/opt/include/isccc
	install    $(BIND_DIR)/opt/include/isccc/* $(BIND_IPK_DIR)/opt/include/isccc
	install -d $(BIND_DIR)/opt/include/isccfg $(BIND_IPK_DIR)/opt/include/isccfg
	install    $(BIND_DIR)/opt/include/isccfg/* $(BIND_IPK_DIR)/opt/include/isccfg
	install -d $(BIND_DIR)/opt/include/lwres $(BIND_IPK_DIR)/opt/include/lwres
	install    $(BIND_DIR)/opt/include/lwres/* $(BIND_IPK_DIR)/opt/include/lwres
	install -d $(BIND_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SOURCE_DIR)/bind/S09named $(BIND_IPK_DIR)/opt/etc/init.d/S09named
	install -m 644 $(SOURCE_DIR)/bind/control  $(BIND_IPK_DIR)/CONTROL/control
	install -m 755 $(SOURCE_DIR)/bind/prerm $(BIND_IPK_DIR)/CONTROL/prerm
	install -m 755 $(SOURCE_DIR)/bind/postinst $(BIND_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BIND_IPK_DIR)

bind-ipk: $(BIND_IPK)

bind-clean:
	-make -C $(BIND_DIR) clean

bind-dirclean:
	rm -rf $(BIND_DIR) $(BIND_IPK_DIR) $(BIND_IPK)
