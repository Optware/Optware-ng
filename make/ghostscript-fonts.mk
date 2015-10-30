###########################################################
#
# ghostscript-fonts
#
###########################################################

# You must replace "ghostscript-fonts" and "GHOSTSCRIPT-FONTS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GHOSTSCRIPT-FONTS_VERSION, GHOSTSCRIPT-FONTS_SITE and GHOSTSCRIPT-FONTS_SOURCE define
# the upstream location of the source code for the package.
# GHOSTSCRIPT-FONTS_DIR is the directory which is created when the source
# archive is unpacked.
# GHOSTSCRIPT-FONTS_UNZIP is the command used to unzip the source.
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
#https://launchpad.net/ubuntu/+archive/primary/+files/gsfonts_8.11%2Burwcyr1.0.7%7Epre44.orig.tar.gz
GHOSTSCRIPT-FONTS_SITE=https://launchpad.net/ubuntu/+archive/primary/+files
GHOSTSCRIPT-FONTS_VERSION1=8.11
#+
GHOSTSCRIPT-FONTS_VERSION2=urwcyr1.0.7
#~
GHOSTSCRIPT-FONTS_VERSION3=pre44
GHOSTSCRIPT-FONTS_VERSION=$(GHOSTSCRIPT-FONTS_VERSION1)-$(GHOSTSCRIPT-FONTS_VERSION2)-$(GHOSTSCRIPT-FONTS_VERSION3)
GHOSTSCRIPT-FONTS_VERSION_ORIG=$(GHOSTSCRIPT-FONTS_VERSION1)+$(GHOSTSCRIPT-FONTS_VERSION2)~$(GHOSTSCRIPT-FONTS_VERSION3)
GHOSTSCRIPT-FONTS_SOURCE=gsfonts_$(GHOSTSCRIPT-FONTS_VERSION_ORIG).orig.tar.gz
GHOSTSCRIPT-FONTS_DIR=gsfonts-$(GHOSTSCRIPT-FONTS_VERSION_ORIG)
GHOSTSCRIPT-FONTS_UNZIP=zcat
GHOSTSCRIPT-FONTS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GHOSTSCRIPT-FONTS_DESCRIPTION=Fonts and font metrics customarily distributed with Ghostscript. \
		Currently includes the 35 standard PostScript fonts and a grab-bag of others.
GHOSTSCRIPT-FONTS_SECTION=misc
GHOSTSCRIPT-FONTS_PRIORITY=optional
GHOSTSCRIPT-FONTS_DEPENDS=
GHOSTSCRIPT-FONTS_SUGGESTS=
GHOSTSCRIPT-FONTS_CONFLICTS=

#
# GHOSTSCRIPT-FONTS_IPK_VERSION should be incremented when the ipk changes.
#
GHOSTSCRIPT-FONTS_IPK_VERSION=1

#
# GHOSTSCRIPT-FONTS_CONFFILES should be a list of user-editable files
#GHOSTSCRIPT-FONTS_CONFFILES=$(TARGET_PREFIX)/etc/ghostscript-fonts.conf $(TARGET_PREFIX)/etc/init.d/SXXghostscript-fonts

#
# GHOSTSCRIPT-FONTS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GHOSTSCRIPT-FONTS_PATCHES=$(GHOSTSCRIPT-FONTS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GHOSTSCRIPT-FONTS_CPPFLAGS=
GHOSTSCRIPT-FONTS_LDFLAGS=

#
# GHOSTSCRIPT-FONTS_BUILD_DIR is the directory in which the build is done.
# GHOSTSCRIPT-FONTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GHOSTSCRIPT-FONTS_IPK_DIR is the directory in which the ipk is built.
# GHOSTSCRIPT-FONTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GHOSTSCRIPT-FONTS_BUILD_DIR=$(BUILD_DIR)/ghostscript-fonts
GHOSTSCRIPT-FONTS_SOURCE_DIR=$(SOURCE_DIR)/ghostscript-fonts
GHOSTSCRIPT-FONTS_IPK_DIR=$(BUILD_DIR)/ghostscript-fonts-$(GHOSTSCRIPT-FONTS_VERSION)-ipk
GHOSTSCRIPT-FONTS_IPK=$(BUILD_DIR)/ghostscript-fonts_$(GHOSTSCRIPT-FONTS_VERSION)-$(GHOSTSCRIPT-FONTS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ghostscript-fonts-source ghostscript-fonts-unpack ghostscript-fonts ghostscript-fonts-stage ghostscript-fonts-ipk ghostscript-fonts-clean ghostscript-fonts-dirclean ghostscript-fonts-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GHOSTSCRIPT-FONTS_SOURCE):
	$(WGET) -P $(@D) $(GHOSTSCRIPT-FONTS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ghostscript-fonts-source: $(DL_DIR)/$(GHOSTSCRIPT-FONTS_SOURCE) $(GHOSTSCRIPT-FONTS_PATCHES)

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
$(GHOSTSCRIPT-FONTS_BUILD_DIR)/.configured: $(DL_DIR)/$(GHOSTSCRIPT-FONTS_SOURCE) $(GHOSTSCRIPT-FONTS_PATCHES) make/ghostscript-fonts.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GHOSTSCRIPT-FONTS_DIR) $(@D)
	$(GHOSTSCRIPT-FONTS_UNZIP) $(DL_DIR)/$(GHOSTSCRIPT-FONTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GHOSTSCRIPT-FONTS_PATCHES)" ; \
		then cat $(GHOSTSCRIPT-FONTS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GHOSTSCRIPT-FONTS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GHOSTSCRIPT-FONTS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GHOSTSCRIPT-FONTS_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GHOSTSCRIPT-FONTS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GHOSTSCRIPT-FONTS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ghostscript-fonts-unpack: $(GHOSTSCRIPT-FONTS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
