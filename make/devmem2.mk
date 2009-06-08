###########################################################
#
# devmem2
#
###########################################################
#
# DEVMEM2_VERSION, DEVMEM2_SITE and DEVMEM2_SOURCE define
# the upstream location of the source code for the package.
# DEVMEM2_DIR is the directory which is created when the source
# archive is unpacked.
# DEVMEM2_UNZIP is the command used to unzip the source.
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
DEVMEM2_SITE=http://www.lartmaker.nl/lartware/port
DEVMEM2_VERSION=1.0
DEVMEM2_SOURCE=devmem2.c
#DEVMEM2_SOURCE_MD5=e23f236e94be4c429aa1ceac0f01544b
#DEVMEM2_SOURCE_MD5=be12c0132a1ae118cbf5e79d98427c1d
DEVMEM2_DIR=devmem2-$(DEVMEM2_VERSION)
#DEVMEM2_UNZIP=zcat
DEVMEM2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEVMEM2_DESCRIPTION=Simple program to read/write from/to any location in memory
DEVMEM2_SECTION=devel
DEVMEM2_PRIORITY=optional
DEVMEM2_DEPENDS=
DEVMEM2_SUGGESTS=
DEVMEM2_CONFLICTS=

#
# DEVMEM2_IPK_VERSION should be incremented when the ipk changes.
#
DEVMEM2_IPK_VERSION=1

#
# DEVMEM2_CONFFILES should be a list of user-editable files
#DEVMEM2_CONFFILES=/opt/etc/devmem2.conf /opt/etc/init.d/SXXdevmem2

#
# DEVMEM2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DEVMEM2_PATCHES=$(DEVMEM2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEVMEM2_CPPFLAGS=
DEVMEM2_LDFLAGS=

#
# DEVMEM2_BUILD_DIR is the directory in which the build is done.
# DEVMEM2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DEVMEM2_IPK_DIR is the directory in which the ipk is built.
# DEVMEM2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEVMEM2_BUILD_DIR=$(BUILD_DIR)/devmem2
DEVMEM2_SOURCE_DIR=$(SOURCE_DIR)/devmem2
DEVMEM2_IPK_DIR=$(BUILD_DIR)/devmem2-$(DEVMEM2_VERSION)-ipk
DEVMEM2_IPK=$(BUILD_DIR)/devmem2_$(DEVMEM2_VERSION)-$(DEVMEM2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: devmem2-source devmem2-unpack devmem2 devmem2-stage devmem2-ipk devmem2-clean devmem2-dirclean devmem2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DEVMEM2_SOURCE):
	$(WGET) -P $(@D) $(DEVMEM2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
#	test `md5sum $@ | cut -f1 -d" "` = $(DEVMEM2_SOURCE_MD5)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
devmem2-source: $(DL_DIR)/$(DEVMEM2_SOURCE) $(DEVMEM2_PATCHES)

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
$(DEVMEM2_BUILD_DIR)/.configured: $(DL_DIR)/$(DEVMEM2_SOURCE) $(DEVMEM2_PATCHES) make/devmem2.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DEVMEM2_DIR) $(@D)
#	$(DEVMEM2_UNZIP) $(DL_DIR)/$(DEVMEM2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mkdir -p $(@D)
	cp -p $(<) $(@D)
	if test -n "$(DEVMEM2_PATCHES)" ; \
		then cat $(DEVMEM2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DEVMEM2_DIR) -p0 ; \
	fi
	touch $@

devmem2-unpack: $(DEVMEM2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEVMEM2_BUILD_DIR)/.built: $(DEVMEM2_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); \
	$(TARGET_CC) $(TARGET_CFLAGS) -o devmem2 devmem2.c
	touch $@

#
# This is the build convenience target.
#
devmem2: $(DEVMEM2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DEVMEM2_BUILD_DIR)/.staged: $(DEVMEM2_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#devmem2-stage: $(DEVMEM2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/devmem2
#
$(DEVMEM2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: devmem2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEVMEM2_PRIORITY)" >>$@
	@echo "Section: $(DEVMEM2_SECTION)" >>$@
	@echo "Version: $(DEVMEM2_VERSION)-$(DEVMEM2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEVMEM2_MAINTAINER)" >>$@
	@echo "Source: $(DEVMEM2_SITE)/$(DEVMEM2_SOURCE)" >>$@
	@echo "Description: $(DEVMEM2_DESCRIPTION)" >>$@
	@echo "Depends: $(DEVMEM2_DEPENDS)" >>$@
	@echo "Suggests: $(DEVMEM2_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEVMEM2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEVMEM2_IPK_DIR)/opt/sbin or $(DEVMEM2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEVMEM2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEVMEM2_IPK_DIR)/opt/etc/devmem2/...
# Documentation files should be installed in $(DEVMEM2_IPK_DIR)/opt/doc/devmem2/...
# Daemon startup scripts should be installed in $(DEVMEM2_IPK_DIR)/opt/etc/init.d/S??devmem2
#
# You may need to patch your application to make it use these locations.
#
$(DEVMEM2_IPK): $(DEVMEM2_BUILD_DIR)/.built
	rm -rf $(DEVMEM2_IPK_DIR) $(BUILD_DIR)/devmem2_*_$(TARGET_ARCH).ipk
	install -d $(DEVMEM2_IPK_DIR)/opt/bin
	install -m 755 $(<D)/devmem2 $(DEVMEM2_IPK_DIR)/opt/bin/devmem2
	$(STRIP_COMMAND) $(DEVMEM2_IPK_DIR)/opt/bin/devmem2
	$(MAKE) $(DEVMEM2_IPK_DIR)/CONTROL/control
#	echo $(DEVMEM2_CONFFILES) | sed -e 's/ /\n/g' > $(DEVMEM2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEVMEM2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
devmem2-ipk: $(DEVMEM2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
devmem2-clean:
	rm -f $(DEVMEM2_BUILD_DIR)/.built
	-$(MAKE) -C $(DEVMEM2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
devmem2-dirclean:
	rm -rf $(BUILD_DIR)/$(DEVMEM2_DIR) $(DEVMEM2_BUILD_DIR) $(DEVMEM2_IPK_DIR) $(DEVMEM2_IPK)
#
#
# Some sanity check for the package.
#
devmem2-check: $(DEVMEM2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
