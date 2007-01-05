###########################################################
#
# py-buildutils
#
###########################################################

#
# PY-BUILDUTILS_VERSION, PY-BUILDUTILS_SITE and PY-BUILDUTILS_SOURCE define
# the upstream location of the source code for the package.
# PY-BUILDUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BUILDUTILS_UNZIP is the command used to unzip the source.
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
# PY-BUILDUTILS_IPK_VERSION should be incremented when the ipk changes.
#
PY-BUILDUTILS_SITE=http://cheeseshop.python.org/packages/source/b/buildutils
PY-BUILDUTILS_VERSION=0.1.2
PY-BUILDUTILS_IPK_VERSION=1
PY-BUILDUTILS_SOURCE=buildutils-$(PY-BUILDUTILS_VERSION).tar.gz
PY-BUILDUTILS_DIR=buildutils-$(PY-BUILDUTILS_VERSION)
PY-BUILDUTILS_UNZIP=zcat
PY-BUILDUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BUILDUTILS_DESCRIPTION=buildutils provides several new commands for your package setup.py file to help make development easier.
PY-BUILDUTILS_SECTION=misc
PY-BUILDUTILS_PRIORITY=optional
PY24-BUILDUTILS_DEPENDS=python24
PY25-BUILDUTILS_DEPENDS=python25
PY-BUILDUTILS_SUGGESTS=
PY-BUILDUTILS_CONFLICTS=


#
# PY-BUILDUTILS_CONFFILES should be a list of user-editable files
#PY-BUILDUTILS_CONFFILES=/opt/etc/py-buildutils.conf /opt/etc/init.d/SXXpy-buildutils

#
# PY-BUILDUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BUILDUTILS_PATCHES=$(PY-BUILDUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BUILDUTILS_CPPFLAGS=
PY-BUILDUTILS_LDFLAGS=

#
# PY-BUILDUTILS_BUILD_DIR is the directory in which the build is done.
# PY-BUILDUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BUILDUTILS_IPK_DIR is the directory in which the ipk is built.
# PY-BUILDUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BUILDUTILS_BUILD_DIR=$(BUILD_DIR)/py-buildutils
PY-BUILDUTILS_SOURCE_DIR=$(SOURCE_DIR)/py-buildutils

