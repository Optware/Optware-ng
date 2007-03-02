###########################################################
#
# hexcurse
#
###########################################################

#
# HEXCURSE_VERSION, HEXCURSE_SITE and HEXCURSE_SOURCE define
# the upstream location of the source code for the package.
# HEXCURSE_DIR is the directory which is created when the source
# archive is unpacked.
# HEXCURSE_UNZIP is the command used to unzip the source.
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
HEXCURSE_SITE=http://www.jewfish.net/description.php?title=HexCurse
HEXCURSE_URL=http://ftp.debian.org/debian/pool/main/h/hexcurse/hexcurse_1.55.orig.tar.gz
HEXCURSE_VERSION=1.55
HEXCURSE_SOURCE=hexcurse_$(HEXCURSE_VERSION).orig.tar.gz
HEXCURSE_DIR=hexcurse-$(HEXCURSE_VERSION)
HEXCURSE_UNZIP=zcat
HEXCURSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HEXCURSE_DESCRIPTION=A versatile ncurses-based hex editor.
HEXCURSE_SECTION=misc
HEXCURSE_PRIORITY=optional
HEXCURSE_DEPENDS=ncurses
HEXCURSE_SUGGESTS=
HEXCURSE_CONFLICTS=

#
# HEXCURSE_IPK_VERSION should be incremented when the ipk changes.
#
HEXCURSE_IPK_VERSION=2

#
# HEXCURSE_CONFFILES should be a list of user-editable files
#HEXCURSE_CONFFILES=/opt/etc/hexcurse.conf /opt/etc/init.d/SXXhexcurse

#
# HEXCURSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HEXCURSE_PATCHES=$(HEXCURSE_SOURCE_DIR)/getopt.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HEXCURSE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
HEXCURSE_LDFLAGS=

#
# HEXCURSE_BUILD_DIR is the directory in which the build is done.
# HEXCURSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HEXCURSE_IPK_DIR is the directory in which the ipk is built.
# HEXCURSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HEXCURSE_BUILD_DIR=$(BUILD_DIR)/hexcurse
HEXCURSE_SOURCE_DIR=$(SOURCE_DIR)/hexcurse
HEXCURSE_IPK_DIR=$(BUILD_DIR)/hexcurse-$(HEXCURSE_VERSION)-ipk
HEXCURSE_IPK=$(BUILD_DIR)/hexcurse_$(HEXCURSE_VERSION)-$(HEXCURSE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HEXCURSE_SOURCE):
	$(WGET) -P $(DL_DIR) $(HEXCURSE_URL)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hexcurse-source: $(DL_DIR)/$(HEXCURSE_SOURCE) $(HEXCURSE_PATCHES)

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
$(HEXCURSE_BUILD_DIR)/.configured: $(DL_DIR)/$(HEXCURSE_SOURCE) $(HEXCURSE_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(HEXCURSE_DIR) $(HEXCURSE_BUILD_DIR)
	$(HEXCURSE_UNZIP) $(DL_DIR)/$(HEXCURSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(HEXCURSE_PATCHES) | patch -d $(BUILD_DIR)/$(HEXCURSE_DIR) -p1
	mv $(BUILD_DIR)/$(HEXCURSE_DIR) $(HEXCURSE_BUILD_DIR)
	(cd $(HEXCURSE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HEXCURSE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HEXCURSE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(HEXCURSE_BUILD_DIR)/.configured

hexcurse-unpack: $(HEXCURSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HEXCURSE_BUILD_DIR)/.built: $(HEXCURSE_BUILD_DIR)/.configured
	rm -f $(HEXCURSE_BUILD_DIR)/.built
	$(MAKE) -C $(HEXCURSE_BUILD_DIR)
	touch $(HEXCURSE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
hexcurse: $(HEXCURSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HEXCURSE_BUILD_DIR)/.staged: $(HEXCURSE_BUILD_DIR)/.built
	rm -f $(HEXCURSE_BUILD_DIR)/.staged
	$(MAKE) -C $(HEXCURSE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(HEXCURSE_BUILD_DIR)/.staged

hexcurse-stage: $(HEXCURSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hexcurse
#
$(HEXCURSE_IPK_DIR)/CONTROL/control:
	@install -d $(HEXCURSE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: hexcurse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HEXCURSE_PRIORITY)" >>$@
	@echo "Section: $(HEXCURSE_SECTION)" >>$@
	@echo "Version: $(HEXCURSE_VERSION)-$(HEXCURSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HEXCURSE_MAINTAINER)" >>$@
	@echo "Source: $(HEXCURSE_SITE)/$(HEXCURSE_SOURCE)" >>$@
	@echo "Description: $(HEXCURSE_DESCRIPTION)" >>$@
	@echo "Depends: $(HEXCURSE_DEPENDS)" >>$@
	@echo "Suggests: $(HEXCURSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(HEXCURSE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HEXCURSE_IPK_DIR)/opt/sbin or $(HEXCURSE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HEXCURSE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HEXCURSE_IPK_DIR)/opt/etc/hexcurse/...
# Documentation files should be installed in $(HEXCURSE_IPK_DIR)/opt/doc/hexcurse/...
# Daemon startup scripts should be installed in $(HEXCURSE_IPK_DIR)/opt/etc/init.d/S??hexcurse
#
# You may need to patch your application to make it use these locations.
#
$(HEXCURSE_IPK): $(HEXCURSE_BUILD_DIR)/.built
	rm -rf $(HEXCURSE_IPK_DIR) $(BUILD_DIR)/hexcurse_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HEXCURSE_BUILD_DIR) DESTDIR=$(HEXCURSE_IPK_DIR) install
	$(STRIP_COMMAND) $(HEXCURSE_IPK_DIR)/opt/bin/hexcurse
	$(MAKE) $(HEXCURSE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HEXCURSE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hexcurse-ipk: $(HEXCURSE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hexcurse-clean:
	-$(MAKE) -C $(HEXCURSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hexcurse-dirclean:
	rm -rf $(BUILD_DIR)/$(HEXCURSE_DIR) $(HEXCURSE_BUILD_DIR) $(HEXCURSE_IPK_DIR) $(HEXCURSE_IPK)
