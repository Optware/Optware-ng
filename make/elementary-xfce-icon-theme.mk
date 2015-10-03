###########################################################
#
# elementary-xfce-icon-theme
#
###########################################################

# You must replace "elementary-xfce-icon-theme" and "ELEMENTARY-XFCE-ICON-THEME" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ELEMENTARY-XFCE-ICON-THEME_VERSION, ELEMENTARY-XFCE-ICON-THEME_SITE and ELEMENTARY-XFCE-ICON-THEME_SOURCE define
# the upstream location of the source code for the package.
# ELEMENTARY-XFCE-ICON-THEME_DIR is the directory which is created when the source
# archive is unpacked.
# ELEMENTARY-XFCE-ICON-THEME_UNZIP is the command used to unzip the source.
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
ELEMENTARY-XFCE-ICON-THEME_SITE=https://github.com/shimmerproject/elementary-xfce/archive
ELEMENTARY-XFCE-ICON-THEME_VERSION=0.5

# this is how the original source tar is called
ELEMENTARY-XFCE-ICON-THEME_SOURCE_FETCH=v$(ELEMENTARY-XFCE-ICON-THEME_VERSION).tar.gz
# we rename the fetched source to this
ELEMENTARY-XFCE-ICON-THEME_SOURCE=elementary-xfce-$(ELEMENTARY-XFCE-ICON-THEME_VERSION).tar.gz

ELEMENTARY-XFCE-ICON-THEME_DIR=elementary-xfce-$(ELEMENTARY-XFCE-ICON-THEME_VERSION)
ELEMENTARY-XFCE-ICON-THEME_UNZIP=zcat
ELEMENTARY-XFCE-ICON-THEME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ELEMENTARY-XFCE-ICON-THEME_DESCRIPTION=elementary-xfce icon theme
ELEMENTARY-XFCE-DARK-ICON-THEME_DESCRIPTION=elementary-xfce-dark icon theme
ELEMENTARY-XFCE-DARKER-ICON-THEME_DESCRIPTION=elementary-xfce-darker icon theme
ELEMENTARY-XFCE-DARKEST-ICON-THEME_DESCRIPTION=elementary-xfce-darkest icon theme
ELEMENTARY-XFCE-ICON-THEME_SECTION=misc
ELEMENTARY-XFCE-ICON-THEME_PRIORITY=optional
ELEMENTARY-XFCE-ICON-THEME_DEPENDS=
ELEMENTARY-XFCE-ICON-THEME_SUGGESTS=
ELEMENTARY-XFCE-ICON-THEME_CONFLICTS=

#
# ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION should be incremented when the ipk changes.
#
ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION=1

#
# ELEMENTARY-XFCE-ICON-THEME_CONFFILES should be a list of user-editable files
#ELEMENTARY-XFCE-ICON-THEME_CONFFILES=$(TARGET_PREFIX)/etc/elementary-xfce-icon-theme.conf $(TARGET_PREFIX)/etc/init.d/SXXelementary-xfce-icon-theme

#
# ELEMENTARY-XFCE-ICON-THEME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ELEMENTARY-XFCE-ICON-THEME_PATCHES=$(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ELEMENTARY-XFCE-ICON-THEME_CPPFLAGS=
ELEMENTARY-XFCE-ICON-THEME_LDFLAGS=

#
# ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR is the directory in which the build is done.
# ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ELEMENTARY-XFCE-ICON-THEME_IPK_DIR is the directory in which the ipk is built.
# ELEMENTARY-XFCE-ICON-THEME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR=$(BUILD_DIR)/elementary-xfce-icon-theme
ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR=$(SOURCE_DIR)/elementary-xfce-icon-theme

ELEMENTARY-XFCE-ICON-THEME_IPK_DIR=$(BUILD_DIR)/elementary-xfce-icon-theme-$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-ipk
ELEMENTARY-XFCE-ICON-THEME_IPK=$(BUILD_DIR)/elementary-xfce-icon-theme_$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)_$(TARGET_ARCH).ipk

ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR=$(BUILD_DIR)/elementary-xfce-dark-icon-theme-$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-ipk
ELEMENTARY-XFCE-DARK-ICON-THEME_IPK=$(BUILD_DIR)/elementary-xfce-dark-icon-theme_$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)_$(TARGET_ARCH).ipk

ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR=$(BUILD_DIR)/elementary-xfce-darker-icon-theme-$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-ipk
ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK=$(BUILD_DIR)/elementary-xfce-darker-icon-theme_$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)_$(TARGET_ARCH).ipk

ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR=$(BUILD_DIR)/elementary-xfce-darkest-icon-theme-$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-ipk
ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK=$(BUILD_DIR)/elementary-xfce-darkest-icon-theme_$(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)_$(TARGET_ARCH).ipk

