###########################################################
#
# gloox
#
###########################################################
#
# GLOOX_VERSION, GLOOX_SITE and GLOOX_SOURCE define
# the upstream location of the source code for the package.
# GLOOX_DIR is the directory which is created when the source
# archive is unpacked.
# GLOOX_UNZIP is the command used to unzip the source.
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
GLOOX_SITE=http://camaya.net/download
GLOOX_VERSION=0.9.9.5
GLOOX_SOURCE=gloox-$(GLOOX_VERSION).tar.bz2
GLOOX_DIR=gloox-$(GLOOX_VERSION)
GLOOX_UNZIP=bzcat
GLOOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GLOOX_DESCRIPTION=gloox is a rock-solid, full-featured Jabber/XMPP client library, written in C++.
GLOOX_SECTION=lib
GLOOX_PRIORITY=optional
GLOOX_DEPENDS=gnutls, libidn
GLOOX_SUGGESTS=
GLOOX_CONFLICTS=

#
# GLOOX_IPK_VERSION should be incremented when the ipk changes.
#
GLOOX_IPK_VERSION=2

#
# GLOOX_CONFFILES should be a list of user-editable files
#GLOOX_CONFFILES=/opt/etc/gloox.conf /opt/etc/init.d/SXXgloox

#
# GLOOX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GLOOX_PATCHES=$(GLOOX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GLOOX_CPPFLAGS=
GLOOX_LDFLAGS=-lgnutls

#
# GLOOX_BUILD_DIR is the directory in which the build is done.
# GLOOX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GLOOX_IPK_DIR is the directory in which the ipk is built.
# GLOOX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GLOOX_BUILD_DIR=$(BUILD_DIR)/gloox
GLOOX_SOURCE_DIR=$(SOURCE_DIR)/gloox
GLOOX_IPK_DIR=$(BUILD_DIR)/gloox-$(GLOOX_VERSION)-ipk
GLOOX_IPK=$(BUILD_DIR)/gloox_$(GLOOX_VERSION)-$(GLOOX_IPK_VERSION)_$(TARGET_ARCH).ipk
GLOOX-DEV_IPK_DIR=$(BUILD_DIR)/gloox-dev-$(GLOOX_VERSION)-ipk
GLOOX-DEV_IPK=$(BUILD_DIR)/gloox-dev_$(GLOOX_VERSION)-$(GLOOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gloox-source gloox-unpack gloox gloox-stage gloox-ipk gloox-clean gloox-dirclean gloox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GLOOX_SOURCE):
	$(WGET) -P $(@D) $(GLOOX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gloox-source: $(DL_DIR)/$(GLOOX_SOURCE) $(GLOOX_PATCHES)

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
$(GLOOX_BUILD_DIR)/.configured: $(DL_DIR)/$(GLOOX_SOURCE) $(GLOOX_PATCHES) make/gloox.mk
	$(MAKE) gnutls-stage libidn-stage
	rm -rf $(BUILD_DIR)/$(GLOOX_DIR) $(@D)
	$(GLOOX_UNZIP) $(DL_DIR)/$(GLOOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GLOOX_PATCHES)" ; \
		then cat $(GLOOX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GLOOX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GLOOX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GLOOX_DIR) $(@D) ; \
	fi
	sed -i -e 's/ -pedantic//' $(@D)/src/Makefile.in $(@D)/src/tests/*/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GLOOX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GLOOX_LDFLAGS)" \
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

gloox-unpack: $(GLOOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GLOOX_BUILD_DIR)/.built: $(GLOOX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gloox: $(GLOOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GLOOX_BUILD_DIR)/.staged: $(GLOOX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgloox.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gloox.pc
	touch $@

gloox-stage: $(GLOOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gloox
#
$(GLOOX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gloox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GLOOX_PRIORITY)" >>$@
	@echo "Section: $(GLOOX_SECTION)" >>$@
	@echo "Version: $(GLOOX_VERSION)-$(GLOOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GLOOX_MAINTAINER)" >>$@
	@echo "Source: $(GLOOX_SITE)/$(GLOOX_SOURCE)" >>$@
	@echo "Description: $(GLOOX_DESCRIPTION)" >>$@
	@echo "Depends: $(GLOOX_DEPENDS)" >>$@
	@echo "Suggests: $(GLOOX_SUGGESTS)" >>$@
	@echo "Conflicts: $(GLOOX_CONFLICTS)" >>$@

$(GLOOX-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gloox-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GLOOX_PRIORITY)" >>$@
	@echo "Section: $(GLOOX_SECTION)" >>$@
	@echo "Version: $(GLOOX_VERSION)-$(GLOOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GLOOX_MAINTAINER)" >>$@
	@echo "Source: $(GLOOX_SITE)/$(GLOOX_SOURCE)" >>$@
	@echo "Description: Development files for gloox library" >>$@
	@echo "Depends: gloox" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GLOOX_IPK_DIR)/opt/sbin or $(GLOOX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GLOOX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GLOOX_IPK_DIR)/opt/etc/gloox/...
# Documentation files should be installed in $(GLOOX_IPK_DIR)/opt/doc/gloox/...
# Daemon startup scripts should be installed in $(GLOOX_IPK_DIR)/opt/etc/init.d/S??gloox
#
# You may need to patch your application to make it use these locations.
#
$(GLOOX_IPK): $(GLOOX_BUILD_DIR)/.built
	rm -rf $(GLOOX_IPK_DIR) $(BUILD_DIR)/gloox_*_$(TARGET_ARCH).ipk
	rm -rf $(GLOOX-DEV_IPK_DIR) $(BUILD_DIR)/gloox-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GLOOX_BUILD_DIR) DESTDIR=$(GLOOX_IPK_DIR) install-strip
	install -d $(GLOOX-DEV_IPK_DIR)/opt/lib
	mv $(GLOOX_IPK_DIR)/opt/include $(GLOOX-DEV_IPK_DIR)/opt/
	mv $(GLOOX_IPK_DIR)/opt/lib/pkgconfig $(GLOOX-DEV_IPK_DIR)/opt/lib/
	mv $(GLOOX_IPK_DIR)/opt/lib/*.la $(GLOOX-DEV_IPK_DIR)/opt/lib/
	$(MAKE) $(GLOOX-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLOOX-DEV_IPK_DIR)
	$(MAKE) $(GLOOX_IPK_DIR)/CONTROL/control
	echo $(GLOOX_CONFFILES) | sed -e 's/ /\n/g' > $(GLOOX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLOOX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gloox-ipk: $(GLOOX_IPK) $(GLOOX-DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gloox-clean:
	rm -f $(GLOOX_BUILD_DIR)/.built
	-$(MAKE) -C $(GLOOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gloox-dirclean:
	rm -rf $(BUILD_DIR)/$(GLOOX_DIR) $(GLOOX_BUILD_DIR)
	rm -rf $(GLOOX_IPK_DIR) $(GLOOX_IPK)
	rm -rf $(GLOOX-DEV_IPK_DIR) $(GLOOX-DEV_IPK)
#
#
# Some sanity check for the package.
#
gloox-check: $(GLOOX_IPK) $(GLOOX-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GLOOX_IPK) $(GLOOX-DEV_IPK)
