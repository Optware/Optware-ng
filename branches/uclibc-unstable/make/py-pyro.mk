###########################################################
#
# py-pyro
#
###########################################################

#
# PY-PYRO_VERSION, PY-PYRO_SITE and PY-PYRO_SOURCE define
# the upstream location of the source code for the package.
# PY-PYRO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PYRO_UNZIP is the command used to unzip the source.
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
PY-PYRO_VERSION=3.5
PY-PYRO_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pyro
PY-PYRO_SOURCE=Pyro-$(PY-PYRO_VERSION).tar.gz
PY-PYRO_DIR=Pyro-$(PY-PYRO_VERSION)
PY-PYRO_UNZIP=zcat
PY-PYRO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PYRO_DESCRIPTION=PYthon Remote Objects.
PY-PYRO_SECTION=misc
PY-PYRO_PRIORITY=optional
PY-PYRO_DEPENDS=python
PY-PYRO_CONFLICTS=

#
# PY-PYRO_IPK_VERSION should be incremented when the ipk changes.
#
PY-PYRO_IPK_VERSION=1

#
# PY-PYRO_CONFFILES should be a list of user-editable files
#PY-PYRO_CONFFILES=/opt/etc/py-pyro.conf /opt/etc/init.d/SXXpy-pyro

#
# PY-PYRO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PYRO_PATCHES=$(PY-PYRO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PYRO_CPPFLAGS=
PY-PYRO_LDFLAGS=

#
# PY-PYRO_BUILD_DIR is the directory in which the build is done.
# PY-PYRO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PYRO_IPK_DIR is the directory in which the ipk is built.
# PY-PYRO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PYRO_BUILD_DIR=$(BUILD_DIR)/py-pyro
PY-PYRO_SOURCE_DIR=$(SOURCE_DIR)/py-pyro
PY-PYRO_IPK_DIR=$(BUILD_DIR)/py-pyro-$(PY-PYRO_VERSION)-ipk
PY-PYRO_IPK=$(BUILD_DIR)/py-pyro_$(PY-PYRO_VERSION)-$(PY-PYRO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PYRO_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PYRO_SITE)/$(PY-PYRO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pyro-source: $(DL_DIR)/$(PY-PYRO_SOURCE) $(PY-PYRO_PATCHES)

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
$(PY-PYRO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PYRO_SOURCE) $(PY-PYRO_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-PYRO_DIR) $(PY-PYRO_BUILD_DIR)
	$(PY-PYRO_UNZIP) $(DL_DIR)/$(PY-PYRO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PYRO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PYRO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PYRO_DIR) $(PY-PYRO_BUILD_DIR)
	(cd $(PY-PYRO_BUILD_DIR); \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python"; \
		echo "[install-options]"; \
		echo "unattended=1"; \
		echo "[install]"; \
		echo "optimize=1"; \
		echo "install-scripts=/opt/bin"; \
	    ) > setup.cfg; \
	)
	touch $(PY-PYRO_BUILD_DIR)/.configured

py-pyro-unpack: $(PY-PYRO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PYRO_BUILD_DIR)/.built: $(PY-PYRO_BUILD_DIR)/.configured
	rm -f $(PY-PYRO_BUILD_DIR)/.built
	(cd $(PY-PYRO_BUILD_DIR); \
	    python2.4 setup.py build; \
	)
	touch $(PY-PYRO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-pyro: $(PY-PYRO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PYRO_BUILD_DIR)/.staged: $(PY-PYRO_BUILD_DIR)/.built
	rm -f $(PY-PYRO_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-PYRO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-PYRO_BUILD_DIR)/.staged

py-pyro-stage: $(PY-PYRO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pyro
#
$(PY-PYRO_IPK_DIR)/CONTROL/control:
	@install -d $(PY-PYRO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-pyro" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PYRO_PRIORITY)" >>$@
	@echo "Section: $(PY-PYRO_SECTION)" >>$@
	@echo "Version: $(PY-PYRO_VERSION)-$(PY-PYRO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PYRO_MAINTAINER)" >>$@
	@echo "Source: $(PY-PYRO_SITE)/$(PY-PYRO_SOURCE)" >>$@
	@echo "Description: $(PY-PYRO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-PYRO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PYRO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PYRO_IPK_DIR)/opt/sbin or $(PY-PYRO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PYRO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PYRO_IPK_DIR)/opt/etc/py-pyro/...
# Documentation files should be installed in $(PY-PYRO_IPK_DIR)/opt/doc/py-pyro/...
# Daemon startup scripts should be installed in $(PY-PYRO_IPK_DIR)/opt/etc/init.d/S??py-pyro
#
# You may need to patch your application to make it use these locations.
#
$(PY-PYRO_IPK): $(PY-PYRO_BUILD_DIR)/.built
	rm -rf $(PY-PYRO_IPK_DIR) $(BUILD_DIR)/py-pyro_*_$(TARGET_ARCH).ipk
	(cd $(PY-PYRO_BUILD_DIR); \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    python2.4 -c "import setuptools; execfile('setup.py')" \
		install --root=$(PY-PYRO_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY-PYRO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-PYRO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pyro-ipk: $(PY-PYRO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pyro-clean:
	-$(MAKE) -C $(PY-PYRO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pyro-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PYRO_DIR) $(PY-PYRO_BUILD_DIR) $(PY-PYRO_IPK_DIR) $(PY-PYRO_IPK)
