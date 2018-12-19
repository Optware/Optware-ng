###########################################################
#
# py-beaker
#
###########################################################

#
# PY-BEAKER_VERSION, PY-BEAKER_SITE and PY-BEAKER_SOURCE define
# the upstream location of the source code for the package.
# PY-BEAKER_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BEAKER_UNZIP is the command used to unzip the source.
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
# PY-BEAKER_IPK_VERSION should be incremented when the ipk changes.
#
PY-BEAKER_SITE=http://pypi.python.org/packages/source/B/Beaker
PY-BEAKER_VERSION=1.6.4
PY-BEAKER_IPK_VERSION=4
PY-BEAKER_SOURCE=Beaker-$(PY-BEAKER_VERSION).tar.gz
PY-BEAKER_DIR=Beaker-$(PY-BEAKER_VERSION)
PY-BEAKER_UNZIP=zcat
PY-BEAKER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BEAKER_DESCRIPTION=A Session and Caching library with WSGI Middleware.
PY-BEAKER_SECTION=misc
PY-BEAKER_PRIORITY=optional
PY25-BEAKER_DEPENDS=python25
PY26-BEAKER_DEPENDS=python26
PY27-BEAKER_DEPENDS=python27
PY3-BEAKER_DEPENDS=python3
PY-BEAKER_SUGGESTS=
PY-BEAKER_CONFLICTS=


#
# PY-BEAKER_CONFFILES should be a list of user-editable files
#PY-BEAKER_CONFFILES=$(TARGET_PREFIX)/etc/py-beaker.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-beaker

#
# PY-BEAKER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BEAKER_PATCHES=$(PY-BEAKER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BEAKER_CPPFLAGS=
PY-BEAKER_LDFLAGS=

#
# PY-BEAKER_BUILD_DIR is the directory in which the build is done.
# PY-BEAKER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BEAKER_IPK_DIR is the directory in which the ipk is built.
# PY-BEAKER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BEAKER_BUILD_DIR=$(BUILD_DIR)/py-beaker
PY-BEAKER_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-beaker
PY-BEAKER_SOURCE_DIR=$(SOURCE_DIR)/py-beaker

PY25-BEAKER_IPK_DIR=$(BUILD_DIR)/py25-beaker-$(PY-BEAKER_VERSION)-ipk
PY25-BEAKER_IPK=$(BUILD_DIR)/py25-beaker_$(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-BEAKER_IPK_DIR=$(BUILD_DIR)/py26-beaker-$(PY-BEAKER_VERSION)-ipk
PY26-BEAKER_IPK=$(BUILD_DIR)/py26-beaker_$(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-BEAKER_IPK_DIR=$(BUILD_DIR)/py27-beaker-$(PY-BEAKER_VERSION)-ipk
PY27-BEAKER_IPK=$(BUILD_DIR)/py27-beaker_$(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-BEAKER_IPK_DIR=$(BUILD_DIR)/py3-beaker-$(PY-BEAKER_VERSION)-ipk
PY3-BEAKER_IPK=$(BUILD_DIR)/py3-beaker_$(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-beaker-source py-beaker-unpack py-beaker py-beaker-stage py-beaker-ipk py-beaker-clean py-beaker-dirclean py-beaker-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BEAKER_SOURCE):
	$(WGET) -P $(@D) $(PY-BEAKER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-beaker-source: $(DL_DIR)/$(PY-BEAKER_SOURCE) $(PY-BEAKER_PATCHES)

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
$(PY-BEAKER_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BEAKER_SOURCE) $(PY-BEAKER_PATCHES) make/py-beaker.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-BEAKER_DIR)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BEAKER_PATCHES)" ; then \
	    cat $(PY-BEAKER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-BEAKER_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python2.5") >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-BEAKER_DIR)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BEAKER_PATCHES)" ; then \
	    cat $(PY-BEAKER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-BEAKER_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python2.6") >> setup.cfg \
	)
	# 2.7
	rm -rf $(BUILD_DIR)/$(PY-BEAKER_DIR)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BEAKER_PATCHES)" ; then \
	    cat $(PY-BEAKER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-BEAKER_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python2.7") >> setup.cfg \
	)
	# 3
	rm -rf $(BUILD_DIR)/$(PY-BEAKER_DIR)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BEAKER_PATCHES)" ; then \
	    cat $(PY-BEAKER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-BEAKER_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/3
	(cd $(@D)/3; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)") >> setup.cfg \
	)
	touch $@

