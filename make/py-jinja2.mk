###########################################################
#
# py-jinja2
#
###########################################################

#
# PY-JINJA2_VERSION, PY-JINJA2_SITE and PY-JINJA2_SOURCE define
# the upstream location of the source code for the package.
# PY-JINJA2_DIR is the directory which is created when the source
# archive is unpacked.
# PY-JINJA2_UNZIP is the command used to unzip the source.
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
PY-JINJA2_VERSION=2.8
PY-JINJA2_SITE=https://pypi.python.org/packages/source/J/Jinja2
PY-JINJA2_SOURCE=Jinja2-$(PY-JINJA2_VERSION).tar.gz
PY-JINJA2_DIR=Jinja2-$(PY-JINJA2_VERSION)
PY-JINJA2_UNZIP=zcat
PY-JINJA2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-JINJA2_DESCRIPTION=Jinja2 is a template engine written in pure Python. It provides a Django inspired non-XML syntax but supports inline expressions and an optional sandboxed environment.
PY-JINJA2_SECTION=misc
PY-JINJA2_PRIORITY=optional
PY26-JINJA2_DEPENDS=python26
PY27-JINJA2_DEPENDS=python27
PY3-JINJA2_DEPENDS=python3
PY-JINJA2_CONFLICTS=

#
# PY-JINJA2_IPK_VERSION should be incremented when the ipk changes.
#
PY-JINJA2_IPK_VERSION=4

#
# PY-JINJA2_CONFFILES should be a list of user-editable files
#PY-JINJA2_CONFFILES=$(TARGET_PREFIX)/etc/py-jinja2.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-jinja2

#
# PY-JINJA2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-JINJA2_PATCHES=$(PY-JINJA2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-JINJA2_CPPFLAGS=
PY-JINJA2_LDFLAGS=

#
# PY-JINJA2_BUILD_DIR is the directory in which the build is done.
# PY-JINJA2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-JINJA2_IPK_DIR is the directory in which the ipk is built.
# PY-JINJA2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-JINJA2_BUILD_DIR=$(BUILD_DIR)/py-jinja2
PY-JINJA2_SOURCE_DIR=$(SOURCE_DIR)/py-jinja2

