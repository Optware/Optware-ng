###########################################################
#
# bzip2
#
###########################################################

BZIP2_SITE=ftp://sources.redhat.com/pub/bzip2/v102/
BZIP2_VERSION=1.0.2
BZIP2_LIB_VERSION:=1.0.2
BZIP2_SOURCE=bzip2-$(BZIP2_VERSION).tar.gz
BZIP2_DIR=bzip2-$(BZIP2_VERSION)
BZIP2_UNZIP=zcat

BZIP2_IPK_VERSION=1

BZIP2_BUILD_DIR=$(BUILD_DIR)/bzip2
BZIP2_SOURCE_DIR=$(SOURCE_DIR)/bzip2
BZIP2_IPK=$(BUILD_DIR)/bzip2_$(BZIP2_VERSION)-$(BZIP2_IPK_VERSION)_armeb.ipk
BZIP2_IPK_DIR=$(BUILD_DIR)/bzip2-$(BZIP2_VERSION)-ipk


$(DL_DIR)/$(BZIP2_SOURCE):
	$(WGET) -P $(DL_DIR) $(BZIP2_SITE)/$(BZIP2_SOURCE)

bzip2-source: $(DL_DIR)/$(BZIP2_SOURCE)

$(BZIP2_BUILD_DIR)/.configured: $(DL_DIR)/$(BZIP2_SOURCE)
	$(BZIP2_UNZIP) $(DL_DIR)/$(BZIP2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BZIP2_DIR) $(BZIP2_BUILD_DIR)
	touch $(BZIP2_BUILD_DIR)/.configured

bzip2-unpack: $(BZIP2_BUILD_DIR)/.configured

$(BZIP2_BUILD_DIR)/bzip2: $(BZIP2_BUILD_DIR)/.configured
	$(MAKE) -C $(BZIP2_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		libbz2.a bzip2 bzip2recover

bzip2: $(BZIP2_BUILD_DIR)/bzip2

$(STAGING_DIR)/opt/lib/libbz2.a: $(BZIP2_BUILD_DIR)/bzip2
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(BZIP2_BUILD_DIR)/bzlib.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(BZIP2_BUILD_DIR)/libbz2.a $(STAGING_DIR)/opt/lib

bzip2-stage: $(STAGING_DIR)/opt/lib/libbz2.a

$(BZIP2_IPK): $(BZIP2_BUILD_DIR)/bzip2
	install -d $(BZIP2_IPK_DIR)/opt/bin
	$(STRIP) $(BZIP2_BUILD_DIR)/bzip2 -o $(BZIP2_IPK_DIR)/opt/bin/bzip2
	$(STRIP) $(BZIP2_BUILD_DIR)/bzip2recover -o $(BZIP2_IPK_DIR)/opt/bin/bzip2recover
	install -d $(BZIP2_IPK_DIR)/opt/lib
	install -m 644 $(BZIP2_BUILD_DIR)/libbz2.a $(BZIP2_IPK_DIR)/opt/lib
	install -d $(BZIP2_IPK_DIR)/opt/doc/bzip2
	install -m 644 $(BZIP2_BUILD_DIR)/manual*.html $(BZIP2_IPK_DIR)/opt/doc/bzip2
	install -d $(BZIP2_IPK_DIR)/CONTROL
	install -m 644 $(BZIP2_SOURCE_DIR)/control $(BZIP2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BZIP2_IPK_DIR)

bzip2-ipk: bzip2-stage $(BZIP2_IPK)

bzip2-clean:
	-$(MAKE) -C $(BZIP2_BUILD_DIR) clean

bzip2-dirclean: bzip2-clean
	rm -rf $(BZIP2_BUILD_DIR) $(BZIP2_IPK_DIR) $(BZIP2_IPK)
