###########################################################
#
# lrzsz
#
###########################################################

# You must replace "lrzsz" and "LRZSZ" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LRZSZ_VERSION, LRZSZ_SITE and LRZSZ_SOURCE define
# the upstream location of the source code for the package.
# LRZSZ_DIR is the directory which is created when the source
# archive is unpacked.
# LRZSZ_UNZIP is the command used to unzip the source.
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
LRZSZ_SITE=http://www.ohse.de/uwe/releases
LRZSZ_VERSION=0.12.20
LRZSZ_SOURCE=lrzsz-$(LRZSZ_VERSION).tar.gz
LRZSZ_DIR=lrzsz-$(LRZSZ_VERSION)
LRZSZ_UNZIP=zcat
LRZSZ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LRZSZ_DESCRIPTION=Tools for zmodem/xmodem/ymodem file transfer
LRZSZ_SECTION=network
LRZSZ_PRIORITY=optional
LRZSZ_DEPENDS=
LRZSZ_SUGGESTS=
LRZSZ_CONFLICTS=

#
# LRZSZ_IPK_VERSION should be incremented when the ipk changes.
#
LRZSZ_IPK_VERSION=1

#
# LRZSZ_CONFFILES should be a list of user-editable files
LRZSZ_CONFFILES=

#
# LRZSZ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LRZSZ_PATCHES=
#	      $(LRZSZ_SOURCE_DIR)/autotools.patch \
#	      $(LRZSZ_SOURCE_DIR)/makefile.patch \
#	      $(LRZSZ_SOURCE_DIR)/gettext.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LRZSZ_CPPFLAGS=
LRZSZ_LDFLAGS=

#
# LRZSZ_BUILD_DIR is the directory in which the build is done.
# LRZSZ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LRZSZ_IPK_DIR is the directory in which the ipk is built.
# LRZSZ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LRZSZ_BUILD_DIR=$(BUILD_DIR)/lrzsz
LRZSZ_SOURCE_DIR=$(SOURCE_DIR)/lrzsz
LRZSZ_IPK_DIR=$(BUILD_DIR)/lrzsz-$(LRZSZ_VERSION)-ipk
LRZSZ_IPK=$(BUILD_DIR)/lrzsz_$(LRZSZ_VERSION)-$(LRZSZ_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LRZSZ_SOURCE):
	$(WGET) -P $(DL_DIR) $(LRZSZ_SITE)/$(LRZSZ_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lrzsz-source: $(DL_DIR)/$(LRZSZ_SOURCE) $(LRZSZ_PATCHES)

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
$(LRZSZ_BUILD_DIR)/.configured: $(DL_DIR)/$(LRZSZ_SOURCE) $(LRZSZ_PATCHES) make/lrzsz.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LRZSZ_DIR) $(LRZSZ_BUILD_DIR)
	$(LRZSZ_UNZIP) $(DL_DIR)/$(LRZSZ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LRZSZ_PATCHES)" ; \
		then cat $(LRZSZ_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LRZSZ_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LRZSZ_DIR)" != "$(LRZSZ_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LRZSZ_DIR) $(LRZSZ_BUILD_DIR) ; \
	fi
	(cd $(LRZSZ_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LRZSZ_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LRZSZ_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(LRZSZ_BUILD_DIR)/libtool
	touch $(LRZSZ_BUILD_DIR)/.configured

lrzsz-unpack: $(LRZSZ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LRZSZ_BUILD_DIR)/.built: $(LRZSZ_BUILD_DIR)/.configured
	rm -f $(LRZSZ_BUILD_DIR)/.built
	$(MAKE) -C $(LRZSZ_BUILD_DIR)
	touch $(LRZSZ_BUILD_DIR)/.built

#
# This is the build convenience target.
#
lrzsz: $(LRZSZ_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lrzsz
#
$(LRZSZ_IPK_DIR)/CONTROL/control:
	@install -d $(LRZSZ_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lrzsz" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LRZSZ_PRIORITY)" >>$@
	@echo "Section: $(LRZSZ_SECTION)" >>$@
	@echo "Version: $(LRZSZ_VERSION)-$(LRZSZ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LRZSZ_MAINTAINER)" >>$@
	@echo "Source: $(LRZSZ_SITE)/$(LRZSZ_SOURCE)" >>$@
	@echo "Description: $(LRZSZ_DESCRIPTION)" >>$@
	@echo "Depends: $(LRZSZ_DEPENDS)" >>$@
	@echo "Suggests: $(LRZSZ_SUGGESTS)" >>$@
	@echo "Conflicts: $(LRZSZ_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LRZSZ_IPK_DIR)/opt/sbin or $(LRZSZ_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LRZSZ_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LRZSZ_IPK_DIR)/opt/etc/lrzsz/...
# Documentation files should be installed in $(LRZSZ_IPK_DIR)/opt/doc/lrzsz/...
# Daemon startup scripts should be installed in $(LRZSZ_IPK_DIR)/opt/etc/init.d/S??lrzsz
#
# You may need to patch your application to make it use these locations.
#
$(LRZSZ_IPK): $(LRZSZ_BUILD_DIR)/.built
	rm -rf $(LRZSZ_IPK_DIR) $(BUILD_DIR)/lrzsz_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LRZSZ_BUILD_DIR) DESTDIR=$(LRZSZ_IPK_DIR) install
	$(MAKE) $(LRZSZ_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LRZSZ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lrzsz-ipk: $(LRZSZ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lrzsz-clean:
	rm -f $(LRZSZ_BUILD_DIR)/.built
	-$(MAKE) -C $(LRZSZ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lrzsz-dirclean:
	rm -rf $(BUILD_DIR)/$(LRZSZ_DIR) $(LRZSZ_BUILD_DIR) $(LRZSZ_IPK_DIR) $(LRZSZ_IPK)
