###########################################################
#
# libsigc++
#
###########################################################

#
# LIBSIGC++_VERSION, LIBSIGC++_SITE and LIBSIGC++_SOURCE define
# the upstream location of the source code for the package.
# LIBSIGC++_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSIGC++_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
LIBSIGC++_SITE=http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.0/
LIBSIGC++_VERSION=2.0.16
LIBSIGC++_SOURCE=libsigc++-$(LIBSIGC++_VERSION).tar.gz
LIBSIGC++_DIR=libsigc++-$(LIBSIGC++_VERSION)
LIBSIGC++_UNZIP=zcat
LIBSIGC++_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSIGC++_DESCRIPTION=Describe libsigc++ here.
LIBSIGC++_SECTION=libs
LIBSIGC++_PRIORITY=optional
LIBSIGC++_DEPENDS=
LIBSIGC++_SUGGESTS=
LIBSIGC++_CONFLICTS=

#
# LIBSIGC++_IPK_VERSION should be incremented when the ipk changes.
#
LIBSIGC++_IPK_VERSION=1

#
# LIBSIGC++_CONFFILES should be a list of user-editable files
LIBSIGC++_CONFFILES=

#
# LIBSIGC++_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSIGC++_PATCHES=$(LIBSIGC++_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSIGC++_CPPFLAGS=
LIBSIGC++_LDFLAGS=

#
# LIBSIGC++_BUILD_DIR is the directory in which the build is done.
# LIBSIGC++_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSIGC++_IPK_DIR is the directory in which the ipk is built.
# LIBSIGC++_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSIGC++_BUILD_DIR=$(BUILD_DIR)/libsigc++
LIBSIGC++_SOURCE_DIR=$(SOURCE_DIR)/libsigc++
LIBSIGC++_IPK_DIR=$(BUILD_DIR)/libsigc++-$(LIBSIGC++_VERSION)-ipk
LIBSIGC++_IPK=$(BUILD_DIR)/libsigc++_$(LIBSIGC++_VERSION)-$(LIBSIGC++_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBSIGC++_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBSIGC++_SITE)/$(LIBSIGC++_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libsigc++-source: $(DL_DIR)/$(LIBSIGC++_SOURCE) $(LIBSIGC++_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(LIBSIGC++_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSIGC++_SOURCE) $(LIBSIGC++_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBSIGC++_DIR) $(LIBSIGC++_BUILD_DIR)
	$(LIBSIGC++_UNZIP) $(DL_DIR)/$(LIBSIGC++_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSIGC++_PATCHES)" ; \
		then cat $(LIBSIGC++_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBSIGC++_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSIGC++_DIR)" != "$(LIBSIGC++_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBSIGC++_DIR) $(LIBSIGC++_BUILD_DIR) ; \
	fi
	(cd $(LIBSIGC++_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSIGC++_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSIGC++_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBSIGC++_BUILD_DIR)/libtool
	touch $(LIBSIGC++_BUILD_DIR)/.configured

libsigc++-unpack: $(LIBSIGC++_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSIGC++_BUILD_DIR)/.built: $(LIBSIGC++_BUILD_DIR)/.configured
	rm -f $(LIBSIGC++_BUILD_DIR)/.built
	$(MAKE) -C $(LIBSIGC++_BUILD_DIR)
	touch $(LIBSIGC++_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libsigc++: $(LIBSIGC++_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSIGC++_BUILD_DIR)/.staged: $(LIBSIGC++_BUILD_DIR)/.built
	rm -f $(LIBSIGC++_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBSIGC++_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBSIGC++_BUILD_DIR)/.staged

libsigc++-stage: $(LIBSIGC++_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libsigc++
#
$(LIBSIGC++_IPK_DIR)/CONTROL/control:
	@install -d $(LIBSIGC++_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libsigc++" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSIGC++_PRIORITY)" >>$@
	@echo "Section: $(LIBSIGC++_SECTION)" >>$@
	@echo "Version: $(LIBSIGC++_VERSION)-$(LIBSIGC++_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSIGC++_MAINTAINER)" >>$@
	@echo "Source: $(LIBSIGC++_SITE)/$(LIBSIGC++_SOURCE)" >>$@
	@echo "Description: $(LIBSIGC++_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSIGC++_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSIGC++_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSIGC++_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSIGC++_IPK_DIR)/opt/sbin or $(LIBSIGC++_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSIGC++_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBSIGC++_IPK_DIR)/opt/etc/libsigc++/...
# Documentation files should be installed in $(LIBSIGC++_IPK_DIR)/opt/doc/libsigc++/...
# Daemon startup scripts should be installed in $(LIBSIGC++_IPK_DIR)/opt/etc/init.d/S??libsigc++
#
# You may need to patch your application to make it use these locations.
#
$(LIBSIGC++_IPK): $(LIBSIGC++_BUILD_DIR)/.built
	rm -rf $(LIBSIGC++_IPK_DIR) $(BUILD_DIR)/libsigc++_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSIGC++_BUILD_DIR) DESTDIR=$(LIBSIGC++_IPK_DIR) install-strip
	# remove documentation and stuff
	rm -rf $(LIBSIGC++_IPK_DIR)/opt/include
	rm -rf $(LIBSIGC++_IPK_DIR)/opt/share
	rm -rf $(LIBSIGC++_IPK_DIR)/opt/lib/pkgconfig
	rm -rf $(LIBSIGC++_IPK_DIR)/opt/lib/*.la
	rm -rf $(LIBSIGC++_IPK_DIR)/opt/lib/sigc++-2.0
	$(MAKE) $(LIBSIGC++_IPK_DIR)/CONTROL/control
	echo $(LIBSIGC++_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSIGC++_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSIGC++_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libsigc++-ipk: $(LIBSIGC++_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libsigc++-clean:
	rm -f $(LIBSIGC++_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSIGC++_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libsigc++-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSIGC++_DIR) $(LIBSIGC++_BUILD_DIR) $(LIBSIGC++_IPK_DIR) $(LIBSIGC++_IPK)
