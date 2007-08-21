###########################################################
#
# py-turbogears
#
###########################################################

#
# PY-TURBOGEARS_VERSION, PY-TURBOGEARS_SITE and PY-TURBOGEARS_SOURCE define
# the upstream location of the source code for the package.
# PY-TURBOGEARS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TURBOGEARS_UNZIP is the command used to unzip the source.
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
PY-TURBOGEARS_SITE=http://files.turbogears.org/eggs
PY-TURBOGEARS_VERSION=1.0.3
PY-TURBOGEARS_IPK_VERSION=2
PY-TURBOGEARS_SOURCE=TurboGears-$(PY-TURBOGEARS_VERSION).tar.gz
PY-TURBOGEARS_DIR=TurboGears-$(PY-TURBOGEARS_VERSION)
PY-TURBOGEARS_UNZIP=zcat
PY-TURBOGEARS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TURBOGEARS_DESCRIPTION=Rapid web development megaframework in Python.
PY-TURBOGEARS_SECTION=misc
PY-TURBOGEARS_PRIORITY=optional

PY24-TURBOGEARS_DEPENDS=python24, \
	py-celementtree (>=1.0.5), \
	py-cherrypy (>=2.2.1), \
	py-configobj (>=4.3.2), \
	py-decoratortools (>=1.4), \
	py-elementtree (>=1.2.6), \
	py-formencode (>=0.7.1), \
	py-nose (>=0.9.1), \
	py-pastescript (>=0.9.7), \
	py-ruledispatch, \
	py-simplejson (>=1.3), \
	py-sqlobject (>=0.8), \
	py-turbocheetah (>=0.9.5), \
	py-turbojson (>=0.9.9), \
	py-turbokid (>=1.0.2), \
	findutils \

PY25-TURBOGEARS_DEPENDS=python25, \
	py25-cherrypy (>=2.2.1), \
	py25-configobj (>=4.3.2), \
	py25-decoratortools (>=1.4), \
	py25-elementtree (>=1.2.6), \
	py25-formencode (>=0.7.1), \
	py25-nose (>=0.9.1), \
	py25-pastescript (>=0.9.7), \
	py25-ruledispatch, \
	py25-simplejson (>=1.3), \
	py25-sqlobject (>=0.8), \
	py25-turbocheetah (>=0.9.5), \
	py25-turbojson (>=0.9.9), \
	py25-turbokid (>=1.0.2), \
	findutils \

PY-TURBOGEARS_CONFLICTS=


#
# PY-TURBOGEARS_CONFFILES should be a list of user-editable files
#PY-TURBOGEARS_CONFFILES=/opt/etc/py-turbogears.conf /opt/etc/init.d/SXXpy-turbogears

#
# PY-TURBOGEARS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TURBOGEARS_PATCHES=$(PY-TURBOGEARS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TURBOGEARS_CPPFLAGS=
PY-TURBOGEARS_LDFLAGS=

#
# PY-TURBOGEARS_BUILD_DIR is the directory in which the build is done.
# PY-TURBOGEARS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TURBOGEARS_IPK_DIR is the directory in which the ipk is built.
# PY-TURBOGEARS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TURBOGEARS_BUILD_DIR=$(BUILD_DIR)/py-turbogears
PY-TURBOGEARS_SOURCE_DIR=$(SOURCE_DIR)/py-turbogears

