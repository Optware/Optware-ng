###########################################################
#
# procps
#
###########################################################

PROCPS_DIR=$(BUILD_DIR)/procps
PROCPS_VERSION=3.2.3
PROCPS=procps-$(PROCPS_VERSION)
PROCPS_SITE=http://procps.sourceforge.net
PROCPS_SOURCE_ARCHIVE=$(PROCPS).tar.gz
PROCPS_UNZIP=zcat

PROCPS_IPK=$(BUILD_DIR)/procps_$(PROCPS_VERSION)-3_armeb.ipk
PROCPS_IPK_DIR=$(BUILD_DIR)/procps-$(PROCPS_VERSION)-ipk

PROCPS_CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_DIR)/opt/include/ncurses"
PROCPS_LDFLAGS="$(STAGING_LDFLAGS)"

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PROCPS_SOURCE_ARCHIVE):
	$(WGET) -P $(DL_DIR) $(PROCPS_SITE)/$(PROCPS_SOURCE_ARCHIVE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
procps-source: $(DL_DIR)/$(PROCPS_SOURCE_ARCHIVE)

#
# This target unpacks the source code into the build directory.
#
$(PROCPS_DIR)/.source: $(DL_DIR)/$(PROCPS_SOURCE_ARCHIVE)
	$(PROCPS_UNZIP) $(DL_DIR)/$(PROCPS_SOURCE_ARCHIVE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/procps-$(PROCPS_VERSION) $(PROCPS_DIR)
	touch $(PROCPS_DIR)/.source

#
# This target configures the build within the build directory.
# This is a fairly important note (cuz I wasted about 5 hours on it).
# Flags usch as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(PROCPS_DIR)/.configured: $(PROCPS_DIR)/.source
	$(MAKE) ncurses-stage
	touch $(PROCPS_DIR)/.configured

#
# This builds the actual binary.
#
$(PROCPS_DIR)/watch: $(PROCPS_DIR)/.configured
	$(MAKE) -C $(PROCPS_DIR)	\
	CC=$(TARGET_CC)			\
	CPPFLAGS=$(PROCPS_CPPFLAGS)	\
	LDFLAGS=$(PROCPS_LDFLAGS)	\
	RANLIB=$(TARGET_RANLIB)

#
# These are the dependencies for the binary.  
#
procps: ncurses $(PROCPS_DIR)/watch

#
# This builds the IPK file.
#
$(PROCPS_IPK): $(PROCPS_DIR)/watch
	rm -rf $(PROCPS_IPK_DIR) $(BUILD_DIR)/procps_*_armeb.ipk
	mkdir -p $(PROCPS_IPK_DIR)/CONTROL
	mkdir -p $(PROCPS_IPK_DIR)/opt
	mkdir -p $(PROCPS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROCPS_DIR)/free -o $(PROCPS_IPK_DIR)/opt/bin/free
	$(STRIP_COMMAND) $(PROCPS_DIR)/kill -o $(PROCPS_IPK_DIR)/opt/bin/kill
	$(STRIP_COMMAND) $(PROCPS_DIR)/pgrep -o $(PROCPS_IPK_DIR)/opt/bin/pgrep
	$(STRIP_COMMAND) $(PROCPS_DIR)/pmap -o $(PROCPS_IPK_DIR)/opt/bin/pmap
	$(STRIP_COMMAND) $(PROCPS_DIR)/skill -o $(PROCPS_IPK_DIR)/opt/bin/skill
	$(STRIP_COMMAND) $(PROCPS_DIR)/slabtop -o $(PROCPS_IPK_DIR)/opt/bin/slabtop
	$(STRIP_COMMAND) $(PROCPS_DIR)/snice -o $(PROCPS_IPK_DIR)/opt/bin/snice
	$(STRIP_COMMAND) $(PROCPS_DIR)/sysctl -o $(PROCPS_IPK_DIR)/opt/bin/sysctl
	cp $(PROCPS_DIR)/t $(PROCPS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROCPS_DIR)/tload -o $(PROCPS_IPK_DIR)/opt/bin/tload
	$(STRIP_COMMAND) $(PROCPS_DIR)/top -o $(PROCPS_IPK_DIR)/opt/bin/top
	$(STRIP_COMMAND) $(PROCPS_DIR)/uptime -o $(PROCPS_IPK_DIR)/opt/bin/uptime
	cp $(PROCPS_DIR)/v $(PROCPS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROCPS_DIR)/vmstat -o $(PROCPS_IPK_DIR)/opt/bin/vmstat
	$(STRIP_COMMAND) $(PROCPS_DIR)/w -o $(PROCPS_IPK_DIR)/opt/bin/w
	$(STRIP_COMMAND) $(PROCPS_DIR)/watch -o $(PROCPS_IPK_DIR)/opt/bin/watch
	mkdir -p $(PROCPS_IPK_DIR)/opt/lib
	cp $(PROCPS_DIR)/proc/libproc-3.2.3.so $(PROCPS_IPK_DIR)/opt/lib
	cp $(SOURCE_DIR)/procps.control $(PROCPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PROCPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
procps-ipk: $(PROCPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
procps-clean:
	-$(MAKE) -C $(PROCPS_DIR) uninstall
	-$(MAKE) -C $(PROCPS_DIR) clean

#
# This is called from the top level makefile to clean ALL files, including
# downloaded source.
#
procps-distclean:
	-rm $(PROCPS_DIR)/.configured
	-$(MAKE) -C $(PROCPS_DIR) distclean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
procps-dirclean:
	rm -rf $(PROCPS_DIR) $(PROCPS_IPK_DIR) $(PROCPS_IPK)
