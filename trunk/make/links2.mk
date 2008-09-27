###########################################################
#
# links2
#
###########################################################
#
# LINKS2_VERSION, LINKS2_SITE and LINKS2_SOURCE define
# the upstream location of the source code for the package.
# LINKS2_DIR is the directory which is created when the source
# archive is unpacked.
# LINKS2_UNZIP is the command used to unzip the source.
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
LINKS2_SITE=http://links.twibright.com/download
LINKS2_VERSION=2.2
LINKS2_SOURCE=links-$(LINKS2_VERSION).tar.bz2
LINKS2_DIR=links-$(LINKS2_VERSION)
LINKS2_UNZIP=bzcat
LINKS2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LINKS2_DESCRIPTION=Links is a web browser that can run in text mode.
LINKS2_SECTION=web
LINKS2_PRIORITY=optional
LINKS2_DEPENDS=bzip2, openssl, zlib
LINKS2_SUGGESTS=
LINKS2_CONFLICTS=

#
# LINKS2_IPK_VERSION should be incremented when the ipk changes.
#
LINKS2_IPK_VERSION=1

#
# LINKS2_CONFFILES should be a list of user-editable files
#LINKS2_CONFFILES=/opt/etc/links2.conf /opt/etc/init.d/SXXlinks2

#
# LINKS2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LINKS2_PATCHES=$(LINKS2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LINKS2_CPPFLAGS=
LINKS2_LDFLAGS=

#
# LINKS2_BUILD_DIR is the directory in which the build is done.
# LINKS2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LINKS2_IPK_DIR is the directory in which the ipk is built.
# LINKS2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LINKS2_BUILD_DIR=$(BUILD_DIR)/links2
LINKS2_SOURCE_DIR=$(SOURCE_DIR)/links2
LINKS2_IPK_DIR=$(BUILD_DIR)/links2-$(LINKS2_VERSION)-ipk
LINKS2_IPK=$(BUILD_DIR)/links2_$(LINKS2_VERSION)-$(LINKS2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: links2-source links2-unpack links2 links2-stage links2-ipk links2-clean links2-dirclean links2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LINKS2_SOURCE):
	$(WGET) -P $(@D) $(LINKS2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
links2-source: $(DL_DIR)/$(LINKS2_SOURCE) $(LINKS2_PATCHES)

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
$(LINKS2_BUILD_DIR)/.configured: $(DL_DIR)/$(LINKS2_SOURCE) $(LINKS2_PATCHES) make/links2.mk
	$(MAKE) bzip2-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(LINKS2_DIR) $(@D)
	$(LINKS2_UNZIP) $(DL_DIR)/$(LINKS2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LINKS2_PATCHES)" ; \
		then cat $(LINKS2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LINKS2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LINKS2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LINKS2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LINKS2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LINKS2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-graphics \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

links2-unpack: $(LINKS2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LINKS2_BUILD_DIR)/.built: $(LINKS2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
links2: $(LINKS2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LINKS2_BUILD_DIR)/.staged: $(LINKS2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

links2-stage: $(LINKS2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/links2
#
$(LINKS2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: links2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LINKS2_PRIORITY)" >>$@
	@echo "Section: $(LINKS2_SECTION)" >>$@
	@echo "Version: $(LINKS2_VERSION)-$(LINKS2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LINKS2_MAINTAINER)" >>$@
	@echo "Source: $(LINKS2_SITE)/$(LINKS2_SOURCE)" >>$@
	@echo "Description: $(LINKS2_DESCRIPTION)" >>$@
	@echo "Depends: $(LINKS2_DEPENDS)" >>$@
	@echo "Suggests: $(LINKS2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LINKS2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LINKS2_IPK_DIR)/opt/sbin or $(LINKS2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LINKS2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LINKS2_IPK_DIR)/opt/etc/links2/...
# Documentation files should be installed in $(LINKS2_IPK_DIR)/opt/doc/links2/...
# Daemon startup scripts should be installed in $(LINKS2_IPK_DIR)/opt/etc/init.d/S??links2
#
# You may need to patch your application to make it use these locations.
#
$(LINKS2_IPK): $(LINKS2_BUILD_DIR)/.built
	rm -rf $(LINKS2_IPK_DIR) $(BUILD_DIR)/links2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LINKS2_BUILD_DIR) DESTDIR=$(LINKS2_IPK_DIR) install
	$(STRIP_COMMAND) $(LINKS2_IPK_DIR)/opt/bin/links
#	install -d $(LINKS2_IPK_DIR)/opt/etc/
#	install -m 644 $(LINKS2_SOURCE_DIR)/links2.conf $(LINKS2_IPK_DIR)/opt/etc/links2.conf
#	install -d $(LINKS2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LINKS2_SOURCE_DIR)/rc.links2 $(LINKS2_IPK_DIR)/opt/etc/init.d/SXXlinks2
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LINKS2_IPK_DIR)/opt/etc/init.d/SXXlinks2
	$(MAKE) $(LINKS2_IPK_DIR)/CONTROL/control
#	install -m 755 $(LINKS2_SOURCE_DIR)/postinst $(LINKS2_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LINKS2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LINKS2_SOURCE_DIR)/prerm $(LINKS2_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LINKS2_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LINKS2_IPK_DIR)/CONTROL/postinst $(LINKS2_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LINKS2_CONFFILES) | sed -e 's/ /\n/g' > $(LINKS2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LINKS2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
links2-ipk: $(LINKS2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
links2-clean:
	rm -f $(LINKS2_BUILD_DIR)/.built
	-$(MAKE) -C $(LINKS2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
links2-dirclean:
	rm -rf $(BUILD_DIR)/$(LINKS2_DIR) $(LINKS2_BUILD_DIR) $(LINKS2_IPK_DIR) $(LINKS2_IPK)
#
#
# Some sanity check for the package.
#
links2-check: $(LINKS2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LINKS2_IPK)
