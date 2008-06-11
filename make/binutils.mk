###########################################################
#
# binutils
#
###########################################################

#
# BINUTILS_VERSION, BINUTILS_SITE and BINUTILS_SOURCE define
# the upstream location of the source code for the package.
# BINUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# BINUTILS_UNZIP is the command used to unzip the source.
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
BINUTILS_SITE=http://ftp.gnu.org/gnu/binutils
BINUTILS_VERSION:=2.17
BINUTILS_SOURCE=binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_DIR=binutils-$(BINUTILS_VERSION)
BINUTILS_UNZIP=bzcat
BINUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BINUTILS_DESCRIPTION=The GNU assembler and linker and related tools
BINUTILS_SECTION=devel
BINUTILS_PRIORITY=optional
BINUTILS_DEPENDS=
BINUTILS_SUGGESTS=
BINUTILS_CONFLICTS=

#
# BINUTILS_IPK_VERSION should be incremented when the ipk changes.
#
BINUTILS_IPK_VERSION=2

#
# BINUTILS_CONFFILES should be a list of user-editable files
#BINUTILS_CONFFILES=/opt/etc/binutils.conf /opt/etc/init.d/SXXbinutils

#
# BINUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BINUTILS_PATCHES=$(BINUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BINUTILS_CPPFLAGS=
BINUTILS_LDFLAGS=

#
# BINUTILS_BUILD_DIR is the directory in which the build is done.
# BINUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BINUTILS_IPK_DIR is the directory in which the ipk is built.
# BINUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BINUTILS_BUILD_DIR=$(BUILD_DIR)/binutils
BINUTILS_SOURCE_DIR=$(SOURCE_DIR)/binutils
BINUTILS_IPK_DIR=$(BUILD_DIR)/binutils-$(BINUTILS_VERSION)-ipk
BINUTILS_IPK=$(BUILD_DIR)/binutils_$(BINUTILS_VERSION)-$(BINUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: binutils-source binutils-unpack binutils binutils-stage binutils-ipk binutils-clean binutils-dirclean binutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BINUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(BINUTILS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
binutils-source: $(DL_DIR)/$(BINUTILS_SOURCE) $(BINUTILS_PATCHES)

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
$(BINUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(BINUTILS_SOURCE) $(BINUTILS_PATCHES) make/binutils.mk
	rm -rf $(BUILD_DIR)/$(BINUTILS_DIR) $(@D)
	$(BINUTILS_UNZIP) $(DL_DIR)/$(BINUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BINUTILS_PATCHES)" ; \
		then cat $(BINUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BINUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BINUTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BINUTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BINUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BINUTILS_LDFLAGS)" \
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

binutils-unpack: $(BINUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BINUTILS_BUILD_DIR)/.built: $(BINUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
binutils: $(BINUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BINUTILS_BUILD_DIR)/.staged: $(BINUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

binutils-stage: $(BINUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/binutils
#
$(BINUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: binutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BINUTILS_PRIORITY)" >>$@
	@echo "Section: $(BINUTILS_SECTION)" >>$@
	@echo "Version: $(BINUTILS_VERSION)-$(BINUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BINUTILS_MAINTAINER)" >>$@
	@echo "Source: $(BINUTILS_SITE)/$(BINUTILS_SOURCE)" >>$@
	@echo "Description: $(BINUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(BINUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(BINUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BINUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BINUTILS_IPK_DIR)/opt/sbin or $(BINUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BINUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BINUTILS_IPK_DIR)/opt/etc/binutils/...
# Documentation files should be installed in $(BINUTILS_IPK_DIR)/opt/doc/binutils/...
# Daemon startup scripts should be installed in $(BINUTILS_IPK_DIR)/opt/etc/init.d/S??binutils
#
# You may need to patch your application to make it use these locations.
#
$(BINUTILS_IPK): $(BINUTILS_BUILD_DIR)/.built
	rm -rf $(BINUTILS_IPK_DIR) $(BUILD_DIR)/binutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BINUTILS_BUILD_DIR) DESTDIR=$(BINUTILS_IPK_DIR) install
	$(STRIP_COMMAND) $(BINUTILS_IPK_DIR)/opt/bin/*
	mv $(BINUTILS_IPK_DIR)/opt/bin/strings $(BINUTILS_IPK_DIR)/opt/bin/binutils-strings
	$(MAKE) $(BINUTILS_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh" ; \
	 echo "update-alternatives --install /opt/bin/strings strings /opt/bin/binutils-strings 50" ; \
	) > $(BINUTILS_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh" ; \
	 echo "update-alternatives --remove strings /opt/bin/binutils-strings" ; \
	) > $(BINUTILS_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ |]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
		$(BINUTILS_IPK_DIR)/CONTROL/postinst $(BINUTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(BINUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(BINUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BINUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
binutils-ipk: $(BINUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
binutils-clean:
	rm -f $(BINUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(BINUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
binutils-dirclean:
	rm -rf $(BUILD_DIR)/$(BINUTILS_DIR) $(BINUTILS_BUILD_DIR) $(BINUTILS_IPK_DIR) $(BINUTILS_IPK)
#
#
# Some sanity check for the package.
#
binutils-check: $(BINUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BINUTILS_IPK)
