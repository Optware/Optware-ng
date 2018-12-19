###########################################################
#
# py-lepl
#
###########################################################

#
# PY-LEPL_VERSION, PY-LEPL_SITE and PY-LEPL_SOURCE define
# the upstream location of the source code for the package.
# PY-LEPL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-LEPL_UNZIP is the command used to unzip the source.
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
PY-LEPL_SITE=http://pypi.python.org/packages/source/L/LEPL
PY-LEPL_VERSION=5.0.0
PY-LEPL_SOURCE=LEPL-$(PY-LEPL_VERSION).tar.gz
PY-LEPL_DIR=LEPL-$(PY-LEPL_VERSION)
PY-LEPL_UNZIP=zcat
PY-LEPL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-LEPL_DESCRIPTION=A Parser Library for Python with Recursive Descent and Full Backtracking
PY-LEPL_SECTION=misc
PY-LEPL_PRIORITY=optional
PY26-LEPL_DEPENDS=python26
PY31-LEPL_DEPENDS=python3
PY-LEPL_CONFLICTS=

#
# PY-LEPL_IPK_VERSION should be incremented when the ipk changes.
#
PY-LEPL_IPK_VERSION=2

#
# PY-LEPL_CONFFILES should be a list of user-editable files
#PY-LEPL_CONFFILES=$(TARGET_PREFIX)/etc/py-lepl.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-lepl

#
# PY-LEPL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-LEPL_PATCHES=$(PY-LEPL_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-LEPL_CPPFLAGS=
PY-LEPL_LDFLAGS=

#
# PY-LEPL_BUILD_DIR is the directory in which the build is done.
# PY-LEPL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-LEPL_IPK_DIR is the directory in which the ipk is built.
# PY-LEPL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-LEPL_BUILD_DIR=$(BUILD_DIR)/py-lepl
PY-LEPL_SOURCE_DIR=$(SOURCE_DIR)/py-lepl

PY26-LEPL_IPK_DIR=$(BUILD_DIR)/py26-lepl-$(PY-LEPL_VERSION)-ipk
PY26-LEPL_IPK=$(BUILD_DIR)/py26-lepl_$(PY-LEPL_VERSION)-$(PY-LEPL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY31-LEPL_IPK_DIR=$(BUILD_DIR)/py31-lepl-$(PY-LEPL_VERSION)-ipk
PY31-LEPL_IPK=$(BUILD_DIR)/py31-lepl_$(PY-LEPL_VERSION)-$(PY-LEPL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-LEPL_SOURCE):
	$(WGET) -P $(@D) $(PY-LEPL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-lepl-source: $(DL_DIR)/$(PY-LEPL_SOURCE) $(PY-LEPL_PATCHES)

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
$(PY-LEPL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-LEPL_SOURCE) $(PY-LEPL_PATCHES) make/py-lepl.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-LEPL_DIR)
	$(PY-LEPL_UNZIP) $(DL_DIR)/$(PY-LEPL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-LEPL_PATCHES)"; then \
	    cat $(PY-LEPL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-LEPL_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-LEPL_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) > setup.cfg \
	)
	# 3.1
	rm -rf $(BUILD_DIR)/$(PY-LEPL_DIR)
	$(PY-LEPL_UNZIP) $(DL_DIR)/$(PY-LEPL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-LEPL_PATCHES)"; then \
	    cat $(PY-LEPL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-LEPL_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-LEPL_DIR) $(@D)/3.1
	(cd $(@D)/3.1; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python3.1"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-lepl-unpack: $(PY-LEPL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-LEPL_BUILD_DIR)/.built: $(PY-LEPL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
#	(cd $(@D)/3.1; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python3.1/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python3.1 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-lepl: $(PY-LEPL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-LEPL_BUILD_DIR)/.staged: $(PY-LEPL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-lepl-stage: $(PY-LEPL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-lepl
#
$(PY26-LEPL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-lepl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-LEPL_PRIORITY)" >>$@
	@echo "Section: $(PY-LEPL_SECTION)" >>$@
	@echo "Version: $(PY-LEPL_VERSION)-$(PY-LEPL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-LEPL_MAINTAINER)" >>$@
	@echo "Source: $(PY-LEPL_SITE)/$(PY-LEPL_SOURCE)" >>$@
	@echo "Description: $(PY-LEPL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-LEPL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-LEPL_CONFLICTS)" >>$@

$(PY31-LEPL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py31-lepl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-LEPL_PRIORITY)" >>$@
	@echo "Section: $(PY-LEPL_SECTION)" >>$@
	@echo "Version: $(PY-LEPL_VERSION)-$(PY-LEPL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-LEPL_MAINTAINER)" >>$@
	@echo "Source: $(PY-LEPL_SITE)/$(PY-LEPL_SOURCE)" >>$@
	@echo "Description: $(PY-LEPL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY31-LEPL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-LEPL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-LEPL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-LEPL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-LEPL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-LEPL_IPK_DIR)$(TARGET_PREFIX)/etc/py-lepl/...
# Documentation files should be installed in $(PY-LEPL_IPK_DIR)$(TARGET_PREFIX)/doc/py-lepl/...
# Daemon startup scripts should be installed in $(PY-LEPL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-lepl
#
# You may need to patch your application to make it use these locations.
#
$(PY26-LEPL_IPK): $(PY-LEPL_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-lepl_*_$(TARGET_ARCH).ipk
	rm -rf $(PY26-LEPL_IPK_DIR) $(BUILD_DIR)/py26-lepl_*_$(TARGET_ARCH).ipk
	(cd $(PY-LEPL_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install --root=$(PY26-LEPL_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-LEPL_IPK_DIR)/CONTROL/control
#	echo $(PY-LEPL_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-LEPL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-LEPL_IPK_DIR)

$(PY31-LEPL_IPK): $(PY-LEPL_BUILD_DIR)/.built
	rm -rf $(PY31-LEPL_IPK_DIR) $(BUILD_DIR)/py31-lepl_*_$(TARGET_ARCH).ipk
	(cd $(PY-LEPL_BUILD_DIR)/3.1; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python3.1/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python3.1 -c "import setuptools; execfile('setup.py')" install --root=$(PY31-LEPL_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY31-LEPL_IPK_DIR)/CONTROL/control
#	echo $(PY-LEPL_CONFFILES) | sed -e 's/ /\n/g' > $(PY31-LEPL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY31-LEPL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-lepl-ipk: $(PY26-LEPL_IPK)
# $(PY31-LEPL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-lepl-clean:
	-$(MAKE) -C $(PY-LEPL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-lepl-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-LEPL_DIR) $(PY-LEPL_BUILD_DIR)
	rm -rf $(PY26-LEPL_IPK_DIR) $(PY26-LEPL_IPK)
	rm -rf $(PY31-LEPL_IPK_DIR) $(PY31-LEPL_IPK)
