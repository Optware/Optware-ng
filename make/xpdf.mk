###########################################################
#
# xpdf
#
###########################################################
#
# XPDF_VERSION, XPDF_SITE and XPDF_SOURCE define
# the upstream location of the source code for the package.
# XPDF_DIR is the directory which is created when the source
# archive is unpacked.
# XPDF_UNZIP is the command used to unzip the source.
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
XPDF_SITE=ftp://ftp.foolabs.com/pub/xpdf
XPDF_VERSION=3.04
XPDF_SOURCE=xpdf-$(XPDF_VERSION).tar.gz
XPDF_DIR=xpdf-$(XPDF_VERSION)
XPDF_UNZIP=zcat
XPDF_MAINTAINER=Bernhard Walle <bernhard.walle@gmx.de>
XPDF_DESCRIPTION=Various PDF tools (without xpdf X11 binaries)
XPDF_X_DESCRIPTION=xpdf X11 binaries (xpdf and pdftoppm)
XPDF_SECTION=tool
XPDF_PRIORITY=optional
XPDF_DEPENDS=libstdc++, freetype
XPDF_X_DEPENDS= xpdf, x11, xext, xpm, motif, ghostscript-fonts
XPDF_SUGGESTS=
XPDF_CONFLICTS=

#
# XPDF_IPK_VERSION should be incremented when the ipk changes.
#
XPDF_IPK_VERSION=2

#
# XPDF_CONFFILES should be a list of user-editable files
XPDF_CONFFILES=$(TARGET_PREFIX)/etc/xpdfrc

#
# XPDF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XPDF_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XPDF_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
XPDF_LDFLAGS=

#
# XPDF_BUILD_DIR is the directory in which the build is done.
# XPDF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XPDF_IPK_DIR is the directory in which the ipk is built.
# XPDF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XPDF_BUILD_DIR=$(BUILD_DIR)/xpdf
XPDF_SOURCE_DIR=$(SOURCE_DIR)/xpdf

XPDF_IPK_DIR=$(BUILD_DIR)/xpdf-$(XPDF_VERSION)-ipk
XPDF_IPK=$(BUILD_DIR)/xpdf_$(XPDF_VERSION)-$(XPDF_IPK_VERSION)_$(TARGET_ARCH).ipk

