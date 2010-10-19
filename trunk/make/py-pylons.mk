###########################################################
#
# py-pylons
#
###########################################################

#
# PY-PYLONS_VERSION, PY-PYLONS_SITE and PY-PYLONS_SOURCE define
# the upstream location of the source code for the package.
# PY-PYLONS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PYLONS_UNZIP is the command used to unzip the source.
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
PY-PYLONS_SITE=http://pypi.python.org/packages/source/P/Pylons
PY-PYLONS_VERSION=0.9.6.2
PY-PYLONS_SOURCE=Pylons-$(PY-PYLONS_VERSION).tar.gz
PY-PYLONS_DIR=Pylons-$(PY-PYLONS_VERSION)
PY-PYLONS_UNZIP=zcat
PY-PYLONS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PYLONS_DESCRIPTION=A lightweight web framework emphasizing flexibility and rapid development.
PY-PYLONS_SECTION=web
PY-PYLONS_PRIORITY=optional
PY-PYLONS_CONFLICTS=

PY25-PYLONS_DEPENDS=\
	py25-beaker (>=0.8.1), \
	py25-decorator (>=2.1.0), \
	py25-formencode (>=0.7), \
	py25-mako (>=0.1.8), \
	py25-nose (>=0.9.3), \
	py25-paste (>=1.4), \
	py25-pastedeploy (>=1.3.1), \
	py25-pastescript (>=1.3.6), \
	py25-routes (>=1.7.3), \
	py25-simplejson (>=1.7.1), \
	py25-webhelpers (>=0.3.2) \

PY26-PYLONS_DEPENDS=\
	py26-beaker (>=0.8.1), \
	py26-decorator (>=2.1.0), \
	py26-formencode (>=0.7), \
	py26-mako (>=0.1.8), \
	py26-nose (>=0.9.3), \
	py26-paste (>=1.4), \
	py26-pastedeploy (>=1.3.1), \
	py26-pastescript (>=1.3.6), \
	py26-routes (>=1.7.3), \
	py26-simplejson (>=1.7.1), \
	py26-webhelpers (>=0.3.2) \


#
# PY-PYLONS_IPK_VERSION should be incremented when the ipk changes.
#
PY-PYLONS_IPK_VERSION=2

#
# PY-PYLONS_CONFFILES should be a list of user-editable files
#PY-PYLONS_CONFFILES=/opt/etc/py-pylons.conf /opt/etc/init.d/SXXpy-pylons

#
# PY-PYLONS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PYLONS_PATCHES=$(PY-PYLONS_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PYLONS_CPPFLAGS=
PY-PYLONS_LDFLAGS=

#
# PY-PYLONS_BUILD_DIR is the directory in which the build is done.
# PY-PYLONS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PYLONS_IPK_DIR is the directory in which the ipk is built.
# PY-PYLONS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PYLONS_BUILD_DIR=$(BUILD_DIR)/py-pylons
PY-PYLONS_SOURCE_DIR=$(SOURCE_DIR)/py-pylons

