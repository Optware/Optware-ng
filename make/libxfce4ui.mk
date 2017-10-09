###########################################################
#
# libxfce4ui
#
###########################################################

# You must replace "libxfce4ui" and "LIBXFCE4UI" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBXFCE4UI_VERSION, LIBXFCE4UI_SITE and LIBXFCE4UI_SOURCE define
# the upstream location of the source code for the package.
# LIBXFCE4UI_DIR is the directory which is created when the source
# archive is unpacked.
# LIBXFCE4UI_UNZIP is the command used to unzip the source.
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
LIBXFCE4UI_SITE=http://archive.xfce.org/src/xfce/libxfce4ui/4.12
LIBXFCE4UI_VERSION=4.12.1
LIBXFCE4UI_SOURCE=libxfce4ui-$(LIBXFCE4UI_VERSION).tar.bz2
LIBXFCE4UI_DIR=libxfce4ui-$(LIBXFCE4UI_VERSION)
LIBXFCE4UI_UNZIP=bzcat
LIBXFCE4UI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBXFCE4UI-1_DESCRIPTION=GTK+ 2 widgets that are used by Xfce applications.
LIBXFCE4UI-2_DESCRIPTION=GTK+ 3 widgets that are used by Xfce applications.
LIBXFCE4UI-COMMON_DESCRIPTION=libxfce4ui common files
LIBXFCE4UI_SECTION=lib
LIBXFCE4UI_PRIORITY=optional
LIBXFCE4UI-1_DEPENDS=gtk2, xfconf, libxfce4ui-common
LIBXFCE4UI-2_DEPENDS=gtk, xfconf, libxfce4ui-common
LIBXFCE4UI-COMMON_DEPENDS=
LIBXFCE4UI-1_SUGGESTS=
LIBXFCE4UI-2_SUGGESTS=
LIBXFCE4UI-COMMON_SUGGESTS=libxfce4ui-1
ifeq (gtk, $(filter gtk, $(PACKAGES)))
LIBXFCE4UI-COMMON_SUGGESTS +=, libxfce4ui-2
endif
LIBXFCE4UI-1_CONFLICTS=
LIBXFCE4UI-2_CONFLICTS=
LIBXFCE4UI-COMMON_CONFLICTS=

#
# LIBXFCE4UI_IPK_VERSION should be incremented when the ipk changes.
#
LIBXFCE4UI_IPK_VERSION=3

#
# LIBXFCE4UI_CONFFILES should be a list of user-editable files
LIBXFCE4UI_CONFFILES=$(TARGET_PREFIX)/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

#
# LIBXFCE4UI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBXFCE4UI_PATCHES=$(LIBXFCE4UI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBXFCE4UI_CPPFLAGS=
LIBXFCE4UI_LDFLAGS=

ifeq (gtk, $(filter gtk, $(PACKAGES)))
LIBXFCE4UI_CONFIGURE_ARGS=--enable-gtk3
else
LIBXFCE4UI_CONFIGURE_ARGS=--disable-gtk3
endif

#
# LIBXFCE4UI_BUILD_DIR is the directory in which the build is done.
# LIBXFCE4UI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBXFCE4UI_IPK_DIR is the directory in which the ipk is built.
# LIBXFCE4UI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBXFCE4UI_BUILD_DIR=$(BUILD_DIR)/libxfce4ui
LIBXFCE4UI_SOURCE_DIR=$(SOURCE_DIR)/libxfce4ui

