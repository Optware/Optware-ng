###########################################################
#
# py-cairo
#
###########################################################

# You must replace "py-cairo" and "PY-CAIRO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PY-CAIRO_VERSION, PY-CAIRO_SITE and PY-CAIRO_SOURCE define
# the upstream location of the source code for the package.
# PY-CAIRO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CAIRO_UNZIP is the command used to unzip the source.
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
PY-CAIRO_SITE=http://cairographics.org/releases
PY-CAIRO_SITE3=https://github.com/pygobject/pycairo/releases/download/v$(PY-CAIRO_VERSION3)
PY-CAIRO_VERSION=1.10.0
PY-CAIRO_VERSION3=1.18.0
PY-CAIRO_SOURCE2=py2cairo-$(PY-CAIRO_VERSION).tar.bz2
PY-CAIRO_SOURCE3=pycairo-$(PY-CAIRO_VERSION3).tar.gz
PY-CAIRO_DIR2=py2cairo-$(PY-CAIRO_VERSION)
PY-CAIRO_DIR3=pycairo-$(PY-CAIRO_VERSION3)
PY-CAIRO_UNZIP=bzcat
PY-CAIRO_UNZIP3=zcat
PY-CAIRO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CAIRO_DESCRIPTION=Pycairo is a set of Python bindings for the cairo graphics library.
PY2-CAIRO_DEV_DESCRIPTION=Pycairo python 2.x development files
PY-CAIRO_SECTION=misc
PY-CAIRO_PRIORITY=optional
PY26-CAIRO_DEPENDS=python26, cairo
PY27-CAIRO_DEPENDS=python27, cairo
PY3-CAIRO_DEPENDS=python3, cairo
PY26-CAIRO_SUGGESTS=
PY26-CAIRO_CONFLICTS=
PY27-CAIRO_SUGGESTS=
PY27-CAIRO_CONFLICTS=
PY3-CAIRO_SUGGESTS=
PY3-CAIRO_CONFLICTS=
PY2-CAIRO_DEV_SUGGESTS=py26-cairo, py27-cairo
PY2-CAIRO_DEV_CONFLICTS=

#
# PY-CAIRO_IPK_VERSION should be incremented when the ipk changes.
#
PY-CAIRO_IPK_VERSION=5
PY-CAIRO_IPK_VERSION3=1

#
# PY-CAIRO_CONFFILES should be a list of user-editable files
#PY-CAIRO_CONFFILES=$(TARGET_PREFIX)/etc/py-cairo.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-cairo

#
# PY-CAIRO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CAIRO_PATCHES2=$(PY-CAIRO_SOURCE_DIR)/configure2.patch
#PY-CAIRO_PATCHES3=\
$(PY-CAIRO_SOURCE_DIR)/pycairo-1.10.0-waf_unpack-1.patch
#PY-CAIRO_WAF_PATCHES=\
$(PY-CAIRO_SOURCE_DIR)/pycairo-1.10.0-waf_python_3_4-1.patch \
$(PY-CAIRO_SOURCE_DIR)/pycairo-1.10.0-waf_python_3_5.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CAIRO_CPPFLAGS=
PY-CAIRO_LDFLAGS=

#
# PY-CAIRO_BUILD_DIR is the directory in which the build is done.
# PY-CAIRO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CAIRO_IPK_DIR is the directory in which the ipk is built.
# PY-CAIRO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CAIRO_BUILD_DIR=$(BUILD_DIR)/py-cairo
PY-CAIRO_SOURCE_DIR=$(SOURCE_DIR)/py-cairo

