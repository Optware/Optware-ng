###########################################################
#
# git
#
###########################################################

# You must replace "git" and "GIT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIT_VERSION, GIT_SITE and GIT_SOURCE define
# the upstream location of the source code for the package.
# GIT_DIR is the directory which is created when the source
# archive is unpacked.
# GIT_UNZIP is the command used to unzip the source.
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
GIT_SITE=http://pasky.or.cz/~pasky/dev/git/
GIT_VERSION=pasky-0.4
GIT_SOURCE=git-pasky-base.tar.bz2
GIT_DIR=git-$(GIT_VERSION)
GIT_UNZIP=bzcat
GIT_MAINTAINER=Rod Whitby <nslu2-linux@yahoogroups.com>
GIT_DESCRIPTION=GIT - the stupid content tracker
GIT_SECTION=net
GIT_PRIORITY=optional
GIT_DEPENDS=openssl, zlib, busybox, rsync, patch, mktemp
GIT_CONFLICTS=

#
# GIT_IPK_VERSION should be incremented when the ipk changes.
#
GIT_IPK_VERSION=1

#
# GIT_CONFFILES should be a list of user-editable files
GIT_CONFFILES=

#
# GIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GIT_PATCHES=$(GIT_SOURCE_DIR)/endian.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIT_CPPFLAGS=
GIT_LDFLAGS=

#
# GIT_BUILD_DIR is the directory in which the build is done.
# GIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIT_IPK_DIR is the directory in which the ipk is built.
# GIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIT_BUILD_DIR=$(BUILD_DIR)/git
GIT_SOURCE_DIR=$(SOURCE_DIR)/git
GIT_IPK_DIR=$(BUILD_DIR)/git-$(GIT_VERSION)-ipk
GIT_IPK=$(BUILD_DIR)/git_$(GIT_VERSION)-$(GIT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIT_SITE)/$(GIT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
git-source: $(DL_DIR)/$(GIT_SOURCE) $(GIT_PATCHES)

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
$(GIT_BUILD_DIR)/.configured: $(DL_DIR)/$(GIT_SOURCE) $(GIT_PATCHES)
	$(MAKE) openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(GIT_DIR) $(GIT_BUILD_DIR)
	$(GIT_UNZIP) $(DL_DIR)/$(GIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GIT_PATCHES) | patch -d $(BUILD_DIR)/$(GIT_DIR) -p1
	mv $(BUILD_DIR)/$(GIT_DIR) $(GIT_BUILD_DIR)
	touch $(GIT_BUILD_DIR)/.configured

git-unpack: $(GIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GIT_BUILD_DIR)/.built: $(GIT_BUILD_DIR)/.configured
	rm -f $(GIT_BUILD_DIR)/.built
	$(MAKE) -C $(GIT_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) -lssl -lz"
	touch $(GIT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
git: $(GIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GIT_BUILD_DIR)/.staged: $(GIT_BUILD_DIR)/.built
	rm -f $(GIT_BUILD_DIR)/.staged
	$(MAKE) -C $(GIT_BUILD_DIR) HOME=$(STAGING_DIR)/opt install
	touch $(GIT_BUILD_DIR)/.staged

git-stage: $(GIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/git
#
$(GIT_IPK_DIR)/CONTROL/control:
	@install -d $(GIT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: git" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIT_PRIORITY)" >>$@
	@echo "Section: $(GIT_SECTION)" >>$@
	@echo "Version: $(GIT_VERSION)-$(GIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIT_MAINTAINER)" >>$@
	@echo "Source: $(GIT_SITE)/$(GIT_SOURCE)" >>$@
	@echo "Description: $(GIT_DESCRIPTION)" >>$@
	@echo "Depends: $(GIT_DEPENDS)" >>$@
	@echo "Conflicts: $(GIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIT_IPK_DIR)/opt/sbin or $(GIT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIT_IPK_DIR)/opt/etc/git/...
# Documentation files should be installed in $(GIT_IPK_DIR)/opt/doc/git/...
# Daemon startup scripts should be installed in $(GIT_IPK_DIR)/opt/etc/init.d/S??git
#
# You may need to patch your application to make it use these locations.
#
$(GIT_IPK): $(GIT_BUILD_DIR)/.built
	rm -rf $(GIT_IPK_DIR) $(BUILD_DIR)/git_*_$(TARGET_ARCH).ipk
	install -d $(GIT_IPK_DIR)/opt/bin
	$(MAKE) -C $(GIT_BUILD_DIR) HOME=$(GIT_IPK_DIR)/opt install
	$(MAKE) $(GIT_IPK_DIR)/CONTROL/control
	echo $(GIT_CONFFILES) | sed -e 's/ /\n/g' > $(GIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
git-ipk: $(GIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
git-clean:
	-$(MAKE) -C $(GIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
git-dirclean:
	rm -rf $(BUILD_DIR)/$(GIT_DIR) $(GIT_BUILD_DIR) $(GIT_IPK_DIR) $(GIT_IPK)
