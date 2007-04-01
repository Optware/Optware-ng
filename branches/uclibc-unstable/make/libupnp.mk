###########################################################
#
# libupnp
#
###########################################################

# You must replace "libupnp" and "LIBUPNP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBUPNP_VERSION, LIBUPNP_SITE and LIBUPNP_SOURCE define
# the upstream location of the source code for the package.
# LIBUPNP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUPNP_UNZIP is the command used to unzip the source.
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
LIBUPNP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pupnp
LIBUPNP_VERSION=1.4.3
LIBUPNP_SOURCE=libupnp-$(LIBUPNP_VERSION).tar.bz2
LIBUPNP_DIR=libupnp-$(LIBUPNP_VERSION)
LIBUPNP_UNZIP=bzcat
LIBUPNP_MAINTAINER=Peter Enzerink <nslu2-libupnp@enzerink.net>
LIBUPNP_DESCRIPTION=The Universal Plug and Play (UPnP) SDK for Linux provides support for building UPnP-compliant control points, devices, and bridges on Linux.
LIBUPNP_SECTION=libs
LIBUPNP_PRIORITY=optional
LIBUPNP_DEPENDS=
LIBUPNP_SUGGESTS=ushare
LIBUPNP_CONFLICTS=

#
# LIBUPNP_IPK_VERSION should be incremented when the ipk changes.
#
LIBUPNP_IPK_VERSION=1

#
# LIBUPNP_CONFFILES should be a list of user-editable files
#LIBUPNP_CONFFILES=/opt/etc/libupnp.conf /opt/etc/init.d/SXXlibupnp

#
# LIBUPNP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBUPNP_PATCHES=$(LIBUPNP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUPNP_CPPFLAGS=
LIBUPNP_LDFLAGS=

#
# LIBUPNP_BUILD_DIR is the directory in which the build is done.
# LIBUPNP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUPNP_IPK_DIR is the directory in which the ipk is built.
# LIBUPNP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUPNP_BUILD_DIR=$(BUILD_DIR)/libupnp
LIBUPNP_SOURCE_DIR=$(SOURCE_DIR)/libupnp
LIBUPNP_IPK_DIR=$(BUILD_DIR)/libupnp-$(LIBUPNP_VERSION)-ipk
LIBUPNP_IPK=$(BUILD_DIR)/libupnp_$(LIBUPNP_VERSION)-$(LIBUPNP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libupnp-source libupnp-unpack libupnp libupnp-stage libupnp-ipk libupnp-clean libupnp-dirclean libupnp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUPNP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBUPNP_SITE)/$(LIBUPNP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBUPNP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libupnp-source: $(DL_DIR)/$(LIBUPNP_SOURCE) $(LIBUPNP_PATCHES)

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
$(LIBUPNP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUPNP_SOURCE) $(LIBUPNP_PATCHES) make/libupnp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBUPNP_DIR) $(LIBUPNP_BUILD_DIR)
	$(LIBUPNP_UNZIP) $(DL_DIR)/$(LIBUPNP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUPNP_PATCHES)" ; \
		then cat $(LIBUPNP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBUPNP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUPNP_DIR)" != "$(LIBUPNP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBUPNP_DIR) $(LIBUPNP_BUILD_DIR) ; \
	fi
	(cd $(LIBUPNP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUPNP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUPNP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBUPNP_BUILD_DIR)/libtool
	touch $(LIBUPNP_BUILD_DIR)/.configured

libupnp-unpack: $(LIBUPNP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUPNP_BUILD_DIR)/.built: $(LIBUPNP_BUILD_DIR)/.configured
	rm -f $(LIBUPNP_BUILD_DIR)/.built
	$(MAKE) -C $(LIBUPNP_BUILD_DIR)
	touch $(LIBUPNP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libupnp: $(LIBUPNP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUPNP_BUILD_DIR)/.staged: $(LIBUPNP_BUILD_DIR)/.built
	rm -f $(LIBUPNP_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBUPNP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBUPNP_BUILD_DIR)/.staged

libupnp-stage: $(LIBUPNP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libupnp
#
$(LIBUPNP_IPK_DIR)/CONTROL/control:
	@install -d $(LIBUPNP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libupnp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUPNP_PRIORITY)" >>$@
	@echo "Section: $(LIBUPNP_SECTION)" >>$@
	@echo "Version: $(LIBUPNP_VERSION)-$(LIBUPNP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUPNP_MAINTAINER)" >>$@
	@echo "Source: $(LIBUPNP_SITE)/$(LIBUPNP_SOURCE)" >>$@
	@echo "Description: $(LIBUPNP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUPNP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUPNP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUPNP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUPNP_IPK_DIR)/opt/sbin or $(LIBUPNP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUPNP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBUPNP_IPK_DIR)/opt/etc/libupnp/...
# Documentation files should be installed in $(LIBUPNP_IPK_DIR)/opt/doc/libupnp/...
# Daemon startup scripts should be installed in $(LIBUPNP_IPK_DIR)/opt/etc/init.d/S??libupnp
#
# You may need to patch your application to make it use these locations.
#
$(LIBUPNP_IPK): $(LIBUPNP_BUILD_DIR)/.built
	rm -rf $(LIBUPNP_IPK_DIR) $(BUILD_DIR)/libupnp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBUPNP_BUILD_DIR) DESTDIR=$(LIBUPNP_IPK_DIR) install-strip
	install -d $(LIBUPNP_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBUPNP_SOURCE_DIR)/libupnp.conf $(LIBUPNP_IPK_DIR)/opt/etc/libupnp.conf
#	install -d $(LIBUPNP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBUPNP_SOURCE_DIR)/rc.libupnp $(LIBUPNP_IPK_DIR)/opt/etc/init.d/SXXlibupnp
	$(MAKE) $(LIBUPNP_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBUPNP_SOURCE_DIR)/postinst $(LIBUPNP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBUPNP_SOURCE_DIR)/prerm $(LIBUPNP_IPK_DIR)/CONTROL/prerm
#	echo $(LIBUPNP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUPNP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUPNP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libupnp-ipk: $(LIBUPNP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libupnp-clean:
	rm -f $(LIBUPNP_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUPNP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libupnp-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUPNP_DIR) $(LIBUPNP_BUILD_DIR) $(LIBUPNP_IPK_DIR) $(LIBUPNP_IPK)
#
#
# Some sanity check for the package.
#
libupnp-check: $(LIBUPNP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBUPNP_IPK)