py-beaker-unpack: $(PY-BEAKER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BEAKER_BUILD_DIR)/.built: $(PY-BEAKER_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
py-beaker: $(PY-BEAKER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-BEAKER_BUILD_DIR)/.staged: $(PY-BEAKER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-beaker-stage: $(PY-BEAKER_BUILD_DIR)/.staged

$(PY-BEAKER_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-BEAKER_SOURCE) make/py-beaker.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)
	$(MAKE) python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	mkdir -p $(@D)/
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-BEAKER_UNZIP) $(DL_DIR)/$(PY-BEAKER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-BEAKER_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D)/2.5; \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.6; \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-beaker-host-stage: $(PY-BEAKER_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-beaker
#
$(PY25-BEAKER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-beaker" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BEAKER_PRIORITY)" >>$@
	@echo "Section: $(PY-BEAKER_SECTION)" >>$@
	@echo "Version: $(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BEAKER_MAINTAINER)" >>$@
	@echo "Source: $(PY-BEAKER_SITE)/$(PY-BEAKER_SOURCE)" >>$@
	@echo "Description: $(PY-BEAKER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BEAKER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BEAKER_CONFLICTS)" >>$@

$(PY26-BEAKER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-beaker" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BEAKER_PRIORITY)" >>$@
	@echo "Section: $(PY-BEAKER_SECTION)" >>$@
	@echo "Version: $(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BEAKER_MAINTAINER)" >>$@
	@echo "Source: $(PY-BEAKER_SITE)/$(PY-BEAKER_SOURCE)" >>$@
	@echo "Description: $(PY-BEAKER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-BEAKER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BEAKER_CONFLICTS)" >>$@

$(PY27-BEAKER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-beaker" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BEAKER_PRIORITY)" >>$@
	@echo "Section: $(PY-BEAKER_SECTION)" >>$@
	@echo "Version: $(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BEAKER_MAINTAINER)" >>$@
	@echo "Source: $(PY-BEAKER_SITE)/$(PY-BEAKER_SOURCE)" >>$@
	@echo "Description: $(PY-BEAKER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-BEAKER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BEAKER_CONFLICTS)" >>$@

$(PY3-BEAKER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-beaker" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BEAKER_PRIORITY)" >>$@
	@echo "Section: $(PY-BEAKER_SECTION)" >>$@
	@echo "Version: $(PY-BEAKER_VERSION)-$(PY-BEAKER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BEAKER_MAINTAINER)" >>$@
	@echo "Source: $(PY-BEAKER_SITE)/$(PY-BEAKER_SOURCE)" >>$@
	@echo "Description: $(PY-BEAKER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-BEAKER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BEAKER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BEAKER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-BEAKER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BEAKER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-BEAKER_IPK_DIR)$(TARGET_PREFIX)/etc/py-beaker/...
# Documentation files should be installed in $(PY-BEAKER_IPK_DIR)$(TARGET_PREFIX)/doc/py-beaker/...
# Daemon startup scripts should be installed in $(PY-BEAKER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-beaker
#
# You may need to patch your application to make it use these locations.
#
$(PY25-BEAKER_IPK): $(PY-BEAKER_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-beaker_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-BEAKER_IPK_DIR) $(BUILD_DIR)/py25-beaker_*_$(TARGET_ARCH).ipk
	(cd $(<D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-BEAKER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY25-BEAKER_IPK_DIR)/CONTROL/control
#	echo $(PY-BEAKER_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-BEAKER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BEAKER_IPK_DIR)

$(PY26-BEAKER_IPK): $(PY-BEAKER_BUILD_DIR)/.built
	rm -rf $(PY26-BEAKER_IPK_DIR) $(BUILD_DIR)/py26-beaker_*_$(TARGET_ARCH).ipk
	(cd $(<D)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-BEAKER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-BEAKER_IPK_DIR)/CONTROL/control
#	echo $(PY-BEAKER_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-BEAKER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-BEAKER_IPK_DIR)

$(PY27-BEAKER_IPK): $(PY-BEAKER_BUILD_DIR)/.built
	rm -rf $(PY27-BEAKER_IPK_DIR) $(BUILD_DIR)/py27-beaker_*_$(TARGET_ARCH).ipk
	(cd $(<D)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install \
	    --root=$(PY27-BEAKER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-BEAKER_IPK_DIR)/CONTROL/control
#	echo $(PY-BEAKER_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-BEAKER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-BEAKER_IPK_DIR)

$(PY3-BEAKER_IPK): $(PY-BEAKER_BUILD_DIR)/.built
	rm -rf $(PY3-BEAKER_IPK_DIR) $(BUILD_DIR)/py3-beaker_*_$(TARGET_ARCH).ipk
	(cd $(<D)/3; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install \
	    --root=$(PY3-BEAKER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-BEAKER_IPK_DIR)/CONTROL/control
#	echo $(PY-BEAKER_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-BEAKER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-BEAKER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-beaker-ipk: $(PY25-BEAKER_IPK) $(PY26-BEAKER_IPK) $(PY27-BEAKER_IPK) $(PY3-BEAKER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-beaker-clean:
	-$(MAKE) -C $(PY-BEAKER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-beaker-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BEAKER_DIR) $(PY-BEAKER_BUILD_DIR)
	rm -rf $(PY25-BEAKER_IPK_DIR) $(PY25-BEAKER_IPK)
	rm -rf $(PY26-BEAKER_IPK_DIR) $(PY26-BEAKER_IPK)
	rm -rf $(PY27-BEAKER_IPK_DIR) $(PY27-BEAKER_IPK)
	rm -rf $(PY3-BEAKER_IPK_DIR) $(PY3-BEAKER_IPK)

#
# Some sanity check for the package.
#
py-beaker-check: $(PY25-BEAKER_IPK) $(PY26-BEAKER_IPK) $(PY27-BEAKER_IPK) $(PY3-BEAKER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
