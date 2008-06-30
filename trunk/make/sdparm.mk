###########################################################
#
# sdparm
#
###########################################################
#
# SDPARM_VERSION, SDPARM_SITE and SDPARM_SOURCE define
# the upstream location of the source code for the package.
# SDPARM_DIR is the directory which is created when the source
# archive is unpacked.
# SDPARM_UNZIP is the command used to unzip the source.
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
SDPARM_SITE=http://sg.torque.net/sg/p
SDPARM_VERSION=1.03
SDPARM_SOURCE=sdparm-$(SDPARM_VERSION).tgz
SDPARM_DIR=sdparm-$(SDPARM_VERSION)
SDPARM_UNZIP=zcat
SDPARM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SDPARM_DESCRIPTION=Utility for listing and potentially changing SCSI disk parameters
SDPARM_SECTION=admin
SDPARM_PRIORITY=optional
SDPARM_DEPENDS=
SDPARM_SUGGESTS=
SDPARM_CONFLICTS=

#
# SDPARM_IPK_VERSION should be incremented when the ipk changes.
#
SDPARM_IPK_VERSION=1

#
# SDPARM_CONFFILES should be a list of user-editable files
#SDPARM_CONFFILES=/opt/etc/sdparm.conf /opt/etc/init.d/SXXsdparm

#
# SDPARM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SDPARM_PATCHES=$(SDPARM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SDPARM_CPPFLAGS=
SDPARM_LDFLAGS=

#
# SDPARM_BUILD_DIR is the directory in which the build is done.
# SDPARM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SDPARM_IPK_DIR is the directory in which the ipk is built.
# SDPARM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SDPARM_BUILD_DIR=$(BUILD_DIR)/sdparm
SDPARM_SOURCE_DIR=$(SOURCE_DIR)/sdparm
SDPARM_IPK_DIR=$(BUILD_DIR)/sdparm-$(SDPARM_VERSION)-ipk
SDPARM_IPK=$(BUILD_DIR)/sdparm_$(SDPARM_VERSION)-$(SDPARM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SDPARM_SOURCE):
	$(WGET) -P $(@D) $(SDPARM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sdparm-source: $(DL_DIR)/$(SDPARM_SOURCE) $(SDPARM_PATCHES)

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
$(SDPARM_BUILD_DIR)/.configured: $(DL_DIR)/$(SDPARM_SOURCE) $(SDPARM_PATCHES) make/sdparm.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SDPARM_DIR) $(SDPARM_BUILD_DIR)
	$(SDPARM_UNZIP) $(DL_DIR)/$(SDPARM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SDPARM_PATCHES)" ; \
		then cat $(SDPARM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SDPARM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SDPARM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SDPARM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SDPARM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SDPARM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SDPARM_BUILD_DIR)/libtool
	touch $@

sdparm-unpack: $(SDPARM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SDPARM_BUILD_DIR)/.built: $(SDPARM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sdparm: $(SDPARM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SDPARM_BUILD_DIR)/.staged: $(SDPARM_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(SDPARM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#sdparm-stage: $(SDPARM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sdparm
#
$(SDPARM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sdparm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SDPARM_PRIORITY)" >>$@
	@echo "Section: $(SDPARM_SECTION)" >>$@
	@echo "Version: $(SDPARM_VERSION)-$(SDPARM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SDPARM_MAINTAINER)" >>$@
	@echo "Source: $(SDPARM_SITE)/$(SDPARM_SOURCE)" >>$@
	@echo "Description: $(SDPARM_DESCRIPTION)" >>$@
	@echo "Depends: $(SDPARM_DEPENDS)" >>$@
	@echo "Suggests: $(SDPARM_SUGGESTS)" >>$@
	@echo "Conflicts: $(SDPARM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SDPARM_IPK_DIR)/opt/sbin or $(SDPARM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SDPARM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SDPARM_IPK_DIR)/opt/etc/sdparm/...
# Documentation files should be installed in $(SDPARM_IPK_DIR)/opt/doc/sdparm/...
# Daemon startup scripts should be installed in $(SDPARM_IPK_DIR)/opt/etc/init.d/S??sdparm
#
# You may need to patch your application to make it use these locations.
#
$(SDPARM_IPK): $(SDPARM_BUILD_DIR)/.built
	rm -rf $(SDPARM_IPK_DIR) $(BUILD_DIR)/sdparm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SDPARM_BUILD_DIR) DESTDIR=$(SDPARM_IPK_DIR) install-strip
#	install -d $(SDPARM_IPK_DIR)/opt/etc/
#	install -m 644 $(SDPARM_SOURCE_DIR)/sdparm.conf $(SDPARM_IPK_DIR)/opt/etc/sdparm.conf
#	install -d $(SDPARM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SDPARM_SOURCE_DIR)/rc.sdparm $(SDPARM_IPK_DIR)/opt/etc/init.d/SXXsdparm
	$(MAKE) $(SDPARM_IPK_DIR)/CONTROL/control
#	install -m 755 $(SDPARM_SOURCE_DIR)/postinst $(SDPARM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SDPARM_SOURCE_DIR)/prerm $(SDPARM_IPK_DIR)/CONTROL/prerm
	echo $(SDPARM_CONFFILES) | sed -e 's/ /\n/g' > $(SDPARM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SDPARM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sdparm-ipk: $(SDPARM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sdparm-clean:
	rm -f $(SDPARM_BUILD_DIR)/.built
	-$(MAKE) -C $(SDPARM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sdparm-dirclean:
	rm -rf $(BUILD_DIR)/$(SDPARM_DIR) $(SDPARM_BUILD_DIR) $(SDPARM_IPK_DIR) $(SDPARM_IPK)

#
# Some sanity check for the package.
#
sdparm-check: $(SDPARM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SDPARM_IPK)
