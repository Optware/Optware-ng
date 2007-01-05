###########################################################
#
# py-myghtyutils
#
###########################################################

#
# PY-MYGHTYUTILS_VERSION, PY-MYGHTYUTILS_SITE and PY-MYGHTYUTILS_SOURCE define
# the upstream location of the source code for the package.
# PY-MYGHTYUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MYGHTYUTILS_UNZIP is the command used to unzip the source.
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
# PY-MYGHTYUTILS_IPK_VERSION should be incremented when the ipk changes.
#
PY-MYGHTYUTILS_SITE=http://cheeseshop.python.org/packages/source/M/MyghtyUtils
PY-MYGHTYUTILS_VERSION=0.52
PY-MYGHTYUTILS_IPK_VERSION=1
PY-MYGHTYUTILS_SOURCE=MyghtyUtils-$(PY-MYGHTYUTILS_VERSION).zip
PY-MYGHTYUTILS_DIR=MyghtyUtils-$(PY-MYGHTYUTILS_VERSION)
PY-MYGHTYUTILS_UNZIP=unzip
PY-MYGHTYUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MYGHTYUTILS_DESCRIPTION=Container and utility functions from the myghty template framework.
PY-MYGHTYUTILS_SECTION=misc
PY-MYGHTYUTILS_PRIORITY=optional
PY24-MYGHTYUTILS_DEPENDS=python24
PY25-MYGHTYUTILS_DEPENDS=python25
PY-MYGHTYUTILS_SUGGESTS=
PY-MYGHTYUTILS_CONFLICTS=


#
# PY-MYGHTYUTILS_CONFFILES should be a list of user-editable files
#PY-MYGHTYUTILS_CONFFILES=/opt/etc/py-myghtyutils.conf /opt/etc/init.d/SXXpy-myghtyutils

#
# PY-MYGHTYUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MYGHTYUTILS_PATCHES=$(PY-MYGHTYUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MYGHTYUTILS_CPPFLAGS=
PY-MYGHTYUTILS_LDFLAGS=

#
# PY-MYGHTYUTILS_BUILD_DIR is the directory in which the build is done.
# PY-MYGHTYUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MYGHTYUTILS_IPK_DIR is the directory in which the ipk is built.
# PY-MYGHTYUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MYGHTYUTILS_BUILD_DIR=$(BUILD_DIR)/py-myghtyutils
PY-MYGHTYUTILS_SOURCE_DIR=$(SOURCE_DIR)/py-myghtyutils

