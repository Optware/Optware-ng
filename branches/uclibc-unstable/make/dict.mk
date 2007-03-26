###########################################################
#
# dict
#
###########################################################

# You must replace "dict" and "DICT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DICT_VERSION, DICT_SITE and DICT_SOURCE define
# the upstream location of the source code for the package.
# DICT_DIR is the directory which is created when the source
# archive is unpacked.
# DICT_UNZIP is the command used to unzip the source.
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
DICT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dict
DICT_VERSION=1.10.7
DICT_SOURCE=dictd-$(DICT_VERSION).tar.gz
DICT_DIR=dictd-$(DICT_VERSION)
DICT_UNZIP=zcat
DICT_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
DICT_DESCRIPTION=DICT Protocol (RFC 2229) Client.
DICT_SECTION=text
DICT_PRIORITY=optional
DICT_DEPENDS=

#
# DICT_IPK_VERSION should be incremented when the ipk changes.
#
DICT_IPK_VERSION=1

#
# DICT_CONFFILES should be a list of user-editable files
DICT_CONFFILES=/opt/etc/dict.conf

#
# DICT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DICT_PATCHES=$(DICT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DICT_CPPFLAGS=
DICT_LDFLAGS=

#
# DICT_BUILD_DIR is the directory in which the build is done.
# DICT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DICT_IPK_DIR is the directory in which the ipk is built.
# DICT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DICT_BUILD_DIR=$(BUILD_DIR)/dict
DICT_SOURCE_DIR=$(SOURCE_DIR)/dict
DICT_IPK_DIR=$(BUILD_DIR)/dict-$(DICT_VERSION)-ipk
DICT_IPK=$(BUILD_DIR)/dict_$(DICT_VERSION)-$(DICT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DICT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DICT_SITE)/$(DICT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dict-source: $(DL_DIR)/$(DICT_SOURCE) $(DICT_PATCHES)

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
$(DICT_BUILD_DIR)/.configured: $(DL_DIR)/$(DICT_SOURCE) $(DICT_PATCHES)
	rm -rf $(BUILD_DIR)/$(DICT_DIR) $(DICT_BUILD_DIR)
	$(DICT_UNZIP) $(DL_DIR)/$(DICT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(DICT_DIR) $(DICT_BUILD_DIR)
	(cd $(DICT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DICT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DICT_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(DICT_BUILD_DIR)/.configured

dict-unpack: $(DICT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DICT_BUILD_DIR)/.built: $(DICT_BUILD_DIR)/.configured
	rm -f $(DICT_BUILD_DIR)/.built
	$(MAKE) -C $(DICT_BUILD_DIR) dict
	touch $(DICT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dict: $(DICT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DICT_BUILD_DIR)/.staged: $(DICT_BUILD_DIR)/.built
	rm -f $(DICT_BUILD_DIR)/.staged
	$(MAKE) -C $(DICT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install.dict
	touch $(DICT_BUILD_DIR)/.staged

dict-stage: $(DICT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dict
#
$(DICT_IPK_DIR)/CONTROL/control:
	@install -d $(DICT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dict" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DICT_PRIORITY)" >>$@
	@echo "Section: $(DICT_SECTION)" >>$@
	@echo "Version: $(DICT_VERSION)-$(DICT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DICT_MAINTAINER)" >>$@
	@echo "Source: $(DICT_SITE)/$(DICT_SOURCE)" >>$@
	@echo "Description: $(DICT_DESCRIPTION)" >>$@
	@echo "Depends: $(DICT_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DICT_IPK_DIR)/opt/sbin or $(DICT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DICT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DICT_IPK_DIR)/opt/etc/dict/...
# Documentation files should be installed in $(DICT_IPK_DIR)/opt/doc/dict/...
# Daemon startup scripts should be installed in $(DICT_IPK_DIR)/opt/etc/init.d/S??dict
#
# You may need to patch your application to make it use these locations.
#
$(DICT_IPK): $(DICT_BUILD_DIR)/.built
	rm -rf $(DICT_IPK_DIR) $(BUILD_DIR)/dict_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DICT_BUILD_DIR) DESTDIR=$(DICT_IPK_DIR) install.dict
	$(STRIP_COMMAND) $(DICT_IPK_DIR)/opt/bin/dict
	install -d $(DICT_IPK_DIR)/opt/etc/
	install -m 644 $(DICT_SOURCE_DIR)/dict.conf $(DICT_IPK_DIR)/opt/etc/dict.conf
	$(MAKE) $(DICT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DICT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dict-ipk: $(DICT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dict-clean:
	-$(MAKE) -C $(DICT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dict-dirclean:
	rm -rf $(BUILD_DIR)/$(DICT_DIR) $(DICT_BUILD_DIR) $(DICT_IPK_DIR) $(DICT_IPK)
