###########################################################
#
# ldconfig
#
###########################################################

# You must replace "ldconfig" and "LDCONFIG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LDCONFIG_VERSION, LDCONFIG_SITE and LDCONFIG_SOURCE define
# the upstream location of the source code for the package.
# LDCONFIG_DIR is the directory which is created when the source
# archive is unpacked.
# LDCONFIG_UNZIP is the command used to unzip the source.
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
LDCONFIG_VERSION=2.2.5
LDCONFIG_SOURCE=toolchain
LDCONFIG_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
LDCONFIG_DESCRIPTION=Builds ld.so.cache, which is used to speed up dynamic linking and to configure a system-wide library search path.
LDCONFIG_SECTION=base
LDCONFIG_PRIORITY=optional
LDCONFIG_DEPENDS=
LDCONFIG_SUGGESTS=
LDCONFIG_CONFLICTS=

LDCONFIG_IPK_VERSION=1

LDCONFIG_CONFFILES=/opt/etc/ld.so.conf

LDCONFIG_BUILD_DIR=$(BUILD_DIR)/ldconfig
LDCONFIG_SOURCE_DIR=$(SOURCE_DIR)/ldconfig
LDCONFIG_IPK_DIR=$(BUILD_DIR)/ldconfig-$(LDCONFIG_VERSION)-ipk
LDCONFIG_IPK=$(BUILD_DIR)/ldconfig_$(LDCONFIG_VERSION)-$(LDCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

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
$(LDCONFIG_BUILD_DIR)/.configured:
	rm -rf $(LDCONFIG_BUILD_DIR)
	mkdir -p $(LDCONFIG_BUILD_DIR)
	touch $(LDCONFIG_BUILD_DIR)/.configured

ldconfig-unpack: $(LDCONFIG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LDCONFIG_BUILD_DIR)/.built: $(LDCONFIG_BUILD_DIR)/.configured
	rm -f $(LDCONFIG_BUILD_DIR)/.built
	cp $(CROSSTOOL_BUILD_DIR)/build/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/build-glibc/elf/* $(LDCONFIG_BUILD_DIR)
	( \
		cd $(LDCONFIG_BUILD_DIR); \
		$(TARGET_CC) -o $(LDCONFIG_BUILD_DIR)/ldconfig \
			ldconfig.o cache.o xmalloc.o xstrdup.o readlib.o \
			chroot_canon.o dl-procinfo.o \
	)
	touch $(LDCONFIG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ldconfig: $(LDCONFIG_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ldconfig
#
$(LDCONFIG_IPK_DIR)/CONTROL/control:
	@install -d $(LDCONFIG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ldconfig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LDCONFIG_PRIORITY)" >>$@
	@echo "Section: $(LDCONFIG_SECTION)" >>$@
	@echo "Version: $(LDCONFIG_VERSION)-$(LDCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LDCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(LDCONFIG_SITE)/$(LDCONFIG_SOURCE)" >>$@
	@echo "Description: $(LDCONFIG_DESCRIPTION)" >>$@
	@echo "Depends: $(LDCONFIG_DEPENDS)" >>$@
	@echo "Suggests: $(LDCONFIG_SUGGESTS)" >>$@
	@echo "Conflicts: $(LDCONFIG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LDCONFIG_IPK_DIR)/opt/sbin or $(LDCONFIG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LDCONFIG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LDCONFIG_IPK_DIR)/opt/etc/ldconfig/...
# Documentation files should be installed in $(LDCONFIG_IPK_DIR)/opt/doc/ldconfig/...
# Daemon startup scripts should be installed in $(LDCONFIG_IPK_DIR)/opt/etc/init.d/S??ldconfig
#
# You may need to patch your application to make it use these locations.
#
$(LDCONFIG_IPK): $(LDCONFIG_BUILD_DIR)/.built
	rm -rf $(LDCONFIG_IPK_DIR) $(BUILD_DIR)/ldconfig_*_$(TARGET_ARCH).ipk
	install -d $(LDCONFIG_IPK_DIR)/opt/bin
	install -d $(LDCONFIG_IPK_DIR)/opt/sbin
	install -m 755 $(LDCONFIG_BUILD_DIR)/ldd $(LDCONFIG_IPK_DIR)/opt/bin/ldd
	install -m 755 $(LDCONFIG_SOURCE_DIR)/ldconfig.wrapper $(LDCONFIG_IPK_DIR)/opt/sbin/ldconfig
	$(STRIP_COMMAND) $(LDCONFIG_BUILD_DIR)/ldconfig -o $(LDCONFIG_IPK_DIR)/opt/sbin/ldconfig.bin
	$(STRIP_COMMAND) $(LDCONFIG_BUILD_DIR)/sprof -o $(LDCONFIG_IPK_DIR)/opt/bin/sprof
	install -d $(LDCONFIG_IPK_DIR)/opt/etc/
	install -m 644 $(LDCONFIG_SOURCE_DIR)/ld.so.conf $(LDCONFIG_IPK_DIR)/opt/etc/ld.so.conf
	install -d $(LDCONFIG_IPK_DIR)/opt/etc/init.d
	install -m 755 $(LDCONFIG_SOURCE_DIR)/postinst $(LDCONFIG_IPK_DIR)/opt/etc/init.d/S03ldconfig
	$(MAKE) $(LDCONFIG_IPK_DIR)/CONTROL/control
	install -m 755 $(LDCONFIG_SOURCE_DIR)/postinst $(LDCONFIG_IPK_DIR)/CONTROL/postinst
	echo $(LDCONFIG_CONFFILES) | sed -e 's/ /\n/g' > $(LDCONFIG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LDCONFIG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ldconfig-ipk: $(LDCONFIG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ldconfig-clean:
	rm -f $(LDCONFIG_BUILD_DIR)/*

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ldconfig-dirclean:
	rm -rf $(LDCONFIG_BUILD_DIR) $(LDCONFIG_IPK_DIR) $(LDCONFIG_IPK)
