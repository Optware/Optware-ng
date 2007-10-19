###########################################################
#
# libijs
#
###########################################################
#
# LIBIJS_VERSION, LIBIJS_SITE and LIBIJS_SOURCE define
# the upstream location of the source code for the package.
# LIBIJS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBIJS_UNZIP is the command used to unzip the source.
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
LIBIJS_SITE=http://www.linuxprinting.org/ijs/download
LIBIJS_VERSION=0.35
LIBIJS_SOURCE=ijs-$(LIBIJS_VERSION).tar.bz2
LIBIJS_DIR=ijs-$(LIBIJS_VERSION)
LIBIJS_UNZIP=bzcat
LIBIJS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBIJS_DESCRIPTION=IJS raster image transport protocol
LIBIJS_SECTION=print
LIBIJS_PRIORITY=optional
LIBIJS_DEPENDS=
LIBIJS_SUGGESTS=
LIBIJS_CONFLICTS=

#
# LIBIJS_IPK_VERSION should be incremented when the ipk changes.
#
LIBIJS_IPK_VERSION=1

#
# LIBIJS_CONFFILES should be a list of user-editable files
#LIBIJS_CONFFILES=/opt/etc/libijs.conf /opt/etc/init.d/SXXlibijs

#
# LIBIJS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBIJS_PATCHES=$(LIBIJS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBIJS_CPPFLAGS=
LIBIJS_LDFLAGS=

#
# LIBIJS_BUILD_DIR is the directory in which the build is done.
# LIBIJS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBIJS_IPK_DIR is the directory in which the ipk is built.
# LIBIJS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBIJS_BUILD_DIR=$(BUILD_DIR)/libijs
LIBIJS_SOURCE_DIR=$(SOURCE_DIR)/libijs
LIBIJS_IPK_DIR=$(BUILD_DIR)/libijs-$(LIBIJS_VERSION)-ipk
LIBIJS_IPK=$(BUILD_DIR)/libijs_$(LIBIJS_VERSION)-$(LIBIJS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libijs-source libijs-unpack libijs libijs-stage libijs-ipk libijs-clean libijs-dirclean libijs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBIJS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBIJS_SITE)/$(LIBIJS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBIJS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libijs-source: $(DL_DIR)/$(LIBIJS_SOURCE) $(LIBIJS_PATCHES)

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
$(LIBIJS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBIJS_SOURCE) $(LIBIJS_PATCHES) make/libijs.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBIJS_DIR) $(LIBIJS_BUILD_DIR)
	$(LIBIJS_UNZIP) $(DL_DIR)/$(LIBIJS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBIJS_PATCHES)" ; \
		then cat $(LIBIJS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBIJS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBIJS_DIR)" != "$(LIBIJS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBIJS_DIR) $(LIBIJS_BUILD_DIR) ; \
	fi
	(cd $(LIBIJS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBIJS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBIJS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(LIBIJS_BUILD_DIR)/libtool
	touch $@

libijs-unpack: $(LIBIJS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBIJS_BUILD_DIR)/.built: $(LIBIJS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBIJS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libijs: $(LIBIJS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBIJS_BUILD_DIR)/.staged: $(LIBIJS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBIJS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=/opt|prefix=$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/ijs-config
	touch $@

libijs-stage: $(LIBIJS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libijs
#
$(LIBIJS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libijs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBIJS_PRIORITY)" >>$@
	@echo "Section: $(LIBIJS_SECTION)" >>$@
	@echo "Version: $(LIBIJS_VERSION)-$(LIBIJS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBIJS_MAINTAINER)" >>$@
	@echo "Source: $(LIBIJS_SITE)/$(LIBIJS_SOURCE)" >>$@
	@echo "Description: $(LIBIJS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBIJS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBIJS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBIJS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBIJS_IPK_DIR)/opt/sbin or $(LIBIJS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBIJS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBIJS_IPK_DIR)/opt/etc/libijs/...
# Documentation files should be installed in $(LIBIJS_IPK_DIR)/opt/doc/libijs/...
# Daemon startup scripts should be installed in $(LIBIJS_IPK_DIR)/opt/etc/init.d/S??libijs
#
# You may need to patch your application to make it use these locations.
#
$(LIBIJS_IPK): $(LIBIJS_BUILD_DIR)/.built
	rm -rf $(LIBIJS_IPK_DIR) $(BUILD_DIR)/libijs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBIJS_BUILD_DIR) DESTDIR=$(LIBIJS_IPK_DIR) install-strip
	rm -f $(LIBIJS_IPK_DIR)/opt/lib/libijs.la
	$(MAKE) $(LIBIJS_IPK_DIR)/CONTROL/control
	echo $(LIBIJS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBIJS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBIJS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libijs-ipk: $(LIBIJS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libijs-clean:
	rm -f $(LIBIJS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBIJS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libijs-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBIJS_DIR) $(LIBIJS_BUILD_DIR) $(LIBIJS_IPK_DIR) $(LIBIJS_IPK)
#
#
# Some sanity check for the package.
#
libijs-check: $(LIBIJS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBIJS_IPK)
