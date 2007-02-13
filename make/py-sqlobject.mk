###########################################################
#
# py-sqlobject
#
###########################################################

#
# PY-SQLOBJECT_VERSION, PY-SQLOBJECT_SITE and PY-SQLOBJECT_SOURCE define
# the upstream location of the source code for the package.
# PY-SQLOBJECT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SQLOBJECT_UNZIP is the command used to unzip the source.
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
# PY-SQLOBJECT_IPK_VERSION should be incremented when the ipk changes.
#
PY-SQLOBJECT_SITE=http://cheeseshop.python.org/packages/source/S/SQLObject
#PY-SQLOBJECT_SVN_REV=1675
#ifneq ($(PY-SQLOBJECT_SVN_REV),)
#PY-SQLOBJECT_ ### VERSION=0.8dev_r1675
#else
PY-SQLOBJECT_VERSION=0.8.0
PY-SQLOBJECT_SOURCE=SQLObject-$(PY-SQLOBJECT_VERSION).tar.gz
#endif
PY-SQLOBJECT_DIR=SQLObject-$(PY-SQLOBJECT_VERSION)
PY-SQLOBJECT_UNZIP=zcat
PY-SQLOBJECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SQLOBJECT_DESCRIPTION=An object-relational mapper for python.
PY-SQLOBJECT_SECTION=misc
PY-SQLOBJECT_PRIORITY=optional
PY24-SQLOBJECT_DEPENDS=python24, py-formencode
PY25-SQLOBJECT_DEPENDS=python25, py25-formencode
PY24-SQLOBJECT_SUGGESTS=py-sqlite, py-psycopg2, py-mysql
PY25-SQLOBJECT_SUGGESTS=py25-psycopg2, py25-mysql
PY-SQLOBJECT_CONFLICTS=

PY-SQLOBJECT_IPK_VERSION=1

#
# PY-SQLOBJECT_CONFFILES should be a list of user-editable files
#PY-SQLOBJECT_CONFFILES=/opt/etc/py-sqlobject.conf /opt/etc/init.d/SXXpy-sqlobject

#
# PY-SQLOBJECT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SQLOBJECT_PATCHES=$(PY-SQLOBJECT_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SQLOBJECT_CPPFLAGS=
PY-SQLOBJECT_LDFLAGS=

#
# PY-SQLOBJECT_BUILD_DIR is the directory in which the build is done.
# PY-SQLOBJECT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SQLOBJECT_IPK_DIR is the directory in which the ipk is built.
# PY-SQLOBJECT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SQLOBJECT_BUILD_DIR=$(BUILD_DIR)/py-sqlobject
PY-SQLOBJECT_SOURCE_DIR=$(SOURCE_DIR)/py-sqlobject

PY24-SQLOBJECT_IPK_DIR=$(BUILD_DIR)/py-sqlobject-$(PY-SQLOBJECT_VERSION)-ipk
PY24-SQLOBJECT_IPK=$(BUILD_DIR)/py-sqlobject_$(PY-SQLOBJECT_VERSION)-$(PY-SQLOBJECT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-SQLOBJECT_IPK_DIR=$(BUILD_DIR)/py25-sqlobject-$(PY-SQLOBJECT_VERSION)-ipk
PY25-SQLOBJECT_IPK=$(BUILD_DIR)/py25-sqlobject_$(PY-SQLOBJECT_VERSION)-$(PY-SQLOBJECT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-sqlobject-source py-sqlobject-unpack py-sqlobject py-sqlobject-stage py-sqlobject-ipk py-sqlobject-clean py-sqlobject-dirclean py-sqlobject-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-SQLOBJECT_SVN_REV),)
$(DL_DIR)/$(PY-SQLOBJECT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SQLOBJECT_SITE)/$(PY-SQLOBJECT_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-sqlobject-source: $(DL_DIR)/$(PY-SQLOBJECT_SOURCE) $(PY-SQLOBJECT_PATCHES)

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
ifeq ($(PY-SQLOBJECT_SVN_REV),)
$(PY-SQLOBJECT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SQLOBJECT_SOURCE) $(PY-SQLOBJECT_PATCHES) make/py-sqlobject.mk
else
$(PY-SQLOBJECT_BUILD_DIR)/.configured: $(PY-SQLOBJECT_PATCHES) make/py-sqlobject.mk
endif
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-SQLOBJECT_BUILD_DIR)
	mkdir -p $(PY-SQLOBJECT_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-SQLOBJECT_DIR)
ifeq ($(PY-SQLOBJECT_SVN_REV),)
	$(PY-SQLOBJECT_UNZIP) $(DL_DIR)/$(PY-SQLOBJECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-SQLOBJECT_SVN_REV) http://svn.colorstudy.com/SQLObject/trunk $(PY-SQLOBJECT_DIR); \
	)
endif
	if test -n "$(PY-SQLOBJECT_PATCHES)" ; then \
	    cat $(PY-SQLOBJECT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) $(PY-SQLOBJECT_BUILD_DIR)/2.4
	(cd $(PY-SQLOBJECT_BUILD_DIR); \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-SQLOBJECT_DIR)
