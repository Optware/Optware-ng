###########################################################
#
# libnsl
#
###########################################################

LIBNSL_VERSION?=$(strip \
        $(if $(filter uclibc, $(LIBC_STYLE)), $(UCLIBC-OPT_VERSION), \
        2.2.5))

LIBNSL_DIR=libnsl-$(LIBNSL_VERSION)
LIBNSL_LIBNAME=libnsl
LIBNSL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNSL_DESCRIPTION=Network Services Library
LIBNSL_SECTION=util
LIBNSL_PRIORITY=optional
LIBNSL_DEPENDS=
LIBNSL_CONFLICTS=uclibc

LIBNSL_IPK_VERSION?=5

LIBNSL_BUILD_DIR=$(BUILD_DIR)/libnsl
LIBNSL_SOURCE_DIR=$(SOURCE_DIR)/libnsl
LIBNSL_IPK_DIR=$(BUILD_DIR)/libnsl-$(LIBNSL_VERSION)-ipk
LIBNSL_IPK=$(BUILD_DIR)/libnsl_$(LIBNSL_VERSION)-$(LIBNSL_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(OPTWARE_TARGET), $(filter cs05q1armel cs05q3armel mssii slugos6be slugos6le, $(OPTWARE_TARGET)))
LIBNSL_SO_DIR = $(TARGET_USRLIBDIR)/../../lib
else
LIBNSL_SO_DIR ?= $(TARGET_LIBDIR)
endif

$(LIBNSL_BUILD_DIR)/.configured: make/libnsl.mk $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(@D)
	$(MAKE) toolchain
	mkdir $(@D)
	touch $@

libnsl-unpack: $(LIBNSL_BUILD_DIR)/.configured

libnsl: $(LIBNSL_BUILD_DIR)/.configured

$(LIBNSL_BUILD_DIR)/.staged: $(LIBNSL_BUILD_DIR)/.configured
	rm -f $@
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(LIBNSL_SO_DIR)/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so $(STAGING_LIB_DIR)
	(cd $(STAGING_LIB_DIR); \
	 ln -nfs $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
                 $(LIBNSL_LIBNAME).so; \
	 ln -nfs $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
                 $(LIBNSL_LIBNAME).so.1; \
	 ln -nfs $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
                 $(LIBNSL_LIBNAME).so.0 \
	)
	touch $@

libnsl-stage: $(LIBNSL_BUILD_DIR)/.staged

$(LIBNSL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnsl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNSL_PRIORITY)" >>$@
	@echo "Section: $(LIBNSL_SECTION)" >>$@
	@echo "Version: $(LIBNSL_VERSION)-$(LIBNSL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNSL_MAINTAINER)" >>$@
	@echo "Source: $(LIBNSL_SITE)/$(LIBNSL_SOURCE)" >>$@
	@echo "Description: $(LIBNSL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNSL_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBNSL_CONFLICTS)" >>$@

$(LIBNSL_IPK): $(LIBNSL_BUILD_DIR)/.configured
	rm -rf $(LIBNSL_IPK_DIR) $(BUILD_DIR)/libnsl_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBNSL_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 644 $(LIBNSL_SO_DIR)/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so $(LIBNSL_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(LIBNSL_IPK_DIR)$(TARGET_PREFIX)/lib/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so
	(cd $(LIBNSL_IPK_DIR)$(TARGET_PREFIX)/lib; \
	 ln -s $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
               $(LIBNSL_LIBNAME).so; \
	 ln -s $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
               $(LIBNSL_LIBNAME).so.1; \
	 ln -s $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
               $(LIBNSL_LIBNAME).so.0 \
	)
	$(MAKE) $(LIBNSL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNSL_IPK_DIR)

libnsl-ipk: $(LIBNSL_IPK)

libnsl-clean:
	rm -rf $(LIBNSL_BUILD_DIR)/*

libnsl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNSL_DIR) $(LIBNSL_BUILD_DIR) $(LIBNSL_IPK_DIR) $(LIBNSL_IPK)
