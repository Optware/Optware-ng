#############################################################
#
# zlib
#
#############################################################

ZLIB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libpng
ZLIB_VERSION:=1.2.3
ZLIB_LIB_VERSION:=1.2.3
ZLIB_SOURCE=zlib-$(ZLIB_VERSION).tar.bz2
ZLIB_DIR=zlib-$(ZLIB_VERSION)
ZLIB_UNZIP=bzcat
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
ifneq ($(OPTWARE_TARGET), $(filter dns323, $(OPTWARE_TARGET)))
ZLIB_MAKE_FLAGS=LDSHARED="$(TARGET_LD) -shared -soname,libz.so.1"
endif
endif

ZLIB_BUILD_DIR=$(BUILD_DIR)/zlib
ZLIB_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/zlib
ZLIB_SOURCE_DIR=$(SOURCE_DIR)/zlib

ZLIB_IPK_DIR=$(BUILD_DIR)/zlib-$(ZLIB_VERSION)-ipk
ZLIB_IPK=$(BUILD_DIR)/zlib_$(ZLIB_VERSION)-$(ZLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(ZLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZLIB_SITE)/$(ZLIB_SOURCE)

zlib-source: $(DL_DIR)/$(ZLIB_SOURCE)

$(ZLIB_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(ZLIB_SOURCE) make/zlib.mk
	rm -rf $(HOST_BUILD_DIR)/$(ZLIB_DIR) $(@D)
	$(ZLIB_UNZIP) $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(ZLIB_DIR) $(@D)
	(cd $(@D); \
		prefix=/opt \
		./configure \
		--shared \
	)
	$(MAKE) -C $(@D)
	install -d $(HOST_STAGING_INCLUDE_DIR)
	install -m 644 $(@D)/zlib.h $(HOST_STAGING_INCLUDE_DIR)
	install -m 644 $(@D)/zconf.h $(HOST_STAGING_INCLUDE_DIR)
	touch $@

zlib-host-stage: $(ZLIB_HOST_BUILD_DIR)/.staged

$(ZLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(ZLIB_SOURCE)
	rm -rf $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR)
	$(ZLIB_UNZIP) $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR)
ifeq (darwin,$(TARGET_OS))
	sed -i -e 's/`.*uname -s.*`/Darwin/' $(ZLIB_BUILD_DIR)/configure
endif
	(cd $(ZLIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		prefix=/opt \
		./configure \
		--shared \
	)
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
	rm -f $@
	install -d $(STAGING_INCLUDE_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/zlib.h $(STAGING_INCLUDE_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/zconf.h $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_LIB_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/libz.a $(STAGING_LIB_DIR)
	install -m 644 $(ZLIB_BUILD_DIR)/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) $(STAGING_LIB_DIR)
	cd $(STAGING_DIR)/opt/lib && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz$(SO).1$(DYLIB)
	cd $(STAGING_DIR)/opt/lib && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz.$(SHLIB_EXT)
	touch $@

zlib-stage: $(ZLIB_BUILD_DIR)/.staged


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(ZLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(ZLIB_IPK): $(ZLIB_BUILD_DIR)/.built
	rm -rf $(ZLIB_IPK_DIR) $(BUILD_DIR)/zlib_*_$(TARGET_ARCH).ipk
	install -d $(ZLIB_IPK_DIR)/opt/include
	install -m 644 $(ZLIB_BUILD_DIR)/zlib.h $(ZLIB_IPK_DIR)/opt/include
	install -m 644 $(ZLIB_BUILD_DIR)/zconf.h $(ZLIB_IPK_DIR)/opt/include
	install -d $(ZLIB_IPK_DIR)/opt/lib
	install -m 644 $(ZLIB_BUILD_DIR)/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) $(ZLIB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(ZLIB_IPK_DIR)/opt/lib/libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB)
	cd $(ZLIB_IPK_DIR)/opt/lib && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz$(SO).1$(DYLIB)
	cd $(ZLIB_IPK_DIR)/opt/lib && ln -fs libz$(SO).$(ZLIB_LIB_VERSION)$(DYLIB) libz.$(SHLIB_EXT)
	$(MAKE) $(ZLIB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZLIB_IPK_DIR)

zlib-ipk: $(ZLIB_IPK)

zlib-clean:
	-$(MAKE) -C $(ZLIB_BUILD_DIR) clean

zlib-dirclean:
	rm -rf $(BUILD_DIR)/$(ZLIB_DIR) $(ZLIB_BUILD_DIR) $(ZLIB_IPK_DIR) $(ZLIB_IPK)
