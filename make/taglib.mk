###########################################################
#
# taglib
#
###########################################################
#
# TAGLIB_VERSION, TAGLIB_SITE and TAGLIB_SOURCE define
# the upstream location of the source code for the package.
# TAGLIB_DIR is the directory which is created when the source
# archive is unpacked.
# TAGLIB_UNZIP is the command used to unzip the source.
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
TAGLIB_SITE=http://developer.kde.org/~wheeler/files/src
TAGLIB_VERSION=1.5
TAGLIB_SOURCE=taglib-$(TAGLIB_VERSION).tar.gz
TAGLIB_DIR=taglib-$(TAGLIB_VERSION)
TAGLIB_UNZIP=zcat
TAGLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TAGLIB_DESCRIPTION=A library for reading and editing the meta-data of several popular audio formats.
TAGLIB_SECTION=lib
TAGLIB_PRIORITY=optional
TAGLIB_DEPENDS=
TAGLIB_SUGGESTS=
TAGLIB_CONFLICTS=

#
# TAGLIB_IPK_VERSION should be incremented when the ipk changes.
#
TAGLIB_IPK_VERSION=1

#
# TAGLIB_CONFFILES should be a list of user-editable files
#TAGLIB_CONFFILES=/opt/etc/taglib.conf /opt/etc/init.d/SXXtaglib

#
# TAGLIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TAGLIB_PATCHES=$(TAGLIB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TAGLIB_CPPFLAGS=
TAGLIB_LDFLAGS=

#
# TAGLIB_BUILD_DIR is the directory in which the build is done.
# TAGLIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TAGLIB_IPK_DIR is the directory in which the ipk is built.
# TAGLIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TAGLIB_BUILD_DIR=$(BUILD_DIR)/taglib
TAGLIB_SOURCE_DIR=$(SOURCE_DIR)/taglib
TAGLIB_IPK_DIR=$(BUILD_DIR)/taglib-$(TAGLIB_VERSION)-ipk
TAGLIB_IPK=$(BUILD_DIR)/taglib_$(TAGLIB_VERSION)-$(TAGLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: taglib-source taglib-unpack taglib taglib-stage taglib-ipk taglib-clean taglib-dirclean taglib-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TAGLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(TAGLIB_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
taglib-source: $(DL_DIR)/$(TAGLIB_SOURCE) $(TAGLIB_PATCHES)

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
$(TAGLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(TAGLIB_SOURCE) $(TAGLIB_PATCHES) make/taglib.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TAGLIB_DIR) $(@D)
	$(TAGLIB_UNZIP) $(DL_DIR)/$(TAGLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TAGLIB_PATCHES)" ; \
		then cat $(TAGLIB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TAGLIB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TAGLIB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TAGLIB_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TAGLIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TAGLIB_LDFLAGS)" \
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

taglib-unpack: $(TAGLIB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TAGLIB_BUILD_DIR)/.built: $(TAGLIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
taglib: $(TAGLIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TAGLIB_BUILD_DIR)/.staged: $(TAGLIB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) transform="" install
	sed -i -e '/includedir=/s|$${prefix}|$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/taglib-config
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/taglib.pc
	touch $@

taglib-stage: $(TAGLIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/taglib
#
$(TAGLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: taglib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TAGLIB_PRIORITY)" >>$@
	@echo "Section: $(TAGLIB_SECTION)" >>$@
	@echo "Version: $(TAGLIB_VERSION)-$(TAGLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TAGLIB_MAINTAINER)" >>$@
	@echo "Source: $(TAGLIB_SITE)/$(TAGLIB_SOURCE)" >>$@
	@echo "Description: $(TAGLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(TAGLIB_DEPENDS)" >>$@
	@echo "Suggests: $(TAGLIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(TAGLIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TAGLIB_IPK_DIR)/opt/sbin or $(TAGLIB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TAGLIB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TAGLIB_IPK_DIR)/opt/etc/taglib/...
# Documentation files should be installed in $(TAGLIB_IPK_DIR)/opt/doc/taglib/...
# Daemon startup scripts should be installed in $(TAGLIB_IPK_DIR)/opt/etc/init.d/S??taglib
#
# You may need to patch your application to make it use these locations.
#
$(TAGLIB_IPK): $(TAGLIB_BUILD_DIR)/.built
	rm -rf $(TAGLIB_IPK_DIR) $(BUILD_DIR)/taglib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TAGLIB_BUILD_DIR) DESTDIR=$(TAGLIB_IPK_DIR) transform="" install-strip
#	install -d $(TAGLIB_IPK_DIR)/opt/etc/
#	install -m 644 $(TAGLIB_SOURCE_DIR)/taglib.conf $(TAGLIB_IPK_DIR)/opt/etc/taglib.conf
#	install -d $(TAGLIB_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TAGLIB_SOURCE_DIR)/rc.taglib $(TAGLIB_IPK_DIR)/opt/etc/init.d/SXXtaglib
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TAGLIB_IPK_DIR)/opt/etc/init.d/SXXtaglib
	$(MAKE) $(TAGLIB_IPK_DIR)/CONTROL/control
#	install -m 755 $(TAGLIB_SOURCE_DIR)/postinst $(TAGLIB_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TAGLIB_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TAGLIB_SOURCE_DIR)/prerm $(TAGLIB_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TAGLIB_IPK_DIR)/CONTROL/prerm
	echo $(TAGLIB_CONFFILES) | sed -e 's/ /\n/g' > $(TAGLIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TAGLIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
taglib-ipk: $(TAGLIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
taglib-clean:
	rm -f $(TAGLIB_BUILD_DIR)/.built
	-$(MAKE) -C $(TAGLIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
taglib-dirclean:
	rm -rf $(BUILD_DIR)/$(TAGLIB_DIR) $(TAGLIB_BUILD_DIR) $(TAGLIB_IPK_DIR) $(TAGLIB_IPK)
#
#
# Some sanity check for the package.
#
taglib-check: $(TAGLIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TAGLIB_IPK)
