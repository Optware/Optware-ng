###########################################################
#
# pciutils
#
###########################################################
#
# PCIUTILS_VERSION, PCIUTILS_SITE and PCIUTILS_SOURCE define
# the upstream location of the source code for the package.
# PCIUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PCIUTILS_UNZIP is the command used to unzip the source.
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
PCIUTILS_SITE=http://www.kernel.org/pub/software/utils/pciutils
PCIUTILS_VERSION=2.2.10
PCIUTILS_SOURCE=pciutils-$(PCIUTILS_VERSION).tar.bz2
PCIUTILS_DIR=pciutils-$(PCIUTILS_VERSION)
PCIUTILS_UNZIP=bzcat
PCIUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCIUTILS_DESCRIPTION=Linux PCI Utilities, various utilities for inspecting and setting of devices connected to the PCI bus.
PCIUTILS_SECTION=utils
PCIUTILS_PRIORITY=optional
PCIUTILS_DEPENDS=zlib
PCIUTILS_SUGGESTS=
PCIUTILS_CONFLICTS=

#
# PCIUTILS_IPK_VERSION should be incremented when the ipk changes.
#
PCIUTILS_IPK_VERSION=1

#
# PCIUTILS_CONFFILES should be a list of user-editable files
#PCIUTILS_CONFFILES=/opt/etc/pciutils.conf /opt/etc/init.d/SXXpciutils

#
# PCIUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PCIUTILS_PATCHES=$(PCIUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCIUTILS_CPPFLAGS=
PCIUTILS_LDFLAGS=-lz

#
# PCIUTILS_BUILD_DIR is the directory in which the build is done.
# PCIUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCIUTILS_IPK_DIR is the directory in which the ipk is built.
# PCIUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCIUTILS_BUILD_DIR=$(BUILD_DIR)/pciutils
PCIUTILS_SOURCE_DIR=$(SOURCE_DIR)/pciutils
PCIUTILS_IPK_DIR=$(BUILD_DIR)/pciutils-$(PCIUTILS_VERSION)-ipk
PCIUTILS_IPK=$(BUILD_DIR)/pciutils_$(PCIUTILS_VERSION)-$(PCIUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pciutils-source pciutils-unpack pciutils pciutils-stage pciutils-ipk pciutils-clean pciutils-dirclean pciutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PCIUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PCIUTILS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pciutils-source: $(DL_DIR)/$(PCIUTILS_SOURCE) $(PCIUTILS_PATCHES)

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
$(PCIUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PCIUTILS_SOURCE) $(PCIUTILS_PATCHES) make/pciutils.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(PCIUTILS_DIR) $(@D)
	$(PCIUTILS_UNZIP) $(DL_DIR)/$(PCIUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PCIUTILS_PATCHES)" ; \
		then cat $(PCIUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PCIUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PCIUTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PCIUTILS_DIR) $(@D) ; \
	fi
	sed -i -e '/$$(INSTALL)/s/-s //' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCIUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCIUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(PCIUTILS_BUILD_DIR)/libtool
	touch $@

pciutils-unpack: $(PCIUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCIUTILS_BUILD_DIR)/.built: $(PCIUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCIUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCIUTILS_LDFLAGS)" \
		PREFIX=/opt \
		HOST=$(GNU_TARGET_NAME) \
	;
	touch $@

#
# This is the build convenience target.
#
pciutils: $(PCIUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCIUTILS_BUILD_DIR)/.staged: $(PCIUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

pciutils-stage: $(PCIUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pciutils
#
$(PCIUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pciutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCIUTILS_PRIORITY)" >>$@
	@echo "Section: $(PCIUTILS_SECTION)" >>$@
	@echo "Version: $(PCIUTILS_VERSION)-$(PCIUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCIUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PCIUTILS_SITE)/$(PCIUTILS_SOURCE)" >>$@
	@echo "Description: $(PCIUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PCIUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(PCIUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PCIUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCIUTILS_IPK_DIR)/opt/sbin or $(PCIUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCIUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PCIUTILS_IPK_DIR)/opt/etc/pciutils/...
# Documentation files should be installed in $(PCIUTILS_IPK_DIR)/opt/doc/pciutils/...
# Daemon startup scripts should be installed in $(PCIUTILS_IPK_DIR)/opt/etc/init.d/S??pciutils
#
# You may need to patch your application to make it use these locations.
#
$(PCIUTILS_IPK): $(PCIUTILS_BUILD_DIR)/.built
	rm -rf $(PCIUTILS_IPK_DIR) $(BUILD_DIR)/pciutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCIUTILS_BUILD_DIR) install \
		DESTDIR=$(PCIUTILS_IPK_DIR) \
		PREFIX=/opt \
		STRIP="" \
	;
	$(STRIP_COMMAND) $(PCIUTILS_IPK_DIR)/opt/sbin/lspci $(PCIUTILS_IPK_DIR)/opt/sbin/setpci
#	install -d $(PCIUTILS_IPK_DIR)/opt/etc/
#	install -m 644 $(PCIUTILS_SOURCE_DIR)/pciutils.conf $(PCIUTILS_IPK_DIR)/opt/etc/pciutils.conf
#	install -d $(PCIUTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PCIUTILS_SOURCE_DIR)/rc.pciutils $(PCIUTILS_IPK_DIR)/opt/etc/init.d/SXXpciutils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PCIUTILS_IPK_DIR)/opt/etc/init.d/SXXpciutils
	$(MAKE) $(PCIUTILS_IPK_DIR)/CONTROL/control
#	install -m 755 $(PCIUTILS_SOURCE_DIR)/postinst $(PCIUTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PCIUTILS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PCIUTILS_SOURCE_DIR)/prerm $(PCIUTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PCIUTILS_IPK_DIR)/CONTROL/prerm
	echo $(PCIUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PCIUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCIUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pciutils-ipk: $(PCIUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pciutils-clean:
	rm -f $(PCIUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(PCIUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pciutils-dirclean:
	rm -rf $(BUILD_DIR)/$(PCIUTILS_DIR) $(PCIUTILS_BUILD_DIR) $(PCIUTILS_IPK_DIR) $(PCIUTILS_IPK)
#
#
# Some sanity check for the package.
#
pciutils-check: $(PCIUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PCIUTILS_IPK)
