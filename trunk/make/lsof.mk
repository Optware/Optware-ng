LSOF=lsof-4.72
LSOF_FILE=lsof_4.72.orig
LSOF_DSC=lsof_4.72-1.dsc
LSOF_SITE=http://http.us.debian.org/debian/pool/main/l/lsof

$(DL_DIR)/$(LSOF_FILE).tar.gz:
	cd $(DL_DIR) && $(WGET) $(LSOF_SITE)/$(LSOF_FILE).tar.gz

$(DL_DIR)/$(LSOF_DSC):
	cd $(DL_DIR) && $(WGET) $(LSOF_SITE)/$(LSOF_DSC)

$(LSOF)-download: $(DL_DIR)/$(LSOF_FILE).tar.gz $(DL_DIR)/$(LSOF_DSC)
	cd $(DL_DIR) && \
		if [ `grep lsof_4.72.orig.tar.gz $(LSOF_DSC) | cut -f 2 -d " "` != \
			`md5sum $(DL_DIR)/$(LSOF_FILE).tar.gz | cut -f 4 -d " "` ] ; then \
			echo "md5sum is not a match, aborting." ; \
			exit 2; \
		else \
			echo "md5sum verified." ; \
		fi

$(LSOF)-unpack: $(LSOF)-download
	tar xzf $(DL_DIR)/$(LSOF_FILE).tar.gz -C $(BUILD_DIR)

$(SOURCE_DIR)/$(LSOF)-patch: $(SOURCE_DIR)/$(LSOF).patch-1 $(SOURCE_DIR)/$(LSOF).patch-2
	@echo "Verified patch files"

$(LSOF)-configure: $(LSOF)-unpack $(SOURCE_DIR)/$(LSOF)-patch
	cd $(BUILD_DIR)/$(LSOF) && echo "n\ny\ny\ny\nn\nn\ny\n" | ./Configure linux
	patch -d $(BUILD_DIR)/$(LSOF) -p1 < $(SOURCE_DIR)/$(LSOF).patch-1
	patch -d $(BUILD_DIR)/$(LSOF) -p1 < $(SOURCE_DIR)/$(LSOF).patch-2
	rm -rf $(BUILD_DIR)/lsof
	mv $(BUILD_DIR)/$(LSOF) $(BUILD_DIR)/lsof
	
lsof-upkg: lsof
	install -d $(TARGET_DIR)/lsof/sbin
	strip $(BUILD_DIR)/lsof/lsof -o $(TARGET_DIR)/lsof/sbin
	tar cvf $(PACKAGE_DIR)/$(LSOF).upkg --group root -C $(TARGET_DIR) lsof

lsof-clean:
	-make -C $(BUILD_DIR)/lsof clean

install: lsof-install

clean: lsof-clean

lsof: directories $(LSOF)-configure
	make -C $(BUILD_DIR)/lsof
