###########################################################
#
# py-decoratortools
#
###########################################################

#
# PY-DECORATORTOOLS_VERSION, PY-DECORATORTOOLS_SITE and PY-DECORATORTOOLS_SOURCE define
# the upstream location of the source code for the package.
# PY-DECORATORTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-DECORATORTOOLS_UNZIP is the command used to unzip the source.
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
PY-DECORATORTOOLS_VERSION=1.6
PY-DECORATORTOOLS_SITE=http://cheeseshop.python.org/packages/source/D/DecoratorTools
PY-DECORATORTOOLS_DIR=DecoratorTools-$(PY-DECORATORTOOLS_VERSION)
PY-DECORATORTOOLS_SOURCE=DecoratorTools-$(PY-DECORATORTOOLS_VERSION).zip
PY-DECORATORTOOLS_UNZIP=unzip
PY-DECORATORTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-DECORATORTOOLS_DESCRIPTION=Class and function decoratortoolss.
PY-DECORATORTOOLS_SECTION=misc
PY-DECORATORTOOLS_PRIORITY=optional
PY24-DECORATORTOOLS_DEPENDS=python24
PY25-DECORATORTOOLS_DEPENDS=python25
PY-DECORATORTOOLS_CONFLICTS=

#
# PY-DECORATORTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
PY-DECORATORTOOLS_IPK_VERSION=1

#
# PY-DECORATORTOOLS_CONFFILES should be a list of user-editable files
#PY-DECORATORTOOLS_CONFFILES=/opt/etc/py-decoratortools.conf /opt/etc/init.d/SXXpy-decoratortools

#
# PY-DECORATORTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-DECORATORTOOLS_PATCHES=$(PY-DECORATORTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-DECORATORTOOLS_CPPFLAGS=
PY-DECORATORTOOLS_LDFLAGS=

#
# PY-DECORATORTOOLS_BUILD_DIR is the directory in which the build is done.
# PY-DECORATORTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-DECORATORTOOLS_IPK_DIR is the directory in which the ipk is built.
# PY-DECORATORTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-DECORATORTOOLS_BUILD_DIR=$(BUILD_DIR)/py-decoratortools
PY-DECORATORTOOLS_SOURCE_DIR=$(SOURCE_DIR)/py-decoratortools

