###########################################################
#
# grep
#
###########################################################

GREP_DIR=$(BUILD_DIR)/grep

GREP_VERSION=2.4.2
GREP=grep-$(GREP_VERSION)
GREP_SITE=ftp://ftp.gnu.org/pub/gnu/grep
GREP_SOURCE=$(GREP).tar.gz
GREP_UNZIP=zcat
GREP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GREP_DESCRIPTION=Global regular expression parser
GREP_SECTION=util
GREP_PRIORITY=optional
GREP_DEPENDS=
GREP_CONFLICTS=busybox

GREP_IPK_VERSION=4

GREP_IPK=$(BUILD_DIR)/grep_$(GREP_VERSION)-$(GREP_IPK_VERSION)_$(TARGET_ARCH).ipk
GREP_IPK_DIR=$(BUILD_DIR)/grep-$(GREP_VERSION)-ipk

$(DL_DIR)/$(GREP_SOURCE):
	$(WGET) -P $(DL_DIR) $(GREP_SITE)/$(GREP_SOURCE)

grep-source: $(DL_DIR)/$(GREP_SOURCE)

ifeq ($(OPTWARE_TARGET),wl500g)
GREP_CONFIGURE_ARGS=--disable-nls
else
GREP_CONFIGURE_ARGS=
endif

$(GREP_DIR)/.configured: $(DL_DIR)/$(GREP_SOURCE)
	$(GREP_UNZIP) $(DL_DIR)/$(GREP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/grep-$(GREP_VERSION) $(GREP_DIR)
	(cd $(GREP_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(GREP_IPK_DIR)/opt \
		$(GREP_CONFIGURE_ARGS) \
	);
	touch $(GREP_DIR)/.configured

grep-unpack: $(GREP_DIR)/.configured

$(GREP_DIR)/src/grep: $(GREP_DIR)/.configured
	$(MAKE) -C $(GREP_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) install

grep: $(GREP_DIR)/src/grep

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/grep
#
$(GREP_IPK_DIR)/CONTROL/control:
	@install -d $(GREP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: grep" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GREP_PRIORITY)" >>$@
	@echo "Section: $(GREP_SECTION)" >>$@
	@echo "Version: $(GREP_VERSION)-$(GREP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GREP_MAINTAINER)" >>$@
	@echo "Source: $(GREP_SITE)/$(GREP_SOURCE)" >>$@
	@echo "Description: $(GREP_DESCRIPTION)" >>$@
	@echo "Depends: $(GREP_DEPENDS)" >>$@
	@echo "Conflicts: $(GREP_CONFLICTS)" >>$@

$(GREP_IPK): $(GREP_DIR)/src/grep
	rm -rf $(GREP_IPK_DIR) $(BUILD_DIR)/grep_*_$(TARGET_ARCH).ipk
	install -d $(GREP_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(GREP_DIR)/src/grep -o $(GREP_IPK_DIR)/opt/bin/grep
	$(STRIP_COMMAND) $(GREP_DIR)/src/egrep -o $(GREP_IPK_DIR)/opt/bin/egrep
	$(STRIP_COMMAND) $(GREP_DIR)/src/fgrep -o $(GREP_IPK_DIR)/opt/bin/fgrep
	$(MAKE) $(GREP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GREP_IPK_DIR)

grep-ipk: $(GREP_IPK)

grep-clean:
	-$(MAKE) -C $(GREP_DIR) clean

grep-dirclean:
	rm -rf $(GREP_DIR) $(GREP_IPK_DIR) $(GREP_IPK)
