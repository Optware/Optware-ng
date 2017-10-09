###########################################################
#
# py-gtk
#
###########################################################

# You must replace "py-gtk" and "PY-GOBJECT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PY-GTK_VERSION, PY-GTK_SITE and PY-GTK_SOURCE define
# the upstream location of the source code for the package.
# PY-GTK_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GTK_UNZIP is the command used to unzip the source.
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
PY-GTK_SITE=http://ftp.gnome.org/pub/gnome/sources/pygtk/2.24
PY-GTK_VERSION=2.24.0
PY-GTK_SOURCE=pygtk-$(PY-GTK_VERSION).tar.bz2
PY-GTK_DIR=pygtk-$(PY-GTK_VERSION)
PY-GTK_UNZIP=bzcat
PY-GTK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GTK_DESCRIPTION=Python2 bindings for the GTK+2 widget set.
PY-GTK_DEV_DESCRIPTION=PyGTK development files
PY-GTK_SECTION=misc
PY-GTK_PRIORITY=optional
PY26-GTK_DEPENDS=python26, py26-gobject2, gtk2, libglade
PY27-GTK_DEPENDS=python27, py27-gobject2, gtk2, libglade
PY-GTK_DEV_DEPENDS=py-gobject2-dev
PY26-GTK_SUGGESTS=gtk2-print
PY26-GTK_CONFLICTS=
PY27-GTK_SUGGESTS=gtk2-print
PY27-GTK_CONFLICTS=
PY-GTK_DEV_SUGGESTS=py26-gtk, py27-gtk
PY-GTK_DEV_CONFLICTS=

#
# PY-GTK_IPK_VERSION should be incremented when the ipk changes.
#
PY-GTK_IPK_VERSION=2

#
# PY-GTK_CONFFILES should be a list of user-editable files
#PY-GTK_CONFFILES=$(TARGET_PREFIX)/etc/py-gtk.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-gtk

#
# PY-GTK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-GTK_PATCHES=$(PY-GTK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GTK_CPPFLAGS=
PY-GTK_LDFLAGS=

#
# PY-GTK_BUILD_DIR is the directory in which the build is done.
# PY-GTK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GTK_IPK_DIR is the directory in which the ipk is built.
# PY-GTK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GTK_BUILD_DIR=$(BUILD_DIR)/py-gtk
PY-GTK_SOURCE_DIR=$(SOURCE_DIR)/py-gtk