ELEMENTARY-XFCE-ICON-THEME_IPK_DIRS=\
$(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR) \
$(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR) \
$(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR) \
$(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR) \

ELEMENTARY-XFCE-ICON-THEME_IPKS=\
$(ELEMENTARY-XFCE-ICON-THEME_IPK) \
$(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK) \
$(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK) \
$(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK) \

.PHONY: elementary-xfce-icon-theme-source elementary-xfce-icon-theme-unpack elementary-xfce-icon-theme elementary-xfce-icon-theme-stage elementary-xfce-icon-theme-ipk elementary-xfce-icon-theme-clean elementary-xfce-icon-theme-dirclean elementary-xfce-icon-theme-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE):
	$(WGET) -O $@ $(ELEMENTARY-XFCE-ICON-THEME_SITE)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE_FETCH) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
elementary-xfce-icon-theme-source: $(DL_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE) $(ELEMENTARY-XFCE-ICON-THEME_PATCHES)

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
$(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.configured: $(DL_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE) $(ELEMENTARY-XFCE-ICON-THEME_PATCHES) make/elementary-xfce-icon-theme.mk
	rm -rf $(BUILD_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_DIR) $(@D)
	$(ELEMENTARY-XFCE-ICON-THEME_UNZIP) $(DL_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ELEMENTARY-XFCE-ICON-THEME_PATCHES)" ; \
		then cat $(ELEMENTARY-XFCE-ICON-THEME_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_DIR) $(@D) ; \
	fi
	touch $@

elementary-xfce-icon-theme-unpack: $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built: $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
elementary-xfce-icon-theme: $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.staged: $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#elementary-xfce-icon-theme-stage: $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/elementary-xfce-icon-theme
#
$(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: elementary-xfce-icon-theme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELEMENTARY-XFCE-ICON-THEME_PRIORITY)" >>$@
	@echo "Section: $(ELEMENTARY-XFCE-ICON-THEME_SECTION)" >>$@
	@echo "Version: $(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELEMENTARY-XFCE-ICON-THEME_MAINTAINER)" >>$@
	@echo "Source: $(ELEMENTARY-XFCE-ICON-THEME_SITE)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE_FETCH)" >>$@
	@echo "Description: $(ELEMENTARY-XFCE-ICON-THEME_DESCRIPTION)" >>$@
	@echo "Depends: $(ELEMENTARY-XFCE-ICON-THEME_DEPENDS)" >>$@
	@echo "Suggests: $(ELEMENTARY-XFCE-ICON-THEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(ELEMENTARY-XFCE-ICON-THEME_CONFLICTS)" >>$@

$(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: elementary-xfce-dark-icon-theme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELEMENTARY-XFCE-ICON-THEME_PRIORITY)" >>$@
	@echo "Section: $(ELEMENTARY-XFCE-ICON-THEME_SECTION)" >>$@
	@echo "Version: $(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELEMENTARY-XFCE-ICON-THEME_MAINTAINER)" >>$@
	@echo "Source: $(ELEMENTARY-XFCE-ICON-THEME_SITE)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE_FETCH)" >>$@
	@echo "Description: $(ELEMENTARY-XFCE-DARK-ICON-THEME_DESCRIPTION)" >>$@
	@echo "Depends: $(ELEMENTARY-XFCE-ICON-THEME_DEPENDS)" >>$@
	@echo "Suggests: $(ELEMENTARY-XFCE-ICON-THEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(ELEMENTARY-XFCE-ICON-THEME_CONFLICTS)" >>$@

$(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: elementary-xfce-darker-icon-theme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELEMENTARY-XFCE-ICON-THEME_PRIORITY)" >>$@
	@echo "Section: $(ELEMENTARY-XFCE-ICON-THEME_SECTION)" >>$@
	@echo "Version: $(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELEMENTARY-XFCE-ICON-THEME_MAINTAINER)" >>$@
	@echo "Source: $(ELEMENTARY-XFCE-ICON-THEME_SITE)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE_FETCH)" >>$@
	@echo "Description: $(ELEMENTARY-XFCE-DARKER-ICON-THEME_DESCRIPTION)" >>$@
	@echo "Depends: $(ELEMENTARY-XFCE-ICON-THEME_DEPENDS)" >>$@
	@echo "Suggests: $(ELEMENTARY-XFCE-ICON-THEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(ELEMENTARY-XFCE-ICON-THEME_CONFLICTS)" >>$@

$(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: elementary-xfce-darkest-icon-theme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELEMENTARY-XFCE-ICON-THEME_PRIORITY)" >>$@
	@echo "Section: $(ELEMENTARY-XFCE-ICON-THEME_SECTION)" >>$@
	@echo "Version: $(ELEMENTARY-XFCE-ICON-THEME_VERSION)-$(ELEMENTARY-XFCE-ICON-THEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELEMENTARY-XFCE-ICON-THEME_MAINTAINER)" >>$@
	@echo "Source: $(ELEMENTARY-XFCE-ICON-THEME_SITE)/$(ELEMENTARY-XFCE-ICON-THEME_SOURCE_FETCH)" >>$@
	@echo "Description: $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_DESCRIPTION)" >>$@
	@echo "Depends: $(ELEMENTARY-XFCE-ICON-THEME_DEPENDS)" >>$@
	@echo "Suggests: $(ELEMENTARY-XFCE-ICON-THEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(ELEMENTARY-XFCE-ICON-THEME_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/etc/elementary-xfce-icon-theme/...
# Documentation files should be installed in $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/doc/elementary-xfce-icon-theme/...
# Daemon startup scripts should be installed in $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??elementary-xfce-icon-theme
#
# You may need to patch your application to make it use these locations.
#
$(ELEMENTARY-XFCE-ICON-THEME_IPK): $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built
	rm -rf $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR) $(BUILD_DIR)/elementary-xfce-icon-theme_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	cp -af $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/elementary-xfce $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	$(MAKE) $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/postinst $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/prerm $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)/CONTROL/prerm
	sed -i -e 's/@THEME@/elementary-xfce/g' $(addprefix $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)/CONTROL/, postinst prerm)
	echo $(ELEMENTARY-XFCE-ICON-THEME_CONFFILES) | sed -e 's/ /\n/g' > $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIR)

