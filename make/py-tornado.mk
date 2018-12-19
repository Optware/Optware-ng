###########################################################
#
# py-tornado
#
###########################################################

#
# PY-TORNADO_VERSION, PY-TORNADO_SITE and PY-TORNADO_SOURCE define
# the upstream location of the source code for the package.
# PY-TORNADO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TORNADO_UNZIP is the command used to unzip the source.
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
PY-TORNADO_VERSION=4.3
PY-TORNADO_SITE=https://pypi.python.org/packages/source/t/tornado
PY-TORNADO_SOURCE=tornado-$(PY-TORNADO_VERSION).tar.gz
PY-TORNADO_DIR=tornado-$(PY-TORNADO_VERSION)
PY-TORNADO_UNZIP=zcat
PY-TORNADO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TORNADO_DESCRIPTION=Tornado is a Python web framework and asynchronous networking library, originally developed at FriendFeed.
PY-TORNADO_SECTION=misc
PY-TORNADO_PRIORITY=optional
PY26-TORNADO_DEPENDS=python26, py26-curl
PY27-TORNADO_DEPENDS=python27, py27-curl
PY3-TORNADO_DEPENDS=python3, py3-curl
PY-TORNADO_CONFLICTS=

#
# PY-TORNADO_IPK_VERSION should be incremented when the ipk changes.
#
PY-TORNADO_IPK_VERSION=4

#
# PY-TORNADO_CONFFILES should be a list of user-editable files
#PY-TORNADO_CONFFILES=$(TARGET_PREFIX)/etc/py-tornado.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-tornado

#
# PY-TORNADO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TORNADO_PATCHES=$(PY-TORNADO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TORNADO_CPPFLAGS=
PY-TORNADO_LDFLAGS=

#
# PY-TORNADO_BUILD_DIR is the directory in which the build is done.
# PY-TORNADO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TORNADO_IPK_DIR is the directory in which the ipk is built.
# PY-TORNADO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TORNADO_BUILD_DIR=$(BUILD_DIR)/py-tornado
PY-TORNADO_SOURCE_DIR=$(SOURCE_DIR)/py-tornado

