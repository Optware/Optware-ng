###########################################################
#
# textutils
#
###########################################################

# You must replace "textutils" and "TEXTUTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TEXTUTILS_VERSION, TEXTUTILS_SITE and TEXTUTILS_SOURCE define
# the upstream location of the source code for the package.
# TEXTUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# TEXTUTILS_UNZIP is the command used to unzip the source.
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
TEXTUTILS_SITE=http://ftp.gnu.org/pub/gnu/textutils
TEXTUTILS_VERSION=2.1
TEXTUTILS_SOURCE=textutils-$(TEXTUTILS_VERSION).tar.gz
TEXTUTILS_DIR=textutils-$(TEXTUTILS_VERSION)
TEXTUTILS_UNZIP=zcat
TEXTUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TEXTUTILS_DESCRIPTION=GNU Text Utilities
TEXTUTILS_SECTION=util
TEXTUTILS_PRIORITY=optional
TEXTUTILS_DEPENDS=
TEXTUTILS_CONFLICTS=

#
# TEXTUTILS_IPK_VERSION should be incremented when the ipk changes.
#
TEXTUTILS_IPK_VERSION=5

#
# TEXTUTILS_CONFFILES should be a list of user-editable files
TEXTUTILS_CONFFILES=

#
# TEXTUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TEXTUTILS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TEXTUTILS_CPPFLAGS=
TEXTUTILS_LDFLAGS=

#
# TEXTUTILS_BUILD_DIR is the directory in which the build is done.
# TEXTUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TEXTUTILS_IPK_DIR is the directory in which the ipk is built.
# TEXTUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TEXTUTILS_BUILD_DIR=$(BUILD_DIR)/textutils
TEXTUTILS_SOURCE_DIR=$(SOURCE_DIR)/textutils
TEXTUTILS_IPK_DIR=$(BUILD_DIR)/textutils-$(TEXTUTILS_VERSION)-ipk
TEXTUTILS_IPK=$(BUILD_DIR)/textutils_$(TEXTUTILS_VERSION)-$(TEXTUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TEXTUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(TEXTUTILS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
textutils-source: $(DL_DIR)/$(TEXTUTILS_SOURCE) $(TEXTUTILS_PATCHES)

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
$(TEXTUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(TEXTUTILS_SOURCE) $(TEXTUTILS_PATCHES) make/textutils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TEXTUTILS_DIR) $(TEXTUTILS_BUILD_DIR)
	$(TEXTUTILS_UNZIP) $(DL_DIR)/$(TEXTUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(TEXTUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(TEXTUTILS_DIR) -p1
	mv $(BUILD_DIR)/$(TEXTUTILS_DIR) $(TEXTUTILS_BUILD_DIR)
	sed -i -e '/\*malloc *()/d' $(TEXTUTILS_BUILD_DIR)/lib/putenv.c
	(cd $(TEXTUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TEXTUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TEXTUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(TEXTUTILS_BUILD_DIR)/.configured

textutils-unpack: $(TEXTUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TEXTUTILS_BUILD_DIR)/.built: $(TEXTUTILS_BUILD_DIR)/.configured
	rm -f $(TEXTUTILS_BUILD_DIR)/.built
	$(MAKE) -C $(TEXTUTILS_BUILD_DIR)
	touch $(TEXTUTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
textutils: $(TEXTUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TEXTUTILS_BUILD_DIR)/.staged: $(TEXTUTILS_BUILD_DIR)/.built
	rm -f $(TEXTUTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(TEXTUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TEXTUTILS_BUILD_DIR)/.staged

textutils-stage: $(TEXTUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/textutils
#
$(TEXTUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(TEXTUTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: textutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TEXTUTILS_PRIORITY)" >>$@
	@echo "Section: $(TEXTUTILS_SECTION)" >>$@
	@echo "Version: $(TEXTUTILS_VERSION)-$(TEXTUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TEXTUTILS_MAINTAINER)" >>$@
	@echo "Source: $(TEXTUTILS_SITE)/$(TEXTUTILS_SOURCE)" >>$@
	@echo "Description: $(TEXTUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(TEXTUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(TEXTUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TEXTUTILS_IPK_DIR)/opt/sbin or $(TEXTUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TEXTUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TEXTUTILS_IPK_DIR)/opt/etc/textutils/...
# Documentation files should be installed in $(TEXTUTILS_IPK_DIR)/opt/doc/textutils/...
# Daemon startup scripts should be installed in $(TEXTUTILS_IPK_DIR)/opt/etc/init.d/S??textutils
#
# You may need to patch your application to make it use these locations.
#
$(TEXTUTILS_IPK): $(TEXTUTILS_BUILD_DIR)/.built
	rm -rf $(TEXTUTILS_IPK_DIR) $(BUILD_DIR)/textutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TEXTUTILS_BUILD_DIR) DESTDIR=$(TEXTUTILS_IPK_DIR) install-strip
	$(MAKE) $(TEXTUTILS_IPK_DIR)/CONTROL/control
	echo $(TEXTUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(TEXTUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TEXTUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
textutils-ipk: $(TEXTUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
textutils-clean:
	-$(MAKE) -C $(TEXTUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
textutils-dirclean:
	rm -rf $(BUILD_DIR)/$(TEXTUTILS_DIR) $(TEXTUTILS_BUILD_DIR) $(TEXTUTILS_IPK_DIR) $(TEXTUTILS_IPK)
