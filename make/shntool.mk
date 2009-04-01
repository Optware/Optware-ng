###########################################################
#
# shntool
#
###########################################################
#
# SHNTOOL_VERSION, SHNTOOL_SITE and SHNTOOL_SOURCE define
# the upstream location of the source code for the package.
# SHNTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# SHNTOOL_UNZIP is the command used to unzip the source.
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
SHNTOOL_SITE=http://etree.org/shnutils/shntool/dist/src
SHNTOOL_VERSION=3.0.10
SHNTOOL_SOURCE=shntool-$(SHNTOOL_VERSION).tar.gz
SHNTOOL_DIR=shntool-$(SHNTOOL_VERSION)
SHNTOOL_UNZIP=zcat
SHNTOOL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SHNTOOL_DESCRIPTION=A multi-purpose WAVE data (compressed or not) processing and reporting utility.
SHNTOOL_SECTION=audio
SHNTOOL_PRIORITY=optional
SHNTOOL_DEPENDS=
SHNTOOL_SUGGESTS=
SHNTOOL_CONFLICTS=

#
# SHNTOOL_IPK_VERSION should be incremented when the ipk changes.
#
SHNTOOL_IPK_VERSION=1

#
# SHNTOOL_CONFFILES should be a list of user-editable files
#SHNTOOL_CONFFILES=/opt/etc/shntool.conf /opt/etc/init.d/SXXshntool

#
# SHNTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SHNTOOL_PATCHES=$(SHNTOOL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SHNTOOL_CPPFLAGS=
SHNTOOL_LDFLAGS=

#
# SHNTOOL_BUILD_DIR is the directory in which the build is done.
# SHNTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SHNTOOL_IPK_DIR is the directory in which the ipk is built.
# SHNTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SHNTOOL_BUILD_DIR=$(BUILD_DIR)/shntool
SHNTOOL_SOURCE_DIR=$(SOURCE_DIR)/shntool
SHNTOOL_IPK_DIR=$(BUILD_DIR)/shntool-$(SHNTOOL_VERSION)-ipk
SHNTOOL_IPK=$(BUILD_DIR)/shntool_$(SHNTOOL_VERSION)-$(SHNTOOL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: shntool-source shntool-unpack shntool shntool-stage shntool-ipk shntool-clean shntool-dirclean shntool-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SHNTOOL_SOURCE):
	$(WGET) -P $(@D) $(SHNTOOL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
shntool-source: $(DL_DIR)/$(SHNTOOL_SOURCE) $(SHNTOOL_PATCHES)

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
$(SHNTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(SHNTOOL_SOURCE) $(SHNTOOL_PATCHES) make/shntool.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SHNTOOL_DIR) $(@D)
	$(SHNTOOL_UNZIP) $(DL_DIR)/$(SHNTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SHNTOOL_PATCHES)" ; \
		then cat $(SHNTOOL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SHNTOOL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SHNTOOL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SHNTOOL_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SHNTOOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SHNTOOL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

shntool-unpack: $(SHNTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SHNTOOL_BUILD_DIR)/.built: $(SHNTOOL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
shntool: $(SHNTOOL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SHNTOOL_BUILD_DIR)/.staged: $(SHNTOOL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

shntool-stage: $(SHNTOOL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/shntool
#
$(SHNTOOL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: shntool" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SHNTOOL_PRIORITY)" >>$@
	@echo "Section: $(SHNTOOL_SECTION)" >>$@
	@echo "Version: $(SHNTOOL_VERSION)-$(SHNTOOL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SHNTOOL_MAINTAINER)" >>$@
	@echo "Source: $(SHNTOOL_SITE)/$(SHNTOOL_SOURCE)" >>$@
	@echo "Description: $(SHNTOOL_DESCRIPTION)" >>$@
	@echo "Depends: $(SHNTOOL_DEPENDS)" >>$@
	@echo "Suggests: $(SHNTOOL_SUGGESTS)" >>$@
	@echo "Conflicts: $(SHNTOOL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SHNTOOL_IPK_DIR)/opt/sbin or $(SHNTOOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SHNTOOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SHNTOOL_IPK_DIR)/opt/etc/shntool/...
# Documentation files should be installed in $(SHNTOOL_IPK_DIR)/opt/doc/shntool/...
# Daemon startup scripts should be installed in $(SHNTOOL_IPK_DIR)/opt/etc/init.d/S??shntool
#
# You may need to patch your application to make it use these locations.
#
$(SHNTOOL_IPK): $(SHNTOOL_BUILD_DIR)/.built
	rm -rf $(SHNTOOL_IPK_DIR) $(BUILD_DIR)/shntool_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SHNTOOL_BUILD_DIR) DESTDIR=$(SHNTOOL_IPK_DIR) install-strip
#	install -d $(SHNTOOL_IPK_DIR)/opt/etc/
#	install -m 644 $(SHNTOOL_SOURCE_DIR)/shntool.conf $(SHNTOOL_IPK_DIR)/opt/etc/shntool.conf
#	install -d $(SHNTOOL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SHNTOOL_SOURCE_DIR)/rc.shntool $(SHNTOOL_IPK_DIR)/opt/etc/init.d/SXXshntool
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHNTOOL_IPK_DIR)/opt/etc/init.d/SXXshntool
	$(MAKE) $(SHNTOOL_IPK_DIR)/CONTROL/control
#	install -m 755 $(SHNTOOL_SOURCE_DIR)/postinst $(SHNTOOL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHNTOOL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SHNTOOL_SOURCE_DIR)/prerm $(SHNTOOL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHNTOOL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SHNTOOL_IPK_DIR)/CONTROL/postinst $(SHNTOOL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SHNTOOL_CONFFILES) | sed -e 's/ /\n/g' > $(SHNTOOL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SHNTOOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
shntool-ipk: $(SHNTOOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
shntool-clean:
	rm -f $(SHNTOOL_BUILD_DIR)/.built
	-$(MAKE) -C $(SHNTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
shntool-dirclean:
	rm -rf $(BUILD_DIR)/$(SHNTOOL_DIR) $(SHNTOOL_BUILD_DIR) $(SHNTOOL_IPK_DIR) $(SHNTOOL_IPK)
#
#
# Some sanity check for the package.
#
shntool-check: $(SHNTOOL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
