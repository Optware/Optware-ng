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
XPDF_SITE=ftp://ftp.foolabs.com/pub/xpdf/
XPDF_VERSION=3.02
XPDF_SOURCE=xpdf-$(XPDF_VERSION).tar.gz
XPDF_DIR=xpdf-$(XPDF_VERSION)
XPDF_UNZIP=zcat
XPDF_MAINTAINER=Bernhard Walle <bernhard.walle@gmx.de>
XPDF_DESCRIPTION=Various PDF tools (no support for X11 compiled in)
XPDF_SECTION=tool
XPDF_PRIORITY=optional
XPDF_DEPENDS=libstdc++
XPDF_SUGGESTS=
XPDF_CONFLICTS=

#
# XPDF_IPK_VERSION should be incremented when the ipk changes.
#
XPDF_IPK_VERSION=1

#
# XPDF_CONFFILES should be a list of user-editable files
XPDF_CONFFILES=/opt/etc/xpdfrc

#
# XPDF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XPDF_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XPDF_CPPFLAGS=
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
$(XPDF_BUILD_DIR)/.configured: $(DL_DIR)/$(XPDF_SOURCE) $(XPDF_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(XPDF_DIR) $(XPDF_BUILD_DIR)
	$(XPDF_UNZIP) $(DL_DIR)/$(XPDF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(XPDF_PATCHES) | patch -d $(BUILD_DIR)/$(XPDF_DIR) -p1
	mv $(BUILD_DIR)/$(XPDF_DIR) $(XPDF_BUILD_DIR)
	(cd $(XPDF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		no_x=yes \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XPDF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XPDF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	#$(PATCH_LIBTOOL) $(XPDF_BUILD_DIR)/libtool
	touch $(XPDF_BUILD_DIR)/.configured

xpdf-unpack: $(XPDF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XPDF_BUILD_DIR)/.built: $(XPDF_BUILD_DIR)/.configured
	rm -f $(XPDF_BUILD_DIR)/.built
	$(MAKE) -C $(XPDF_BUILD_DIR)
	touch $(XPDF_BUILD_DIR)/.built

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
	@install -d $(XPDF_IPK_DIR)/CONTROL
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(XPDF_IPK_DIR)/opt/sbin or $(XPDF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XPDF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XPDF_IPK_DIR)/opt/etc/xpdf/...
# Documentation files should be installed in $(XPDF_IPK_DIR)/opt/doc/xpdf/...
# Daemon startup scripts should be installed in $(XPDF_IPK_DIR)/opt/etc/init.d/S??xpdf
#
# You may need to patch your application to make it use these locations.
#
$(XPDF_IPK): $(XPDF_BUILD_DIR)/.built
	rm -rf $(XPDF_IPK_DIR) $(BUILD_DIR)/xpdf_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XPDF_BUILD_DIR) DESTDIR=$(XPDF_IPK_DIR) install
	$(STRIP_COMMAND) $(XPDF_IPK_DIR)/opt/bin/*
	#install -d $(XPDF_IPK_DIR)/opt/etc/
	#install -m 644 $(XPDF_SOURCE_DIR)/xpdf.conf $(XPDF_IPK_DIR)/opt/etc/xpdf.conf
	#install -d $(XPDF_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(XPDF_SOURCE_DIR)/rc.xpdf $(XPDF_IPK_DIR)/opt/etc/init.d/SXXxpdf
	$(MAKE) $(XPDF_IPK_DIR)/CONTROL/control
	#install -m 755 $(XPDF_SOURCE_DIR)/postinst $(XPDF_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(XPDF_SOURCE_DIR)/prerm $(XPDF_IPK_DIR)/CONTROL/prerm
	echo $(XPDF_CONFFILES) | sed -e 's/ /\n/g' > $(XPDF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XPDF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xpdf-ipk: $(XPDF_IPK)

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
	rm -rf $(BUILD_DIR)/$(XPDF_DIR) $(XPDF_BUILD_DIR) $(XPDF_IPK_DIR) $(XPDF_IPK)
