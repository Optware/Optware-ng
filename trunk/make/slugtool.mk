#############################################################
#
# slugtool
#
#############################################################

SLUGTOOL_DIR:=$(TOOL_BUILD_DIR)/slugtool

SLUGTOOL_SITE:=http://www.lantz.com/filemgmt_data/files/
SLUGTOOL_SOURCE:=slugtool.tar.gz
SLUGTOOL_UNZIP:=zcat

SLUGTOOL_PATCH:=$(SOURCE_DIR)/slugtool.patch

$(DL_DIR)/$(SLUGTOOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(SLUGTOOL_SITE)/$(SLUGTOOL_SOURCE)

slugtool-source: $(DL_DIR)/$(SLUGTOOL_SOURCE) $(SLUGTOOL_PATCH)

$(SLUGTOOL_DIR)/.configured: $(DL_DIR)/$(SLUGTOOL_SOURCE) $(SLUGTOOL_PATCH)
	@rm -rf $(SLUGTOOL_DIR)
	mkdir -p $(SLUGTOOL_DIR)
	$(SLUGTOOL_UNZIP) $(DL_DIR)/$(SLUGTOOL_SOURCE) | tar -C $(SLUGTOOL_DIR) -xvf -
	cat $(SLUGTOOL_PATCH) | patch -d $(SLUGTOOL_DIR) -p1
	touch $(SLUGTOOL_DIR)/.configured

slugtool-unpack: $(SLUGTOOL_DIR)/.configured

$(SLUGTOOL_DIR)/slugtool: $(SLUGTOOL_DIR)/.configured
	make -C $(SLUGTOOL_DIR) slugtool

$(STAGING_DIR)/bin/slugtool: $(SLUGTOOL_DIR)/slugtool
	mkdir -p $(STAGING_DIR)/bin
	install -m 755 $(SLUGTOOL_DIR)/slugtool $(STAGING_DIR)/bin/slugtool

slugtool: $(STAGING_DIR)/bin/slugtool

slugtool-install: slugtool

slugtool-clean:
	-make -C $(SLUGTOOL_DIR) clean
	rm -f $(STAGING_DIR)/bin/slugtool

slugtool-dirclean:
	rm -rf $(SLUGTOOL_DIR)

SLUGTOOL := PATH=$(TARGET_PATH) slugtool
