###########################################################
#
# which
#
###########################################################

# You must replace "which" and "WHICH" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WHICH_VERSION, WHICH_SITE and WHICH_SOURCE define
# the upstream location of the source code for the package.
# WHICH_DIR is the directory which is created when the source
# archive is unpacked.
# WHICH_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
WHICH_SITE=http://www.xs4all.nl/~carlo17/which
WHICH_VERSION=2.16
WHICH_SOURCE=which-2.16.tar.gz
WHICH_DIR=which-2.16
WHICH_UNZIP=zcat

#
# WHICH_IPK_VERSION should be incremented when the ipk changes.
#
WHICH_IPK_VERSION=1

#
# WHICH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#WHICH_PATCHES=$(WHICH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WHICH_CPPFLAGS=
WHICH_LDFLAGS=

#
# WHICH_BUILD_DIR is the directory in which the build is done.
# WHICH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WHICH_IPK_DIR is the directory in which the ipk is built.
# WHICH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WHICH_BUILD_DIR=$(BUILD_DIR)/which
WHICH_SOURCE_DIR=$(SOURCE_DIR)/which
WHICH_IPK_DIR=$(BUILD_DIR)/which-$(WHICH_VERSION)-ipk
WHICH_IPK=$(BUILD_DIR)/which_$(WHICH_VERSION)-$(WHICH_IPK_VERSION)_$(TARGET_ARCH).ipk

WHICH_INST_DIR=/opt
WHICH_BIN_DIR=$(WHICH_INST_DIR)/bin
WHICH_SBIN_DIR=$(WHICH_INST_DIR)/sbin
WHICH_LIBEXEC_DIR=$(WHICH_INST_DIR)/libexec
WHICH_DATA_DIR=$(WHICH_INST_DIR)/share/which
WHICH_SYSCONF_DIR=$(WHICH_INST_DIR)/etc/which
WHICH_SHAREDSTATE_DIR=$(WHICH_INST_DIR)/com/which
WHICH_LOCALSTATE_DIR=$(WHICH_INST_DIR)/var/which
WHICH_LIB_DIR=$(WHICH_INST_DIR)/lib
WHICH_INCLUDE_DIR=$(WHICH_INST_DIR)/include
WHICH_INFO_DIR=$(WHICH_INST_DIR)/info
WHICH_MAN_DIR=$(WHICH_INST_DIR)/man


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WHICH_SOURCE):
	$(WGET) -P $(DL_DIR) $(WHICH_SITE)/$(WHICH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
which-source: $(DL_DIR)/$(WHICH_SOURCE) $(WHICH_PATCHES)

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
$(WHICH_BUILD_DIR)/.configured: $(DL_DIR)/$(WHICH_SOURCE) $(WHICH_PATCHES)
	rm -rf $(BUILD_DIR)/$(WHICH_DIR) $(WHICH_BUILD_DIR)
	$(WHICH_UNZIP) $(DL_DIR)/$(WHICH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(WHICH_DIR) $(WHICH_BUILD_DIR)
	(cd $(WHICH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WHICH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WHICH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(WHICH_INST_DIR) \
		--bindir=$(WHICH_BIN_DIR) \
		--sbindir=$(WHICH_SBIN_DIR) \
		--libexecdir=$(WHICH_LIBEXEC_DIR) \
		--datadir=$(WHICH_DATA_DIR) \
		--sysconfdir=$(WHICH_SYSCONF_DIR) \
		--sharedstatedir=$(WHICH_SHAREDSTATE_DIR) \
		--localstatedir=$(WHICH_LOCALSTATE_DIR) \
		--libdir=$(WHICH_LIB_DIR) \
		--includedir=$(WHICH_INCLUDE_DIR) \
		--oldincludedir=$(WHICH_INCLUDE_DIR) \
		--infodir=$(WHICH_INFO_DIR) \
		--mandir=$(WHICH_MAN_DIR) \
		--disable-nls \
	)
	touch $(WHICH_BUILD_DIR)/.configured

which-unpack: $(WHICH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WHICH_BUILD_DIR)/.built: $(WHICH_BUILD_DIR)/.configured
	rm -f $(WHICH_BUILD_DIR)/.built
	$(MAKE) -C $(WHICH_BUILD_DIR)
	touch $(WHICH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
which: $(WHICH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WHICH_BUILD_DIR)/.staged: $(WHICH_BUILD_DIR)/.built
	rm -f $(WHICH_BUILD_DIR)/.staged
	$(MAKE) -C $(WHICH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(WHICH_BUILD_DIR)/.staged

which-stage: $(WHICH_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(WHICH_IPK_DIR)/opt/sbin or $(WHICH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WHICH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WHICH_IPK_DIR)/opt/etc/which/...
# Documentation files should be installed in $(WHICH_IPK_DIR)/opt/doc/which/...
# Daemon startup scripts should be installed in $(WHICH_IPK_DIR)/opt/etc/init.d/S??which
#
# You may need to patch your application to make it use these locations.
#
$(WHICH_IPK): $(WHICH_BUILD_DIR)/.built
	rm -rf $(WHICH_IPK_DIR) $(BUILD_DIR)/which_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WHICH_BUILD_DIR) DESTDIR=$(WHICH_IPK_DIR) install
	install -d $(WHICH_IPK_DIR)/CONTROL
	install -m 644 $(WHICH_SOURCE_DIR)/control $(WHICH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WHICH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
which-ipk: $(WHICH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
which-clean:
	-$(MAKE) -C $(WHICH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
which-dirclean:
	rm -rf $(BUILD_DIR)/$(WHICH_DIR) $(WHICH_BUILD_DIR) $(WHICH_IPK_DIR) $(WHICH_IPK)
