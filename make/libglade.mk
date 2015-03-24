###########################################################
#
# libglade
#
###########################################################

# You must replace "libglade" and "LIBGLADE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBGLADE_VERSION, LIBGLADE_SITE and LIBGLADE_SOURCE define
# the upstream location of the source code for the package.
# LIBGLADE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGLADE_UNZIP is the command used to unzip the source.
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
LIBGLADE_SITE=http://ftp.gnome.org/pub/gnome/sources/libglade/2.6
LIBGLADE_VERSION=2.6.4
LIBGLADE_SOURCE=libglade-$(LIBGLADE_VERSION).tar.bz2
LIBGLADE_DIR=libglade-$(LIBGLADE_VERSION)
LIBGLADE_UNZIP=bzcat
LIBGLADE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGLADE_DESCRIPTION=Library for dynamically loading GLADE interface files.
LIBGLADE_SECTION=lib
LIBGLADE_PRIORITY=optional
LIBGLADE_DEPENDS=libxml2, gtk2
LIBGLADE_SUGGESTS=
LIBGLADE_CONFLICTS=

#
# LIBGLADE_IPK_VERSION should be incremented when the ipk changes.
#
LIBGLADE_IPK_VERSION=1

#
# LIBGLADE_CONFFILES should be a list of user-editable files
#LIBGLADE_CONFFILES=/opt/etc/libglade.conf /opt/etc/init.d/SXXlibglade

#
# LIBGLADE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBGLADE_PATCHES=$(LIBGLADE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGLADE_CPPFLAGS=
LIBGLADE_LDFLAGS=

#
# LIBGLADE_BUILD_DIR is the directory in which the build is done.
# LIBGLADE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGLADE_IPK_DIR is the directory in which the ipk is built.
# LIBGLADE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGLADE_BUILD_DIR=$(BUILD_DIR)/libglade
LIBGLADE_SOURCE_DIR=$(SOURCE_DIR)/libglade
LIBGLADE_IPK_DIR=$(BUILD_DIR)/libglade-$(LIBGLADE_VERSION)-ipk
LIBGLADE_IPK=$(BUILD_DIR)/libglade_$(LIBGLADE_VERSION)-$(LIBGLADE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libglade-source libglade-unpack libglade libglade-stage libglade-ipk libglade-clean libglade-dirclean libglade-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGLADE_SOURCE):
	$(WGET) -P $(@D) $(LIBGLADE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libglade-source: $(DL_DIR)/$(LIBGLADE_SOURCE) $(LIBGLADE_PATCHES)

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
$(LIBGLADE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGLADE_SOURCE) $(LIBGLADE_PATCHES) make/libglade.mk
	$(MAKE) libxml2-stage gtk2-stage
	rm -rf $(BUILD_DIR)/$(LIBGLADE_DIR) $(@D)
	$(LIBGLADE_UNZIP) $(DL_DIR)/$(LIBGLADE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBGLADE_PATCHES)" ; \
		then cat $(LIBGLADE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBGLADE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBGLADE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBGLADE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGLADE_CPPFLAGS)" \
		LDFLAGS="$(LIBGLADE_LDFLAGS) $(STAGING_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
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

libglade-unpack: $(LIBGLADE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGLADE_BUILD_DIR)/.built: $(LIBGLADE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libglade: $(LIBGLADE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGLADE_BUILD_DIR)/.staged: $(LIBGLADE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libglade-2.0.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libglade-2.0.pc
	touch $@

libglade-stage: $(LIBGLADE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libglade
#
$(LIBGLADE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libglade" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGLADE_PRIORITY)" >>$@
	@echo "Section: $(LIBGLADE_SECTION)" >>$@
	@echo "Version: $(LIBGLADE_VERSION)-$(LIBGLADE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGLADE_MAINTAINER)" >>$@
	@echo "Source: $(LIBGLADE_SITE)/$(LIBGLADE_SOURCE)" >>$@
	@echo "Description: $(LIBGLADE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGLADE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGLADE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGLADE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGLADE_IPK_DIR)/opt/sbin or $(LIBGLADE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGLADE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGLADE_IPK_DIR)/opt/etc/libglade/...
# Documentation files should be installed in $(LIBGLADE_IPK_DIR)/opt/doc/libglade/...
# Daemon startup scripts should be installed in $(LIBGLADE_IPK_DIR)/opt/etc/init.d/S??libglade
#
# You may need to patch your application to make it use these locations.
#
$(LIBGLADE_IPK): $(LIBGLADE_BUILD_DIR)/.built
	rm -rf $(LIBGLADE_IPK_DIR) $(BUILD_DIR)/libglade_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGLADE_BUILD_DIR) DESTDIR=$(LIBGLADE_IPK_DIR) install-strip
	rm -rf $(LIBGLADE_IPK_DIR)/opt/bin $(LIBGLADE_IPK_DIR)/opt/share/gtk-doc $(LIBGLADE_IPK_DIR)/opt/lib/libglade-2.0.la
#	install -d $(LIBGLADE_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBGLADE_SOURCE_DIR)/libglade.conf $(LIBGLADE_IPK_DIR)/opt/etc/libglade.conf
#	install -d $(LIBGLADE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBGLADE_SOURCE_DIR)/rc.libglade $(LIBGLADE_IPK_DIR)/opt/etc/init.d/SXXlibglade
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBGLADE_IPK_DIR)/opt/etc/init.d/SXXlibglade
	$(MAKE) $(LIBGLADE_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBGLADE_SOURCE_DIR)/postinst $(LIBGLADE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBGLADE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBGLADE_SOURCE_DIR)/prerm $(LIBGLADE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBGLADE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBGLADE_IPK_DIR)/CONTROL/postinst $(LIBGLADE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBGLADE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBGLADE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGLADE_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBGLADE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libglade-ipk: $(LIBGLADE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libglade-clean:
	rm -f $(LIBGLADE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBGLADE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libglade-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGLADE_DIR) $(LIBGLADE_BUILD_DIR) $(LIBGLADE_IPK_DIR) $(LIBGLADE_IPK)
#
#
# Some sanity check for the package.
#
libglade-check: $(LIBGLADE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
