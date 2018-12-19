###########################################################
#
# py-mako
#
###########################################################

#
# PY-MAKO_VERSION, PY-MAKO_SITE and PY-MAKO_SOURCE define
# the upstream location of the source code for the package.
# PY-MAKO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MAKO_UNZIP is the command used to unzip the source.
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
# PY-MAKO_IPK_VERSION should be incremented when the ipk changes.
#
PY-MAKO_SITE=http://pypi.python.org/packages/source/M/Mako
PY-MAKO_VERSION=1.0.1
PY-MAKO_VERSION_OLD=0.9.1
PY-MAKO_IPK_VERSION=4
PY-MAKO_SOURCE=Mako-$(PY-MAKO_VERSION).tar.gz
PY-MAKO_SOURCE_OLD=Mako-$(PY-MAKO_VERSION_OLD).tar.gz
PY-MAKO_DIR=Mako-$(PY-MAKO_VERSION)
PY-MAKO_DIR_OLD=Mako-$(PY-MAKO_VERSION_OLD)
PY-MAKO_UNZIP=zcat
PY-MAKO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MAKO_DESCRIPTION=Mako is a template library written in Python.
PY-MAKO_SECTION=misc
PY-MAKO_PRIORITY=optional
PY25-MAKO_DEPENDS=python25, py25-beaker
PY26-MAKO_DEPENDS=python26, py26-beaker
PY27-MAKO_DEPENDS=python27, py27-beaker
PY3-MAKO_DEPENDS=python3, py3-beaker
PY-MAKO_SUGGESTS=
PY-MAKO_CONFLICTS=


#
# PY-MAKO_CONFFILES should be a list of user-editable files
#PY-MAKO_CONFFILES=$(TARGET_PREFIX)/etc/py-mako.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-mako

#
# PY-MAKO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MAKO_PATCHES=$(PY-MAKO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MAKO_CPPFLAGS=
PY-MAKO_LDFLAGS=

#
# PY-MAKO_BUILD_DIR is the directory in which the build is done.
# PY-MAKO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MAKO_IPK_DIR is the directory in which the ipk is built.
# PY-MAKO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MAKO_BUILD_DIR=$(BUILD_DIR)/py-mako
PY-MAKO_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-mako
PY-MAKO_SOURCE_DIR=$(SOURCE_DIR)/py-mako

