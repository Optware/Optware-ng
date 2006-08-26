###########################################################
#
# freeze
#
###########################################################

FREEZE_SITE=ftp://sunsite.unc.edu/pub/Linux/utils/compress
FREEZE_VERSION=2.5.0
FREEZE_SOURCE=freeze-$(FREEZE_VERSION).tar.gz
FREEZE_DIR=freeze-$(FREEZE_VERSION)
FREEZE_UNZIP=zcat
FREEZE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FREEZE_DESCRIPTION=freeze - archiver and compressor
FREEZE_SECTION=apps
FREEZE_PRIORITY=optional
FREEZE_DEPENDS=
FREEZE_SUGGESTS=
FREEZE_CONFLICTS=

#
# FREEZE_IPK_VERSION should be incremented when the ipk changes.
#
FREEZE_IPK_VERSION=1

#
# FREEZE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FREEZE_PATCHES=$(FREEZE_SOURCE_DIR)/freeze-2.5.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FREEZE_CPPFLAGS=
FREEZE_LDFLAGS=

#
# FREEZE_BUILD_DIR is the directory in which the build is done.
# FREEZE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FREEZE_IPK_DIR is the directory in which the ipk is built.
# FREEZE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FREEZE_BUILD_DIR=$(BUILD_DIR)/freeze
FREEZE_SOURCE_DIR=$(SOURCE_DIR)/freeze
FREEZE_IPK_DIR=$(BUILD_DIR)/freeze-$(FREEZE_VERSION)-ipk
FREEZE_IPK=$(BUILD_DIR)/freeze_$(FREEZE_VERSION)-$(FREEZE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FREEZE_SOURCE):
	$(WGET) -P $(DL_DIR) $(FREEZE_SITE)/$(FREEZE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
freeze-source: $(DL_DIR)/$(FREEZE_SOURCE) $(FREEZE_PATCHES)

$(FREEZE_BUILD_DIR)/.configured: $(DL_DIR)/$(FREEZE_SOURCE) $(FREEZE_PATCHES) make/freeze.mk
	rm -rf $(BUILD_DIR)/$(FREEZE_DIR) $(FREEZE_BUILD_DIR)
	$(FREEZE_UNZIP) $(DL_DIR)/$(FREEZE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FREEZE_PATCHES)" ; \
		then cat $(FREEZE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FREEZE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FREEZE_DIR)" != "$(FREEZE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FREEZE_DIR) $(FREEZE_BUILD_DIR) ; \
	fi
	(cd $(FREEZE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FREEZE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FREEZE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(FREEZE_BUILD_DIR)/.configured

freeze-unpack: $(FREEZE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FREEZE_BUILD_DIR)/.built: $(FREEZE_BUILD_DIR)/.configured
	rm -f $(FREEZE_BUILD_DIR)/.built
	$(MAKE) -C $(FREEZE_BUILD_DIR)
	touch $(FREEZE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
freeze: $(FREEZE_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/freeze
#
$(FREEZE_IPK_DIR)/CONTROL/control:
	@install -d $(FREEZE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: freeze" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FREEZE_PRIORITY)" >>$@
	@echo "Section: $(FREEZE_SECTION)" >>$@
	@echo "Version: $(FREEZE_VERSION)-$(FREEZE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FREEZE_MAINTAINER)" >>$@
	@echo "Source: $(FREEZE_SITE)/$(FREEZE_SOURCE)" >>$@
	@echo "Description: $(FREEZE_DESCRIPTION)" >>$@
	@echo "Depends: $(FREEZE_DEPENDS)" >>$@
	@echo "Suggests: $(FREEZE_SUGGESTS)" >>$@
	@echo "Conflicts: $(FREEZE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FREEZE_IPK_DIR)/opt/sbin or $(FREEZE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FREEZE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FREEZE_IPK_DIR)/opt/etc/freeze/...
# Documentation files should be installed in $(FREEZE_IPK_DIR)/opt/doc/freeze/...
# Daemon startup scripts should be installed in $(FREEZE_IPK_DIR)/opt/etc/init.d/S??freeze
#
# You may need to patch your application to make it use these locations.
#
$(FREEZE_IPK): $(FREEZE_BUILD_DIR)/.built
	rm -rf $(FREEZE_IPK_DIR) $(BUILD_DIR)/freeze_*_$(TARGET_ARCH).ipk
	install -d $(FREEZE_IPK_DIR)/opt/bin
	install -d $(FREEZE_IPK_DIR)/opt/share/man/man1
	$(MAKE) -C $(FREEZE_BUILD_DIR) prefix=$(FREEZE_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(FREEZE_IPK_DIR)/opt/bin/freeze
	$(STRIP_COMMAND) $(FREEZE_IPK_DIR)/opt/bin/statist
	$(MAKE) $(FREEZE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FREEZE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
freeze-ipk: $(FREEZE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
freeze-clean:
	rm -f $(FREEZE_BUILD_DIR)/.built
	-$(MAKE) -C $(FREEZE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
freeze-dirclean:
	rm -rf $(BUILD_DIR)/$(FREEZE_DIR) $(FREEZE_BUILD_DIR) $(FREEZE_IPK_DIR) $(FREEZE_IPK)
