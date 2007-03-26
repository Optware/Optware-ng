###########################################################
#
# py-mantissa
#
###########################################################

#
# PY-MANTISSA_VERSION, PY-MANTISSA_SITE and PY-MANTISSA_SOURCE define
# the upstream location of the source code for the package.
# PY-MANTISSA_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MANTISSA_UNZIP is the command used to unzip the source.
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
PY-MANTISSA_VERSION=0.6.1
PY-MANTISSA_SOURCE=Mantissa-$(PY-MANTISSA_VERSION).tar.gz
PY-MANTISSA_SITE=http://divmod.org/trac/attachment/wiki/SoftwareReleases/$(PY-MANTISSA_SOURCE)?format=raw
PY-MANTISSA_DIR=Mantissa-$(PY-MANTISSA_VERSION)
PY-MANTISSA_UNZIP=zcat
PY-MANTISSA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MANTISSA_DESCRIPTION=An extensible, multi-protocol, multi-user, interactive application server built on top of Axiom and Nevow.
PY-MANTISSA_SECTION=misc
PY-MANTISSA_PRIORITY=optional
PY24-MANTISSA_DEPENDS=python24, py-nevow
PY25-MANTISSA_DEPENDS=python25, py25-nevow
PY-MANTISSA_CONFLICTS=

#
# PY-MANTISSA_IPK_VERSION should be incremented when the ipk changes.
#
PY-MANTISSA_IPK_VERSION=1

#
# PY-MANTISSA_CONFFILES should be a list of user-editable files
#PY-MANTISSA_CONFFILES=/opt/etc/py-mantissa.conf /opt/etc/init.d/SXXpy-mantissa

#
# PY-MANTISSA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MANTISSA_PATCHES=$(PY-MANTISSA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MANTISSA_CPPFLAGS=
PY-MANTISSA_LDFLAGS=

#
# PY-MANTISSA_BUILD_DIR is the directory in which the build is done.
# PY-MANTISSA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MANTISSA_IPK_DIR is the directory in which the ipk is built.
# PY-MANTISSA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MANTISSA_BUILD_DIR=$(BUILD_DIR)/py-mantissa
PY-MANTISSA_SOURCE_DIR=$(SOURCE_DIR)/py-mantissa

