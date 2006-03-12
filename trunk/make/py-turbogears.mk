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
PY-TURBOGEARS_SITE=http://turbogears.org/download/eggs
PY-TURBOGEARS_VERSION=0.8.9
PY-TURBOGEARS_SOURCE=TurboGears-$(PY-TURBOGEARS_VERSION).tar.gz
PY-TURBOGEARS_DIR=TurboGears-$(PY-TURBOGEARS_VERSION)
PY-TURBOGEARS_UNZIP=zcat
PY-TURBOGEARS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-TURBOGEARS_DESCRIPTION=Rapid web development megaframework in Python.
PY-TURBOGEARS_SECTION=misc
PY-TURBOGEARS_PRIORITY=optional
PY-TURBOGEARS_DEPENDS=python, py-kid (>=0.8), py-cherrypy (>=2.1.1), py-sqlobject (>=0.8dev1457), py-json (>=3.4), py-elementtree (>=1.2.6), py-celementtree (>=1.0.2), py-formencode (>=0.4), py-testgears (>=0.2)
PY-TURBOGEARS_CONFLICTS=

#
# PY-TURBOGEARS_IPK_VERSION should be incremented when the ipk changes.
#
PY-TURBOGEARS_IPK_VERSION=3

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
PY-TURBOGEARS_IPK_DIR=$(BUILD_DIR)/py-turbogears-$(PY-TURBOGEARS_VERSION)-ipk
PY-TURBOGEARS_IPK=$(BUILD_DIR)/py-turbogears_$(PY-TURBOGEARS_VERSION)-$(PY-TURBOGEARS_IPK_VERSION)_$(TARGET_ARCH).ipk

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
	rm -rf $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) $(PY-TURBOGEARS_BUILD_DIR)
	$(PY-TURBOGEARS_UNZIP) $(DL_DIR)/$(PY-TURBOGEARS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TURBOGEARS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) $(PY-TURBOGEARS_BUILD_DIR)
	(cd $(PY-TURBOGEARS_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-TURBOGEARS_BUILD_DIR)/.configured

py-turbogears-unpack: $(PY-TURBOGEARS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TURBOGEARS_BUILD_DIR)/.built: $(PY-TURBOGEARS_BUILD_DIR)/.configured
	rm -f $(PY-TURBOGEARS_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-TURBOGEARS_BUILD_DIR)
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
$(PY-TURBOGEARS_IPK_DIR)/CONTROL/control:
	@install -d $(PY-TURBOGEARS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-turbogears" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOGEARS_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOGEARS_SECTION)" >>$@
	@echo "Version: $(PY-TURBOGEARS_VERSION)-$(PY-TURBOGEARS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOGEARS_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOGEARS_SITE)/$(PY-TURBOGEARS_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOGEARS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-TURBOGEARS_DEPENDS)" >>$@
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
$(PY-TURBOGEARS_IPK): $(PY-TURBOGEARS_BUILD_DIR)/.built
	rm -rf $(PY-TURBOGEARS_IPK_DIR) $(BUILD_DIR)/py-turbogears_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOGEARS_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-TURBOGEARS_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-TURBOGEARS_IPK_DIR)/CONTROL/control
	echo $(PY-TURBOGEARS_CONFFILES) | sed -e 's/ /\n/g' > $(PY-TURBOGEARS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-TURBOGEARS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-turbogears-ipk: $(PY-TURBOGEARS_IPK)

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
	rm -rf $(BUILD_DIR)/$(PY-TURBOGEARS_DIR) $(PY-TURBOGEARS_BUILD_DIR) $(PY-TURBOGEARS_IPK_DIR) $(PY-TURBOGEARS_IPK)