PY24-TURBOGEARS_IPK_DIR=$(BUILD_DIR)/py-turbogears-$(PY-TURBOGEARS_VERSION)-ipk
PY24-TURBOGEARS_IPK=$(BUILD_DIR)/py-turbogears_$(PY-TURBOGEARS_VERSION)-$(PY-TURBOGEARS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-TURBOGEARS_IPK_DIR=$(BUILD_DIR)/py25-turbogears-$(PY-TURBOGEARS_VERSION)-ipk
PY25-TURBOGEARS_IPK=$(BUILD_DIR)/py25-turbogears_$(PY-TURBOGEARS_VERSION)-$(PY-TURBOGEARS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-turbogears-source py-turbogears-unpack py-turbogears py-turbogears-stage py-turbogears-ipk py-turbogears-clean py-turbogears-dirclean py-turbogears-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TURBOGEARS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-TURBOGEARS_SITE)/$(PY-TURBOGEARS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-turbogears-source: $(DL_DIR)/$(PY-TURBOGEARS_SOURCE) $(PY-TURBOGEARS_PATCHES)

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
$(PY-TURBOGEARS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TURBOGEARS_SOURCE) $(PY-TURBOGEARS_PATCHES) make/py-turbogears.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-TURBOGEARS_BUILD_DIR)
	mkdir -p $(PY-TURBOGEARS_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-TURBOGEARS_DIR)
	$(PY-TURBOGEARS_UNZIP) $(DL_DIR)/$(PY-TURBOGEARS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TURBOGEARS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) $(PY-TURBOGEARS_BUILD_DIR)/2.4
	(cd $(PY-TURBOGEARS_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-TURBOGEARS_DIR)
	$(PY-TURBOGEARS_UNZIP) $(DL_DIR)/$(PY-TURBOGEARS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TURBOGEARS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) $(PY-TURBOGEARS_BUILD_DIR)/2.5
	(cd $(PY-TURBOGEARS_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-TURBOGEARS_BUILD_DIR)/.configured

py-turbogears-unpack: $(PY-TURBOGEARS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TURBOGEARS_BUILD_DIR)/.built: $(PY-TURBOGEARS_BUILD_DIR)/.configured
	rm -f $(PY-TURBOGEARS_BUILD_DIR)/.built
	(cd $(PY-TURBOGEARS_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-TURBOGEARS_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-TURBOGEARS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-turbogears: $(PY-TURBOGEARS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TURBOGEARS_BUILD_DIR)/.staged: $(PY-TURBOGEARS_BUILD_DIR)/.built
	rm -f $(PY-TURBOGEARS_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-TURBOGEARS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-TURBOGEARS_BUILD_DIR)/.staged

py-turbogears-stage: $(PY-TURBOGEARS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-turbogears
#
$(PY24-TURBOGEARS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-turbogears" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOGEARS_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOGEARS_SECTION)" >>$@
	@echo "Version: $(PY-TURBOGEARS_VERSION)-$(PY-TURBOGEARS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOGEARS_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOGEARS_SITE)/$(PY-TURBOGEARS_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOGEARS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-TURBOGEARS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOGEARS_CONFLICTS)" >>$@

$(PY25-TURBOGEARS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-turbogears" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOGEARS_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOGEARS_SECTION)" >>$@
	@echo "Version: $(PY-TURBOGEARS_VERSION)-$(PY-TURBOGEARS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOGEARS_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOGEARS_SITE)/$(PY-TURBOGEARS_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOGEARS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TURBOGEARS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOGEARS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TURBOGEARS_IPK_DIR)/opt/sbin or $(PY-TURBOGEARS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TURBOGEARS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TURBOGEARS_IPK_DIR)/opt/etc/py-turbogears/...
# Documentation files should be installed in $(PY-TURBOGEARS_IPK_DIR)/opt/doc/py-turbogears/...
# Daemon startup scripts should be installed in $(PY-TURBOGEARS_IPK_DIR)/opt/etc/init.d/S??py-turbogears
#
# You may need to patch your application to make it use these locations.
#
$(PY24-TURBOGEARS_IPK): $(PY-TURBOGEARS_BUILD_DIR)/.built
	rm -rf $(PY24-TURBOGEARS_IPK_DIR) $(BUILD_DIR)/py-turbogears_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOGEARS_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-TURBOGEARS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-TURBOGEARS_IPK_DIR)/CONTROL/control
	(echo '#!/bin/sh'; \
echo /opt/bin/find /opt/lib/python2.4/site-packages -maxdepth 1 -empty -type d -name \'*.egg-info\' -printf \"rmdir %p\\n\" -exec rmdir {} + ; \
	) > $(PY24-TURBOGEARS_IPK_DIR)/CONTROL/postinst
	echo $(PY-TURBOGEARS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-TURBOGEARS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-TURBOGEARS_IPK_DIR)

$(PY25-TURBOGEARS_IPK): $(PY-TURBOGEARS_BUILD_DIR)/.built
	rm -rf $(PY25-TURBOGEARS_IPK_DIR) $(BUILD_DIR)/py25-turbogears_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOGEARS_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-TURBOGEARS_IPK_DIR) --prefix=/opt)
	for f in $(PY25-TURBOGEARS_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-TURBOGEARS_IPK_DIR)/CONTROL/control
	(echo '#!/bin/sh'; \
echo /opt/bin/find /opt/lib/python2.5/site-packages -maxdepth 1 -empty -type d -name \'*.egg-info\' -printf \"rmdir %p\\n\" -exec rmdir {} + ; \
	) > $(PY25-TURBOGEARS_IPK_DIR)/CONTROL/postinst
	echo $(PY-TURBOGEARS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-TURBOGEARS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-TURBOGEARS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-turbogears-ipk: $(PY24-TURBOGEARS_IPK) $(PY25-TURBOGEARS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-turbogears-clean:
	-$(MAKE) -C $(PY-TURBOGEARS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-turbogears-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) $(PY-TURBOGEARS_BUILD_DIR)
	rm -rf $(PY24-TURBOGEARS_IPK_DIR) $(PY24-TURBOGEARS_IPK)
	rm -rf $(PY25-TURBOGEARS_IPK_DIR) $(PY25-TURBOGEARS_IPK)

#
# Some sanity check for the package.
#
py-turbogears-check: $(PY24-TURBOGEARS_IPK) $(PY25-TURBOGEARS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-TURBOGEARS_IPK) $(PY25-TURBOGEARS_IPK)