PY24-MANTISSA_IPK_DIR=$(BUILD_DIR)/py-mantissa-$(PY-MANTISSA_VERSION)-ipk
PY24-MANTISSA_IPK=$(BUILD_DIR)/py-mantissa_$(PY-MANTISSA_VERSION)-$(PY-MANTISSA_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MANTISSA_IPK_DIR=$(BUILD_DIR)/py25-mantissa-$(PY-MANTISSA_VERSION)-ipk
PY25-MANTISSA_IPK=$(BUILD_DIR)/py25-mantissa_$(PY-MANTISSA_VERSION)-$(PY-MANTISSA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mantissa-source py-mantissa-unpack py-mantissa py-mantissa-stage py-mantissa-ipk py-mantissa-clean py-mantissa-dirclean py-mantissa-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MANTISSA_SOURCE):
	$(WGET) -O $(DL_DIR)/$(PY-MANTISSA_SOURCE) $(PY-MANTISSA_SITE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mantissa-source: $(DL_DIR)/$(PY-MANTISSA_SOURCE) $(PY-MANTISSA_PATCHES)

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
$(PY-MANTISSA_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MANTISSA_SOURCE) $(PY-MANTISSA_PATCHES)
	$(MAKE) py-epsilon-stage
	rm -rf $(PY-MANTISSA_BUILD_DIR)
	mkdir -p $(PY-MANTISSA_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MANTISSA_DIR)
	$(PY-MANTISSA_UNZIP) $(DL_DIR)/$(PY-MANTISSA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MANTISSA_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MANTISSA_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MANTISSA_DIR) $(PY-MANTISSA_BUILD_DIR)/2.4
	(cd $(PY-MANTISSA_BUILD_DIR)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MANTISSA_DIR)
	$(PY-MANTISSA_UNZIP) $(DL_DIR)/$(PY-MANTISSA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MANTISSA_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MANTISSA_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MANTISSA_DIR) $(PY-MANTISSA_BUILD_DIR)/2.5
	(cd $(PY-MANTISSA_BUILD_DIR)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-mantissa-unpack: $(PY-MANTISSA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MANTISSA_BUILD_DIR)/.built: $(PY-MANTISSA_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-MANTISSA_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-MANTISSA_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-mantissa: $(PY-MANTISSA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MANTISSA_BUILD_DIR)/.staged: $(PY-MANTISSA_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-MANTISSA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-mantissa-stage: $(PY-MANTISSA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mantissa
#
$(PY24-MANTISSA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-mantissa" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MANTISSA_PRIORITY)" >>$@
	@echo "Section: $(PY-MANTISSA_SECTION)" >>$@
	@echo "Version: $(PY-MANTISSA_VERSION)-$(PY-MANTISSA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MANTISSA_MAINTAINER)" >>$@
	@echo "Source: $(PY-MANTISSA_SITE)/$(PY-MANTISSA_SOURCE)" >>$@
	@echo "Description: $(PY-MANTISSA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-MANTISSA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MANTISSA_CONFLICTS)" >>$@

$(PY25-MANTISSA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-mantissa" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MANTISSA_PRIORITY)" >>$@
	@echo "Section: $(PY-MANTISSA_SECTION)" >>$@
	@echo "Version: $(PY-MANTISSA_VERSION)-$(PY-MANTISSA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MANTISSA_MAINTAINER)" >>$@
	@echo "Source: $(PY-MANTISSA_SITE)/$(PY-MANTISSA_SOURCE)" >>$@
	@echo "Description: $(PY-MANTISSA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MANTISSA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MANTISSA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MANTISSA_IPK_DIR)/opt/sbin or $(PY-MANTISSA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MANTISSA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MANTISSA_IPK_DIR)/opt/etc/py-mantissa/...
# Documentation files should be installed in $(PY-MANTISSA_IPK_DIR)/opt/doc/py-mantissa/...
# Daemon startup scripts should be installed in $(PY-MANTISSA_IPK_DIR)/opt/etc/init.d/S??py-mantissa
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MANTISSA_IPK): $(PY-MANTISSA_BUILD_DIR)/.built
	rm -rf $(PY24-MANTISSA_IPK_DIR) $(BUILD_DIR)/py-mantissa_*_$(TARGET_ARCH).ipk
	(cd $(PY-MANTISSA_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-MANTISSA_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-MANTISSA_IPK_DIR)/CONTROL/control
	echo $(PY-MANTISSA_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-MANTISSA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MANTISSA_IPK_DIR)

$(PY25-MANTISSA_IPK): $(PY-MANTISSA_BUILD_DIR)/.built
	rm -rf $(PY25-MANTISSA_IPK_DIR) $(BUILD_DIR)/py25-mantissa_*_$(TARGET_ARCH).ipk
	(cd $(PY-MANTISSA_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-MANTISSA_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-MANTISSA_IPK_DIR)/CONTROL/control
	echo $(PY-MANTISSA_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-MANTISSA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MANTISSA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mantissa-ipk: $(PY24-MANTISSA_IPK) $(PY25-MANTISSA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mantissa-clean:
	-$(MAKE) -C $(PY-MANTISSA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mantissa-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MANTISSA_DIR) $(PY-MANTISSA_BUILD_DIR)
	rm -rf $(PY24-MANTISSA_IPK_DIR) $(PY24-MANTISSA_IPK)
	rm -rf $(PY25-MANTISSA_IPK_DIR) $(PY25-MANTISSA_IPK)

#
# Some sanity check for the package.
#
py-mantissa-check: $(PY24-MANTISSA_IPK) $(PY25-MANTISSA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MANTISSA_IPK) $(PY25-MANTISSA_IPK)
