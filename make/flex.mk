###########################################################
#
# flex
#
###########################################################

FLEX_SITE=https://github.com/westes/flex/releases/download/v$(FLEX_VERSION)
FLEX_VERSION=2.6.4
FLEX_SOURCE=flex-$(FLEX_VERSION).tar.gz
FLEX_DIR=flex-$(FLEX_VERSION)
FLEX_UNZIP=zcat
FLEX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FLEX_DESCRIPTION=Generates programs that perform pattern-matching on text.
FLEX_SECTION=devel
FLEX_PRIORITY=optional
FLEX_DEPENDS=m4
FLEX_CONFLICTS=

FLEX_IPK_VERSION=1

FLEX_BUILD_DIR=$(BUILD_DIR)/flex
FLEX_SOURCE_DIR=$(SOURCE_DIR)/flex
FLEX_IPK_DIR=$(BUILD_DIR)/flex-$(FLEX_VERSION)-ipk
FLEX_IPK=$(BUILD_DIR)/flex_$(FLEX_VERSION)-$(FLEX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: flex-source flex-unpack flex flex-stage flex-ipk flex-clean flex-dirclean flex-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FLEX_SOURCE):
	$(WGET) -P $(DL_DIR) $(FLEX_SITE)/$(FLEX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
flex-source: $(DL_DIR)/$(FLEX_SOURCE)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(FLEX_BUILD_DIR)/.configured: $(DL_DIR)/$(FLEX_SOURCE) make/flex.mk
	rm -rf $(BUILD_DIR)/$(FLEX_DIR) $(@D)
	$(FLEX_UNZIP) $(DL_DIR)/$(FLEX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(FLEX_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FLEX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FLEX_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-shared \
		--disable-static \
		--disable-nls \
	)
	sed -i -e 's|/usr/bin|$(TARGET_PREFIX)/bin|'  $(@D)/src/config.h
	touch $@

flex-unpack: $(FLEX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FLEX_BUILD_DIR)/.built: $(FLEX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
flex: $(FLEX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FLEX_BUILD_DIR)/.staged: $(FLEX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
ifneq ($(HOSTCC), $(TARGET_CC)) # prevent PATH=staging$(TARGET_PREFIX)/bin problems
	if test -x $(STAGING_PREFIX)/bin/flex ;\
		 then rm $(STAGING_PREFIX)/bin/flex ;\
	fi
endif
	touch $@

flex-stage: $(FLEX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.
#
$(FLEX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: flex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FLEX_PRIORITY)" >>$@
	@echo "Section: $(FLEX_SECTION)" >>$@
	@echo "Version: $(FLEX_VERSION)-$(FLEX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FLEX_MAINTAINER)" >>$@
	@echo "Source: $(FLEX_SITE)/$(FLEX_SOURCE)" >>$@
	@echo "Description: $(FLEX_DESCRIPTION)" >>$@
	@echo "Depends: $(FLEX_DEPENDS)" >>$@
	@echo "Conflicts: $(FLEX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(FLEX_IPK): $(FLEX_BUILD_DIR)/.built
	rm -rf $(FLEX_IPK_DIR) $(BUILD_DIR)/flex_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FLEX_BUILD_DIR) DESTDIR=$(FLEX_IPK_DIR) install-strip
	rm -f $(FLEX_IPK_DIR)$(TARGET_PREFIX)/info/dir
	rm -rf $(FLEX_IPK_DIR)$(TARGET_PREFIX)/man
	$(MAKE) $(FLEX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FLEX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
flex-ipk: $(FLEX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
flex-clean:
	-$(MAKE) -C $(FLEX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
flex-dirclean:
	rm -rf $(BUILD_DIR)/$(FLEX_DIR) $(FLEX_BUILD_DIR) $(FLEX_IPK_DIR) $(FLEX_IPK)

#
# Some sanity check for the package.
#
flex-check: $(FLEX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FLEX_IPK)
