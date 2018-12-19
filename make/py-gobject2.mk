###########################################################
#
# py-gobject2
#
###########################################################

# You must replace "py-gobject2" and "PY-GOBJECT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PY-GOBJECT2_VERSION, PY-GOBJECT2_SITE and PY-GOBJECT2_SOURCE define
# the upstream location of the source code for the package.
# PY-GOBJECT2_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GOBJECT2_UNZIP is the command used to unzip the source.
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
PY-GOBJECT2_SITE=http://ftp.gnome.org/pub/gnome/sources/pygobject/2.28
PY-GOBJECT2_VERSION=2.28.6
PY-GOBJECT2_SOURCE=pygobject-$(PY-GOBJECT2_VERSION).tar.xz
PY-GOBJECT2_DIR=pygobject-$(PY-GOBJECT2_VERSION)
PY-GOBJECT2_UNZIP=xzcat
PY-GOBJECT2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GOBJECT2_DESCRIPTION=PyGObject2 provides deprecated Python bindings to the GObject class from GLib.
PY-GOBJECT2_DEV_DESCRIPTION=PyGObject2 development files
PY-GOBJECT2_SECTION=misc
PY-GOBJECT2_PRIORITY=optional
PY26-GOBJECT2_DEPENDS=python26, py26-cairo, glib, libffi
PY27-GOBJECT2_DEPENDS=python27, py27-cairo, glib, libffi
PY3-GOBJECT2_DEPENDS=python3, py3-cairo, glib, libffi
PY26-GOBJECT2_SUGGESTS=
PY26-GOBJECT2_CONFLICTS=
PY27-GOBJECT2_SUGGESTS=
PY27-GOBJECT2_CONFLICTS=
PY3-GOBJECT2_SUGGESTS=
PY3-GOBJECT2_CONFLICTS=
PY-GOBJECT2_DEV_SUGGESTS=py26-gobject2, py27-gobject2, py3-gobject2
PY-GOBJECT2_DEV_CONFLICTS=

#
# PY-GOBJECT2_IPK_VERSION should be incremented when the ipk changes.
#
PY-GOBJECT2_IPK_VERSION=6

#
# PY-GOBJECT2_CONFFILES should be a list of user-editable files
#PY-GOBJECT2_CONFFILES=$(TARGET_PREFIX)/etc/py-gobject2.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-gobject2

#
# PY-GOBJECT2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-GOBJECT2_PATCHES=$(PY-GOBJECT2_SOURCE_DIR)/pygobject-2.28.6-fixes.patch \
$(PY-GOBJECT2_SOURCE_DIR)/py-compile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GOBJECT2_CPPFLAGS=
PY-GOBJECT2_LDFLAGS=

#
# PY-GOBJECT2_BUILD_DIR is the directory in which the build is done.
# PY-GOBJECT2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GOBJECT2_IPK_DIR is the directory in which the ipk is built.
# PY-GOBJECT2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GOBJECT2_BUILD_DIR=$(BUILD_DIR)/py-gobject2
PY-GOBJECT2_SOURCE_DIR=$(SOURCE_DIR)/py-gobject2

