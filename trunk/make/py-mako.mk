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
PY-MAKO_VERSION=0.2.4
PY-MAKO_IPK_VERSION=1
PY-MAKO_SOURCE=Mako-$(PY-MAKO_VERSION).tar.gz
PY-MAKO_DIR=Mako-$(PY-MAKO_VERSION)
PY-MAKO_UNZIP=zcat
PY-MAKO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MAKO_DESCRIPTION=Mako is a template library written in Python.
PY-MAKO_SECTION=misc
PY-MAKO_PRIORITY=optional
PY24-MAKO_DEPENDS=python24, py24-beaker
PY25-MAKO_DEPENDS=python25, py25-beaker
PY26-MAKO_DEPENDS=python26, py26-beaker
PY-MAKO_SUGGESTS=
PY-MAKO_CONFLICTS=


#
# PY-MAKO_CONFFILES should be a list of user-editable files
#PY-MAKO_CONFFILES=/opt/etc/py-mako.conf /opt/etc/init.d/SXXpy-mako

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
PY-MAKO_SOURCE_DIR=$(SOURCE_DIR)/py-mako

PY24-MAKO_IPK_DIR=$(BUILD_DIR)/py24-mako-$(PY-MAKO_VERSION)-ipk
PY24-MAKO_IPK=$(BUILD_DIR)/py24-mako_$(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MAKO_IPK_DIR=$(BUILD_DIR)/py25-mako-$(PY-MAKO_VERSION)-ipk
PY25-MAKO_IPK=$(BUILD_DIR)/py25-mako_$(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-MAKO_IPK_DIR=$(BUILD_DIR)/py26-mako-$(PY-MAKO_VERSION)-ipk
PY26-MAKO_IPK=$(BUILD_DIR)/py26-mako_$(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mako-source py-mako-unpack py-mako py-mako-stage py-mako-ipk py-mako-clean py-mako-dirclean py-mako-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MAKO_SOURCE):
	$(WGET) -P $(@D) $(PY-MAKO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mako-source: $(DL_DIR)/$(PY-MAKO_SOURCE) $(PY-MAKO_PATCHES)

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
$(PY-MAKO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MAKO_SOURCE) $(PY-MAKO_PATCHES) make/py-mako.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MAKO_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MAKO_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-MAKO_DIR)
	$(PY-MAKO_UNZIP) $(DL_DIR)/$(PY-MAKO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MAKO_PATCHES)" ; then \
	    cat $(PY-MAKO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MAKO_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MAKO_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.6") >> setup.cfg \
	)
	touch $@

py-mako-unpack: $(PY-MAKO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MAKO_BUILD_DIR)/.built: $(PY-MAKO_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
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
py-mako: $(PY-MAKO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MAKO_BUILD_DIR)/.staged: $(PY-MAKO_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-mako-stage: $(PY-MAKO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mako
#
$(PY24-MAKO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-mako" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MAKO_PRIORITY)" >>$@
	@echo "Section: $(PY-MAKO_SECTION)" >>$@
	@echo "Version: $(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MAKO_MAINTAINER)" >>$@
	@echo "Source: $(PY-MAKO_SITE)/$(PY-MAKO_SOURCE)" >>$@
	@echo "Description: $(PY-MAKO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-MAKO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MAKO_CONFLICTS)" >>$@

$(PY25-MAKO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-mako" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MAKO_PRIORITY)" >>$@
	@echo "Section: $(PY-MAKO_SECTION)" >>$@
	@echo "Version: $(PY-MAKO_VERSION)-$(PY-MAKO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MAKO_MAINTAINER)" >>$@
	@echo "Source: $(PY-MAKO_SITE)/$(PY-MAKO_SOURCE)" >>$@
	@echo "Description: $(PY-MAKO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MAKO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MAKO_CONFLICTS)" >>$@

$(PY26-MAKO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MAKO_IPK_DIR)/opt/sbin or $(PY-MAKO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MAKO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MAKO_IPK_DIR)/opt/etc/py-mako/...
# Documentation files should be installed in $(PY-MAKO_IPK_DIR)/opt/doc/py-mako/...
# Daemon startup scripts should be installed in $(PY-MAKO_IPK_DIR)/opt/etc/init.d/S??py-mako
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(PY24-MAKO_IPK_DIR) $(BUILD_DIR)/py24-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-MAKO_IPK_DIR) --prefix=/opt)
	for f in $(PY24-MAKO_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MAKO_IPK_DIR)

$(PY25-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(PY25-MAKO_IPK_DIR) $(BUILD_DIR)/py25-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MAKO_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MAKO_IPK_DIR)

$(PY26-MAKO_IPK): $(PY-MAKO_BUILD_DIR)/.built
	rm -rf $(PY26-MAKO_IPK_DIR) $(BUILD_DIR)/py26-mako_*_$(TARGET_ARCH).ipk
	(cd $(PY-MAKO_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-MAKO_IPK_DIR) --prefix=/opt)
	for f in $(PY26-MAKO_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.6|'`; done
	$(MAKE) $(PY26-MAKO_IPK_DIR)/CONTROL/control
#	echo $(PY-MAKO_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-MAKO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-MAKO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mako-ipk: $(PY24-MAKO_IPK) $(PY25-MAKO_IPK) $(PY26-MAKO_IPK)

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
	rm -rf $(PY24-MAKO_IPK_DIR) $(PY24-MAKO_IPK)
	rm -rf $(PY25-MAKO_IPK_DIR) $(PY25-MAKO_IPK)
	rm -rf $(PY26-MAKO_IPK_DIR) $(PY26-MAKO_IPK)

#
# Some sanity check for the package.
#
py-mako-check: $(PY24-MAKO_IPK) $(PY25-MAKO_IPK) $(PY26-MAKO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) \
		$(PY24-MAKO_IPK) $(PY25-MAKO_IPK) $(PY26-MAKO_IPK)
