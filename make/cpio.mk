###########################################################
#
# cpio
#
###########################################################

CPIO_SITE=http://ftp.gnu.org/gnu/cpio
CPIO_VERSION=2.9
CPIO_SOURCE=cpio-$(CPIO_VERSION).tar.bz2
CPIO_DIR=cpio-$(CPIO_VERSION)
CPIO_UNZIP=bzcat
CPIO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CPIO_DESCRIPTION=file archive utility
CPIO_SECTION=utilities
CPIO_PRIORITY=optional
CPIO_DEPENDS=

#
# CPIO_IPK_VERSION should be incremented when the ipk changes.
#
CPIO_IPK_VERSION=3

#
# CPIO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CPIO_CPPFLAGS=
CPIO_LDFLAGS=

#
# CPIO_BUILD_DIR is the directory in which the build is done.
# CPIO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CPIO_IPK_DIR is the directory in which the ipk is built.
# CPIO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CPIO_BUILD_DIR=$(BUILD_DIR)/cpio
CPIO_SOURCE_DIR=$(SOURCE_DIR)/cpio
CPIO_IPK_DIR=$(BUILD_DIR)/cpio-$(CPIO_VERSION)-ipk
CPIO_IPK=$(BUILD_DIR)/cpio_$(CPIO_VERSION)-$(CPIO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cpio-source cpio-unpack cpio cpio-stage cpio-ipk cpio-clean cpio-dirclean cpio-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CPIO_SOURCE):
	$(WGET) -P $(DL_DIR) $(CPIO_SITE)/$(CPIO_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CPIO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cpio-source: $(DL_DIR)/$(CPIO_SOURCE) $(CPIO_PATCHES)

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
$(CPIO_BUILD_DIR)/.configured: $(DL_DIR)/$(CPIO_SOURCE) $(CPIO_PATCHES) make/cpio.mk
	rm -rf $(BUILD_DIR)/$(CPIO_DIR) $(CPIO_BUILD_DIR)
	$(CPIO_UNZIP) $(DL_DIR)/$(CPIO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(CPIO_DIR) $(CPIO_BUILD_DIR)
	(cd $(CPIO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CPIO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CPIO_LDFLAGS)" \
		./configure \
		CPIO_MT_PROG=mt \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

cpio-unpack: $(CPIO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CPIO_BUILD_DIR)/.built: $(CPIO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CPIO_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
cpio: $(CPIO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#

cpio-stage: $(STAGING_DIR)/opt/lib/libcpio.so.$(CPIO_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cpio
#
$(CPIO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cpio" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CPIO_PRIORITY)" >>$@
	@echo "Section: $(CPIO_SECTION)" >>$@
	@echo "Version: $(CPIO_VERSION)-$(CPIO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CPIO_MAINTAINER)" >>$@
	@echo "Source: $(CPIO_SITE)/$(CPIO_SOURCE)" >>$@
	@echo "Description: $(CPIO_DESCRIPTION)" >>$@
	@echo "Depends: $(CPIO_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CPIO_IPK_DIR)/opt/sbin or $(CPIO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CPIO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CPIO_IPK_DIR)/opt/etc/cpio/...
# Documentation files should be installed in $(CPIO_IPK_DIR)/opt/doc/cpio/...
# Daemon startup scripts should be installed in $(CPIO_IPK_DIR)/opt/etc/init.d/S??cpio
#
# You may need to patch your application to make it use these locations.
#
$(CPIO_IPK): $(CPIO_BUILD_DIR)/.built
	rm -rf $(CPIO_IPK_DIR) $(BUILD_DIR)/cpio_*_$(TARGET_ARCH).ipk
	install -d $(CPIO_IPK_DIR)/opt/bin
	$(MAKE) -C $(CPIO_BUILD_DIR) DESTDIR=$(CPIO_IPK_DIR) install-strip
	mv $(CPIO_IPK_DIR)/opt/bin/cpio $(CPIO_IPK_DIR)/opt/bin/cpio-cpio
	$(MAKE) $(CPIO_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/cpio cpio /opt/bin/cpio-cpio 80"; \
	) > $(CPIO_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove cpio /opt/bin/cpio-cpio"; \
	) > $(CPIO_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CPIO_IPK_DIR)/CONTROL/postinst $(CPIO_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CPIO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cpio-ipk: $(CPIO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cpio-clean:
	rm -f $(CPIO_BUILD_DIR)/.built
	-$(MAKE) -C $(CPIO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cpio-dirclean:
	rm -rf $(BUILD_DIR)/$(CPIO_DIR) $(CPIO_BUILD_DIR) $(CPIO_IPK_DIR) $(CPIO_IPK)

#
# Some sanity check for the package.
#
cpio-check: $(CPIO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CPIO_IPK)
