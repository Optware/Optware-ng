###########################################################
#
# procps
#
###########################################################

ifeq ($(OPTWARE_TARGET), wl500g)
PROCPS_VERSION=3.2.3
else
PROCPS_VERSION=3.2.7
endif
PROCPS=procps-$(PROCPS_VERSION)
PROCPS_SITE=http://procps.sourceforge.net
PROCPS_SOURCE_ARCHIVE=$(PROCPS).tar.gz
PROCPS_UNZIP=zcat
PROCPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PROCPS_DESCRIPTION=PROCPS System Utilities
PROCPS_SECTION=devel
PROCPS_PRIORITY=optional
PROCPS_DEPENDS=ncurses
PROCPS_CONFLICTS=

PROCPS_IPK_VERSION=5

PROCPS_BUILD_DIR=$(BUILD_DIR)/procps
PROCPS_SOURCE_DIR=$(SOURCE_DIR)/procps
PROCPS_IPK=$(BUILD_DIR)/procps_$(PROCPS_VERSION)-$(PROCPS_IPK_VERSION)_$(TARGET_ARCH).ipk
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
$(PROCPS_BUILD_DIR)/.source: $(DL_DIR)/$(PROCPS_SOURCE_ARCHIVE)
	$(PROCPS_UNZIP) $(DL_DIR)/$(PROCPS_SOURCE_ARCHIVE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/procps-$(PROCPS_VERSION) $(PROCPS_BUILD_DIR)
	touch $(PROCPS_BUILD_DIR)/.source

#
# This target configures the build within the build directory.
# This is a fairly important note (cuz I wasted about 5 hours on it).
# Flags usch as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(PROCPS_BUILD_DIR)/.configured: $(PROCPS_BUILD_DIR)/.source
	$(MAKE) ncurses-stage
	touch $(PROCPS_BUILD_DIR)/.configured

procps-unpack: $(PROCPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PROCPS_BUILD_DIR)/.built: $(PROCPS_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(PROCPS_BUILD_DIR)	\
	CC=$(TARGET_CC)			\
	CPPFLAGS=$(PROCPS_CPPFLAGS)	\
	LDFLAGS=$(PROCPS_LDFLAGS)	\
	RANLIB=$(TARGET_RANLIB)
	touch $@
#
# These are the dependencies for the binary.  
#
procps: ncurses $(PROCPS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/procps
#
$(PROCPS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: procps" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PROCPS_PRIORITY)" >>$@
	@echo "Section: $(PROCPS_SECTION)" >>$@
	@echo "Version: $(PROCPS_VERSION)-$(PROCPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PROCPS_MAINTAINER)" >>$@
	@echo "Source: $(PROCPS_SITE)/$(PROCPS_SOURCE)" >>$@
	@echo "Description: $(PROCPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PROCPS_DEPENDS)" >>$@
	@echo "Conflicts: $(PROCPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(PROCPS_IPK): $(PROCPS_BUILD_DIR)/.built
	rm -rf $(PROCPS_IPK_DIR) $(BUILD_DIR)/procps_*_$(TARGET_ARCH).ipk
	mkdir -p $(PROCPS_IPK_DIR)/opt
	mkdir -p $(PROCPS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/free -o $(PROCPS_IPK_DIR)/opt/bin/procps-free
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/kill -o $(PROCPS_IPK_DIR)/opt/bin/procps-kill
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/pgrep -o $(PROCPS_IPK_DIR)/opt/bin/pgrep
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/pmap -o $(PROCPS_IPK_DIR)/opt/bin/pmap
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/ps/ps -o $(PROCPS_IPK_DIR)/opt/bin/procps-ps
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/skill -o $(PROCPS_IPK_DIR)/opt/bin/skill
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/slabtop -o $(PROCPS_IPK_DIR)/opt/bin/slabtop
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/snice -o $(PROCPS_IPK_DIR)/opt/bin/snice
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/sysctl -o $(PROCPS_IPK_DIR)/opt/bin/sysctl
	cp $(PROCPS_BUILD_DIR)/t $(PROCPS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/tload -o $(PROCPS_IPK_DIR)/opt/bin/tload
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/top -o $(PROCPS_IPK_DIR)/opt/bin/procps-top
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/uptime -o $(PROCPS_IPK_DIR)/opt/bin/procps-uptime
	cp $(PROCPS_BUILD_DIR)/v $(PROCPS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/vmstat -o $(PROCPS_IPK_DIR)/opt/bin/vmstat
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/w -o $(PROCPS_IPK_DIR)/opt/bin/w
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/watch -o $(PROCPS_IPK_DIR)/opt/bin/procps-watch
	mkdir -p $(PROCPS_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(PROCPS_BUILD_DIR)/proc/libproc-$(PROCPS_VERSION).so -o $(PROCPS_IPK_DIR)/opt/lib/libproc-$(PROCPS_VERSION).so
	$(MAKE) $(PROCPS_IPK_DIR)/CONTROL/control
	install -m 644 $(PROCPS_SOURCE_DIR)/postinst $(PROCPS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(PROCPS_SOURCE_DIR)/prerm $(PROCPS_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PROCPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
procps-ipk: $(PROCPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
procps-clean:
	-$(MAKE) -C $(PROCPS_BUILD_DIR) uninstall
	-$(MAKE) -C $(PROCPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean ALL files, including
# downloaded source.
#
procps-distclean:
	-rm $(PROCPS_BUILD_DIR)/.configured
	-$(MAKE) -C $(PROCPS_BUILD_DIR) distclean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
procps-dirclean:
	rm -rf $(PROCPS_BUILD_DIR) $(PROCPS_IPK_DIR) $(PROCPS_IPK)

procps-check: $(PROCPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PROCPS_IPK)
