###########################################################
#
# sed
#
###########################################################

#
# SED_VERSION, SED_SITE and SED_SOURCE define
# the upstream location of the source code for the package.
# SED_DIR is the directory which is created when the source
# archive is unpacked.
# SED_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SED_SITE=http://ftp.gnu.org/gnu/sed
SED_VERSION=4.1.5
SED_SOURCE=sed-$(SED_VERSION).tar.gz
SED_DIR=sed-$(SED_VERSION)
SED_UNZIP=zcat
SED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SED_DESCRIPTION=Stream editor.
SED_SECTION=util
SED_PRIORITY=optional
SED_DEPENDS=
SED_SUGGESTS=
SED_CONFLICTS=

#
# SED_IPK_VERSION should be incremented when the ipk changes.
#
SED_IPK_VERSION=2

#
# SED_CONFFILES should be a list of user-editable files
#SED_CONFFILES=/opt/etc/sed.conf /opt/etc/init.d/SXXsed

#
# SED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SED_PATCHES=$(SED_SOURCE_DIR)/wchar_t.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SED_CPPFLAGS=
SED_LDFLAGS=

#
# SED_BUILD_DIR is the directory in which the build is done.
# SED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SED_IPK_DIR is the directory in which the ipk is built.
# SED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SED_BUILD_DIR=$(BUILD_DIR)/sed
SED_SOURCE_DIR=$(SOURCE_DIR)/sed
SED_IPK_DIR=$(BUILD_DIR)/sed-$(SED_VERSION)-ipk
SED_IPK=$(BUILD_DIR)/sed_$(SED_VERSION)-$(SED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sed-source sed-unpack sed sed-stage sed-ipk sed-clean sed-dirclean sed-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SED_SOURCE):
	$(WGET) -P $(DL_DIR) $(SED_SITE)/$(SED_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sed-source: $(DL_DIR)/$(SED_SOURCE) $(SED_PATCHES)

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
$(SED_BUILD_DIR)/.configured: $(DL_DIR)/$(SED_SOURCE) $(SED_PATCHES) make/sed.mk
	rm -rf $(BUILD_DIR)/$(SED_DIR) $(SED_BUILD_DIR)
	$(SED_UNZIP) $(DL_DIR)/$(SED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SED_PATCHES) | patch -d $(BUILD_DIR)/$(SED_DIR) -p1
	mv $(BUILD_DIR)/$(SED_DIR) $(SED_BUILD_DIR)
	(cd $(SED_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SED_LDFLAGS)" \
		ac_cv_func_mmap_fixed_mapped=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

sed-unpack: $(SED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SED_BUILD_DIR)/.built: $(SED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SED_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
sed: $(SED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SED_BUILD_DIR)/.staged: $(SED_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SED_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

sed-stage: $(SED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sed
#
$(SED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sed" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SED_PRIORITY)" >>$@
	@echo "Section: $(SED_SECTION)" >>$@
	@echo "Version: $(SED_VERSION)-$(SED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SED_MAINTAINER)" >>$@
	@echo "Source: $(SED_SITE)/$(SED_SOURCE)" >>$@
	@echo "Description: $(SED_DESCRIPTION)" >>$@
	@echo "Depends: $(SED_DEPENDS)" >>$@
	@echo "Suggests: $(SED_SUGGESTS)" >>$@
	@echo "Conflicts: $(SED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SED_IPK_DIR)/opt/sbin or $(SED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SED_IPK_DIR)/opt/etc/sed/...
# Documentation files should be installed in $(SED_IPK_DIR)/opt/doc/sed/...
# Daemon startup scripts should be installed in $(SED_IPK_DIR)/opt/etc/init.d/S??sed
#
# You may need to patch your application to make it use these locations.
#
$(SED_IPK): $(SED_BUILD_DIR)/.built
	rm -rf $(SED_IPK_DIR) $(BUILD_DIR)/sed_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SED_BUILD_DIR) DESTDIR=$(SED_IPK_DIR) install-strip
	mv $(SED_IPK_DIR)/opt/bin/sed $(SED_IPK_DIR)/opt/bin/gnu-sed
	$(MAKE) $(SED_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/sed sed /opt/bin/gnu-sed 80"; \
	) > $(SED_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove sed /opt/bin/gnu-sed"; \
	) > $(SED_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sed-ipk: $(SED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sed-clean:
	-$(MAKE) -C $(SED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sed-dirclean:
	rm -rf $(BUILD_DIR)/$(SED_DIR) $(SED_BUILD_DIR) $(SED_IPK_DIR) $(SED_IPK)

#
# Some sanity check for the package.
#
sed-check: $(SED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SED_IPK)
