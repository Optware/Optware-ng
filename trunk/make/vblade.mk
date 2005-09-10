###########################################################
#
# vblade
#
###########################################################
#
# $Header$
#


# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
VBLADE_SITE=http://dl.sourceforge.net/sourceforge/aoetools
VBLADE_VERSION=6
VBLADE_SOURCE=vblade-$(VBLADE_VERSION).tar.gz
VBLADE_DIR=vblade-$(VBLADE_VERSION)
VBLADE_UNZIP=zcat
VBLADE_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
VBLADE_DESCRIPTION=vblade makes a seekable file available over ATA over Ethernet
VBLADE_SECTION=net
VBLADE_PRIORITY=optional
VBLADE_DEPENDS=
VBLADE_SUGGESTS=
VBLADE_CONFLICTS=

#
# VBLADE_IPK_VERSION should be incremented when the ipk changes.
#
VBLADE_IPK_VERSION=3

#
# VBLADE_CONFFILES should be a list of user-editable files
VBLADE_CONFFILES=""

#
# VBLADE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VBLADE_PATCHES=$(VBLADE_SOURCE_DIR)/vblade-u64.patch $(VBLADE_SOURCE_DIR)/cross-compile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VBLADE_CPPFLAGS=
VBLADE_LDFLAGS=

#
# VBLADE_BUILD_DIR is the directory in which the build is done.
# VBLADE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VBLADE_IPK_DIR is the directory in which the ipk is built.
# VBLADE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VBLADE_BUILD_DIR=$(BUILD_DIR)/vblade
VBLADE_SOURCE_DIR=$(SOURCE_DIR)/vblade
VBLADE_IPK_DIR=$(BUILD_DIR)/vblade-$(VBLADE_VERSION)-ipk
VBLADE_IPK=$(BUILD_DIR)/vblade_$(VBLADE_VERSION)-$(VBLADE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VBLADE_SOURCE):
	$(WGET) -P $(DL_DIR) $(VBLADE_SITE)/$(VBLADE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vblade-source: $(DL_DIR)/$(VBLADE_SOURCE) $(VBLADE_PATCHES)

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
$(VBLADE_BUILD_DIR)/.configured: $(DL_DIR)/$(VBLADE_SOURCE) $(VBLADE_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(VBLADE_DIR) $(VBLADE_BUILD_DIR)
	$(VBLADE_UNZIP) $(DL_DIR)/$(VBLADE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(VBLADE_PATCHES) | patch -d $(BUILD_DIR)/$(VBLADE_DIR) -p1
	mv $(BUILD_DIR)/$(VBLADE_DIR) $(VBLADE_BUILD_DIR)
	#(cd $(VBLADE_BUILD_DIR); \
	#$(TARGET_CONFIGURE_OPTS) \
	#	CPPFLAGS="$(STAGING_CPPFLAGS) $(VBLADE_CPPFLAGS)" \
	#	LDFLAGS="$(STAGING_LDFLAGS) $(VBLADE_LDFLAGS)" \
	#	./configure \
	#	--build=$(GNU_HOST_NAME) \
	#	--host=$(GNU_TARGET_NAME) \
	#	--target=$(GNU_TARGET_NAME) \
	#	--prefix=/opt \
	#	--disable-nls \
	#)
	touch $(VBLADE_BUILD_DIR)/.configured

vblade-unpack: $(VBLADE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VBLADE_BUILD_DIR)/.built: $(VBLADE_BUILD_DIR)/.configured
	rm -f $(VBLADE_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VBLADE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VBLADE_LDFLAGS)" \
		$(MAKE) -C $(VBLADE_BUILD_DIR)
	touch $(VBLADE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
vblade: $(VBLADE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VBLADE_BUILD_DIR)/.staged: $(VBLADE_BUILD_DIR)/.built
	rm -f $(VBLADE_BUILD_DIR)/.staged
	$(MAKE) -C $(VBLADE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(VBLADE_BUILD_DIR)/.staged

vblade-stage: $(VBLADE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vblade
#
$(VBLADE_IPK_DIR)/CONTROL/control:
	@install -d $(VBLADE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: vblade" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VBLADE_PRIORITY)" >>$@
	@echo "Section: $(VBLADE_SECTION)" >>$@
	@echo "Version: $(VBLADE_VERSION)-$(VBLADE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VBLADE_MAINTAINER)" >>$@
	@echo "Source: $(VBLADE_SITE)/$(VBLADE_SOURCE)" >>$@
	@echo "Description: $(VBLADE_DESCRIPTION)" >>$@
	@echo "Depends: $(VBLADE_DEPENDS)" >>$@
	@echo "Suggests: $(VBLADE_SUGGESTS)" >>$@
	@echo "Conflicts: $(VBLADE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VBLADE_IPK_DIR)/opt/sbin or $(VBLADE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VBLADE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VBLADE_IPK_DIR)/opt/etc/vblade/...
# Documentation files should be installed in $(VBLADE_IPK_DIR)/opt/doc/vblade/...
# Daemon startup scripts should be installed in $(VBLADE_IPK_DIR)/opt/etc/init.d/S??vblade
#
# You may need to patch your application to make it use these locations.
#
$(VBLADE_IPK): $(VBLADE_BUILD_DIR)/.built
	rm -rf $(VBLADE_IPK_DIR) $(BUILD_DIR)/vblade_*_$(TARGET_ARCH).ipk
	mkdir -p $(VBLADE_IPK_DIR)/opt/sbin
	install -m 755 $(VBLADE_BUILD_DIR)/vblade $(VBLADE_IPK_DIR)/opt/sbin
	$(MAKE) $(VBLADE_IPK_DIR)/CONTROL/control
	$(STRIP_COMMAND) $(VBLADE_IPK_DIR)/opt/sbin/vblade
	echo $(VBLADE_CONFFILES) | sed -e 's/ /\n/g' > $(VBLADE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VBLADE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vblade-ipk: $(VBLADE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vblade-clean:
	-$(MAKE) -C $(VBLADE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vblade-dirclean:
	rm -rf $(BUILD_DIR)/$(VBLADE_DIR) $(VBLADE_BUILD_DIR) $(VBLADE_IPK_DIR) $(VBLADE_IPK)