PY26-CAIRO_IPK_DIR=$(BUILD_DIR)/py26-cairo-$(PY-CAIRO_VERSION)-ipk
PY26-CAIRO_IPK=$(BUILD_DIR)/py26-cairo_$(PY-CAIRO_VERSION)-$(PY-CAIRO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CAIRO_IPK_DIR=$(BUILD_DIR)/py27-cairo-$(PY-CAIRO_VERSION)-ipk
PY27-CAIRO_IPK=$(BUILD_DIR)/py27-cairo_$(PY-CAIRO_VERSION)-$(PY-CAIRO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CAIRO_IPK_DIR=$(BUILD_DIR)/py3-cairo-$(PY-CAIRO_VERSION3)-ipk
PY3-CAIRO_IPK=$(BUILD_DIR)/py3-cairo_$(PY-CAIRO_VERSION3)-$(PY-CAIRO_IPK_VERSION3)_$(TARGET_ARCH).ipk

PY2-CAIRO_DEV_IPK_DIR=$(BUILD_DIR)/py2-cairo-dev-$(PY-CAIRO_VERSION)-ipk
PY2-CAIRO_DEV_IPK=$(BUILD_DIR)/py2-cairo-dev_$(PY-CAIRO_VERSION)-$(PY-CAIRO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-cairo-source py-cairo-unpack py-cairo py-cairo-stage py-cairo-ipk py-cairo-clean py-cairo-dirclean py-cairo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CAIRO_SOURCE2):
	$(WGET) -P $(@D) $(PY-CAIRO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-CAIRO_SOURCE3):
	$(WGET) -P $(@D) $(PY-CAIRO_SITE3)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cairo-source: $(DL_DIR)/$(PY-CAIRO_SOURCE2) $(DL_DIR)/$(PY-CAIRO_SOURCE3) $(PY-CAIRO_PATCHES2) $(PY-CAIRO_PATCHES3) $(PY-CAIRO_WAF_PATCHES)

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
$(PY-CAIRO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CAIRO_SOURCE2) $(DL_DIR)/$(PY-CAIRO_SOURCE3) \
		$(PY-CAIRO_WAF_PATCHES)	$(PY-CAIRO_PATCHES2) $(PY-CAIRO_PATCHES3) make/py-cairo.mk
	$(MAKE) cairo-stage python26-stage python27-stage python3-stage \
		python26-host-stage python27-host-stage python3-host-stage
	rm -rf $(BUILD_DIR)/$(PY-CAIRO_DIR2) $(BUILD_DIR)/$(PY-CAIRO_DIR3) $(@D)
	$(INSTALL) -d $(@D)
	$(PY-CAIRO_UNZIP) $(DL_DIR)/$(PY-CAIRO_SOURCE2) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-CAIRO_PATCHES2)" ; \
		then cat $(PY-CAIRO2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-CAIRO_DIR2) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-CAIRO_DIR2) $(@D)/2.6
	$(PY-CAIRO_UNZIP) $(DL_DIR)/$(PY-CAIRO_SOURCE2) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-CAIRO_PATCHES2)" ; \
		then cat $(PY-CAIRO2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-CAIRO_DIR2) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-CAIRO_DIR2) $(@D)/2.7
	$(PY-CAIRO_UNZIP3) $(DL_DIR)/$(PY-CAIRO_SOURCE3) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-CAIRO_PATCHES3)" ; \
		then cat $(PY-CAIRO_PATCHES3) | \
		$(PATCH) -d $(BUILD_DIR)/$(PY-CAIRO_DIR3) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PY-CAIRO_DIR3) $(@D)/3
	touch $(@D)/2.6/ChangeLog
	$(AUTORECONF1.14) -vif $(@D)/2.6
	(cd $(@D)/2.6; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python2.6 $(PY-CAIRO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-CAIRO_LDFLAGS)" \
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
	)
	$(PATCH_LIBTOOL) $(@D)/2.6/libtool
	touch $(@D)/2.7/ChangeLog
	$(AUTORECONF1.14) -vif $(@D)/2.7
	(cd $(@D)/2.7; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/python2.7 $(PY-CAIRO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-CAIRO_LDFLAGS)" \
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
	)
	$(PATCH_LIBTOOL) $(@D)/2.7/libtool
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-cairo-unpack: $(PY-CAIRO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CAIRO_BUILD_DIR)/.built: $(PY-CAIRO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/2.6 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.6"
	$(MAKE) -C $(@D)/2.7 PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.7"
	(cd $(@D)/3; \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-cairo: $(PY-CAIRO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CAIRO_BUILD_DIR)/.staged: $(PY-CAIRO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/2.6 DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(@D)/2.7 DESTDIR=$(STAGING_DIR) install
	(cd $(@D)/3; \
		LDSHARED='$(TARGET_CC) -shared' PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX); \
	)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' -e 's|\(-[IL]\)$(TARGET_PREFIX)/|\1$(STAGING_PREFIX)/|g' \
		$(STAGING_LIB_DIR)/pkgconfig/pycairo.pc $(STAGING_LIB_DIR)/pkgconfig/py3cairo.pc
	touch $@

py-cairo-stage: $(PY-CAIRO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cairo
#
$(PY26-CAIRO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-cairo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CAIRO_PRIORITY)" >>$@
	@echo "Section: $(PY-CAIRO_SECTION)" >>$@
	@echo "Version: $(PY-CAIRO_VERSION)-$(PY-CAIRO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CAIRO_MAINTAINER)" >>$@
	@echo "Source: $(PY-CAIRO_SITE)/$(PY-CAIRO_SOURCE2)" >>$@
	@echo "Description: $(PY-CAIRO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CAIRO_DEPENDS)" >>$@
	@echo "Suggests: $(PY26-CAIRO_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY26-CAIRO_CONFLICTS)" >>$@

$(PY27-CAIRO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-cairo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CAIRO_PRIORITY)" >>$@
	@echo "Section: $(PY-CAIRO_SECTION)" >>$@
	@echo "Version: $(PY-CAIRO_VERSION)-$(PY-CAIRO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CAIRO_MAINTAINER)" >>$@
	@echo "Source: $(PY-CAIRO_SITE)/$(PY-CAIRO_SOURCE2)" >>$@
	@echo "Description: $(PY-CAIRO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CAIRO_DEPENDS)" >>$@
	@echo "Suggests: $(PY27-CAIRO_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY27-CAIRO_CONFLICTS)" >>$@

$(PY3-CAIRO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-cairo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CAIRO_PRIORITY)" >>$@
	@echo "Section: $(PY-CAIRO_SECTION)" >>$@
	@echo "Version: $(PY-CAIRO_VERSION3)-$(PY-CAIRO_IPK_VERSION3)" >>$@
	@echo "Maintainer: $(PY-CAIRO_MAINTAINER)" >>$@
	@echo "Source: $(PY-CAIRO_SITE3)/$(PY-CAIRO_SOURCE3)" >>$@
	@echo "Description: $(PY-CAIRO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CAIRO_DEPENDS)" >>$@
	@echo "Suggests: $(PY3-CAIRO_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY3-CAIRO_CONFLICTS)" >>$@

$(PY2-CAIRO_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py2-cairo-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CAIRO_PRIORITY)" >>$@
	@echo "Section: $(PY-CAIRO_SECTION)" >>$@
	@echo "Version: $(PY-CAIRO_VERSION)-$(PY-CAIRO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CAIRO_MAINTAINER)" >>$@
	@echo "Source: $(PY-CAIRO_SITE)/$(PY-CAIRO_SOURCE2)" >>$@
	@echo "Description: $(PY2-CAIRO_DEV_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(PY2-CAIRO_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY2-CAIRO_DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CAIRO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CAIRO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CAIRO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CAIRO_IPK_DIR)$(TARGET_PREFIX)/etc/py-cairo/...
# Documentation files should be installed in $(PY-CAIRO_IPK_DIR)$(TARGET_PREFIX)/doc/py-cairo/...
# Daemon startup scripts should be installed in $(PY-CAIRO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-cairo
#
# You may need to patch your application to make it use these locations.
#
$(PY26-CAIRO_IPK) $(PY2-CAIRO_DEV_IPK): $(PY-CAIRO_BUILD_DIR)/.built
	rm -rf $(PY26-CAIRO_IPK_DIR) $(BUILD_DIR)/py26-cairo_*_$(TARGET_ARCH).ipk \
		$(PY2-CAIRO_DEV_IPK_DIR) $(BUILD_DIR)/py2-cairo-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-CAIRO_BUILD_DIR)/2.6 DESTDIR=$(PY26-CAIRO_IPK_DIR) install-strip
	$(INSTALL) -d $(PY2-CAIRO_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(PY26-CAIRO_IPK_DIR)$(TARGET_PREFIX)/include $(PY2-CAIRO_DEV_IPK_DIR)$(TARGET_PREFIX)/
	mv -f $(PY26-CAIRO_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig $(PY2-CAIRO_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(MAKE) $(PY26-CAIRO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CAIRO_IPK_DIR)
	$(MAKE) $(PY2-CAIRO_DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY2-CAIRO_DEV_IPK_DIR)

$(PY27-CAIRO_IPK): $(PY-CAIRO_BUILD_DIR)/.built
	rm -rf $(PY27-CAIRO_IPK_DIR) $(BUILD_DIR)/py27-cairo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PY-CAIRO_BUILD_DIR)/2.7 DESTDIR=$(PY27-CAIRO_IPK_DIR) install-strip
	rm -rf $(PY27-CAIRO_IPK_DIR)$(TARGET_PREFIX)/include $(PY27-CAIRO_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	$(MAKE) $(PY27-CAIRO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CAIRO_IPK_DIR)

$(PY3-CAIRO_IPK): $(PY-CAIRO_BUILD_DIR)/.built
	rm -rf $(PY3-CAIRO_IPK_DIR) $(BUILD_DIR)/py3-cairo_*_$(TARGET_ARCH).ipk
	(cd $(PY-CAIRO_BUILD_DIR)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-CAIRO_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY3-CAIRO_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/cairo/*.so
	$(MAKE) $(PY3-CAIRO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CAIRO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cairo-ipk: $(PY26-CAIRO_IPK) $(PY27-CAIRO_IPK) $(PY2-CAIRO_DEV_IPK) $(PY3-CAIRO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cairo-clean:
	rm -f $(PY-CAIRO_BUILD_DIR)/.built
	-$(MAKE) -C $(PY-CAIRO_BUILD_DIR)/2.6 clean
	-$(MAKE) -C $(PY-CAIRO_BUILD_DIR)/2.7 clean
	-(cd $(PY-CAIRO_BUILD_DIR)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) waf clean; \
	)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cairo-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CAIRO_DIR2) $(BUILD_DIR)/$(PY-CAIRO_DIR3) $(PY-CAIRO_BUILD_DIR) \
	$(PY26-CAIRO_IPK_DIR) $(PY27-CAIRO_IPK_DIR) $(PY2-CAIRO_DEV_IPK_DIR) $(PY3-CAIRO_IPK_DIR) \
	$(PY26-CAIRO_IPK) $(PY27-CAIRO_IPK) $(PY2-CAIRO_DEV_IPK) $(PY3-CAIRO_IPK)
#
#
# Some sanity check for the package.
#
py-cairo-check: $(PY26-CAIRO_IPK) $(PY27-CAIRO_IPK) $(PY2-CAIRO_DEV_IPK) $(PY3-CAIRO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
