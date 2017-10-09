###########################################################
#
# libexosip2
#
###########################################################
#
# LIBEXOSIP2_VERSION, LIBEXOSIP2_SITE and LIBEXOSIP2_SOURCE define
# the upstream location of the source code for the package.
# LIBEXOSIP2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEXOSIP2_UNZIP is the command used to unzip the source.
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
LIBEXOSIP2_SITE=http://download.savannah.gnu.org/releases-noredirect/exosip
LIBEXOSIP2_VERSION=3.3.0
LIBEXOSIP2_SOURCE=libeXosip2-$(LIBEXOSIP2_VERSION).tar.gz
LIBEXOSIP2_DIR=libeXosip2-$(LIBEXOSIP2_VERSION)
LIBEXOSIP2_UNZIP=zcat
LIBEXOSIP2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEXOSIP2_DESCRIPTION=The eXtended osip library.
LIBEXOSIP2_SECTION=lib
LIBEXOSIP2_PRIORITY=optional
LIBEXOSIP2_DEPENDS=libosip2
LIBEXOSIP2_SUGGESTS=
LIBEXOSIP2_CONFLICTS=

#
# LIBEXOSIP2_IPK_VERSION should be incremented when the ipk changes.
#
LIBEXOSIP2_IPK_VERSION=3

#
# LIBEXOSIP2_CONFFILES should be a list of user-editable files
#LIBEXOSIP2_CONFFILES=$(TARGET_PREFIX)/etc/libexosip2.conf $(TARGET_PREFIX)/etc/init.d/SXXlibexosip2

#
# LIBEXOSIP2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBEXOSIP2_PATCHES=$(LIBEXOSIP2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEXOSIP2_CPPFLAGS=
LIBEXOSIP2_LDFLAGS=

#
# LIBEXOSIP2_BUILD_DIR is the directory in which the build is done.
# LIBEXOSIP2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEXOSIP2_IPK_DIR is the directory in which the ipk is built.
# LIBEXOSIP2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEXOSIP2_BUILD_DIR=$(BUILD_DIR)/libexosip2
LIBEXOSIP2_SOURCE_DIR=$(SOURCE_DIR)/libexosip2
LIBEXOSIP2_IPK_DIR=$(BUILD_DIR)/libexosip2-$(LIBEXOSIP2_VERSION)-ipk
LIBEXOSIP2_IPK=$(BUILD_DIR)/libexosip2_$(LIBEXOSIP2_VERSION)-$(LIBEXOSIP2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libexosip2-source libexosip2-unpack libexosip2 libexosip2-stage libexosip2-ipk libexosip2-clean libexosip2-dirclean libexosip2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEXOSIP2_SOURCE):
	$(WGET) -P $(@D) $(LIBEXOSIP2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libexosip2-source: $(DL_DIR)/$(LIBEXOSIP2_SOURCE) $(LIBEXOSIP2_PATCHES)

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
$(LIBEXOSIP2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEXOSIP2_SOURCE) $(LIBEXOSIP2_PATCHES) make/libexosip2.mk
	$(MAKE) libosip2-stage
	rm -rf $(BUILD_DIR)/$(LIBEXOSIP2_DIR) $(@D)
	$(LIBEXOSIP2_UNZIP) $(DL_DIR)/$(LIBEXOSIP2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBEXOSIP2_PATCHES)" ; \
		then cat $(LIBEXOSIP2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBEXOSIP2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBEXOSIP2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBEXOSIP2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEXOSIP2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEXOSIP2_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
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

libexosip2-unpack: $(LIBEXOSIP2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEXOSIP2_BUILD_DIR)/.built: $(LIBEXOSIP2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libexosip2: $(LIBEXOSIP2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEXOSIP2_BUILD_DIR)/.staged: $(LIBEXOSIP2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libeXosip2.la
	touch $@

libexosip2-stage: $(LIBEXOSIP2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libexosip2
#
$(LIBEXOSIP2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libexosip2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEXOSIP2_PRIORITY)" >>$@
	@echo "Section: $(LIBEXOSIP2_SECTION)" >>$@
	@echo "Version: $(LIBEXOSIP2_VERSION)-$(LIBEXOSIP2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEXOSIP2_MAINTAINER)" >>$@
	@echo "Source: $(LIBEXOSIP2_SITE)/$(LIBEXOSIP2_SOURCE)" >>$@
	@echo "Description: $(LIBEXOSIP2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEXOSIP2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBEXOSIP2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBEXOSIP2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEXOSIP2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBEXOSIP2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEXOSIP2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBEXOSIP2_IPK_DIR)$(TARGET_PREFIX)/etc/libexosip2/...
# Documentation files should be installed in $(LIBEXOSIP2_IPK_DIR)$(TARGET_PREFIX)/doc/libexosip2/...
# Daemon startup scripts should be installed in $(LIBEXOSIP2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libexosip2
#
# You may need to patch your application to make it use these locations.
#
$(LIBEXOSIP2_IPK): $(LIBEXOSIP2_BUILD_DIR)/.built
	rm -rf $(LIBEXOSIP2_IPK_DIR) $(BUILD_DIR)/libexosip2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEXOSIP2_BUILD_DIR) DESTDIR=$(LIBEXOSIP2_IPK_DIR) install-strip
	$(MAKE) $(LIBEXOSIP2_IPK_DIR)/CONTROL/control
	echo $(LIBEXOSIP2_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEXOSIP2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEXOSIP2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libexosip2-ipk: $(LIBEXOSIP2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libexosip2-clean:
	rm -f $(LIBEXOSIP2_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBEXOSIP2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libexosip2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEXOSIP2_DIR) $(LIBEXOSIP2_BUILD_DIR) $(LIBEXOSIP2_IPK_DIR) $(LIBEXOSIP2_IPK)
#
#
# Some sanity check for the package.
#
libexosip2-check: $(LIBEXOSIP2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
