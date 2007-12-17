###########################################################
#
# py-formencode
#
###########################################################

#
# PY-FORMENCODE_VERSION, PY-FORMENCODE_SITE and PY-FORMENCODE_SOURCE define
# the upstream location of the source code for the package.
# PY-FORMENCODE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-FORMENCODE_UNZIP is the command used to unzip the source.
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
PY-FORMENCODE_SITE=http://cheeseshop.python.org/packages/source/F/FormEncode
PY-FORMENCODE_VERSION=0.9
PY-FORMENCODE_SOURCE=FormEncode-$(PY-FORMENCODE_VERSION).tar.gz
PY-FORMENCODE_DIR=FormEncode-$(PY-FORMENCODE_VERSION)
PY-FORMENCODE_UNZIP=zcat
PY-FORMENCODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-FORMENCODE_DESCRIPTION=A form generation and validation package for python.
PY-FORMENCODE_SECTION=web
PY-FORMENCODE_PRIORITY=optional
PY24-FORMENCODE_DEPENDS=python24
PY25-FORMENCODE_DEPENDS=python25
PY-FORMENCODE_CONFLICTS=

#
# PY-FORMENCODE_IPK_VERSION should be incremented when the ipk changes.
#
PY-FORMENCODE_IPK_VERSION=1

#
# PY-FORMENCODE_CONFFILES should be a list of user-editable files
#PY-FORMENCODE_CONFFILES=/opt/etc/py-formencode.conf /opt/etc/init.d/SXXpy-formencode

#
# PY-FORMENCODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-FORMENCODE_PATCHES=$(PY-FORMENCODE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-FORMENCODE_CPPFLAGS=
PY-FORMENCODE_LDFLAGS=

#
# PY-FORMENCODE_BUILD_DIR is the directory in which the build is done.
# PY-FORMENCODE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-FORMENCODE_IPK_DIR is the directory in which the ipk is built.
# PY-FORMENCODE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-FORMENCODE_BUILD_DIR=$(BUILD_DIR)/py-formencode
PY-FORMENCODE_SOURCE_DIR=$(SOURCE_DIR)/py-formencode

