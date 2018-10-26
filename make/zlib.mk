#############################################################
#
# zlib
#
#############################################################

ZLIB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libpng
ZLIB_SITE2=http://zlib.net
ZLIB_VERSION:=1.2.11
ZLIB_LIB_VERSION:=1.2.11
ZLIB_SOURCE=zlib-$(ZLIB_VERSION).tar.xz
ZLIB_DIR=zlib-$(ZLIB_VERSION)
ZLIB_UNZIP=xzcat
ZLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZLIB_DESCRIPTION=zlib is a library implementing the 'deflate' compression system.
ZLIB_SECTION=libs
ZLIB_PRIORITY=optional
ZLIB_DEPENDS=
ZLIB_CONFLICTS=

ZLIB_IPK_VERSION=2

ZLIB_CFLAGS= $(TARGET_CFLAGS) -fPIC
ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
ZLIB_CFLAGS+= -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif

ifneq (darwin,$(TARGET_OS))
ZLIB_LDFLAGS=-Wl,-soname,libz.so.1
ZLIB_MAKE_FLAGS=LDSHARED="$(TARGET_CC) -shared $(STAGING_LDFLAGS) $(ZLIB_LDFLAGS)"
endif

ZLIB_BUILD_DIR=$(BUILD_DIR)/zlib
ZLIB_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/zlib
ZLIB_SOURCE_DIR=$(SOURCE_DIR)/zlib

