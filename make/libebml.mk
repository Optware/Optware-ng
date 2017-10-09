###########################################################
#
# libebml
#
###########################################################
#
# LIBEBML_VERSION, LIBEBML_SITE and LIBEBML_SOURCE define
# the upstream location of the source code for the package.
# LIBEBML_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEBML_UNZIP is the command used to unzip the source.
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
LIBEBML_SITE=http://bunkus.org/videotools/mkvtoolnix/sources
LIBEBML_VERSION=1.3.1
LIBEBML_SOURCE=libebml-$(LIBEBML_VERSION).tar.bz2
LIBEBML_DIR=libebml-$(LIBEBML_VERSION)
LIBEBML_UNZIP=bzcat
LIBEBML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEBML_DESCRIPTION=Extensible Binary Meta Language access library
LIBEBML_SECTION=libs
LIBEBML_PRIORITY=optional
LIBEBML_DEPENDS=
LIBEBML_SUGGESTS=
LIBEBML_CONFLICTS=

#
# LIBEBML_IPK_VERSION should be incremented when the ipk changes.
#
LIBEBML_IPK_VERSION=2

#
# LIBEBML_CONFFILES should be a list of user-editable files
#LIBEBML_CONFFILES=$(TARGET_PREFIX)/etc/libebml.conf $(TARGET_PREFIX)/etc/init.d/SXXlibebml

#
# LIBEBML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBEBML_PATCHES=$(LIBEBML_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEBML_CPPFLAGS=
LIBEBML_LDFLAGS=-lgcc

#
# LIBEBML_BUILD_DIR is the directory in which the build is done.
# LIBEBML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEBML_IPK_DIR is the directory in which the ipk is built.
# LIBEBML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEBML_BUILD_DIR=$(BUILD_DIR)/libebml
LIBEBML_SOURCE_DIR=$(SOURCE_DIR)/libebml
LIBEBML_IPK_DIR=$(BUILD_DIR)/libebml-$(LIBEBML_VERSION)-ipk
LIBEBML_IPK=$(BUILD_DIR)/libebml_$(LIBEBML_VERSION)-$(LIBEBML_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libebml-source libebml-unpack libebml libebml-stage libebml-ipk libebml-clean libebml-dirclean libebml-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEBML_SOURCE):
	$(WGET) -P $(@D) $(LIBEBML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libebml-source: $(DL_DIR)/$(LIBEBML_SOURCE) $(LIBEBML_PATCHES)

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
$(LIBEBML_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEBML_SOURCE) $(LIBEBML_PATCHES) make/libebml.mk
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(LIBEBML_DIR) $(@D)
	rm -rf $(STAGING_INCLUDE_DIR)/ebml $(STAGING_LIB_DIR)/libebml*
	$(LIBEBML_UNZIP) $(DL_DIR)/$(LIBEBML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBEBML_PATCHES)" ; \
		then cat $(LIBEBML_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBEBML_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBEBML_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBEBML_DIR) $(@D) ; \
	fi
#	sed -i -e 's|-shared|$$(LDFLAGS) &|' $(@D)/make/linux/Makefile
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEBML_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEBML_LDFLAGS)" \
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

libebml-unpack: $(LIBEBML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEBML_BUILD_DIR)/.built: $(LIBEBML_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)/make/linux \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEBML_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEBML_LDFLAGS)" \
		prefix=$(TARGET_PREFIX)
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libebml: $(LIBEBML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEBML_BUILD_DIR)/.staged: $(LIBEBML_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D)/make/linux install_sharedlib install_headers \
		DESTDIR=$(STAGING_DIR) \
		prefix=$(STAGING_PREFIX)
	$(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR)
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libebml.pc
	rm -f $(STAGING_LIB_DIR)/libebml.la
	touch $@

libebml-stage: $(LIBEBML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libebml
#
$(LIBEBML_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libebml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEBML_PRIORITY)" >>$@
	@echo "Section: $(LIBEBML_SECTION)" >>$@
	@echo "Version: $(LIBEBML_VERSION)-$(LIBEBML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEBML_MAINTAINER)" >>$@
	@echo "Source: $(LIBEBML_SITE)/$(LIBEBML_SOURCE)" >>$@
	@echo "Description: $(LIBEBML_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEBML_DEPENDS)" >>$@
	@echo "Suggests: $(LIBEBML_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBEBML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/etc/libebml/...
# Documentation files should be installed in $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/doc/libebml/...
# Daemon startup scripts should be installed in $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libebml
#
# You may need to patch your application to make it use these locations.
#
$(LIBEBML_IPK): $(LIBEBML_BUILD_DIR)/.built
	rm -rf $(LIBEBML_IPK_DIR) $(BUILD_DIR)/libebml_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(LIBEBML_BUILD_DIR)/make/linux install_sharedlib \
		DESTDIR=$(LIBEBML_IPK_DIR) \
		prefix=$(LIBEBML_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) -C $(LIBEBML_BUILD_DIR) install DESTDIR=$(LIBEBML_IPK_DIR)
	rm -f $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/lib/libebml.la
	$(STRIP_COMMAND) $(LIBEBML_IPK_DIR)$(TARGET_PREFIX)/lib/libebml.so.*
	$(MAKE) $(LIBEBML_IPK_DIR)/CONTROL/control
	echo $(LIBEBML_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEBML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEBML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libebml-ipk: $(LIBEBML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libebml-clean:
	rm -f $(LIBEBML_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBEBML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libebml-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEBML_DIR) $(LIBEBML_BUILD_DIR) $(LIBEBML_IPK_DIR) $(LIBEBML_IPK)
#
#
# Some sanity check for the package.
#
libebml-check: $(LIBEBML_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
