###########################################################
#
# extract-xiso
#
###########################################################

# You must replace "<foo>" and "<FOO>" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# EXTRACT-XISO_VERSION, EXTRACT-XISO_SITE and EXTRACT-XISO_SOURCE define
# the upstream location of the source code for the package.
# EXTRACT-XISO_DIR is the directory which is created when the source
# archive is unpacked.
# EXTRACT-XISO_UNZIP is the command used to unzip the source.
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
EXTRACT-XISO_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/extract-xiso
EXTRACT-XISO_VERSION=2.5
EXTRACT-XISO_SOURCE=extract-xiso_v$(EXTRACT-XISO_VERSION)_src.tgz
EXTRACT-XISO_DIR=extract-xiso
EXTRACT-XISO_UNZIP=zcat
EXTRACT-XISO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EXTRACT-XISO_DESCRIPTION=Extract-xiso is the premier backup tool for creating and extracting disc image .iso's of XBox games.
EXTRACT-XISO_SECTION=misc
EXTRACT-XISO_PRIORITY=optional
EXTRACT-XISO_DEPENDS=
EXTRACT-XISO_SUGGESTS=
EXTRACT-XISO_CONFLICTS=

#
# EXTRACT-XISO_IPK_VERSION should be incremented when the ipk changes.
#
EXTRACT-XISO_IPK_VERSION=1

#
# EXTRACT-XISO_CONFFILES should be a list of user-editable files
EXTRACT-XISO_CONFFILES=

#
# EXTRACT-XISO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EXTRACT-XISO_PATCHES=$(EXTRACT-XISO_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EXTRACT-XISO_CPPFLAGS=
EXTRACT-XISO_LDFLAGS=

#
# EXTRACT-XISO_BUILD_DIR is the directory in which the build is done.
# EXTRACT-XISO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EXTRACT-XISO_IPK_DIR is the directory in which the ipk is built.
# EXTRACT-XISO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EXTRACT-XISO_BUILD_DIR=$(BUILD_DIR)/extract-xiso
EXTRACT-XISO_SOURCE_DIR=$(SOURCE_DIR)/extract-xiso
EXTRACT-XISO_IPK_DIR=$(BUILD_DIR)/extract-xiso-$(EXTRACT-XISO_VERSION)-ipk
EXTRACT-XISO_IPK=$(BUILD_DIR)/extract-xiso_$(EXTRACT-XISO_VERSION)-$(EXTRACT-XISO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EXTRACT-XISO_SOURCE):
	$(WGET) -P $(DL_DIR) $(EXTRACT-XISO_SITE)/$(EXTRACT-XISO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
extract-xiso-source: $(DL_DIR)/$(EXTRACT-XISO_SOURCE) $(EXTRACT-XISO_PATCHES)

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
$(EXTRACT-XISO_BUILD_DIR)/.configured: $(DL_DIR)/$(EXTRACT-XISO_SOURCE) $(EXTRACT-XISO_PATCHES) make/extract-xiso.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(EXTRACT-XISO_DIR) $(EXTRACT-XISO_BUILD_DIR)
	$(EXTRACT-XISO_UNZIP) $(DL_DIR)/$(EXTRACT-XISO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EXTRACT-XISO_PATCHES)" ; \
		then cat $(EXTRACT-XISO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EXTRACT-XISO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EXTRACT-XISO_DIR)" != "$(EXTRACT-XISO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(EXTRACT-XISO_DIR) $(EXTRACT-XISO_BUILD_DIR) ; \
	fi
	(cd $(EXTRACT-XISO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EXTRACT-XISO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXTRACT-XISO_LDFLAGS)" )
	touch $(EXTRACT-XISO_BUILD_DIR)/.configured

extract-xiso-unpack: $(EXTRACT-XISO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EXTRACT-XISO_BUILD_DIR)/.built: $(EXTRACT-XISO_BUILD_DIR)/.configured
	rm -f $(EXTRACT-XISO_BUILD_DIR)/.built
	$(MAKE) -C $(EXTRACT-XISO_BUILD_DIR) -e $(TARGET_CONFIGURE_OPTS)
	touch $(EXTRACT-XISO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
extract-xiso: $(EXTRACT-XISO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EXTRACT-XISO_BUILD_DIR)/.staged: $(EXTRACT-XISO_BUILD_DIR)/.built
	rm -f $(EXTRACT-XISO_BUILD_DIR)/.staged
	$(MAKE) -C $(EXTRACT-XISO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(EXTRACT-XISO_BUILD_DIR)/.staged

extract-xiso-stage: $(EXTRACT-XISO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/extract-xiso
#
$(EXTRACT-XISO_IPK_DIR)/CONTROL/control:
	@install -d $(EXTRACT-XISO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: extract-xiso" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EXTRACT-XISO_PRIORITY)" >>$@
	@echo "Section: $(EXTRACT-XISO_SECTION)" >>$@
	@echo "Version: $(EXTRACT-XISO_VERSION)-$(EXTRACT-XISO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EXTRACT-XISO_MAINTAINER)" >>$@
	@echo "Source: $(EXTRACT-XISO_SITE)/$(EXTRACT-XISO_SOURCE)" >>$@
	@echo "Description: $(EXTRACT-XISO_DESCRIPTION)" >>$@
	@echo "Depends: $(EXTRACT-XISO_DEPENDS)" >>$@
	@echo "Suggests: $(EXTRACT-XISO_SUGGESTS)" >>$@
	@echo "Conflicts: $(EXTRACT-XISO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EXTRACT-XISO_IPK_DIR)/opt/sbin or $(EXTRACT-XISO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EXTRACT-XISO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EXTRACT-XISO_IPK_DIR)/opt/etc/extract-xiso/...
# Documentation files should be installed in $(EXTRACT-XISO_IPK_DIR)/opt/doc/extract-xiso/...
# Daemon startup scripts should be installed in $(EXTRACT-XISO_IPK_DIR)/opt/etc/init.d/S??extract-xiso
#
# You may need to patch your application to make it use these locations.
#
$(EXTRACT-XISO_IPK): $(EXTRACT-XISO_BUILD_DIR)/.built
	rm -rf $(EXTRACT-XISO_IPK_DIR) $(BUILD_DIR)/extract-xiso_*_$(TARGET_ARCH).ipk
	install -d $(EXTRACT-XISO_IPK_DIR)/opt/bin/
	install -m 755 $(EXTRACT-XISO_BUILD_DIR)/extract-xiso $(EXTRACT-XISO_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(EXTRACT-XISO_BUILD_DIR)/extract-xiso -o $(EXTRACT-XISO_IPK_DIR)/opt/bin/extract-xiso
	$(MAKE) $(EXTRACT-XISO_IPK_DIR)/CONTROL/control
	echo $(EXTRACT-XISO_CONFFILES) | sed -e 's/ /\n/g' > $(EXTRACT-XISO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EXTRACT-XISO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
extract-xiso-ipk: $(EXTRACT-XISO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
extract-xiso-clean:
	rm -f $(EXTRACT-XISO_BUILD_DIR)/.built
	-$(MAKE) -C $(EXTRACT-XISO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
extract-xiso-dirclean:
	rm -rf $(BUILD_DIR)/$(EXTRACT-XISO_DIR) $(EXTRACT-XISO_BUILD_DIR) $(EXTRACT-XISO_IPK_DIR) $(EXTRACT-XISO_IPK)
