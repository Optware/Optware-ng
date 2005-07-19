###########################################################
#
# taged
#
###########################################################
#
# TAGED_VERSION, TAGED_SITE and TAGED_SOURCE define
# the upstream location of the source code for the package.
# TAGED_DIR is the directory which is created when the source
# archive is unpacked.
# TAGED_UNZIP is the command used to unzip the source.
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
TAGED_SITE=http://www.stacken.kth.se/~mhe/
TAGED_VERSION=3.0
TAGED_SOURCE=taged-$(TAGED_VERSION).tar.gz
TAGED_DIR=taged-$(TAGED_VERSION)
TAGED_UNZIP=zcat
TAGED_MAINTAINER=Bernhard Walle <bernhard.walle@gmx.de>
TAGED_DESCRIPTION=command line utility that can create and modify ID3 data
TAGED_SECTION=util
TAGED_PRIORITY=optional
TAGED_DEPENDS=libid3tag, readline, ncurses
TAGED_SUGGESTS=
TAGED_CONFLICTS=

#
# TAGED_IPK_VERSION should be incremented when the ipk changes.
#
TAGED_IPK_VERSION=1

#
# TAGED_CONFFILES should be a list of user-editable files
TAGED_CONFFILES=

#
# TAGED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TAGED_PATCHES=$(TAGED_SOURCE_DIR)/configure.ac.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TAGED_CPPFLAGS=
TAGED_LDFLAGS=

#
# TAGED_BUILD_DIR is the directory in which the build is done.
# TAGED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TAGED_IPK_DIR is the directory in which the ipk is built.
# TAGED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TAGED_BUILD_DIR=$(BUILD_DIR)/taged
TAGED_SOURCE_DIR=$(SOURCE_DIR)/taged
TAGED_IPK_DIR=$(BUILD_DIR)/taged-$(TAGED_VERSION)-ipk
TAGED_IPK=$(BUILD_DIR)/taged_$(TAGED_VERSION)-$(TAGED_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TAGED_SOURCE):
	$(WGET) -P $(DL_DIR) $(TAGED_SITE)/$(TAGED_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
taged-source: $(DL_DIR)/$(TAGED_SOURCE) $(TAGED_PATCHES)

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
$(TAGED_BUILD_DIR)/.configured: $(DL_DIR)/$(TAGED_SOURCE) $(TAGED_PATCHES)
	$(MAKE) libid3tag-stage readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(TAGED_DIR) $(TAGED_BUILD_DIR)
	$(TAGED_UNZIP) $(DL_DIR)/$(TAGED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(TAGED_PATCHES) | patch -d $(BUILD_DIR)/$(TAGED_DIR) -p1
	mv $(BUILD_DIR)/$(TAGED_DIR) $(TAGED_BUILD_DIR)
	(cd $(TAGED_BUILD_DIR); \
	    cd confuse ; \
	    ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -v ; \
		libtoolize --force ;\
		cd - ; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TAGED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TAGED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(TAGED_BUILD_DIR)/confuse/libtool
	touch $(TAGED_BUILD_DIR)/.configured

taged-unpack: $(TAGED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TAGED_BUILD_DIR)/.built: $(TAGED_BUILD_DIR)/.configured
	rm -f $(TAGED_BUILD_DIR)/.built
	$(MAKE) -C $(TAGED_BUILD_DIR)
	touch $(TAGED_BUILD_DIR)/.built

#
# This is the build convenience target.
#
taged: $(TAGED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TAGED_BUILD_DIR)/.staged: $(TAGED_BUILD_DIR)/.built
	rm -f $(TAGED_BUILD_DIR)/.staged
	$(MAKE) -C $(TAGED_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TAGED_BUILD_DIR)/.staged

taged-stage: $(TAGED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/taged
#
$(TAGED_IPK_DIR)/CONTROL/control:
	@install -d $(TAGED_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: taged" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TAGED_PRIORITY)" >>$@
	@echo "Section: $(TAGED_SECTION)" >>$@
	@echo "Version: $(TAGED_VERSION)-$(TAGED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TAGED_MAINTAINER)" >>$@
	@echo "Source: $(TAGED_SITE)/$(TAGED_SOURCE)" >>$@
	@echo "Description: $(TAGED_DESCRIPTION)" >>$@
	@echo "Depends: $(TAGED_DEPENDS)" >>$@
	@echo "Suggests: $(TAGED_SUGGESTS)" >>$@
	@echo "Conflicts: $(TAGED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TAGED_IPK_DIR)/opt/sbin or $(TAGED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TAGED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TAGED_IPK_DIR)/opt/etc/taged/...
# Documentation files should be installed in $(TAGED_IPK_DIR)/opt/doc/taged/...
# Daemon startup scripts should be installed in $(TAGED_IPK_DIR)/opt/etc/init.d/S??taged
#
# You may need to patch your application to make it use these locations.
#
$(TAGED_IPK): $(TAGED_BUILD_DIR)/.built
	rm -rf $(TAGED_IPK_DIR) $(BUILD_DIR)/taged_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TAGED_BUILD_DIR) DESTDIR=$(TAGED_IPK_DIR) install-strip
	$(MAKE) $(TAGED_IPK_DIR)/CONTROL/control
	echo $(TAGED_CONFFILES) | sed -e 's/ /\n/g' > $(TAGED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TAGED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
taged-ipk: $(TAGED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
taged-clean:
	-$(MAKE) -C $(TAGED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
taged-dirclean:
	rm -rf $(BUILD_DIR)/$(TAGED_DIR) $(TAGED_BUILD_DIR) $(TAGED_IPK_DIR) $(TAGED_IPK)
