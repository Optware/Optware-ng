###########################################################
#
# py-axiom
#
###########################################################

#
# PY-AXIOM_VERSION, PY-AXIOM_SITE and PY-AXIOM_SOURCE define
# the upstream location of the source code for the package.
# PY-AXIOM_DIR is the directory which is created when the source
# archive is unpacked.
# PY-AXIOM_UNZIP is the command used to unzip the source.
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
PY-AXIOM_VERSION=0.5.27
PY-AXIOM_SOURCE=Axiom-$(PY-AXIOM_VERSION).tar.gz
PY-AXIOM_SITE=http://divmod.org/trac/attachment/wiki/SoftwareReleases/$(PY-AXIOM_SOURCE)?format=raw
PY-AXIOM_DIR=Axiom-$(PY-AXIOM_VERSION)
PY-AXIOM_UNZIP=zcat
PY-AXIOM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-AXIOM_DESCRIPTION=An object database or object-relational mapper.
PY-AXIOM_SECTION=misc
PY-AXIOM_PRIORITY=optional
PY24-AXIOM_DEPENDS=python24, py24-epsilon, py24-sqlite
PY25-AXIOM_DEPENDS=python25, py25-epsilon
PY-AXIOM_CONFLICTS=

#
# PY-AXIOM_IPK_VERSION should be incremented when the ipk changes.
#
PY-AXIOM_IPK_VERSION=1

#
# PY-AXIOM_CONFFILES should be a list of user-editable files
#PY-AXIOM_CONFFILES=/opt/etc/py-axiom.conf /opt/etc/init.d/SXXpy-axiom

#
# PY-AXIOM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-AXIOM_PATCHES=$(PY-AXIOM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-AXIOM_CPPFLAGS=
PY-AXIOM_LDFLAGS=

#
# PY-AXIOM_BUILD_DIR is the directory in which the build is done.
# PY-AXIOM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-AXIOM_IPK_DIR is the directory in which the ipk is built.
# PY-AXIOM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-AXIOM_BUILD_DIR=$(BUILD_DIR)/py-axiom
PY-AXIOM_SOURCE_DIR=$(SOURCE_DIR)/py-axiom

