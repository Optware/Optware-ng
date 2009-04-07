###########################################################
#
# module-init-tools
#
###########################################################
#
# MODULE_INIT_TOOLS_VERSION, MODULE_INIT_TOOLS_SITE and MODULE_INIT_TOOLS_SOURCE define
# the upstream location of the source code for the package.
# MODULE_INIT_TOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# MODULE_INIT_TOOLS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
MODULE_INIT_TOOLS_SITE=http://www.kernel.org/pub/linux/utils/kernel/module-init-tools
MODULE_INIT_TOOLS_VERSION=3.5
MODULE_INIT_TOOLS_SOURCE=module-init-tools-$(MODULE_INIT_TOOLS_VERSION).tar.bz2
MODULE_INIT_TOOLS_DIR=module-init-tools-$(MODULE_INIT_TOOLS_VERSION)
MODULE_INIT_TOOLS_UNZIP=bzcat
MODULE_INIT_TOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MODULE_INIT_TOOLS_DESCRIPTION=This package contains a set of programs for loading, inserting, and removing kernel modules for Linux (versions 2.5.48 and above). It serves the same function that the "modutils" package serves for Linux 2.4.
MODULE_INIT_TOOLS_SECTION=utils
MODULE_INIT_TOOLS_PRIORITY=optional
MODULE_INIT_TOOLS_DEPENDS=
MODULE_INIT_TOOLS_SUGGESTS=
MODULE_INIT_TOOLS_CONFLICTS=

#
# MODULE_INIT_TOOLS_IPK_VERSION should be incremented when the ipk changes.
#
MODULE_INIT_TOOLS_IPK_VERSION=1

#
# MODULE_INIT_TOOLS_CONFFILES should be a list of user-editable files
#MODULE_INIT_TOOLS_CONFFILES=/opt/etc/module-init-tools.conf /opt/etc/init.d/SXXmodule-init-tools

#
# MODULE_INIT_TOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MODULE_INIT_TOOLS_PATCHES=$(MODULE_INIT_TOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MODULE_INIT_TOOLS_CPPFLAGS=
ifneq (, $(filter syno-x07, $(OPTWARE_TARGET)))
MODULE_INIT_TOOLS_CPPFLAGS += -DCONFIG_NO_BACKWARDS_COMPAT
endif
MODULE_INIT_TOOLS_LDFLAGS=

ifeq ($(OPTWARE_TARGET), $(filter cs05q3armel cs08q1armel syno-x07 syno-e500 ts509, $(OPTWARE_TARGET)))
MODULE_INIT_TOOLS_CONFIGURE_OPTIONS=--with-moddir=/opt/lib/modules
endif

