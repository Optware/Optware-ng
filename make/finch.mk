###########################################################
#
# finch
#
###########################################################
#
# when we have a second client also uses libpurple, we should separate it into its own ipk, and make sure stage works
#
FINCH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pidgin
FINCH_VERSION=2.3.1
FINCH_SOURCE=pidgin-$(FINCH_VERSION).tar.bz2
FINCH_DIR=pidgin-$(FINCH_VERSION)
FINCH_UNZIP=bzcat
FINCH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FINCH_DESCRIPTION=Finch is a console-based IM program that lets you sign on to AIM, Jabber, MSN, Yahoo!, and other IM networks. \
It uses ncurses. It was formerly called Gaim-text.
FINCH_SECTION=net-im
FINCH_PRIORITY=optional
FINCH_DEPENDS=glib, gnutls, libxml2, ncursesw
FINCH_SUGGESTS=
FINCH_CONFLICTS=

#
# FINCH_IPK_VERSION should be incremented when the ipk changes.
#
FINCH_IPK_VERSION=1

#
# FINCH_CONFFILES should be a list of user-editable files
#FINCH_CONFFILES=/opt/etc/finch.conf /opt/etc/init.d/SXXfinch

#
# FINCH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FINCH_PATCHES=$(FINCH_SOURCE_DIR)/glib2.6-G_PARAM_STATIC.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FINCH_CPPFLAGS=
FINCH_LDFLAGS=

#
# FINCH_BUILD_DIR is the directory in which the build is done.
# FINCH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FINCH_IPK_DIR is the directory in which the ipk is built.
# FINCH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FINCH_BUILD_DIR=$(BUILD_DIR)/finch
FINCH_SOURCE_DIR=$(SOURCE_DIR)/finch
FINCH_IPK_DIR=$(BUILD_DIR)/finch-$(FINCH_VERSION)-ipk
FINCH_IPK=$(BUILD_DIR)/finch_$(FINCH_VERSION)-$(FINCH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: finch-source finch-unpack finch finch-stage finch-ipk finch-clean finch-dirclean finch-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FINCH_SOURCE):
	$(WGET) -P $(DL_DIR) $(FINCH_SITE)/$(FINCH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FINCH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
finch-source: $(DL_DIR)/$(FINCH_SOURCE) $(FINCH_PATCHES)

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
$(FINCH_BUILD_DIR)/.configured: $(DL_DIR)/$(FINCH_SOURCE) $(FINCH_PATCHES) make/finch.mk
	$(MAKE) glib-stage gnutls-stage libxml2-stage ncursesw-stage
	rm -rf $(BUILD_DIR)/$(FINCH_DIR) $(FINCH_BUILD_DIR)
	$(FINCH_UNZIP) $(DL_DIR)/$(FINCH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FINCH_PATCHES)" ; \
		then cat $(FINCH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FINCH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FINCH_DIR)" != "$(FINCH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FINCH_DIR) $(FINCH_BUILD_DIR) ; \
	fi
	sed -i.orig -e '/^SUBDIRS/s/ plugins//' $(FINCH_BUILD_DIR)/finch/Makefile.in
	(cd $(FINCH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FINCH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FINCH_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-consoleui \
		--disable-gtkui \
		--with-ncurses-headers=$(STAGING_INCLUDE_DIR)/ncursesw \
		--without-x \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(FINCH_BUILD_DIR)/libtool
	touch $@

finch-unpack: $(FINCH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FINCH_BUILD_DIR)/.built: $(FINCH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FINCH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
finch: $(FINCH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FINCH_BUILD_DIR)/.staged: $(FINCH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FINCH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

finch-stage: $(FINCH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/finch
#
$(FINCH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: finch" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FINCH_PRIORITY)" >>$@
	@echo "Section: $(FINCH_SECTION)" >>$@
	@echo "Version: $(FINCH_VERSION)-$(FINCH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FINCH_MAINTAINER)" >>$@
	@echo "Source: $(FINCH_SITE)/$(FINCH_SOURCE)" >>$@
	@echo "Description: $(FINCH_DESCRIPTION)" >>$@
	@echo "Depends: $(FINCH_DEPENDS)" >>$@
	@echo "Suggests: $(FINCH_SUGGESTS)" >>$@
	@echo "Conflicts: $(FINCH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FINCH_IPK_DIR)/opt/sbin or $(FINCH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FINCH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FINCH_IPK_DIR)/opt/etc/finch/...
# Documentation files should be installed in $(FINCH_IPK_DIR)/opt/doc/finch/...
# Daemon startup scripts should be installed in $(FINCH_IPK_DIR)/opt/etc/init.d/S??finch
#
# You may need to patch your application to make it use these locations.
#
$(FINCH_IPK): $(FINCH_BUILD_DIR)/.built
	rm -rf $(FINCH_IPK_DIR) $(BUILD_DIR)/finch_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FINCH_BUILD_DIR) DESTDIR=$(FINCH_IPK_DIR) install-strip transform=""
	rm -f $(FINCH_IPK_DIR)/opt/lib/finch/*.la $(FINCH_IPK_DIR)/opt/lib/purple-2/*.la
	rm -f $(FINCH_IPK_DIR)/opt/lib/libpurple.la $(FINCH_IPK_DIR)/opt/lib/libgnt.la 
#	install -d $(FINCH_IPK_DIR)/opt/etc/
#	install -m 644 $(FINCH_SOURCE_DIR)/finch.conf $(FINCH_IPK_DIR)/opt/etc/finch.conf
#	install -d $(FINCH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FINCH_SOURCE_DIR)/rc.finch $(FINCH_IPK_DIR)/opt/etc/init.d/SXXfinch
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FINCH_IPK_DIR)/opt/etc/init.d/SXXfinch
	$(MAKE) $(FINCH_IPK_DIR)/CONTROL/control
#	install -m 755 $(FINCH_SOURCE_DIR)/postinst $(FINCH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FINCH_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FINCH_SOURCE_DIR)/prerm $(FINCH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FINCH_IPK_DIR)/CONTROL/prerm
	echo $(FINCH_CONFFILES) | sed -e 's/ /\n/g' > $(FINCH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FINCH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
finch-ipk: $(FINCH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
finch-clean:
	rm -f $(FINCH_BUILD_DIR)/.built
	-$(MAKE) -C $(FINCH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
finch-dirclean:
	rm -rf $(BUILD_DIR)/$(FINCH_DIR) $(FINCH_BUILD_DIR) $(FINCH_IPK_DIR) $(FINCH_IPK)
#
#
# Some sanity check for the package.
#
finch-check: $(FINCH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FINCH_IPK)
