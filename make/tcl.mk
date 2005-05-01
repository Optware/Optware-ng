###########################################################
#
# tcl
#
###########################################################

# You must replace "tcl" and "TCL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TCL_VERSION, TCL_SITE and TCL_SOURCE define
# the upstream location of the source code for the package.
# TCL_DIR is the directory which is created when the source
# archive is unpacked.
# TCL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
TCL_SITE=http://puzzle.dl.sourceforge.net/sourceforge/tcl/
TCL_VERSION=8.4.9
TCL_SOURCE=tcl$(TCL_VERSION)-src.tar.gz
TCL_DIR=tcl$(TCL_VERSION)
TCL_UNZIP=zcat

#
# TCL_IPK_VERSION should be incremented when the ipk changes.
#
TCL_IPK_VERSION=1

#
# TCL_CONFFILES should be a list of user-editable files
#TCL_CONFFILES=/opt/etc/tcl.conf /opt/etc/init.d/SXXtcl

#
# TCL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TCL_PATCHES=$(TCL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TCL_CPPFLAGS=
TCL_LDFLAGS=

#
# TCL_BUILD_DIR is the directory in which the build is done.
# TCL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TCL_IPK_DIR is the directory in which the ipk is built.
# TCL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TCL_BUILD_DIR=$(BUILD_DIR)/tcl
TCL_SOURCE_DIR=$(SOURCE_DIR)/tcl
TCL_IPK_DIR=$(BUILD_DIR)/tcl-$(TCL_VERSION)-ipk
TCL_IPK=$(BUILD_DIR)/tcl_$(TCL_VERSION)-$(TCL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TCL_SOURCE):
	$(WGET) -P $(DL_DIR) $(TCL_SITE)/$(TCL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tcl-source: $(DL_DIR)/$(TCL_SOURCE) $(TCL_PATCHES)

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
$(TCL_BUILD_DIR)/.configured: $(DL_DIR)/$(TCL_SOURCE) $(TCL_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TCL_DIR) $(TCL_BUILD_DIR)
	$(TCL_UNZIP) $(DL_DIR)/$(TCL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(TCL_PATCHES) | patch -d $(BUILD_DIR)/$(TCL_DIR) -p1
	mv $(BUILD_DIR)/$(TCL_DIR) $(TCL_BUILD_DIR)
	(cd $(TCL_BUILD_DIR)/unix; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TCL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TCL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(TCL_BUILD_DIR)/.configured

tcl-unpack: $(TCL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TCL_BUILD_DIR)/.built: $(TCL_BUILD_DIR)/.configured
	rm -f $(TCL_BUILD_DIR)/.built
	$(MAKE) -C $(TCL_BUILD_DIR)/unix
	touch $(TCL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tcl: $(TCL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TCL_BUILD_DIR)/.staged: $(TCL_BUILD_DIR)/.built
	rm -f $(TCL_BUILD_DIR)/.staged
	$(MAKE) -C $(TCL_BUILD_DIR)/unix DESTDIR=$(STAGING_DIR) install
	touch $(TCL_BUILD_DIR)/.staged

tcl-stage: $(TCL_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(TCL_IPK_DIR)/opt/sbin or $(TCL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TCL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TCL_IPK_DIR)/opt/etc/tcl/...
# Documentation files should be installed in $(TCL_IPK_DIR)/opt/doc/tcl/...
# Daemon startup scripts should be installed in $(TCL_IPK_DIR)/opt/etc/init.d/S??tcl
#
# You may need to patch your application to make it use these locations.
#
$(TCL_IPK): $(TCL_BUILD_DIR)/.built
	rm -rf $(TCL_IPK_DIR) $(BUILD_DIR)/tcl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TCL_BUILD_DIR)/unix INSTALL_ROOT=$(TCL_IPK_DIR) install
	install -d $(TCL_IPK_DIR)/CONTROL
	install -m 644 $(TCL_SOURCE_DIR)/control $(TCL_IPK_DIR)/CONTROL/control
	echo $(TCL_CONFFILES) | sed -e 's/ /\n/g' > $(TCL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tcl-ipk: $(TCL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tcl-clean:
	-$(MAKE) -C $(TCL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tcl-dirclean:
	rm -rf $(BUILD_DIR)/$(TCL_DIR) $(TCL_BUILD_DIR) $(TCL_IPK_DIR) $(TCL_IPK)