PY24-BUILDUTILS_IPK_DIR=$(BUILD_DIR)/py-buildutils-$(PY-BUILDUTILS_VERSION)-ipk
PY24-BUILDUTILS_IPK=$(BUILD_DIR)/py-buildutils_$(PY-BUILDUTILS_VERSION)-$(PY-BUILDUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-BUILDUTILS_IPK_DIR=$(BUILD_DIR)/py25-buildutils-$(PY-BUILDUTILS_VERSION)-ipk
PY25-BUILDUTILS_IPK=$(BUILD_DIR)/py25-buildutils_$(PY-BUILDUTILS_VERSION)-$(PY-BUILDUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-buildutils-source py-buildutils-unpack py-buildutils py-buildutils-stage py-buildutils-ipk py-buildutils-clean py-buildutils-dirclean py-buildutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BUILDUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-BUILDUTILS_SITE)/$(PY-BUILDUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-buildutils-source: $(DL_DIR)/$(PY-BUILDUTILS_SOURCE) $(PY-BUILDUTILS_PATCHES)

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
$(PY-BUILDUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BUILDUTILS_SOURCE) $(PY-BUILDUTILS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-BUILDUTILS_BUILD_DIR)
	mkdir -p $(PY-BUILDUTILS_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-BUILDUTILS_DIR)
	$(PY-BUILDUTILS_UNZIP) $(DL_DIR)/$(PY-BUILDUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BUILDUTILS_PATCHES)" ; then \
	    cat $(PY-BUILDUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BUILDUTILS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-BUILDUTILS_DIR) $(PY-BUILDUTILS_BUILD_DIR)/2.4
	(cd $(PY-BUILDUTILS_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-BUILDUTILS_DIR)
	$(PY-BUILDUTILS_UNZIP) $(DL_DIR)/$(PY-BUILDUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BUILDUTILS_PATCHES)" ; then \
	    cat $(PY-BUILDUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BUILDUTILS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-BUILDUTILS_DIR) $(PY-BUILDUTILS_BUILD_DIR)/2.5
	(cd $(PY-BUILDUTILS_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-buildutils-unpack: $(PY-BUILDUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BUILDUTILS_BUILD_DIR)/.built: $(PY-BUILDUTILS_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(PY-BUILDUTILS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
py-buildutils: $(PY-BUILDUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-BUILDUTILS_BUILD_DIR)/.staged: $(PY-BUILDUTILS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-BUILDUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-buildutils-stage: $(PY-BUILDUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-buildutils
#
$(PY24-BUILDUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-buildutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BUILDUTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-BUILDUTILS_SECTION)" >>$@
	@echo "Version: $(PY-BUILDUTILS_VERSION)-$(PY-BUILDUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BUILDUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-BUILDUTILS_SITE)/$(PY-BUILDUTILS_SOURCE)" >>$@
	@echo "Description: $(PY-BUILDUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-BUILDUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BUILDUTILS_CONFLICTS)" >>$@

$(PY25-BUILDUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-buildutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BUILDUTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-BUILDUTILS_SECTION)" >>$@
	@echo "Version: $(PY-BUILDUTILS_VERSION)-$(PY-BUILDUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BUILDUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-BUILDUTILS_SITE)/$(PY-BUILDUTILS_SOURCE)" >>$@
	@echo "Description: $(PY-BUILDUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BUILDUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BUILDUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BUILDUTILS_IPK_DIR)/opt/sbin or $(PY-BUILDUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BUILDUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BUILDUTILS_IPK_DIR)/opt/etc/py-buildutils/...
# Documentation files should be installed in $(PY-BUILDUTILS_IPK_DIR)/opt/doc/py-buildutils/...
# Daemon startup scripts should be installed in $(PY-BUILDUTILS_IPK_DIR)/opt/etc/init.d/S??py-buildutils
#
# You may need to patch your application to make it use these locations.
#
$(PY24-BUILDUTILS_IPK): $(PY-BUILDUTILS_BUILD_DIR)/.built
	rm -rf $(PY24-BUILDUTILS_IPK_DIR) $(BUILD_DIR)/py-buildutils_*_$(TARGET_ARCH).ipk
	(cd $(PY-BUILDUTILS_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-BUILDUTILS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-BUILDUTILS_IPK_DIR)/CONTROL/control
#	echo $(PY-BUILDUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-BUILDUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-BUILDUTILS_IPK_DIR)

$(PY25-BUILDUTILS_IPK): $(PY-BUILDUTILS_BUILD_DIR)/.built
	rm -rf $(PY25-BUILDUTILS_IPK_DIR) $(BUILD_DIR)/py25-buildutils_*_$(TARGET_ARCH).ipk
	(cd $(PY-BUILDUTILS_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-BUILDUTILS_IPK_DIR) --prefix=/opt)
	for f in $(PY25-BUILDUTILS_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-BUILDUTILS_IPK_DIR)/CONTROL/control
#	echo $(PY-BUILDUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-BUILDUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BUILDUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-buildutils-ipk: $(PY24-BUILDUTILS_IPK) $(PY25-BUILDUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-buildutils-clean:
	-$(MAKE) -C $(PY-BUILDUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-buildutils-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BUILDUTILS_DIR) $(PY-BUILDUTILS_BUILD_DIR)
	rm -rf $(PY24-BUILDUTILS_IPK_DIR) $(PY24-BUILDUTILS_IPK)
	rm -rf $(PY25-BUILDUTILS_IPK_DIR) $(PY25-BUILDUTILS_IPK)

#
# Some sanity check for the package.
#
py-buildutils-check: $(PY24-BUILDUTILS_IPK) $(PY25-BUILDUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-BUILDUTILS_IPK) $(PY25-BUILDUTILS_IPK)
