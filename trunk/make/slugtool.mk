SLUGTOOL=slugtool
SLUGTOOL_SITE=http://www.lantz.com/filemgmt_data/files/

$(DL_DIR)/$(SLUGTOOL).tar.gz:
	cd $(DL_DIR) && $(WGET) $(SLUGTOOL_SITE)/$(SLUGTOOL).tar.gz

$(BUILD_DIR)/slugtool/slugtool.c: $(DL_DIR)/$(SLUGTOOL).tar.gz $(SOURCE_DIR)/slugtool.patch
	@rm -rf $(BUILD_DIR)/$(SLUGTOOL)
	mkdir $(BUILD_DIR)/$(SLUGTOOL)
	tar zxf $(DL_DIR)/$(SLUGTOOL).tar.gz -C $(BUILD_DIR)/slugtool
	patch -d $(BUILD_DIR)/$(SLUGTOOL) -p1 < $(SOURCE_DIR)/slugtool.patch

$(BUILD_DIR)/slugtool/slugtool: $(BUILD_DIR)/slugtool/slugtool.c
	make -C $(BUILD_DIR)/slugtool slugtool CC=$(HOSTCC)

$(FIRMWARE_DIR)/slugtool: $(BUILD_DIR)/slugtool/slugtool
	install -m 755 $(BUILD_DIR)/slugtool/slugtool $(FIRMWARE_DIR)/slugtool

slugtool: $(FIRMWARE_DIR)/slugtool

slugtool-install: slugtool

slugtool-clean:
	-make -C $(BUILD_DIR)/slugtool clean
