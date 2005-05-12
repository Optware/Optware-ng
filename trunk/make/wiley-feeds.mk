###########################################################
#
# wiley-feeds
#
###########################################################

# You must replace "wiley-feeds" and "WILEY-FEEDS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WILEY-FEEDS_VERSION, WILEY-FEEDS_SITE and WILEY-FEEDS_SOURCE define
# the upstream location of the source code for the package.
# WILEY-FEEDS_DIR is the directory which is created when the source
# archive is unpacked.
# WILEY-FEEDS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
WILEY-FEEDS_VERSION=1.0
WILEY-FEEDS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WILEY-FEEDS_DESCRIPTION=A list of sanctioned Unslung package feeds.
WILEY-FEEDS_SECTION=base
WILEY-FEEDS_PRIORITY=optional
WILEY-FEEDS_DEPENDS=
WILEY-FEEDS_CONFLICTS=

#
# WILEY-FEEDS_IPK_VERSION should be incremented when the ipk changes.
#
WILEY-FEEDS_IPK_VERSION=1

#
# WILEY-FEEDS_CONFFILES should be a list of user-editable files
#WILEY-FEEDS_CONFFILES=

#
# WILEY-FEEDS_BUILD_DIR is the directory in which the build is done.
# WILEY-FEEDS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WILEY-FEEDS_IPK_DIR is the directory in which the ipk is built.
# WILEY-FEEDS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WILEY-FEEDS_BUILD_DIR=$(BUILD_DIR)/wiley-feeds
WILEY-FEEDS_SOURCE_DIR=$(SOURCE_DIR)/wiley-feeds
WILEY-FEEDS_IPK_DIR=$(BUILD_DIR)/wiley-feeds-$(WILEY-FEEDS_VERSION)-ipk
WILEY-FEEDS_IPK=$(BUILD_DIR)/wiley-feeds_$(WILEY-FEEDS_VERSION)-$(WILEY-FEEDS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wiley-feeds-source:

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
$(WILEY-FEEDS_BUILD_DIR)/.configured:
	rm -rf $(WILEY-FEEDS_BUILD_DIR)
	mkdir $(WILEY-FEEDS_BUILD_DIR)
	touch $(WILEY-FEEDS_BUILD_DIR)/.configured

wiley-feeds-unpack: $(WILEY-FEEDS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WILEY-FEEDS_BUILD_DIR)/.built: $(WILEY-FEEDS_BUILD_DIR)/.configured
	rm -f $(WILEY-FEEDS_BUILD_DIR)/.built
	touch $(WILEY-FEEDS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
wiley-feeds: $(WILEY-FEEDS_BUILD_DIR)/.built

$(WILEY-FEEDS_IPK_DIR)/CONTROL/control:
	@install -d $(WILEY-FEEDS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: wiley-feeds" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WILEY-FEEDS_PRIORITY)" >>$@
	@echo "Section: $(WILEY-FEEDS_SECTION)" >>$@
	@echo "Version: $(WILEY-FEEDS_VERSION)-$(WILEY-FEEDS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WILEY-FEEDS_MAINTAINER)" >>$@
	@echo "Source: $(WILEY-FEEDS_SITE)/$(WILEY-FEEDS_SOURCE)" >>$@
	@echo "Description: $(WILEY-FEEDS_DESCRIPTION)" >>$@
	@echo "Depends: $(WILEY-FEEDS_DEPENDS)" >>$@
	@echo "Conflicts: $(WILEY-FEEDS_CONFLICTS)" >>$@
#
# This builds the IPK file.
#
# Binaries should be installed into $(WILEY-FEEDS_IPK_DIR)/opt/sbin or $(WILEY-FEEDS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WILEY-FEEDS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WILEY-FEEDS_IPK_DIR)/opt/etc/wiley-feeds/...
# Documentation files should be installed in $(WILEY-FEEDS_IPK_DIR)/opt/doc/wiley-feeds/...
# Daemon startup scripts should be installed in $(WILEY-FEEDS_IPK_DIR)/opt/etc/init.d/S??wiley-feeds
#
# You may need to patch your application to make it use these locations.
#
$(WILEY-FEEDS_IPK): $(WILEY-FEEDS_BUILD_DIR)/.built
	rm -rf $(WILEY-FEEDS_IPK_DIR) $(BUILD_DIR)/wiley-feeds_*_$(TARGET_ARCH).ipk
	install -d $(WILEY-FEEDS_IPK_DIR)/opt/etc
	$(MAKE) $(WILEY-FEEDS_IPK_DIR)/CONTROL/control
	install -m 644 $(WILEY-FEEDS_SOURCE_DIR)/postinst $(WILEY-FEEDS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(WILEY-FEEDS_SOURCE_DIR)/prerm $(WILEY-FEEDS_IPK_DIR)/CONTROL/prerm
	#echo $(WILEY-FEEDS_CONFFILES) | sed -e 's/ /\n/g' > $(WILEY-FEEDS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WILEY-FEEDS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wiley-feeds-ipk: $(WILEY-FEEDS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wiley-feeds-clean:

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wiley-feeds-dirclean:
	rm -rf $(WILEY-FEEDS_BUILD_DIR) $(WILEY-FEEDS_IPK_DIR) $(WILEY-FEEDS_IPK)
