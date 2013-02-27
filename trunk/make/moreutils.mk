###########################################################
#
# moreutils
#
###########################################################
#
# MOREUTILS_VERSION, MOREUTILS_SITE and MOREUTILS_SOURCE define
# the upstream location of the source code for the package.
# MOREUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# MOREUTILS_UNZIP is the command used to unzip the source.
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
MOREUTILS_SITE=http://ftp.debian.org/debian/pool/main/m/moreutils
MOREUTILS_VERSION=0.47
MOREUTILS_SOURCE=moreutils_$(MOREUTILS_VERSION).tar.gz
MOREUTILS_DIR=moreutils
MOREUTILS_UNZIP=zcat
MOREUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOREUTILS_DESCRIPTION=additional Unix utilities
MOREUTILS_SECTION=utils
MOREUTILS_PRIORITY=optional
MOREUTILS_DEPENDS=perl
MOREUTILS_SUGGESTS=
MOREUTILS_CONFLICTS=

#
# MOREUTILS_IPK_VERSION should be incremented when the ipk changes.
#
MOREUTILS_IPK_VERSION=1

#
# MOREUTILS_CONFFILES should be a list of user-editable files
#MOREUTILS_CONFFILES=/opt/etc/moreutils.conf /opt/etc/init.d/SXXmoreutils

#
# MOREUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOREUTILS_PATCHES=$(MOREUTILS_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOREUTILS_CPPFLAGS=
MOREUTILS_LDFLAGS=

#
# MOREUTILS_BUILD_DIR is the directory in which the build is done.
# MOREUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOREUTILS_IPK_DIR is the directory in which the ipk is built.
# MOREUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOREUTILS_BUILD_DIR=$(BUILD_DIR)/moreutils
MOREUTILS_SOURCE_DIR=$(SOURCE_DIR)/moreutils
MOREUTILS_IPK_DIR=$(BUILD_DIR)/moreutils-$(MOREUTILS_VERSION)-ipk
MOREUTILS_IPK=$(BUILD_DIR)/moreutils_$(MOREUTILS_VERSION)-$(MOREUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: moreutils-source moreutils-unpack moreutils moreutils-stage moreutils-ipk moreutils-clean moreutils-dirclean moreutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOREUTILS_SOURCE):
	$(WGET) -P $(@D) $(MOREUTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
moreutils-source: $(DL_DIR)/$(MOREUTILS_SOURCE) $(MOREUTILS_PATCHES)

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
$(MOREUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(MOREUTILS_SOURCE) $(MOREUTILS_PATCHES) make/moreutils.mk
	rm -rf $(BUILD_DIR)/$(MOREUTILS_DIR) $(@D)
	$(MOREUTILS_UNZIP) $(DL_DIR)/$(MOREUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOREUTILS_PATCHES)" ; \
		then cat $(MOREUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOREUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOREUTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MOREUTILS_DIR) $(@D) ; \
	fi
	touch $@

moreutils-unpack: $(MOREUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOREUTILS_BUILD_DIR)/.built: $(MOREUTILS_BUILD_DIR)/.configured
	rm -f $@
	CC=$(TARGET_CC) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
moreutils: $(MOREUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOREUTILS_BUILD_DIR)/.staged: $(MOREUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

moreutils-stage: $(MOREUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/moreutils
#
$(MOREUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: moreutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOREUTILS_PRIORITY)" >>$@
	@echo "Section: $(MOREUTILS_SECTION)" >>$@
	@echo "Version: $(MOREUTILS_VERSION)-$(MOREUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOREUTILS_MAINTAINER)" >>$@
	@echo "Source: $(MOREUTILS_SITE)/$(MOREUTILS_SOURCE)" >>$@
	@echo "Description: $(MOREUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(MOREUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(MOREUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOREUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOREUTILS_IPK_DIR)/opt/sbin or $(MOREUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOREUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOREUTILS_IPK_DIR)/opt/etc/moreutils/...
# Documentation files should be installed in $(MOREUTILS_IPK_DIR)/opt/doc/moreutils/...
# Daemon startup scripts should be installed in $(MOREUTILS_IPK_DIR)/opt/etc/init.d/S??moreutils
#
# You may need to patch your application to make it use these locations.
#
$(MOREUTILS_IPK): $(MOREUTILS_BUILD_DIR)/.built
	rm -rf $(MOREUTILS_IPK_DIR) $(BUILD_DIR)/moreutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOREUTILS_BUILD_DIR) STRIP_COMMAND="$(STRIP_COMMAND)" PREFIX=/opt DESTDIR=$(MOREUTILS_IPK_DIR) install
	$(MAKE) $(MOREUTILS_IPK_DIR)/CONTROL/control
	echo $(MOREUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(MOREUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOREUTILS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MOREUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
moreutils-ipk: $(MOREUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
moreutils-clean:
	rm -f $(MOREUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(MOREUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
moreutils-dirclean:
	rm -rf $(BUILD_DIR)/$(MOREUTILS_DIR) $(MOREUTILS_BUILD_DIR) $(MOREUTILS_IPK_DIR) $(MOREUTILS_IPK)
#
#
# Some sanity check for the package.
#
moreutils-check: $(MOREUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
