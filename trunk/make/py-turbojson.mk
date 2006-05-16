###########################################################
#
# py-turbojson
#
###########################################################

#
# PY-TURBOJSON_VERSION, PY-TURBOJSON_SITE and PY-TURBOJSON_SOURCE define
# the upstream location of the source code for the package.
# PY-TURBOJSON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TURBOJSON_UNZIP is the command used to unzip the source.
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
PY-TURBOJSON_VERSION=0.9.3
PY-TURBOJSON_SOURCE=$(PY-TURBOGEARS_SOURCE)
PY-TURBOJSON_DIR=TurboJson-$(PY-TURBOJSON_VERSION)
PY-TURBOJSON_UNZIP=zcat
PY-TURBOJSON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TURBOJSON_DESCRIPTION=Python template plugin that supports JSON.
PY-TURBOJSON_SECTION=misc
PY-TURBOJSON_PRIORITY=optional
PY-TURBOJSON_DEPENDS=python, py-simplesjon
PY-TURBOJSON_CONFLICTS=

#
# PY-TURBOJSON_IPK_VERSION should be incremented when the ipk changes.
#
PY-TURBOJSON_IPK_VERSION=1

#
# PY-TURBOJSON_CONFFILES should be a list of user-editable files
#PY-TURBOJSON_CONFFILES=/opt/etc/py-turbojson.conf /opt/etc/init.d/SXXpy-turbojson

#
# PY-TURBOJSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TURBOJSON_PATCHES=$(PY-TURBOJSON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TURBOJSON_CPPFLAGS=
PY-TURBOJSON_LDFLAGS=

#
# PY-TURBOJSON_BUILD_DIR is the directory in which the build is done.
# PY-TURBOJSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TURBOJSON_IPK_DIR is the directory in which the ipk is built.
# PY-TURBOJSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TURBOJSON_BUILD_DIR=$(BUILD_DIR)/py-turbojson
PY-TURBOJSON_SOURCE_DIR=$(SOURCE_DIR)/py-turbojson
PY-TURBOJSON_IPK_DIR=$(BUILD_DIR)/py-turbojson-$(PY-TURBOJSON_VERSION)-ipk
PY-TURBOJSON_IPK=$(BUILD_DIR)/py-turbojson_$(PY-TURBOJSON_VERSION)-$(PY-TURBOJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(PY-TURBOJSON_SOURCE):
#	$(WGET) -P $(DL_DIR) $(PY-TURBOJSON_SITE)/$(PY-TURBOJSON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-turbojson-source: $(DL_DIR)/$(PY-TURBOJSON_SOURCE) $(PY-TURBOJSON_PATCHES)

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
$(PY-TURBOJSON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TURBOJSON_SOURCE) $(PY-TURBOJSON_PATCHES) make/py-turbojson.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-TURBOJSON_DIR) $(PY-TURBOJSON_BUILD_DIR)
	mkdir $(BUILD_DIR)/$(PY-TURBOJSON_DIR)
	$(PY-TURBOJSON_UNZIP) $(DL_DIR)/$(PY-TURBOJSON_SOURCE) | tar -C $(BUILD_DIR)/$(PY-TURBOJSON_DIR) -xvf - $(PY-TURBOGEARS_DIR)/plugins/json
#	cat $(PY-TURBOJSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOJSON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOJSON_DIR) $(PY-TURBOJSON_BUILD_DIR)
	(cd $(PY-TURBOJSON_BUILD_DIR)/$(PY-TURBOGEARS_DIR)/plugins/kid; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-TURBOJSON_BUILD_DIR)/.configured

py-turbojson-unpack: $(PY-TURBOJSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TURBOJSON_BUILD_DIR)/.built: $(PY-TURBOJSON_BUILD_DIR)/.configured
	rm -f $(PY-TURBOJSON_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-TURBOJSON_BUILD_DIR)
	touch $(PY-TURBOJSON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-turbojson: $(PY-TURBOJSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TURBOJSON_BUILD_DIR)/.staged: $(PY-TURBOJSON_BUILD_DIR)/.built
	rm -f $(PY-TURBOJSON_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-TURBOJSON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-TURBOJSON_BUILD_DIR)/.staged

py-turbojson-stage: $(PY-TURBOJSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-turbojson
#
$(PY-TURBOJSON_IPK_DIR)/CONTROL/control:
	@install -d $(PY-TURBOJSON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-turbojson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOJSON_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOJSON_SECTION)" >>$@
	@echo "Version: $(PY-TURBOJSON_VERSION)-$(PY-TURBOJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOJSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOJSON_SITE)/$(PY-TURBOJSON_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-TURBOJSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOJSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TURBOJSON_IPK_DIR)/opt/sbin or $(PY-TURBOJSON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TURBOJSON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TURBOJSON_IPK_DIR)/opt/etc/py-turbojson/...
# Documentation files should be installed in $(PY-TURBOJSON_IPK_DIR)/opt/doc/py-turbojson/...
# Daemon startup scripts should be installed in $(PY-TURBOJSON_IPK_DIR)/opt/etc/init.d/S??py-turbojson
#
# You may need to patch your application to make it use these locations.
#
$(PY-TURBOJSON_IPK): $(PY-TURBOJSON_BUILD_DIR)/.built
	rm -rf $(PY-TURBOJSON_IPK_DIR) $(BUILD_DIR)/py-turbojson_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOJSON_BUILD_DIR)/$(PY-TURBOGEARS_DIR)/plugins/json; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-TURBOJSON_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY-TURBOJSON_IPK_DIR)/CONTROL/control
	echo $(PY-TURBOJSON_CONFFILES) | sed -e 's/ /\n/g' > $(PY-TURBOJSON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-TURBOJSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-turbojson-ipk: $(PY-TURBOJSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-turbojson-clean:
	-$(MAKE) -C $(PY-TURBOJSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-turbojson-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TURBOJSON_DIR) $(PY-TURBOJSON_BUILD_DIR) $(PY-TURBOJSON_IPK_DIR) $(PY-TURBOJSON_IPK)