#
# MODULE_INIT_TOOLS_BUILD_DIR is the directory in which the build is done.
# MODULE_INIT_TOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MODULE_INIT_TOOLS_IPK_DIR is the directory in which the ipk is built.
# MODULE_INIT_TOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MODULE_INIT_TOOLS_BUILD_DIR=$(BUILD_DIR)/module-init-tools
MODULE_INIT_TOOLS_SOURCE_DIR=$(SOURCE_DIR)/module-init-tools
MODULE_INIT_TOOLS_IPK_DIR=$(BUILD_DIR)/module-init-tools-$(MODULE_INIT_TOOLS_VERSION)-ipk
MODULE_INIT_TOOLS_IPK=$(BUILD_DIR)/module-init-tools_$(MODULE_INIT_TOOLS_VERSION)-$(MODULE_INIT_TOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: module-init-tools-source module-init-tools-unpack module-init-tools module-init-tools-stage module-init-tools-ipk module-init-tools-clean module-init-tools-dirclean module-init-tools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MODULE_INIT_TOOLS_SOURCE):
	$(WGET) -P $(@D) $(MODULE_INIT_TOOLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
module-init-tools-source: $(DL_DIR)/$(MODULE_INIT_TOOLS_SOURCE) $(MODULE_INIT_TOOLS_PATCHES)

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
$(MODULE_INIT_TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(MODULE_INIT_TOOLS_SOURCE) $(MODULE_INIT_TOOLS_PATCHES) make/module-init-tools.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MODULE_INIT_TOOLS_DIR) $(@D)
	$(MODULE_INIT_TOOLS_UNZIP) $(DL_DIR)/$(MODULE_INIT_TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MODULE_INIT_TOOLS_PATCHES)" ; \
		then cat $(MODULE_INIT_TOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MODULE_INIT_TOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MODULE_INIT_TOOLS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MODULE_INIT_TOOLS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MODULE_INIT_TOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MODULE_INIT_TOOLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MODULE_INIT_TOOLS_CONFIGURE_OPTIONS) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MODULE_INIT_TOOLS_BUILD_DIR)/libtool
	touch $@

module-init-tools-unpack: $(MODULE_INIT_TOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MODULE_INIT_TOOLS_BUILD_DIR)/.built: $(MODULE_INIT_TOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
module-init-tools: $(MODULE_INIT_TOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MODULE_INIT_TOOLS_BUILD_DIR)/.staged: $(MODULE_INIT_TOOLS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

module-init-tools-stage: $(MODULE_INIT_TOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/module-init-tools
#
$(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: module-init-tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MODULE_INIT_TOOLS_PRIORITY)" >>$@
	@echo "Section: $(MODULE_INIT_TOOLS_SECTION)" >>$@
	@echo "Version: $(MODULE_INIT_TOOLS_VERSION)-$(MODULE_INIT_TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MODULE_INIT_TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(MODULE_INIT_TOOLS_SITE)/$(MODULE_INIT_TOOLS_SOURCE)" >>$@
	@echo "Description: $(MODULE_INIT_TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(MODULE_INIT_TOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(MODULE_INIT_TOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(MODULE_INIT_TOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MODULE_INIT_TOOLS_IPK_DIR)/opt/sbin or $(MODULE_INIT_TOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MODULE_INIT_TOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MODULE_INIT_TOOLS_IPK_DIR)/opt/etc/module-init-tools/...
# Documentation files should be installed in $(MODULE_INIT_TOOLS_IPK_DIR)/opt/doc/module-init-tools/...
# Daemon startup scripts should be installed in $(MODULE_INIT_TOOLS_IPK_DIR)/opt/etc/init.d/S??module-init-tools
#
# You may need to patch your application to make it use these locations.
#
$(MODULE_INIT_TOOLS_IPK): $(MODULE_INIT_TOOLS_BUILD_DIR)/.built
	rm -rf $(MODULE_INIT_TOOLS_IPK_DIR) $(BUILD_DIR)/module-init-tools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MODULE_INIT_TOOLS_BUILD_DIR) install-strip \
		DESTDIR=$(MODULE_INIT_TOOLS_IPK_DIR) transform=''
	$(MAKE) $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/prerm
	cd $(MODULE_INIT_TOOLS_IPK_DIR)/opt/sbin; \
	for f in depmod insmod modprobe rmmod; do \
	    mv $$f module-init-tools-$$f; \
	    echo "update-alternatives --install /opt/sbin/$$f $$f /opt/sbin/module-init-tools-$$f 80" \
		>> $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/sbin/module-init-tools-$$f" \
		>> $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/postinst $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MODULE_INIT_TOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(MODULE_INIT_TOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MODULE_INIT_TOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
module-init-tools-ipk: $(MODULE_INIT_TOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
module-init-tools-clean:
	rm -f $(MODULE_INIT_TOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(MODULE_INIT_TOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
module-init-tools-dirclean:
	rm -rf $(BUILD_DIR)/$(MODULE_INIT_TOOLS_DIR) $(MODULE_INIT_TOOLS_BUILD_DIR) $(MODULE_INIT_TOOLS_IPK_DIR) $(MODULE_INIT_TOOLS_IPK)
#
#
# Some sanity check for the package.
#
module-init-tools-check: $(MODULE_INIT_TOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
