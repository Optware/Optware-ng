###########################################################
#
# scsi-idle
#
###########################################################
#
# SCSI_IDLE_VERSION, SCSI_IDLE_SITE and SCSI_IDLE_SOURCE define
# the upstream location of the source code for the package.
# SCSI_IDLE_DIR is the directory which is created when the source
# archive is unpacked.
# SCSI_IDLE_UNZIP is the command used to unzip the source.
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
SCSI_IDLE_SITE=http://lost-habit.com
SCSI_IDLE_VERSION=2.4.23
SCSI_IDLE_SOURCE=scsi-idle-$(SCSI_IDLE_VERSION).tar.gz
SCSI_IDLE_DIR=scsi-idle-$(SCSI_IDLE_VERSION)
SCSI_IDLE_UNZIP=zcat
SCSI_IDLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SCSI_IDLE_DESCRIPTION=SCSI disks and a daemon that spins down drives when idle - kernel patch needed for spin-up
SCSI_IDLE_SECTION=kernel
SCSI_IDLE_PRIORITY=optional
SCSI_IDLE_DEPENDS=
SCSI_IDLE_SUGGESTS=
SCSI_IDLE_CONFLICTS=

#
# SCSI_IDLE_IPK_VERSION should be incremented when the ipk changes.
#
SCSI_IDLE_IPK_VERSION=1

#
# SCSI_IDLE_CONFFILES should be a list of user-editable files
SCSI_IDLE_CONFFILES=/opt/etc/scsi-idle.conf /opt/etc/init.d/SXXscsi-idle

#
# SCSI_IDLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# SCSI_IDLE_PATCHES=$(SCSI_IDLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCSI_IDLE_CPPFLAGS=
SCSI_IDLE_LDFLAGS=