#$(GHOSTSCRIPT-FONTS_BUILD_DIR)/.built: $(GHOSTSCRIPT-FONTS_BUILD_DIR)/.configured
#	rm -f $@
#	$(MAKE) -C $(@D)
#	touch $@

#
# This is the build convenience target.
#
ghostscript-fonts: $(GHOSTSCRIPT-FONTS_BUILD_DIR)/.configured

#
# If you are building a library, then you need to stage it too.
#
#$(GHOSTSCRIPT-FONTS_BUILD_DIR)/.staged: $(GHOSTSCRIPT-FONTS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

ghostscript-fonts-stage: #$(GHOSTSCRIPT-FONTS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ghostscript-fonts
#
$(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ghostscript-fonts" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GHOSTSCRIPT-FONTS_PRIORITY)" >>$@
	@echo "Section: $(GHOSTSCRIPT-FONTS_SECTION)" >>$@
	@echo "Version: $(GHOSTSCRIPT-FONTS_VERSION)-$(GHOSTSCRIPT-FONTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GHOSTSCRIPT-FONTS_MAINTAINER)" >>$@
	@echo "Source: $(GHOSTSCRIPT-FONTS_SITE)/$(GHOSTSCRIPT-FONTS_SOURCE)" >>$@
	@echo "Description: $(GHOSTSCRIPT-FONTS_DESCRIPTION)" >>$@
	@echo "Depends: $(GHOSTSCRIPT-FONTS_DEPENDS)" >>$@
	@echo "Suggests: $(GHOSTSCRIPT-FONTS_SUGGESTS)" >>$@
	@echo "Conflicts: $(GHOSTSCRIPT-FONTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/etc/ghostscript-fonts/...
# Documentation files should be installed in $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/doc/ghostscript-fonts/...
# Daemon startup scripts should be installed in $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ghostscript-fonts
#
# You may need to patch your application to make it use these locations.
#
$(GHOSTSCRIPT-FONTS_IPK): $(GHOSTSCRIPT-FONTS_BUILD_DIR)/.configured
	rm -rf $(GHOSTSCRIPT-FONTS_IPK_DIR) $(BUILD_DIR)/ghostscript-fonts_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(GHOSTSCRIPT-FONTS_BUILD_DIR) DESTDIR=$(GHOSTSCRIPT-FONTS_IPK_DIR) install
	$(INSTALL) -d $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/share/fonts/default/Type1
	cp -f $(addprefix $(GHOSTSCRIPT-FONTS_BUILD_DIR)/*., afm pfb pfm) $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/share/fonts/default/Type1
#	$(INSTALL) -m 644 $(GHOSTSCRIPT-FONTS_SOURCE_DIR)/ghostscript-fonts.conf $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/etc/ghostscript-fonts.conf
#	$(INSTALL) -d $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GHOSTSCRIPT-FONTS_SOURCE_DIR)/rc.ghostscript-fonts $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXghostscript-fonts
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GHOSTSCRIPT-FONTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXghostscript-fonts
	$(MAKE) $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GHOSTSCRIPT-FONTS_SOURCE_DIR)/postinst $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GHOSTSCRIPT-FONTS_SOURCE_DIR)/prerm $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/postinst $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GHOSTSCRIPT-FONTS_CONFFILES) | sed -e 's/ /\n/g' > $(GHOSTSCRIPT-FONTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GHOSTSCRIPT-FONTS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GHOSTSCRIPT-FONTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ghostscript-fonts-ipk: $(GHOSTSCRIPT-FONTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ghostscript-fonts-clean:
	rm -f $(GHOSTSCRIPT-FONTS_BUILD_DIR)/.built
	-$(MAKE) -C $(GHOSTSCRIPT-FONTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ghostscript-fonts-dirclean:
	rm -rf $(BUILD_DIR)/$(GHOSTSCRIPT-FONTS_DIR) $(GHOSTSCRIPT-FONTS_BUILD_DIR) $(GHOSTSCRIPT-FONTS_IPK_DIR) $(GHOSTSCRIPT-FONTS_IPK)
#
#
# Some sanity check for the package.
#
ghostscript-fonts-check: $(GHOSTSCRIPT-FONTS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
