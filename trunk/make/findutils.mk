###########################################################
#
# FINDUTILS
#
###########################################################

FINDUTILS_NAME=findutils
FINDUTILS_DOC_NAME=findutils-doc
FINDUTILS_SITE=http://ftp.gnu.org/pub/gnu/findutils
ifneq ($(OPTWARE_TARGET),wl500g)
FINDUTILS_VERSION=4.2.31
FINDUTILS_IPK_VERSION=2
else
FINDUTILS_VERSION=4.1.20
FINDUTILS_IPK_VERSION=3
endif
FINDUTILS_SOURCE=$(FINDUTILS_NAME)-$(FINDUTILS_VERSION).tar.gz
FINDUTILS_DIR=$(FINDUTILS_NAME)-$(FINDUTILS_VERSION)
FINDUTILS_UNZIP=zcat

#
# FINDUTILS_IPK_VERSION should be incremented when the ipk changes.
#

#
# Control file info
#
FINDUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FINDUTILS_DESCRIPTION=File finding utilities
FINDUTILS_SECTION=utilities
FINDUTILS_PRIORITY=optional
FINDUTILS_CONFLICTS=busybox-links
FINDUTILS_DEPENDS=

FINDUTILS_DOC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FINDUTILS_DOC_DESCRIPTION=Documentation for file finding utilities
FINDUTILS_DOC_SECTION=documentation
FINDUTILS_DOC_PRIORITY=optional
FINDUTILS_DOC_CONFLICTS=
FINDUTILS_DOC_DEPENDS=

#
# FINDUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FINDUTILS_CPPFLAGS=
FINDUTILS_LDFLAGS=

