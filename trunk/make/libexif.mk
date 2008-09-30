###########################################################
#
# libexif
#
###########################################################

# You must replace "libexif" and "LIBEXIF" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBEXIF_VERSION, LIBEXIF_SITE and LIBEXIF_SOURCE define
# the upstream location of the source code for the package.
# LIBEXIF_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEXIF_UNZIP is the command used to unzip the source.
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
LIBEXIF_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libexif
LIBEXIF_VERSION=0.6.16
LIBEXIF_SOURCE=libexif-$(LIBEXIF_VERSION).tar.bz2
LIBEXIF_DIR=libexif-$(LIBEXIF_VERSION)
LIBEXIF_UNZIP=bzcat
LIBEXIF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEXIF_DESCRIPTION=Library to parse EXIF info in JPEG file and read/write the data from those tags.
LIBEXIF_SECTION=lib
LIBEXIF_PRIORITY=optional
LIBEXIF_DEPENDS=
LIBEXIF_SUGGESTS=
LIBEXIF_CONFLICTS=

#
# LIBEXIF_IPK_VERSION should be incremented when the ipk changes.
#
LIBEXIF_IPK_VERSION=1

#
# LIBEXIF_CONFFILES should be a list of user-editable files
#LIBEXIF_CONFFILES=/opt/etc/libexif.conf /opt/etc/init.d/SXXlibexif

#
# LIBEXIF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBEXIF_PATCHES=$(LIBEXIF_SOURCE_DIR)/doc_Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEXIF_CPPFLAGS=
LIBEXIF_LDFLAGS=

#
# LIBEXIF_BUILD_DIR is the directory in which the build is done.
# LIBEXIF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEXIF_IPK_DIR is the directory in which the ipk is built.
# LIBEXIF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEXIF_BUILD_DIR=$(BUILD_DIR)/libexif
LIBEXIF_SOURCE_DIR=$(SOURCE_DIR)/libexif
LIBEXIF_IPK_DIR=$(BUILD_DIR)/libexif-$(LIBEXIF_VERSION)-ipk
LIBEXIF_IPK=$(BUILD_DIR)/libexif_$(LIBEXIF_VERSION)-$(LIBEXIF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEXIF_SOURCE):
	$(WGET) -P $(@D) $(LIBEXIF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libexif-source: $(DL_DIR)/$(LIBEXIF_SOURCE) $(LIBEXIF_PATCHES)

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

# You will need doxygen on your build machine.

$(LIBEXIF_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEXIF_SOURCE) $(LIBEXIF_PATCHES) make/libexif.mk
#	$(MAKE) doxygen-stage
	rm -rf $(BUILD_DIR)/$(LIBEXIF_DIR) $(@D)
	$(LIBEXIF_UNZIP) $(DL_DIR)/$(LIBEXIF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBEXIF_PATCHES)" ; \
		then cat $(LIBEXIF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBEXIF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBEXIF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBEXIF_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEXIF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEXIF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libexif-unpack: $(LIBEXIF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEXIF_BUILD_DIR)/.built: $(LIBEXIF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libexif: $(LIBEXIF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEXIF_BUILD_DIR)/.staged: $(LIBEXIF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/libexif DESTDIR=$(STAGING_DIR) install
	touch $@

libexif-stage: $(LIBEXIF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libexif
#
$(LIBEXIF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libexif" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEXIF_PRIORITY)" >>$@
	@echo "Section: $(LIBEXIF_SECTION)" >>$@
	@echo "Version: $(LIBEXIF_VERSION)-$(LIBEXIF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEXIF_MAINTAINER)" >>$@
	@echo "Source: $(LIBEXIF_SITE)/$(LIBEXIF_SOURCE)" >>$@
	@echo "Description: $(LIBEXIF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEXIF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBEXIF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBEXIF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEXIF_IPK_DIR)/opt/sbin or $(LIBEXIF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEXIF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBEXIF_IPK_DIR)/opt/etc/libexif/...
# Documentation files should be installed in $(LIBEXIF_IPK_DIR)/opt/doc/libexif/...
# Daemon startup scripts should be installed in $(LIBEXIF_IPK_DIR)/opt/etc/init.d/S??libexif
#
# You may need to patch your application to make it use these locations.
#
$(LIBEXIF_IPK): $(LIBEXIF_BUILD_DIR)/.built
	rm -rf $(LIBEXIF_IPK_DIR) $(BUILD_DIR)/libexif_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEXIF_BUILD_DIR)/libexif DESTDIR=$(LIBEXIF_IPK_DIR) install-strip
#	install -d $(LIBEXIF_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBEXIF_SOURCE_DIR)/libexif.conf $(LIBEXIF_IPK_DIR)/opt/etc/libexif.conf
#	install -d $(LIBEXIF_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBEXIF_SOURCE_DIR)/rc.libexif $(LIBEXIF_IPK_DIR)/opt/etc/init.d/SXXlibexif
	$(MAKE) $(LIBEXIF_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBEXIF_SOURCE_DIR)/postinst $(LIBEXIF_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBEXIF_SOURCE_DIR)/prerm $(LIBEXIF_IPK_DIR)/CONTROL/prerm
	echo $(LIBEXIF_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEXIF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEXIF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libexif-ipk: $(LIBEXIF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libexif-clean:
	rm -f $(LIBEXIF_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBEXIF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libexif-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEXIF_DIR) $(LIBEXIF_BUILD_DIR) $(LIBEXIF_IPK_DIR) $(LIBEXIF_IPK)

#
# Some sanity check for the package.
#
libexif-check: $(LIBEXIF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBEXIF_IPK)
