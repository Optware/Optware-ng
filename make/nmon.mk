###########################################################
#
# nmon
#
###########################################################

# You must replace "nmon" and "NMON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NMON_VERSION, NMON_SITE and NMON_SOURCE define
# the upstream location of the source code for the package.
# NMON_DIR is the directory which is created when the source
# archive is unpacked.
# NMON_UNZIP is the command used to unzip the source.
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
NMON_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nmon
NMON_VERSION=14g
NMON_SOURCE=lmon$(NMON_VERSION).c
NMON_DIR=nmon-$(NMON_VERSION)
NMON_UNZIP=
NMON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NMON_DESCRIPTION=Nigel's performance Monitor for Linux
NMON_SECTION=utils
NMON_PRIORITY=optional
NMON_DEPENDS=ncurses
NMON_SUGGESTS=
NMON_CONFLICTS=

#
# NMON_IPK_VERSION should be incremented when the ipk changes.
#
NMON_IPK_VERSION=1

#
# NMON_CONFFILES should be a list of user-editable files
#NMON_CONFFILES=/opt/etc/nmon.conf /opt/etc/init.d/SXXnmon

#
# NMON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NMON_PATCHES=$(NMON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NMON_CPPFLAGS=-g -D JFS -D GETUSER -Wall -D LARGEMEM -I$(STAGING_INCLUDE_DIR)/ncurses
NMON_LDFLAGS=-lncurses

#
# NMON_BUILD_DIR is the directory in which the build is done.
# NMON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NMON_IPK_DIR is the directory in which the ipk is built.
# NMON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NMON_BUILD_DIR=$(BUILD_DIR)/nmon
NMON_SOURCE_DIR=$(SOURCE_DIR)/nmon
NMON_IPK_DIR=$(BUILD_DIR)/nmon-$(NMON_VERSION)-ipk
NMON_IPK=$(BUILD_DIR)/nmon_$(NMON_VERSION)-$(NMON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nmon-source nmon-unpack nmon nmon-stage nmon-ipk nmon-clean nmon-dirclean nmon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NMON_SOURCE):
	$(WGET) -P $(@D) $(NMON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nmon-source: $(DL_DIR)/$(NMON_SOURCE) $(NMON_PATCHES)

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
$(NMON_BUILD_DIR)/.configured: $(DL_DIR)/$(NMON_SOURCE) $(NMON_PATCHES) make/nmon.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NMON_DIR) $(@D)
	mkdir $(@D)
	cp $(DL_DIR)/$(NMON_SOURCE) $(@D)/
	if test -n "$(NMON_PATCHES)" ; \
		then cat $(NMON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NMON_DIR) -p0 ; \
	fi
	touch $@

nmon-unpack: $(NMON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NMON_BUILD_DIR)/.built: $(NMON_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		$(TARGET_CC) $(STAGING_CPPFLAGS) $(NMON_CPPFLAGS) $(STAGING_LDFLAGS) $(NMON_LDFLAGS) $(NMON_SOURCE) -o nmon \
	)
	touch $@

#
# This is the build convenience target.
#
nmon: $(NMON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NMON_BUILD_DIR)/.staged: $(NMON_BUILD_DIR)/.built
	rm -f $@
	touch $@

nmon-stage: $(NMON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nmon
#
$(NMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nmon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NMON_PRIORITY)" >>$@
	@echo "Section: $(NMON_SECTION)" >>$@
	@echo "Version: $(NMON_VERSION)-$(NMON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NMON_MAINTAINER)" >>$@
	@echo "Source: $(NMON_SITE)/$(NMON_SOURCE)" >>$@
	@echo "Description: $(NMON_DESCRIPTION)" >>$@
	@echo "Depends: $(NMON_DEPENDS)" >>$@
	@echo "Suggests: $(NMON_SUGGESTS)" >>$@
	@echo "Conflicts: $(NMON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NMON_IPK_DIR)/opt/sbin or $(NMON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NMON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NMON_IPK_DIR)/opt/etc/nmon/...
# Documentation files should be installed in $(NMON_IPK_DIR)/opt/doc/nmon/...
# Daemon startup scripts should be installed in $(NMON_IPK_DIR)/opt/etc/init.d/S??nmon
#
# You may need to patch your application to make it use these locations.
#
$(NMON_IPK): $(NMON_BUILD_DIR)/.built
	rm -rf $(NMON_IPK_DIR) $(BUILD_DIR)/nmon_*_$(TARGET_ARCH).ipk
	install -d $(NMON_IPK_DIR)/opt/bin
	install -m 755 $(NMON_BUILD_DIR)/nmon $(NMON_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(NMON_IPK_DIR)/opt/bin/nmon
	$(MAKE) $(NMON_IPK_DIR)/CONTROL/control
	echo $(NMON_CONFFILES) | sed -e 's/ /\n/g' > $(NMON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NMON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NMON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nmon-ipk: $(NMON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nmon-clean:
	rm -f $(NMON_BUILD_DIR)/.built
	rm -f $(NMON_BUILD_DIR)/nmon

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nmon-dirclean:
	rm -rf $(BUILD_DIR)/$(NMON_DIR) $(NMON_BUILD_DIR) $(NMON_IPK_DIR) $(NMON_IPK)
#
#
# Some sanity check for the package.
#
nmon-check: $(NMON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
