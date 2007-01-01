###########################################################
#
# nethack
#
###########################################################

# You must replace "nethack" and "NETHACK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NETHACK_VERSION, NETHACK_SITE and NETHACK_SOURCE define
# the upstream location of the source code for the package.
# NETHACK_DIR is the directory which is created when the source
# archive is unpacked.
# NETHACK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NETHACK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nethack
NETHACK_VERSION=3.4.3
NETHACK_SOURCE=nethack-343-src.tgz
NETHACK_DIR=nethack-$(NETHACK_VERSION)
NETHACK_UNZIP=zcat
NETHACK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NETHACK_DESCRIPTION=The best text based RPG of all time.
NETHACK_SECTION=games
NETHACK_PRIORITY=optional
NETHACK_DEPENDS=ncurses
NETHACK_SUGGESTS=
NETHACK_CONFLICTS=

#
# NETHACK_IPK_VERSION should be incremented when the ipk changes.
#
NETHACK_IPK_VERSION=2

#
# NETHACK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NETHACK_PATCHES=$(NETHACK_SOURCE_DIR)/nethack_setup.patch $(NETHACK_SOURCE_DIR)/nethack_nslu2.patch
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETHACK_CPPFLAGS=-O -I../include
NETHACK_LDFLAGS=

#
# NETHACK_BUILD_DIR is the directory in which the build is done.
# NETHACK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETHACK_IPK_DIR is the directory in which the ipk is built.
# NETHACK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETHACK_BUILD_DIR=$(BUILD_DIR)/nethack
NETHACK_SOURCE_DIR=$(SOURCE_DIR)/nethack
NETHACK_IPK_DIR=$(BUILD_DIR)/nethack-$(NETHACK_VERSION)-ipk
NETHACK_IPK=$(BUILD_DIR)/nethack_$(NETHACK_VERSION)-$(NETHACK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nethack-source nethack-unpack nethack nethack-stage nethack-ipk nethack-clean nethack-dirclean nethack-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETHACK_SOURCE):
	$(WGET) -P $(DL_DIR) $(NETHACK_SITE)/$(NETHACK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nethack-source: $(DL_DIR)/$(NETHACK_SOURCE) $(NETHACK_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(NETHACK_BUILD_DIR)/.configured: $(DL_DIR)/$(NETHACK_SOURCE) $(NETHACK_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NETHACK_DIR) $(NETHACK_BUILD_DIR)
	$(NETHACK_UNZIP) $(DL_DIR)/$(NETHACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NETHACK_DIR) $(NETHACK_BUILD_DIR)
	patch -f -d $(NETHACK_BUILD_DIR)/sys/unix/ -p1 < $(NETHACK_SOURCE_DIR)/nethack_setup.patch
	chmod 766 $(NETHACK_BUILD_DIR)/sys/unix/setup.sh
	$(NETHACK_BUILD_DIR)/sys/unix/setup.sh
	patch -f -d $(NETHACK_BUILD_DIR) -p1 < $(NETHACK_SOURCE_DIR)/nethack_nslu2.patch
	touch $(NETHACK_BUILD_DIR)/.configured

nethack-unpack: $(NETHACK_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NETHACK_BUILD_DIR)/src/nethack: $(NETHACK_BUILD_DIR)/.configured
	make install -C $(NETHACK_BUILD_DIR) \
		CC=$(TARGET_CC) \
		AR=$(TARGET_AR) \
		RANLIB=$(TARGET_RANLIB) \
		CFLAGS="$(STAGING_CPPFLAGS) $(NETHACK_CPPFLAGS)" \
		LFLAGS="$(STAGING_LDFLAGS) $(NETHACK_LDFLAGS)" \
		PREFIX=$(NETHACK_BUILD_DIR)/install 

#
# You should change the dependency to refer directly to the main
# binary which is built.
#
nethack: $(NETHACK_BUILD_DIR)/src/nethack

$(NETHACK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nethack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETHACK_PRIORITY)" >>$@
	@echo "Section: $(NETHACK_SECTION)" >>$@
	@echo "Version: $(NETHACK_VERSION)-$(NETHACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETHACK_MAINTAINER)" >>$@
	@echo "Source: $(NETHACK_SITE)/$(NETHACK_SOURCE)" >>$@
	@echo "Description: $(NETHACK_DESCRIPTION)" >>$@
	@echo "Depends: $(NETHACK_DEPENDS)" >>$@
	@echo "Suggests: $(NETHACK_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETHACK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETHACK_IPK_DIR)/opt/sbin or $(NETHACK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETHACK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETHACK_IPK_DIR)/opt/etc/nethack/...
# Documentation files should be installed in $(NETHACK_IPK_DIR)/opt/doc/nethack/...
# Daemon startup scripts should be installed in $(NETHACK_IPK_DIR)/opt/etc/init.d/S??nethack
#
# You may need to patch your application to make it use these locations.
#
$(NETHACK_IPK): $(NETHACK_BUILD_DIR)/src/nethack
	install -d $(NETHACK_IPK_DIR)/opt/bin
	install -m 755 $(NETHACK_BUILD_DIR)/install/nethack $(NETHACK_IPK_DIR)/opt/bin/
	install -d $(NETHACK_IPK_DIR)/opt/share/nethackdir/
	cp -r $(NETHACK_BUILD_DIR)/install/nethackdir/* $(NETHACK_IPK_DIR)/opt/share/nethackdir/
	$(STRIP_COMMAND) \
		$(NETHACK_IPK_DIR)/opt/share/nethackdir/nethack \
		$(NETHACK_IPK_DIR)/opt/share/nethackdir/recover \
		$(NETHACK_IPK_DIR)/opt/share/nethackdir/util/*
	$(MAKE) $(NETHACK_IPK_DIR)/CONTROL/control
	install -m 755 $(NETHACK_SOURCE_DIR)/postinst $(NETHACK_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETHACK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nethack-ipk: $(NETHACK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nethack-clean:
	-$(MAKE) -C $(NETHACK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nethack-dirclean:
	rm -rf $(BUILD_DIR)/$(NETHACK_DIR) $(NETHACK_BUILD_DIR) $(NETHACK_IPK_DIR) $(NETHACK_IPK)

#
# Some sanity check for the package.
#
nethack-check: $(NETHACK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NETHACK_IPK)
