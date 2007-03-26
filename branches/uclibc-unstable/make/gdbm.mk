###########################################################
#
# gdbm
#
###########################################################

GDBM_SITE=ftp://ftp.gnu.org/gnu/gdbm
GDBM_VERSION=1.8.3
GDBM_LIB_VERSION=3.0.0
GDBM_SOURCE=gdbm-$(GDBM_VERSION).tar.gz
GDBM_DIR=gdbm-$(GDBM_VERSION)
GDBM_UNZIP=zcat
GDBM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GDBM_DESCRIPTION=GNU dbm is a set of database routines that use extensible hashing. It works similar to the standard UNIX dbm routines.
GDBM_SECTION=libs
GDBM_PRIORITY=optional
GDBM_DEPENDS=
GDBM_CONFLICTS=

GDBM_IPK_VERSION=2

GDBM_PATCHES=$(GDBM_SOURCE_DIR)/Makefile.patch

GDBM_BUILD_DIR=$(BUILD_DIR)/gdbm
GDBM_SOURCE_DIR=$(SOURCE_DIR)/gdbm
GDBM_IPK=$(BUILD_DIR)/gdbm_$(GDBM_VERSION)-$(GDBM_IPK_VERSION)_$(TARGET_ARCH).ipk
GDBM_IPK_DIR=$(BUILD_DIR)/gdbm-$(GDBM_VERSION)-ipk

$(DL_DIR)/$(GDBM_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDBM_SITE)/$(GDBM_SOURCE)

gdbm-source: $(DL_DIR)/$(GDBM_SOURCE) $(GDBM_PATCHES)

$(GDBM_BUILD_DIR)/.configured: $(DL_DIR)/$(GDBM_SOURCE)
	rm -rf $(BUILD_DIR)/$(GDBM_DIR) $(GDBM_BUILD_DIR)
	$(GDBM_UNZIP) $(DL_DIR)/$(GDBM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GDBM_PATCHES) | patch -d $(BUILD_DIR)/$(GDBM_DIR) -p1
	mv $(BUILD_DIR)/$(GDBM_DIR) $(GDBM_BUILD_DIR)
	(cd $(GDBM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	touch $(GDBM_BUILD_DIR)/.configured

gdbm-unpack: $(GDBM_BUILD_DIR)/.configured

$(GDBM_BUILD_DIR)/.libs/libgdbm.a: $(GDBM_BUILD_DIR)/.configured
	$(MAKE) -C $(GDBM_BUILD_DIR)

gdbm: $(GDBM_BUILD_DIR)/.libs/libgdbm.a

$(GDBM_BUILD_DIR)/.staged: $(GDBM_BUILD_DIR)/.libs/libgdbm.a
	rm -f $@
	$(MAKE) -C $(GDBM_BUILD_DIR) INSTALL_ROOT=$(STAGING_DIR) install install-compat
	rm -rf $(STAGING_LIB_DIR)/libgdbm.la
	rm -rf $(STAGING_LIB_DIR)/libgdbm_compat.la
	touch $@

gdbm-stage: $(GDBM_BUILD_DIR)/.staged

$(GDBM_IPK_DIR)/CONTROL/control:
	@install -d $(GDBM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gdbm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GDBM_PRIORITY)" >>$@
	@echo "Section: $(GDBM_SECTION)" >>$@
	@echo "Version: $(GDBM_VERSION)-$(GDBM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GDBM_MAINTAINER)" >>$@
	@echo "Source: $(GDBM_SITE)/$(GDBM_SOURCE)" >>$@
	@echo "Description: $(GDBM_DESCRIPTION)" >>$@
	@echo "Depends: $(GDBM_DEPENDS)" >>$@
	@echo "Conflicts: $(GDBM_CONFLICTS)" >>$@

$(GDBM_IPK): $(GDBM_BUILD_DIR)/.libs/libgdbm.a
	rm -rf $(GDBM_IPK_DIR) $(GDBM_IPK)
	$(MAKE) -C $(GDBM_BUILD_DIR) INSTALL_ROOT=$(GDBM_IPK_DIR) install install-compat
	$(STRIP_COMMAND) $(GDBM_IPK_DIR)/opt/lib/*.so.*
	rm -rf $(GDBM_IPK_DIR)/opt/{man,info}
	rm -f $(GDBM_IPK_DIR)/opt/lib/*.{la,a}
	$(MAKE) $(GDBM_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GDBM_IPK_DIR)

gdbm-ipk: $(GDBM_IPK)

gdbm-clean:
	-$(MAKE) -C $(GDBM_BUILD_DIR) clean

gdbm-dirclean:
	rm -rf $(BUILD_DIR)/$(GDBM_DIR) $(GDBM_BUILD_DIR) $(GDBM_IPK_DIR) $(GDBM_IPK)

