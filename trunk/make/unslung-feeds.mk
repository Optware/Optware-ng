###########################################################
#
# unslung-feeds
#
###########################################################

# You must replace "unslung-feeds" and "UNSLUNG-FEEDS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UNSLUNG-FEEDS_VERSION, UNSLUNG-FEEDS_SITE and UNSLUNG-FEEDS_SOURCE define
# the upstream location of the source code for the package.
# UNSLUNG-FEEDS_DIR is the directory which is created when the source
# archive is unpacked.
# UNSLUNG-FEEDS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
# Revison History
# 3.0 adds unslung-cross and unslung-native feeds
# 3.1 adds two additional stable optware feeds - combinations of cross and native

UNSLUNG-FEEDS_VERSION=3.1
UNSLUNG-FEEDS_SOURCE=Unslung CVS repository
UNSLUNG-FEEDS_DIR=unslung-feeds-$(UNSLUNG-FEEDS_VERSION)
UNSLUNG-FEEDS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNSLUNG-FEEDS_DESCRIPTION=A list of sanctioned Unslung package feeds.
UNSLUNG-FEEDS_SECTION=base
UNSLUNG-FEEDS_PRIORITY=optional
UNSLUNG-FEEDS_DEPENDS=
UNSLUNG-FEEDS_SUGGESTS=
UNSLUNG-FEEDS_CONFLICTS=

#
# UNSLUNG-FEEDS_IPK_VERSION should be incremented when the ipk changes.
#
UNSLUNG-FEEDS_IPK_VERSION=1

#
# UNSLUNG-FEEDS_CONFFILES should be a list of user-editable files
UNSLUNG-FEEDS_CONFFILES= \
			/etc/ipkg/unslung-cross.conf /etc/ipkg/unslung-native.conf \
			/etc/ipkg/optware-nslu2-cross-stable.conf \
			/etc/ipkg/optware-nslu2-native-stable.conf

#
# UNSLUNG-FEEDS_BUILD_DIR is the directory in which the build is done.
# UNSLUNG-FEEDS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNSLUNG-FEEDS_IPK_DIR is the directory in which the ipk is built.
# UNSLUNG-FEEDS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNSLUNG-FEEDS_BUILD_DIR=$(BUILD_DIR)/unslung-feeds
UNSLUNG-FEEDS_SOURCE_DIR=$(SOURCE_DIR)/unslung-feeds
UNSLUNG-FEEDS_IPK_DIR=$(BUILD_DIR)/unslung-feeds-$(UNSLUNG-FEEDS_VERSION)-ipk
UNSLUNG-FEEDS_IPK=$(BUILD_DIR)/unslung-feeds_$(UNSLUNG-FEEDS_VERSION)-$(UNSLUNG-FEEDS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unslung-feeds-source unslung-feeds-unpack unslung-feeds unslung-feeds-stage unslung-feeds-ipk unslung-feeds-clean unslung-feeds-dirclean unslung-feeds-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unslung-feeds-source:

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
$(UNSLUNG-FEEDS_BUILD_DIR)/.configured:
	rm -rf $(UNSLUNG-FEEDS_BUILD_DIR)
	mkdir $(UNSLUNG-FEEDS_BUILD_DIR)
	touch $(UNSLUNG-FEEDS_BUILD_DIR)/.configured

unslung-feeds-unpack: $(UNSLUNG-FEEDS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNSLUNG-FEEDS_BUILD_DIR)/.built: $(UNSLUNG-FEEDS_BUILD_DIR)/.configured
	rm -f $(UNSLUNG-FEEDS_BUILD_DIR)/.built
	touch $(UNSLUNG-FEEDS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
unslung-feeds: $(UNSLUNG-FEEDS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unslung-feeds
#
$(UNSLUNG-FEEDS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: unslung-feeds" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNSLUNG-FEEDS_PRIORITY)" >>$@
	@echo "Section: $(UNSLUNG-FEEDS_SECTION)" >>$@
	@echo "Version: $(UNSLUNG-FEEDS_VERSION)-$(UNSLUNG-FEEDS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNSLUNG-FEEDS_MAINTAINER)" >>$@
	@echo "Source: $(UNSLUNG-FEEDS_SOURCE)" >>$@
	@echo "Description: $(UNSLUNG-FEEDS_DESCRIPTION)" >>$@
	@echo "Depends: $(UNSLUNG-FEEDS_DEPENDS)" >>$@
	@echo "Suggests: $(UNSLUNG-FEEDS_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNSLUNG-FEEDS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNSLUNG-FEEDS_IPK_DIR)/opt/sbin or $(UNSLUNG-FEEDS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNSLUNG-FEEDS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNSLUNG-FEEDS_IPK_DIR)/opt/etc/unslung-feeds/...
# Documentation files should be installed in $(UNSLUNG-FEEDS_IPK_DIR)/opt/doc/unslung-feeds/...
# Daemon startup scripts should be installed in $(UNSLUNG-FEEDS_IPK_DIR)/opt/etc/init.d/S??unslung-feeds
#
# You may need to patch your application to make it use these locations.
#
$(UNSLUNG-FEEDS_IPK): $(UNSLUNG-FEEDS_BUILD_DIR)/.built
	rm -rf $(UNSLUNG-FEEDS_IPK_DIR) $(BUILD_DIR)/unslung-feeds_*_$(TARGET_ARCH).ipk
	install -d $(UNSLUNG-FEEDS_IPK_DIR)/etc/ipkg
	install -m 755 $(UNSLUNG-FEEDS_SOURCE_DIR)/unslung-cross.conf $(UNSLUNG-FEEDS_IPK_DIR)/etc/ipkg/unslung-cross.conf
	install -m 755 $(UNSLUNG-FEEDS_SOURCE_DIR)/unslung-native.conf $(UNSLUNG-FEEDS_IPK_DIR)/etc/ipkg/unslung-native.conf
	install -m 755 $(UNSLUNG-FEEDS_SOURCE_DIR)/optware-nslu2-cross-stable.conf $(UNSLUNG-FEEDS_IPK_DIR)/etc/ipkg/optware-nslu2-cross-stable.conf
	install -m 755 $(UNSLUNG-FEEDS_SOURCE_DIR)/optware-nslu2-native-stable.conf $(UNSLUNG-FEEDS_IPK_DIR)/etc/ipkg/optware-nslu2-native-stable.conf
	$(MAKE) $(UNSLUNG-FEEDS_IPK_DIR)/CONTROL/control
	install -m 644 $(UNSLUNG-FEEDS_SOURCE_DIR)/postinst $(UNSLUNG-FEEDS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(UNSLUNG-FEEDS_SOURCE_DIR)/prerm $(UNSLUNG-FEEDS_IPK_DIR)/CONTROL/prerm
	echo $(UNSLUNG-FEEDS_CONFFILES) | sed -e 's/ /\n/g' > $(UNSLUNG-FEEDS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNSLUNG-FEEDS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unslung-feeds-ipk: $(UNSLUNG-FEEDS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unslung-feeds-clean:

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unslung-feeds-dirclean:
	rm -rf $(UNSLUNG-FEEDS_BUILD_DIR) $(UNSLUNG-FEEDS_IPK_DIR) $(UNSLUNG-FEEDS_IPK)


