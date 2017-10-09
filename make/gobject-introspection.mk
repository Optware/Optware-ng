###########################################################
#
# gobject-introspection
#
###########################################################

# You must replace "gobject-introspection" and "GOBJECT-INTROSPECTION" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GOBJECT-INTROSPECTION_VERSION, GOBJECT-INTROSPECTION_SITE and GOBJECT-INTROSPECTION_SOURCE define
# the upstream location of the source code for the package.
# GOBJECT-INTROSPECTION_DIR is the directory which is created when the source
# archive is unpacked.
# GOBJECT-INTROSPECTION_UNZIP is the command used to unzip the source.
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
GOBJECT-INTROSPECTION_SITE=http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.43
GOBJECT-INTROSPECTION_VERSION=1.43.92
GOBJECT-INTROSPECTION_SOURCE=gobject-introspection-$(GOBJECT-INTROSPECTION_VERSION).tar.xz
GOBJECT-INTROSPECTION_DIR=gobject-introspection-$(GOBJECT-INTROSPECTION_VERSION)
GOBJECT-INTROSPECTION_UNZIP=xzcat
GOBJECT-INTROSPECTION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GOBJECT-INTROSPECTION_DESCRIPTION=The GObject Introspection is used to describe the program APIs and collect them in a uniform, machine readable format.
GOBJECT-INTROSPECTION_SECTION=lib
GOBJECT-INTROSPECTION_PRIORITY=optional
GOBJECT-INTROSPECTION_DEPENDS=glib
GOBJECT-INTROSPECTION_SUGGESTS=py27-mako
GOBJECT-INTROSPECTION_CONFLICTS=

#
# GOBJECT-INTROSPECTION_IPK_VERSION should be incremented when the ipk changes.
#
GOBJECT-INTROSPECTION_IPK_VERSION=3

#
# GOBJECT-INTROSPECTION_CONFFILES should be a list of user-editable files
#GOBJECT-INTROSPECTION_CONFFILES=$(TARGET_PREFIX)/etc/gobject-introspection.conf $(TARGET_PREFIX)/etc/init.d/SXXgobject-introspection

#
# GOBJECT-INTROSPECTION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GOBJECT-INTROSPECTION_PATCHES=$(GOBJECT-INTROSPECTION_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GOBJECT-INTROSPECTION_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.7 -I$(STAGING_INCLUDE_DIR)/glib-2.0
GOBJECT-INTROSPECTION_LDFLAGS=-Wl,--no-as-needed

