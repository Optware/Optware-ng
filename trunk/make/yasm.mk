###########################################################
#
# yasm
#
###########################################################
#
# YASM_VERSION, YASM_SITE and YASM_SOURCE define
# the upstream location of the source code for the package.
# YASM_DIR is the directory which is created when the source
# archive is unpacked.
# YASM_UNZIP is the command used to unzip the source.
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
YASM_SITE=http://www.tortall.net/projects/yasm/releases
YASM_VERSION=1.1.0
YASM_SOURCE=yasm-$(YASM_VERSION).tar.gz
YASM_DIR=yasm-$(YASM_VERSION)
YASM_UNZIP=zcat
YASM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
YASM_DESCRIPTION=Yasm Modular Assembler, currently for x86 or x86_64.
YASM_SECTION=devel
YASM_PRIORITY=optional
YASM_DEPENDS=
YASM_SUGGESTS=
YASM_CONFLICTS=

#
# YASM_IPK_VERSION should be incremented when the ipk changes.
#
YASM_IPK_VERSION=1

#
# YASM_CONFFILES should be a list of user-editable files
#YASM_CONFFILES=/opt/etc/yasm.conf /opt/etc/init.d/SXXyasm

#
# YASM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#YASM_PATCHES=$(YASM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
YASM_CPPFLAGS=
YASM_LDFLAGS=

#
# YASM_BUILD_DIR is the directory in which the build is done.
# YASM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# YASM_IPK_DIR is the directory in which the ipk is built.
# YASM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
YASM_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/yasm
YASM_BUILD_DIR=$(BUILD_DIR)/yasm
YASM_SOURCE_DIR=$(SOURCE_DIR)/yasm
YASM_IPK_DIR=$(BUILD_DIR)/yasm-$(YASM_VERSION)-ipk
YASM_IPK=$(BUILD_DIR)/yasm_$(YASM_VERSION)-$(YASM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: yasm-source yasm-unpack yasm yasm-stage yasm-ipk yasm-clean yasm-dirclean yasm-check yasm-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(YASM_SOURCE):
	$(WGET) -P $(@D) $(YASM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
yasm-source: $(DL_DIR)/$(YASM_SOURCE) $(YASM_PATCHES)

$(YASM_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(YASM_SOURCE) $(YASM_PATCHES) make/yasm.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(HOST_BUILD_DIR)/$(YASM_DIR) $(@D)
	$(YASM_UNZIP) $(DL_DIR)/$(YASM_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(YASM_PATCHES)" ; \
		then cat $(YASM_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(YASM_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(YASM_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(YASM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(@D)
	$(MAKE) -C $(@D) DESTDIR=$(HOST_STAGING_DIR) install
	touch $@

yasm-host-stage: $(YASM_HOST_BUILD_DIR)/.staged

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
$(YASM_BUILD_DIR)/.configured: $(DL_DIR)/$(YASM_SOURCE) $(YASM_PATCHES) make/yasm.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(YASM_DIR) $(@D)
	$(YASM_UNZIP) $(DL_DIR)/$(YASM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(YASM_PATCHES)" ; \
		then cat $(YASM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(YASM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(YASM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(YASM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(YASM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(YASM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

yasm-unpack: $(YASM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(YASM_BUILD_DIR)/.built: $(YASM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
yasm: $(YASM_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/yasm
#
$(YASM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: yasm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(YASM_PRIORITY)" >>$@
	@echo "Section: $(YASM_SECTION)" >>$@
	@echo "Version: $(YASM_VERSION)-$(YASM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(YASM_MAINTAINER)" >>$@
	@echo "Source: $(YASM_SITE)/$(YASM_SOURCE)" >>$@
	@echo "Description: $(YASM_DESCRIPTION)" >>$@
	@echo "Depends: $(YASM_DEPENDS)" >>$@
	@echo "Suggests: $(YASM_SUGGESTS)" >>$@
	@echo "Conflicts: $(YASM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(YASM_IPK_DIR)/opt/sbin or $(YASM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(YASM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(YASM_IPK_DIR)/opt/etc/yasm/...
# Documentation files should be installed in $(YASM_IPK_DIR)/opt/doc/yasm/...
# Daemon startup scripts should be installed in $(YASM_IPK_DIR)/opt/etc/init.d/S??yasm
#
# You may need to patch your application to make it use these locations.
#
$(YASM_IPK): $(YASM_BUILD_DIR)/.built
	rm -rf $(YASM_IPK_DIR) $(BUILD_DIR)/yasm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(YASM_BUILD_DIR) DESTDIR=$(YASM_IPK_DIR) install-strip
#	install -d $(YASM_IPK_DIR)/opt/etc/
#	install -m 644 $(YASM_SOURCE_DIR)/yasm.conf $(YASM_IPK_DIR)/opt/etc/yasm.conf
#	install -d $(YASM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(YASM_SOURCE_DIR)/rc.yasm $(YASM_IPK_DIR)/opt/etc/init.d/SXXyasm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(YASM_IPK_DIR)/opt/etc/init.d/SXXyasm
	$(MAKE) $(YASM_IPK_DIR)/CONTROL/control
#	install -m 755 $(YASM_SOURCE_DIR)/postinst $(YASM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(YASM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(YASM_SOURCE_DIR)/prerm $(YASM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(YASM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(YASM_IPK_DIR)/CONTROL/postinst $(YASM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(YASM_CONFFILES) | sed -e 's/ /\n/g' > $(YASM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(YASM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
yasm-ipk: $(YASM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
yasm-clean:
	rm -f $(YASM_BUILD_DIR)/.built
	-$(MAKE) -C $(YASM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
yasm-dirclean:
	rm -rf $(BUILD_DIR)/$(YASM_DIR) $(YASM_BUILD_DIR) $(YASM_IPK_DIR) $(YASM_IPK)
#
#
# Some sanity check for the package.
#
yasm-check: $(YASM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