PY24-DECORATORTOOLS_IPK_DIR=$(BUILD_DIR)/py-decoratortools-$(PY-DECORATORTOOLS_VERSION)-ipk
PY24-DECORATORTOOLS_IPK=$(BUILD_DIR)/py-decoratortools_$(PY-DECORATORTOOLS_VERSION)-$(PY-DECORATORTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-DECORATORTOOLS_IPK_DIR=$(BUILD_DIR)/py25-decoratortools-$(PY-DECORATORTOOLS_VERSION)-ipk
PY25-DECORATORTOOLS_IPK=$(BUILD_DIR)/py25-decoratortools_$(PY-DECORATORTOOLS_VERSION)-$(PY-DECORATORTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-decoratortools-source py-decoratortools-unpack py-decoratortools py-decoratortools-stage py-decoratortools-ipk py-decoratortools-clean py-decoratortools-dirclean py-decoratortools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-DECORATORTOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-DECORATORTOOLS_SITE)/$(PY-DECORATORTOOLS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PY-DECORATORTOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-decoratortools-source: $(DL_DIR)/$(PY-DECORATORTOOLS_SOURCE) $(PY-DECORATORTOOLS_PATCHES)

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
$(PY-DECORATORTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-DECORATORTOOLS_SOURCE) $(PY-DECORATORTOOLS_PATCHES) make/py-decoratortools.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-DECORATORTOOLS_BUILD_DIR)
	mkdir -p $(PY-DECORATORTOOLS_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR)
	cd $(BUILD_DIR) && $(PY-DECORATORTOOLS_UNZIP) $(DL_DIR)/$(PY-DECORATORTOOLS_SOURCE)
#	cat $(PY-DECORATORTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR) $(PY-DECORATORTOOLS_BUILD_DIR)/2.4
	(cd $(PY-DECORATORTOOLS_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR)
	cd $(BUILD_DIR) && $(PY-DECORATORTOOLS_UNZIP) $(DL_DIR)/$(PY-DECORATORTOOLS_SOURCE)
#	cat $(PY-DECORATORTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR) $(PY-DECORATORTOOLS_BUILD_DIR)/2.5
	(cd $(PY-DECORATORTOOLS_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-DECORATORTOOLS_BUILD_DIR)/.configured

py-decoratortools-unpack: $(PY-DECORATORTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-DECORATORTOOLS_BUILD_DIR)/.built: $(PY-DECORATORTOOLS_BUILD_DIR)/.configured
	rm -f $(PY-DECORATORTOOLS_BUILD_DIR)/.built
	(cd $(PY-DECORATORTOOLS_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-DECORATORTOOLS_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-DECORATORTOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-decoratortools: $(PY-DECORATORTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-DECORATORTOOLS_BUILD_DIR)/.staged: $(PY-DECORATORTOOLS_BUILD_DIR)/.built
	rm -f $(PY-DECORATORTOOLS_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-DECORATORTOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-DECORATORTOOLS_BUILD_DIR)/.staged

py-decoratortools-stage: $(PY-DECORATORTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-decoratortools
#
$(PY24-DECORATORTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-decoratortools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DECORATORTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-DECORATORTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-DECORATORTOOLS_VERSION)-$(PY-DECORATORTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DECORATORTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-DECORATORTOOLS_SITE)/$(PY-DECORATORTOOLS_SOURCE)" >>$@
	@echo "Description: $(PY-DECORATORTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-DECORATORTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DECORATORTOOLS_CONFLICTS)" >>$@

$(PY25-DECORATORTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-decoratortools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DECORATORTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-DECORATORTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-DECORATORTOOLS_VERSION)-$(PY-DECORATORTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DECORATORTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-DECORATORTOOLS_SITE)/$(PY-DECORATORTOOLS_SOURCE)" >>$@
	@echo "Description: $(PY-DECORATORTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-DECORATORTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DECORATORTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-DECORATORTOOLS_IPK_DIR)/opt/sbin or $(PY-DECORATORTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-DECORATORTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-DECORATORTOOLS_IPK_DIR)/opt/etc/py-decoratortools/...
# Documentation files should be installed in $(PY-DECORATORTOOLS_IPK_DIR)/opt/doc/py-decoratortools/...
# Daemon startup scripts should be installed in $(PY-DECORATORTOOLS_IPK_DIR)/opt/etc/init.d/S??py-decoratortools
#
# You may need to patch your application to make it use these locations.
#
$(PY24-DECORATORTOOLS_IPK): $(PY-DECORATORTOOLS_BUILD_DIR)/.built
	rm -rf $(PY24-DECORATORTOOLS_IPK_DIR) $(BUILD_DIR)/py-decoratortools_*_$(TARGET_ARCH).ipk
	(cd $(PY-DECORATORTOOLS_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-DECORATORTOOLS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-DECORATORTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-DECORATORTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-DECORATORTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-DECORATORTOOLS_IPK_DIR)

$(PY25-DECORATORTOOLS_IPK): $(PY-DECORATORTOOLS_BUILD_DIR)/.built
	rm -rf $(PY25-DECORATORTOOLS_IPK_DIR) $(BUILD_DIR)/py25-decoratortools_*_$(TARGET_ARCH).ipk
	(cd $(PY-DECORATORTOOLS_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-DECORATORTOOLS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-DECORATORTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-DECORATORTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-DECORATORTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-DECORATORTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-decoratortools-ipk: $(PY24-DECORATORTOOLS_IPK) $(PY25-DECORATORTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-decoratortools-clean:
	-$(MAKE) -C $(PY-DECORATORTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-decoratortools-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-DECORATORTOOLS_DIR) $(PY-DECORATORTOOLS_BUILD_DIR)
	rm -rf $(PY24-DECORATORTOOLS_IPK_DIR) $(PY24-DECORATORTOOLS_IPK)
	rm -rf $(PY25-DECORATORTOOLS_IPK_DIR) $(PY25-DECORATORTOOLS_IPK)

#
# Some sanity check for the package.
#
py-decoratortools-check: $(PY24-DECORATORTOOLS_IPK) $(PY25-DECORATORTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-DECORATORTOOLS_IPK) $(PY25-DECORATORTOOLS_IPK)
