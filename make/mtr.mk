###########################################################
#
# mtr
#
###########################################################

#
# MTR_VERSION, MTR_SITE and MTR_SOURCE define
# the upstream location of the source code for the package.
# MTR_DIR is the directory which is created when the source
# archive is unpacked.
# MTR_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MTR_SITE=ftp://ftp.bitwizard.nl/mtr
MTR_VERSION=0.69
MTR_SOURCE=mtr-$(MTR_VERSION).tar.gz
MTR_DIR=mtr-$(MTR_VERSION)
MTR_UNZIP=zcat

#
# MTR_IPK_VERSION should be incremented when the ipk changes.
#
MTR_IPK_VERSION=1

#
# MTR_CONFFILES should be a list of user-editable files
MTR_CONFFILES=

#
# MTR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MTR_PATCHES=$(MTR_SOURCE_DIR)/configure.patch
MTR_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MTR_CPPFLAGS=
MTR_LDFLAGS=

#
# MTR_BUILD_DIR is the directory in which the build is done.
# MTR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MTR_IPK_DIR is the directory in which the ipk is built.
# MTR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MTR_BUILD_DIR=$(BUILD_DIR)/mtr
MTR_SOURCE_DIR=$(SOURCE_DIR)/mtr
MTR_IPK_DIR=$(BUILD_DIR)/mtr-$(MTR_VERSION)-ipk
MTR_IPK=$(BUILD_DIR)/mtr_$(MTR_VERSION)-$(MTR_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MTR_SOURCE):
	$(WGET) -P $(DL_DIR) $(MTR_SITE)/$(MTR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mtr-source: $(DL_DIR)/$(MTR_SOURCE) $(MTR_PATCHES)

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
$(MTR_BUILD_DIR)/.configured: $(DL_DIR)/$(MTR_SOURCE) $(MTR_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(MTR_DIR) $(MTR_BUILD_DIR)
	$(MTR_UNZIP) $(DL_DIR)/$(MTR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MTR_PATCHES) | patch -d $(BUILD_DIR)/$(MTR_DIR) -p1
	mv $(BUILD_DIR)/$(MTR_DIR) $(MTR_BUILD_DIR)
	(cd $(MTR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MTR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MTR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--without-gtk \
	)
	touch $(MTR_BUILD_DIR)/.configured

mtr-unpack: $(MTR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MTR_BUILD_DIR)/.built: $(MTR_BUILD_DIR)/.configured
	rm -f $(MTR_BUILD_DIR)/.built
	$(MAKE) -C $(MTR_BUILD_DIR)
	touch $(MTR_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mtr: $(MTR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MTR_BUILD_DIR)/.staged: $(MTR_BUILD_DIR)/.built
	rm -f $(MTR_BUILD_DIR)/.staged
	$(MAKE) -C $(MTR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MTR_BUILD_DIR)/.staged

mtr-stage: $(MTR_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(MTR_IPK_DIR)/opt/sbin or $(MTR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MTR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MTR_IPK_DIR)/opt/etc/mtr/...
# Documentation files should be installed in $(MTR_IPK_DIR)/opt/doc/mtr/...
# Daemon startup scripts should be installed in $(MTR_IPK_DIR)/opt/etc/init.d/S??mtr
#
# You may need to patch your application to make it use these locations.
#
$(MTR_IPK): $(MTR_BUILD_DIR)/.built
	rm -rf $(MTR_IPK_DIR) $(BUILD_DIR)/mtr_*_armeb.ipk
	$(MAKE) -C $(MTR_BUILD_DIR) DESTDIR=$(MTR_IPK_DIR) install
#	install -d $(MTR_IPK_DIR)/opt/etc/
#	install -m 755 $(MTR_SOURCE_DIR)/mtr.conf $(MTR_IPK_DIR)/opt/etc/mtr.conf
#	install -d $(MTR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MTR_SOURCE_DIR)/rc.mtr $(MTR_IPK_DIR)/opt/etc/init.d/SXXmtr
	install -d $(MTR_IPK_DIR)/CONTROL
	install -m 644 $(MTR_SOURCE_DIR)/control $(MTR_IPK_DIR)/CONTROL/control
#	install -m 644 $(MTR_SOURCE_DIR)/postinst $(MTR_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(MTR_SOURCE_DIR)/prerm $(MTR_IPK_DIR)/CONTROL/prerm
#	echo $(MTR_CONFFILES) | sed -e 's/ /\n/g' > $(MTR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MTR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mtr-ipk: $(MTR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mtr-clean:
	-$(MAKE) -C $(MTR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mtr-dirclean:
	rm -rf $(BUILD_DIR)/$(MTR_DIR) $(MTR_BUILD_DIR) $(MTR_IPK_DIR) $(MTR_IPK)
