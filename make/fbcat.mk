###########################################################
#
# fbcat
#
###########################################################

# You must replace "fbcat" and "FBCAT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FBCAT_VERSION, FBCAT_SITE and FBCAT_SOURCE define
# the upstream location of the source code for the package.
# FBCAT_DIR is the directory which is created when the source
# archive is unpacked.
# FBCAT_UNZIP is the command used to unzip the source.
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
FBCAT_SITE=http://fbcat.googlecode.com/files
FBCAT_VERSION=0.2
FBCAT_SOURCE=fbcat-$(FBCAT_VERSION).tar.gz
FBCAT_DIR=fbcat-$(FBCAT_VERSION)
FBCAT_UNZIP=zcat
FBCAT_MAINTAINER=WebOS Internals <support@webos-internals.org>
FBCAT_DESCRIPTION=fbcat takes a screenshot using the framebuffer device.
FBCAT_SECTION=util
FBCAT_PRIORITY=optional
FBCAT_DEPENDS=
FBCAT_SUGGESTS=
FBCAT_CONFLICTS=

#
# FBCAT_IPK_VERSION should be incremented when the ipk changes.
#
FBCAT_IPK_VERSION=1

#
# FBCAT_CONFFILES should be a list of user-editable files
#FBCAT_CONFFILES=/opt/etc/fbcat.conf /opt/etc/init.d/SXXfbcat

#
# FBCAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# FBCAT_PATCHES=$(FBCAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FBCAT_CPPFLAGS=
FBCAT_LDFLAGS=

#
# FBCAT_BUILD_DIR is the directory in which the build is done.
# FBCAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FBCAT_IPK_DIR is the directory in which the ipk is built.
# FBCAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FBCAT_BUILD_DIR=$(BUILD_DIR)/fbcat
FBCAT_SOURCE_DIR=$(SOURCE_DIR)/fbcat
FBCAT_IPK_DIR=$(BUILD_DIR)/fbcat-$(FBCAT_VERSION)-ipk
FBCAT_IPK=$(BUILD_DIR)/fbcat_$(FBCAT_VERSION)-$(FBCAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fbcat-source fbcat-unpack fbcat fbcat-stage fbcat-ipk fbcat-clean fbcat-dirclean fbcat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FBCAT_SOURCE):
	$(WGET) -P $(@D) $(FBCAT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fbcat-source: $(DL_DIR)/$(FBCAT_SOURCE) $(FBCAT_PATCHES)

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
$(FBCAT_BUILD_DIR)/.configured: $(DL_DIR)/$(FBCAT_SOURCE) $(FBCAT_PATCHES) make/fbcat.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FBCAT_DIR) $(@D)
	$(FBCAT_UNZIP) $(DL_DIR)/$(FBCAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FBCAT_PATCHES)" ; \
		then cat $(FBCAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FBCAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FBCAT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FBCAT_DIR) $(@D) ; \
	fi
	touch $@

fbcat-unpack: $(FBCAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FBCAT_BUILD_DIR)/.built: $(FBCAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS)
	touch $@

#
# This is the build convenience target.
#
fbcat: $(FBCAT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fbcat
#
$(FBCAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fbcat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FBCAT_PRIORITY)" >>$@
	@echo "Section: $(FBCAT_SECTION)" >>$@
	@echo "Version: $(FBCAT_VERSION)-$(FBCAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FBCAT_MAINTAINER)" >>$@
	@echo "Source: $(FBCAT_SITE)/$(FBCAT_SOURCE)" >>$@
	@echo "Description: $(FBCAT_DESCRIPTION)" >>$@
	@echo "Depends: $(FBCAT_DEPENDS)" >>$@
	@echo "Suggests: $(FBCAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(FBCAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FBCAT_IPK_DIR)/opt/sbin or $(FBCAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FBCAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FBCAT_IPK_DIR)/opt/etc/fbcat/...
# Documentation files should be installed in $(FBCAT_IPK_DIR)/opt/doc/fbcat/...
# Daemon startup scripts should be installed in $(FBCAT_IPK_DIR)/opt/etc/init.d/S??fbcat
#
# You may need to patch your application to make it use these locations.
#
$(FBCAT_IPK): $(FBCAT_BUILD_DIR)/.built
	rm -rf $(FBCAT_IPK_DIR) $(BUILD_DIR)/fbcat_*_$(TARGET_ARCH).ipk
	install -d $(FBCAT_IPK_DIR)/opt/bin/
	install -m 755 $(FBCAT_BUILD_DIR)/fbcat $(FBCAT_IPK_DIR)/opt/bin/
	install -m 755 $(FBCAT_BUILD_DIR)/fbgrab $(FBCAT_IPK_DIR)/opt/bin/
	$(MAKE) $(FBCAT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FBCAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fbcat-ipk: $(FBCAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fbcat-clean:
	rm -f $(FBCAT_BUILD_DIR)/.built
	-$(MAKE) -C $(FBCAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fbcat-dirclean:
	rm -rf $(BUILD_DIR)/$(FBCAT_DIR) $(FBCAT_BUILD_DIR) $(FBCAT_IPK_DIR) $(FBCAT_IPK)
#
#
# Some sanity check for the package.
#
fbcat-check: $(FBCAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
