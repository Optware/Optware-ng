###########################################################
#
# ntpclient
#
###########################################################

#NTPCLIENT_SITE=http://doolittle.faludi.com/ntpclient
NTPCLIENT_SITE=http://ipkg.nslu2-linux.org/downloads
NTPCLIENT_VERSION=2003_194
NTPCLIENT_SOURCE=ntpclient_$(NTPCLIENT_VERSION).tar.gz
NTPCLIENT_DIR=ntpclient
NTPCLIENT_UNZIP=zcat

NTPCLIENT_IPK_VERSION=1

NTPCLIENT_CPPFLAGS=
NTPCLIENT_LDFLAGS=

NTPCLIENT_BUILD_DIR=$(BUILD_DIR)/ntpclient
NTPCLIENT_SOURCE_DIR=$(SOURCE_DIR)/ntpclient
NTPCLIENT_IPK_DIR=$(BUILD_DIR)/ntpclient-$(NTPCLIENT_VERSION)-ipk
NTPCLIENT_IPK=$(BUILD_DIR)/ntpclient_$(NTPCLIENT_VERSION)-$(NTPCLIENT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(NTPCLIENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(NTPCLIENT_SITE)/$(NTPCLIENT_SOURCE)

ntpclient-source: $(DL_DIR)/$(NTPCLIENT_SOURCE)

$(NTPCLIENT_BUILD_DIR)/.configured: $(DL_DIR)/$(NTPCLIENT_SOURCE)
	$(NTPCLIENT_UNZIP) $(DL_DIR)/$(NTPCLIENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	mv $(BUILD_DIR)/$(NTPCLIENT_DIR) $(NTPCLIENT_BUILD_DIR)
	touch $(NTPCLIENT_BUILD_DIR)/.configured

ntpclient-unpack: $(NTPCLIENT_BUILD_DIR)/.configured

$(NTPCLIENT_BUILD_DIR)/ntpclient: $(NTPCLIENT_BUILD_DIR)/.configured
	$(MAKE) -C $(NTPCLIENT_BUILD_DIR) ntpclient adjtimex CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 

ntpclient: $(NTPCLIENT_BUILD_DIR)/ntpclient

$(NTPCLIENT_IPK): $(NTPCLIENT_BUILD_DIR)/ntpclient
	install -d $(NTPCLIENT_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(NTPCLIENT_BUILD_DIR)/ntpclient -o $(NTPCLIENT_IPK_DIR)/opt/bin/ntpclient
	install -d $(NTPCLIENT_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(NTPCLIENT_BUILD_DIR)/adjtimex -o $(NTPCLIENT_IPK_DIR)/opt/sbin/adjtimex
	install -d $(NTPCLIENT_IPK_DIR)/CONTROL
	install -m 644 $(NTPCLIENT_SOURCE_DIR)/control $(NTPCLIENT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTPCLIENT_IPK_DIR)

ntpclient-ipk: $(NTPCLIENT_IPK)

ntpclient-clean:
	-$(MAKE) -C $(NTPCLIENT_BUILD_DIR) clean

ntpclient-dirclean:
	rm -rf $(BUILD_DIR)/$(NTPCLIENT_DIR) $(NTPCLIENT_BUILD_DIR) $(NTPCLIENT_IPK_DIR) $(NTPCLIENT_IPK)