$(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK): $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built
	rm -rf $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR) $(BUILD_DIR)/elementary-xfce-dark-icon-theme_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	cp -af $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/elementary-xfce-dark $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	$(MAKE) $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/postinst $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/prerm $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)/CONTROL/prerm
	sed -i -e 's/@THEME@/elementary-xfce-dark/g' $(addprefix $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)/CONTROL/, postinst prerm)
	echo $(ELEMENTARY-XFCE-DARK-ICON-THEME_CONFFILES) | sed -e 's/ /\n/g' > $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(ELEMENTARY-XFCE-DARK-ICON-THEME_IPK_DIR)

$(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK): $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built
	rm -rf $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR) $(BUILD_DIR)/elementary-xfce-darker-icon-theme_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	cp -af $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/elementary-xfce-darker $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	$(MAKE) $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/postinst $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/prerm $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)/CONTROL/prerm
	sed -i -e 's/@THEME@/elementary-xfce-darker/g' $(addprefix $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)/CONTROL/, postinst prerm)
	echo $(ELEMENTARY-XFCE-DARKER-ICON-THEME_CONFFILES) | sed -e 's/ /\n/g' > $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(ELEMENTARY-XFCE-DARKER-ICON-THEME_IPK_DIR)

$(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK): $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built
	rm -rf $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR) $(BUILD_DIR)/elementary-xfce-darkest-icon-theme_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	cp -af $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/elementary-xfce-darkest $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)$(TARGET_PREFIX)/share/icons
	$(MAKE) $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/postinst $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(ELEMENTARY-XFCE-ICON-THEME_SOURCE_DIR)/prerm $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)/CONTROL/prerm
	sed -i -e 's/@THEME@/elementary-xfce-darkest/g' $(addprefix $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)/CONTROL/, postinst prerm)
	echo $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_CONFFILES) | sed -e 's/ /\n/g' > $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(ELEMENTARY-XFCE-DARKEST-ICON-THEME_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
elementary-xfce-icon-theme-ipk: $(ELEMENTARY-XFCE-ICON-THEME_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
elementary-xfce-icon-theme-clean:
	rm -f $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR)/.built
	-$(MAKE) -C $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
elementary-xfce-icon-theme-dirclean:
	rm -rf $(BUILD_DIR)/$(ELEMENTARY-XFCE-ICON-THEME_DIR) $(ELEMENTARY-XFCE-ICON-THEME_BUILD_DIR) $(ELEMENTARY-XFCE-ICON-THEME_IPK_DIRS) $(ELEMENTARY-XFCE-ICON-THEME_IPKS)
#
#
# Some sanity check for the package.
#
elementary-xfce-icon-theme-check: $(ELEMENTARY-XFCE-ICON-THEME_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