PY24-FORMENCODE_IPK_DIR=$(BUILD_DIR)/py-formencode-$(PY-FORMENCODE_VERSION)-ipk
PY24-FORMENCODE_IPK=$(BUILD_DIR)/py-formencode_$(PY-FORMENCODE_VERSION)-$(PY-FORMENCODE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-FORMENCODE_IPK_DIR=$(BUILD_DIR)/py25-formencode-$(PY-FORMENCODE_VERSION)-ipk
PY25-FORMENCODE_IPK=$(BUILD_DIR)/py25-formencode_$(PY-FORMENCODE_VERSION)-$(PY-FORMENCODE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-formencode-source py-formencode-unpack py-formencode py-formencode-stage py-formencode-ipk py-formencode-clean py-formencode-dirclean py-formencode-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-FORMENCODE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-FORMENCODE_SITE)/$(PY-FORMENCODE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-formencode-source: $(DL_DIR)/$(PY-FORMENCODE_SOURCE) $(PY-FORMENCODE_PATCHES)

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
$(PY-FORMENCODE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-FORMENCODE_SOURCE) $(PY-FORMENCODE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-FORMENCODE_BUILD_DIR)
	mkdir -p $(PY-FORMENCODE_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-FORMENCODE_DIR)
	$(PY-FORMENCODE_UNZIP) $(DL_DIR)/$(PY-FORMENCODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-FORMENCODE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-FORMENCODE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-FORMENCODE_DIR) $(PY-FORMENCODE_BUILD_DIR)/2.4
	(cd $(PY-FORMENCODE_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-FORMENCODE_DIR)
	$(PY-FORMENCODE_UNZIP) $(DL_DIR)/$(PY-FORMENCODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-FORMENCODE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-FORMENCODE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-FORMENCODE_DIR) $(PY-FORMENCODE_BUILD_DIR)/2.5
	(cd $(PY-FORMENCODE_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-FORMENCODE_BUILD_DIR)/.configured

py-formencode-unpack: $(PY-FORMENCODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-FORMENCODE_BUILD_DIR)/.built: $(PY-FORMENCODE_BUILD_DIR)/.configured
	rm -f $(PY-FORMENCODE_BUILD_DIR)/.built
	(cd $(PY-FORMENCODE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-FORMENCODE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-FORMENCODE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-formencode: $(PY-FORMENCODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-FORMENCODE_BUILD_DIR)/.staged: $(PY-FORMENCODE_BUILD_DIR)/.built
	rm -f $(PY-FORMENCODE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-FORMENCODE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-FORMENCODE_BUILD_DIR)/.staged

py-formencode-stage: $(PY-FORMENCODE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-formencode
#
$(PY24-FORMENCODE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-formencode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-FORMENCODE_PRIORITY)" >>$@
	@echo "Section: $(PY-FORMENCODE_SECTION)" >>$@
	@echo "Version: $(PY-FORMENCODE_VERSION)-$(PY-FORMENCODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-FORMENCODE_MAINTAINER)" >>$@
	@echo "Source: $(PY-FORMENCODE_SITE)/$(PY-FORMENCODE_SOURCE)" >>$@
	@echo "Description: $(PY-FORMENCODE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-FORMENCODE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-FORMENCODE_CONFLICTS)" >>$@

$(PY25-FORMENCODE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-formencode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-FORMENCODE_PRIORITY)" >>$@
	@echo "Section: $(PY-FORMENCODE_SECTION)" >>$@
	@echo "Version: $(PY-FORMENCODE_VERSION)-$(PY-FORMENCODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-FORMENCODE_MAINTAINER)" >>$@
	@echo "Source: $(PY-FORMENCODE_SITE)/$(PY-FORMENCODE_SOURCE)" >>$@
	@echo "Description: $(PY-FORMENCODE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-FORMENCODE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-FORMENCODE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-FORMENCODE_IPK_DIR)/opt/sbin or $(PY-FORMENCODE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-FORMENCODE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-FORMENCODE_IPK_DIR)/opt/etc/py-formencode/...
# Documentation files should be installed in $(PY-FORMENCODE_IPK_DIR)/opt/doc/py-formencode/...
# Daemon startup scripts should be installed in $(PY-FORMENCODE_IPK_DIR)/opt/etc/init.d/S??py-formencode
#
# You may need to patch your application to make it use these locations.
#
$(PY24-FORMENCODE_IPK): $(PY-FORMENCODE_BUILD_DIR)/.built
	rm -rf $(PY24-FORMENCODE_IPK_DIR) $(BUILD_DIR)/py-formencode_*_$(TARGET_ARCH).ipk
	(cd $(PY-FORMENCODE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-FORMENCODE_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-FORMENCODE_IPK_DIR)/CONTROL/control
#	echo $(PY-FORMENCODE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-FORMENCODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-FORMENCODE_IPK_DIR)

$(PY25-FORMENCODE_IPK): $(PY-FORMENCODE_BUILD_DIR)/.built
	rm -rf $(PY25-FORMENCODE_IPK_DIR) $(BUILD_DIR)/py25-formencode_*_$(TARGET_ARCH).ipk
	(cd $(PY-FORMENCODE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-FORMENCODE_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-FORMENCODE_IPK_DIR)/CONTROL/control
#	echo $(PY-FORMENCODE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-FORMENCODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-FORMENCODE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-formencode-ipk: $(PY24-FORMENCODE_IPK) $(PY25-FORMENCODE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-formencode-clean:
	-$(MAKE) -C $(PY-FORMENCODE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-formencode-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-FORMENCODE_DIR) $(PY-FORMENCODE_BUILD_DIR)
	rm -rf $(PY24-FORMENCODE_IPK_DIR) $(PY24-FORMENCODE_IPK)
	rm -rf $(PY25-FORMENCODE_IPK_DIR) $(PY25-FORMENCODE_IPK)

#
# Some sanity check for the package.
#
py-formencode-check: $(PY24-FORMENCODE_IPK) $(PY25-FORMENCODE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-FORMENCODE_IPK) $(PY25-FORMENCODE_IPK)
