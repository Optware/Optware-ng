###########################################################
#
# sg3-utils
#
###########################################################
#
# SG3-UTILS_VERSION, SG3-UTILS_SITE and SG3-UTILS_SOURCE define
# the upstream location of the source code for the package.
# SG3-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# SG3-UTILS_UNZIP is the command used to unzip the source.
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
SG3-UTILS_SITE=http://sg.torque.net/sg/p
SG3-UTILS_VERSION=1.25
SG3-UTILS_SOURCE=sg3_utils-$(SG3-UTILS_VERSION).tgz
SG3-UTILS_DIR=sg3_utils-$(SG3-UTILS_VERSION)
SG3-UTILS_UNZIP=zcat
SG3-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SG3-UTILS_DESCRIPTION=Utilities that send SCSI commands to devices.
SG3-UTILS_SECTION=sysadmin
SG3-UTILS_PRIORITY=optional
SG3-UTILS_DEPENDS=
SG3-UTILS_SUGGESTS=
SG3-UTILS_CONFLICTS=

#
# SG3-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
SG3-UTILS_IPK_VERSION=1

#
# SG3-UTILS_CONFFILES should be a list of user-editable files
#SG3-UTILS_CONFFILES=/opt/etc/sg3-utils.conf /opt/etc/init.d/SXXsg3-utils

#
# SG3-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SG3-UTILS_PATCHES=$(SG3-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SG3-UTILS_CPPFLAGS=
SG3-UTILS_LDFLAGS=

#
# SG3-UTILS_BUILD_DIR is the directory in which the build is done.
# SG3-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SG3-UTILS_IPK_DIR is the directory in which the ipk is built.
# SG3-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SG3-UTILS_BUILD_DIR=$(BUILD_DIR)/sg3-utils
SG3-UTILS_SOURCE_DIR=$(SOURCE_DIR)/sg3-utils
SG3-UTILS_IPK_DIR=$(BUILD_DIR)/sg3-utils-$(SG3-UTILS_VERSION)-ipk
SG3-UTILS_IPK=$(BUILD_DIR)/sg3-utils_$(SG3-UTILS_VERSION)-$(SG3-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sg3-utils-source sg3-utils-unpack sg3-utils sg3-utils-stage sg3-utils-ipk sg3-utils-clean sg3-utils-dirclean sg3-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SG3-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(SG3-UTILS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sg3-utils-source: $(DL_DIR)/$(SG3-UTILS_SOURCE) $(SG3-UTILS_PATCHES)

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
$(SG3-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(SG3-UTILS_SOURCE) $(SG3-UTILS_PATCHES) make/sg3-utils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SG3-UTILS_DIR) $(@D)
	$(SG3-UTILS_UNZIP) $(DL_DIR)/$(SG3-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SG3-UTILS_PATCHES)" ; \
		then cat $(SG3-UTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SG3-UTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SG3-UTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SG3-UTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SG3-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SG3-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sg3-utils-unpack: $(SG3-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SG3-UTILS_BUILD_DIR)/.built: $(SG3-UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sg3-utils: $(SG3-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SG3-UTILS_BUILD_DIR)/.staged: $(SG3-UTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

sg3-utils-stage: $(SG3-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sg3-utils
#
$(SG3-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sg3-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SG3-UTILS_PRIORITY)" >>$@
	@echo "Section: $(SG3-UTILS_SECTION)" >>$@
	@echo "Version: $(SG3-UTILS_VERSION)-$(SG3-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SG3-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(SG3-UTILS_SITE)/$(SG3-UTILS_SOURCE)" >>$@
	@echo "Description: $(SG3-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(SG3-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(SG3-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SG3-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SG3-UTILS_IPK_DIR)/opt/sbin or $(SG3-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SG3-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SG3-UTILS_IPK_DIR)/opt/etc/sg3-utils/...
# Documentation files should be installed in $(SG3-UTILS_IPK_DIR)/opt/doc/sg3-utils/...
# Daemon startup scripts should be installed in $(SG3-UTILS_IPK_DIR)/opt/etc/init.d/S??sg3-utils
#
# You may need to patch your application to make it use these locations.
#
$(SG3-UTILS_IPK): $(SG3-UTILS_BUILD_DIR)/.built
	rm -rf $(SG3-UTILS_IPK_DIR) $(BUILD_DIR)/sg3-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SG3-UTILS_BUILD_DIR) DESTDIR=$(SG3-UTILS_IPK_DIR) install-strip
#	install -d $(SG3-UTILS_IPK_DIR)/opt/etc/
#	install -m 644 $(SG3-UTILS_SOURCE_DIR)/sg3-utils.conf $(SG3-UTILS_IPK_DIR)/opt/etc/sg3-utils.conf
#	install -d $(SG3-UTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SG3-UTILS_SOURCE_DIR)/rc.sg3-utils $(SG3-UTILS_IPK_DIR)/opt/etc/init.d/SXXsg3-utils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SG3-UTILS_IPK_DIR)/opt/etc/init.d/SXXsg3-utils
	$(MAKE) $(SG3-UTILS_IPK_DIR)/CONTROL/control
#	install -m 755 $(SG3-UTILS_SOURCE_DIR)/postinst $(SG3-UTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SG3-UTILS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SG3-UTILS_SOURCE_DIR)/prerm $(SG3-UTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SG3-UTILS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SG3-UTILS_IPK_DIR)/CONTROL/postinst $(SG3-UTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SG3-UTILS_CONFFILES) | sed -e 's/ /\n/g' > $(SG3-UTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SG3-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sg3-utils-ipk: $(SG3-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sg3-utils-clean:
	rm -f $(SG3-UTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(SG3-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sg3-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(SG3-UTILS_DIR) $(SG3-UTILS_BUILD_DIR) $(SG3-UTILS_IPK_DIR) $(SG3-UTILS_IPK)
#
#
# Some sanity check for the package.
#
sg3-utils-check: $(SG3-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SG3-UTILS_IPK)
