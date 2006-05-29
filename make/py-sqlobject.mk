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
PY-SQLOBJECT_VERSION=0.7.1b1
PY-SQLOBJECT_SOURCE=SQLObject-$(PY-SQLOBJECT_VERSION).tar.gz
#endif
PY-SQLOBJECT_DIR=SQLObject-$(PY-SQLOBJECT_VERSION)
PY-SQLOBJECT_UNZIP=zcat
PY-SQLOBJECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SQLOBJECT_DESCRIPTION=An object-relational mapper for python.
PY-SQLOBJECT_SECTION=misc
PY-SQLOBJECT_PRIORITY=optional
PY-SQLOBJECT_DEPENDS=python, py-formencode
PY-SQLOBJECT_SUGGESTS=py-sqlite, py-psycopg, py-mysql
PY-SQLOBJECT_CONFLICTS=

PY-SQLOBJECT_IPK_VERSION=2

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
PY-SQLOBJECT_IPK_DIR=$(BUILD_DIR)/py-sqlobject-$(PY-SQLOBJECT_VERSION)-ipk
PY-SQLOBJECT_IPK=$(BUILD_DIR)/py-sqlobject_$(PY-SQLOBJECT_VERSION)-$(PY-SQLOBJECT_IPK_VERSION)_$(TARGET_ARCH).ipk

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
	rm -rf $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) $(PY-SQLOBJECT_BUILD_DIR)
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
	mv $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) $(PY-SQLOBJECT_BUILD_DIR)
	(cd $(PY-SQLOBJECT_BUILD_DIR); \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-SQLOBJECT_BUILD_DIR)/.configured

py-sqlobject-unpack: $(PY-SQLOBJECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SQLOBJECT_BUILD_DIR)/.built: $(PY-SQLOBJECT_BUILD_DIR)/.configured
	rm -f $(PY-SQLOBJECT_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-SQLOBJECT_BUILD_DIR)
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
$(PY-SQLOBJECT_IPK_DIR)/CONTROL/control:
	@install -d $(PY-SQLOBJECT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-sqlobject" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SQLOBJECT_PRIORITY)" >>$@
	@echo "Section: $(PY-SQLOBJECT_SECTION)" >>$@
	@echo "Version: $(PY-SQLOBJECT_VERSION)-$(PY-SQLOBJECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SQLOBJECT_MAINTAINER)" >>$@
	@echo "Source: $(PY-SQLOBJECT_SITE)/$(PY-SQLOBJECT_SOURCE)" >>$@
	@echo "Description: $(PY-SQLOBJECT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-SQLOBJECT_DEPENDS)" >>$@
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
$(PY-SQLOBJECT_IPK): $(PY-SQLOBJECT_BUILD_DIR)/.built
	rm -rf $(PY-SQLOBJECT_IPK_DIR) $(BUILD_DIR)/py-sqlobject_*_$(TARGET_ARCH).ipk
	(cd $(PY-SQLOBJECT_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 -c "import setuptools; execfile('setup.py')" install \
	--root=$(PY-SQLOBJECT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY-SQLOBJECT_IPK_DIR)/CONTROL/control
#	echo $(PY-SQLOBJECT_CONFFILES) | sed -e 's/ /\n/g' > $(PY-SQLOBJECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-SQLOBJECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-sqlobject-ipk: $(PY-SQLOBJECT_IPK)

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
	rm -rf $(BUILD_DIR)/$(PY-SQLOBJECT_DIR) $(PY-SQLOBJECT_BUILD_DIR) $(PY-SQLOBJECT_IPK_DIR) $(PY-SQLOBJECT_IPK)