PY25-PYLONS_IPK_DIR=$(BUILD_DIR)/py25-pylons-$(PY-PYLONS_VERSION)-ipk
PY25-PYLONS_IPK=$(BUILD_DIR)/py25-pylons_$(PY-PYLONS_VERSION)-$(PY-PYLONS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-PYLONS_IPK_DIR=$(BUILD_DIR)/py26-pylons-$(PY-PYLONS_VERSION)-ipk
PY26-PYLONS_IPK=$(BUILD_DIR)/py26-pylons_$(PY-PYLONS_VERSION)-$(PY-PYLONS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pylons-source py-pylons-unpack py-pylons py-pylons-stage py-pylons-ipk py-pylons-clean py-pylons-dirclean py-pylons-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PYLONS_SOURCE):
	$(WGET) -P $(@D) $(PY-PYLONS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pylons-source: $(DL_DIR)/$(PY-PYLONS_SOURCE) $(PY-PYLONS_PATCHES)

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
$(PY-PYLONS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PYLONS_SOURCE) $(PY-PYLONS_PATCHES) make/py-pylons.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PYLONS_DIR)
	$(PY-PYLONS_UNZIP) $(DL_DIR)/$(PY-PYLONS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PYLONS_PATCHES)"; \
		then cat $(PY-PYLONS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PYLONS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PYLONS_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-PYLONS_DIR)
	$(PY-PYLONS_UNZIP) $(DL_DIR)/$(PY-PYLONS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PYLONS_PATCHES)"; \
		then cat $(PY-PYLONS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PYLONS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PYLONS_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	touch $@

py-pylons-unpack: $(PY-PYLONS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PYLONS_BUILD_DIR)/.built: $(PY-PYLONS_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	cd $(@D)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-pylons: $(PY-PYLONS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-PYLONS_BUILD_DIR)/.staged: $(PY-PYLONS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#py-pylons-stage: $(PY-PYLONS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pylons
#
$(PY25-PYLONS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pylons" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PYLONS_PRIORITY)" >>$@
	@echo "Section: $(PY-PYLONS_SECTION)" >>$@
	@echo "Version: $(PY-PYLONS_VERSION)-$(PY-PYLONS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PYLONS_MAINTAINER)" >>$@
	@echo "Source: $(PY-PYLONS_SITE)/$(PY-PYLONS_SOURCE)" >>$@
	@echo "Description: $(PY-PYLONS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PYLONS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PYLONS_CONFLICTS)" >>$@

$(PY26-PYLONS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-pylons" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PYLONS_PRIORITY)" >>$@
	@echo "Section: $(PY-PYLONS_SECTION)" >>$@
	@echo "Version: $(PY-PYLONS_VERSION)-$(PY-PYLONS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PYLONS_MAINTAINER)" >>$@
	@echo "Source: $(PY-PYLONS_SITE)/$(PY-PYLONS_SOURCE)" >>$@
	@echo "Description: $(PY-PYLONS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PYLONS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PYLONS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PYLONS_IPK_DIR)/opt/sbin or $(PY-PYLONS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PYLONS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PYLONS_IPK_DIR)/opt/etc/py-pylons/...
# Documentation files should be installed in $(PY-PYLONS_IPK_DIR)/opt/doc/py-pylons/...
# Daemon startup scripts should be installed in $(PY-PYLONS_IPK_DIR)/opt/etc/init.d/S??py-pylons
#
# You may need to patch your application to make it use these locations.
#
$(PY25-PYLONS_IPK): $(PY-PYLONS_BUILD_DIR)/.built
	rm -rf $(PY25-PYLONS_IPK_DIR) $(BUILD_DIR)/py2[45]-pylons_*_$(TARGET_ARCH).ipk
	cd $(PY-PYLONS_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-PYLONS_IPK_DIR) --prefix=/opt
#	$(STRIP_COMMAND) `find $(PY25-PYLONS_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`
	$(MAKE) $(PY25-PYLONS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PYLONS_IPK_DIR)

$(PY26-PYLONS_IPK): $(PY-PYLONS_BUILD_DIR)/.built
	rm -rf $(PY26-PYLONS_IPK_DIR) $(BUILD_DIR)/py26-pylons_*_$(TARGET_ARCH).ipk
	cd $(PY-PYLONS_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-PYLONS_IPK_DIR) --prefix=/opt
#	$(STRIP_COMMAND) `find $(PY26-PYLONS_IPK_DIR)/opt/lib/python2.6/site-packages -name '*.so'`
	$(MAKE) $(PY26-PYLONS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PYLONS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pylons-ipk: $(PY25-PYLONS_IPK) $(PY26-PYLONS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pylons-clean:
	-$(MAKE) -C $(PY-PYLONS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pylons-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PYLONS_DIR) $(PY-PYLONS_BUILD_DIR)
	rm -rf $(PY25-PYLONS_IPK_DIR) $(PY25-PYLONS_IPK)
	rm -rf $(PY26-PYLONS_IPK_DIR) $(PY26-PYLONS_IPK)

#
# Some sanity check for the package.
#
py-pylons-check: $(PY25-PYLONS_IPK) $(PY26-PYLONS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