#
# GOBJECT-INTROSPECTION_BUILD_DIR is the directory in which the build is done.
# GOBJECT-INTROSPECTION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GOBJECT-INTROSPECTION_IPK_DIR is the directory in which the ipk is built.
# GOBJECT-INTROSPECTION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GOBJECT-INTROSPECTION_BUILD_DIR=$(BUILD_DIR)/gobject-introspection
GOBJECT-INTROSPECTION_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gobject-introspection
GOBJECT-INTROSPECTION_SOURCE_DIR=$(SOURCE_DIR)/gobject-introspection
GOBJECT-INTROSPECTION_IPK_DIR=$(BUILD_DIR)/gobject-introspection-$(GOBJECT-INTROSPECTION_VERSION)-ipk
GOBJECT-INTROSPECTION_IPK=$(BUILD_DIR)/gobject-introspection_$(GOBJECT-INTROSPECTION_VERSION)-$(GOBJECT-INTROSPECTION_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gobject-introspection-source gobject-introspection-unpack gobject-introspection gobject-introspection-stage gobject-introspection-ipk gobject-introspection-clean gobject-introspection-dirclean gobject-introspection-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GOBJECT-INTROSPECTION_SOURCE):
	$(WGET) -P $(@D) $(GOBJECT-INTROSPECTION_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gobject-introspection-source: $(DL_DIR)/$(GOBJECT-INTROSPECTION_SOURCE) $(GOBJECT-INTROSPECTION_PATCHES)

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
$(GOBJECT-INTROSPECTION_BUILD_DIR)/.configured: $(DL_DIR)/$(GOBJECT-INTROSPECTION_SOURCE) $(GOBJECT-INTROSPECTION_PATCHES) \
						$(GOBJECT-INTROSPECTION_HOST_BUILD_DIR)/.staged make/gobject-introspection.mk
	$(MAKE) glib-stage python27-stage python27-host-stage
	rm -rf $(BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR) $(@D)
	$(GOBJECT-INTROSPECTION_UNZIP) $(DL_DIR)/$(GOBJECT-INTROSPECTION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GOBJECT-INTROSPECTION_PATCHES)" ; \
		then cat $(GOBJECT-INTROSPECTION_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GOBJECT-INTROSPECTION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GOBJECT-INTROSPECTION_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.7 \
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

gobject-introspection-unpack: $(GOBJECT-INTROSPECTION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GOBJECT-INTROSPECTION_BUILD_DIR)/.built: $(GOBJECT-INTROSPECTION_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) libgirepository-1.0.la _giscanner.la g-ir-compiler g-ir-generate \
						g-ir-annotation-tool g-ir-doc-tool g-ir-scanner
	touch $@

#
# This is the build convenience target.
#
gobject-introspection: $(GOBJECT-INTROSPECTION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GOBJECT-INTROSPECTION_BUILD_DIR)/.staged: $(GOBJECT-INTROSPECTION_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-girepoHEADERS install-libLTLIBRARIES
	rm -f $(STAGING_LIB_DIR)/libgirepository-1.0.la
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	sed -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' -e '/^bindir=/s|=.*|=$(HOST_STAGING_PREFIX)/bin|' \
		-e '/^datarootdir=/s|=.*|=$(HOST_STAGING_PREFIX)/share|' \
		-e '/^typelibdir=/s|=.*|=$(HOST_STAGING_LIB_DIR)/girepository-1.0|' $(@D)/gobject-introspection-1.0.pc > \
						$(STAGING_LIB_DIR)/pkgconfig/gobject-introspection-1.0.pc
	sed -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' -e '/^bindir=/s|=.*|=$(HOST_STAGING_PREFIX)/bin|' \
		-e '/^datarootdir=/s|=.*|=$(HOST_STAGING_PREFIX)/share|' \
		-e '/^typelibdir=/s|=.*|=$(HOST_STAGING_LIB_DIR)/girepository-1.0|' $(@D)/gobject-introspection-no-export-1.0.pc > \
						$(STAGING_LIB_DIR)/pkgconfig/gobject-introspection-no-export-1.0.pc
	touch $@

gobject-introspection-stage: $(GOBJECT-INTROSPECTION_BUILD_DIR)/.staged

$(GOBJECT-INTROSPECTION_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(GOBJECT-INTROSPECTION_SOURCE) #make/gobject-introspection.mk
	$(MAKE) glib-host-stage py-mako-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR) $(@D)
	$(GOBJECT-INTROSPECTION_UNZIP) $(DL_DIR)/$(GOBJECT-INTROSPECTION_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		CFLAGS="-fPIC" \
		LDFLAGS="-L$(HOST_STAGING_LIB_DIR) -Wl,-rpath=$(HOST_STAGING_LIB_DIR)" \
		LIBS="-lgmodule-2.0 -lglib-2.0 -lz -lffi -lresolv -ldl" \
    		PKG_CONFIG_PATH="$(HOST_STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(HOST_STAGING_LIB_DIR)/pkgconfig" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.7 \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX) \
		--disable-nls \
		--enable-shared \
		--enable-static \
	)
	$(MAKE) -C $(@D) install
	rm -f $(HOST_STAGING_LIB_DIR)/libgirepository-1.0.so* $(HOST_STAGING_LIB_DIR)/libgirepository-1.0.la
	touch $@

gobject-introspection-host-stage: $(GOBJECT-INTROSPECTION_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gobject-introspection
#
$(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gobject-introspection" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GOBJECT-INTROSPECTION_PRIORITY)" >>$@
	@echo "Section: $(GOBJECT-INTROSPECTION_SECTION)" >>$@
	@echo "Version: $(GOBJECT-INTROSPECTION_VERSION)-$(GOBJECT-INTROSPECTION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GOBJECT-INTROSPECTION_MAINTAINER)" >>$@
	@echo "Source: $(GOBJECT-INTROSPECTION_SITE)/$(GOBJECT-INTROSPECTION_SOURCE)" >>$@
	@echo "Description: $(GOBJECT-INTROSPECTION_DESCRIPTION)" >>$@
	@echo "Depends: $(GOBJECT-INTROSPECTION_DEPENDS)" >>$@
	@echo "Suggests: $(GOBJECT-INTROSPECTION_SUGGESTS)" >>$@
	@echo "Conflicts: $(GOBJECT-INTROSPECTION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/gobject-introspection/...
# Documentation files should be installed in $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/doc/gobject-introspection/...
# Daemon startup scripts should be installed in $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gobject-introspection
#
# You may need to patch your application to make it use these locations.
#
$(GOBJECT-INTROSPECTION_IPK): $(GOBJECT-INTROSPECTION_BUILD_DIR)/.built
	rm -rf $(GOBJECT-INTROSPECTION_IPK_DIR) $(BUILD_DIR)/gobject-introspection_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GOBJECT-INTROSPECTION_BUILD_DIR) DESTDIR=$(GOBJECT-INTROSPECTION_IPK_DIR) install-girepoHEADERS \
		install-libLTLIBRARIES install-pkgconfigDATA install-binSCRIPTS install-binPROGRAMS install-m4DATA \
		install-man1 install-pkgpyexecLTLIBRARIES install-pkgpyexecPYTHON
	find $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/lib -type f -name *.la -exec rm -f {} \;
	-$(STRIP_COMMAND) $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(STRIP_COMMAND) $(addprefix $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/lib/, libgirepository-1.0.so.1.0.0 \
		gobject-introspection/giscanner/_giscanner.so)
	$(MAKE) -C $(GOBJECT-INTROSPECTION_HOST_BUILD_DIR) DESTDIR=$(GOBJECT-INTROSPECTION_IPK_DIR) GIR_DIR=$(TARGET_PREFIX)/share/gir-1.0 \
		install-girDATA
	sed -i -e '0,/^#!/s|^#!.*|#!$(TARGET_PREFIX)/bin/python2.7|' $(addprefix $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/bin/, g-ir-annotation-tool \
							g-ir-doc-tool g-ir-scanner)
#	$(INSTALL) -d $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GOBJECT-INTROSPECTION_SOURCE_DIR)/gobject-introspection.conf $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/gobject-introspection.conf
#	$(INSTALL) -d $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GOBJECT-INTROSPECTION_SOURCE_DIR)/rc.gobject-introspection $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgobject-introspection
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GOBJECT-INTROSPECTION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgobject-introspection
	$(MAKE) $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(GOBJECT-INTROSPECTION_SOURCE_DIR)/postinst $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(GOBJECT-INTROSPECTION_SOURCE_DIR)/prerm $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/postinst $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GOBJECT-INTROSPECTION_CONFFILES) | sed -e 's/ /\n/g' > $(GOBJECT-INTROSPECTION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GOBJECT-INTROSPECTION_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(GOBJECT-INTROSPECTION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gobject-introspection-ipk: $(GOBJECT-INTROSPECTION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gobject-introspection-clean:
	rm -f $(GOBJECT-INTROSPECTION_BUILD_DIR)/.built
	-$(MAKE) -C $(GOBJECT-INTROSPECTION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gobject-introspection-dirclean:
	rm -rf $(BUILD_DIR)/$(GOBJECT-INTROSPECTION_DIR) $(GOBJECT-INTROSPECTION_BUILD_DIR) $(GOBJECT-INTROSPECTION_IPK_DIR) $(GOBJECT-INTROSPECTION_IPK)
#
#
# Some sanity check for the package.
#
gobject-introspection-check: $(GOBJECT-INTROSPECTION_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
