###########################################################
#
# dbus-python
#
###########################################################

#
# DBUS_PYTHON_VERSION, DBUS_PYTHON_SITE and DBUS_PYTHON_SOURCE define
# the upstream location of the source code for the package.
# DBUS_PYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# DBUS_PYTHON_UNZIP is the command used to unzip the source.
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
DBUS_PYTHON_VERSION=1.2.6
DBUS_PYTHON_VERSION_OLD=0.84.0
DBUS_PYTHON_SITE=http://dbus.freedesktop.org/releases/dbus-python
DBUS_PYTHON_SOURCE=dbus-python-$(DBUS_PYTHON_VERSION).tar.gz
DBUS_PYTHON_SOURCE_OLD=dbus-python-$(DBUS_PYTHON_VERSION_OLD).tar.gz
DBUS_PYTHON_DIR=dbus-python-$(DBUS_PYTHON_VERSION)
DBUS_PYTHON_DIR_OLD=dbus-python-$(DBUS_PYTHON_VERSION_OLD)
DBUS_PYTHON_UNZIP=zcat
DBUS_PYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DBUS_PYTHON_DESCRIPTION=Python bindings to DBUS
DBUS_PYTHON_SECTION=devel
DBUS_PYTHON_PRIORITY=optional
PY25_DBUS_PYTHON_DEPENDS=dbus-glib, python25
PY26_DBUS_PYTHON_DEPENDS=dbus-glib, python26
PY27_DBUS_PYTHON_DEPENDS=libdbus, python27
PY3_DBUS_PYTHON_DEPENDS=libdbus, python3
DBUS_PYTHON_CONFLICTS=

#
# DBUS_PYTHON_IPK_VERSION should be incremented when the ipk changes.
#
DBUS_PYTHON_IPK_VERSION=2
DBUS_PYTHON_IPK_VERSION_OLD=1

#
# DBUS_PYTHON_CONFFILES should be a list of user-editable files
#DBUS_PYTHON_CONFFILES=$(TARGET_PREFIX)/etc/dbus-python.conf $(TARGET_PREFIX)/etc/init.d/SXXdbus-python

#
# DBUS_PYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DBUS_PYTHON_PATCHES=$(DBUS_PYTHON_SOURCE_DIR)/python_include.patch
#DBUS_PYTHON_PATCHES_OLD=$(DBUS_PYTHON_SOURCE_DIR)/python_include.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DBUS_PYTHON_CPPFLAGS=
DBUS_PYTHON_LDFLAGS=

#
# DBUS_PYTHON_BUILD_DIR is the directory in which the build is done.
# DBUS_PYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DBUS_PYTHON_IPK_DIR is the directory in which the ipk is built.
# DBUS_PYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DBUS_PYTHON_BUILD_DIR=$(BUILD_DIR)/dbus-python
DBUS_PYTHON_SOURCE_DIR=$(SOURCE_DIR)/dbus-python