#
# SCSI_IDLE_BUILD_DIR is the directory in which the build is done.
# SCSI_IDLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCSI_IDLE_IPK_DIR is the directory in which the ipk is built.
# SCSI_IDLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCSI_IDLE_BUILD_DIR=$(BUILD_DIR)/scsi-idle
SCSI_IDLE_SOURCE_DIR=$(SOURCE_DIR)/scsi-idle
SCSI_IDLE_IPK_DIR=$(BUILD_DIR)/scsi-idle-$(SCSI_IDLE_VERSION)-ipk
SCSI_IDLE_IPK=$(BUILD_DIR)/scsi-idle_$(SCSI_IDLE_VERSION)-$(SCSI_IDLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: scsi-idle-source scsi-idle-unpack scsi-idle scsi-idle-stage scsi-idle-ipk scsi-idle-clean scsi-idle-dirclean scsi-idle-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCSI_IDLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(SCSI_IDLE_SITE)/$(SCSI_IDLE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SCSI_IDLE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
scsi-idle-source: $(DL_DIR)/$(SCSI_IDLE_SOURCE) $(SCSI_IDLE_PATCHES)

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
$(SCSI_IDLE_BUILD_DIR)/.configured: $(DL_DIR)/$(SCSI_IDLE_SOURCE) $(SCSI_IDLE_PATCHES) make/scsi-idle.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SCSI_IDLE_DIR) $(SCSI_IDLE_BUILD_DIR)
	$(SCSI_IDLE_UNZIP) $(DL_DIR)/$(SCSI_IDLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SCSI_IDLE_PATCHES)" ; \
		then cat $(SCSI_IDLE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SCSI_IDLE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SCSI_IDLE_DIR)" != "$(SCSI_IDLE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SCSI_IDLE_DIR) $(SCSI_IDLE_BUILD_DIR) ; \
	fi
	(cd $(SCSI_IDLE_BUILD_DIR); \
		sed -i -e 's|/usr/local|$$(DESTDIR)/opt|;/CFLAGS/d' Makefile \
	)

#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(SCSI_IDLE_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(SCSI_IDLE_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
#	$(PATCH_LIBTOOL) $(SCSI_IDLE_BUILD_DIR)/libtool
	touch $@

scsi-idle-unpack: $(SCSI_IDLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SCSI_IDLE_BUILD_DIR)/.built: $(SCSI_IDLE_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(SCSI_IDLE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
scsi-idle: $(SCSI_IDLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SCSI_IDLE_BUILD_DIR)/.staged: $(SCSI_IDLE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SCSI_IDLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

scsi-idle-stage: $(SCSI_IDLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/scsi-idle
#
$(SCSI_IDLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: scsi-idle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SCSI_IDLE_PRIORITY)" >>$@
	@echo "Section: $(SCSI_IDLE_SECTION)" >>$@
	@echo "Version: $(SCSI_IDLE_VERSION)-$(SCSI_IDLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SCSI_IDLE_MAINTAINER)" >>$@
	@echo "Source: $(SCSI_IDLE_SITE)/$(SCSI_IDLE_SOURCE)" >>$@
	@echo "Description: $(SCSI_IDLE_DESCRIPTION)" >>$@
	@echo "Depends: $(SCSI_IDLE_DEPENDS)" >>$@
	@echo "Suggests: $(SCSI_IDLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(SCSI_IDLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SCSI_IDLE_IPK_DIR)/opt/sbin or $(SCSI_IDLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCSI_IDLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCSI_IDLE_IPK_DIR)/opt/etc/scsi-idle/...
# Documentation files should be installed in $(SCSI_IDLE_IPK_DIR)/opt/doc/scsi-idle/...
# Daemon startup scripts should be installed in $(SCSI_IDLE_IPK_DIR)/opt/etc/init.d/S??scsi-idle
#
# You may need to patch your application to make it use these locations.
#
$(SCSI_IDLE_IPK): $(SCSI_IDLE_BUILD_DIR)/.built
	rm -rf $(SCSI_IDLE_IPK_DIR) $(BUILD_DIR)/scsi-idle_*_$(TARGET_ARCH).ipk
	install -d $(SCSI_IDLE_IPK_DIR)/opt/sbin
	$(MAKE) -C $(SCSI_IDLE_BUILD_DIR) DESTDIR=$(SCSI_IDLE_IPK_DIR) install
	$(STRIP_COMMAND) $(SCSI_IDLE_IPK_DIR)/opt/sbin/scsi-idle
	$(STRIP_COMMAND) $(SCSI_IDLE_IPK_DIR)/opt/sbin/scsi-start
	$(STRIP_COMMAND) $(SCSI_IDLE_IPK_DIR)/opt/sbin/scsi-stop
	install -d $(SCSI_IDLE_IPK_DIR)/opt/share/doc/
	install -m 644 $(SCSI_IDLE_BUILD_DIR)/scsi-idle.README $(SCSI_IDLE_IPK_DIR)/opt/share/doc/
#	install -m 644 $(SCSI_IDLE_SOURCE_DIR)/scsi-idle.conf $(SCSI_IDLE_IPK_DIR)/opt/etc/scsi-idle.conf
#	install -d $(SCSI_IDLE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SCSI_IDLE_SOURCE_DIR)/rc.scsi-idle $(SCSI_IDLE_IPK_DIR)/opt/etc/init.d/SXXscsi-idle
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCSI_IDLE_IPK_DIR)/opt/etc/init.d/SXXscsi-idle
	$(MAKE) $(SCSI_IDLE_IPK_DIR)/CONTROL/control
#	install -m 755 $(SCSI_IDLE_SOURCE_DIR)/postinst $(SCSI_IDLE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCSI_IDLE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SCSI_IDLE_SOURCE_DIR)/prerm $(SCSI_IDLE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCSI_IDLE_IPK_DIR)/CONTROL/prerm
#	echo $(SCSI_IDLE_CONFFILES) | sed -e 's/ /\n/g' > $(SCSI_IDLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCSI_IDLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
scsi-idle-ipk: $(SCSI_IDLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
scsi-idle-clean:
	rm -f $(SCSI_IDLE_BUILD_DIR)/.built
	-$(MAKE) -C $(SCSI_IDLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
scsi-idle-dirclean:
	rm -rf $(BUILD_DIR)/$(SCSI_IDLE_DIR) $(SCSI_IDLE_BUILD_DIR) $(SCSI_IDLE_IPK_DIR) $(SCSI_IDLE_IPK)
#
#
# Some sanity check for the package.
#
scsi-idle-check: $(SCSI_IDLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SCSI_IDLE_IPK)
