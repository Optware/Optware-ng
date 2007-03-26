#############################################################
#
# slugtool
#
#############################################################

SLUGTOOL_SITE=http://www.lantz.com/filemgmt_data/files/
SLUGTOOL_SOURCE=slugtool.tar.gz
SLUGTOOL_DIR=slugtool
SLUGTOOL_UNZIP=zcat

SLUGTOOL_PATCH=$(SLUGTOOL_SOURCE_DIR)/redboot_typo.patch

SLUGTOOL_BUILD_DIR=$(TOOL_BUILD_DIR)/slugtool
SLUGTOOL_SOURCE_DIR=$(SOURCE_DIR)/slugtool

$(DL_DIR)/$(SLUGTOOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(SLUGTOOL_SITE)/$(SLUGTOOL_SOURCE)

slugtool-source: $(DL_DIR)/$(SLUGTOOL_SOURCE) $(SLUGTOOL_PATCH)

$(SLUGTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(SLUGTOOL_SOURCE) $(SLUGTOOL_PATCH)
	@rm -rf $(SLUGTOOL_BUILD_DIR)
	mkdir -p $(SLUGTOOL_BUILD_DIR)
	$(SLUGTOOL_UNZIP) $(DL_DIR)/$(SLUGTOOL_SOURCE) | tar -C $(SLUGTOOL_BUILD_DIR) -xvf -
	cat $(SLUGTOOL_PATCH) | patch -d $(SLUGTOOL_BUILD_DIR) -p1
	touch $(SLUGTOOL_BUILD_DIR)/.configured

slugtool-unpack: $(SLUGTOOL_BUILD_DIR)/.configured

$(SLUGTOOL_BUILD_DIR)/slugtool: $(SLUGTOOL_BUILD_DIR)/.configured
	make -C $(SLUGTOOL_BUILD_DIR) slugtool

$(STAGING_DIR)/bin/slugtool: $(SLUGTOOL_BUILD_DIR)/slugtool
	install -d $(STAGING_DIR)/bin
	install -m 755 $(SLUGTOOL_BUILD_DIR)/slugtool $(STAGING_DIR)/bin/slugtool

slugtool: $(STAGING_DIR)/bin/slugtool

slugtool-install: slugtool

slugtool-clean:
	-make -C $(SLUGTOOL_BUILD_DIR) clean

slugtool-dirclean:
	rm -rf $(SLUGTOOL_BUILD_DIR)
	rm -f $(STAGING_DIR)/bin/slugtool

SLUGTOOL = PATH=$(TARGET_PATH) slugtool
