###########################################################
#
# py-webhelpers
#
###########################################################

#
# PY-WEBHELPERS_VERSION, PY-WEBHELPERS_SITE and PY-WEBHELPERS_SOURCE define
# the upstream location of the source code for the package.
# PY-WEBHELPERS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-WEBHELPERS_UNZIP is the command used to unzip the source.
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
# PY-WEBHELPERS_IPK_VERSION should be incremented when the ipk changes.
#
PY-WEBHELPERS_SITE=http://cheeseshop.python.org/packages/source/W/WebHelpers
PY-WEBHELPERS_VERSION=0.3
PY-WEBHELPERS_IPK_VERSION=1
PY-WEBHELPERS_SOURCE=WebHelpers-$(PY-WEBHELPERS_VERSION).tar.gz
PY-WEBHELPERS_DIR=WebHelpers-$(PY-WEBHELPERS_VERSION)
PY-WEBHELPERS_UNZIP=zcat
PY-WEBHELPERS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-WEBHELPERS_DESCRIPTION=A library of helper functions intended to make writing templates in web applications easier.
PY-WEBHELPERS_SECTION=misc
PY-WEBHELPERS_PRIORITY=optional
PY24-WEBHELPERS_DEPENDS=python24, py-routes (>=1.1), py-simplejson (>=1.4)
PY25-WEBHELPERS_DEPENDS=python25, py25-routes (>=1.1), py25-simplejson (>=1.4)
PY-WEBHELPERS_SUGGESTS=
PY-WEBHELPERS_CONFLICTS=


#
# PY-WEBHELPERS_CONFFILES should be a list of user-editable files
#PY-WEBHELPERS_CONFFILES=/opt/etc/py-webhelpers.conf /opt/etc/init.d/SXXpy-webhelpers

#
# PY-WEBHELPERS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-WEBHELPERS_PATCHES=$(PY-WEBHELPERS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-WEBHELPERS_CPPFLAGS=
PY-WEBHELPERS_LDFLAGS=

#
# PY-WEBHELPERS_BUILD_DIR is the directory in which the build is done.
# PY-WEBHELPERS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-WEBHELPERS_IPK_DIR is the directory in which the ipk is built.
# PY-WEBHELPERS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-WEBHELPERS_BUILD_DIR=$(BUILD_DIR)/py-webhelpers
PY-WEBHELPERS_SOURCE_DIR=$(SOURCE_DIR)/py-webhelpers

