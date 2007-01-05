###########################################################
#
# py-myghty
#
###########################################################

#
# PY-MYGHTY_VERSION, PY-MYGHTY_SITE and PY-MYGHTY_SOURCE define
# the upstream location of the source code for the package.
# PY-MYGHTY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MYGHTY_UNZIP is the command used to unzip the source.
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
PY-MYGHTY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/myghty
PY-MYGHTY_VERSION=1.1
PY-MYGHTY_SOURCE=Myghty-$(PY-MYGHTY_VERSION).tar.gz
PY-MYGHTY_DIR=Myghty-$(PY-MYGHTY_VERSION)
PY-MYGHTY_UNZIP=zcat
PY-MYGHTY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MYGHTY_DESCRIPTION=A Python based web and templating framework.
PY-MYGHTY_SECTION=misc
PY-MYGHTY_PRIORITY=optional
PY24-MYGHTY_DEPENDS=py-paste, py-pastedeploy, py-pastescript, py-routes
PY25-MYGHTY_DEPENDS=py25-paste, py25-pastedeploy, py25-pastescript, py25-routes
PY-MYGHTY_CONFLICTS=

#
# PY-MYGHTY_IPK_VERSION should be incremented when the ipk changes.
#
PY-MYGHTY_IPK_VERSION=2

#
# PY-MYGHTY_CONFFILES should be a list of user-editable files
#PY-MYGHTY_CONFFILES=/opt/etc/py-myghty.conf /opt/etc/init.d/SXXpy-myghty

#
# PY-MYGHTY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MYGHTY_PATCHES=$(PY-MYGHTY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MYGHTY_CPPFLAGS=
PY-MYGHTY_LDFLAGS=

#
# PY-MYGHTY_BUILD_DIR is the directory in which the build is done.
# PY-MYGHTY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MYGHTY_IPK_DIR is the directory in which the ipk is built.
# PY-MYGHTY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MYGHTY_BUILD_DIR=$(BUILD_DIR)/py-myghty
PY-MYGHTY_SOURCE_DIR=$(SOURCE_DIR)/py-myghty

PY24-MYGHTY_IPK_DIR=$(BUILD_DIR)/py-myghty-$(PY-MYGHTY_VERSION)-ipk
PY24-MYGHTY_IPK=$(BUILD_DIR)/py-myghty_$(PY-MYGHTY_VERSION)-$(PY-MYGHTY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MYGHTY_IPK_DIR=$(BUILD_DIR)/py25-myghty-$(PY-MYGHTY_VERSION)-ipk
PY25-MYGHTY_IPK=$(BUILD_DIR)/py25-myghty_$(PY-MYGHTY_VERSION)-$(PY-MYGHTY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-myghty-source py-myghty-unpack py-myghty py-myghty-stage py-myghty-ipk py-myghty-clean py-myghty-dirclean py-myghty-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MYGHTY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-MYGHTY_SITE)/$(PY-MYGHTY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-myghty-source: $(DL_DIR)/$(PY-MYGHTY_SOURCE) $(PY-MYGHTY_PATCHES)

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
$(PY-MYGHTY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MYGHTY_SOURCE) $(PY-MYGHTY_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-MYGHTY_BUILD_DIR)
	mkdir -p $(PY-MYGHTY_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MYGHTY_DIR)
	$(PY-MYGHTY_UNZIP) $(DL_DIR)/$(PY-MYGHTY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MYGHTY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MYGHTY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MYGHTY_DIR) $(PY-MYGHTY_BUILD_DIR)/2.4
	(cd $(PY-MYGHTY_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MYGHTY_DIR)
	$(PY-MYGHTY_UNZIP) $(DL_DIR)/$(PY-MYGHTY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MYGHTY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MYGHTY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MYGHTY_DIR) $(PY-MYGHTY_BUILD_DIR)/2.5
	(cd $(PY-MYGHTY_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-myghty-unpack: $(PY-MYGHTY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MYGHTY_BUILD_DIR)/.built: $(PY-MYGHTY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-MYGHTY_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-MYGHTY_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-myghty: $(PY-MYGHTY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MYGHTY_BUILD_DIR)/.staged: $(PY-MYGHTY_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-MYGHTY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-myghty-stage: $(PY-MYGHTY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-myghty
#
$(PY24-MYGHTY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-myghty" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MYGHTY_PRIORITY)" >>$@
	@echo "Section: $(PY-MYGHTY_SECTION)" >>$@
	@echo "Version: $(PY-MYGHTY_VERSION)-$(PY-MYGHTY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MYGHTY_MAINTAINER)" >>$@
	@echo "Source: $(PY-MYGHTY_SITE)/$(PY-MYGHTY_SOURCE)" >>$@
	@echo "Description: $(PY-MYGHTY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-MYGHTY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MYGHTY_CONFLICTS)" >>$@

$(PY25-MYGHTY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-myghty" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MYGHTY_PRIORITY)" >>$@
	@echo "Section: $(PY-MYGHTY_SECTION)" >>$@
	@echo "Version: $(PY-MYGHTY_VERSION)-$(PY-MYGHTY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MYGHTY_MAINTAINER)" >>$@
	@echo "Source: $(PY-MYGHTY_SITE)/$(PY-MYGHTY_SOURCE)" >>$@
	@echo "Description: $(PY-MYGHTY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MYGHTY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MYGHTY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MYGHTY_IPK_DIR)/opt/sbin or $(PY-MYGHTY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MYGHTY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MYGHTY_IPK_DIR)/opt/etc/py-myghty/...
# Documentation files should be installed in $(PY-MYGHTY_IPK_DIR)/opt/doc/py-myghty/...
# Daemon startup scripts should be installed in $(PY-MYGHTY_IPK_DIR)/opt/etc/init.d/S??py-myghty
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MYGHTY_IPK): $(PY-MYGHTY_BUILD_DIR)/.built
	rm -rf $(PY24-MYGHTY_IPK_DIR) $(BUILD_DIR)/py-myghty_*_$(TARGET_ARCH).ipk
	(cd $(PY-MYGHTY_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-MYGHTY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-MYGHTY_IPK_DIR)/CONTROL/control
#	echo $(PY-MYGHTY_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-MYGHTY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MYGHTY_IPK_DIR)

$(PY25-MYGHTY_IPK): $(PY-MYGHTY_BUILD_DIR)/.built
	rm -rf $(PY25-MYGHTY_IPK_DIR) $(BUILD_DIR)/py25-myghty_*_$(TARGET_ARCH).ipk
	(cd $(PY-MYGHTY_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MYGHTY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-MYGHTY_IPK_DIR)/CONTROL/control
#	echo $(PY-MYGHTY_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-MYGHTY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MYGHTY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-myghty-ipk: $(PY24-MYGHTY_IPK) $(PY25-MYGHTY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-myghty-clean:
	-$(MAKE) -C $(PY-MYGHTY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-myghty-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MYGHTY_DIR) $(PY-MYGHTY_BUILD_DIR)
	rm -rf $(PY24-MYGHTY_IPK_DIR) $(PY24-MYGHTY_IPK)
	rm -rf $(PY25-MYGHTY_IPK_DIR) $(PY25-MYGHTY_IPK)

#
# Some sanity check for the package.
#
py-myghty-check: $(PY24-MYGHTY_IPK) $(PY25-MYGHTY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MYGHTY_IPK) $(PY25-MYGHTY_IPK)
