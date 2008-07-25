###########################################################
#
# libpth
#
###########################################################

# You must replace "libpth" and "LIBPTH" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBPTH_VERSION, LIBPTH_SITE and LIBPTH_SOURCE define
# the upstream location of the source code for the package.
# LIBPTH_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPTH_UNZIP is the command used to unzip the source.
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
LIBPTH_SITE=ftp://ftp.gnu.org/gnu/pth
LIBPTH_VERSION=2.0.7
LIBPTH_SOURCE=pth-$(LIBPTH_VERSION).tar.gz
LIBPTH_DIR=pth-$(LIBPTH_VERSION)
LIBPTH_UNZIP=zcat
LIBPTH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBPTH_DESCRIPTION=Pth is a very portable POSIX/ANSI-C based library for Unix platforms which provides non-preemptive priority-based scheduling for multiple threads of execution (aka "multithreading") inside event-driven applications.
LIBPTH_SECTION=lib
LIBPTH_PRIORITY=optional
LIBPTH_DEPENDS=
LIBPTH_SUGGESTS=
LIBPTH_CONFLICTS=

#
# LIBPTH_IPK_VERSION should be incremented when the ipk changes.
#
LIBPTH_IPK_VERSION=2

#
# LIBPTH_CONFFILES should be a list of user-editable files
#LIBPTH_CONFFILES=/opt/etc/libpth.conf /opt/etc/init.d/SXXlibpth

#
# LIBPTH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBPTH_PATCHES=$(LIBPTH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPTH_CPPFLAGS=
LIBPTH_LDFLAGS=

#
# LIBPTH_BUILD_DIR is the directory in which the build is done.
# LIBPTH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPTH_IPK_DIR is the directory in which the ipk is built.
# LIBPTH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPTH_BUILD_DIR=$(BUILD_DIR)/libpth
LIBPTH_SOURCE_DIR=$(SOURCE_DIR)/libpth
LIBPTH_IPK_DIR=$(BUILD_DIR)/libpth-$(LIBPTH_VERSION)-ipk
LIBPTH_IPK=$(BUILD_DIR)/libpth_$(LIBPTH_VERSION)-$(LIBPTH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libpth-source libpth-unpack libpth libpth-stage libpth-ipk libpth-clean libpth-dirclean libpth-check
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPTH_SOURCE):
	$(WGET) -P $(@D) $(LIBPTH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpth-source: $(DL_DIR)/$(LIBPTH_SOURCE) $(LIBPTH_PATCHES)

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
$(LIBPTH_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPTH_SOURCE) $(LIBPTH_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBPTH_DIR) $(@D)
	$(LIBPTH_UNZIP) $(DL_DIR)/$(LIBPTH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBPTH_PATCHES) | patch -d $(BUILD_DIR)/$(LIBPTH_DIR) -p1
	mv $(BUILD_DIR)/$(LIBPTH_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPTH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPTH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libpth-unpack: $(LIBPTH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBPTH_BUILD_DIR)/.built: $(LIBPTH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libpth: $(LIBPTH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBPTH_BUILD_DIR)/.staged: $(LIBPTH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-strip
	touch $@

libpth-stage: $(LIBPTH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libpth
#
$(LIBPTH_IPK_DIR)/CONTROL/control:
	@install -d $(LIBPTH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libpth" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPTH_PRIORITY)" >>$@
	@echo "Section: $(LIBPTH_SECTION)" >>$@
	@echo "Version: $(LIBPTH_VERSION)-$(LIBPTH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPTH_MAINTAINER)" >>$@
	@echo "Source: $(LIBPTH_SITE)/$(LIBPTH_SOURCE)" >>$@
	@echo "Description: $(LIBPTH_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPTH_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPTH_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPTH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPTH_IPK_DIR)/opt/sbin or $(LIBPTH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPTH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBPTH_IPK_DIR)/opt/etc/libpth/...
# Documentation files should be installed in $(LIBPTH_IPK_DIR)/opt/doc/libpth/...
# Daemon startup scripts should be installed in $(LIBPTH_IPK_DIR)/opt/etc/init.d/S??libpth
#
# You may need to patch your application to make it use these locations.
#
$(LIBPTH_IPK): $(LIBPTH_BUILD_DIR)/.built
	rm -rf $(LIBPTH_IPK_DIR) $(BUILD_DIR)/libpth_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBPTH_BUILD_DIR) DESTDIR=$(LIBPTH_IPK_DIR) install-strip
	rm -f $(LIBPTH_IPK_DIR)/opt/lib/libpth.a
	$(STRIP_COMMAND) $(LIBPTH_IPK_DIR)/opt/lib/libpth.so.*.*.*
	$(MAKE) $(LIBPTH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPTH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpth-ipk: $(LIBPTH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpth-clean:
	-$(MAKE) -C $(LIBPTH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpth-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPTH_DIR) $(LIBPTH_BUILD_DIR) $(LIBPTH_IPK_DIR) $(LIBPTH_IPK)

libpth-check: $(LIBPTH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBPTH_IPK)
