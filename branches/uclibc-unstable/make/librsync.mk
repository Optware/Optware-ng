###########################################################
#
# librsync
#
###########################################################

# You must replace "librsync" and "LIBRSYNC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBRSYNC_VERSION, LIBRSYNC_SITE and LIBRSYNC_SOURCE define
# the upstream location of the source code for the package.
# LIBRSYNC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBRSYNC_UNZIP is the command used to unzip the source.
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
LIBRSYNC_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/librsync
LIBRSYNC_VERSION=0.9.7
LIBRSYNC_SOURCE=librsync-$(LIBRSYNC_VERSION).tar.gz
LIBRSYNC_DIR=librsync-$(LIBRSYNC_VERSION)
LIBRSYNC_UNZIP=zcat
LIBRSYNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBRSYNC_DESCRIPTION=librsync is a free software library that implements the rsync remote-delta algorithm.
LIBRSYNC_SECTION=net
LIBRSYNC_PRIORITY=optional
LIBRSYNC_DEPENDS=popt, bzip2
LIBRSYNC_SUGGESTS=
LIBRSYNC_CONFLICTS=

#
# LIBRSYNC_IPK_VERSION should be incremented when the ipk changes.
#
LIBRSYNC_IPK_VERSION=1

#
# LIBRSYNC_CONFFILES should be a list of user-editable files
#LIBRSYNC_CONFFILES=/opt/etc/librsync.conf /opt/etc/init.d/SXXlibrsync

#
# LIBRSYNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBRSYNC_PATCHES=$(LIBRSYNC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBRSYNC_CPPFLAGS=
LIBRSYNC_LDFLAGS=

#
# LIBRSYNC_BUILD_DIR is the directory in which the build is done.
# LIBRSYNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBRSYNC_IPK_DIR is the directory in which the ipk is built.
# LIBRSYNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBRSYNC_BUILD_DIR=$(BUILD_DIR)/librsync
LIBRSYNC_SOURCE_DIR=$(SOURCE_DIR)/librsync
LIBRSYNC_IPK_DIR=$(BUILD_DIR)/librsync-$(LIBRSYNC_VERSION)-ipk
LIBRSYNC_IPK=$(BUILD_DIR)/librsync_$(LIBRSYNC_VERSION)-$(LIBRSYNC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBRSYNC_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBRSYNC_SITE)/$(LIBRSYNC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
librsync-source: $(DL_DIR)/$(LIBRSYNC_SOURCE) $(LIBRSYNC_PATCHES)

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
$(LIBRSYNC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBRSYNC_SOURCE) $(LIBRSYNC_PATCHES)
	$(MAKE) popt-stage bzip2-stage
	rm -rf $(BUILD_DIR)/$(LIBRSYNC_DIR) $(LIBRSYNC_BUILD_DIR)
	$(LIBRSYNC_UNZIP) $(DL_DIR)/$(LIBRSYNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBRSYNC_PATCHES)" ; \
		then cat $(LIBRSYNC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBRSYNC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBRSYNC_DIR)" != "$(LIBRSYNC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBRSYNC_DIR) $(LIBRSYNC_BUILD_DIR) ; \
	fi
	(cd $(LIBRSYNC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBRSYNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBRSYNC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static --enable-shared \
	)
	$(PATCH_LIBTOOL) $(LIBRSYNC_BUILD_DIR)/libtool
	touch $(LIBRSYNC_BUILD_DIR)/.configured

librsync-unpack: $(LIBRSYNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBRSYNC_BUILD_DIR)/.built: $(LIBRSYNC_BUILD_DIR)/.configured
	rm -f $(LIBRSYNC_BUILD_DIR)/.built
	$(MAKE) -C $(LIBRSYNC_BUILD_DIR)
	touch $(LIBRSYNC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
librsync: $(LIBRSYNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBRSYNC_BUILD_DIR)/.staged: $(LIBRSYNC_BUILD_DIR)/.built
	rm -f $(LIBRSYNC_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBRSYNC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBRSYNC_BUILD_DIR)/.staged

librsync-stage: $(LIBRSYNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/librsync
#
$(LIBRSYNC_IPK_DIR)/CONTROL/control:
	@install -d $(LIBRSYNC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: librsync" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBRSYNC_PRIORITY)" >>$@
	@echo "Section: $(LIBRSYNC_SECTION)" >>$@
	@echo "Version: $(LIBRSYNC_VERSION)-$(LIBRSYNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBRSYNC_MAINTAINER)" >>$@
	@echo "Source: $(LIBRSYNC_SITE)/$(LIBRSYNC_SOURCE)" >>$@
	@echo "Description: $(LIBRSYNC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBRSYNC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBRSYNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBRSYNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBRSYNC_IPK_DIR)/opt/sbin or $(LIBRSYNC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBRSYNC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBRSYNC_IPK_DIR)/opt/etc/librsync/...
# Documentation files should be installed in $(LIBRSYNC_IPK_DIR)/opt/doc/librsync/...
# Daemon startup scripts should be installed in $(LIBRSYNC_IPK_DIR)/opt/etc/init.d/S??librsync
#
# You may need to patch your application to make it use these locations.
#
$(LIBRSYNC_IPK): $(LIBRSYNC_BUILD_DIR)/.built
	rm -rf $(LIBRSYNC_IPK_DIR) $(BUILD_DIR)/librsync_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBRSYNC_BUILD_DIR) DESTDIR=$(LIBRSYNC_IPK_DIR) install-strip
	rm -f $(LIBRSYNC_IPK_DIR)/opt/lib/*.la
#	install -d $(LIBRSYNC_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBRSYNC_SOURCE_DIR)/librsync.conf $(LIBRSYNC_IPK_DIR)/opt/etc/librsync.conf
#	install -d $(LIBRSYNC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBRSYNC_SOURCE_DIR)/rc.librsync $(LIBRSYNC_IPK_DIR)/opt/etc/init.d/SXXlibrsync
	$(MAKE) $(LIBRSYNC_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBRSYNC_SOURCE_DIR)/postinst $(LIBRSYNC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBRSYNC_SOURCE_DIR)/prerm $(LIBRSYNC_IPK_DIR)/CONTROL/prerm
	echo $(LIBRSYNC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBRSYNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBRSYNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
librsync-ipk: $(LIBRSYNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
librsync-clean:
	rm -f $(LIBRSYNC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBRSYNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
librsync-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBRSYNC_DIR) $(LIBRSYNC_BUILD_DIR) $(LIBRSYNC_IPK_DIR) $(LIBRSYNC_IPK)
