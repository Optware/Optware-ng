###########################################################
#
# py-routes
#
###########################################################

#
# PY-ROUTES_VERSION, PY-ROUTES_SITE and PY-ROUTES_SOURCE define
# the upstream location of the source code for the package.
# PY-ROUTES_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ROUTES_UNZIP is the command used to unzip the source.
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
# PY-ROUTES_IPK_VERSION should be incremented when the ipk changes.
#
PY-ROUTES_SITE=http://pypi.python.org/packages/source/R/Routes
PY-ROUTES_VERSION=1.12.3
PY-ROUTES_IPK_VERSION=1
PY-ROUTES_SOURCE=Routes-$(PY-ROUTES_VERSION).tar.gz
PY-ROUTES_DIR=Routes-$(PY-ROUTES_VERSION)
PY-ROUTES_UNZIP=zcat
PY-ROUTES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ROUTES_DESCRIPTION=Routing Recognition and Generation Tools.
PY-ROUTES_SECTION=misc
PY-ROUTES_PRIORITY=optional
PY25-ROUTES_DEPENDS=python25
PY26-ROUTES_DEPENDS=python26
PY-ROUTES_SUGGESTS=
PY-ROUTES_CONFLICTS=

#
# PY-ROUTES_CONFFILES should be a list of user-editable files
#PY-ROUTES_CONFFILES=/opt/etc/py-routes.conf /opt/etc/init.d/SXXpy-routes

#
# PY-ROUTES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ROUTES_PATCHES=$(PY-ROUTES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ROUTES_CPPFLAGS=
PY-ROUTES_LDFLAGS=

#
# PY-ROUTES_BUILD_DIR is the directory in which the build is done.
# PY-ROUTES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ROUTES_IPK_DIR is the directory in which the ipk is built.
# PY-ROUTES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ROUTES_BUILD_DIR=$(BUILD_DIR)/py-routes
PY-ROUTES_SOURCE_DIR=$(SOURCE_DIR)/py-routes

PY25-ROUTES_IPK_DIR=$(BUILD_DIR)/py25-routes-$(PY-ROUTES_VERSION)-ipk
PY25-ROUTES_IPK=$(BUILD_DIR)/py25-routes_$(PY-ROUTES_VERSION)-$(PY-ROUTES_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-ROUTES_IPK_DIR=$(BUILD_DIR)/py26-routes-$(PY-ROUTES_VERSION)-ipk
PY26-ROUTES_IPK=$(BUILD_DIR)/py26-routes_$(PY-ROUTES_VERSION)-$(PY-ROUTES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-routes-source py-routes-unpack py-routes py-routes-stage py-routes-ipk py-routes-clean py-routes-dirclean py-routes-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ROUTES_SOURCE):
	$(WGET) -P $(@D) $(PY-ROUTES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-routes-source: $(DL_DIR)/$(PY-ROUTES_SOURCE) $(PY-ROUTES_PATCHES)

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
$(PY-ROUTES_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ROUTES_SOURCE) $(PY-ROUTES_PATCHES) make/py-routes.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-ROUTES_DIR)
	$(PY-ROUTES_UNZIP) $(DL_DIR)/$(PY-ROUTES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-ROUTES_PATCHES)" ; then \
	    cat $(PY-ROUTES_PATCHES) | patch -d $(BUILD_DIR)/$(PY-ROUTES_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-ROUTES_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-ROUTES_DIR)
	$(PY-ROUTES_UNZIP) $(DL_DIR)/$(PY-ROUTES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-ROUTES_PATCHES)" ; then \
	    cat $(PY-ROUTES_PATCHES) | patch -d $(BUILD_DIR)/$(PY-ROUTES_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-ROUTES_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.6") >> setup.cfg \
	)
	touch $@

py-routes-unpack: $(PY-ROUTES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ROUTES_BUILD_DIR)/.built: $(PY-ROUTES_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-routes: $(PY-ROUTES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-ROUTES_BUILD_DIR)/.staged: $(PY-ROUTES_BUILD_DIR)/.built
#	rm -f $(PY-ROUTES_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-ROUTES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(PY-ROUTES_BUILD_DIR)/.staged

#py-routes-stage: $(PY-ROUTES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-routes
#
$(PY25-ROUTES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-routes" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ROUTES_PRIORITY)" >>$@
	@echo "Section: $(PY-ROUTES_SECTION)" >>$@
	@echo "Version: $(PY-ROUTES_VERSION)-$(PY-ROUTES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ROUTES_MAINTAINER)" >>$@
	@echo "Source: $(PY-ROUTES_SITE)/$(PY-ROUTES_SOURCE)" >>$@
	@echo "Description: $(PY-ROUTES_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-ROUTES_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ROUTES_CONFLICTS)" >>$@

$(PY26-ROUTES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-routes" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ROUTES_PRIORITY)" >>$@
	@echo "Section: $(PY-ROUTES_SECTION)" >>$@
	@echo "Version: $(PY-ROUTES_VERSION)-$(PY-ROUTES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ROUTES_MAINTAINER)" >>$@
	@echo "Source: $(PY-ROUTES_SITE)/$(PY-ROUTES_SOURCE)" >>$@
	@echo "Description: $(PY-ROUTES_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-ROUTES_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ROUTES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ROUTES_IPK_DIR)/opt/sbin or $(PY-ROUTES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ROUTES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-ROUTES_IPK_DIR)/opt/etc/py-routes/...
# Documentation files should be installed in $(PY-ROUTES_IPK_DIR)/opt/doc/py-routes/...
# Daemon startup scripts should be installed in $(PY-ROUTES_IPK_DIR)/opt/etc/init.d/S??py-routes
#
# You may need to patch your application to make it use these locations.
#
$(PY25-ROUTES_IPK): $(PY-ROUTES_BUILD_DIR)/.built
	rm -rf $(PY25-ROUTES_IPK_DIR) $(BUILD_DIR)/py25-routes_*_$(TARGET_ARCH).ipk
	(cd $(PY-ROUTES_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install\
		--root=$(PY25-ROUTES_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-ROUTES_IPK_DIR)/CONTROL/control
#	echo $(PY-ROUTES_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-ROUTES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-ROUTES_IPK_DIR)

$(PY26-ROUTES_IPK): $(PY-ROUTES_BUILD_DIR)/.built
	rm -rf $(PY26-ROUTES_IPK_DIR) $(BUILD_DIR)/py26-routes_*_$(TARGET_ARCH).ipk
	(cd $(PY-ROUTES_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install\
		--root=$(PY26-ROUTES_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY26-ROUTES_IPK_DIR)/CONTROL/control
#	echo $(PY-ROUTES_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-ROUTES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-ROUTES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-routes-ipk: $(PY25-ROUTES_IPK) $(PY26-ROUTES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-routes-clean:
	-$(MAKE) -C $(PY-ROUTES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-routes-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ROUTES_DIR) $(PY-ROUTES_BUILD_DIR)
	rm -rf $(PY25-ROUTES_IPK_DIR) $(PY25-ROUTES_IPK)
	rm -rf $(PY26-ROUTES_IPK_DIR) $(PY26-ROUTES_IPK)

#
# Some sanity check for the package.
#
py-routes-check: $(PY25-ROUTES_IPK) $(PY26-ROUTES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