XPDF_X_IPK_DIR=$(BUILD_DIR)/xpdf-x-$(XPDF_VERSION)-ipk
XPDF_X_IPK=$(BUILD_DIR)/xpdf-x_$(XPDF_VERSION)-$(XPDF_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq (x11, $(filter x11, $(PACKAGES)))
XPDF_IPKS=$(XPDF_IPK) $(XPDF_X_IPK)
XPDF_ENV =
else
XPDF_IPKS=$(XPDF_IPK)
XPDF_ENV = no_x=yes
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XPDF_SOURCE):
	$(WGET) -P $(DL_DIR) $(XPDF_SITE)/$(XPDF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xpdf-source: $(DL_DIR)/$(XPDF_SOURCE) $(XPDF_PATCHES)

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
$(XPDF_BUILD_DIR)/.configured: $(DL_DIR)/$(XPDF_SOURCE) $(XPDF_PATCHES) make/xpdf.mk
	$(MAKE) libstdc++-stage freetype-stage
ifeq (x11, $(filter x11, $(PACKAGES)))
	$(MAKE) x11-stage xext-stage xpm-stage motif-stage
endif
	rm -rf $(BUILD_DIR)/$(XPDF_DIR) $(@D)
	$(XPDF_UNZIP) $(DL_DIR)/$(XPDF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(XPDF_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(XPDF_DIR) -p1
	mv $(BUILD_DIR)/$(XPDF_DIR) $(@D)
#	sed fonts root dir to $(TARGET_PREFIX)/share
	sed -i -e 's~/usr/share\|/usr/local/share~$(TARGET_PREFIX)/share~g' $(@D)/xpdf/GlobalParams.cc
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		$(XPDF_ENV) \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(XPDF_CPPFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XPDF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XPDF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	#$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

xpdf-unpack: $(XPDF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XPDF_BUILD_DIR)/.built: $(XPDF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xpdf: $(XPDF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XPDF_BUILD_DIR)/.staged: $(XPDF_BUILD_DIR)/.built
	rm -f $(XPDF_BUILD_DIR)/.staged
	$(MAKE) -C $(XPDF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(XPDF_BUILD_DIR)/.staged

xpdf-stage: $(XPDF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xpdf
#
$(XPDF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xpdf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XPDF_PRIORITY)" >>$@
	@echo "Section: $(XPDF_SECTION)" >>$@
	@echo "Version: $(XPDF_VERSION)-$(XPDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XPDF_MAINTAINER)" >>$@
	@echo "Source: $(XPDF_SITE)/$(XPDF_SOURCE)" >>$@
	@echo "Description: $(XPDF_DESCRIPTION)" >>$@
	@echo "Depends: $(XPDF_DEPENDS)" >>$@
	@echo "Suggests: $(XPDF_SUGGESTS)" >>$@
	@echo "Conflicts: $(XPDF_CONFLICTS)" >>$@

$(XPDF_X_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xpdf-x" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XPDF_PRIORITY)" >>$@
	@echo "Section: $(XPDF_SECTION)" >>$@
	@echo "Version: $(XPDF_VERSION)-$(XPDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XPDF_MAINTAINER)" >>$@
	@echo "Source: $(XPDF_SITE)/$(XPDF_SOURCE)" >>$@
	@echo "Description: $(XPDF_X_DESCRIPTION)" >>$@
	@echo "Depends: $(XPDF_X_DEPENDS)" >>$@
	@echo "Suggests: $(XPDF_SUGGESTS)" >>$@
	@echo "Conflicts: $(XPDF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XPDF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XPDF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XPDF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XPDF_IPK_DIR)$(TARGET_PREFIX)/etc/xpdf/...
# Documentation files should be installed in $(XPDF_IPK_DIR)$(TARGET_PREFIX)/doc/xpdf/...
# Daemon startup scripts should be installed in $(XPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xpdf
#
# You may need to patch your application to make it use these locations.
#
$(XPDF_IPKS): $(XPDF_BUILD_DIR)/.built
	rm -rf $(XPDF_IPK_DIR) $(BUILD_DIR)/xpdf_*_$(TARGET_ARCH).ipk \
		$(XPDF_X_IPK_DIR) $(BUILD_DIR)/xpdf-x_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XPDF_BUILD_DIR) DESTDIR=$(XPDF_IPK_DIR) install
	$(STRIP_COMMAND) $(XPDF_IPK_DIR)$(TARGET_PREFIX)/bin/*
ifeq (x11, $(filter x11, $(PACKAGES)))
	$(INSTALL) -d $(XPDF_X_IPK_DIR)$(TARGET_PREFIX)/bin
	mv -f $(XPDF_IPK_DIR)$(TARGET_PREFIX)/bin/xpdf $(XPDF_IPK_DIR)$(TARGET_PREFIX)/bin/pdftoppm \
							$(XPDF_X_IPK_DIR)$(TARGET_PREFIX)/bin/
	$(MAKE) $(XPDF_X_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XPDF_X_IPK_DIR)
endif
	#$(INSTALL) -d $(XPDF_IPK_DIR)$(TARGET_PREFIX)/etc/
	#$(INSTALL) -m 644 $(XPDF_SOURCE_DIR)/xpdf.conf $(XPDF_IPK_DIR)$(TARGET_PREFIX)/etc/xpdf.conf
	#$(INSTALL) -d $(XPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	#$(INSTALL) -m 755 $(XPDF_SOURCE_DIR)/rc.xpdf $(XPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxpdf
	$(MAKE) $(XPDF_IPK_DIR)/CONTROL/control
	#$(INSTALL) -m 755 $(XPDF_SOURCE_DIR)/postinst $(XPDF_IPK_DIR)/CONTROL/postinst
	#$(INSTALL) -m 755 $(XPDF_SOURCE_DIR)/prerm $(XPDF_IPK_DIR)/CONTROL/prerm
	echo $(XPDF_CONFFILES) | sed -e 's/ /\n/g' > $(XPDF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XPDF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xpdf-ipk: $(XPDF_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
xpdf-clean:
	rm -f $(XPDF_BUILD_DIR)/.built
	-$(MAKE) -C $(XPDF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xpdf-dirclean:
	rm -rf $(BUILD_DIR)/$(XPDF_DIR) $(XPDF_BUILD_DIR) $(XPDF_IPK_DIR) $(XPDF_X_IPK_DIR) $(XPDF_IPK) $(XPDF_X_IPK)
#
# Some sanity check for the package.
#
xpdf-check: $(XPDF_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