PY26-TORNADO_IPK_DIR=$(BUILD_DIR)/py26-tornado-$(PY-TORNADO_VERSION)-ipk
PY26-TORNADO_IPK=$(BUILD_DIR)/py26-tornado_$(PY-TORNADO_VERSION)-$(PY-TORNADO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-TORNADO_IPK_DIR=$(BUILD_DIR)/py27-tornado-$(PY-TORNADO_VERSION)-ipk
PY27-TORNADO_IPK=$(BUILD_DIR)/py27-tornado_$(PY-TORNADO_VERSION)-$(PY-TORNADO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-TORNADO_IPK_DIR=$(BUILD_DIR)/py3-tornado-$(PY-TORNADO_VERSION)-ipk
PY3-TORNADO_IPK=$(BUILD_DIR)/py3-tornado_$(PY-TORNADO_VERSION)-$(PY-TORNADO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-tornado-source py-tornado-unpack py-tornado py-tornado-stage py-tornado-ipk py-tornado-clean py-tornado-dirclean py-tornado-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TORNADO_SOURCE):
	$(WGET) -P $(@D) $(PY-TORNADO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-tornado-source: $(DL_DIR)/$(PY-TORNADO_SOURCE) $(PY-TORNADO_PATCHES)

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
$(PY-TORNADO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TORNADO_SOURCE) $(PY-TORNADO_PATCHES) make/py-tornado.mk
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-TORNADO_DIR) $(BUILD_DIR)/$(PY-TORNADO_DIR) $(@D)
	mkdir -p $(PY-TORNADO_BUILD_DIR)
	$(PY-TORNADO_UNZIP) $(DL_DIR)/$(PY-TORNADO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TORNADO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-TORNADO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TORNADO_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=$(TARGET_PREFIX)/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6") >> setup.cfg; \
	)
	$(PY-TORNADO_UNZIP) $(DL_DIR)/$(PY-TORNADO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TORNADO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-TORNADO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TORNADO_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=$(TARGET_PREFIX)/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7") >> setup.cfg; \
	)
	$(PY-TORNADO_UNZIP) $(DL_DIR)/$(PY-TORNADO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TORNADO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-TORNADO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TORNADO_DIR) $(@D)/3
	(cd $(@D)/3; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=$(TARGET_PREFIX)/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)") >> setup.cfg; \
	)
	touch $@

py-tornado-unpack: $(PY-TORNADO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TORNADO_BUILD_DIR)/.built: $(PY-TORNADO_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-tornado: $(PY-TORNADO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-TORNADO_BUILD_DIR)/.staged: $(PY-TORNADO_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-TORNADO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-tornado-stage: $(PY-TORNADO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-tornado
#
$(PY26-TORNADO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-tornado" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TORNADO_PRIORITY)" >>$@
	@echo "Section: $(PY-TORNADO_SECTION)" >>$@
	@echo "Version: $(PY-TORNADO_VERSION)-$(PY-TORNADO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TORNADO_MAINTAINER)" >>$@
	@echo "Source: $(PY-TORNADO_SITE)/$(PY-TORNADO_SOURCE)" >>$@
	@echo "Description: $(PY-TORNADO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-TORNADO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TORNADO_CONFLICTS)" >>$@

$(PY27-TORNADO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-tornado" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TORNADO_PRIORITY)" >>$@
	@echo "Section: $(PY-TORNADO_SECTION)" >>$@
	@echo "Version: $(PY-TORNADO_VERSION)-$(PY-TORNADO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TORNADO_MAINTAINER)" >>$@
	@echo "Source: $(PY-TORNADO_SITE)/$(PY-TORNADO_SOURCE)" >>$@
	@echo "Description: $(PY-TORNADO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-TORNADO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TORNADO_CONFLICTS)" >>$@

$(PY3-TORNADO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-tornado" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TORNADO_PRIORITY)" >>$@
	@echo "Section: $(PY-TORNADO_SECTION)" >>$@
	@echo "Version: $(PY-TORNADO_VERSION)-$(PY-TORNADO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TORNADO_MAINTAINER)" >>$@
	@echo "Source: $(PY-TORNADO_SITE)/$(PY-TORNADO_SOURCE)" >>$@
	@echo "Description: $(PY-TORNADO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-TORNADO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TORNADO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TORNADO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-TORNADO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TORNADO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-TORNADO_IPK_DIR)$(TARGET_PREFIX)/etc/py-tornado/...
# Documentation files should be installed in $(PY-TORNADO_IPK_DIR)$(TARGET_PREFIX)/doc/py-tornado/...
# Daemon startup scripts should be installed in $(PY-TORNADO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-tornado
#
# You may need to patch your application to make it use these locations.
#
$(PY26-TORNADO_IPK): $(PY-TORNADO_BUILD_DIR)/.built
	rm -rf $(PY26-TORNADO_IPK_DIR) $(BUILD_DIR)/py26-tornado_*_$(TARGET_ARCH).ipk
	(cd $(PY-TORNADO_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-TORNADO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY26-TORNADO_IPK_DIR)$(TARGET_PREFIX)/lib/ -name '*.so'`
	$(MAKE) $(PY26-TORNADO_IPK_DIR)/CONTROL/control
	echo $(PY-TORNADO_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-TORNADO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-TORNADO_IPK_DIR)

$(PY27-TORNADO_IPK): $(PY-TORNADO_BUILD_DIR)/.built
	rm -rf $(PY27-TORNADO_IPK_DIR) $(BUILD_DIR)/py27-tornado_*_$(TARGET_ARCH).ipk
	(cd $(PY-TORNADO_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-TORNADO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY27-TORNADO_IPK_DIR)$(TARGET_PREFIX)/lib/ -name '*.so'`
	$(MAKE) $(PY27-TORNADO_IPK_DIR)/CONTROL/control
	echo $(PY-TORNADO_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-TORNADO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-TORNADO_IPK_DIR)

$(PY3-TORNADO_IPK): $(PY-TORNADO_BUILD_DIR)/.built
	rm -rf $(PY3-TORNADO_IPK_DIR) $(BUILD_DIR)/py3-tornado_*_$(TARGET_ARCH).ipk
	(cd $(PY-TORNADO_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-TORNADO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY3-TORNADO_IPK_DIR)$(TARGET_PREFIX)/lib/ -name '*.so'`
	$(MAKE) $(PY3-TORNADO_IPK_DIR)/CONTROL/control
	echo $(PY-TORNADO_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-TORNADO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-TORNADO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-tornado-ipk: $(PY26-TORNADO_IPK) $(PY27-TORNADO_IPK) $(PY3-TORNADO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-tornado-clean:
	-$(MAKE) -C $(PY-TORNADO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-tornado-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TORNADO_DIR) $(PY-TORNADO_BUILD_DIR) \
	$(PY26-TORNADO_IPK_DIR) $(PY26-TORNADO_IPK) \
	$(PY27-TORNADO_IPK_DIR) $(PY27-TORNADO_IPK) \
	$(PY3-TORNADO_IPK_DIR) $(PY3-TORNADO_IPK) \

#
# Some sanity check for the package.
#
py-tornado-check: $(PY26-TORNADO_IPK) $(PY27-TORNADO_IPK) $(PY3-TORNADO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
