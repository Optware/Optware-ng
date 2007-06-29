###########################################################
#
# dialog
#
###########################################################
#
# DIALOG_VERSION, DIALOG_SITE and DIALOG_SOURCE define
# the upstream location of the source code for the package.
# DIALOG_DIR is the directory which is created when the source
# archive is unpacked.
# DIALOG_UNZIP is the command used to unzip the source.
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
DIALOG_SITE=ftp://invisible-island.net/dialog
DIALOG_VERSION=1.1-20070604
DIALOG_SOURCE=dialog-$(DIALOG_VERSION).tgz
DIALOG_DIR=dialog-$(DIALOG_VERSION)
DIALOG_UNZIP=zcat
DIALOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DIALOG_DESCRIPTION=Script-driven curses widgets.
DIALOG_SECTION=console
DIALOG_PRIORITY=optional
DIALOG_DEPENDS=$(NCURSES_FOR_OPTWARE_TARGET)
DIALOG_SUGGESTS=
DIALOG_CONFLICTS=

#
# DIALOG_IPK_VERSION should be incremented when the ipk changes.
#
DIALOG_IPK_VERSION=1

#
# DIALOG_CONFFILES should be a list of user-editable files
#DIALOG_CONFFILES=/opt/etc/dialog.conf /opt/etc/init.d/SXXdialog

#
# DIALOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DIALOG_PATCHES=$(DIALOG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIALOG_CPPFLAGS=
DIALOG_LDFLAGS=

#
# DIALOG_BUILD_DIR is the directory in which the build is done.
# DIALOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIALOG_IPK_DIR is the directory in which the ipk is built.
# DIALOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIALOG_BUILD_DIR=$(BUILD_DIR)/dialog
DIALOG_SOURCE_DIR=$(SOURCE_DIR)/dialog
DIALOG_IPK_DIR=$(BUILD_DIR)/dialog-$(DIALOG_VERSION)-ipk
DIALOG_IPK=$(BUILD_DIR)/dialog_$(DIALOG_VERSION)-$(DIALOG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dialog-source dialog-unpack dialog dialog-stage dialog-ipk dialog-clean dialog-dirclean dialog-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DIALOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(DIALOG_SITE)/$(DIALOG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DIALOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dialog-source: $(DL_DIR)/$(DIALOG_SOURCE) $(DIALOG_PATCHES)

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
$(DIALOG_BUILD_DIR)/.configured: $(DL_DIR)/$(DIALOG_SOURCE) $(DIALOG_PATCHES) make/dialog.mk
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	rm -rf $(BUILD_DIR)/$(DIALOG_DIR) $(DIALOG_BUILD_DIR)
	$(DIALOG_UNZIP) $(DL_DIR)/$(DIALOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DIALOG_PATCHES)" ; \
		then cat $(DIALOG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DIALOG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DIALOG_DIR)" != "$(DIALOG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DIALOG_DIR) $(DIALOG_BUILD_DIR) ; \
	fi
	(cd $(DIALOG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DIALOG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DIALOG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^LIBS/s| -L/lib||' $(DIALOG_BUILD_DIR)/makefile
#	$(PATCH_LIBTOOL) $(DIALOG_BUILD_DIR)/libtool
	touch $@

dialog-unpack: $(DIALOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DIALOG_BUILD_DIR)/.built: $(DIALOG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DIALOG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
dialog: $(DIALOG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DIALOG_BUILD_DIR)/.staged: $(DIALOG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DIALOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

dialog-stage: $(DIALOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dialog
#
$(DIALOG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dialog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIALOG_PRIORITY)" >>$@
	@echo "Section: $(DIALOG_SECTION)" >>$@
	@echo "Version: $(DIALOG_VERSION)-$(DIALOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIALOG_MAINTAINER)" >>$@
	@echo "Source: $(DIALOG_SITE)/$(DIALOG_SOURCE)" >>$@
	@echo "Description: $(DIALOG_DESCRIPTION)" >>$@
	@echo "Depends: $(DIALOG_DEPENDS)" >>$@
	@echo "Suggests: $(DIALOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(DIALOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIALOG_IPK_DIR)/opt/sbin or $(DIALOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIALOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DIALOG_IPK_DIR)/opt/etc/dialog/...
# Documentation files should be installed in $(DIALOG_IPK_DIR)/opt/doc/dialog/...
# Daemon startup scripts should be installed in $(DIALOG_IPK_DIR)/opt/etc/init.d/S??dialog
#
# You may need to patch your application to make it use these locations.
#
$(DIALOG_IPK): $(DIALOG_BUILD_DIR)/.built
	rm -rf $(DIALOG_IPK_DIR) $(BUILD_DIR)/dialog_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DIALOG_BUILD_DIR) DESTDIR=$(DIALOG_IPK_DIR) install
	$(STRIP_COMMAND) $(DIALOG_IPK_DIR)/opt/bin/dialog
#	install -d $(DIALOG_IPK_DIR)/opt/etc/
#	install -m 644 $(DIALOG_SOURCE_DIR)/dialog.conf $(DIALOG_IPK_DIR)/opt/etc/dialog.conf
#	install -d $(DIALOG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DIALOG_SOURCE_DIR)/rc.dialog $(DIALOG_IPK_DIR)/opt/etc/init.d/SXXdialog
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DIALOG_IPK_DIR)/opt/etc/init.d/SXXdialog
	$(MAKE) $(DIALOG_IPK_DIR)/CONTROL/control
#	install -m 755 $(DIALOG_SOURCE_DIR)/postinst $(DIALOG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DIALOG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DIALOG_SOURCE_DIR)/prerm $(DIALOG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DIALOG_IPK_DIR)/CONTROL/prerm
	echo $(DIALOG_CONFFILES) | sed -e 's/ /\n/g' > $(DIALOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIALOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dialog-ipk: $(DIALOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dialog-clean:
	rm -f $(DIALOG_BUILD_DIR)/.built
	-$(MAKE) -C $(DIALOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dialog-dirclean:
	rm -rf $(BUILD_DIR)/$(DIALOG_DIR) $(DIALOG_BUILD_DIR) $(DIALOG_IPK_DIR) $(DIALOG_IPK)
#
#
# Some sanity check for the package.
#
dialog-check: $(DIALOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DIALOG_IPK)
