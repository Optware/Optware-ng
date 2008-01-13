###########################################################
#
# lm-sensors
#
###########################################################
#
# LM_SENSORS_VERSION, LM_SENSORS_SITE and LM_SENSORS_SOURCE define
# the upstream location of the source code for the package.
# LM_SENSORS_DIR is the directory which is created when the source
# archive is unpacked.
# LM_SENSORS_UNZIP is the command used to unzip the source.
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
LM_SENSORS_SITE=http://dl.lm-sensors.org/lm-sensors/releases
LM_SENSORS_VERSION=3.0.0
LM_SENSORS_SOURCE=lm_sensors-$(LM_SENSORS_VERSION).tar.bz2
LM_SENSORS_DIR=lm_sensors-$(LM_SENSORS_VERSION)
LM_SENSORS_UNZIP=bzcat
LM_SENSORS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LM_SENSORS_DESCRIPTION=Linux hardware monitoring.
LM_SENSORS_SECTION=sysadmin
LM_SENSORS_PRIORITY=optional
LM_SENSORS_DEPENDS=sysfsutils
LM_SENSORS_SUGGESTS=
LM_SENSORS_CONFLICTS=

#
# LM_SENSORS_IPK_VERSION should be incremented when the ipk changes.
#
LM_SENSORS_IPK_VERSION=1

#
# LM_SENSORS_CONFFILES should be a list of user-editable files
#LM_SENSORS_CONFFILES=/opt/etc/lm-sensors.conf /opt/etc/init.d/SXXlm-sensors

#
# LM_SENSORS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LM_SENSORS_PATCHES=$(LM_SENSORS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LM_SENSORS_CPPFLAGS=
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
LM_SENSORS_CPPFLAGS += -DNAME_MAX=255
endif
LM_SENSORS_LDFLAGS=

#
# LM_SENSORS_BUILD_DIR is the directory in which the build is done.
# LM_SENSORS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LM_SENSORS_IPK_DIR is the directory in which the ipk is built.
# LM_SENSORS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LM_SENSORS_BUILD_DIR=$(BUILD_DIR)/lm-sensors
LM_SENSORS_SOURCE_DIR=$(SOURCE_DIR)/lm-sensors
LM_SENSORS_IPK_DIR=$(BUILD_DIR)/lm-sensors-$(LM_SENSORS_VERSION)-ipk
LM_SENSORS_IPK=$(BUILD_DIR)/lm-sensors_$(LM_SENSORS_VERSION)-$(LM_SENSORS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lm-sensors-source lm-sensors-unpack lm-sensors lm-sensors-stage lm-sensors-ipk lm-sensors-clean lm-sensors-dirclean lm-sensors-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LM_SENSORS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LM_SENSORS_SITE)/$(LM_SENSORS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LM_SENSORS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lm-sensors-source: $(DL_DIR)/$(LM_SENSORS_SOURCE) $(LM_SENSORS_PATCHES)

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
$(LM_SENSORS_BUILD_DIR)/.configured: $(DL_DIR)/$(LM_SENSORS_SOURCE) $(LM_SENSORS_PATCHES) make/lm-sensors.mk
	$(MAKE) sysfsutils-stage
	rm -rf $(BUILD_DIR)/$(LM_SENSORS_DIR) $(@D)
	$(LM_SENSORS_UNZIP) $(DL_DIR)/$(LM_SENSORS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LM_SENSORS_PATCHES)" ; \
		then cat $(LM_SENSORS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LM_SENSORS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LM_SENSORS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LM_SENSORS_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LM_SENSORS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LM_SENSORS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e '/-lsysfs/s|$$| $$(LDFLAGS)|' $(@D)/lib/Module.mk
	touch $@

lm-sensors-unpack: $(LM_SENSORS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LM_SENSORS_BUILD_DIR)/.built: $(LM_SENSORS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) all \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LM_SENSORS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LM_SENSORS_LDFLAGS)" \
		EXLDFLAGS="$(STAGING_LDFLAGS) $(LM_SENSORS_LDFLAGS)" \
		PREFIX=/opt \
		ETCDIR=/opt/etc \
		;
	touch $@

#
# This is the build convenience target.
#
lm-sensors: $(LM_SENSORS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LM_SENSORS_BUILD_DIR)/.staged: $(LM_SENSORS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

lm-sensors-stage: $(LM_SENSORS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lm-sensors
#
$(LM_SENSORS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lm-sensors" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LM_SENSORS_PRIORITY)" >>$@
	@echo "Section: $(LM_SENSORS_SECTION)" >>$@
	@echo "Version: $(LM_SENSORS_VERSION)-$(LM_SENSORS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LM_SENSORS_MAINTAINER)" >>$@
	@echo "Source: $(LM_SENSORS_SITE)/$(LM_SENSORS_SOURCE)" >>$@
	@echo "Description: $(LM_SENSORS_DESCRIPTION)" >>$@
	@echo "Depends: $(LM_SENSORS_DEPENDS)" >>$@
	@echo "Suggests: $(LM_SENSORS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LM_SENSORS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LM_SENSORS_IPK_DIR)/opt/sbin or $(LM_SENSORS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LM_SENSORS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LM_SENSORS_IPK_DIR)/opt/etc/lm-sensors/...
# Documentation files should be installed in $(LM_SENSORS_IPK_DIR)/opt/doc/lm-sensors/...
# Daemon startup scripts should be installed in $(LM_SENSORS_IPK_DIR)/opt/etc/init.d/S??lm-sensors
#
# You may need to patch your application to make it use these locations.
#
$(LM_SENSORS_IPK): $(LM_SENSORS_BUILD_DIR)/.built
	rm -rf $(LM_SENSORS_IPK_DIR) $(BUILD_DIR)/lm-sensors_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LM_SENSORS_BUILD_DIR) install \
		DESTDIR=$(LM_SENSORS_IPK_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LM_SENSORS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LM_SENSORS_LDFLAGS)" \
		EXLDFLAGS="$(STAGING_LDFLAGS) $(LM_SENSORS_LDFLAGS)" \
		PREFIX=/opt \
		ETCDIR=/opt/etc \
		;
	rm -f $(LM_SENSORS_IPK_DIR)/opt/lib/libsensors.a
	$(STRIP_COMMAND) \
		$(LM_SENSORS_IPK_DIR)/opt/bin/sensors \
		$(LM_SENSORS_IPK_DIR)/opt/sbin/isa* \
		$(LM_SENSORS_IPK_DIR)/opt/lib/libsensors.so
	$(MAKE) $(LM_SENSORS_IPK_DIR)/CONTROL/control
	echo $(LM_SENSORS_CONFFILES) | sed -e 's/ /\n/g' > $(LM_SENSORS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LM_SENSORS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lm-sensors-ipk: $(LM_SENSORS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lm-sensors-clean:
	rm -f $(LM_SENSORS_BUILD_DIR)/.built
	-$(MAKE) -C $(LM_SENSORS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lm-sensors-dirclean:
	rm -rf $(BUILD_DIR)/$(LM_SENSORS_DIR) $(LM_SENSORS_BUILD_DIR) $(LM_SENSORS_IPK_DIR) $(LM_SENSORS_IPK)
#
#
# Some sanity check for the package.
#
lm-sensors-check: $(LM_SENSORS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LM_SENSORS_IPK)