PY25_DBUS_PYTHON_IPK_DIR=$(BUILD_DIR)/py25-dbus-python-$(DBUS_PYTHON_VERSION_OLD)-ipk
PY25_DBUS_PYTHON_IPK=$(BUILD_DIR)/py25-dbus-python_$(DBUS_PYTHON_VERSION_OLD)-$(DBUS_PYTHON_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY26_DBUS_PYTHON_IPK_DIR=$(BUILD_DIR)/py26-dbus-python-$(DBUS_PYTHON_VERSION_OLD)-ipk
PY26_DBUS_PYTHON_IPK=$(BUILD_DIR)/py26-dbus-python_$(DBUS_PYTHON_VERSION_OLD)-$(DBUS_PYTHON_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY27_DBUS_PYTHON_IPK_DIR=$(BUILD_DIR)/py27-dbus-python-$(DBUS_PYTHON_VERSION)-ipk
PY27_DBUS_PYTHON_IPK=$(BUILD_DIR)/py27-dbus-python_$(DBUS_PYTHON_VERSION)-$(DBUS_PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3_DBUS_PYTHON_IPK_DIR=$(BUILD_DIR)/py3-dbus-python-$(DBUS_PYTHON_VERSION)-ipk
PY3_DBUS_PYTHON_IPK=$(BUILD_DIR)/py3-dbus-python_$(DBUS_PYTHON_VERSION)-$(DBUS_PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dbus-python-source dbus-python-unpack dbus-python dbus-python-stage dbus-python-ipk dbus-python-clean dbus-python-dirclean dbus-python-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DBUS_PYTHON_SOURCE):
	$(WGET) -P $(@D) $(DBUS_PYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(DBUS_PYTHON_SOURCE_OLD):
	$(WGET) -P $(@D) $(DBUS_PYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dbus-python-source: $(DL_DIR)/$(DBUS_PYTHON_SOURCE) \
			$(DL_DIR)/$(DBUS_PYTHON_SOURCE_OLD) \
			$(DBUS_PYTHON_PATCHES)

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
$(DBUS_PYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(DBUS_PYTHON_SOURCE) $(DL_DIR)/$(DBUS_PYTHON_SOURCE_OLD) \
					$(DBUS_PYTHON_PATCHES) make/dbus-python.mk
	$(MAKE) python-stage dbus-stage dbus-glib-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(DBUS_PYTHON_DIR_OLD)
	$(DBUS_PYTHON_UNZIP) $(DL_DIR)/$(DBUS_PYTHON_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS_PYTHON_PATCHES_OLD)"; then \
		cat $(DBUS_PYTHON_PATCHES_OLD) | $(PATCH) -d $(BUILD_DIR)/$(DBUS_PYTHON_DIR_OLD) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(DBUS_PYTHON_DIR_OLD) $(@D)/2.5
#	$(AUTORECONF1.10) -vif $(@D)/2.5
	(cd $(@D)/2.5; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS_PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS_PYTHON_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5 \
                PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.5" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/2.5/libtool
	# 2.6
	rm -rf $(BUILD_DIR)/$(DBUS_PYTHON_DIR_OLD)
	$(DBUS_PYTHON_UNZIP) $(DL_DIR)/$(DBUS_PYTHON_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS_PYTHON_PATCHES_OLD)"; then \
		cat $(DBUS_PYTHON_PATCHES_OLD) | $(PATCH) -d $(BUILD_DIR)/$(DBUS_PYTHON_DIR_OLD) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(DBUS_PYTHON_DIR_OLD) $(@D)/2.6
#	$(AUTORECONF1.10) -vif $(@D)/2.6
	(cd $(@D)/2.6; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS_PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS_PYTHON_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.6 \
                PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.6" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/2.6/libtool
	# 2.7
	rm -rf $(BUILD_DIR)/$(DBUS_PYTHON_DIR)
	$(DBUS_PYTHON_UNZIP) $(DL_DIR)/$(DBUS_PYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS_PYTHON_PATCHES)"; then \
		cat $(DBUS_PYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(DBUS_PYTHON_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(DBUS_PYTHON_DIR) $(@D)/2.7
#	$(AUTORECONF1.10) -vif $(@D)/2.7
	(cd $(@D)/2.7; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS_PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS_PYTHON_LDFLAGS) -lpython2.7" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.7 \
                PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python2.7" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/2.7/libtool
	# 3
	rm -rf $(BUILD_DIR)/$(DBUS_PYTHON_DIR)
	$(DBUS_PYTHON_UNZIP) $(DL_DIR)/$(DBUS_PYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS_PYTHON_PATCHES)"; then \
		cat $(DBUS_PYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(DBUS_PYTHON_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(DBUS_PYTHON_DIR) $(@D)/3
#	$(AUTORECONF1.10) -vif $(@D)/3
	(cd $(@D)/3; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS_PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS_PYTHON_LDFLAGS) -lpython$(PYTHON3_VERSION_MAJOR)m" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_PYTHON=$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) \
                PYTHON_INCLUDES="-I$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/3/libtool
	touch $@

dbus-python-unpack: $(DBUS_PYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DBUS_PYTHON_BUILD_DIR)/.built: $(DBUS_PYTHON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/2.5
	$(MAKE) -C $(@D)/2.6
	$(MAKE) -C $(@D)/2.7
	$(MAKE) -C $(@D)/3
	touch $@

#
# This is the build convenience target.
#
dbus-python: $(DBUS_PYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DBUS_PYTHON_BUILD_DIR)/.staged: $(DBUS_PYTHON_BUILD_DIR)/.built
#	rm -f $@
#	#$(MAKE) -C $(DBUS_PYTHON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#dbus-python-stage: $(DBUS_PYTHON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dbus-python
#
$(PY25_DBUS_PYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-dbus-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS_PYTHON_PRIORITY)" >>$@
	@echo "Section: $(DBUS_PYTHON_SECTION)" >>$@
	@echo "Version: $(DBUS_PYTHON_VERSION_OLD)-$(DBUS_PYTHON_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(DBUS_PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_PYTHON_SITE)/$(DBUS_PYTHON_SOURCE_OLD)" >>$@
	@echo "Description: $(DBUS_PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25_DBUS_PYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(DBUS_PYTHON_CONFLICTS)" >>$@

$(PY26_DBUS_PYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-dbus-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS_PYTHON_PRIORITY)" >>$@
	@echo "Section: $(DBUS_PYTHON_SECTION)" >>$@
	@echo "Version: $(DBUS_PYTHON_VERSION_OLD)-$(DBUS_PYTHON_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(DBUS_PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_PYTHON_SITE)/$(DBUS_PYTHON_SOURCE_OLD)" >>$@
	@echo "Description: $(DBUS_PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26_DBUS_PYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(DBUS_PYTHON_CONFLICTS)" >>$@

$(PY27_DBUS_PYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-dbus-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS_PYTHON_PRIORITY)" >>$@
	@echo "Section: $(DBUS_PYTHON_SECTION)" >>$@
	@echo "Version: $(DBUS_PYTHON_VERSION)-$(DBUS_PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS_PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_PYTHON_SITE)/$(DBUS_PYTHON_SOURCE)" >>$@
	@echo "Description: $(DBUS_PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27_DBUS_PYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(DBUS_PYTHON_CONFLICTS)" >>$@

$(PY3_DBUS_PYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-dbus-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS_PYTHON_PRIORITY)" >>$@
	@echo "Section: $(DBUS_PYTHON_SECTION)" >>$@
	@echo "Version: $(DBUS_PYTHON_VERSION)-$(DBUS_PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS_PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_PYTHON_SITE)/$(DBUS_PYTHON_SOURCE)" >>$@
	@echo "Description: $(DBUS_PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3_DBUS_PYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(DBUS_PYTHON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/etc/dbus-python/...
# Documentation files should be installed in $(DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/doc/dbus-python/...
# Daemon startup scripts should be installed in $(DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??dbus-python
#
# You may need to patch your application to make it use these locations.
#
$(PY25_DBUS_PYTHON_IPK): $(DBUS_PYTHON_BUILD_DIR)/.built
	rm -rf $(PY25_DBUS_PYTHON_IPK_DIR) $(BUILD_DIR)/py25-dbus-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS_PYTHON_BUILD_DIR)/2.5 DESTDIR=$(PY25_DBUS_PYTHON_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(PY25_DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python2.5/site-packages/dbus-python/*.so
	$(MAKE) $(PY25_DBUS_PYTHON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25_DBUS_PYTHON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY25_DBUS_PYTHON_IPK_DIR)

$(PY26_DBUS_PYTHON_IPK): $(DBUS_PYTHON_BUILD_DIR)/.built
	rm -rf $(PY26_DBUS_PYTHON_IPK_DIR) $(BUILD_DIR)/py26-dbus-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS_PYTHON_BUILD_DIR)/2.6 DESTDIR=$(PY26_DBUS_PYTHON_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(PY26_DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/dbus-python/*.so
	$(MAKE) $(PY26_DBUS_PYTHON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26_DBUS_PYTHON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY26_DBUS_PYTHON_IPK_DIR)

$(PY27_DBUS_PYTHON_IPK): $(DBUS_PYTHON_BUILD_DIR)/.built
	rm -rf $(PY27_DBUS_PYTHON_IPK_DIR) $(BUILD_DIR)/py27-dbus-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS_PYTHON_BUILD_DIR)/2.7 DESTDIR=$(PY27_DBUS_PYTHON_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(PY27_DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/dbus-python/*.so
	$(MAKE) $(PY27_DBUS_PYTHON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27_DBUS_PYTHON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY27_DBUS_PYTHON_IPK_DIR)

$(PY3_DBUS_PYTHON_IPK): $(DBUS_PYTHON_BUILD_DIR)/.built
	rm -rf $(PY3_DBUS_PYTHON_IPK_DIR) $(BUILD_DIR)/py3-dbus-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS_PYTHON_BUILD_DIR)/3 DESTDIR=$(PY3_DBUS_PYTHON_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(PY3_DBUS_PYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/dbus-python/*.so
	$(MAKE) $(PY3_DBUS_PYTHON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3_DBUS_PYTHON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY3_DBUS_PYTHON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dbus-python-ipk: $(PY25_DBUS_PYTHON_IPK) $(PY26_DBUS_PYTHON_IPK) $(PY27_DBUS_PYTHON_IPK) $(PY3_DBUS_PYTHON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dbus-python-clean:
	-$(MAKE) -C $(DBUS_PYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dbus-python-dirclean:
	rm -rf $(BUILD_DIR)/$(DBUS_PYTHON_DIR) $(DBUS_PYTHON_BUILD_DIR) \
		 $(PY25_DBUS_PYTHON_IPK_DIR) $(PY25_DBUS_PYTHON_IPK) \
		 $(PY26_DBUS_PYTHON_IPK_DIR) $(PY26_DBUS_PYTHON_IPK) \
		 $(PY27_DBUS_PYTHON_IPK_DIR) $(PY27_DBUS_PYTHON_IPK) \
		 $(PY3_DBUS_PYTHON_IPK_DIR) $(PY3_DBUS_PYTHON_IPK) \

#
# Some sanity check for the package.
#
dbus-python-check: $(PY25_DBUS_PYTHON_IPK) $(PY26_DBUS_PYTHON_IPK) $(PY27_DBUS_PYTHON_IPK) $(PY3_DBUS_PYTHON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