PY26-GTK_IPK_DIR=$(BUILD_DIR)/py26-gtk-$(PY-GTK_VERSION)-ipk
PY26-GTK_IPK=$(BUILD_DIR)/py26-gtk_$(PY-GTK_VERSION)-$(PY-GTK_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-GTK_IPK_DIR=$(BUILD_DIR)/py27-gtk-$(PY-GTK_VERSION)-ipk
PY27-GTK_IPK=$(BUILD_DIR)/py27-gtk_$(PY-GTK_VERSION)-$(PY-GTK_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-GTK_DEV_IPK_DIR=$(BUILD_DIR)/py-gtk-dev-$(PY-GTK_VERSION)-ipk
PY-GTK_DEV_IPK=$(BUILD_DIR)/py-gtk-dev_$(PY-GTK_VERSION)-$(PY-GTK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-gtk-source py-gtk-unpack py-gtk py-gtk-stage py-gtk-ipk py-gtk-clean py-gtk-dirclean py-gtk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GTK_SOURCE):
	$(WGET) -P $(@D) $(PY-GTK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-gtk-source: $(DL_DIR)/$(PY-GTK_SOURCE) $(PY-GTK_PATCHES)

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
$(PY-GTK_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GTK_SOURCE) $(PY-GTK_PATCHES) make/py-gtk.mk
	$(MAKE) gtk2-stage libglade-stage python26-stage python27-stage \
		python26-host-stage python27-host-stage \
		py-gobject2-stage
	rm -rf $(BUILD_DIR)/$(PY-GTK_DIR) $(@D)
	$(INSTALL) -d $(@D)
	$(PY-GTK_UNZIP) $(DL_DIR)/$(PY-GTK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GTK_PATCHES)" ; \
		then cat $(PY-GTK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-GTK_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-GTK_DIR) $(@D)/2.6
	$(PY-GTK_UNZIP) $(DL_DIR)/$(PY-GTK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GTK_PATCHES)" ; \
		then cat $(PY-GTK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-GTK_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-GTK_DIR) $(@D)/2.7
	(cd $(@D)/2.6; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python2.6 $(PY-GTK_CPPFLAGS)" \
		LDFLAGS="$(PY-GTK_LDFLAGS) $(STAGING_LDFLAGS)" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.6 \
		am_cv_python_pythondir=$(TARGET_PREFIX)/lib/python2.6/site-packages \
		am_cv_python_pyexecdir=$(TARGET_PREFIX)/lib/python2.6/site-packages \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-introspection \
		--with-glade \
		--disable-glibtest \
		--disable-docs \
	)
	$(PATCH_LIBTOOL) $(@D)/2.6/libtool
	(cd $(@D)/2.7; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python2.7 $(PY-GTK_CPPFLAGS)" \
		LDFLAGS="$(PY-GTK_LDFLAGS) $(STAGING_LDFLAGS)" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.7 \
		am_cv_python_pythondir=$(TARGET_PREFIX)/lib/python2.7/site-packages \
		am_cv_python_pyexecdir=$(TARGET_PREFIX)/lib/python2.7/site-packages \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-introspection \
		--with-glade \
		--disable-glibtest \
		--disable-docs \
	)
	$(PATCH_LIBTOOL) $(@D)/2.7/libtool
	touch $@

py-gtk-unpack: $(PY-GTK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GTK_BUILD_DIR)/.built: $(PY-GTK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/2.6 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.6"
	$(MAKE) -C $(@D)/2.7 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.7"
	touch $@

#
# This is the build convenience target.
#
py-gtk: $(PY-GTK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GTK_BUILD_DIR)/.staged: $(PY-GTK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/2.6 DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(@D)/2.7 DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/pygtk-2.0.pc
	touch $@

py-gtk-stage: $(PY-GTK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-gtk
#
$(PY26-GTK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-gtk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GTK_PRIORITY)" >>$@
	@echo "Section: $(PY-GTK_SECTION)" >>$@
	@echo "Version: $(PY-GTK_VERSION)-$(PY-GTK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GTK_MAINTAINER)" >>$@
	@echo "Source: $(PY-GTK_SITE)/$(PY-GTK_SOURCE)" >>$@
	@echo "Description: $(PY-GTK_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-GTK_DEPENDS)" >>$@
	@echo "Suggests: $(PY26-GTK_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY26-GTK_CONFLICTS)" >>$@

$(PY27-GTK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-gtk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GTK_PRIORITY)" >>$@
	@echo "Section: $(PY-GTK_SECTION)" >>$@
	@echo "Version: $(PY-GTK_VERSION)-$(PY-GTK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GTK_MAINTAINER)" >>$@
	@echo "Source: $(PY-GTK_SITE)/$(PY-GTK_SOURCE)" >>$@
	@echo "Description: $(PY-GTK_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-GTK_DEPENDS)" >>$@
	@echo "Suggests: $(PY27-GTK_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY27-GTK_CONFLICTS)" >>$@

$(PY-GTK_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py-gtk-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GTK_PRIORITY)" >>$@
	@echo "Section: $(PY-GTK_SECTION)" >>$@
	@echo "Version: $(PY-GTK_VERSION)-$(PY-GTK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GTK_MAINTAINER)" >>$@
	@echo "Source: $(PY-GTK_SITE)/$(PY-GTK_SOURCE)" >>$@
	@echo "Description: $(PY-GTK_DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-GTK_DEV_DEPENDS)" >>$@
	@echo "Suggests: $(PY-GTK_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-GTK_DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GTK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-GTK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GTK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-GTK_IPK_DIR)$(TARGET_PREFIX)/etc/py-gtk/...
# Documentation files should be installed in $(PY-GTK_IPK_DIR)$(TARGET_PREFIX)/doc/py-gtk/...
# Daemon startup scripts should be installed in $(PY-GTK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-gtk
#
# You may need to patch your application to make it use these locations.
#
$(PY26-GTK_IPK) $(PY-GTK_DEV_IPK): $(PY-GTK_BUILD_DIR)/.built
	rm -rf $(PY26-GTK_IPK_DIR) $(BUILD_DIR)/py26-gtk_*_$(TARGET_ARCH).ipk \
		$(PY-GTK_DEV_IPK_DIR) $(BUILD_DIR)/py-gtk-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-GTK_BUILD_DIR)/2.6 DESTDIR=$(PY26-GTK_IPK_DIR) install-strip
	$(INSTALL) -d $(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(PY26-GTK_IPK_DIR)$(TARGET_PREFIX)/bin $(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/
	rm -f $(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/bin/pygtk-demo
	$(INSTALL) -m 755 $(PY-GTK_SOURCE_DIR)/pygtk-demo $(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/bin/pygtk-demo
	mv -f $(PY26-GTK_IPK_DIR)$(TARGET_PREFIX)/include $(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/
	mv -f $(PY26-GTK_IPK_DIR)$(TARGET_PREFIX)/share $(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/
	mv -f $(PY26-GTK_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig $(PY26-GTK_IPK_DIR)$(TARGET_PREFIX)/lib/pygtk \
							$(PY-GTK_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(MAKE) $(PY26-GTK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-GTK_IPK_DIR)
	$(MAKE) $(PY-GTK_DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-GTK_DEV_IPK_DIR)

$(PY27-GTK_IPK): $(PY-GTK_BUILD_DIR)/.built
	rm -rf $(PY27-GTK_IPK_DIR) $(BUILD_DIR)/py27-gtk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-GTK_BUILD_DIR)/2.7 DESTDIR=$(PY27-GTK_IPK_DIR) install-strip
	rm -rf $(addprefix $(PY27-GTK_IPK_DIR)$(TARGET_PREFIX)/, include lib/pkgconfig share bin)
	$(MAKE) $(PY27-GTK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-GTK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-gtk-ipk: $(PY26-GTK_IPK) $(PY27-GTK_IPK) $(PY-GTK_DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-gtk-clean:
	rm -f $(PY-GTK_BUILD_DIR)/.built
	-$(MAKE) -C $(PY-GTK_BUILD_DIR)/2.6 clean
	-$(MAKE) -C $(PY-GTK_BUILD_DIR)/2.7 clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-gtk-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GTK_DIR) $(PY-GTK_BUILD_DIR) \
	$(PY26-GTK_IPK_DIR) $(PY27-GTK_IPK_DIR) $(PY-GTK_DEV_IPK_DIR) \
	$(PY26-GTK_IPK) $(PY27-GTK_IPK) $(PY-GTK_DEV_IPK)
#
#
# Some sanity check for the package.
#
py-gtk-check: $(PY26-GTK_IPK) $(PY27-GTK_IPK) $(PY-GTK_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
