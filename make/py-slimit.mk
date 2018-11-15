###########################################################
#
# py-slimit
#
###########################################################

#
# PY-SLIMIT_VERSION, PY-SLIMIT_SITE and PY-SLIMIT_SOURCE define
# the upstream location of the source code for the package.
# PY-SLIMIT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SLIMIT_UNZIP is the command used to unzip the source.
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
PY-SLIMIT_SITE=http://ftp.ksu.edu.tw/FTP/Linux/ubuntu/pool/universe/s/slimit
PY-SLIMIT_VERSION=0.8.1
PY-SLIMIT_SOURCE=slimit_$(PY-SLIMIT_VERSION).orig.tar.gz
PY-SLIMIT_DIR=slimit-$(PY-SLIMIT_VERSION)
PY-SLIMIT_UNZIP=zcat
PY-SLIMIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SLIMIT_DESCRIPTION=SlimIt is a JavaScript minifier written in Python. It compiles JavaScript into more compact code so that it downloads and runs faster.
PY-SLIMIT_SECTION=misc
PY-SLIMIT_PRIORITY=optional
PY27-SLIMIT_DEPENDS=python27, py27-ply
PY3-SLIMIT_DEPENDS=python3, py3-ply
PY-SLIMIT_CONFLICTS=

#
# PY-SLIMIT_IPK_VERSION should be incremented when the ipk changes.
#
PY-SLIMIT_IPK_VERSION=4

#
# PY-SLIMIT_CONFFILES should be a list of user-editable files
#PY-SLIMIT_CONFFILES=$(TARGET_PREFIX)/etc/py-slimit.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-slimit

#
# PY-SLIMIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SLIMIT_PATCHES=$(PY-SLIMIT_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SLIMIT_CPPFLAGS=
PY-SLIMIT_LDFLAGS=

#
# PY-SLIMIT_BUILD_DIR is the directory in which the build is done.
# PY-SLIMIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SLIMIT_IPK_DIR is the directory in which the ipk is built.
# PY-SLIMIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SLIMIT_BUILD_DIR=$(BUILD_DIR)/py-slimit
PY-SLIMIT_SOURCE_DIR=$(SOURCE_DIR)/py-slimit
PY-SLIMIT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-slimit

