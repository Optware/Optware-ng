###########################################################
#
# py-roundup
#
###########################################################

#
# PY-ROUNDUP_VERSION, PY-ROUNDUP_SITE and PY-ROUNDUP_SOURCE define
# the upstream location of the source code for the package.
# PY-ROUNDUP_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ROUNDUP_UNZIP is the command used to unzip the source.
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
PY-ROUNDUP_SITE=http://cheeseshop.python.org/packages/source/r/roundup
PY-ROUNDUP_VERSION=1.1.1
PY-ROUNDUP_SOURCE=roundup-$(PY-ROUNDUP_VERSION).tar.gz
PY-ROUNDUP_DIR=roundup-$(PY-ROUNDUP_VERSION)
PY-ROUNDUP_UNZIP=zcat
PY-ROUNDUP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ROUNDUP_DESCRIPTION=An issue-tracking system with command-line, web and e-mail interfaces.
PY-ROUNDUP_SECTION=misc
PY-ROUNDUP_PRIORITY=optional
PY-ROUNDUP_DEPENDS=python
PY-ROUNDUP_CONFLICTS=

#
# PY-ROUNDUP_IPK_VERSION should be incremented when the ipk changes.
#
PY-ROUNDUP_IPK_VERSION=1

#
# PY-ROUNDUP_CONFFILES should be a list of user-editable files
#PY-ROUNDUP_CONFFILES=/opt/etc/py-roundup.conf /opt/etc/init.d/SXXpy-roundup

#
# PY-ROUNDUP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-ROUNDUP_PATCHES=$(PY-ROUNDUP_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ROUNDUP_CPPFLAGS=
PY-ROUNDUP_LDFLAGS=

#
# PY-ROUNDUP_BUILD_DIR is the directory in which the build is done.
# PY-ROUNDUP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ROUNDUP_IPK_DIR is the directory in which the ipk is built.
# PY-ROUNDUP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ROUNDUP_BUILD_DIR=$(BUILD_DIR)/py-roundup
PY-ROUNDUP_SOURCE_DIR=$(SOURCE_DIR)/py-roundup
PY-ROUNDUP_IPK_DIR=$(BUILD_DIR)/py-roundup-$(PY-ROUNDUP_VERSION)-ipk
PY-ROUNDUP_IPK=$(BUILD_DIR)/py-roundup_$(PY-ROUNDUP_VERSION)-$(PY-ROUNDUP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ROUNDUP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-ROUNDUP_SITE)/$(PY-ROUNDUP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-roundup-source: $(DL_DIR)/$(PY-ROUNDUP_SOURCE) $(PY-ROUNDUP_PATCHES)

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
$(PY-ROUNDUP_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ROUNDUP_SOURCE) $(PY-ROUNDUP_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PY-ROUNDUP_DIR) $(PY-ROUNDUP_BUILD_DIR)
	$(PY-ROUNDUP_UNZIP) $(DL_DIR)/$(PY-ROUNDUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-ROUNDUP_PATCHES) | patch -d $(BUILD_DIR)/$(PY-ROUNDUP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ROUNDUP_DIR) $(PY-ROUNDUP_BUILD_DIR)
	(cd $(PY-ROUNDUP_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $(PY-ROUNDUP_BUILD_DIR)/.configured

py-roundup-unpack: $(PY-ROUNDUP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ROUNDUP_BUILD_DIR)/.built: $(PY-ROUNDUP_BUILD_DIR)/.configured
	rm -f $(PY-ROUNDUP_BUILD_DIR)/.built
	(cd $(PY-ROUNDUP_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-ROUNDUP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-roundup: $(PY-ROUNDUP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ROUNDUP_BUILD_DIR)/.staged: $(PY-ROUNDUP_BUILD_DIR)/.built
	rm -f $(PY-ROUNDUP_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-ROUNDUP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-ROUNDUP_BUILD_DIR)/.staged

py-roundup-stage: $(PY-ROUNDUP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-roundup
#
$(PY-ROUNDUP_IPK_DIR)/CONTROL/control:
	@install -d $(PY-ROUNDUP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-roundup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ROUNDUP_PRIORITY)" >>$@
	@echo "Section: $(PY-ROUNDUP_SECTION)" >>$@
	@echo "Version: $(PY-ROUNDUP_VERSION)-$(PY-ROUNDUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ROUNDUP_MAINTAINER)" >>$@
	@echo "Source: $(PY-ROUNDUP_SITE)/$(PY-ROUNDUP_SOURCE)" >>$@
	@echo "Description: $(PY-ROUNDUP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-ROUNDUP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ROUNDUP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ROUNDUP_IPK_DIR)/opt/sbin or $(PY-ROUNDUP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ROUNDUP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-ROUNDUP_IPK_DIR)/opt/etc/py-roundup/...
# Documentation files should be installed in $(PY-ROUNDUP_IPK_DIR)/opt/doc/py-roundup/...
# Daemon startup scripts should be installed in $(PY-ROUNDUP_IPK_DIR)/opt/etc/init.d/S??py-roundup
#
# You may need to patch your application to make it use these locations.
#
$(PY-ROUNDUP_IPK): $(PY-ROUNDUP_BUILD_DIR)/.built
	rm -rf $(PY-ROUNDUP_IPK_DIR) $(BUILD_DIR)/py-roundup_*_$(TARGET_ARCH).ipk
	(cd $(PY-ROUNDUP_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py install --prefix=$(PY-ROUNDUP_IPK_DIR)/opt; \
	)
#	$(STRIP_COMMAND) `find $(PY-ROUNDUP_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	$(MAKE) $(PY-ROUNDUP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-ROUNDUP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-roundup-ipk: $(PY-ROUNDUP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-roundup-clean:
	-$(MAKE) -C $(PY-ROUNDUP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-roundup-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ROUNDUP_DIR) $(PY-ROUNDUP_BUILD_DIR) $(PY-ROUNDUP_IPK_DIR) $(PY-ROUNDUP_IPK)
