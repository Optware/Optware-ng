###########################################################
#
# dbus-python
#
###########################################################

#
# DBUS-PYTHON_VERSION, DBUS-PYTHON_SITE and DBUS-PYTHON_SOURCE define
# the upstream location of the source code for the package.
# DBUS-PYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# DBUS-PYTHON_UNZIP is the command used to unzip the source.
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
DBUS-PYTHON_VERSION=0.83.0
DBUS-PYTHON_SITE=http://dbus.freedesktop.org/releases/dbus-python
DBUS-PYTHON_SOURCE=dbus-python-$(DBUS-PYTHON_VERSION).tar.gz
DBUS-PYTHON_DIR=dbus-python-$(DBUS-PYTHON_VERSION)
DBUS-PYTHON_UNZIP=zcat
DBUS-PYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DBUS-PYTHON_DESCRIPTION=Python bindings to DBUS
DBUS-PYTHON_SECTION=devel
DBUS-PYTHON_PRIORITY=optional
PY25-DBUS-PYTHON_DEPENDS=dbus, python25
PY26-DBUS-PYTHON_DEPENDS=dbus, python26
DBUS-PYTHON_CONFLICTS=

#
# DBUS-PYTHON_IPK_VERSION should be incremented when the ipk changes.
#
DBUS-PYTHON_IPK_VERSION=1

#
# DBUS-PYTHON_CONFFILES should be a list of user-editable files
#DBUS-PYTHON_CONFFILES=/opt/etc/dbus-python.conf /opt/etc/init.d/SXXdbus-python

#
# DBUS-PYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DBUS-PYTHON_PATCHES=$(DBUS-PYTHON_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DBUS-PYTHON_CPPFLAGS=
DBUS-PYTHON_LDFLAGS=

#
# DBUS-PYTHON_BUILD_DIR is the directory in which the build is done.
# DBUS-PYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DBUS-PYTHON_IPK_DIR is the directory in which the ipk is built.
# DBUS-PYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DBUS-PYTHON_BUILD_DIR=$(BUILD_DIR)/dbus-python
DBUS-PYTHON_SOURCE_DIR=$(SOURCE_DIR)/dbus-python

