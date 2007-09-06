###########################################################
#
# ctags
#
###########################################################

# You must replace "ctags" and "CTAGS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CTAGS_VERSION, CTAGS_SITE and CTAGS_SOURCE define
# the upstream location of the source code for the package.
# CTAGS_DIR is the directory which is created when the source
# archive is unpacked.
# CTAGS_UNZIP is the command used to unzip the source.
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
CTAGS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ctags
CTAGS_VERSION=5.7
CTAGS_SOURCE=ctags-$(CTAGS_VERSION).tar.gz
CTAGS_DIR=ctags-$(CTAGS_VERSION)
CTAGS_UNZIP=zcat
CTAGS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CTAGS_DESCRIPTION=Ctags generates an index (or tag) file of language objects found in source files that allows these items to be quickly and easily located by a text editor or other utility.
CTAGS_SECTION=misc
CTAGS_PRIORITY=optional
CTAGS_DEPENDS=

#
# CTAGS_IPK_VERSION should be incremented when the ipk changes.
#
CTAGS_IPK_VERSION=1

#
# CTAGS_CONFFILES should be a list of user-editable files
CTAGS_CONFFILES=/opt/etc/ctags.conf /opt/etc/init.d/SXXctags

#
# CTAGS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CTAGS_PATCHES=$(CTAGS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CTAGS_CPPFLAGS=
CTAGS_LDFLAGS=

#
# CTAGS_BUILD_DIR is the directory in which the build is done.
# CTAGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CTAGS_IPK_DIR is the directory in which the ipk is built.
# CTAGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CTAGS_BUILD_DIR=$(BUILD_DIR)/ctags
CTAGS_SOURCE_DIR=$(SOURCE_DIR)/ctags
CTAGS_IPK_DIR=$(BUILD_DIR)/ctags-$(CTAGS_VERSION)-ipk
CTAGS_IPK=$(BUILD_DIR)/ctags_$(CTAGS_VERSION)-$(CTAGS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CTAGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CTAGS_SITE)/$(CTAGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ctags-source: $(DL_DIR)/$(CTAGS_SOURCE) $(CTAGS_PATCHES)

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
$(CTAGS_BUILD_DIR)/.configured: $(DL_DIR)/$(CTAGS_SOURCE) $(CTAGS_PATCHES)
	rm -rf $(BUILD_DIR)/$(CTAGS_DIR) $(CTAGS_BUILD_DIR)
	$(CTAGS_UNZIP) $(DL_DIR)/$(CTAGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CTAGS_PATCHES) | patch -d $(BUILD_DIR)/$(CTAGS_DIR) -p2
	mv $(BUILD_DIR)/$(CTAGS_DIR) $(CTAGS_BUILD_DIR)
	(cd $(CTAGS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CTAGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CTAGS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(CTAGS_BUILD_DIR)/.configured

ctags-unpack: $(CTAGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CTAGS_BUILD_DIR)/.built: $(CTAGS_BUILD_DIR)/.configured
	rm -f $(CTAGS_BUILD_DIR)/.built
	$(MAKE) -C $(CTAGS_BUILD_DIR)
	touch $(CTAGS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ctags: $(CTAGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CTAGS_BUILD_DIR)/.staged: $(CTAGS_BUILD_DIR)/.built
	rm -f $(CTAGS_BUILD_DIR)/.staged
	$(MAKE) -C $(CTAGS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CTAGS_BUILD_DIR)/.staged

ctags-stage: $(CTAGS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ctags
#
$(CTAGS_IPK_DIR)/CONTROL/control:
	@install -d $(CTAGS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ctags" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CTAGS_PRIORITY)" >>$@
	@echo "Section: $(CTAGS_SECTION)" >>$@
	@echo "Version: $(CTAGS_VERSION)-$(CTAGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CTAGS_MAINTAINER)" >>$@
	@echo "Source: $(CTAGS_SITE)/$(CTAGS_SOURCE)" >>$@
	@echo "Description: $(CTAGS_DESCRIPTION)" >>$@
	@echo "Depends: $(CTAGS_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CTAGS_IPK_DIR)/opt/sbin or $(CTAGS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CTAGS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CTAGS_IPK_DIR)/opt/etc/ctags/...
# Documentation files should be installed in $(CTAGS_IPK_DIR)/opt/doc/ctags/...
# Daemon startup scripts should be installed in $(CTAGS_IPK_DIR)/opt/etc/init.d/S??ctags
#
# You may need to patch your application to make it use these locations.
#
$(CTAGS_IPK): $(CTAGS_BUILD_DIR)/.built
	rm -rf $(CTAGS_IPK_DIR) $(BUILD_DIR)/ctags_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CTAGS_BUILD_DIR) DESTDIR=$(CTAGS_IPK_DIR) prefix=$(CTAGS_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(CTAGS_IPK_DIR)/opt/bin/ctags
	$(MAKE) $(CTAGS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CTAGS_IPK_DIR)

ctags-ipk: $(CTAGS_IPK)

ctags-clean:
	-$(MAKE) -C $(CTAGS_BUILD_DIR) clean

ctags-dirclean:
	rm -rf $(BUILD_DIR)/$(CTAGS_DIR) $(CTAGS_BUILD_DIR) $(CTAGS_IPK_DIR) $(CTAGS_IPK)

ctags-check: $(CTAGS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CTAGS_IPK)
