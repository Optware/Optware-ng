###########################################################
#
# py-json
#
###########################################################

#
# PY-JSON_VERSION, PY-JSON_SITE and PY-JSON_SOURCE define
# the upstream location of the source code for the package.
# PY-JSON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-JSON_UNZIP is the command used to unzip the source.
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
PY-JSON_VERSION=3.4
PY-JSON_SITE=http://turbogears.org/download/eggs
#PY-JSON_SITE=http://dl.sourceforge.net/sourceforge/json-py
#PY-JSON_SOURCE=json-py-3_4.zip
# ok, we cheat here: this egg is platform independent already
PY-JSON_EGG=json_py-$(PY-JSON_VERSION)-py2.4.egg
PY-JSON_DIR=py-json-$(PY-JSON_VERSION)
PY-JSON_UNZIP=unzip
PY-JSON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-JSON_DESCRIPTION=An implementation of a JSON (http://json.org) reader and writer in Python.
PY-JSON_SECTION=misc
PY-JSON_PRIORITY=optional
PY-JSON_DEPENDS=python
PY-JSON_CONFLICTS=

#
# PY-JSON_IPK_VERSION should be incremented when the ipk changes.
#
PY-JSON_IPK_VERSION=1

#
# PY-JSON_CONFFILES should be a list of user-editable files
#PY-JSON_CONFFILES=/opt/etc/py-json.conf /opt/etc/init.d/SXXpy-json

#
# PY-JSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-JSON_PATCHES=$(PY-JSON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-JSON_CPPFLAGS=
PY-JSON_LDFLAGS=

#
# PY-JSON_BUILD_DIR is the directory in which the build is done.
# PY-JSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-JSON_IPK_DIR is the directory in which the ipk is built.
# PY-JSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-JSON_BUILD_DIR=$(BUILD_DIR)/py-json
PY-JSON_SOURCE_DIR=$(SOURCE_DIR)/py-json
PY-JSON_IPK_DIR=$(BUILD_DIR)/py-json-$(PY-JSON_VERSION)-ipk
PY-JSON_IPK=$(BUILD_DIR)/py-json_$(PY-JSON_VERSION)-$(PY-JSON_IPK_VERSION)_$(TARGET_ARCH).ipk
PY-JSON_PYLIBDIR=$(PY-JSON_IPK_DIR)/opt/lib/python2.4/site-packages

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-JSON_EGG):
	$(WGET) -P $(DL_DIR) $(PY-JSON_SITE)/$(PY-JSON_EGG)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-json-source: $(DL_DIR)/$(PY-JSON_EGG) $(PY-JSON_PATCHES)

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
$(PY-JSON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-JSON_EGG) $(PY-JSON_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-JSON_DIR) $(PY-JSON_BUILD_DIR)
	cd $(BUILD_DIR) && $(PY-JSON_UNZIP) -d $(PY-JSON_BUILD_DIR) $(DL_DIR)/$(PY-JSON_EGG)
#	cat $(PY-JSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-JSON_DIR) -p1
#	mv $(BUILD_DIR)/$(PY-JSON_DIR) $(PY-JSON_BUILD_DIR)
#	(cd $(PY-JSON_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-JSON_BUILD_DIR)/.configured

py-json-unpack: $(PY-JSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-JSON_BUILD_DIR)/.built: $(PY-JSON_BUILD_DIR)/.configured
	rm -f $(PY-JSON_BUILD_DIR)/.built
#	cd $(PY-JSON_BUILD_DIR) &&  python2.4 setup.py build
	touch $(PY-JSON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-json: $(PY-JSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-JSON_BUILD_DIR)/.staged: $(PY-JSON_BUILD_DIR)/.built
	rm -f $(PY-JSON_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-JSON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-JSON_BUILD_DIR)/.staged

py-json-stage: $(PY-JSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-json
#
$(PY-JSON_IPK_DIR)/CONTROL/control:
	@install -d $(PY-JSON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-json" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-JSON_PRIORITY)" >>$@
	@echo "Section: $(PY-JSON_SECTION)" >>$@
	@echo "Version: $(PY-JSON_VERSION)-$(PY-JSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-JSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-JSON_SITE)/$(PY-JSON_EGG)" >>$@
	@echo "Description: $(PY-JSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-JSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-JSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-JSON_IPK_DIR)/opt/sbin or $(PY-JSON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-JSON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-JSON_IPK_DIR)/opt/etc/py-json/...
# Documentation files should be installed in $(PY-JSON_IPK_DIR)/opt/doc/py-json/...
# Daemon startup scripts should be installed in $(PY-JSON_IPK_DIR)/opt/etc/init.d/S??py-json
#
# You may need to patch your application to make it use these locations.
#
$(PY-JSON_IPK): $(PY-JSON_BUILD_DIR)/.built
	rm -rf $(PY-JSON_IPK_DIR) $(BUILD_DIR)/py-json_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-JSON_BUILD_DIR) DESTDIR=$(PY-JSON_IPK_DIR) install
#	(cd $(PY-JSON_BUILD_DIR); \
		python2.4 setup.py install --root=$(PY-JSON_IPK_DIR) --prefix=/opt)
	install -d $(PY-JSON_PYLIBDIR)
	install $(PY-JSON_BUILD_DIR)/*.py* $(PY-JSON_PYLIBDIR)
	install -d $(PY-JSON_PYLIBDIR)/$(PY-JSON_EGG)-info
	install $(PY-JSON_BUILD_DIR)/EGG-INFO/* $(PY-JSON_PYLIBDIR)/$(PY-JSON_EGG)-info
	$(MAKE) $(PY-JSON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-JSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-json-ipk: $(PY-JSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-json-clean:
	-$(MAKE) -C $(PY-JSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-json-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-JSON_DIR) $(PY-JSON_BUILD_DIR) $(PY-JSON_IPK_DIR) $(PY-JSON_IPK)