PY27-SLIMIT_IPK_DIR=$(BUILD_DIR)/py27-slimit-$(PY-SLIMIT_VERSION)-ipk
PY27-SLIMIT_IPK=$(BUILD_DIR)/py27-slimit_$(PY-SLIMIT_VERSION)-$(PY-SLIMIT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-SLIMIT_IPK_DIR=$(BUILD_DIR)/py3-slimit-$(PY-SLIMIT_VERSION)-ipk
PY3-SLIMIT_IPK=$(BUILD_DIR)/py3-slimit_$(PY-SLIMIT_VERSION)-$(PY-SLIMIT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SLIMIT_SOURCE):
	$(WGET) -P $(@D) $(PY-SLIMIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-slimit-source: $(DL_DIR)/$(PY-SLIMIT_SOURCE) $(PY-SLIMIT_PATCHES)

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
$(PY-SLIMIT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SLIMIT_SOURCE) $(PY-SLIMIT_PATCHES) make/py-slimit.mk
	$(MAKE) py-setuptools-stage py-setuptools-host-stage py-ply-host-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.7
	rm -rf $(BUILD_DIR)/$(PY-SLIMIT_DIR)
	$(PY-SLIMIT_UNZIP) $(DL_DIR)/$(PY-SLIMIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-SLIMIT_PATCHES)"; then \
	    cat $(PY-SLIMIT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SLIMIT_DIR) -p1; \
	fi
	sed -i -e "s/(__file__)/('__file__')/" $(BUILD_DIR)/$(PY-SLIMIT_DIR)/setup.py
	mv $(BUILD_DIR)/$(PY-SLIMIT_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) > setup.cfg \
	)
	# 3
	rm -rf $(BUILD_DIR)/$(PY-SLIMIT_DIR)
	$(PY-SLIMIT_UNZIP) $(DL_DIR)/$(PY-SLIMIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-SLIMIT_PATCHES)"; then \
	    cat $(PY-SLIMIT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SLIMIT_DIR) -p1; \
	fi
	sed -i -e "s/(__file__)/('__file__')/" $(BUILD_DIR)/$(PY-SLIMIT_DIR)/setup.py
	mv $(BUILD_DIR)/$(PY-SLIMIT_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-slimit-unpack: $(PY-SLIMIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SLIMIT_BUILD_DIR)/.built: $(PY-SLIMIT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-slimit: $(PY-SLIMIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SLIMIT_BUILD_DIR)/.staged: $(PY-SLIMIT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

$(PY-SLIMIT_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-SLIMIT_SOURCE) make/py-slimit.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-SLIMIT_DIR) $(@D)
	$(MAKE) py-setuptools-host-stage
	mkdir -p $(@D)/
	$(PY-SLIMIT_UNZIP) $(DL_DIR)/$(PY-SLIMIT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	sed -i -e "s/(__file__)/('__file__')/" $(HOST_BUILD_DIR)/$(PY-SLIMIT_DIR)/setup.py
	mv $(HOST_BUILD_DIR)/$(PY-SLIMIT_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(HOST_STAGING_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	$(PY-SLIMIT_UNZIP) $(DL_DIR)/$(PY-SLIMIT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	sed -i -e "s/(__file__)/('__file__')/" $(HOST_BUILD_DIR)/$(PY-SLIMIT_DIR)/setup.py
	mv $(HOST_BUILD_DIR)/$(PY-SLIMIT_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-slimit-host-stage: $(PY-SLIMIT_HOST_BUILD_DIR)/.staged

py-slimit-stage: $(PY-SLIMIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-slimit
#
$(PY27-SLIMIT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-slimit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SLIMIT_PRIORITY)" >>$@
	@echo "Section: $(PY-SLIMIT_SECTION)" >>$@
	@echo "Version: $(PY-SLIMIT_VERSION)-$(PY-SLIMIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SLIMIT_MAINTAINER)" >>$@
	@echo "Source: $(PY-SLIMIT_SITE)/$(PY-SLIMIT_SOURCE)" >>$@
	@echo "Description: $(PY-SLIMIT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-SLIMIT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SLIMIT_CONFLICTS)" >>$@

$(PY3-SLIMIT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-slimit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SLIMIT_PRIORITY)" >>$@
	@echo "Section: $(PY-SLIMIT_SECTION)" >>$@
	@echo "Version: $(PY-SLIMIT_VERSION)-$(PY-SLIMIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SLIMIT_MAINTAINER)" >>$@
	@echo "Source: $(PY-SLIMIT_SITE)/$(PY-SLIMIT_SOURCE)" >>$@
	@echo "Description: $(PY-SLIMIT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-SLIMIT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SLIMIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SLIMIT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-SLIMIT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SLIMIT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-SLIMIT_IPK_DIR)$(TARGET_PREFIX)/etc/py-slimit/...
# Documentation files should be installed in $(PY-SLIMIT_IPK_DIR)$(TARGET_PREFIX)/doc/py-slimit/...
# Daemon startup scripts should be installed in $(PY-SLIMIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-slimit
#
# You may need to patch your application to make it use these locations.
#
$(PY27-SLIMIT_IPK): $(PY-SLIMIT_BUILD_DIR)/.built
	rm -rf $(PY27-SLIMIT_IPK_DIR) $(BUILD_DIR)/py27-slimit_*_$(TARGET_ARCH).ipk
	(cd $(PY-SLIMIT_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 -c "import setuptools; execfile('setup.py')" install --root=$(PY27-SLIMIT_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-SLIMIT_IPK_DIR)/CONTROL/control
#	echo $(PY-SLIMIT_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-SLIMIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-SLIMIT_IPK_DIR)

$(PY3-SLIMIT_IPK): $(PY-SLIMIT_BUILD_DIR)/.built
	rm -rf $(PY3-SLIMIT_IPK_DIR) $(BUILD_DIR)/py3-slimit_*_$(TARGET_ARCH).ipk
	(cd $(PY-SLIMIT_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-SLIMIT_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-SLIMIT_IPK_DIR)/CONTROL/control
#	echo $(PY-SLIMIT_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-SLIMIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-SLIMIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-slimit-ipk: $(PY27-SLIMIT_IPK) $(PY3-SLIMIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-slimit-clean:
	-$(MAKE) -C $(PY-SLIMIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-slimit-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SLIMIT_DIR) $(PY-SLIMIT_BUILD_DIR)
	rm -rf $(PY27-SLIMIT_IPK_DIR) $(PY27-SLIMIT_IPK)
	rm -rf $(PY3-SLIMIT_IPK_DIR) $(PY3-SLIMIT_IPK)