ifeq ($(PY-SQLOBJECT_SVN_REV),)
	$(PY-SQLOBJECT_UNZIP) $(DL_DIR)/$(PY-SQLOBJECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-SQLOBJECT_SVN_REV) http://svn.colorstudy.com/SQLObject/trunk $(PY-SQLOBJECT_DIR); \
	)
endif
	if test -n "$(PY-SQLOBJECT_PATCHES)" ; then \
	    cat $(PY-SQLOBJECT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) $(PY-SQLOBJECT_BUILD_DIR)/2.5
	(cd $(PY-SQLOBJECT_BUILD_DIR); \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-SQLOBJECT_BUILD_DIR)/.configured

py-sqlobject-unpack: $(PY-SQLOBJECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SQLOBJECT_BUILD_DIR)/.built: $(PY-SQLOBJECT_BUILD_DIR)/.configured
	rm -f $(PY-SQLOBJECT_BUILD_DIR)/.built
	(cd $(PY-SQLOBJECT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" build)
	(cd $(PY-SQLOBJECT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" build)
	touch $(PY-SQLOBJECT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-sqlobject: $(PY-SQLOBJECT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SQLOBJECT_BUILD_DIR)/.staged: $(PY-SQLOBJECT_BUILD_DIR)/.built
	rm -f $(PY-SQLOBJECT_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-SQLOBJECT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-SQLOBJECT_BUILD_DIR)/.staged

py-sqlobject-stage: $(PY-SQLOBJECT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-sqlobject
#
$(PY24-SQLOBJECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-sqlobject" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SQLOBJECT_PRIORITY)" >>$@
	@echo "Section: $(PY-SQLOBJECT_SECTION)" >>$@
	@echo "Version: $(PY-SQLOBJECT_VERSION)-$(PY-SQLOBJECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SQLOBJECT_MAINTAINER)" >>$@
	@echo "Source: $(PY-SQLOBJECT_SITE)/$(PY-SQLOBJECT_SOURCE)" >>$@
	@echo "Description: $(PY-SQLOBJECT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-SQLOBJECT_DEPENDS)" >>$@
	@echo "Suggests: $(PY24-SQLOBJECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-SQLOBJECT_CONFLICTS)" >>$@

$(PY25-SQLOBJECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-sqlobject" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SQLOBJECT_PRIORITY)" >>$@
	@echo "Section: $(PY-SQLOBJECT_SECTION)" >>$@
	@echo "Version: $(PY-SQLOBJECT_VERSION)-$(PY-SQLOBJECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SQLOBJECT_MAINTAINER)" >>$@
	@echo "Source: $(PY-SQLOBJECT_SITE)/$(PY-SQLOBJECT_SOURCE)" >>$@
	@echo "Description: $(PY-SQLOBJECT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SQLOBJECT_DEPENDS)" >>$@
	@echo "Suggests: $(PY25-SQLOBJECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-SQLOBJECT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SQLOBJECT_IPK_DIR)/opt/sbin or $(PY-SQLOBJECT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SQLOBJECT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SQLOBJECT_IPK_DIR)/opt/etc/py-sqlobject/...
# Documentation files should be installed in $(PY-SQLOBJECT_IPK_DIR)/opt/doc/py-sqlobject/...
# Daemon startup scripts should be installed in $(PY-SQLOBJECT_IPK_DIR)/opt/etc/init.d/S??py-sqlobject
#
# You may need to patch your application to make it use these locations.
#
$(PY24-SQLOBJECT_IPK): $(PY-SQLOBJECT_BUILD_DIR)/.built
	rm -rf $(PY24-SQLOBJECT_IPK_DIR) $(BUILD_DIR)/py-sqlobject_*_$(TARGET_ARCH).ipk
	(cd $(PY-SQLOBJECT_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
		--root=$(PY24-SQLOBJECT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-SQLOBJECT_IPK_DIR)/CONTROL/control
#	echo $(PY-SQLOBJECT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-SQLOBJECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-SQLOBJECT_IPK_DIR)

$(PY25-SQLOBJECT_IPK): $(PY-SQLOBJECT_BUILD_DIR)/.built
	rm -rf $(PY25-SQLOBJECT_IPK_DIR) $(BUILD_DIR)/py25-sqlobject_*_$(TARGET_ARCH).ipk
	(cd $(PY-SQLOBJECT_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
		--root=$(PY25-SQLOBJECT_IPK_DIR) --prefix=/opt)
	for f in $(PY25-SQLOBJECT_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-SQLOBJECT_IPK_DIR)/CONTROL/control
#	echo $(PY-SQLOBJECT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SQLOBJECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SQLOBJECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-sqlobject-ipk: $(PY24-SQLOBJECT_IPK) $(PY25-SQLOBJECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-sqlobject-clean:
	-$(MAKE) -C $(PY-SQLOBJECT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-sqlobject-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) $(PY-SQLOBJECT_BUILD_DIR)
	rm -rf $(PY24-SQLOBJECT_IPK_DIR) $(PY24-SQLOBJECT_IPK)
	rm -rf $(PY25-SQLOBJECT_IPK_DIR) $(PY25-SQLOBJECT_IPK)

#
# Some sanity check for the package.
#
py-sqlobject-check: $(PY24-SQLOBJECT_IPK) $(PY25-SQLOBJECT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-SQLOBJECT_IPK) $(PY25-SQLOBJECT_IPK)