LIBXFCE4UI-1_IPK_DIR=$(BUILD_DIR)/libxfce4ui-1-$(LIBXFCE4UI_VERSION)-ipk
LIBXFCE4UI-1_IPK=$(BUILD_DIR)/libxfce4ui-1_$(LIBXFCE4UI_VERSION)-$(LIBXFCE4UI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBXFCE4UI-2_IPK_DIR=$(BUILD_DIR)/libxfce4ui-2-$(LIBXFCE4UI_VERSION)-ipk
LIBXFCE4UI-2_IPK=$(BUILD_DIR)/libxfce4ui-2_$(LIBXFCE4UI_VERSION)-$(LIBXFCE4UI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBXFCE4UI-COMMON_IPK_DIR=$(BUILD_DIR)/libxfce4ui-common-$(LIBXFCE4UI_VERSION)-ipk
LIBXFCE4UI-COMMON_IPK=$(BUILD_DIR)/libxfce4ui-common_$(LIBXFCE4UI_VERSION)-$(LIBXFCE4UI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libxfce4ui-source libxfce4ui-unpack libxfce4ui libxfce4ui-stage libxfce4ui-ipk libxfce4ui-clean libxfce4ui-dirclean libxfce4ui-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBXFCE4UI_SOURCE):
	$(WGET) -P $(@D) $(LIBXFCE4UI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libxfce4ui-source: $(DL_DIR)/$(LIBXFCE4UI_SOURCE) $(LIBXFCE4UI_PATCHES)

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
$(LIBXFCE4UI_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXFCE4UI_SOURCE) $(LIBXFCE4UI_PATCHES) make/libxfce4ui.mk
	$(MAKE) gtk2-stage xfconf-stage
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	$(MAKE) gtk-stage
endif
	rm -rf $(BUILD_DIR)/$(LIBXFCE4UI_DIR) $(@D)
	$(LIBXFCE4UI_UNZIP) $(DL_DIR)/$(LIBXFCE4UI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBXFCE4UI_PATCHES)" ; \
		then cat $(LIBXFCE4UI_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBXFCE4UI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBXFCE4UI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBXFCE4UI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBXFCE4UI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBXFCE4UI_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		$(LIBXFCE4UI_CONFIGURE_ARGS) \
		--program-transform-name='s&^&&' \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libxfce4ui-unpack: $(LIBXFCE4UI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXFCE4UI_BUILD_DIR)/.built: $(LIBXFCE4UI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libxfce4ui: $(LIBXFCE4UI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXFCE4UI_BUILD_DIR)/.staged: $(LIBXFCE4UI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(addprefix $(STAGING_LIB_DIR)/, libxfce4ui-1.la libxfce4kbd-private-2.la)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(addprefix $(STAGING_LIB_DIR)/pkgconfig/, \
		libxfce4ui-1.pc libxfce4kbd-private-2.pc)
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	rm -f $(addprefix $(STAGING_LIB_DIR)/, libxfce4ui-2.la libxfce4kbd-private-3.la)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(addprefix $(STAGING_LIB_DIR)/pkgconfig/, \
		libxfce4ui-2.pc libxfce4kbd-private-3.pc)
endif
	touch $@

libxfce4ui-stage: $(LIBXFCE4UI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libxfce4ui
#
$(LIBXFCE4UI-1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libxfce4ui-1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXFCE4UI_PRIORITY)" >>$@
	@echo "Section: $(LIBXFCE4UI_SECTION)" >>$@
	@echo "Version: $(LIBXFCE4UI_VERSION)-$(LIBXFCE4UI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXFCE4UI_MAINTAINER)" >>$@
	@echo "Source: $(LIBXFCE4UI_SITE)/$(LIBXFCE4UI_SOURCE)" >>$@
	@echo "Description: $(LIBXFCE4UI-1_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXFCE4UI-1_DEPENDS)" >>$@
	@echo "Suggests: $(LIBXFCE4UI-1_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBXFCE4UI-1_CONFLICTS)" >>$@

$(LIBXFCE4UI-2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libxfce4ui-2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXFCE4UI_PRIORITY)" >>$@
	@echo "Section: $(LIBXFCE4UI_SECTION)" >>$@
	@echo "Version: $(LIBXFCE4UI_VERSION)-$(LIBXFCE4UI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXFCE4UI_MAINTAINER)" >>$@
	@echo "Source: $(LIBXFCE4UI_SITE)/$(LIBXFCE4UI_SOURCE)" >>$@
	@echo "Description: $(LIBXFCE4UI-2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXFCE4UI-2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBXFCE4UI-2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBXFCE4UI-2_CONFLICTS)" >>$@

$(LIBXFCE4UI-COMMON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libxfce4ui-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXFCE4UI_PRIORITY)" >>$@
	@echo "Section: $(LIBXFCE4UI_SECTION)" >>$@
	@echo "Version: $(LIBXFCE4UI_VERSION)-$(LIBXFCE4UI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXFCE4UI_MAINTAINER)" >>$@
	@echo "Source: $(LIBXFCE4UI_SITE)/$(LIBXFCE4UI_SOURCE)" >>$@
	@echo "Description: $(LIBXFCE4UI-COMMON_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXFCE4UI-COMMON_DEPENDS)" >>$@
	@echo "Suggests: $(LIBXFCE4UI-COMMON_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBXFCE4UI-COMMON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/libxfce4ui/...
# Documentation files should be installed in $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/doc/libxfce4ui/...
# Daemon startup scripts should be installed in $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libxfce4ui
#
# You may need to patch your application to make it use these locations.
#
ifeq (gtk, $(filter gtk, $(PACKAGES)))
$(LIBXFCE4UI-1_IPK) $(LIBXFCE4UI-2_IPK) $(LIBXFCE4UI-COMMON_IPK): $(LIBXFCE4UI_BUILD_DIR)/.built
else
$(LIBXFCE4UI-1_IPK) $(LIBXFCE4UI-COMMON_IPK): $(LIBXFCE4UI_BUILD_DIR)/.built
endif
	rm -rf $(LIBXFCE4UI-1_IPK_DIR) $(BUILD_DIR)/libxfce4ui-1_*_$(TARGET_ARCH).ipk \
		$(LIBXFCE4UI-COMMON_IPK_DIR) $(BUILD_DIR)/libxfce4ui-common_*_$(TARGET_ARCH).ipk
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	rm -rf $(LIBXFCE4UI-2_IPK_DIR) $(BUILD_DIR)/libxfce4ui-2_*_$(TARGET_ARCH).ipk
endif
	$(MAKE) -C $(LIBXFCE4UI_BUILD_DIR) DESTDIR=$(LIBXFCE4UI-1_IPK_DIR) install-strip
	rm -f $(LIBXFCE4UI-1_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(INSTALL) -d $(LIBXFCE4UI-COMMON_IPK_DIR)$(TARGET_PREFIX)
	mv -f $(LIBXFCE4UI-1_IPK_DIR)$(TARGET_PREFIX)/share $(LIBXFCE4UI-1_IPK_DIR)$(TARGET_PREFIX)/etc $(LIBXFCE4UI-COMMON_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) $(LIBXFCE4UI-COMMON_IPK_DIR)/CONTROL/control
	echo $(LIBXFCE4UI_CONFFILES) | sed -e 's/ /\n/g' > $(LIBXFCE4UI-COMMON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXFCE4UI-COMMON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBXFCE4UI-COMMON_IPK_DIR)
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	$(INSTALL) -d $(LIBXFCE4UI-2_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig  $(LIBXFCE4UI-2_IPK_DIR)$(TARGET_PREFIX)/include/xfce4
	mv -f $(addprefix $(LIBXFCE4UI-1_IPK_DIR)$(TARGET_PREFIX)/lib/, libxfce4ui-2.* libxfce4kbd-private-3.*) \
											$(LIBXFCE4UI-2_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(addprefix $(LIBXFCE4UI-1_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/, libxfce4ui-2.pc libxfce4kbd-private-3.pc) \
										$(LIBXFCE4UI-2_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	mv -f $(addprefix $(LIBXFCE4UI-1_IPK_DIR)$(TARGET_PREFIX)/include/xfce4/, libxfce4ui-2 libxfce4kbd-private-3) \
										$(LIBXFCE4UI-2_IPK_DIR)$(TARGET_PREFIX)/include/xfce4
	$(MAKE) $(LIBXFCE4UI-2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXFCE4UI-2_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBXFCE4UI-2_IPK_DIR)
endif
#	$(INSTALL) -d $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBXFCE4UI_SOURCE_DIR)/libxfce4ui.conf $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/libxfce4ui.conf
#	$(INSTALL) -d $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBXFCE4UI_SOURCE_DIR)/rc.libxfce4ui $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibxfce4ui
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXFCE4UI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibxfce4ui
	$(MAKE) $(LIBXFCE4UI-1_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBXFCE4UI_SOURCE_DIR)/postinst $(LIBXFCE4UI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXFCE4UI_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBXFCE4UI_SOURCE_DIR)/prerm $(LIBXFCE4UI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXFCE4UI_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBXFCE4UI_IPK_DIR)/CONTROL/postinst $(LIBXFCE4UI_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXFCE4UI-1_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBXFCE4UI-1_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ifeq (gtk, $(filter gtk, $(PACKAGES)))
libxfce4ui-ipk: $(LIBXFCE4UI-1_IPK) $(LIBXFCE4UI-2_IPK) $(LIBXFCE4UI-COMMON_IPK)
else
libxfce4ui-ipk: $(LIBXFCE4UI-1_IPK) $(LIBXFCE4UI-COMMON_IPK)
endif

#
# This is called from the top level makefile to clean all of the built files.
#
libxfce4ui-clean:
	rm -f $(LIBXFCE4UI_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBXFCE4UI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libxfce4ui-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBXFCE4UI_DIR) $(LIBXFCE4UI_BUILD_DIR) \
		$(LIBXFCE4UI-1_IPK_DIR) $(LIBXFCE4UI-1_IPK) \
		$(LIBXFCE4UI-COMMON_IPK_DIR) $(LIBXFCE4UI-COMMON_IPK)
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	rm -rf $(LIBXFCE4UI-2_IPK_DIR) $(LIBXFCE4UI-2_IPK)
endif
#
#
# Some sanity check for the package.
#
ifeq (gtk, $(filter gtk, $(PACKAGES)))
libxfce4ui-check: $(LIBXFCE4UI-1_IPK) $(LIBXFCE4UI-2_IPK) $(LIBXFCE4UI-COMMON_IPK)
else
libxfce4ui-check: $(LIBXFCE4UI-1_IPK) $(LIBXFCE4UI-COMMON_IPK)
endif
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