PY25-DBUS-PYTHON_IPK_DIR=$(BUILD_DIR)/py25-dbus-python-$(DBUS-PYTHON_VERSION)-ipk
PY25-DBUS-PYTHON_IPK=$(BUILD_DIR)/py25-dbus-python_$(DBUS-PYTHON_VERSION)-$(DBUS-PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-DBUS-PYTHON_IPK_DIR=$(BUILD_DIR)/py26-dbus-python-$(DBUS-PYTHON_VERSION)-ipk
PY26-DBUS-PYTHON_IPK=$(BUILD_DIR)/py26-dbus-python_$(DBUS-PYTHON_VERSION)-$(DBUS-PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dbus-python-source dbus-python-unpack dbus-python dbus-python-stage dbus-python-ipk dbus-python-clean dbus-python-dirclean dbus-python-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DBUS-PYTHON_SOURCE):
	$(WGET) -P $(@D) $(DBUS-PYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dbus-python-source: $(DL_DIR)/$(DBUS-PYTHON_SOURCE) $(DBUS-PYTHON_PATCHES)

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
$(DBUS-PYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(DBUS-PYTHON_SOURCE) $(DBUS-PYTHON_PATCHES) make/dbus-python.mk
	$(MAKE) python-stage dbus-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(DBUS-PYTHON_DIR)
	$(DBUS-PYTHON_UNZIP) $(DL_DIR)/$(DBUS-PYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS-PYTHON_PATCHES)"; then \
		cat $(DBUS-PYTHON_PATCHES) | patch -d $(BUILD_DIR)/$(DBUS-PYTHON_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(DBUS-PYTHON_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS-PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS-PYTHON_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/2.5/libtool
	# 2.6
	rm -rf $(BUILD_DIR)/$(DBUS-PYTHON_DIR)
	$(DBUS-PYTHON_UNZIP) $(DL_DIR)/$(DBUS-PYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS-PYTHON_PATCHES)"; then \
		cat $(DBUS-PYTHON_PATCHES) | patch -d $(BUILD_DIR)/$(DBUS-PYTHON_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(DBUS-PYTHON_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS-PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS-PYTHON_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.6 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/2.6/libtool
	touch $@

dbus-python-unpack: $(DBUS-PYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DBUS-PYTHON_BUILD_DIR)/.built: $(DBUS-PYTHON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/2.5
	$(MAKE) -C $(@D)/2.6
	touch $@

#
# This is the build convenience target.
#
dbus-python: $(DBUS-PYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DBUS-PYTHON_BUILD_DIR)/.staged: $(DBUS-PYTHON_BUILD_DIR)/.built
#	rm -f $@
#	#$(MAKE) -C $(DBUS-PYTHON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#dbus-python-stage: $(DBUS-PYTHON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dbus-python
#
$(PY25-DBUS-PYTHON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-dbus-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS-PYTHON_PRIORITY)" >>$@
	@echo "Section: $(DBUS-PYTHON_SECTION)" >>$@
	@echo "Version: $(DBUS-PYTHON_VERSION)-$(DBUS-PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS-PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(DBUS-PYTHON_SITE)/$(DBUS-PYTHON_SOURCE)" >>$@
	@echo "Description: $(DBUS-PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-DBUS-PYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(DBUS-PYTHON_CONFLICTS)" >>$@

$(PY26-DBUS-PYTHON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-dbus-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS-PYTHON_PRIORITY)" >>$@
	@echo "Section: $(DBUS-PYTHON_SECTION)" >>$@
	@echo "Version: $(DBUS-PYTHON_VERSION)-$(DBUS-PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS-PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(DBUS-PYTHON_SITE)/$(DBUS-PYTHON_SOURCE)" >>$@
	@echo "Description: $(DBUS-PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-DBUS-PYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(DBUS-PYTHON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DBUS-PYTHON_IPK_DIR)/opt/sbin or $(DBUS-PYTHON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DBUS-PYTHON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DBUS-PYTHON_IPK_DIR)/opt/etc/dbus-python/...
# Documentation files should be installed in $(DBUS-PYTHON_IPK_DIR)/opt/doc/dbus-python/...
# Daemon startup scripts should be installed in $(DBUS-PYTHON_IPK_DIR)/opt/etc/init.d/S??dbus-python
#
# You may need to patch your application to make it use these locations.
#
$(PY25-DBUS-PYTHON_IPK): $(DBUS-PYTHON_BUILD_DIR)/.built
	rm -rf $(PY25-DBUS-PYTHON_IPK_DIR) $(BUILD_DIR)/py25-dbus-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS-PYTHON_BUILD_DIR)/2.5 DESTDIR=$(PY25-DBUS-PYTHON_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(PY25-DBUS-PYTHON_IPK_DIR)/opt/lib/python2.5/site-packages/dbus-python/*.so
	$(MAKE) $(PY25-DBUS-PYTHON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-DBUS-PYTHON_IPK_DIR)

$(PY26-DBUS-PYTHON_IPK): $(DBUS-PYTHON_BUILD_DIR)/.built
	rm -rf $(PY26-DBUS-PYTHON_IPK_DIR) $(BUILD_DIR)/py26-dbus-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS-PYTHON_BUILD_DIR)/2.6 DESTDIR=$(PY26-DBUS-PYTHON_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(PY26-DBUS-PYTHON_IPK_DIR)/opt/lib/python2.6/site-packages/dbus-python/*.so
	$(MAKE) $(PY26-DBUS-PYTHON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-DBUS-PYTHON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dbus-python-ipk: $(PY25-DBUS-PYTHON_IPK) $(PY26-DBUS-PYTHON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dbus-python-clean:
	-$(MAKE) -C $(DBUS-PYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dbus-python-dirclean:
	rm -rf $(BUILD_DIR)/$(DBUS-PYTHON_DIR) $(DBUS-PYTHON_BUILD_DIR)
	rm -rf $(PY25-DBUS-PYTHON_IPK_DIR) $(PY25-DBUS-PYTHON_IPK)
	rm -rf $(PY26-DBUS-PYTHON_IPK_DIR) $(PY26-DBUS-PYTHON_IPK)

#
# Some sanity check for the package.
#
dbus-python-check: $(PY25-DBUS-PYTHON_IPK) $(PY26-DBUS-PYTHON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
