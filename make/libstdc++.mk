###########################################################
#
# libstdc++
#
###########################################################

# You must replace "libstdc++" and "LIBSTDC++" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBSTDC++_VERSION, LIBSTDC++_SITE and LIBSTDC++_SOURCE define
# the upstream location of the source code for the package.
# LIBSTDC++_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSTDC++_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
#LIBSTDC++_SITE=http://www.libstdc++.org/downloads
LIBSTDC++_VERSION=5.0.7
#LIBSTDC++_SOURCE=libstdc++-$(LIBSTDC++_VERSION).tar.gz
LIBSTDC++_DIR=libstdc++-$(LIBSTDC++_VERSION)
LIBSTDC++_LIBNAME=libstdc++.so
LIBSTDC++_UNZIP=zcat

#
# LIBSTDC++_IPK_VERSION should be incremented when the ipk changes.
#
LIBSTDC++_IPK_VERSION=1

#
# LIBSTDC++_CONFFILES should be a list of user-editable files
LIBSTDC++_CONFFILES=

#
# LIBSTDC++_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBSTDC++_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSTDC++_CPPFLAGS=
LIBSTDC++_LDFLAGS=

#
# LIBSTDC++_BUILD_DIR is the directory in which the build is done.
# LIBSTDC++_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSTDC++_IPK_DIR is the directory in which the ipk is built.
# LIBSTDC++_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSTDC++_BUILD_DIR=$(BUILD_DIR)/libstdc++
LIBSTDC++_SOURCE_DIR=$(SOURCE_DIR)/libstdc++
LIBSTDC++_IPK_DIR=$(BUILD_DIR)/libstdc++-$(LIBSTDC++_VERSION)-ipk
LIBSTDC++_IPK=$(BUILD_DIR)/libstdc++_$(LIBSTDC++_VERSION)-$(LIBSTDC++_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(LIBSTDC++_SOURCE):
#	$(WGET) -P $(DL_DIR) $(LIBSTDC++_SITE)/$(LIBSTDC++_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#libstdc++-source: $(DL_DIR)/$(LIBSTDC++_SOURCE) $(LIBSTDC++_PATCHES)
libstdc++-source: $(LIBSTDC++_PATCHES)

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
$(LIBSTDC++_BUILD_DIR)/.configured: $(LIBSTDC++_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBSTDC++_DIR) $(LIBSTDC++_BUILD_DIR)
	mkdir -p $(LIBSTDC++_BUILD_DIR)
	touch $(LIBSTDC++_BUILD_DIR)/.configured

libstdc++-unpack: $(LIBSTDC++_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSTDC++_BUILD_DIR)/.built: $(LIBSTDC++_BUILD_DIR)/.configured
	rm -f $(LIBSTDC++_BUILD_DIR)/.built
	cp $(TARGET_LIBDIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_BUILD_DIR)/
	touch $(LIBSTDC++_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libstdc++: $(LIBSTDC++_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSTDC++_BUILD_DIR)/.staged: $(LIBSTDC++_BUILD_DIR)/.built
	rm -f $(LIBSTDC++_BUILD_DIR)/.staged
#	$(MAKE) -C $(LIBSTDC++_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBSTDC++_BUILD_DIR)/.staged

libstdc++-stage: $(LIBSTDC++_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSTDC++_IPK_DIR)/opt/sbin or $(LIBSTDC++_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSTDC++_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBSTDC++_IPK_DIR)/opt/etc/libstdc++/...
# Documentation files should be installed in $(LIBSTDC++_IPK_DIR)/opt/doc/libstdc++/...
# Daemon startup scripts should be installed in $(LIBSTDC++_IPK_DIR)/opt/etc/init.d/S??libstdc++
#
# You may need to patch your application to make it use these locations.
#
$(LIBSTDC++_IPK): $(LIBSTDC++_BUILD_DIR)/.built
	rm -rf $(LIBSTDC++_IPK_DIR) $(BUILD_DIR)/libstdc++_*_armeb.ipk
	install -d $(LIBSTDC++_IPK_DIR)/opt/lib
	install -m 644 $(LIBSTDC++_BUILD_DIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_IPK_DIR)/opt/lib
	(cd $(LIBSTDC++_IPK_DIR)/opt/lib; \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME); \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME).5 \
	)
	install -d $(LIBSTDC++_IPK_DIR)/CONTROL
	install -m 644 $(LIBSTDC++_SOURCE_DIR)/control $(LIBSTDC++_IPK_DIR)/CONTROL/control
#	install -m 644 $(LIBSTDC++_SOURCE_DIR)/postinst $(LIBSTDC++_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(LIBSTDC++_SOURCE_DIR)/prerm $(LIBSTDC++_IPK_DIR)/CONTROL/prerm
#	echo $(LIBSTDC++_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSTDC++_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSTDC++_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libstdc++-ipk: $(LIBSTDC++_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libstdc++-clean:
	rm -rf $(LIBSTDC++_BUILD_DIR)/*

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libstdc++-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSTDC++_DIR) $(LIBSTDC++_BUILD_DIR) $(LIBSTDC++_IPK_DIR) $(LIBSTDC++_IPK)
