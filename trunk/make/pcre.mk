###########################################################
#
# pcre
#
###########################################################

PCRE_SITE=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
PCRE_VERSION=5.0
PCRE_SOURCE=pcre-$(PCRE_VERSION).tar.bz2
PCRE_DIR=pcre-$(PCRE_VERSION)
PCRE_UNZIP=bzcat
PCRE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCRE_DESCRIPTION=Perl-compatible regular expression library
PCRE_SECTION=util
PCRE_PRIORITY=optional
PCRE_DEPENDS=
PCRE_CONFLICTS=

ifeq ($(HOST_MACHINE),armv5b)
	PCRE_LIBTOOL_TAG=""
else
	PCRE_LIBTOOL_TAG="--tag=CXX"
endif

PCRE_IPK_VERSION=4

PCRE_PATCHES=$(PCRE_SOURCE_DIR)/Makefile.in.patch

PCRE_BUILD_DIR=$(BUILD_DIR)/pcre
PCRE_SOURCE_DIR=$(SOURCE_DIR)/pcre
PCRE_IPK_DIR=$(BUILD_DIR)/pcre-$(PCRE_VERSION)-ipk
PCRE_IPK=$(BUILD_DIR)/pcre_$(PCRE_VERSION)-$(PCRE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PCRE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PCRE_SITE)/$(PCRE_SOURCE)

pcre-source: $(DL_DIR)/$(PCRE_SOURCE) $(PCRE_PATCHES)

$(PCRE_BUILD_DIR)/.configured: $(DL_DIR)/$(PCRE_SOURCE) $(PCRE_PATCHES)
	rm -rf $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR)
	$(PCRE_UNZIP) $(DL_DIR)/$(PCRE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PCRE_PATCHES) | patch -d $(BUILD_DIR)/$(PCRE_DIR) -p1
	mv $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR)
	(cd $(PCRE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CC_FOR_BUILD=$(HOSTCC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(PCRE_BUILD_DIR)/libtool
	touch $(PCRE_BUILD_DIR)/.configured

pcre-unpack: $(PCRE_BUILD_DIR)/.configured

$(PCRE_BUILD_DIR)/.built: $(PCRE_BUILD_DIR)/.configured
	rm -f $(PCRE_BUILD_DIR)/.built
	$(MAKE) -C $(PCRE_BUILD_DIR) LIBTOOL_TAG=$(PCRE_LIBTOOL_TAG)
	touch $(PCRE_BUILD_DIR)/.built

pcre: $(PCRE_BUILD_DIR)/.built

$(PCRE_BUILD_DIR)/.staged: $(PCRE_BUILD_DIR)/.built
	rm -f $(PCRE_BUILD_DIR)/.staged
	$(MAKE) -C $(PCRE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpcre.la
	rm -f $(STAGING_LIB_DIR)/libpcreposix.la
	touch $(PCRE_BUILD_DIR)/.staged

pcre-stage: $(PCRE_BUILD_DIR)/.staged

$(PCRE_IPK_DIR)/CONTROL/control:
	@install -d $(PCRE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pcre" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCRE_PRIORITY)" >>$@
	@echo "Section: $(PCRE_SECTION)" >>$@
	@echo "Version: $(PCRE_VERSION)-$(PCRE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCRE_MAINTAINER)" >>$@
	@echo "Source: $(PCRE_SITE)/$(PCRE_SOURCE)" >>$@
	@echo "Description: $(PCRE_DESCRIPTION)" >>$@
	@echo "Depends: $(PCRE_DEPENDS)" >>$@
	@echo "Conflicts: $(PCRE_CONFLICTS)" >>$@

$(PCRE_IPK): $(PCRE_BUILD_DIR)/.built
	rm -rf $(PCRE_IPK_DIR) $(BUILD_DIR)/pcre_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCRE_BUILD_DIR) DESTDIR=$(PCRE_IPK_DIR) install
	find $(PCRE_IPK_DIR) -type d -exec chmod go+rx {} \;
	$(STRIP_COMMAND) $(PCRE_IPK_DIR)/opt/bin/pcregrep
	$(STRIP_COMMAND) $(PCRE_IPK_DIR)/opt/bin/pcretest
	$(STRIP_COMMAND) $(PCRE_IPK_DIR)/opt/lib/*.so
	rm -f $(PCRE_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(PCRE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCRE_IPK_DIR)

pcre-ipk: $(PCRE_IPK)

pcre-clean:
	-$(MAKE) -C $(PCRE_BUILD_DIR) clean

pcre-dirclean:
	rm -rf $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR) $(PCRE_IPK_DIR) $(PCRE_IPK)
