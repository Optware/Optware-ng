###########################################################
#
# gnet
#
###########################################################
#
# GNET_VERSION, GNET_SITE and GNET_SOURCE define
# the upstream location of the source code for the package.
# GNET_DIR is the directory which is created when the source
# archive is unpacked.
# GNET_UNZIP is the command used to unzip the source.
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
GNET_SITE=http://ftp.gnome.org/pub/GNOME/sources/gnet/2.0
GNET_VERSION=2.0.8
GNET_SOURCE=gnet-$(GNET_VERSION).tar.gz
GNET_DIR=gnet-$(GNET_VERSION)
GNET_UNZIP=zcat
GNET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNET_DESCRIPTION=A simple network library written in C, object-oriented, and built upon GLib.
GNET_SECTION=lib
GNET_PRIORITY=optional
GNET_DEPENDS=glib
GNET_SUGGESTS=
GNET_CONFLICTS=

#
# GNET_IPK_VERSION should be incremented when the ipk changes.
#
GNET_IPK_VERSION=1

#
# GNET_CONFFILES should be a list of user-editable files
#GNET_CONFFILES=/opt/etc/gnet.conf /opt/etc/init.d/SXXgnet

#
# GNET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GNET_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNET_CPPFLAGS=
GNET_LDFLAGS=

#
# GNET_BUILD_DIR is the directory in which the build is done.
# GNET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNET_IPK_DIR is the directory in which the ipk is built.
# GNET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNET_BUILD_DIR=$(BUILD_DIR)/gnet
GNET_SOURCE_DIR=$(SOURCE_DIR)/gnet
GNET_IPK_DIR=$(BUILD_DIR)/gnet-$(GNET_VERSION)-ipk
GNET_IPK=$(BUILD_DIR)/gnet_$(GNET_VERSION)-$(GNET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gnet-source gnet-unpack gnet gnet-stage gnet-ipk gnet-clean gnet-dirclean gnet-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNET_SOURCE):
	$(WGET) -P $(DL_DIR) $(GNET_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnet-source: $(DL_DIR)/$(GNET_SOURCE) $(GNET_PATCHES)

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
$(GNET_BUILD_DIR)/.configured: $(DL_DIR)/$(GNET_SOURCE) $(GNET_PATCHES) make/gnet.mk
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(GNET_DIR) $(GNET_BUILD_DIR)
	$(GNET_UNZIP) $(DL_DIR)/$(GNET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNET_PATCHES)" ; \
		then cat $(GNET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GNET_DIR)" != "$(GNET_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GNET_DIR) $(GNET_BUILD_DIR) ; \
	fi
	(cd $(GNET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNET_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_gnet_have_abstract_sockets=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-pthreads \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(GNET_BUILD_DIR)/libtool
	touch $@

gnet-unpack: $(GNET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNET_BUILD_DIR)/.built: $(GNET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GNET_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gnet: $(GNET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNET_BUILD_DIR)/.staged: $(GNET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GNET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gnet-*.pc
	touch $@

gnet-stage: $(GNET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnet
#
$(GNET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNET_PRIORITY)" >>$@
	@echo "Section: $(GNET_SECTION)" >>$@
	@echo "Version: $(GNET_VERSION)-$(GNET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNET_MAINTAINER)" >>$@
	@echo "Source: $(GNET_SITE)/$(GNET_SOURCE)" >>$@
	@echo "Description: $(GNET_DESCRIPTION)" >>$@
	@echo "Depends: $(GNET_DEPENDS)" >>$@
	@echo "Suggests: $(GNET_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNET_IPK_DIR)/opt/sbin or $(GNET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNET_IPK_DIR)/opt/etc/gnet/...
# Documentation files should be installed in $(GNET_IPK_DIR)/opt/doc/gnet/...
# Daemon startup scripts should be installed in $(GNET_IPK_DIR)/opt/etc/init.d/S??gnet
#
# You may need to patch your application to make it use these locations.
#
$(GNET_IPK): $(GNET_BUILD_DIR)/.built
	rm -rf $(GNET_IPK_DIR) $(BUILD_DIR)/gnet_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNET_BUILD_DIR) DESTDIR=$(GNET_IPK_DIR) install-strip
#	install -d $(GNET_IPK_DIR)/opt/etc/
#	install -m 644 $(GNET_SOURCE_DIR)/gnet.conf $(GNET_IPK_DIR)/opt/etc/gnet.conf
#	install -d $(GNET_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GNET_SOURCE_DIR)/rc.gnet $(GNET_IPK_DIR)/opt/etc/init.d/SXXgnet
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNET_IPK_DIR)/opt/etc/init.d/SXXgnet
	$(MAKE) $(GNET_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNET_SOURCE_DIR)/postinst $(GNET_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNET_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNET_SOURCE_DIR)/prerm $(GNET_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNET_IPK_DIR)/CONTROL/prerm
	echo $(GNET_CONFFILES) | sed -e 's/ /\n/g' > $(GNET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnet-ipk: $(GNET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnet-clean:
	rm -f $(GNET_BUILD_DIR)/.built
	-$(MAKE) -C $(GNET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnet-dirclean:
	rm -rf $(BUILD_DIR)/$(GNET_DIR) $(GNET_BUILD_DIR) $(GNET_IPK_DIR) $(GNET_IPK)
#
#
# Some sanity check for the package.
#
gnet-check: $(GNET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNET_IPK)
