###########################################################
#
# unslung-feeds-unstable
#
###########################################################

# You must replace "unslung-feeds-unstable" and "UNSLUNG-FEEDS-UNSTABLE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UNSLUNG-FEEDS-UNSTABLE_VERSION, UNSLUNG-FEEDS-UNSTABLE_SITE and UNSLUNG-FEEDS-UNSTABLE_SOURCE define
# the upstream location of the source code for the package.
# UNSLUNG-FEEDS-UNSTABLE_DIR is the directory which is created when the source
# archive is unpacked.
# UNSLUNG-FEEDS-UNSTABLE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
# Revison History
# 3.1 first mk file - two optware unstable feeds - combinations of cross and native

UNSLUNG-FEEDS-UNSTABLE_VERSION=3.1
UNSLUNG-FEEDS-UNSTABLE_SOURCE=Unslung CVS repository
UNSLUNG-FEEDS-UNSTABLE_DIR=unslung-feeds-unstable-$(UNSLUNG-FEEDS-UNSTABLE_VERSION)
UNSLUNG-FEEDS-UNSTABLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNSLUNG-FEEDS-UNSTABLE_DESCRIPTION=A list of sanctioned Unslung 'unstable' package feeds.
UNSLUNG-FEEDS-UNSTABLE_SECTION=base
UNSLUNG-FEEDS-UNSTABLE_PRIORITY=optional
UNSLUNG-FEEDS-UNSTABLE_DEPENDS=unslung-feeds
UNSLUNG-FEEDS-UNSTABLE_SUGGESTS=
UNSLUNG-FEEDS-UNSTABLE_CONFLICTS=

#
# UNSLUNG-FEEDS-UNSTABLE_IPK_VERSION should be incremented when the ipk changes.
#
UNSLUNG-FEEDS-UNSTABLE_IPK_VERSION=1

#
# UNSLUNG-FEEDS-UNSTABLE_CONFFILES should be a list of user-editable files
UNSLUNG-FEEDS-UNSTABLE_CONFFILES= \
			/etc/ipkg/optware-nslu2-cross-unstable.conf \
			/etc/ipkg/optware-nslu2-native-unstable.conf

#
# UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR is the directory in which the build is done.
# UNSLUNG-FEEDS-UNSTABLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNSLUNG-FEEDS-UNSTABLE_IPK_DIR is the directory in which the ipk is built.
# UNSLUNG-FEEDS-UNSTABLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR=$(BUILD_DIR)/unslung-feeds-unstable
UNSLUNG-FEEDS-UNSTABLE_SOURCE_DIR=$(SOURCE_DIR)/unslung-feeds-unstable
UNSLUNG-FEEDS-UNSTABLE_IPK_DIR=$(BUILD_DIR)/unslung-feeds-unstable-$(UNSLUNG-FEEDS-UNSTABLE_VERSION)-ipk
UNSLUNG-FEEDS-UNSTABLE_IPK=$(BUILD_DIR)/unslung-feeds-unstable_$(UNSLUNG-FEEDS-UNSTABLE_VERSION)-$(UNSLUNG-FEEDS-UNSTABLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unslung-feeds-unstable-source unslung-feeds-unstable-unpack unslung-feeds-unstable unslung-feeds-unstable-stage unslung-feeds-unstable-ipk unslung-feeds-unstable-clean unslung-feeds-unstable-dirclean unslung-feeds-unstable-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unslung-feeds-unstable-source:

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
$(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.configured:
	rm -rf $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)
	mkdir $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)
	touch $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.configured

unslung-feeds-unstable-unpack: $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.built: $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.configured
	rm -f $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.built
	touch $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
unslung-feeds-unstable: $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unslung-feeds-unstable
#
$(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: unslung-feeds-unstable" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNSLUNG-FEEDS-UNSTABLE_PRIORITY)" >>$@
	@echo "Section: $(UNSLUNG-FEEDS-UNSTABLE_SECTION)" >>$@
	@echo "Version: $(UNSLUNG-FEEDS-UNSTABLE_VERSION)-$(UNSLUNG-FEEDS-UNSTABLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNSLUNG-FEEDS-UNSTABLE_MAINTAINER)" >>$@
	@echo "Source: $(UNSLUNG-FEEDS-UNSTABLE_SOURCE)" >>$@
	@echo "Description: $(UNSLUNG-FEEDS-UNSTABLE_DESCRIPTION)" >>$@
	@echo "Depends: $(UNSLUNG-FEEDS-UNSTABLE_DEPENDS)" >>$@
	@echo "Suggests: $(UNSLUNG-FEEDS-UNSTABLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNSLUNG-FEEDS-UNSTABLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/opt/sbin or $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/opt/etc/unslung-feeds-unstable/...
# Documentation files should be installed in $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/opt/doc/unslung-feeds-unstable/...
# Daemon startup scripts should be installed in $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/opt/etc/init.d/S??unslung-feeds-unstable
#
# You may need to patch your application to make it use these locations.
#
$(UNSLUNG-FEEDS-UNSTABLE_IPK): $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR)/.built
	rm -rf $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR) $(BUILD_DIR)/unslung-feeds-unstable_*_$(TARGET_ARCH).ipk
	install -d $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/etc/ipkg
	install -m 755 $(UNSLUNG-FEEDS-UNSTABLE_SOURCE_DIR)/optware-nslu2-cross-unstable.conf $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/etc/ipkg/optware-nslu2-cross-unstable.conf
	install -m 755 $(UNSLUNG-FEEDS-UNSTABLE_SOURCE_DIR)/optware-nslu2-native-unstable.conf $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/etc/ipkg/optware-nslu2-native-unstable.conf
	$(MAKE) $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/CONTROL/control
#	install -m 644 $(UNSLUNG-FEEDS-UNSTABLE_SOURCE_DIR)/postinst $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/CONTROL/postinst
	install -m 644 $(UNSLUNG-FEEDS-UNSTABLE_SOURCE_DIR)/prerm $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/CONTROL/prerm
	echo $(UNSLUNG-FEEDS-UNSTABLE_CONFFILES) | sed -e 's/ /\n/g' > $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unslung-feeds-unstable-ipk: $(UNSLUNG-FEEDS-UNSTABLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unslung-feeds-unstable-clean:

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unslung-feeds-unstable-dirclean:
	rm -rf $(UNSLUNG-FEEDS-UNSTABLE_BUILD_DIR) $(UNSLUNG-FEEDS-UNSTABLE_IPK_DIR) $(UNSLUNG-FEEDS-UNSTABLE_IPK)


