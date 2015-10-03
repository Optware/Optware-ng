###########################################################
#
# libjansson
#
###########################################################
#
# LIBJANSSON_VERSION, LIBJANSSON_SITE and LIBJANSSON_SOURCE define
# the upstream location of the source code for the package.
# LIBJANSSON_DIR is the directory which is created when the source
# archive is unpacked.
# LIBJANSSON_UNZIP is the command used to unzip the source.
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
LIBJANSSON_SITE=http://www.digip.org/jansson/releases
LIBJANSSON_VERSION=2.7
LIBJANSSON_SOURCE=jansson-$(LIBJANSSON_VERSION).tar.bz2
LIBJANSSON_DIR=jansson-$(LIBJANSSON_VERSION)
LIBJANSSON_UNZIP=bzcat
LIBJANSSON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBJANSSON_DESCRIPTION=A C library for encoding, decoding and manipulating JSON data.
LIBJANSSON_SECTION=lib
LIBJANSSON_PRIORITY=optional
LIBJANSSON_DEPENDS=
LIBJANSSON_SUGGESTS=
LIBJANSSON_CONFLICTS=

#
# LIBJANSSON_IPK_VERSION should be incremented when the ipk changes.
#
LIBJANSSON_IPK_VERSION=1

#
# LIBJANSSON_CONFFILES should be a list of user-editable files
#LIBJANSSON_CONFFILES=$(TARGET_PREFIX)/etc/libjansson.conf $(TARGET_PREFIX)/etc/init.d/SXXlibjansson

#
# LIBJANSSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBJANSSON_PATCHES=$(LIBJANSSON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBJANSSON_CPPFLAGS=
LIBJANSSON_LDFLAGS=

#
# LIBJANSSON_BUILD_DIR is the directory in which the build is done.
# LIBJANSSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBJANSSON_IPK_DIR is the directory in which the ipk is built.
# LIBJANSSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBJANSSON_BUILD_DIR=$(BUILD_DIR)/libjansson
LIBJANSSON_SOURCE_DIR=$(SOURCE_DIR)/libjansson
LIBJANSSON_IPK_DIR=$(BUILD_DIR)/libjansson-$(LIBJANSSON_VERSION)-ipk
LIBJANSSON_IPK=$(BUILD_DIR)/libjansson_$(LIBJANSSON_VERSION)-$(LIBJANSSON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libjansson-source libjansson-unpack libjansson libjansson-stage libjansson-ipk libjansson-clean libjansson-dirclean libjansson-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBJANSSON_SOURCE):
	$(WGET) -P $(@D) $(LIBJANSSON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libjansson-source: $(DL_DIR)/$(LIBJANSSON_SOURCE) $(LIBJANSSON_PATCHES)

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
$(LIBJANSSON_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBJANSSON_SOURCE) $(LIBJANSSON_PATCHES) make/libjansson.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBJANSSON_DIR) $(@D)
	$(LIBJANSSON_UNZIP) $(DL_DIR)/$(LIBJANSSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBJANSSON_PATCHES)" ; \
		then cat $(LIBJANSSON_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBJANSSON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBJANSSON_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBJANSSON_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBJANSSON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBJANSSON_LDFLAGS)" \
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

libjansson-unpack: $(LIBJANSSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBJANSSON_BUILD_DIR)/.built: $(LIBJANSSON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libjansson: $(LIBJANSSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBJANSSON_BUILD_DIR)/.staged: $(LIBJANSSON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/jansson.pc
	rm -f $(STAGING_LIB_DIR)/libjansson.la
	touch $@

libjansson-stage: $(LIBJANSSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libjansson
#
$(LIBJANSSON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libjansson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBJANSSON_PRIORITY)" >>$@
	@echo "Section: $(LIBJANSSON_SECTION)" >>$@
	@echo "Version: $(LIBJANSSON_VERSION)-$(LIBJANSSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBJANSSON_MAINTAINER)" >>$@
	@echo "Source: $(LIBJANSSON_SITE)/$(LIBJANSSON_SOURCE)" >>$@
	@echo "Description: $(LIBJANSSON_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBJANSSON_DEPENDS)" >>$@
	@echo "Suggests: $(LIBJANSSON_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBJANSSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/libjansson/...
# Documentation files should be installed in $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/doc/libjansson/...
# Daemon startup scripts should be installed in $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libjansson
#
# You may need to patch your application to make it use these locations.
#
$(LIBJANSSON_IPK): $(LIBJANSSON_BUILD_DIR)/.built
	rm -rf $(LIBJANSSON_IPK_DIR) $(BUILD_DIR)/libjansson_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBJANSSON_BUILD_DIR) DESTDIR=$(LIBJANSSON_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	rm -f $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBJANSSON_SOURCE_DIR)/libjansson.conf $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/libjansson.conf
#	$(INSTALL) -d $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBJANSSON_SOURCE_DIR)/rc.libjansson $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibjansson
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBJANSSON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibjansson
	$(MAKE) $(LIBJANSSON_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBJANSSON_SOURCE_DIR)/postinst $(LIBJANSSON_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBJANSSON_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBJANSSON_SOURCE_DIR)/prerm $(LIBJANSSON_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBJANSSON_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBJANSSON_IPK_DIR)/CONTROL/postinst $(LIBJANSSON_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBJANSSON_CONFFILES) | sed -e 's/ /\n/g' > $(LIBJANSSON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBJANSSON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBJANSSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libjansson-ipk: $(LIBJANSSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libjansson-clean:
	rm -f $(LIBJANSSON_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBJANSSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libjansson-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBJANSSON_DIR) $(LIBJANSSON_BUILD_DIR) $(LIBJANSSON_IPK_DIR) $(LIBJANSSON_IPK)
#
#
# Some sanity check for the package.
#
libjansson-check: $(LIBJANSSON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
