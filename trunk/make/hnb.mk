###########################################################
#
# hnb
#
###########################################################

# You must replace "hnb" and "HNB" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HNB_VERSION, HNB_SITE and HNB_SOURCE define
# the upstream location of the source code for the package.
# HNB_DIR is the directory which is created when the source
# archive is unpacked.
# HNB_UNZIP is the command used to unzip the source.
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
HNB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/hnb
HNB_VERSION=1.9.17
HNB_SOURCE=hnb-$(HNB_VERSION).tar.gz
HNB_DIR=hnb-$(HNB_VERSION)
HNB_UNZIP=zcat
HNB_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
HNB_DESCRIPTION=Hierarchical notebook(hnb) is a curses program to structure many kinds of data in one place.
HNB_SECTION=misc
HNB_PRIORITY=optional
HNB_DEPENDS=ncurses
HNB_CONFLICTS=

#
# HNB_IPK_VERSION should be incremented when the ipk changes.
#
HNB_IPK_VERSION=1

#
# HNB_CONFFILES should be a list of user-editable files
#HNB_CONFFILES=/opt/etc/hnb.conf /opt/etc/init.d/SXXhnb

#
# HNB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HNB_PATCHES=$(HNB_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HNB_CPPFLAGS=
HNB_LDFLAGS=

#
# HNB_BUILD_DIR is the directory in which the build is done.
# HNB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HNB_IPK_DIR is the directory in which the ipk is built.
# HNB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HNB_BUILD_DIR=$(BUILD_DIR)/hnb
HNB_SOURCE_DIR=$(SOURCE_DIR)/hnb
HNB_IPK_DIR=$(BUILD_DIR)/hnb-$(HNB_VERSION)-ipk
HNB_IPK=$(BUILD_DIR)/hnb_$(HNB_VERSION)-$(HNB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HNB_SOURCE):
	$(WGET) -P $(DL_DIR) $(HNB_SITE)/$(HNB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hnb-source: $(DL_DIR)/$(HNB_SOURCE) $(HNB_PATCHES)

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
$(HNB_BUILD_DIR)/.configured: $(DL_DIR)/$(HNB_SOURCE) $(HNB_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(HNB_DIR) $(HNB_BUILD_DIR)
	$(HNB_UNZIP) $(DL_DIR)/$(HNB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(HNB_PATCHES) | patch -d $(BUILD_DIR)/$(HNB_DIR) -p1
	mv $(BUILD_DIR)/$(HNB_DIR) $(HNB_BUILD_DIR)
#	(cd $(HNB_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(HNB_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(HNB_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#	)
	touch $(HNB_BUILD_DIR)/.configured

hnb-unpack: $(HNB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HNB_BUILD_DIR)/.built: $(HNB_BUILD_DIR)/.configured
	rm -f $(HNB_BUILD_DIR)/.built
	cd $(HNB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STAGING_CPPFLAGS)/ncurses $(HNB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HNB_LDFLAGS)" \
		$(MAKE) -C $(HNB_BUILD_DIR)
	touch $(HNB_BUILD_DIR)/.built

#
# This is the build convenience target.
#
hnb: $(HNB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HNB_BUILD_DIR)/.staged: $(HNB_BUILD_DIR)/.built
	rm -f $(HNB_BUILD_DIR)/.staged
	$(MAKE) -C $(HNB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(HNB_BUILD_DIR)/.staged

hnb-stage: $(HNB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hnb
#
$(HNB_IPK_DIR)/CONTROL/control:
	@install -d $(HNB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: hnb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HNB_PRIORITY)" >>$@
	@echo "Section: $(HNB_SECTION)" >>$@
	@echo "Version: $(HNB_VERSION)-$(HNB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HNB_MAINTAINER)" >>$@
	@echo "Source: $(HNB_SITE)/$(HNB_SOURCE)" >>$@
	@echo "Description: $(HNB_DESCRIPTION)" >>$@
	@echo "Depends: $(HNB_DEPENDS)" >>$@
	@echo "Conflicts: $(HNB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HNB_IPK_DIR)/opt/sbin or $(HNB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HNB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HNB_IPK_DIR)/opt/etc/hnb/...
# Documentation files should be installed in $(HNB_IPK_DIR)/opt/doc/hnb/...
# Daemon startup scripts should be installed in $(HNB_IPK_DIR)/opt/etc/init.d/S??hnb
#
# You may need to patch your application to make it use these locations.
#
$(HNB_IPK): $(HNB_BUILD_DIR)/.built
	rm -rf $(HNB_IPK_DIR) $(BUILD_DIR)/hnb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HNB_BUILD_DIR) DESTDIR=$(HNB_IPK_DIR)/opt install
	$(MAKE) $(HNB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HNB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hnb-ipk: $(HNB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hnb-clean:
	-$(MAKE) -C $(HNB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hnb-dirclean:
	rm -rf $(BUILD_DIR)/$(HNB_DIR) $(HNB_BUILD_DIR) $(HNB_IPK_DIR) $(HNB_IPK)
