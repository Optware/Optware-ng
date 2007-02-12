###########################################################
#
# xterm
#
###########################################################

# You must replace "xterm" and "XTERM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# XTERM_VERSION, XTERM_SITE and XTERM_SOURCE define
# the upstream location of the source code for the package.
# XTERM_DIR is the directory which is created when the source
# archive is unpacked.
# XTERM_UNZIP is the command used to unzip the source.
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
XTERM_SITE=ftp://invisible-island.net/xterm
XTERM_VERSION=224
XTERM_SOURCE=xterm-$(XTERM_VERSION).tgz
XTERM_DIR=xterm-$(XTERM_VERSION)
XTERM_UNZIP=zcat
XTERM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XTERM_DESCRIPTION=Terminal emulator for X.
XTERM_SECTION=x11
XTERM_PRIORITY=optional
XTERM_DEPENDS=xaw

#
# XTERM_IPK_VERSION should be incremented when the ipk changes.
#
XTERM_IPK_VERSION=1

#
# XTERM_CONFFILES should be a list of user-editable files
#XTERM_CONFFILES=/opt/etc/xterm.conf /opt/etc/init.d/SXXxterm

#
# XTERM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XTERM_PATCHES=$(XTERM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XTERM_CPPFLAGS=
XTERM_LDFLAGS=-lX11 -lXt -lICE -lSM -lXau

#
# XTERM_BUILD_DIR is the directory in which the build is done.
# XTERM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XTERM_IPK_DIR is the directory in which the ipk is built.
# XTERM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XTERM_BUILD_DIR=$(BUILD_DIR)/xterm
XTERM_SOURCE_DIR=$(SOURCE_DIR)/xterm
XTERM_IPK_DIR=$(BUILD_DIR)/xterm-$(XTERM_VERSION)-ipk
XTERM_IPK=$(BUILD_DIR)/xterm_$(XTERM_VERSION)-$(XTERM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xterm-source xterm-unpack xterm xterm-stage xterm-ipk xterm-clean xterm-dirclean xterm-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XTERM_SOURCE):
	$(WGET) -P $(DL_DIR) $(XTERM_SITE)/$(XTERM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xterm-source: $(DL_DIR)/$(XTERM_SOURCE) $(XTERM_PATCHES)

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
$(XTERM_BUILD_DIR)/.configured: $(DL_DIR)/$(XTERM_SOURCE) $(XTERM_PATCHES)
	$(MAKE) x11-stage xaw-stage xt-stage
	rm -rf $(BUILD_DIR)/$(XTERM_DIR) $(XTERM_BUILD_DIR)
	$(XTERM_UNZIP) $(DL_DIR)/$(XTERM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(XTERM_PATCHES) | patch -d $(BUILD_DIR)/$(XTERM_DIR) -p1
	mv $(BUILD_DIR)/$(XTERM_DIR) $(XTERM_BUILD_DIR)
	(cd $(XTERM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XTERM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XTERM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--disable-nls \
	)
	touch $(XTERM_BUILD_DIR)/.configured

xterm-unpack: $(XTERM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XTERM_BUILD_DIR)/.built: $(XTERM_BUILD_DIR)/.configured
	rm -f $(XTERM_BUILD_DIR)/.built
	$(MAKE) -C $(XTERM_BUILD_DIR)
	touch $(XTERM_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xterm: $(XTERM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XTERM_BUILD_DIR)/.staged: $(XTERM_BUILD_DIR)/.built
	rm -f $(XTERM_BUILD_DIR)/.staged
	$(MAKE) -C $(XTERM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(XTERM_BUILD_DIR)/.staged

xterm-stage: $(XTERM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xterm
#
$(XTERM_IPK_DIR)/CONTROL/control:
	@install -d $(XTERM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xterm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XTERM_PRIORITY)" >>$@
	@echo "Section: $(XTERM_SECTION)" >>$@
	@echo "Version: $(XTERM_VERSION)-$(XTERM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XTERM_MAINTAINER)" >>$@
	@echo "Source: $(XTERM_SITE)/$(XTERM_SOURCE)" >>$@
	@echo "Description: $(XTERM_DESCRIPTION)" >>$@
	@echo "Depends: $(XTERM_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XTERM_IPK_DIR)/opt/sbin or $(XTERM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XTERM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XTERM_IPK_DIR)/opt/etc/xterm/...
# Documentation files should be installed in $(XTERM_IPK_DIR)/opt/doc/xterm/...
# Daemon startup scripts should be installed in $(XTERM_IPK_DIR)/opt/etc/init.d/S??xterm
#
# You may need to patch your application to make it use these locations.
#
$(XTERM_IPK): $(XTERM_BUILD_DIR)/.built
	rm -rf $(XTERM_IPK_DIR) $(BUILD_DIR)/xterm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XTERM_BUILD_DIR) DESTDIR=$(XTERM_IPK_DIR) install
	$(STRIP_COMMAND) $(XTERM_IPK_DIR)/opt/bin/{resize,xterm}
	$(MAKE) $(XTERM_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XTERM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xterm-ipk: $(XTERM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xterm-clean:
	-$(MAKE) -C $(XTERM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xterm-dirclean:
	rm -rf $(BUILD_DIR)/$(XTERM_DIR) $(XTERM_BUILD_DIR) $(XTERM_IPK_DIR) $(XTERM_IPK)

#
# Some sanity check for the package.
#
xterm-check: $(XTERM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(XTERM_IPK)