PY24-MYGHTYUTILS_IPK_DIR=$(BUILD_DIR)/py-myghtyutils-$(PY-MYGHTYUTILS_VERSION)-ipk
PY24-MYGHTYUTILS_IPK=$(BUILD_DIR)/py-myghtyutils_$(PY-MYGHTYUTILS_VERSION)-$(PY-MYGHTYUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MYGHTYUTILS_IPK_DIR=$(BUILD_DIR)/py25-myghtyutils-$(PY-MYGHTYUTILS_VERSION)-ipk
PY25-MYGHTYUTILS_IPK=$(BUILD_DIR)/py25-myghtyutils_$(PY-MYGHTYUTILS_VERSION)-$(PY-MYGHTYUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-myghtyutils-source py-myghtyutils-unpack py-myghtyutils py-myghtyutils-stage py-myghtyutils-ipk py-myghtyutils-clean py-myghtyutils-dirclean py-myghtyutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MYGHTYUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-MYGHTYUTILS_SITE)/$(PY-MYGHTYUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-myghtyutils-source: $(DL_DIR)/$(PY-MYGHTYUTILS_SOURCE) $(PY-MYGHTYUTILS_PATCHES)

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
$(PY-MYGHTYUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MYGHTYUTILS_SOURCE) $(PY-MYGHTYUTILS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-MYGHTYUTILS_BUILD_DIR)
	mkdir -p $(PY-MYGHTYUTILS_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR)
	$(PY-MYGHTYUTILS_UNZIP) -d $(BUILD_DIR) $(DL_DIR)/$(PY-MYGHTYUTILS_SOURCE)
	if test -n "$(PY-MYGHTYUTILS_PATCHES)" ; then \
	    cat $(PY-MYGHTYUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR) $(PY-MYGHTYUTILS_BUILD_DIR)/2.4
	(cd $(PY-MYGHTYUTILS_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR)
	$(PY-MYGHTYUTILS_UNZIP) -d $(BUILD_DIR) $(DL_DIR)/$(PY-MYGHTYUTILS_SOURCE)
	if test -n "$(PY-MYGHTYUTILS_PATCHES)" ; then \
	    cat $(PY-MYGHTYUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR) $(PY-MYGHTYUTILS_BUILD_DIR)/2.5
	(cd $(PY-MYGHTYUTILS_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-myghtyutils-unpack: $(PY-MYGHTYUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MYGHTYUTILS_BUILD_DIR)/.built: $(PY-MYGHTYUTILS_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(PY-MYGHTYUTILS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
py-myghtyutils: $(PY-MYGHTYUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MYGHTYUTILS_BUILD_DIR)/.staged: $(PY-MYGHTYUTILS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-MYGHTYUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-myghtyutils-stage: $(PY-MYGHTYUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-myghtyutils
#
$(PY24-MYGHTYUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-myghtyutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MYGHTYUTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-MYGHTYUTILS_SECTION)" >>$@
	@echo "Version: $(PY-MYGHTYUTILS_VERSION)-$(PY-MYGHTYUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MYGHTYUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-MYGHTYUTILS_SITE)/$(PY-MYGHTYUTILS_SOURCE)" >>$@
	@echo "Description: $(PY-MYGHTYUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-MYGHTYUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MYGHTYUTILS_CONFLICTS)" >>$@

$(PY25-MYGHTYUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-myghtyutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MYGHTYUTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-MYGHTYUTILS_SECTION)" >>$@
	@echo "Version: $(PY-MYGHTYUTILS_VERSION)-$(PY-MYGHTYUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MYGHTYUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-MYGHTYUTILS_SITE)/$(PY-MYGHTYUTILS_SOURCE)" >>$@
	@echo "Description: $(PY-MYGHTYUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MYGHTYUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MYGHTYUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MYGHTYUTILS_IPK_DIR)/opt/sbin or $(PY-MYGHTYUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MYGHTYUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MYGHTYUTILS_IPK_DIR)/opt/etc/py-myghtyutils/...
# Documentation files should be installed in $(PY-MYGHTYUTILS_IPK_DIR)/opt/doc/py-myghtyutils/...
# Daemon startup scripts should be installed in $(PY-MYGHTYUTILS_IPK_DIR)/opt/etc/init.d/S??py-myghtyutils
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MYGHTYUTILS_IPK): $(PY-MYGHTYUTILS_BUILD_DIR)/.built
	rm -rf $(PY24-MYGHTYUTILS_IPK_DIR) $(BUILD_DIR)/py-myghtyutils_*_$(TARGET_ARCH).ipk
	(cd $(PY-MYGHTYUTILS_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-MYGHTYUTILS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-MYGHTYUTILS_IPK_DIR)/CONTROL/control
#	echo $(PY-MYGHTYUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-MYGHTYUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MYGHTYUTILS_IPK_DIR)

$(PY25-MYGHTYUTILS_IPK): $(PY-MYGHTYUTILS_BUILD_DIR)/.built
	rm -rf $(PY25-MYGHTYUTILS_IPK_DIR) $(BUILD_DIR)/py25-myghtyutils_*_$(TARGET_ARCH).ipk
	(cd $(PY-MYGHTYUTILS_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MYGHTYUTILS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-MYGHTYUTILS_IPK_DIR)/CONTROL/control
#	echo $(PY-MYGHTYUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-MYGHTYUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MYGHTYUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-myghtyutils-ipk: $(PY24-MYGHTYUTILS_IPK) $(PY25-MYGHTYUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-myghtyutils-clean:
	-$(MAKE) -C $(PY-MYGHTYUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-myghtyutils-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MYGHTYUTILS_DIR) $(PY-MYGHTYUTILS_BUILD_DIR)
	rm -rf $(PY24-MYGHTYUTILS_IPK_DIR) $(PY24-MYGHTYUTILS_IPK)
	rm -rf $(PY25-MYGHTYUTILS_IPK_DIR) $(PY25-MYGHTYUTILS_IPK)

#
# Some sanity check for the package.
#
py-myghtyutils-check: $(PY24-MYGHTYUTILS_IPK) $(PY25-MYGHTYUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MYGHTYUTILS_IPK) $(PY25-MYGHTYUTILS_IPK)
