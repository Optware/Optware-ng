###########################################################
#
# py-bazaar-ng
#
###########################################################

#
# PY-BAZAAR-NG_VERSION, PY-BAZAAR-NG_SITE and PY-BAZAAR-NG_SOURCE define
# the upstream location of the source code for the package.
# PY-BAZAAR-NG_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BAZAAR-NG_UNZIP is the command used to unzip the source.
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
PY-BAZAAR-NG_VERSION=0.9
PY-BAZAAR-NG_SITE=http://bazaar-vcs.org/pkg
PY-BAZAAR-NG_SOURCE=bzr-$(PY-BAZAAR-NG_VERSION).tar.gz
PY-BAZAAR-NG_DIR=bzr-$(PY-BAZAAR-NG_VERSION)
PY-BAZAAR-NG_UNZIP=zcat
PY-BAZAAR-NG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BAZAAR-NG_DESCRIPTION=A decentralized revision control system designed to be easy for developers and end users alike.
PY-BAZAAR-NG_SECTION=misc
PY-BAZAAR-NG_PRIORITY=optional
PY-BAZAAR-NG_DEPENDS=python, py-celementtree
PY-BAZAAR-NG_CONFLICTS=

#
# PY-BAZAAR-NG_IPK_VERSION should be incremented when the ipk changes.
#
PY-BAZAAR-NG_IPK_VERSION=1

#
# PY-BAZAAR-NG_CONFFILES should be a list of user-editable files
#PY-BAZAAR-NG_CONFFILES=/opt/etc/py-bazaar-ng.conf /opt/etc/init.d/SXXpy-bazaar-ng

#
# PY-BAZAAR-NG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BAZAAR-NG_PATCHES=$(PY-BAZAAR-NG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BAZAAR-NG_CPPFLAGS=
PY-BAZAAR-NG_LDFLAGS=

#
# PY-BAZAAR-NG_BUILD_DIR is the directory in which the build is done.
# PY-BAZAAR-NG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BAZAAR-NG_IPK_DIR is the directory in which the ipk is built.
# PY-BAZAAR-NG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BAZAAR-NG_BUILD_DIR=$(BUILD_DIR)/py-bazaar-ng
PY-BAZAAR-NG_SOURCE_DIR=$(SOURCE_DIR)/py-bazaar-ng
PY-BAZAAR-NG_IPK_DIR=$(BUILD_DIR)/py-bazaar-ng-$(PY-BAZAAR-NG_VERSION)-ipk
PY-BAZAAR-NG_IPK=$(BUILD_DIR)/py-bazaar-ng_$(PY-BAZAAR-NG_VERSION)-$(PY-BAZAAR-NG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BAZAAR-NG_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-BAZAAR-NG_SITE)/$(PY-BAZAAR-NG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-bazaar-ng-source: $(DL_DIR)/$(PY-BAZAAR-NG_SOURCE) $(PY-BAZAAR-NG_PATCHES)

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
$(PY-BAZAAR-NG_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BAZAAR-NG_SOURCE) $(PY-BAZAAR-NG_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PY-BAZAAR-NG_DIR) $(PY-BAZAAR-NG_BUILD_DIR)
	$(PY-BAZAAR-NG_UNZIP) $(DL_DIR)/$(PY-BAZAAR-NG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-BAZAAR-NG_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BAZAAR-NG_DIR) -p1
	mv $(BUILD_DIR)/$(PY-BAZAAR-NG_DIR) $(PY-BAZAAR-NG_BUILD_DIR)
	(cd $(PY-BAZAAR-NG_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	)
	touch $(PY-BAZAAR-NG_BUILD_DIR)/.configured

py-bazaar-ng-unpack: $(PY-BAZAAR-NG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BAZAAR-NG_BUILD_DIR)/.built: $(PY-BAZAAR-NG_BUILD_DIR)/.configured
	rm -f $(PY-BAZAAR-NG_BUILD_DIR)/.built
	(cd $(PY-BAZAAR-NG_BUILD_DIR); \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-BAZAAR-NG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-bazaar-ng: $(PY-BAZAAR-NG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-BAZAAR-NG_BUILD_DIR)/.staged: $(PY-BAZAAR-NG_BUILD_DIR)/.built
	rm -f $(PY-BAZAAR-NG_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-BAZAAR-NG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-BAZAAR-NG_BUILD_DIR)/.staged

py-bazaar-ng-stage: $(PY-BAZAAR-NG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-bazaar-ng
#
$(PY-BAZAAR-NG_IPK_DIR)/CONTROL/control:
	@install -d $(PY-BAZAAR-NG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-bazaar-ng" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BAZAAR-NG_PRIORITY)" >>$@
	@echo "Section: $(PY-BAZAAR-NG_SECTION)" >>$@
	@echo "Version: $(PY-BAZAAR-NG_VERSION)-$(PY-BAZAAR-NG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BAZAAR-NG_MAINTAINER)" >>$@
	@echo "Source: $(PY-BAZAAR-NG_SITE)/$(PY-BAZAAR-NG_SOURCE)" >>$@
	@echo "Description: $(PY-BAZAAR-NG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-BAZAAR-NG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BAZAAR-NG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BAZAAR-NG_IPK_DIR)/opt/sbin or $(PY-BAZAAR-NG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BAZAAR-NG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BAZAAR-NG_IPK_DIR)/opt/etc/py-bazaar-ng/...
# Documentation files should be installed in $(PY-BAZAAR-NG_IPK_DIR)/opt/doc/py-bazaar-ng/...
# Daemon startup scripts should be installed in $(PY-BAZAAR-NG_IPK_DIR)/opt/etc/init.d/S??py-bazaar-ng
#
# You may need to patch your application to make it use these locations.
#
$(PY-BAZAAR-NG_IPK): $(PY-BAZAAR-NG_BUILD_DIR)/.built
	rm -rf $(PY-BAZAAR-NG_IPK_DIR) $(BUILD_DIR)/py-bazaar-ng_*_$(TARGET_ARCH).ipk
	(cd $(PY-BAZAAR-NG_BUILD_DIR); \
	    python2.4 setup.py install --root=$(PY-BAZAAR-NG_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY-BAZAAR-NG_IPK_DIR)/opt/lib/python2.4/site-packages/bazaar-ng/*.so
	$(MAKE) $(PY-BAZAAR-NG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-BAZAAR-NG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-bazaar-ng-ipk: $(PY-BAZAAR-NG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-bazaar-ng-clean:
	-$(MAKE) -C $(PY-BAZAAR-NG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-bazaar-ng-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BAZAAR-NG_DIR) $(PY-BAZAAR-NG_BUILD_DIR) $(PY-BAZAAR-NG_IPK_DIR) $(PY-BAZAAR-NG_IPK)
