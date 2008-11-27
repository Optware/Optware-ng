###########################################################
#
# silc-client
#
###########################################################
#
# SILC_CLIENT_VERSION, SILC_CLIENT_SITE and SILC_CLIENT_SOURCE define
# the upstream location of the source code for the package.
# SILC_CLIENT_DIR is the directory which is created when the source
# archive is unpacked.
# SILC_CLIENT_UNZIP is the command used to unzip the source.
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
SILC_CLIENT_SITE=http://www.silcnet.org/download/client/sources
SILC_CLIENT_VERSION=1.1.6
SILC_CLIENT_SOURCE=silc-client-$(SILC_CLIENT_VERSION).tar.bz2
SILC_CLIENT_DIR=silc-client-$(SILC_CLIENT_VERSION)
SILC_CLIENT_UNZIP=bzcat
SILC_CLIENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SILC_CLIENT_DESCRIPTION=Secure Internet Live Conferencing client.
SILC_CLIENT_SECTION=net
SILC_CLIENT_PRIORITY=optional
SILC_CLIENT_DEPENDS=glib, ncurses
SILC_CLIENT_SUGGESTS=
SILC_CLIENT_CONFLICTS=

#
# SILC_CLIENT_IPK_VERSION should be incremented when the ipk changes.
#
SILC_CLIENT_IPK_VERSION=1

#
# SILC_CLIENT_CONFFILES should be a list of user-editable files
#SILC_CLIENT_CONFFILES=/opt/etc/silc-client.conf /opt/etc/init.d/SXXsilc-client

#
# SILC_CLIENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SILC_CLIENT_PATCHES=$(SILC_CLIENT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SILC_CLIENT_CPPFLAGS=
SILC_CLIENT_LDFLAGS=

#
# SILC_CLIENT_BUILD_DIR is the directory in which the build is done.
# SILC_CLIENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SILC_CLIENT_IPK_DIR is the directory in which the ipk is built.
# SILC_CLIENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SILC_CLIENT_BUILD_DIR=$(BUILD_DIR)/silc-client
SILC_CLIENT_SOURCE_DIR=$(SOURCE_DIR)/silc-client
SILC_CLIENT_IPK_DIR=$(BUILD_DIR)/silc-client-$(SILC_CLIENT_VERSION)-ipk
SILC_CLIENT_IPK=$(BUILD_DIR)/silc-client_$(SILC_CLIENT_VERSION)-$(SILC_CLIENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: silc-client-source silc-client-unpack silc-client silc-client-stage silc-client-ipk silc-client-clean silc-client-dirclean silc-client-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SILC_CLIENT_SOURCE):
	$(WGET) -P $(@D) $(SILC_CLIENT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
silc-client-source: $(DL_DIR)/$(SILC_CLIENT_SOURCE) $(SILC_CLIENT_PATCHES)

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
$(SILC_CLIENT_BUILD_DIR)/.configured: $(DL_DIR)/$(SILC_CLIENT_SOURCE) $(SILC_CLIENT_PATCHES) make/silc-client.mk
	$(MAKE) glib-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(SILC_CLIENT_DIR) $(@D)
	$(SILC_CLIENT_UNZIP) $(DL_DIR)/$(SILC_CLIENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SILC_CLIENT_PATCHES)" ; \
		then cat $(SILC_CLIENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SILC_CLIENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SILC_CLIENT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SILC_CLIENT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SILC_CLIENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SILC_CLIENT_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
ac_cv_func_epoll_wait=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-perl \
		--disable-asm \
		--disable-ipv6 \
		--without-silcd \
		--without-pthreads \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

silc-client-unpack: $(SILC_CLIENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SILC_CLIENT_BUILD_DIR)/.built: $(SILC_CLIENT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
silc-client: $(SILC_CLIENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SILC_CLIENT_BUILD_DIR)/.staged: $(SILC_CLIENT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

silc-client-stage: $(SILC_CLIENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/silc-client
#
$(SILC_CLIENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: silc-client" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SILC_CLIENT_PRIORITY)" >>$@
	@echo "Section: $(SILC_CLIENT_SECTION)" >>$@
	@echo "Version: $(SILC_CLIENT_VERSION)-$(SILC_CLIENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SILC_CLIENT_MAINTAINER)" >>$@
	@echo "Source: $(SILC_CLIENT_SITE)/$(SILC_CLIENT_SOURCE)" >>$@
	@echo "Description: $(SILC_CLIENT_DESCRIPTION)" >>$@
	@echo "Depends: $(SILC_CLIENT_DEPENDS)" >>$@
	@echo "Suggests: $(SILC_CLIENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SILC_CLIENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SILC_CLIENT_IPK_DIR)/opt/sbin or $(SILC_CLIENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SILC_CLIENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SILC_CLIENT_IPK_DIR)/opt/etc/silc-client/...
# Documentation files should be installed in $(SILC_CLIENT_IPK_DIR)/opt/doc/silc-client/...
# Daemon startup scripts should be installed in $(SILC_CLIENT_IPK_DIR)/opt/etc/init.d/S??silc-client
#
# You may need to patch your application to make it use these locations.
#
$(SILC_CLIENT_IPK): $(SILC_CLIENT_BUILD_DIR)/.built
	rm -rf $(SILC_CLIENT_IPK_DIR) $(BUILD_DIR)/silc-client_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SILC_CLIENT_BUILD_DIR) DESTDIR=$(SILC_CLIENT_IPK_DIR) install-strip
#	install -d $(SILC_CLIENT_IPK_DIR)/opt/etc/
#	install -m 644 $(SILC_CLIENT_SOURCE_DIR)/silc-client.conf $(SILC_CLIENT_IPK_DIR)/opt/etc/silc-client.conf
#	install -d $(SILC_CLIENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SILC_CLIENT_SOURCE_DIR)/rc.silc-client $(SILC_CLIENT_IPK_DIR)/opt/etc/init.d/SXXsilc-client
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SILC_CLIENT_IPK_DIR)/opt/etc/init.d/SXXsilc-client
	$(MAKE) $(SILC_CLIENT_IPK_DIR)/CONTROL/control
#	install -m 755 $(SILC_CLIENT_SOURCE_DIR)/postinst $(SILC_CLIENT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SILC_CLIENT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SILC_CLIENT_SOURCE_DIR)/prerm $(SILC_CLIENT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SILC_CLIENT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SILC_CLIENT_IPK_DIR)/CONTROL/postinst $(SILC_CLIENT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SILC_CLIENT_CONFFILES) | sed -e 's/ /\n/g' > $(SILC_CLIENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SILC_CLIENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
silc-client-ipk: $(SILC_CLIENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
silc-client-clean:
	rm -f $(SILC_CLIENT_BUILD_DIR)/.built
	-$(MAKE) -C $(SILC_CLIENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
silc-client-dirclean:
	rm -rf $(BUILD_DIR)/$(SILC_CLIENT_DIR) $(SILC_CLIENT_BUILD_DIR) $(SILC_CLIENT_IPK_DIR) $(SILC_CLIENT_IPK)
#
#
# Some sanity check for the package.
#
silc-client-check: $(SILC_CLIENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SILC_CLIENT_IPK)
