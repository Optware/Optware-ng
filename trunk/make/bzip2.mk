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

BZIP2_IPK_VERSION=2

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
		PREFIX=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		-f Makefile \
		libbz2.a bzip2 bzip2recover
	$(MAKE) -C $(BZIP2_BUILD_DIR) \
		PREFIX=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		-f Makefile-libbz2_so

bzip2: $(BZIP2_BUILD_DIR)/bzip2

$(STAGING_LIB_DIR)/libbz2.a: $(BZIP2_BUILD_DIR)/bzip2
	install -d $(STAGING_INCLUDE_DIR)
	install -m 644 $(BZIP2_BUILD_DIR)/bzlib.h $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_LIB_DIR)
	install -m 644 $(BZIP2_BUILD_DIR)/libbz2.a $(STAGING_LIB_DIR)
	install -m 644 $(BZIP2_BUILD_DIR)/libbz2.so.$(BZIP2_LIB_VERSION) $(STAGING_LIB_DIR)
	cd $(STAGING_DIR)/opt/lib && ln -fs libbz2.so.$(BZIP2_LIB_VERSION) libbz2.so.1.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libbz2.so.$(BZIP2_LIB_VERSION) libbz2.so

bzip2-stage: $(STAGING_LIB_DIR)/libbz2.a

$(BZIP2_IPK): $(BZIP2_BUILD_DIR)/bzip2
	rm -rf $(BZIP2_IPK_DIR) $(BUILD_DIR)/bzip2_*_armeb.ipk
	install -d $(BZIP2_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(BZIP2_BUILD_DIR)/bzip2 -o $(BZIP2_IPK_DIR)/opt/bin/bzip2
	$(STRIP_COMMAND) $(BZIP2_BUILD_DIR)/bzip2recover -o $(BZIP2_IPK_DIR)/opt/bin/bzip2recover
	install -d $(BZIP2_IPK_DIR)/opt/include
	install -m 644 $(BZIP2_BUILD_DIR)/bzlib.h $(BZIP2_IPK_DIR)/opt/include
	install -d $(BZIP2_IPK_DIR)/opt/lib
	install -m 644 $(BZIP2_BUILD_DIR)/libbz2.a $(BZIP2_IPK_DIR)/opt/lib
	install -m 644 $(BZIP2_BUILD_DIR)/libbz2.so.$(BZIP2_LIB_VERSION) $(BZIP2_IPK_DIR)/opt/lib
	cd $(BZIP2_IPK_DIR)/opt/lib && ln -fs libbz2.so.$(BZIP2_LIB_VERSION) libbz2.so.1.0
	cd $(BZIP2_IPK_DIR)/opt/lib && ln -fs libbz2.so.$(BZIP2_LIB_VERSION) libbz2.so
	install -d $(BZIP2_IPK_DIR)/opt/doc/bzip2
	install -m 644 $(BZIP2_BUILD_DIR)/manual*.html $(BZIP2_IPK_DIR)/opt/doc/bzip2
	install -d $(BZIP2_IPK_DIR)/CONTROL
	install -m 644 $(BZIP2_SOURCE_DIR)/control $(BZIP2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BZIP2_IPK_DIR)

bzip2-ipk: bzip2-stage $(BZIP2_IPK)

bzip2-clean:
	-$(MAKE) -C $(BZIP2_BUILD_DIR) clean

bzip2-dirclean:
	rm -rf $(BUILD_DIR)/$(BZIP2_DIR) $(BZIP2_BUILD_DIR) $(BZIP2_IPK_DIR) $(BZIP2_IPK)