PY24-AXIOM_IPK_DIR=$(BUILD_DIR)/py24-axiom-$(PY-AXIOM_VERSION)-ipk
PY24-AXIOM_IPK=$(BUILD_DIR)/py24-axiom_$(PY-AXIOM_VERSION)-$(PY-AXIOM_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-AXIOM_IPK_DIR=$(BUILD_DIR)/py25-axiom-$(PY-AXIOM_VERSION)-ipk
PY25-AXIOM_IPK=$(BUILD_DIR)/py25-axiom_$(PY-AXIOM_VERSION)-$(PY-AXIOM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-axiom-source py-axiom-unpack py-axiom py-axiom-stage py-axiom-ipk py-axiom-clean py-axiom-dirclean py-axiom-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-AXIOM_SOURCE):
	$(WGET) -O $(DL_DIR)/$(PY-AXIOM_SOURCE) $(PY-AXIOM_SITE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-axiom-source: $(DL_DIR)/$(PY-AXIOM_SOURCE) $(PY-AXIOM_PATCHES)

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
$(PY-AXIOM_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-AXIOM_SOURCE) $(PY-AXIOM_PATCHES)
	$(MAKE) py-epsilon-stage
	rm -rf $(PY-AXIOM_BUILD_DIR)
	mkdir -p $(PY-AXIOM_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-AXIOM_DIR)
	$(PY-AXIOM_UNZIP) $(DL_DIR)/$(PY-AXIOM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-AXIOM_PATCHES) | patch -d $(BUILD_DIR)/$(PY-AXIOM_DIR) -p1
	mv $(BUILD_DIR)/$(PY-AXIOM_DIR) $(PY-AXIOM_BUILD_DIR)/2.4
	(cd $(PY-AXIOM_BUILD_DIR)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-AXIOM_DIR)
	$(PY-AXIOM_UNZIP) $(DL_DIR)/$(PY-AXIOM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-AXIOM_PATCHES) | patch -d $(BUILD_DIR)/$(PY-AXIOM_DIR) -p1
	mv $(BUILD_DIR)/$(PY-AXIOM_DIR) $(PY-AXIOM_BUILD_DIR)/2.5
	(cd $(PY-AXIOM_BUILD_DIR)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-axiom-unpack: $(PY-AXIOM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-AXIOM_BUILD_DIR)/.built: $(PY-AXIOM_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-AXIOM_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-AXIOM_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-axiom: $(PY-AXIOM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-AXIOM_BUILD_DIR)/.staged: $(PY-AXIOM_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-AXIOM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-axiom-stage: $(PY-AXIOM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-axiom
#
$(PY24-AXIOM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-axiom" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-AXIOM_PRIORITY)" >>$@
	@echo "Section: $(PY-AXIOM_SECTION)" >>$@
	@echo "Version: $(PY-AXIOM_VERSION)-$(PY-AXIOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-AXIOM_MAINTAINER)" >>$@
	@echo "Source: $(PY-AXIOM_SITE)/$(PY-AXIOM_SOURCE)" >>$@
	@echo "Description: $(PY-AXIOM_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-AXIOM_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-AXIOM_CONFLICTS)" >>$@

$(PY25-AXIOM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-axiom" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-AXIOM_PRIORITY)" >>$@
	@echo "Section: $(PY-AXIOM_SECTION)" >>$@
	@echo "Version: $(PY-AXIOM_VERSION)-$(PY-AXIOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-AXIOM_MAINTAINER)" >>$@
	@echo "Source: $(PY-AXIOM_SITE)/$(PY-AXIOM_SOURCE)" >>$@
	@echo "Description: $(PY-AXIOM_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-AXIOM_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-AXIOM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-AXIOM_IPK_DIR)/opt/sbin or $(PY-AXIOM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-AXIOM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-AXIOM_IPK_DIR)/opt/etc/py-axiom/...
# Documentation files should be installed in $(PY-AXIOM_IPK_DIR)/opt/doc/py-axiom/...
# Daemon startup scripts should be installed in $(PY-AXIOM_IPK_DIR)/opt/etc/init.d/S??py-axiom
#
# You may need to patch your application to make it use these locations.
#
$(PY24-AXIOM_IPK): $(PY-AXIOM_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-axiom_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-AXIOM_IPK_DIR) $(BUILD_DIR)/py24-axiom_*_$(TARGET_ARCH).ipk
	(cd $(PY-AXIOM_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-AXIOM_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-AXIOM_IPK_DIR)/CONTROL/control
	echo $(PY-AXIOM_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-AXIOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-AXIOM_IPK_DIR)

$(PY25-AXIOM_IPK): $(PY-AXIOM_BUILD_DIR)/.built
	rm -rf $(PY25-AXIOM_IPK_DIR) $(BUILD_DIR)/py25-axiom_*_$(TARGET_ARCH).ipk
	(cd $(PY-AXIOM_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-AXIOM_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-AXIOM_IPK_DIR)/CONTROL/control
	echo $(PY-AXIOM_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-AXIOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-AXIOM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-axiom-ipk: $(PY24-AXIOM_IPK) $(PY25-AXIOM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-axiom-clean:
	-$(MAKE) -C $(PY-AXIOM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-axiom-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-AXIOM_DIR) $(PY-AXIOM_BUILD_DIR)
	rm -rf $(PY24-AXIOM_IPK_DIR) $(PY24-AXIOM_IPK)
	rm -rf $(PY25-AXIOM_IPK_DIR) $(PY25-AXIOM_IPK)

#
# Some sanity check for the package.
#
py-axiom-check: $(PY24-AXIOM_IPK) $(PY25-AXIOM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-AXIOM_IPK) $(PY25-AXIOM_IPK)