PY26-JINJA2_IPK_DIR=$(BUILD_DIR)/py26-jinja2-$(PY-JINJA2_VERSION)-ipk
PY26-JINJA2_IPK=$(BUILD_DIR)/py26-jinja2_$(PY-JINJA2_VERSION)-$(PY-JINJA2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-JINJA2_IPK_DIR=$(BUILD_DIR)/py27-jinja2-$(PY-JINJA2_VERSION)-ipk
PY27-JINJA2_IPK=$(BUILD_DIR)/py27-jinja2_$(PY-JINJA2_VERSION)-$(PY-JINJA2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-JINJA2_IPK_DIR=$(BUILD_DIR)/py3-jinja2-$(PY-JINJA2_VERSION)-ipk
PY3-JINJA2_IPK=$(BUILD_DIR)/py3-jinja2_$(PY-JINJA2_VERSION)-$(PY-JINJA2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-jinja2-source py-jinja2-unpack py-jinja2 py-jinja2-stage py-jinja2-ipk py-jinja2-clean py-jinja2-dirclean py-jinja2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-JINJA2_SOURCE):
	$(WGET) -P $(@D) $(PY-JINJA2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-jinja2-source: $(DL_DIR)/$(PY-JINJA2_SOURCE) $(PY-JINJA2_PATCHES)

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
$(PY-JINJA2_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-JINJA2_SOURCE) $(PY-JINJA2_PATCHES) make/py-jinja2.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-JINJA2_DIR) $(BUILD_DIR)/$(PY-JINJA2_DIR) $(@D)
	mkdir -p $(PY-JINJA2_BUILD_DIR)
	$(PY-JINJA2_UNZIP) $(DL_DIR)/$(PY-JINJA2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-JINJA2_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JINJA2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-JINJA2_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-JINJA2_UNZIP) $(DL_DIR)/$(PY-JINJA2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-JINJA2_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JINJA2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-JINJA2_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-JINJA2_UNZIP) $(DL_DIR)/$(PY-JINJA2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-JINJA2_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-JINJA2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-JINJA2_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-jinja2-unpack: $(PY-JINJA2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-JINJA2_BUILD_DIR)/.built: $(PY-JINJA2_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-jinja2: $(PY-JINJA2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-JINJA2_BUILD_DIR)/.staged: $(PY-JINJA2_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-JINJA2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-jinja2-stage: $(PY-JINJA2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-jinja2
#
$(PY26-JINJA2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-jinja2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JINJA2_PRIORITY)" >>$@
	@echo "Section: $(PY-JINJA2_SECTION)" >>$@
	@echo "Version: $(PY-JINJA2_VERSION)-$(PY-JINJA2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JINJA2_MAINTAINER)" >>$@
	@echo "Source: $(PY-JINJA2_SITE)/$(PY-JINJA2_SOURCE)" >>$@
	@echo "Description: $(PY-JINJA2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-JINJA2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JINJA2_CONFLICTS)" >>$@

$(PY27-JINJA2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-jinja2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JINJA2_PRIORITY)" >>$@
	@echo "Section: $(PY-JINJA2_SECTION)" >>$@
	@echo "Version: $(PY-JINJA2_VERSION)-$(PY-JINJA2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JINJA2_MAINTAINER)" >>$@
	@echo "Source: $(PY-JINJA2_SITE)/$(PY-JINJA2_SOURCE)" >>$@
	@echo "Description: $(PY-JINJA2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-JINJA2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JINJA2_CONFLICTS)" >>$@

$(PY3-JINJA2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-jinja2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JINJA2_PRIORITY)" >>$@
	@echo "Section: $(PY-JINJA2_SECTION)" >>$@
	@echo "Version: $(PY-JINJA2_VERSION)-$(PY-JINJA2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JINJA2_MAINTAINER)" >>$@
	@echo "Source: $(PY-JINJA2_SITE)/$(PY-JINJA2_SOURCE)" >>$@
	@echo "Description: $(PY-JINJA2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-JINJA2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JINJA2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-JINJA2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-JINJA2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-JINJA2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-JINJA2_IPK_DIR)$(TARGET_PREFIX)/etc/py-jinja2/...
# Documentation files should be installed in $(PY-JINJA2_IPK_DIR)$(TARGET_PREFIX)/doc/py-jinja2/...
# Daemon startup scripts should be installed in $(PY-JINJA2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-jinja2
#
# You may need to patch your application to make it use these locations.
#
$(PY26-JINJA2_IPK): $(PY-JINJA2_BUILD_DIR)/.built
	rm -rf $(PY26-JINJA2_IPK_DIR) $(BUILD_DIR)/py26-jinja2_*_$(TARGET_ARCH).ipk
	(cd $(PY-JINJA2_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-JINJA2_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-JINJA2_IPK_DIR)/CONTROL/control
	echo $(PY-JINJA2_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-JINJA2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-JINJA2_IPK_DIR)

$(PY27-JINJA2_IPK): $(PY-JINJA2_BUILD_DIR)/.built
	rm -rf $(PY27-JINJA2_IPK_DIR) $(BUILD_DIR)/py27-jinja2_*_$(TARGET_ARCH).ipk
	(cd $(PY-JINJA2_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-JINJA2_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-JINJA2_IPK_DIR)/CONTROL/control
	echo $(PY-JINJA2_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-JINJA2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-JINJA2_IPK_DIR)

$(PY3-JINJA2_IPK): $(PY-JINJA2_BUILD_DIR)/.built
	rm -rf $(PY3-JINJA2_IPK_DIR) $(BUILD_DIR)/py3-jinja2_*_$(TARGET_ARCH).ipk
	(cd $(PY-JINJA2_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-JINJA2_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-JINJA2_IPK_DIR)/CONTROL/control
	echo $(PY-JINJA2_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-JINJA2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-JINJA2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-jinja2-ipk: $(PY26-JINJA2_IPK) $(PY27-JINJA2_IPK) $(PY3-JINJA2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-jinja2-clean:
	-$(MAKE) -C $(PY-JINJA2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-jinja2-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-JINJA2_DIR) $(PY-JINJA2_BUILD_DIR) \
	$(PY26-JINJA2_IPK_DIR) $(PY26-JINJA2_IPK) \
	$(PY27-JINJA2_IPK_DIR) $(PY27-JINJA2_IPK) \
	$(PY3-JINJA2_IPK_DIR) $(PY3-JINJA2_IPK) \

#
# Some sanity check for the package.
#
py-jinja2-check: $(PY26-JINJA2_IPK) $(PY27-JINJA2_IPK) $(PY3-JINJA2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
