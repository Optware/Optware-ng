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

LIBNSL_IPK_VERSION=4

LIBNSL_BUILD_DIR=$(BUILD_DIR)/libnsl
LIBNSL_SOURCE_DIR=$(SOURCE_DIR)/libnsl
LIBNSL_IPK_DIR=$(BUILD_DIR)/libnsl-$(LIBNSL_VERSION)-ipk
LIBNSL_IPK=$(BUILD_DIR)/libnsl_$(LIBNSL_VERSION)-$(LIBNSL_IPK_VERSION)_$(TARGET_ARCH).ipk

$(LIBNSL_BUILD_DIR)/.configured: make/libnsl.mk
	rm -rf $(BUILD_DIR)/$(LIBNSL_DIR) $(LIBNSL_BUILD_DIR)
	mkdir -p $(LIBNSL_BUILD_DIR)
	touch $@

libnsl-unpack: $(LIBNSL_BUILD_DIR)/.configured

$(LIBNSL_BUILD_DIR)/.built: $(LIBNSL_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(OPTWARE_TARGET), $(filter cs05q3armel mssii, $(OPTWARE_TARGET)))
	cp $(TARGET_USRLIBDIR)/../../lib/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so $(LIBNSL_BUILD_DIR)/
else
	cp $(TARGET_LIBDIR)/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so $(LIBNSL_BUILD_DIR)/
endif
	touch $@

libnsl: $(LIBNSL_BUILD_DIR)/.built

$(LIBNSL_BUILD_DIR)/.staged: $(LIBNSL_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBNSL_BUILD_DIR)/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so $(STAGING_DIR)/opt/lib
	(cd $(STAGING_DIR)/opt/lib; \
	 ln -nfs $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
                 $(LIBNSL_LIBNAME).so; \
	 ln -nfs $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
                 $(LIBNSL_LIBNAME).so.1 \
	)
	touch $@

libnsl-stage: $(LIBNSL_BUILD_DIR)/.staged

$(LIBNSL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(LIBNSL_IPK): $(LIBNSL_BUILD_DIR)/.built
	rm -rf $(LIBNSL_IPK_DIR) $(BUILD_DIR)/libnsl_*_$(TARGET_ARCH).ipk
	install -d $(LIBNSL_IPK_DIR)/opt/lib
	install -m 644 $(LIBNSL_BUILD_DIR)/$(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so $(LIBNSL_IPK_DIR)/opt/lib
	(cd $(LIBNSL_IPK_DIR)/opt/lib; \
	 ln -s $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
               $(LIBNSL_LIBNAME).so; \
	 ln -s $(LIBNSL_LIBNAME)-$(LIBNSL_VERSION).so \
               $(LIBNSL_LIBNAME).so.1 \
	)
	$(MAKE) $(LIBNSL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNSL_IPK_DIR)

libnsl-ipk: $(LIBNSL_IPK)

libnsl-clean:
	rm -rf $(LIBNSL_BUILD_DIR)/*

libnsl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNSL_DIR) $(LIBNSL_BUILD_DIR) $(LIBNSL_IPK_DIR) $(LIBNSL_IPK)