ZLIB_IPK_DIR=$(BUILD_DIR)/zlib-$(ZLIB_VERSION)-ipk
ZLIB_IPK=$(BUILD_DIR)/zlib_$(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)_$(TARGET_ARCH).ipk
ZLIB-DEV_IPK_DIR=$(BUILD_DIR)/zlib-dev-$(ZLIB_VERSION)-ipk
ZLIB-DEV_IPK=$(BUILD_DIR)/zlib-dev_$(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: zlib-source zlib-unpack zlib zlib-stage zlib-ipk zlib-clean \
zlib-dirclean zlib-check zlib-host zlib-host-stage zlib-unstage


$(DL_DIR)/$(ZLIB_SOURCE):
	$(WGET) -P $(@D) $(ZLIB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(ZLIB_SITE2)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

zlib-source: $(DL_DIR)/$(ZLIB_SOURCE)

$(ZLIB_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(ZLIB_SOURCE) make/zlib.mk
	rm -rf $(HOST_BUILD_DIR)/$(ZLIB_DIR) $(@D)
	$(ZLIB_UNZIP) $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(ZLIB_DIR) $(@D)
	(cd $(@D); \
	    	CFLAGS="-fPIC" \
		prefix=/opt \
		./configure \
		--shared \
	)
	$(MAKE) -C $(@D)
	$(INSTALL) -d $(HOST_STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(HOST_STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(@D)/zlib.h $(HOST_STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(@D)/zconf.h $(HOST_STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(@D)/libz.a $(HOST_STAGING_LIB_DIR)
	touch $@

zlib-host-stage: $(ZLIB_HOST_BUILD_DIR)/.staged

$(ZLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(ZLIB_SOURCE) make/zlib.mk
	rm -rf $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR)
	rm -f $(STAGING_INCLUDE_DIR)/zconf.h $(STAGING_INCLUDE_DIR)/zlib.h
	rm -f $(STAGING_LIB_DIR)/libz.a $(STAGING_LIB_DIR)/libz.so*
	$(ZLIB_UNZIP) $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR)
ifeq (darwin,$(TARGET_OS))
	sed -i -e 's/`.*uname -s.*`/Darwin/' $(ZLIB_BUILD_DIR)/configure
endif
	(cd $(ZLIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		prefix=$(TARGET_PREFIX) \
		./configure \
		--shared \
	)
	sed -i -e "s/^ARFLAGS=.*/ARFLAGS=/" $(@D)/Makefile
	touch $@

zlib-unpack: $(ZLIB_BUILD_DIR)/.configured

$(ZLIB_BUILD_DIR)/.built: $(ZLIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR) rc" \
		SHAREDLIB="libz.$(SHLIB_EXT)" \
		SHAREDLIBV="libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB)" \
		SHAREDLIBM="libz$(SO).1$(DYLIB)" \
		CFLAGS="$(ZLIB_CFLAGS)" \
		CC=$(TARGET_CC) \
		$(ZLIB_MAKE_FLAGS) \
		-C $(ZLIB_BUILD_DIR) libz.a libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) all
	touch $@

zlib: $(ZLIB_BUILD_DIR)/.built

$(ZLIB_BUILD_DIR)/.staged: $(ZLIB_BUILD_DIR)/.built
	rm -f $@ $(ZLIB_BUILD_DIR)/.unstaged
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/zlib.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/zconf.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/libz.a $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) $(STAGING_LIB_DIR)
	cd $(STAGING_LIB_DIR) && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz$(SO).1$(DYLIB)
	cd $(STAGING_LIB_DIR) && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz.$(SHLIB_EXT)
	sed -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(@D)/zlib.pc > $(STAGING_LIB_DIR)/pkgconfig/zlib.pc
	touch $@

zlib-stage: $(ZLIB_BUILD_DIR)/.staged

$(ZLIB_BUILD_DIR)/.unstaged:
	rm -f $@ $(ZLIB_BUILD_DIR)/.staged
	rm -f $(STAGING_INCLUDE_DIR)/zlib.h $(STAGING_INCLUDE_DIR)/zconf.h
	rm -f $(STAGING_LIB_DIR)/libz.a $(STAGING_LIB_DIR)/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB)
	rm -f $(STAGING_LIB_DIR)/libz$(SO).1$(DYLIB) $(STAGING_LIB_DIR)/libz.$(SHLIB_EXT)
	-touch $@

zlib-unstage: $(ZLIB_BUILD_DIR)/.unstaged


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(ZLIB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: zlib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZLIB_PRIORITY)" >>$@
	@echo "Section: $(ZLIB_SECTION)" >>$@
	@echo "Version: $(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZLIB_MAINTAINER)" >>$@
	@echo "Source: $(ZLIB_SITE)/$(ZLIB_SOURCE)" >>$@
	@echo "Description: $(ZLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(ZLIB_DEPENDS)" >>$@
	@echo "Conflicts: $(ZLIB_CONFLICTS)" >>$@
	
$(ZLIB-DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: zlib-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZLIB_PRIORITY)" >>$@
	@echo "Section: $(ZLIB_SECTION)" >>$@
	@echo "Version: $(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZLIB_MAINTAINER)" >>$@
	@echo "Source: $(ZLIB_SITE)/$(ZLIB_SOURCE)" >>$@
	@echo "Description: Development files for ZLIB" >>$@
	@echo "Depends: zlib" >>$@
	@echo "Conflicts: " >>$@	

$(ZLIB_IPK) $(ZLIB-DEV_IPK): $(ZLIB_BUILD_DIR)/.built
	rm -rf $(ZLIB_IPK_DIR) $(BUILD_DIR)/zlib_*_$(TARGET_ARCH).ipk
	rm -rf $(ZLIB-DEV_IPK_DIR) $(BUILD_DIR)/zlib-dev_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ZLIB_IPK_DIR)$(TARGET_PREFIX)/lib	
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) $(ZLIB_IPK_DIR)$(TARGET_PREFIX)/lib	
	$(INSTALL) -d $(ZLIB-DEV_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/zlib.h $(ZLIB-DEV_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/zconf.h $(ZLIB-DEV_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -d $(ZLIB-DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	$(INSTALL) -m 644 $(ZLIB_BUILD_DIR)/zlib.pc $(ZLIB-DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/zlib.pc
ifneq ($(OPTWARE_TARGET), $(filter buildroot-i686, $(OPTWARE_TARGET)))
# workaround for native gcc warning
# as: $(TARGET_PREFIX)/lib/libz.so.1: no version information available (required by .../as)
	$(STRIP_COMMAND) $(ZLIB_IPK_DIR)$(TARGET_PREFIX)/lib/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB)
endif
	cd $(ZLIB_IPK_DIR)$(TARGET_PREFIX)/lib && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz$(SO).1$(DYLIB)
	cd $(ZLIB_IPK_DIR)$(TARGET_PREFIX)/lib && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz.$(SHLIB_EXT)
	$(MAKE) $(ZLIB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZLIB_IPK_DIR)
	$(MAKE) $(ZLIB-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZLIB-DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ZLIB_IPK_DIR) $(ZLIB-DEV_IPK_DIR)

zlib-ipk: $(ZLIB_IPK) $(ZLIB-DEV_IPK)

zlib-clean: zlib-unstage
	rm -f $(ZLIB_BUILD_DIR)/.built
	rm -f $(ZLIB_HOST_BUILD_DIR)/.staged
	-$(MAKE) -C $(ZLIB_BUILD_DIR) clean

zlib-dirclean: zlib-unstage
	rm -rf $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR) $(ZLIB_IPK_DIR) $(ZLIB-DEV_IPK_DIR) $(ZLIB_IPK) $(ZLIB-DEV_IPK)

#
# Some sanity check for the package.
#
zlib-check: $(ZLIB_IPK) $(ZLIB-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
