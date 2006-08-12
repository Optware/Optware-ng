###########################################################
#
# pyrex
#
###########################################################
#
# PYREX_VERSION, PYREX_SITE and PYREX_SOURCE define
# the upstream location of the source code for the package.
# PYREX_DIR is the directory which is created when the source
# archive is unpacked.
# PYREX_UNZIP is the command used to unzip the source.
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
PYREX_SITE=http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex
PYREX_VERSION=0.9.4.1
PYREX_SOURCE=Pyrex-$(PYREX_VERSION).tar.gz
PYREX_DIR=Pyrex-$(PYREX_VERSION)
PYREX_UNZIP=zcat
PYREX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PYREX_DESCRIPTION=A Language for Writing Python Extension Modules.
PYREX_SECTION=lang
PYREX_PRIORITY=optional
PYREX_DEPENDS=python
PYREX_SUGGESTS=
PYREX_CONFLICTS=

#
# PYREX_IPK_VERSION should be incremented when the ipk changes.
#
PYREX_IPK_VERSION=2

#
# PYREX_CONFFILES should be a list of user-editable files
#PYREX_CONFFILES=/opt/etc/pyrex.conf /opt/etc/init.d/SXXpyrex

#
# PYREX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PYREX_PATCHES=$(PYREX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYREX_CPPFLAGS=
PYREX_LDFLAGS=

#
# PYREX_BUILD_DIR is the directory in which the build is done.
# PYREX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYREX_IPK_DIR is the directory in which the ipk is built.
# PYREX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYREX_BUILD_DIR=$(BUILD_DIR)/pyrex
PYREX_SOURCE_DIR=$(SOURCE_DIR)/pyrex
PYREX_IPK_DIR=$(BUILD_DIR)/pyrex-$(PYREX_VERSION)-ipk
PYREX_IPK=$(BUILD_DIR)/pyrex_$(PYREX_VERSION)-$(PYREX_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYREX_SOURCE):
	$(WGET) -P $(DL_DIR) $(PYREX_SITE)/$(PYREX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pyrex-source: $(DL_DIR)/$(PYREX_SOURCE) $(PYREX_PATCHES)

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
$(PYREX_BUILD_DIR)/.configured: $(DL_DIR)/$(PYREX_SOURCE) $(PYREX_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PYREX_DIR) $(PYREX_BUILD_DIR)
	$(PYREX_UNZIP) $(DL_DIR)/$(PYREX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PYREX_PATCHES) | patch -d $(BUILD_DIR)/$(PYREX_DIR) -p1
	mv $(BUILD_DIR)/$(PYREX_DIR) $(PYREX_BUILD_DIR)
	(cd $(PYREX_BUILD_DIR); \
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
	touch $(PYREX_BUILD_DIR)/.configured

pyrex-unpack: $(PYREX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYREX_BUILD_DIR)/.built: $(PYREX_BUILD_DIR)/.configured
	rm -f $(PYREX_BUILD_DIR)/.built
	(cd $(PYREX_BUILD_DIR); \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PYREX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
pyrex: $(PYREX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYREX_BUILD_DIR)/.staged: $(PYREX_BUILD_DIR)/.built
	rm -f $(PYREX_BUILD_DIR)/.staged
	(cd $(PYREX_BUILD_DIR); \
	    python2.4 setup.py install --root=$(STAGING_DIR) --prefix=/opt; \
	)
#	sed -i -e 's|#!/opt/bin/python|#!/usr/bin/env python2.4|' $(STAGING_PREFIX)/bin/pyrexc
	touch $(PYREX_BUILD_DIR)/.staged

pyrex-stage: $(PYREX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pyrex
#
$(PYREX_IPK_DIR)/CONTROL/control:
	@install -d $(PYREX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pyrex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYREX_PRIORITY)" >>$@
	@echo "Section: $(PYREX_SECTION)" >>$@
	@echo "Version: $(PYREX_VERSION)-$(PYREX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYREX_MAINTAINER)" >>$@
	@echo "Source: $(PYREX_SITE)/$(PYREX_SOURCE)" >>$@
	@echo "Description: $(PYREX_DESCRIPTION)" >>$@
	@echo "Depends: $(PYREX_DEPENDS)" >>$@
	@echo "Conflicts: $(PYREX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYREX_IPK_DIR)/opt/sbin or $(PYREX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYREX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYREX_IPK_DIR)/opt/etc/pyrex/...
# Documentation files should be installed in $(PYREX_IPK_DIR)/opt/doc/pyrex/...
# Daemon startup scripts should be installed in $(PYREX_IPK_DIR)/opt/etc/init.d/S??pyrex
#
# You may need to patch your application to make it use these locations.
#
$(PYREX_IPK): $(PYREX_BUILD_DIR)/.built
	rm -rf $(PYREX_IPK_DIR) $(BUILD_DIR)/pyrex_*_$(TARGET_ARCH).ipk
	(cd $(PYREX_BUILD_DIR); \
	    python2.4 setup.py install --root=$(PYREX_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PYREX_IPK_DIR)/opt/lib/python2.4/site-packages/pyrex/*.so
	$(MAKE) $(PYREX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYREX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pyrex-ipk: $(PYREX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pyrex-clean:
	-$(MAKE) -C $(PYREX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pyrex-dirclean:
	rm -rf $(BUILD_DIR)/$(PYREX_DIR) $(PYREX_BUILD_DIR) $(PYREX_IPK_DIR) $(PYREX_IPK)
