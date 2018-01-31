###########################################################
#
# libupnp6
#
###########################################################

# You must replace "libupnp6" and "LIBUPNP6" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBUPNP6_VERSION, LIBUPNP6_SITE and LIBUPNP6_SOURCE define
# the upstream location of the source code for the package.
# LIBUPNP6_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUPNP6_UNZIP is the command used to unzip the source.
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
LIBUPNP6_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pupnp
LIBUPNP6_VERSION=1.6.24
LIBUPNP6_SOURCE=libupnp-$(LIBUPNP6_VERSION).tar.bz2
LIBUPNP6_DIR=libupnp-$(LIBUPNP6_VERSION)
LIBUPNP6_UNZIP=bzcat
LIBUPNP6_MAINTAINER=Peter Enzerink <nslu2-libupnp6@enzerink.net>
LIBUPNP6_DESCRIPTION=The Universal Plug and Play (UPnP) SDK for Linux provides support for building UPnP-compliant control points, devices, and bridges on Linux.
LIBUPNP6_SECTION=libs
LIBUPNP6_PRIORITY=optional
LIBUPNP6_DEPENDS=
LIBUPNP6_SUGGESTS=
LIBUPNP6_CONFLICTS=

#
# LIBUPNP6_IPK_VERSION should be incremented when the ipk changes.
#
LIBUPNP6_IPK_VERSION=1

#
# LIBUPNP6_CONFFILES should be a list of user-editable files
#LIBUPNP6_CONFFILES=$(TARGET_PREFIX)/etc/libupnp6.conf $(TARGET_PREFIX)/etc/init.d/SXXlibupnp6

#
# LIBUPNP6_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBUPNP6_PATCHES=\
#$(LIBUPNP6_SOURCE_DIR)/get_content_type_static_inline.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUPNP6_CPPFLAGS=-D_FILE_OFFSET_BITS=64
LIBUPNP6_LDFLAGS=

#
# LIBUPNP6_BUILD_DIR is the directory in which the build is done.
# LIBUPNP6_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUPNP6_IPK_DIR is the directory in which the ipk is built.
# LIBUPNP6_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUPNP6_BUILD_DIR=$(BUILD_DIR)/libupnp6
LIBUPNP6_SOURCE_DIR=$(SOURCE_DIR)/libupnp6
LIBUPNP6_IPK_DIR=$(BUILD_DIR)/libupnp6-$(LIBUPNP6_VERSION)-ipk
LIBUPNP6_IPK=$(BUILD_DIR)/libupnp6_$(LIBUPNP6_VERSION)-$(LIBUPNP6_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libupnp6-source libupnp6-unpack libupnp6 libupnp6-stage libupnp6-ipk libupnp6-clean libupnp6-dirclean libupnp6-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUPNP6_SOURCE):
	$(WGET) -P $(@D) $(LIBUPNP6_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libupnp6-source: $(DL_DIR)/$(LIBUPNP6_SOURCE) $(LIBUPNP6_PATCHES)

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
$(LIBUPNP6_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUPNP6_SOURCE) $(LIBUPNP6_PATCHES) make/libupnp6.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBUPNP6_DIR) $(LIBUPNP6_BUILD_DIR)
	$(LIBUPNP6_UNZIP) $(DL_DIR)/$(LIBUPNP6_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUPNP6_PATCHES)" ; \
		then cat $(LIBUPNP6_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBUPNP6_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUPNP6_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBUPNP6_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUPNP6_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUPNP6_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libupnp6-unpack: $(LIBUPNP6_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUPNP6_BUILD_DIR)/.built: $(LIBUPNP6_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libupnp6: $(LIBUPNP6_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUPNP6_BUILD_DIR)/.staged: $(LIBUPNP6_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR)/libupnp6 install
	rm -f $(STAGING_DIR)/libupnp6/$(TARGET_PREFIX)/*.la
	sed -i -e '/^prefix=/s|=$(TARGET_PREFIX)|=$(STAGING_DIR)/libupnp6/$(TARGET_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libupnp.pc
	touch $@

libupnp6-stage: $(LIBUPNP6_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libupnp6
#
$(LIBUPNP6_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libupnp6" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUPNP6_PRIORITY)" >>$@
	@echo "Section: $(LIBUPNP6_SECTION)" >>$@
	@echo "Version: $(LIBUPNP6_VERSION)-$(LIBUPNP6_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUPNP6_MAINTAINER)" >>$@
	@echo "Source: $(LIBUPNP6_SITE)/$(LIBUPNP6_SOURCE)" >>$@
	@echo "Description: $(LIBUPNP6_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUPNP6_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUPNP6_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUPNP6_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/etc/libupnp6/...
# Documentation files should be installed in $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/doc/libupnp6/...
# Daemon startup scripts should be installed in $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libupnp6
#
# You may need to patch your application to make it use these locations.
#
$(LIBUPNP6_IPK): $(LIBUPNP6_BUILD_DIR)/.built
	rm -rf $(LIBUPNP6_IPK_DIR) $(BUILD_DIR)/libupnp6_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBUPNP6_BUILD_DIR) DESTDIR=$(LIBUPNP6_IPK_DIR) install-strip
	rm -f $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	# to avoid conflict with libupnp package
	rm -rf $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/lib/*.so \
		$(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig \
		$(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -d $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBUPNP6_SOURCE_DIR)/libupnp6.conf $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/etc/libupnp6.conf
#	$(INSTALL) -d $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBUPNP6_SOURCE_DIR)/rc.libupnp6 $(LIBUPNP6_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibupnp6
	$(MAKE) $(LIBUPNP6_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBUPNP6_SOURCE_DIR)/postinst $(LIBUPNP6_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBUPNP6_SOURCE_DIR)/prerm $(LIBUPNP6_IPK_DIR)/CONTROL/prerm
#	echo $(LIBUPNP6_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUPNP6_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUPNP6_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUPNP6_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libupnp6-ipk: $(LIBUPNP6_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libupnp6-clean:
	rm -f $(LIBUPNP6_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUPNP6_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libupnp6-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUPNP6_DIR) $(LIBUPNP6_BUILD_DIR) $(LIBUPNP6_IPK_DIR) $(LIBUPNP6_IPK)
#
#
# Some sanity check for the package.
#
libupnp6-check: $(LIBUPNP6_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
