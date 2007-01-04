###########################################################
#
# smartmontools
#
###########################################################

SMARTMONTOOLS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/smartmontools
SMARTMONTOOLS_VERSION=5.37
SMARTMONTOOLS_SOURCE=smartmontools-$(SMARTMONTOOLS_VERSION).tar.gz
SMARTMONTOOLS_DIR=smartmontools-$(SMARTMONTOOLS_VERSION)
SMARTMONTOOLS_UNZIP=zcat
SMARTMONTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SMARTMONTOOLS_DESCRIPTION=Utility programs to control and monitor \
 (SMART) built into most modern ATA and SCSI hard disks.
SMARTMONTOOLS_SECTION=misc
SMARTMONTOOLS_PRIORITY=optional
SMARTMONTOOLS_DEPENDS=
SMARTMONTOOLS_SUGGESTS=
SMARTMONTOOLS_CONFLICTS=

#
# SMARTMONTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
SMARTMONTOOLS_IPK_VERSION=1

#
# SMARTMONTOOLS_CONFFILES should be a list of user-editable files
SMARTMONTOOLS_CONFFILES=/opt/etc/smartd.conf /opt/etc/init.d/S20smartmontools

#
# SMARTMONTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SMARTMONTOOLS_PATCHES=$(SMARTMONTOOLS_SOURCE_DIR)/configargs.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SMARTMONTOOLS_CPPFLAGS=
SMARTMONTOOLS_LDFLAGS=

#
# SMARTMONTOOLS_BUILD_DIR is the directory in which the build is done.
# SMARTMONTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SMARTMONTOOLS_IPK_DIR is the directory in which the ipk is built.
# SMARTMONTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SMARTMONTOOLS_BUILD_DIR=$(BUILD_DIR)/smartmontools
SMARTMONTOOLS_SOURCE_DIR=$(SOURCE_DIR)/smartmontools
SMARTMONTOOLS_IPK_DIR=$(BUILD_DIR)/smartmontools-$(SMARTMONTOOLS_VERSION)-ipk
SMARTMONTOOLS_IPK=$(BUILD_DIR)/smartmontools_$(SMARTMONTOOLS_VERSION)-$(SMARTMONTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SMARTMONTOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(SMARTMONTOOLS_SITE)/$(SMARTMONTOOLS_SOURCE)

.PHONY: smartmontools-source smartmontools-unpack smartmontools smartmontools-stage smartmontools-ipk smartmontools-clean smartmontools-dirclean smartmontools-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
smartmontools-source: $(DL_DIR)/$(SMARTMONTOOLS_SOURCE) $(SMARTMONTOOLS_PATCHES)

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
$(SMARTMONTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(SMARTMONTOOLS_SOURCE) $(SMARTMONTOOLS_PATCHES)
	rm -rf $(BUILD_DIR)/$(SMARTMONTOOLS_DIR) $(SMARTMONTOOLS_BUILD_DIR)
	$(SMARTMONTOOLS_UNZIP) $(DL_DIR)/$(SMARTMONTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SMARTMONTOOLS_PATCHES)" ; \
		then cat $(SMARTMONTOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SMARTMONTOOLS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SMARTMONTOOLS_DIR)" != "$(SMARTMONTOOLS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SMARTMONTOOLS_DIR) $(SMARTMONTOOLS_BUILD_DIR) ; \
	fi
	(cd $(SMARTMONTOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SMARTMONTOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SMARTMONTOOLS_LDFLAGS)" \
		libc_have_working_snprintf=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(SMARTMONTOOLS_BUILD_DIR)/.configured

smartmontools-unpack: $(SMARTMONTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SMARTMONTOOLS_BUILD_DIR)/.built: $(SMARTMONTOOLS_BUILD_DIR)/.configured
	rm -f $(SMARTMONTOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(SMARTMONTOOLS_BUILD_DIR)
	touch $(SMARTMONTOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
smartmontools: $(SMARTMONTOOLS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/smartmontools
#
$(SMARTMONTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(SMARTMONTOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: smartmontools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SMARTMONTOOLS_PRIORITY)" >>$@
	@echo "Section: $(SMARTMONTOOLS_SECTION)" >>$@
	@echo "Version: $(SMARTMONTOOLS_VERSION)-$(SMARTMONTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SMARTMONTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(SMARTMONTOOLS_SITE)/$(SMARTMONTOOLS_SOURCE)" >>$@
	@echo "Description: $(SMARTMONTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(SMARTMONTOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(SMARTMONTOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SMARTMONTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(SMARTMONTOOLS_IPK): $(SMARTMONTOOLS_BUILD_DIR)/.built
	rm -rf $(SMARTMONTOOLS_IPK_DIR) $(BUILD_DIR)/smartmontools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SMARTMONTOOLS_BUILD_DIR) DESTDIR=$(SMARTMONTOOLS_IPK_DIR) install-strip
	install -d $(SMARTMONTOOLS_IPK_DIR)/opt/etc/init.d
	rm -rf $(SMARTMONTOOLS_IPK_DIR)/opt/etc/rc.d
	rm -rf $(SMARTMONTOOLS_IPK_DIR)/opt/man
	rm -rf $(SMARTMONTOOLS_IPK_DIR)/opt/share
	install -m 755 $(SMARTMONTOOLS_SOURCE_DIR)/rc.smartmontools $(SMARTMONTOOLS_IPK_DIR)/opt/etc/init.d/S20smartmontools
	$(MAKE) $(SMARTMONTOOLS_IPK_DIR)/CONTROL/control
	install -m 755 $(SMARTMONTOOLS_SOURCE_DIR)/postinst $(SMARTMONTOOLS_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SMARTMONTOOLS_SOURCE_DIR)/prerm $(SMARTMONTOOLS_IPK_DIR)/CONTROL/prerm
	echo $(SMARTMONTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(SMARTMONTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SMARTMONTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
smartmontools-ipk: $(SMARTMONTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
smartmontools-clean:
	rm -f $(SMARTMONTOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(SMARTMONTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
smartmontools-dirclean:
	rm -rf $(BUILD_DIR)/$(SMARTMONTOOLS_DIR) $(SMARTMONTOOLS_BUILD_DIR) $(SMARTMONTOOLS_IPK_DIR) $(SMARTMONTOOLS_IPK)
#
#
# Some sanity check for the package.
#
smartmontools-check: $(SMARTMONTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SMARTMONTOOLS_IPK)
