###########################################################
#
# libstdc++
#
###########################################################

LIBSTDC++_VERSION=$(strip \
	$(if $(filter nslu2bag, $(OPTWARE_TARGET)), 6.0.8, \
	$(if $(filter mss, $(OPTWARE_TARGET)), 5.0.3, \
	$(if $(filter ds101g ts72xx, $(OPTWARE_TARGET)), 5.0.6, \
	5.0.7))))
LIBSTDC++_MAJOR=$(shell echo $(LIBSTDC++_VERSION) | sed 's/\..*//')

LIBSTDC++_DIR=libstdc++-$(LIBSTDC++_VERSION)
LIBSTDC++_LIBNAME=libstdc++.so
LIBSTDC++_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSTDC++_DESCRIPTION=Standard C++ library, needed for dynamically linked C++ programs
LIBSTDC++_SECTION=util
LIBSTDC++_PRIORITY=optional
LIBSTDC++_DEPENDS=
LIBSTDC++_CONFLICTS=

ifeq ($(LIBC_STYLE), uclibc)
LIBSTDC++_DEPENDS=libuclibc++
LIBSTDC++_VERSION=0.2.0
LIBSTDC++_DESCRIPTION==Standard C++ library, wrapped for uClibc++
LIBSTDC++_LIBNAME=
endif

LIBSTDC++_IPK_VERSION=5

LIBSTDC++_BUILD_DIR=$(BUILD_DIR)/libstdc++
LIBSTDC++_SOURCE_DIR=$(SOURCE_DIR)/libstdc++
LIBSTDC++_IPK_DIR=$(BUILD_DIR)/libstdc++-$(LIBSTDC++_VERSION)-ipk
LIBSTDC++_IPK=$(BUILD_DIR)/libstdc++_$(LIBSTDC++_VERSION)-$(LIBSTDC++_IPK_VERSION)_$(TARGET_ARCH).ipk

$(LIBSTDC++_BUILD_DIR)/.configured: $(LIBSTDC++_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBSTDC++_DIR) $(LIBSTDC++_BUILD_DIR)
	mkdir -p $(LIBSTDC++_BUILD_DIR)
	touch $(LIBSTDC++_BUILD_DIR)/.configured

libstdc++-unpack: $(LIBSTDC++_BUILD_DIR)/.configured

$(LIBSTDC++_BUILD_DIR)/.built: $(LIBSTDC++_BUILD_DIR)/.configured
	rm -f $(LIBSTDC++_BUILD_DIR)/.built
ifneq ($(LIBC_STYLE), uclibc)
	cp $(TARGET_LIBDIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_BUILD_DIR)/
endif
	touch $(LIBSTDC++_BUILD_DIR)/.built

libstdc++: $(LIBSTDC++_BUILD_DIR)/.built

$(LIBSTDC++_BUILD_DIR)/.staged: $(LIBSTDC++_BUILD_DIR)/.built
	rm -f $(LIBSTDC++_BUILD_DIR)/.staged
ifneq ($(LIBC_STYLE), uclibc)
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBSTDC++_BUILD_DIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(STAGING_DIR)/opt/lib
	(cd $(STAGING_DIR)/opt/lib; \
	 ln -sf $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
		$(LIBSTDC++_LIBNAME); \
	 ln -sf $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
		$(LIBSTDC++_LIBNAME).$(LIBSTDC++_MAJOR) \
	)
endif
	touch $(LIBSTDC++_BUILD_DIR)/.staged

libstdc++-stage: $(LIBSTDC++_BUILD_DIR)/.staged

$(LIBSTDC++_IPK_DIR)/CONTROL/control:
	@install -d $(LIBSTDC++_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libstdc++" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSTDC++_PRIORITY)" >>$@
	@echo "Section: $(LIBSTDC++_SECTION)" >>$@
	@echo "Version: $(LIBSTDC++_VERSION)-$(LIBSTDC++_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSTDC++_MAINTAINER)" >>$@
	@echo "Source: $(LIBSTDC++_SITE)/$(LIBSTDC++_SOURCE)" >>$@
	@echo "Description: $(LIBSTDC++_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSTDC++_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBSTDC++_CONFLICTS)" >>$@

$(LIBSTDC++_IPK): $(LIBSTDC++_BUILD_DIR)/.built
	rm -rf $(LIBSTDC++_IPK_DIR) $(BUILD_DIR)/libstdc++_*_$(TARGET_ARCH).ipk
ifneq ($(LIBC_STYLE), uclibc)
	install -d $(LIBSTDC++_IPK_DIR)/opt/lib
	install -m 644 $(LIBSTDC++_BUILD_DIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_IPK_DIR)/opt/lib
	(cd $(LIBSTDC++_IPK_DIR)/opt/lib; \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME); \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME).$(LIBSTDC++_MAJOR) \
	)
	$(STRIP_COMMAND) $(LIBSTDC++_IPK_DIR)/opt/lib/*.so
endif
	$(MAKE) $(LIBSTDC++_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSTDC++_IPK_DIR)

libstdc++-ipk: $(LIBSTDC++_IPK)

libstdc++-clean:
	rm -rf $(LIBSTDC++_BUILD_DIR)/*

libstdc++-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSTDC++_DIR) $(LIBSTDC++_BUILD_DIR) $(LIBSTDC++_IPK_DIR) $(LIBSTDC++_IPK)
