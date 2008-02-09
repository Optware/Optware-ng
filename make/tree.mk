###########################################################
#
# tree
#
###########################################################
#
# TREE_VERSION, TREE_SITE and TREE_SOURCE define
# the upstream location of the source code for the package.
# TREE_DIR is the directory which is created when the source
# archive is unpacked.
# TREE_UNZIP is the command used to unzip the source.
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
TREE_SITE=ftp://mama.indstate.edu/linux/tree
TREE_VERSION=1.5.1.1
TREE_SOURCE=tree-$(TREE_VERSION).tgz
TREE_DIR=tree-$(TREE_VERSION)
TREE_UNZIP=zcat
TREE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TREE_DESCRIPTION=list contents of directories in a tree-like format.
TREE_SECTION=utils
TREE_PRIORITY=optional
TREE_DEPENDS=
TREE_SUGGESTS=
TREE_CONFLICTS=

#
# TREE_IPK_VERSION should be incremented when the ipk changes.
#
TREE_IPK_VERSION=1

#
# TREE_CONFFILES should be a list of user-editable files
#TREE_CONFFILES=/opt/etc/tree.conf /opt/etc/init.d/SXXtree

#
# TREE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TREE_PATCHES=$(TREE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TREE_CPPFLAGS=
TREE_LDFLAGS=

#
# TREE_BUILD_DIR is the directory in which the build is done.
# TREE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TREE_IPK_DIR is the directory in which the ipk is built.
# TREE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TREE_BUILD_DIR=$(BUILD_DIR)/tree
TREE_SOURCE_DIR=$(SOURCE_DIR)/tree
TREE_IPK_DIR=$(BUILD_DIR)/tree-$(TREE_VERSION)-ipk
TREE_IPK=$(BUILD_DIR)/tree_$(TREE_VERSION)-$(TREE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tree-source tree-unpack tree tree-stage tree-ipk tree-clean tree-dirclean tree-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TREE_SOURCE):
	$(WGET) -P $(DL_DIR) $(TREE_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tree-source: $(DL_DIR)/$(TREE_SOURCE) $(TREE_PATCHES)

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
$(TREE_BUILD_DIR)/.configured: $(DL_DIR)/$(TREE_SOURCE) $(TREE_PATCHES) make/tree.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TREE_DIR) $(@D)
	$(TREE_UNZIP) $(DL_DIR)/$(TREE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TREE_PATCHES)" ; \
		then cat $(TREE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TREE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TREE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TREE_DIR) $(@D) ; \
	fi
	sed -i -e 's|install -s|install|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TREE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TREE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

tree-unpack: $(TREE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TREE_BUILD_DIR)/.built: $(TREE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TREE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TREE_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
tree: $(TREE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TREE_BUILD_DIR)/.staged: $(TREE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tree-stage: $(TREE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tree
#
$(TREE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tree" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TREE_PRIORITY)" >>$@
	@echo "Section: $(TREE_SECTION)" >>$@
	@echo "Version: $(TREE_VERSION)-$(TREE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TREE_MAINTAINER)" >>$@
	@echo "Source: $(TREE_SITE)/$(TREE_SOURCE)" >>$@
	@echo "Description: $(TREE_DESCRIPTION)" >>$@
	@echo "Depends: $(TREE_DEPENDS)" >>$@
	@echo "Suggests: $(TREE_SUGGESTS)" >>$@
	@echo "Conflicts: $(TREE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TREE_IPK_DIR)/opt/sbin or $(TREE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TREE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TREE_IPK_DIR)/opt/etc/tree/...
# Documentation files should be installed in $(TREE_IPK_DIR)/opt/doc/tree/...
# Daemon startup scripts should be installed in $(TREE_IPK_DIR)/opt/etc/init.d/S??tree
#
# You may need to patch your application to make it use these locations.
#
$(TREE_IPK): $(TREE_BUILD_DIR)/.built
	rm -rf $(TREE_IPK_DIR) $(BUILD_DIR)/tree_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TREE_BUILD_DIR) install \
		DESTDIR=$(TREE_IPK_DIR) prefix=$(TREE_IPK_DIR)/opt
	$(STRIP_COMMAND) $(TREE_IPK_DIR)/opt/bin/tree
	$(MAKE) $(TREE_IPK_DIR)/CONTROL/control
	echo $(TREE_CONFFILES) | sed -e 's/ /\n/g' > $(TREE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TREE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tree-ipk: $(TREE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tree-clean:
	rm -f $(TREE_BUILD_DIR)/.built
	-$(MAKE) -C $(TREE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tree-dirclean:
	rm -rf $(BUILD_DIR)/$(TREE_DIR) $(TREE_BUILD_DIR) $(TREE_IPK_DIR) $(TREE_IPK)
#
#
# Some sanity check for the package.
#
tree-check: $(TREE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TREE_IPK)