PY26-GOBJECT2_IPK_DIR=$(BUILD_DIR)/py26-gobject2-$(PY-GOBJECT2_VERSION)-ipk
PY26-GOBJECT2_IPK=$(BUILD_DIR)/py26-gobject2_$(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-GOBJECT2_IPK_DIR=$(BUILD_DIR)/py27-gobject2-$(PY-GOBJECT2_VERSION)-ipk
PY27-GOBJECT2_IPK=$(BUILD_DIR)/py27-gobject2_$(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-GOBJECT2_IPK_DIR=$(BUILD_DIR)/py3-gobject2-$(PY-GOBJECT2_VERSION)-ipk
PY3-GOBJECT2_IPK=$(BUILD_DIR)/py3-gobject2_$(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-GOBJECT2_DEV_IPK_DIR=$(BUILD_DIR)/py-gobject2-dev-$(PY-GOBJECT2_VERSION)-ipk
PY-GOBJECT2_DEV_IPK=$(BUILD_DIR)/py-gobject2-dev_$(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-gobject2-source py-gobject2-unpack py-gobject2 py-gobject2-stage py-gobject2-ipk py-gobject2-clean py-gobject2-dirclean py-gobject2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GOBJECT2_SOURCE):
	$(WGET) -P $(@D) $(PY-GOBJECT2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-gobject2-source: $(DL_DIR)/$(PY-GOBJECT2_SOURCE) $(PY-GOBJECT2_PATCHES)

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
$(PY-GOBJECT2_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GOBJECT2_SOURCE) $(PY-GOBJECT2_PATCHES) make/py-gobject2.mk
	$(MAKE) cairo-stage glib-stage libffi-stage python26-stage python27-stage python3-stage \
		python26-host-stage python27-host-stage python3-host-stage \
		py-cairo-stage
	rm -rf $(BUILD_DIR)/$(PY-GOBJECT2_DIR) $(@D)
	$(INSTALL) -d $(@D)
	$(PY-GOBJECT2_UNZIP) $(DL_DIR)/$(PY-GOBJECT2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GOBJECT2_PATCHES)" ; \
		then cat $(PY-GOBJECT2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-GOBJECT2_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-GOBJECT2_DIR) $(@D)/2.6
	$(PY-GOBJECT2_UNZIP) $(DL_DIR)/$(PY-GOBJECT2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GOBJECT2_PATCHES)" ; \
		then cat $(PY-GOBJECT2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-GOBJECT2_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-GOBJECT2_DIR) $(@D)/2.7
	$(PY-GOBJECT2_UNZIP) $(DL_DIR)/$(PY-GOBJECT2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GOBJECT2_PATCHES)" ; \
		then cat $(PY-GOBJECT2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-GOBJECT2_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-GOBJECT2_DIR) $(@D)/3
	$(AUTORECONF1.10) -vif $(@D)/2.6
	(cd $(@D)/2.6; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python2.6 $(PY-GOBJECT2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-GOBJECT2_LDFLAGS)" \
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
		--with-ffi \
	)
	$(PATCH_LIBTOOL) $(@D)/2.6/libtool
	$(AUTORECONF1.10) -vif $(@D)/2.7
	(cd $(@D)/2.7; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python2.7 $(PY-GOBJECT2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-GOBJECT2_LDFLAGS)" \
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
		--with-ffi \
	)
	$(PATCH_LIBTOOL) $(@D)/2.7/libtool
	mv -f $(@D)/3/py-compile $(@D)/3/py3-compile
	$(AUTORECONF1.10) -vif $(@D)/3
	(cd $(@D)/3; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m $(PY-GOBJECT2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-GOBJECT2_LDFLAGS)" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) \
		am_cv_python_pythondir=$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages \
		am_cv_python_pyexecdir=$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages \
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
		--with-ffi \
	)
	$(PATCH_LIBTOOL) $(@D)/3/libtool
	mv -f $(@D)/3/py3-compile $(@D)/3/py-compile
	touch $@

py-gobject2-unpack: $(PY-GOBJECT2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GOBJECT2_BUILD_DIR)/.built: $(PY-GOBJECT2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/2.6 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.6"
	$(MAKE) -C $(@D)/2.7 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.7"
	$(MAKE) -C $(@D)/3 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"
	touch $@

#
# This is the build convenience target.
#
py-gobject2: $(PY-GOBJECT2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GOBJECT2_BUILD_DIR)/.staged: $(PY-GOBJECT2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/2.6 DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(@D)/2.7 DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(@D)/3 DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' -e 's|=$(TARGET_PREFIX)/|=$(STAGING_PREFIX)/|' \
		$(STAGING_LIB_DIR)/pkgconfig/pygobject-2.0.pc
	touch $@

py-gobject2-stage: $(PY-GOBJECT2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-gobject2
#
$(PY26-GOBJECT2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-gobject2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GOBJECT2_PRIORITY)" >>$@
	@echo "Section: $(PY-GOBJECT2_SECTION)" >>$@
	@echo "Version: $(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GOBJECT2_MAINTAINER)" >>$@
	@echo "Source: $(PY-GOBJECT2_SITE)/$(PY-GOBJECT2_SOURCE)" >>$@
	@echo "Description: $(PY-GOBJECT2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-GOBJECT2_DEPENDS)" >>$@
	@echo "Suggests: $(PY26-GOBJECT2_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY26-GOBJECT2_CONFLICTS)" >>$@

$(PY27-GOBJECT2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-gobject2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GOBJECT2_PRIORITY)" >>$@
	@echo "Section: $(PY-GOBJECT2_SECTION)" >>$@
	@echo "Version: $(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GOBJECT2_MAINTAINER)" >>$@
	@echo "Source: $(PY-GOBJECT2_SITE)/$(PY-GOBJECT2_SOURCE)" >>$@
	@echo "Description: $(PY-GOBJECT2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-GOBJECT2_DEPENDS)" >>$@
	@echo "Suggests: $(PY27-GOBJECT2_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY27-GOBJECT2_CONFLICTS)" >>$@

$(PY3-GOBJECT2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-gobject2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GOBJECT2_PRIORITY)" >>$@
	@echo "Section: $(PY-GOBJECT2_SECTION)" >>$@
	@echo "Version: $(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GOBJECT2_MAINTAINER)" >>$@
	@echo "Source: $(PY-GOBJECT2_SITE)/$(PY-GOBJECT2_SOURCE)" >>$@
	@echo "Description: $(PY-GOBJECT2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-GOBJECT2_DEPENDS)" >>$@
	@echo "Suggests: $(PY3-GOBJECT2_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY3-GOBJECT2_CONFLICTS)" >>$@

$(PY-GOBJECT2_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py-gobject2-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GOBJECT2_PRIORITY)" >>$@
	@echo "Section: $(PY-GOBJECT2_SECTION)" >>$@
	@echo "Version: $(PY-GOBJECT2_VERSION)-$(PY-GOBJECT2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GOBJECT2_MAINTAINER)" >>$@
	@echo "Source: $(PY-GOBJECT2_SITE)/$(PY-GOBJECT2_SOURCE)" >>$@
	@echo "Description: $(PY-GOBJECT2_DEV_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(PY-GOBJECT2_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-GOBJECT2_DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/etc/py-gobject2/...
# Documentation files should be installed in $(PY-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/doc/py-gobject2/...
# Daemon startup scripts should be installed in $(PY-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-gobject2
#
# You may need to patch your application to make it use these locations.
#
$(PY26-GOBJECT2_IPK) $(PY-GOBJECT2_DEV_IPK): $(PY-GOBJECT2_BUILD_DIR)/.built
	rm -rf $(PY26-GOBJECT2_IPK_DIR) $(BUILD_DIR)/py26-gobject2_*_$(TARGET_ARCH).ipk \
		$(PY-GOBJECT2_DEV_IPK_DIR) $(BUILD_DIR)/py-gobject2-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-GOBJECT2_BUILD_DIR)/2.6 DESTDIR=$(PY26-GOBJECT2_IPK_DIR) install-strip
	$(INSTALL) -d $(PY-GOBJECT2_DEV_IPK_DIR)$(TARGET_PREFIX)/lib $(PY-GOBJECT2_DEV_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(PY-GOBJECT2_SOURCE_DIR)/pygobject-codegen-2.0 $(PY-GOBJECT2_DEV_IPK_DIR)$(TARGET_PREFIX)/bin/
	rm -rf $(PY26-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/bin
	mv -f $(PY26-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/include $(PY-GOBJECT2_DEV_IPK_DIR)$(TARGET_PREFIX)/
	mv -f $(PY26-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/share $(PY-GOBJECT2_DEV_IPK_DIR)$(TARGET_PREFIX)/
	mv -f $(PY26-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig $(PY-GOBJECT2_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(MAKE) $(PY26-GOBJECT2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-GOBJECT2_IPK_DIR)
	$(MAKE) $(PY-GOBJECT2_DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-GOBJECT2_DEV_IPK_DIR)

$(PY27-GOBJECT2_IPK): $(PY-GOBJECT2_BUILD_DIR)/.built
	rm -rf $(PY27-GOBJECT2_IPK_DIR) $(BUILD_DIR)/py27-gobject2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-GOBJECT2_BUILD_DIR)/2.7 DESTDIR=$(PY27-GOBJECT2_IPK_DIR) install-strip
	rm -rf $(addprefix $(PY27-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/, include lib/pkgconfig share bin)
	$(MAKE) $(PY27-GOBJECT2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-GOBJECT2_IPK_DIR)

$(PY3-GOBJECT2_IPK): $(PY-GOBJECT2_BUILD_DIR)/.built
	rm -rf $(PY3-GOBJECT2_IPK_DIR) $(BUILD_DIR)/py3-gobject2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-GOBJECT2_BUILD_DIR)/3 DESTDIR=$(PY3-GOBJECT2_IPK_DIR) install-strip
	rm -rf $(addprefix $(PY3-GOBJECT2_IPK_DIR)$(TARGET_PREFIX)/, include lib/pkgconfig share bin)
	$(MAKE) $(PY3-GOBJECT2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-GOBJECT2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-gobject2-ipk: $(PY26-GOBJECT2_IPK) $(PY27-GOBJECT2_IPK) $(PY-GOBJECT2_DEV_IPK) $(PY3-GOBJECT2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-gobject2-clean:
	rm -f $(PY-GOBJECT2_BUILD_DIR)/.built
	-$(MAKE) -C $(PY-GOBJECT2_BUILD_DIR)/2.6 clean
	-$(MAKE) -C $(PY-GOBJECT2_BUILD_DIR)/2.7 clean
	-$(MAKE) -C $(PY-GOBJECT2_BUILD_DIR)/3 clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-gobject2-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GOBJECT2_DIR) $(PY-GOBJECT2_BUILD_DIR) \
	$(PY26-GOBJECT2_IPK_DIR) $(PY27-GOBJECT2_IPK_DIR) $(PY3-GOBJECT2_IPK_DIR) $(PY-GOBJECT2_DEV_IPK_DIR) \
	$(PY26-GOBJECT2_IPK) $(PY27-GOBJECT2_IPK) $(PY3-GOBJECT2_IPK) $(PY-GOBJECT2_DEV_IPK)
#
#
# Some sanity check for the package.
#
py-gobject2-check: $(PY26-GOBJECT2_IPK) $(PY27-GOBJECT2_IPK) $(PY3-GOBJECT2_IPK) $(PY-GOBJECT2_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
