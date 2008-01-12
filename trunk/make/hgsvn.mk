###########################################################
#
# hgsvn
#
###########################################################

#
# HGSVN_VERSION, HGSVN_SITE and HGSVN_SOURCE define
# the upstream location of the source code for the package.
# HGSVN_DIR is the directory which is created when the source
# archive is unpacked.
# HGSVN_UNZIP is the command used to unzip the source.
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
HGSVN_SITE=http://pypi.python.org/packages/source/h/hgsvn
HGSVN_VERSION=0.1.5
HGSVN_SOURCE=hgsvn-$(HGSVN_VERSION).tar.gz
HGSVN_DIR=hgsvn-$(HGSVN_VERSION)
HGSVN_UNZIP=zcat
HGSVN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HGSVN_DESCRIPTION=A set of scripts to work locally on Subversion checkouts using Mercurial.
HGSVN_SECTION=misc
HGSVN_PRIORITY=optional
PY24-HGSVN_DEPENDS=python24, py-mercurial
PY25-HGSVN_DEPENDS=python25, py25-mercurial
HGSVN_CONFLICTS=

#
# HGSVN_IPK_VERSION should be incremented when the ipk changes.
#
HGSVN_IPK_VERSION=1

#
# HGSVN_CONFFILES should be a list of user-editable files
#HGSVN_CONFFILES=/opt/etc/hgsvn.conf /opt/etc/init.d/SXXhgsvn

#
# HGSVN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HGSVN_PATCHES=$(HGSVN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HGSVN_CPPFLAGS=
HGSVN_LDFLAGS=

#
# HGSVN_BUILD_DIR is the directory in which the build is done.
# HGSVN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HGSVN_IPK_DIR is the directory in which the ipk is built.
# HGSVN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HGSVN_BUILD_DIR=$(BUILD_DIR)/hgsvn
HGSVN_SOURCE_DIR=$(SOURCE_DIR)/hgsvn

PY24-HGSVN_IPK_DIR=$(BUILD_DIR)/py24-hgsvn-$(HGSVN_VERSION)-ipk
PY24-HGSVN_IPK=$(BUILD_DIR)/py24-hgsvn_$(HGSVN_VERSION)-$(HGSVN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-HGSVN_IPK_DIR=$(BUILD_DIR)/py25-hgsvn-$(HGSVN_VERSION)-ipk
PY25-HGSVN_IPK=$(BUILD_DIR)/py25-hgsvn_$(HGSVN_VERSION)-$(HGSVN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hgsvn-source hgsvn-unpack hgsvn hgsvn-stage hgsvn-ipk hgsvn-clean hgsvn-dirclean hgsvn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HGSVN_SOURCE):
	$(WGET) -P $(DL_DIR) $(HGSVN_SITE)/$(HGSVN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hgsvn-source: $(DL_DIR)/$(HGSVN_SOURCE) $(HGSVN_PATCHES)

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
$(HGSVN_BUILD_DIR)/.configured: $(DL_DIR)/$(HGSVN_SOURCE) $(HGSVN_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(HGSVN_DIR) $(@D)
	mkdir -p $(@D)
	# 2.4
	$(HGSVN_UNZIP) $(DL_DIR)/$(HGSVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(HGSVN_PATCHES) | patch -d $(BUILD_DIR)/$(HGSVN_DIR) -p1
	mv $(BUILD_DIR)/$(HGSVN_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	$(HGSVN_UNZIP) $(DL_DIR)/$(HGSVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(HGSVN_PATCHES) | patch -d $(BUILD_DIR)/$(HGSVN_DIR) -p1
	mv $(BUILD_DIR)/$(HGSVN_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

hgsvn-unpack: $(HGSVN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HGSVN_BUILD_DIR)/.built: $(HGSVN_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
hgsvn: $(HGSVN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HGSVN_BUILD_DIR)/.staged: $(HGSVN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(HGSVN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

hgsvn-stage: $(HGSVN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hgsvn
#
$(PY24-HGSVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-hgsvn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HGSVN_PRIORITY)" >>$@
	@echo "Section: $(HGSVN_SECTION)" >>$@
	@echo "Version: $(HGSVN_VERSION)-$(HGSVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HGSVN_MAINTAINER)" >>$@
	@echo "Source: $(HGSVN_SITE)/$(HGSVN_SOURCE)" >>$@
	@echo "Description: $(HGSVN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-HGSVN_DEPENDS)" >>$@
	@echo "Conflicts: $(HGSVN_CONFLICTS)" >>$@

$(PY25-HGSVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-hgsvn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HGSVN_PRIORITY)" >>$@
	@echo "Section: $(HGSVN_SECTION)" >>$@
	@echo "Version: $(HGSVN_VERSION)-$(HGSVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HGSVN_MAINTAINER)" >>$@
	@echo "Source: $(HGSVN_SITE)/$(HGSVN_SOURCE)" >>$@
	@echo "Description: $(HGSVN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-HGSVN_DEPENDS)" >>$@
	@echo "Conflicts: $(HGSVN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HGSVN_IPK_DIR)/opt/sbin or $(HGSVN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HGSVN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HGSVN_IPK_DIR)/opt/etc/hgsvn/...
# Documentation files should be installed in $(HGSVN_IPK_DIR)/opt/doc/hgsvn/...
# Daemon startup scripts should be installed in $(HGSVN_IPK_DIR)/opt/etc/init.d/S??hgsvn
#
# You may need to patch your application to make it use these locations.
#
$(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK): $(HGSVN_BUILD_DIR)/.built
	# 2.4
	rm -rf $(PY24-HGSVN_IPK_DIR) $(BUILD_DIR)/hgsvn_*_$(TARGET_ARCH).ipk
	(cd $(HGSVN_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-HGSVN_IPK_DIR) --prefix=/opt; \
	)
	for f in $(PY24-HGSVN_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-HGSVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-HGSVN_IPK_DIR)
	# 2.5
	rm -rf $(PY25-HGSVN_IPK_DIR) $(BUILD_DIR)/py25-hgsvn_*_$(TARGET_ARCH).ipk
	(cd $(HGSVN_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-HGSVN_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY25-HGSVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-HGSVN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hgsvn-ipk: $(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hgsvn-clean:
	-$(MAKE) -C $(HGSVN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hgsvn-dirclean:
	rm -rf $(BUILD_DIR)/$(HGSVN_DIR) $(HGSVN_BUILD_DIR)
	rm -rf $(PY24-HGSVN_IPK_DIR) $(PY24-HGSVN_IPK)
	rm -rf $(PY25-HGSVN_IPK_DIR) $(PY25-HGSVN_IPK)

#
# Some sanity check for the package.
#
hgsvn-check: $(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK)
