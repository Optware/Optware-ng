###########################################################
#
# libdvb
#
###########################################################

# You must replace "libdvb" and "LIBDVB" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBDVB_VERSION, LIBDVB_SITE and LIBDVB_SOURCE define
# the upstream location of the source code for the package.
# LIBDVB_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDVB_UNZIP is the command used to unzip the source.
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
LIBDVB_SITE=http://www.metzlerbros.org/dvb
LIBDVB_VERSION=0.5.5.1
LIBDVB_SOURCE=libdvb-$(LIBDVB_VERSION).tar.gz
LIBDVB_DIR=libdvb-$(LIBDVB_VERSION)
LIBDVB_UNZIP=zcat
LIBDVB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDVB_DESCRIPTION=Linux DVB library
LIBDVB_SECTION=libs
LIBDVB_PRIORITY=optional
LIBDVB_DEPENDS=libstdc++
LIBDVB_SUGGESTS=
LIBDVB_CONFLICTS=

LIBDVB_HEADERS_VERSION=20050311
LIBDVB_HEADERS_SOURCE=DVB-$(LIBDVB_HEADERS_VERSION).tar.gz
LIBDVB_HEADERS_DIR=DVB

#
# LIBDVB_IPK_VERSION should be incremented when the ipk changes.
#
LIBDVB_IPK_VERSION=1

#
# LIBDVB_CONFFILES should be a list of user-editable files
LIBDVB_CONFFILES=

#
# LIBDVB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBDVB_PATCHES=$(LIBDVB_SOURCE_DIR)/topf2ps.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDVB_CPPFLAGS=-I. -I../include -I$(BUILD_DIR)/libdvb/$(LIBDVB_HEADERS_DIR)/include
LIBDVB_LDFLAGS=

#
# LIBDVB_BUILD_DIR is the directory in which the build is done.
# LIBDVB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDVB_IPK_DIR is the directory in which the ipk is built.
# LIBDVB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDVB_BUILD_DIR=$(BUILD_DIR)/libdvb
LIBDVB_SOURCE_DIR=$(SOURCE_DIR)/libdvb
LIBDVB_IPK_DIR=$(BUILD_DIR)/libdvb-$(LIBDVB_VERSION)-ipk
LIBDVB_IPK=$(BUILD_DIR)/libdvb_$(LIBDVB_VERSION)-$(LIBDVB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDVB_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDVB_SITE)/$(LIBDVB_SOURCE)

$(DL_DIR)/$(LIBDVB_HEADERS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDVB_SITE)/$(LIBDVB_HEADERS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdvb-source: $(DL_DIR)/$(LIBDVB_SOURCE) $(DL_DIR)/$(LIBDVB_HEADERS_SOURCE) $(LIBDVB_PATCHES)

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
$(LIBDVB_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDVB_SOURCE) $(LIBDVB_PATCHES)
#	$(MAKE) dvb-kernel-stage
	rm -rf $(BUILD_DIR)/$(LIBDVB_DIR) $(LIBDVB_BUILD_DIR)
	$(LIBDVB_UNZIP) $(DL_DIR)/$(LIBDVB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	$(LIBDVB_UNZIP) $(DL_DIR)/$(LIBDVB_HEADERS_SOURCE) | tar -C $(BUILD_DIR)/$(LIBDVB_DIR) -xvf -
	cat $(LIBDVB_PATCHES) | patch -d $(BUILD_DIR)/$(LIBDVB_DIR) -p1
	mv $(BUILD_DIR)/$(LIBDVB_DIR) $(LIBDVB_BUILD_DIR)
	touch $(LIBDVB_BUILD_DIR)/.configured

libdvb-unpack: $(LIBDVB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDVB_BUILD_DIR)/.built: $(LIBDVB_BUILD_DIR)/.configured
	rm -f $(LIBDVB_BUILD_DIR)/.built
	$(MAKE) -C $(LIBDVB_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		INCLUDES="$(STAGING_CPPFLAGS) $(LIBDVB_CPPFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) $(LIBDVB_LDFLAGS) -L../ -ldvbmpegtools" \
		PREFIX=/opt
	touch $(LIBDVB_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libdvb: $(LIBDVB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDVB_BUILD_DIR)/.staged: $(LIBDVB_BUILD_DIR)/.built
	rm -f $(LIBDVB_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBDVB_BUILD_DIR) DESTDIR=$(STAGING_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		INCLUDES="$(STAGING_CPPFLAGS) $(LIBDVB_CPPFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) $(LIBDVB_LDFLAGS) -L../ -ldvbmpegtools" \
		PREFIX=/opt install
	touch $(LIBDVB_BUILD_DIR)/.staged

libdvb-stage: $(LIBDVB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdvb
#
$(LIBDVB_IPK_DIR)/CONTROL/control:
	@install -d $(LIBDVB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libdvb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDVB_PRIORITY)" >>$@
	@echo "Section: $(LIBDVB_SECTION)" >>$@
	@echo "Version: $(LIBDVB_VERSION)-$(LIBDVB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDVB_MAINTAINER)" >>$@
	@echo "Source: $(LIBDVB_SITE)/$(LIBDVB_SOURCE)" >>$@
	@echo "Description: $(LIBDVB_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDVB_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDVB_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDVB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDVB_IPK_DIR)/opt/sbin or $(LIBDVB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDVB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDVB_IPK_DIR)/opt/etc/libdvb/...
# Documentation files should be installed in $(LIBDVB_IPK_DIR)/opt/doc/libdvb/...
# Daemon startup scripts should be installed in $(LIBDVB_IPK_DIR)/opt/etc/init.d/S??libdvb
#
# You may need to patch your application to make it use these locations.
#
$(LIBDVB_IPK): $(LIBDVB_BUILD_DIR)/.built
	rm -rf $(LIBDVB_IPK_DIR) $(BUILD_DIR)/libdvb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDVB_BUILD_DIR) DESTDIR=$(LIBDVB_IPK_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		INCLUDES="$(STAGING_CPPFLAGS) $(LIBDVB_CPPFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) $(LIBDVB_LDFLAGS) -L../ -ldvbmpegtools" \
		PREFIX=/opt install
	$(MAKE) $(LIBDVB_IPK_DIR)/CONTROL/control
	echo $(LIBDVB_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDVB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDVB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdvb-ipk: $(LIBDVB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdvb-clean:
	-$(MAKE) -C $(LIBDVB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdvb-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDVB_DIR) $(LIBDVB_BUILD_DIR) $(LIBDVB_IPK_DIR) $(LIBDVB_IPK)