PY25-MAKO_IPK_DIR=$(BUILD_DIR)/py25-mako-$(PY-MAKO_VERSION_OLD)-ipk
PY25-MAKO_IPK=$(BUILD_DIR)/py25-mako_$(PY-MAKO_VERSION_OLD)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-MAKO_IPK_DIR=$(BUILD_DIR)/py26-mako-$(PY-MAKO_VERSION)-ipk
PY26-MAKO_IPK=$(BUILD_DIR)/py26-mako_$(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-MAKO_IPK_DIR=$(BUILD_DIR)/py27-mako-$(PY-MAKO_VERSION)-ipk
PY27-MAKO_IPK=$(BUILD_DIR)/py27-mako_$(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-MAKO_IPK_DIR=$(BUILD_DIR)/py3-mako-$(PY-MAKO_VERSION)-ipk
PY3-MAKO_IPK=$(BUILD_DIR)/py3-mako_$(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mako-source py-mako-unpack py-mako py-mako-stage py-mako-ipk py-mako-clean py-mako-dirclean py-mako-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MAKO_SOURCE):
	$(WGET) -P $(@D) $(PY-MAKO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-MAKO_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-MAKO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mako-source: $(DL_DIR)/$(PY-MAKO_SOURCE) $(DL_DIR)/$(PY-MAKO_SOURCE_OLD) $(PY-MAKO_PATCHES)

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
$(PY-MAKO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MAKO_SOURCE) $(DL_DIR)/$(PY-MAKO_SOURCE_OLD) $(PY-MAKO_PATCHES) make/py-mako.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR_OLD)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-MAKO_DIR_OLD) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python2.5") >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-MAKO_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python2.6") >> setup.cfg \
	)
	# 2.7
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-MAKO_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python2.7") >> setup.cfg \
	)
	# 3
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-MAKO_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/3
	(cd $(@D)/3; \
	    (echo "[build_scripts]"; echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)") >> setup.cfg \
	)
	touch $@

py-mako-unpack: $(PY-MAKO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MAKO_BUILD_DIR)/.built: $(PY-MAKO_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-mako: $(PY-MAKO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MAKO_BUILD_DIR)/.staged: $(PY-MAKO_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

$(PY-MAKO_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-MAKO_SOURCE)  $(DL_DIR)/$(PY-MAKO_SOURCE_OLD) make/py-mako.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-MAKO_DIR) $(HOST_BUILD_DIR)/$(PY-MAKO_DIR_OLD) $(@D)
	$(MAKE) py-beaker-host-stage
	mkdir -p $(@D)/
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-MAKO_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/3
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

py-mako-host-stage: $(PY-MAKO_HOST_BUILD_DIR)/.staged

py-mako-stage: $(PY-MAKO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mako
#
$(PY25-MAKO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-mako" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MAKO_PRIORITY)" >>$@
	@echo "Section: $(PY-MAKO_SECTION)" >>$@
	@echo "Version: $(PY-MAKO_VERSION_OLD)-$(PY-MAKO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MAKO_MAINTAINER)" >>$@
	@echo "Source: $(PY-MAKO_SITE)/$(PY-MAKO_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-MAKO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MAKO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MAKO_CONFLICTS)" >>$@

$(PY26-MAKO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-mako" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MAKO_PRIORITY)" >>$@
	@echo "Section: $(PY-MAKO_SECTION)" >>$@
	@echo "Version: $(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MAKO_MAINTAINER)" >>$@
	@echo "Source: $(PY-MAKO_SITE)/$(PY-MAKO_SOURCE)" >>$@
	@echo "Description: $(PY-MAKO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-MAKO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MAKO_CONFLICTS)" >>$@

$(PY27-MAKO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-mako" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MAKO_PRIORITY)" >>$@
	@echo "Section: $(PY-MAKO_SECTION)" >>$@
	@echo "Version: $(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MAKO_MAINTAINER)" >>$@
	@echo "Source: $(PY-MAKO_SITE)/$(PY-MAKO_SOURCE)" >>$@
	@echo "Description: $(PY-MAKO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-MAKO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MAKO_CONFLICTS)" >>$@

$(PY3-MAKO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-mako" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MAKO_PRIORITY)" >>$@
	@echo "Section: $(PY-MAKO_SECTION)" >>$@
	@echo "Version: $(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MAKO_MAINTAINER)" >>$@
	@echo "Source: $(PY-MAKO_SITE)/$(PY-MAKO_SOURCE)" >>$@
	@echo "Description: $(PY-MAKO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-MAKO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MAKO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MAKO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-MAKO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MAKO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-MAKO_IPK_DIR)$(TARGET_PREFIX)/etc/py-mako/...
# Documentation files should be installed in $(PY-MAKO_IPK_DIR)$(TARGET_PREFIX)/doc/py-mako/...
# Daemon startup scripts should be installed in $(PY-MAKO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-mako
#
# You may need to patch your application to make it use these locations.
#
$(PY25-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-mako_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-MAKO_IPK_DIR) $(BUILD_DIR)/py25-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MAKO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	for f in $(PY25-MAKO_IPK_DIR)$(TARGET_PREFIX)/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-py2.5|'`; done
	$(MAKE) $(PY25-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MAKO_IPK_DIR)

$(PY26-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(PY26-MAKO_IPK_DIR) $(BUILD_DIR)/py26-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-MAKO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-MAKO_IPK_DIR)

$(PY27-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(PY27-MAKO_IPK_DIR) $(BUILD_DIR)/py27-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.7; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install \
	    --root=$(PY27-MAKO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-MAKO_IPK_DIR)

$(PY3-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(PY3-MAKO_IPK_DIR) $(BUILD_DIR)/py3-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install \
	    --root=$(PY26-MAKO_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-MAKO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mako-ipk: $(PY25-MAKO_IPK) $(PY26-MAKO_IPK) $(PY27-MAKO_IPK) $(PY3-MAKO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mako-clean:
	-$(MAKE) -C $(PY-MAKO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mako-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR) $(PY-MAKO_BUILD_DIR)
	rm -rf $(PY25-MAKO_IPK_DIR) $(PY25-MAKO_IPK)
	rm -rf $(PY26-MAKO_IPK_DIR) $(PY26-MAKO_IPK)
	rm -rf $(PY27-MAKO_IPK_DIR) $(PY27-MAKO_IPK)
	rm -rf $(PY3-MAKO_IPK_DIR) $(PY3-MAKO_IPK)

#
# Some sanity check for the package.
#
py-mako-check: $(PY25-MAKO_IPK) $(PY26-MAKO_IPK) $(PY27-MAKO_IPK) $(PY3-MAKO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
