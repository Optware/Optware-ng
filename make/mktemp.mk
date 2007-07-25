###########################################################
#
# mktemp
#
###########################################################

# You must replace "mktemp" and "MKTEMP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MKTEMP_VERSION, MKTEMP_SITE and MKTEMP_SOURCE define
# the upstream location of the source code for the package.
# MKTEMP_DIR is the directory which is created when the source
# archive is unpacked.
# MKTEMP_UNZIP is the command used to unzip the source.
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
MKTEMP_SITE=ftp://ftp.cs.colorado.edu/pub/mktemp
MKTEMP_VERSION=1.5
MKTEMP_SOURCE=mktemp-$(MKTEMP_VERSION).tar.gz
MKTEMP_DIR=mktemp-$(MKTEMP_VERSION)
MKTEMP_UNZIP=zcat
MKTEMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MKTEMP_DESCRIPTION=Mktemp is a small program to allow safe temporary file creation from shell scripts.
MKTEMP_SECTION=util
MKTEMP_PRIORITY=optional
MKTEMP_DEPENDS=
MKTEMP_CONFLICTS=

#
# MKTEMP_IPK_VERSION should be incremented when the ipk changes.
#
MKTEMP_IPK_VERSION=1

#
# MKTEMP_CONFFILES should be a list of user-editable files
MKTEMP_CONFFILES=

#
# MKTEMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MKTEMP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MKTEMP_CPPFLAGS=
MKTEMP_LDFLAGS=

#
# MKTEMP_BUILD_DIR is the directory in which the build is done.
# MKTEMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MKTEMP_IPK_DIR is the directory in which the ipk is built.
# MKTEMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MKTEMP_BUILD_DIR=$(BUILD_DIR)/mktemp
MKTEMP_SOURCE_DIR=$(SOURCE_DIR)/mktemp
MKTEMP_IPK_DIR=$(BUILD_DIR)/mktemp-$(MKTEMP_VERSION)-ipk
MKTEMP_IPK=$(BUILD_DIR)/mktemp_$(MKTEMP_VERSION)-$(MKTEMP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MKTEMP_SOURCE):
	$(WGET) -P $(DL_DIR) $(MKTEMP_SITE)/$(MKTEMP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mktemp-source: $(DL_DIR)/$(MKTEMP_SOURCE) $(MKTEMP_PATCHES)

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
$(MKTEMP_BUILD_DIR)/.configured: $(DL_DIR)/$(MKTEMP_SOURCE) $(MKTEMP_PATCHES) make/mktemp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MKTEMP_DIR) $(MKTEMP_BUILD_DIR)
	$(MKTEMP_UNZIP) $(DL_DIR)/$(MKTEMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MKTEMP_PATCHES) | patch -d $(BUILD_DIR)/$(MKTEMP_DIR) -p1
	mv $(BUILD_DIR)/$(MKTEMP_DIR) $(MKTEMP_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(MKTEMP_BUILD_DIR)/
	(cd $(MKTEMP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MKTEMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MKTEMP_LDFLAGS)" \
		sudo_cv_ebcdic=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(MKTEMP_BUILD_DIR)/.configured

mktemp-unpack: $(MKTEMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MKTEMP_BUILD_DIR)/.built: $(MKTEMP_BUILD_DIR)/.configured
	rm -f $(MKTEMP_BUILD_DIR)/.built
	$(MAKE) -C $(MKTEMP_BUILD_DIR)
	touch $(MKTEMP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mktemp: $(MKTEMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MKTEMP_BUILD_DIR)/.staged: $(MKTEMP_BUILD_DIR)/.built
	rm -f $(MKTEMP_BUILD_DIR)/.staged
	$(MAKE) -C $(MKTEMP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MKTEMP_BUILD_DIR)/.staged

mktemp-stage: $(MKTEMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mktemp
#
$(MKTEMP_IPK_DIR)/CONTROL/control:
	@install -d $(MKTEMP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mktemp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MKTEMP_PRIORITY)" >>$@
	@echo "Section: $(MKTEMP_SECTION)" >>$@
	@echo "Version: $(MKTEMP_VERSION)-$(MKTEMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MKTEMP_MAINTAINER)" >>$@
	@echo "Source: $(MKTEMP_SITE)/$(MKTEMP_SOURCE)" >>$@
	@echo "Description: $(MKTEMP_DESCRIPTION)" >>$@
	@echo "Depends: $(MKTEMP_DEPENDS)" >>$@
	@echo "Conflicts: $(MKTEMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MKTEMP_IPK_DIR)/opt/sbin or $(MKTEMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MKTEMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MKTEMP_IPK_DIR)/opt/etc/mktemp/...
# Documentation files should be installed in $(MKTEMP_IPK_DIR)/opt/doc/mktemp/...
# Daemon startup scripts should be installed in $(MKTEMP_IPK_DIR)/opt/etc/init.d/S??mktemp
#
# You may need to patch your application to make it use these locations.
#
$(MKTEMP_IPK): $(MKTEMP_BUILD_DIR)/.built
	rm -rf $(MKTEMP_IPK_DIR) $(BUILD_DIR)/mktemp_*_$(TARGET_ARCH).ipk
	install -d $(MKTEMP_IPK_DIR)/opt/bin
	install -m 755 $(MKTEMP_BUILD_DIR)/mktemp $(MKTEMP_IPK_DIR)/opt/bin/mktemp
	$(MAKE) $(MKTEMP_IPK_DIR)/CONTROL/control
	echo $(MKTEMP_CONFFILES) | sed -e 's/ /\n/g' > $(MKTEMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MKTEMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mktemp-ipk: $(MKTEMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mktemp-clean:
	-$(MAKE) -C $(MKTEMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mktemp-dirclean:
	rm -rf $(BUILD_DIR)/$(MKTEMP_DIR) $(MKTEMP_BUILD_DIR) $(MKTEMP_IPK_DIR) $(MKTEMP_IPK)
