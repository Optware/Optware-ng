###########################################################
#
# microcom
#
###########################################################
#
# MICROCOM_VERSION, MICROCOM_SITE and MICROCOM_SOURCE define
# the upstream location of the source code for the package.
# MICROCOM_DIR is the directory which is created when the source
# archive is unpacked.
# MICROCOM_UNZIP is the command used to unzip the source.
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
MICROCOM_SITE=http://sources.nslu2-linux.org/sources
MICROCOM_VERSION=102
MICROCOM_SOURCE=m$(MICROCOM_VERSION).tar.gz
MICROCOM_DIR=m$(MICROCOM_VERSION)
MICROCOM_UNZIP=zcat
MICROCOM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MICROCOM_DESCRIPTION=A minicom-like serial terminal emulator with scripting support.
MICROCOM_SECTION=misc
MICROCOM_PRIORITY=optional
MICROCOM_DEPENDS=
MICROCOM_SUGGESTS=
MICROCOM_CONFLICTS=

#
# MICROCOM_IPK_VERSION should be incremented when the ipk changes.
#
MICROCOM_IPK_VERSION=1

#
# MICROCOM_CONFFILES should be a list of user-editable files
#MICROCOM_CONFFILES=/opt/etc/microcom.conf /opt/etc/init.d/SXXmicrocom

#
# MICROCOM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MICROCOM_PATCHES=$(MICROCOM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MICROCOM_CPPFLAGS=
MICROCOM_LDFLAGS=

#
# MICROCOM_BUILD_DIR is the directory in which the build is done.
# MICROCOM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MICROCOM_IPK_DIR is the directory in which the ipk is built.
# MICROCOM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MICROCOM_BUILD_DIR=$(BUILD_DIR)/microcom
MICROCOM_SOURCE_DIR=$(SOURCE_DIR)/microcom
MICROCOM_IPK_DIR=$(BUILD_DIR)/microcom-$(MICROCOM_VERSION)-ipk
MICROCOM_IPK=$(BUILD_DIR)/microcom_$(MICROCOM_VERSION)-$(MICROCOM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: microcom-source microcom-unpack microcom microcom-stage microcom-ipk microcom-clean microcom-dirclean microcom-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MICROCOM_SOURCE):
	$(WGET) -P $(DL_DIR) $(MICROCOM_SITE)/$(MICROCOM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
microcom-source: $(DL_DIR)/$(MICROCOM_SOURCE) $(MICROCOM_PATCHES)

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
$(MICROCOM_BUILD_DIR)/.configured: $(DL_DIR)/$(MICROCOM_SOURCE) $(MICROCOM_PATCHES) make/microcom.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MICROCOM_DIR) $(MICROCOM_BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(MICROCOM_DIR)
	$(MICROCOM_UNZIP) $(DL_DIR)/$(MICROCOM_SOURCE) | tar -C $(BUILD_DIR)/$(MICROCOM_DIR) -xvf -
	if test -n "$(MICROCOM_PATCHES)" ; \
		then cat $(MICROCOM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MICROCOM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MICROCOM_DIR)" != "$(MICROCOM_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MICROCOM_DIR) $(MICROCOM_BUILD_DIR) ; \
	fi
	sed -ie 's|	gcc |	$(TARGET_CC) |g' $(MICROCOM_BUILD_DIR)/Makefile
#	(cd $(MICROCOM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MICROCOM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MICROCOM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MICROCOM_BUILD_DIR)/libtool
	touch $@

microcom-unpack: $(MICROCOM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MICROCOM_BUILD_DIR)/.built: $(MICROCOM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MICROCOM_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
microcom: $(MICROCOM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MICROCOM_BUILD_DIR)/.staged: $(MICROCOM_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(MICROCOM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

microcom-stage: $(MICROCOM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/microcom
#
$(MICROCOM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: microcom" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MICROCOM_PRIORITY)" >>$@
	@echo "Section: $(MICROCOM_SECTION)" >>$@
	@echo "Version: $(MICROCOM_VERSION)-$(MICROCOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MICROCOM_MAINTAINER)" >>$@
	@echo "Source: $(MICROCOM_SITE)/$(MICROCOM_SOURCE)" >>$@
	@echo "Description: $(MICROCOM_DESCRIPTION)" >>$@
	@echo "Depends: $(MICROCOM_DEPENDS)" >>$@
	@echo "Suggests: $(MICROCOM_SUGGESTS)" >>$@
	@echo "Conflicts: $(MICROCOM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MICROCOM_IPK_DIR)/opt/sbin or $(MICROCOM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MICROCOM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MICROCOM_IPK_DIR)/opt/etc/microcom/...
# Documentation files should be installed in $(MICROCOM_IPK_DIR)/opt/doc/microcom/...
# Daemon startup scripts should be installed in $(MICROCOM_IPK_DIR)/opt/etc/init.d/S??microcom
#
# You may need to patch your application to make it use these locations.
#
$(MICROCOM_IPK): $(MICROCOM_BUILD_DIR)/.built
	rm -rf $(MICROCOM_IPK_DIR) $(BUILD_DIR)/microcom_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(MICROCOM_BUILD_DIR) DESTDIR=$(MICROCOM_IPK_DIR) install-strip
	install -d $(MICROCOM_IPK_DIR)/opt/bin
	install $(MICROCOM_BUILD_DIR)/microcom $(MICROCOM_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(MICROCOM_IPK_DIR)/opt/bin/microcom
#	install -d $(MICROCOM_IPK_DIR)/opt/etc/
#	install -m 644 $(MICROCOM_SOURCE_DIR)/microcom.conf $(MICROCOM_IPK_DIR)/opt/etc/microcom.conf
	$(MAKE) $(MICROCOM_IPK_DIR)/CONTROL/control
#	echo $(MICROCOM_CONFFILES) | sed -e 's/ /\n/g' > $(MICROCOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MICROCOM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
microcom-ipk: $(MICROCOM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
microcom-clean:
	rm -f $(MICROCOM_BUILD_DIR)/.built
	-$(MAKE) -C $(MICROCOM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
microcom-dirclean:
	rm -rf $(BUILD_DIR)/$(MICROCOM_DIR) $(MICROCOM_BUILD_DIR) $(MICROCOM_IPK_DIR) $(MICROCOM_IPK)
#
#
# Some sanity check for the package.
#
microcom-check: $(MICROCOM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MICROCOM_IPK)
