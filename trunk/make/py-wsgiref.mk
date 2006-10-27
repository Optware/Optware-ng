###########################################################
#
# py-wsgiref
#
###########################################################

#
# PY-WSGIREF_VERSION, PY-WSGIREF_SITE and PY-WSGIREF_SOURCE define
# the upstream location of the source code for the package.
# PY-WSGIREF_DIR is the directory which is created when the source
# archive is unpacked.
# PY-WSGIREF_UNZIP is the command used to unzip the source.
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
PY-WSGIREF_SITE=http://cheeseshop.python.org/packages/source/w/wsgiref
PY-WSGIREF_VERSION=0.1.2
PY-WSGIREF_SOURCE=wsgiref-$(PY-WSGIREF_VERSION).zip
PY-WSGIREF_DIR=wsgiref-$(PY-WSGIREF_VERSION)
PY-WSGIREF_UNZIP=unzip
PY-WSGIREF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-WSGIREF_DESCRIPTION=Reference implementation of the python Web Server Gateway Interface specification.
PY-WSGIREF_SECTION=misc
PY-WSGIREF_PRIORITY=optional
PY-WSGIREF_DEPENDS=python
PY-WSGIREF_CONFLICTS=

#
# PY-WSGIREF_IPK_VERSION should be incremented when the ipk changes.
#
PY-WSGIREF_IPK_VERSION=1

#
# PY-WSGIREF_CONFFILES should be a list of user-editable files
#PY-WSGIREF_CONFFILES=/opt/etc/py-wsgiref.conf /opt/etc/init.d/SXXpy-wsgiref

#
# PY-WSGIREF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-WSGIREF_PATCHES=$(PY-WSGIREF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-WSGIREF_CPPFLAGS=
PY-WSGIREF_LDFLAGS=

#
# PY-WSGIREF_BUILD_DIR is the directory in which the build is done.
# PY-WSGIREF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-WSGIREF_IPK_DIR is the directory in which the ipk is built.
# PY-WSGIREF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-WSGIREF_BUILD_DIR=$(BUILD_DIR)/py-wsgiref
PY-WSGIREF_SOURCE_DIR=$(SOURCE_DIR)/py-wsgiref
PY-WSGIREF_IPK_DIR=$(BUILD_DIR)/py-wsgiref-$(PY-WSGIREF_VERSION)-ipk
PY-WSGIREF_IPK=$(BUILD_DIR)/py-wsgiref_$(PY-WSGIREF_VERSION)-$(PY-WSGIREF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-WSGIREF_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-WSGIREF_SITE)/$(PY-WSGIREF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-wsgiref-source: $(DL_DIR)/$(PY-WSGIREF_SOURCE) $(PY-WSGIREF_PATCHES)

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
$(PY-WSGIREF_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-WSGIREF_SOURCE) $(PY-WSGIREF_PATCHES) make/py-wsgiref.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-WSGIREF_DIR) $(PY-WSGIREF_BUILD_DIR)
	cd $(BUILD_DIR) && $(PY-WSGIREF_UNZIP) $(DL_DIR)/$(PY-WSGIREF_SOURCE)
#	cat $(PY-WSGIREF_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WSGIREF_DIR) -p1
	mv $(BUILD_DIR)/$(PY-WSGIREF_DIR) $(PY-WSGIREF_BUILD_DIR)
	(cd $(PY-WSGIREF_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-WSGIREF_BUILD_DIR)/.configured

py-wsgiref-unpack: $(PY-WSGIREF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-WSGIREF_BUILD_DIR)/.built: $(PY-WSGIREF_BUILD_DIR)/.configured
	rm -f $(PY-WSGIREF_BUILD_DIR)/.built
	(cd $(PY-WSGIREF_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py build)
#	$(MAKE) -C $(PY-WSGIREF_BUILD_DIR)
	touch $(PY-WSGIREF_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-wsgiref: $(PY-WSGIREF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-WSGIREF_BUILD_DIR)/.staged: $(PY-WSGIREF_BUILD_DIR)/.built
	rm -f $(PY-WSGIREF_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-WSGIREF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-WSGIREF_BUILD_DIR)/.staged

py-wsgiref-stage: $(PY-WSGIREF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-wsgiref
#
$(PY-WSGIREF_IPK_DIR)/CONTROL/control:
	@install -d $(PY-WSGIREF_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-wsgiref" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WSGIREF_PRIORITY)" >>$@
	@echo "Section: $(PY-WSGIREF_SECTION)" >>$@
	@echo "Version: $(PY-WSGIREF_VERSION)-$(PY-WSGIREF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WSGIREF_MAINTAINER)" >>$@
	@echo "Source: $(PY-WSGIREF_SITE)/$(PY-WSGIREF_SOURCE)" >>$@
	@echo "Description: $(PY-WSGIREF_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-WSGIREF_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-WSGIREF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-WSGIREF_IPK_DIR)/opt/sbin or $(PY-WSGIREF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-WSGIREF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-WSGIREF_IPK_DIR)/opt/etc/py-wsgiref/...
# Documentation files should be installed in $(PY-WSGIREF_IPK_DIR)/opt/doc/py-wsgiref/...
# Daemon startup scripts should be installed in $(PY-WSGIREF_IPK_DIR)/opt/etc/init.d/S??py-wsgiref
#
# You may need to patch your application to make it use these locations.
#
$(PY-WSGIREF_IPK): $(PY-WSGIREF_BUILD_DIR)/.built
	rm -rf $(PY-WSGIREF_IPK_DIR) $(BUILD_DIR)/py-wsgiref_*_$(TARGET_ARCH).ipk
	(cd $(PY-WSGIREF_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-WSGIREF_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY-WSGIREF_IPK_DIR)/CONTROL/control
	echo $(PY-WSGIREF_CONFFILES) | sed -e 's/ /\n/g' > $(PY-WSGIREF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-WSGIREF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-wsgiref-ipk: $(PY-WSGIREF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-wsgiref-clean:
	-$(MAKE) -C $(PY-WSGIREF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-wsgiref-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-WSGIREF_DIR) $(PY-WSGIREF_BUILD_DIR) $(PY-WSGIREF_IPK_DIR) $(PY-WSGIREF_IPK)