#
# FINDUTILS_BUILD_DIR is the directory in which the build is done.
# FINDUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FINDUTILS_IPK_DIR is the directory in which the ipk is built.
# FINDUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FINDUTILS_BUILD_DIR=$(BUILD_DIR)/findutils
FINDUTILS_SOURCE_DIR=$(SOURCE_DIR)/findutils
FINDUTILS_IPK_DIR=$(BUILD_DIR)/findutils-$(FINDUTILS_VERSION)-ipk
FINDUTILS_IPK=$(BUILD_DIR)/findutils_$(FINDUTILS_VERSION)-$(FINDUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk
FINDUTILS_DOC_IPK_DIR=$(BUILD_DIR)/findutils-doc-$(FINDUTILS_VERSION)-ipk
FINDUTILS_DOC_IPK=$(BUILD_DIR)/findutils-doc_$(FINDUTILS_VERSION)-$(FINDUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: findutils-source findutils-unpack findutils findutils-stage findutils-ipk findutils-clean findutils-dirclean findutils-check

#
# Automatically create a ipkg control file
#
$(FINDUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: findutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FINDUTILS_PRIORITY)" >>$@
	@echo "Section: $(FINDUTILS_SECTION)" >>$@
	@echo "Version: $(FINDUTILS_VERSION)-$(FINDUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FINDUTILS_MAINTAINER)" >>$@
	@echo "Source: $(FINDUTILS_SITE)/$(FINDUTILS_SOURCE)" >>$@
	@echo "Description: $(FINDUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(FINDUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(FINDUTILS_CONFLICTS)" >>$@

#
# Automatically create a ipkg control file
#
$(FINDUTILS_DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: findutils-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FINDUTILS_DOC_PRIORITY)" >>$@
	@echo "Section: $(FINDUTILS_DOC_SECTION)" >>$@
	@echo "Version: $(FINDUTILS_VERSION)-$(FINDUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FINDUTILS_DOC_MAINTAINER)" >>$@
	@echo "Source: $(FINDUTILS_SITE)/$(FINDUTILS_SOURCE)" >>$@
	@echo "Description: $(FINDUTILS_DOC_DESCRIPTION)" >>$@
	@echo "Depends: $(FINDUTILS_DOC_DEPENDS)" >>$@
	@echo "Conflicts: $(FINDUTILS_DOC_CONFLICTS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FINDUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(FINDUTILS_SITE)/$(FINDUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
findutils-source: $(DL_DIR)/$(FINDUTILS_SOURCE) $(FINDUTILS_PATCHES)

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
$(FINDUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(FINDUTILS_SOURCE) $(FINDUTILS_PATCHES)
	rm -rf $(BUILD_DIR)/$(FINDUTILS_DIR) $(FINDUTILS_BUILD_DIR)
	$(FINDUTILS_UNZIP) $(DL_DIR)/$(FINDUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FINDUTILS_PATCHES)" ; \
		then cat $(FINDUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FINDUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FINDUTILS_DIR)" != "$(FINDUTILS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FINDUTILS_DIR) $(FINDUTILS_BUILD_DIR) ; \
	fi
	(cd $(FINDUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FINDUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FINDUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(FINDUTILS_BUILD_DIR)/.configured

findutils-unpack: $(FINDUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(FINDUTILS_BUILD_DIR)/.built: $(FINDUTILS_BUILD_DIR)/.configured
	rm -f $(FINDUTILS_BUILD_DIR)/.built
	$(MAKE) -C $(FINDUTILS_BUILD_DIR)
	touch $(FINDUTILS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
findutils: $(FINDUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#

#
# This builds the IPK file.
#
# Binaries should be installed into $(FINDUTILS_IPK_DIR)/opt/sbin or $(FINDUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FINDUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FINDUTILS_IPK_DIR)/opt/etc/findutils/...
# Documentation files should be installed in $(FINDUTILS_IPK_DIR)/opt/doc/findutils/...
# Daemon startup scripts should be installed in $(FINDUTILS_IPK_DIR)/opt/etc/init.d/S??findutils
#
# You may need to patch your application to make it use these locations.
#
$(FINDUTILS_IPK): $(FINDUTILS_BUILD_DIR)/.built
	rm -rf $(FINDUTILS_IPK_DIR) $(BUILD_DIR)/findutils_*_$(TARGET_ARCH).ipk
	install -d $(FINDUTILS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(FINDUTILS_BUILD_DIR)/find/find -o $(FINDUTILS_IPK_DIR)/opt/bin/findutils-find
	$(STRIP_COMMAND) $(FINDUTILS_BUILD_DIR)/xargs/xargs -o $(FINDUTILS_IPK_DIR)/opt/bin/findutils-xargs
	install -d $(FINDUTILS_IPK_DIR)/opt/man/man1
	install -m 644 $(FINDUTILS_BUILD_DIR)/find/find.1 $(FINDUTILS_IPK_DIR)/opt/man/man1
	install -m 644 $(FINDUTILS_BUILD_DIR)/xargs/xargs.1 $(FINDUTILS_IPK_DIR)/opt/man/man1
	make  $(FINDUTILS_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/find find /opt/bin/findutils-find 80"; \
	 echo "update-alternatives --install /opt/bin/xargs xargs /opt/bin/findutils-xargs 80"; \
	) > $(FINDUTILS_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove find /opt/bin/findutils-find"; \
	 echo "update-alternatives --remove xargs /opt/bin/findutils-xargs"; \
	) > $(FINDUTILS_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FINDUTILS_IPK_DIR)

$(FINDUTILS_DOC_IPK): $(FINDUTILS_BUILD_DIR)/.built
	rm -rf $(FINDUTILS_DOC_IPK_DIR) $(BUILD_DIR)/findutils-doc_*_$(TARGET_ARCH).ipk
	install -d $(FINDUTILS_DOC_IPK_DIR)/opt/doc/findutils
	install -m 644 $(FINDUTILS_BUILD_DIR)/doc/find.i* $(FINDUTILS_DOC_IPK_DIR)/opt/doc/findutils
	make  $(FINDUTILS_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FINDUTILS_DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
findutils-ipk: $(FINDUTILS_IPK) $(FINDUTILS_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
findutils-clean:
	-$(MAKE) -C $(FINDUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
findutils-dirclean:
	rm -rf $(BUILD_DIR)/$(FINDUTILS_DIR) $(FINDUTILS_BUILD_DIR)
	rm -rf $(FINDUTILS_IPK_DIR) $(FINDUTILS_IPK) $(FINDUTILS_DOC_IPK_DIR) $(FINDUTILS_DOC_IPK)

#
# Some sanity check for the package.
#
findutils-check: $(FINDUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FINDUTILS_IPK)
