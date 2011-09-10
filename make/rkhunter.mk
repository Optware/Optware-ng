###########################################################
#
# rkhunter
#
###########################################################

# You must replace "rkhunter" and "RKHUNTER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# RKHUNTER_VERSION, RKHUNTER_SITE and RKHUNTER_SOURCE define
# the upstream location of the source code for the package.
# RKHUNTER_DIR is the directory which is created when the source
# archive is unpacked.
# RKHUNTER_UNZIP is the command used to unzip the source.
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
RKHUNTER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/rkhunter
RKHUNTER_VERSION=1.3.8
RKHUNTER_SOURCE=rkhunter-$(RKHUNTER_VERSION).tar.gz
RKHUNTER_DIR=rkhunter-$(RKHUNTER_VERSION)
RKHUNTER_UNZIP=zcat
RKHUNTER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RKHUNTER_DESCRIPTION=Scans files and systems for known and unknown rootkits.
RKHUNTER_SECTION=security
RKHUNTER_PRIORITY=optional
RKHUNTER_DEPENDS=
RKHUNTER_SUGGESTS=lsof
RKHUNTER_CONFLICTS=

#
# RKHUNTER_IPK_VERSION should be incremented when the ipk changes.
#
RKHUNTER_IPK_VERSION=1

#
# RKHUNTER_CONFFILES should be a list of user-editable files
RKHUNTER_CONFFILES=/opt/etc/rkhunter.conf

#
# RKHUNTER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RKHUNTER_PATCHES=$(RKHUNTER_SOURCE_DIR)/conffile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RKHUNTER_CPPFLAGS=
RKHUNTER_LDFLAGS=

#
# RKHUNTER_BUILD_DIR is the directory in which the build is done.
# RKHUNTER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RKHUNTER_IPK_DIR is the directory in which the ipk is built.
# RKHUNTER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RKHUNTER_BUILD_DIR=$(BUILD_DIR)/rkhunter
RKHUNTER_SOURCE_DIR=$(SOURCE_DIR)/rkhunter
RKHUNTER_IPK_DIR=$(BUILD_DIR)/rkhunter-$(RKHUNTER_VERSION)-ipk
RKHUNTER_IPK=$(BUILD_DIR)/rkhunter_$(RKHUNTER_VERSION)-$(RKHUNTER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rkhunter-source rkhunter-unpack rkhunter rkhunter-stage rkhunter-ipk rkhunter-clean rkhunter-dirclean rkhunter-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RKHUNTER_SOURCE):
	$(WGET) -P $(@D) $(RKHUNTER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rkhunter-source: $(DL_DIR)/$(RKHUNTER_SOURCE) $(RKHUNTER_PATCHES)

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
$(RKHUNTER_BUILD_DIR)/.configured: $(DL_DIR)/$(RKHUNTER_SOURCE) $(RKHUNTER_PATCHES) make/rkhunter.mk
	rm -rf $(BUILD_DIR)/$(RKHUNTER_DIR) $(@D)
	$(RKHUNTER_UNZIP) $(DL_DIR)/$(RKHUNTER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RKHUNTER_PATCHES)" ; \
		then cat $(RKHUNTER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RKHUNTER_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RKHUNTER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RKHUNTER_DIR) $(@D) ; \
	fi
	touch $@

rkhunter-unpack: $(RKHUNTER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RKHUNTER_BUILD_DIR)/.built: $(RKHUNTER_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
rkhunter: $(RKHUNTER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RKHUNTER_BUILD_DIR)/.staged: $(RKHUNTER_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D); \
		./installer.sh \
		--layout custom $(STAGING_DIR)/opt \
		--install \
	)
	touch $@

rkhunter-stage: $(RKHUNTER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rkhunter
#
$(RKHUNTER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rkhunter" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RKHUNTER_PRIORITY)" >>$@
	@echo "Section: $(RKHUNTER_SECTION)" >>$@
	@echo "Version: $(RKHUNTER_VERSION)-$(RKHUNTER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RKHUNTER_MAINTAINER)" >>$@
	@echo "Source: $(RKHUNTER_SITE)/$(RKHUNTER_SOURCE)" >>$@
	@echo "Description: $(RKHUNTER_DESCRIPTION)" >>$@
	@echo "Depends: $(RKHUNTER_DEPENDS)" >>$@
	@echo "Suggests: $(RKHUNTER_SUGGESTS)" >>$@
	@echo "Conflicts: $(RKHUNTER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RKHUNTER_IPK_DIR)/opt/sbin or $(RKHUNTER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RKHUNTER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RKHUNTER_IPK_DIR)/opt/etc/rkhunter/...
# Documentation files should be installed in $(RKHUNTER_IPK_DIR)/opt/doc/rkhunter/...
# Daemon startup scripts should be installed in $(RKHUNTER_IPK_DIR)/opt/etc/init.d/S??rkhunter
#
# You may need to patch your application to make it use these locations.
#
$(RKHUNTER_IPK): $(RKHUNTER_BUILD_DIR)/.built
	rm -rf $(RKHUNTER_IPK_DIR) $(BUILD_DIR)/rkhunter_*_$(TARGET_ARCH).ipk
	mkdir -p $(RKHUNTER_IPK_DIR)/opt
	(cd $(RKHUNTER_BUILD_DIR); \
		./installer.sh --layout custom $(RKHUNTER_IPK_DIR)/opt --striproot $(RKHUNTER_IPK_DIR) --install \
	)
	$(MAKE) $(RKHUNTER_IPK_DIR)/CONTROL/control
	install -m 755 $(RKHUNTER_SOURCE_DIR)/postinst $(RKHUNTER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RKHUNTER_IPK_DIR)/CONTROL/postinst
	echo $(RKHUNTER_CONFFILES) | sed -e 's/ /\n/g' > $(RKHUNTER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RKHUNTER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(RKHUNTER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rkhunter-ipk: $(RKHUNTER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rkhunter-clean:
	rm -f $(RKHUNTER_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rkhunter-dirclean:
	rm -rf $(BUILD_DIR)/$(RKHUNTER_DIR) $(RKHUNTER_BUILD_DIR) $(RKHUNTER_IPK_DIR) $(RKHUNTER_IPK)
#
#
# Some sanity check for the package.
#
rkhunter-check: $(RKHUNTER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
