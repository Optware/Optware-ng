#############################################################
#
# tcp_wrappers
#
#############################################################

TCPWRAPPERS_DIR:=$(BUILD_DIR)/tcp_wrappers

TCPWRAPPERS_VERSION=7.6
TCPWRAPPERS=tcp_wrappers_$(TCPWRAPPERS_VERSION)
TCPWRAPPERS_SITE=ftp://ftp.porcupine.org/pub/security/
TCPWRAPPERS_SOURCE:=$(TCPWRAPPERS).tar.gz
TCPWRAPPERS_UNZIP=zcat
TCPWRAPPERS_IPK=$(BUILD_DIR)/tcp_wrappers_$(TCPWRAPPERS_VERSION)-1_armeb.ipk
TCPWRAPPERS_IPK_DIR:=$(BUILD_DIR)/tcp_wrappers-$(TCPWRAPPERS_VERSION)-ipk
TCPWRAPPERS_PATCH=$(SOURCE_DIR)/tcp_wrappers.patch

$(DL_DIR)/$(TCPWRAPPERS_SOURCE):
	$(WGET) -P $(DL_DIR) $(TCPWRAPPERS_SITE)/$(TCPWRAPPERS_SOURCE)

tcpwrappers-source: $(DL_DIR)/$(TCPWRAPPERS_SOURCE)

$(TCPWRAPPERS_DIR)/.configured: $(DL_DIR)/$(TCPWRAPPERS_SOURCE)
	@rm -rf $(BUILD_DIR)/$(TCPWRAPPERS) $(TCPWRAPPERS_DIR)
	$(TCPWRAPPERS_UNZIP) $(DL_DIR)/$(TCPWRAPPERS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TCPWRAPPERS) $(TCPWRAPPERS_DIR)
	patch -d $(TCPWRAPPERS_DIR) < $(TCPWRAPPERS_PATCH)
	touch $(TCPWRAPPERS_DIR)/.configured

tcpwrappers-unpack: $(TCPWRAPPERS_DIR)/.configured

$(TCPWRAPPERS_DIR)/tcpd: $(TCPWRAPPERS_DIR)/.configured
	make -C $(TCPWRAPPERS_DIR) \
		CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) \
		REAL_DAEMON_DIR=/dev/null \
		linux

tcpwrappers: $(TCPWRAPPERS_DIR)/tcpd

$(TCPWRAPPERS_IPK): $(TCPWRAPPERS_DIR)/tcpd
	install -d $(TCPWRAPPERS_IPK_DIR)/CONTROL
	install -d $(TCPWRAPPERS_IPK_DIR)/opt/lib
	install -d $(TCPWRAPPERS_IPK_DIR)/opt/sbin
	install -d $(TCPWRAPPERS_IPK_DIR)/opt/share/man/man3
	install -d $(TCPWRAPPERS_IPK_DIR)/opt/share/man/man5
	install -d $(TCPWRAPPERS_IPK_DIR)/opt/share/man/man8
	install -d $(TCPWRAPPERS_IPK_DIR)/opt/libexec
	install -m 755 $(SOURCE_DIR)/tcpwrappers.control $(TCPWRAPPERS_IPK_DIR)/CONTROL/control
	install -m 755 $(TCPWRAPPERS_DIR)/tcpd  $(TCPWRAPPERS_IPK_DIR)/opt/libexec
	install -m 755 $(TCPWRAPPERS_DIR)/tcpdchk $(TCPWRAPPERS_IPK_DIR)/opt/sbin
	install -m 755 $(TCPWRAPPERS_DIR)/tcpdmatch $(TCPWRAPPERS_IPK_DIR)/opt/sbin
	install -m 755 $(TCPWRAPPERS_DIR)/tcpd*.8 $(TCPWRAPPERS_IPK_DIR)/opt/share/man/man8
	install -m 755 $(TCPWRAPPERS_DIR)/hosts_access.3 $(TCPWRAPPERS_IPK_DIR)/opt/share/man/man3
	install -m 755 $(TCPWRAPPERS_DIR)/hosts_access.5 $(TCPWRAPPERS_IPK_DIR)/opt/share/man/man5
	install -m 755 $(TCPWRAPPERS_DIR)/libwrap.a $(TCPWRAPPERS_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCPWRAPPERS_IPK_DIR)

tcpwrappers-ipk: $(TCPWRAPPERS_IPK)

tcpwrappers-clean:
	-make -C $(TCPWRAPPER_DIR) clean

tcpwrappers-dirclean:
	rm -rf $(TCPWRAPPERS_DIR) $(TCPWRAPPERS_DIR)