PY24-WEBHELPERS_IPK_DIR=$(BUILD_DIR)/py-webhelpers-$(PY-WEBHELPERS_VERSION)-ipk
PY24-WEBHELPERS_IPK=$(BUILD_DIR)/py-webhelpers_$(PY-WEBHELPERS_VERSION)-$(PY-WEBHELPERS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-WEBHELPERS_IPK_DIR=$(BUILD_DIR)/py25-webhelpers-$(PY-WEBHELPERS_VERSION)-ipk
PY25-WEBHELPERS_IPK=$(BUILD_DIR)/py25-webhelpers_$(PY-WEBHELPERS_VERSION)-$(PY-WEBHELPERS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-webhelpers-source py-webhelpers-unpack py-webhelpers py-webhelpers-stage py-webhelpers-ipk py-webhelpers-clean py-webhelpers-dirclean py-webhelpers-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-WEBHELPERS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-WEBHELPERS_SITE)/$(PY-WEBHELPERS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-webhelpers-source: $(DL_DIR)/$(PY-WEBHELPERS_SOURCE) $(PY-WEBHELPERS_PATCHES)

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
$(PY-WEBHELPERS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-WEBHELPERS_SOURCE) $(PY-WEBHELPERS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-WEBHELPERS_BUILD_DIR)
	mkdir -p $(PY-WEBHELPERS_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-WEBHELPERS_DIR)
	$(PY-WEBHELPERS_UNZIP) $(DL_DIR)/$(PY-WEBHELPERS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-WEBHELPERS_PATCHES)" ; then \
	    cat $(PY-WEBHELPERS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WEBHELPERS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-WEBHELPERS_DIR) $(PY-WEBHELPERS_BUILD_DIR)/2.4
	(cd $(PY-WEBHELPERS_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-WEBHELPERS_DIR)
	$(PY-WEBHELPERS_UNZIP) $(DL_DIR)/$(PY-WEBHELPERS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-WEBHELPERS_PATCHES)" ; then \
	    cat $(PY-WEBHELPERS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WEBHELPERS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-WEBHELPERS_DIR) $(PY-WEBHELPERS_BUILD_DIR)/2.5
	(cd $(PY-WEBHELPERS_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-webhelpers-unpack: $(PY-WEBHELPERS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-WEBHELPERS_BUILD_DIR)/.built: $(PY-WEBHELPERS_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(PY-WEBHELPERS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
py-webhelpers: $(PY-WEBHELPERS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-WEBHELPERS_BUILD_DIR)/.staged: $(PY-WEBHELPERS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-WEBHELPERS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-webhelpers-stage: $(PY-WEBHELPERS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-webhelpers
#
$(PY24-WEBHELPERS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-webhelpers" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEBHELPERS_PRIORITY)" >>$@
	@echo "Section: $(PY-WEBHELPERS_SECTION)" >>$@
	@echo "Version: $(PY-WEBHELPERS_VERSION)-$(PY-WEBHELPERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEBHELPERS_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEBHELPERS_SITE)/$(PY-WEBHELPERS_SOURCE)" >>$@
	@echo "Description: $(PY-WEBHELPERS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-WEBHELPERS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-WEBHELPERS_CONFLICTS)" >>$@

$(PY25-WEBHELPERS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-webhelpers" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEBHELPERS_PRIORITY)" >>$@
	@echo "Section: $(PY-WEBHELPERS_SECTION)" >>$@
	@echo "Version: $(PY-WEBHELPERS_VERSION)-$(PY-WEBHELPERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEBHELPERS_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEBHELPERS_SITE)/$(PY-WEBHELPERS_SOURCE)" >>$@
	@echo "Description: $(PY-WEBHELPERS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-WEBHELPERS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-WEBHELPERS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-WEBHELPERS_IPK_DIR)/opt/sbin or $(PY-WEBHELPERS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-WEBHELPERS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-WEBHELPERS_IPK_DIR)/opt/etc/py-webhelpers/...
# Documentation files should be installed in $(PY-WEBHELPERS_IPK_DIR)/opt/doc/py-webhelpers/...
# Daemon startup scripts should be installed in $(PY-WEBHELPERS_IPK_DIR)/opt/etc/init.d/S??py-webhelpers
#
# You may need to patch your application to make it use these locations.
#
$(PY24-WEBHELPERS_IPK): $(PY-WEBHELPERS_BUILD_DIR)/.built
	rm -rf $(PY24-WEBHELPERS_IPK_DIR) $(BUILD_DIR)/py-webhelpers_*_$(TARGET_ARCH).ipk
	(cd $(PY-WEBHELPERS_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-WEBHELPERS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-WEBHELPERS_IPK_DIR)/CONTROL/control
#	echo $(PY-WEBHELPERS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-WEBHELPERS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-WEBHELPERS_IPK_DIR)

$(PY25-WEBHELPERS_IPK): $(PY-WEBHELPERS_BUILD_DIR)/.built
	rm -rf $(PY25-WEBHELPERS_IPK_DIR) $(BUILD_DIR)/py25-webhelpers_*_$(TARGET_ARCH).ipk
	(cd $(PY-WEBHELPERS_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-WEBHELPERS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-WEBHELPERS_IPK_DIR)/CONTROL/control
#	echo $(PY-WEBHELPERS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-WEBHELPERS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-WEBHELPERS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-webhelpers-ipk: $(PY24-WEBHELPERS_IPK) $(PY25-WEBHELPERS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-webhelpers-clean:
	-$(MAKE) -C $(PY-WEBHELPERS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-webhelpers-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-WEBHELPERS_DIR) $(PY-WEBHELPERS_BUILD_DIR)
	rm -rf $(PY24-WEBHELPERS_IPK_DIR) $(PY24-WEBHELPERS_IPK)
	rm -rf $(PY25-WEBHELPERS_IPK_DIR) $(PY25-WEBHELPERS_IPK)

#
# Some sanity check for the package.
#
py-webhelpers-check: $(PY24-WEBHELPERS_IPK) $(PY25-WEBHELPERS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-WEBHELPERS_IPK) $(PY25-WEBHELPERS_IPK)
