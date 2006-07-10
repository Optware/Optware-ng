###########################################################
#
# py-moin
#
###########################################################

#
# PY-MOIN_VERSION, PY-MOIN_SITE and PY-MOIN_SOURCE define
# the upstream location of the source code for the package.
# PY-MOIN_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MOIN_UNZIP is the command used to unzip the source.
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
PY-MOIN_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/moin
PY-MOIN_VERSION=1.5.4
PY-MOIN_SOURCE=moin-$(PY-MOIN_VERSION).tar.gz
PY-MOIN_DIR=moin-$(PY-MOIN_VERSION)
PY-MOIN_UNZIP=zcat
PY-MOIN_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-MOIN_DESCRIPTION=MoinMoin is a nice and easy WikiEngine with advanced features, providing collaboration on easily editable web pages.
PY-MOIN_SECTION=web
PY-MOIN_PRIORITY=optional
PY-MOIN_DEPENDS=python
PY-MOIN_CONFLICTS=

#
# PY-MOIN_IPK_VERSION should be incremented when the ipk changes.
#
PY-MOIN_IPK_VERSION=1

#
# PY-MOIN_CONFFILES should be a list of user-editable files
#PY-MOIN_CONFFILES=/opt/etc/py-moin.conf /opt/etc/init.d/SXXpy-moin

#
# PY-MOIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-MOIN_PATCHES=$(PY-MOIN_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MOIN_CPPFLAGS=
PY-MOIN_LDFLAGS=

#
# PY-MOIN_BUILD_DIR is the directory in which the build is done.
# PY-MOIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MOIN_IPK_DIR is the directory in which the ipk is built.
# PY-MOIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MOIN_BUILD_DIR=$(BUILD_DIR)/py-moin
PY-MOIN_SOURCE_DIR=$(SOURCE_DIR)/py-moin
PY-MOIN_IPK_DIR=$(BUILD_DIR)/py-moin-$(PY-MOIN_VERSION)-ipk
PY-MOIN_IPK=$(BUILD_DIR)/py-moin_$(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MOIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-MOIN_SITE)/$(PY-MOIN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-moin-source: $(DL_DIR)/$(PY-MOIN_SOURCE) $(PY-MOIN_PATCHES)

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
$(PY-MOIN_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MOIN_SOURCE) $(PY-MOIN_PATCHES)
	rm -rf $(BUILD_DIR)/$(PY-MOIN_DIR) $(PY-MOIN_BUILD_DIR)
	$(PY-MOIN_UNZIP) $(DL_DIR)/$(PY-MOIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-MOIN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MOIN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MOIN_DIR) $(PY-MOIN_BUILD_DIR)
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python") >> $(PY-MOIN_BUILD_DIR)/setup.cfg
	touch $(PY-MOIN_BUILD_DIR)/.configured

py-moin-unpack: $(PY-MOIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MOIN_BUILD_DIR)/.built: $(PY-MOIN_BUILD_DIR)/.configured
	rm -f $(PY-MOIN_BUILD_DIR)/.built
	cd $(PY-MOIN_BUILD_DIR); \
	    python2.4 setup.py build;
	touch $(PY-MOIN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-moin: $(PY-MOIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MOIN_BUILD_DIR)/.staged: $(PY-MOIN_BUILD_DIR)/.built
	rm -f $(PY-MOIN_BUILD_DIR)/.staged
	$(MAKE) -C $(PY-MOIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-MOIN_BUILD_DIR)/.staged

py-moin-stage: $(PY-MOIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-moin
#
$(PY-MOIN_IPK_DIR)/CONTROL/control:
	@install -d $(PY-MOIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-moin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MOIN_PRIORITY)" >>$@
	@echo "Section: $(PY-MOIN_SECTION)" >>$@
	@echo "Version: $(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MOIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-MOIN_SITE)/$(PY-MOIN_SOURCE)" >>$@
	@echo "Description: $(PY-MOIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-MOIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MOIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MOIN_IPK_DIR)/opt/sbin or $(PY-MOIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MOIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MOIN_IPK_DIR)/opt/etc/py-moin/...
# Documentation files should be installed in $(PY-MOIN_IPK_DIR)/opt/doc/py-moin/...
# Daemon startup scripts should be installed in $(PY-MOIN_IPK_DIR)/opt/etc/init.d/S??py-moin
#
# You may need to patch your application to make it use these locations.
#
$(PY-MOIN_IPK): $(PY-MOIN_BUILD_DIR)/.built
	rm -rf $(PY-MOIN_IPK_DIR) $(BUILD_DIR)/py-moin_*_$(TARGET_ARCH).ipk
	cd $(PY-MOIN_BUILD_DIR); \
	    python2.4 setup.py install --root=$(PY-MOIN_IPK_DIR) --prefix=/opt;
	cd $(PY-MOIN_IPK_DIR)/opt/share/moin; \
	    tar --remove-files -cvzf underlay.tar.gz underlay; \
	    rm -rf underlay
	$(MAKE) $(PY-MOIN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-MOIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-moin-ipk: $(PY-MOIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-moin-clean:
	-$(MAKE) -C $(PY-MOIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-moin-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MOIN_DIR) $(PY-MOIN_BUILD_DIR) $(PY-MOIN_IPK_DIR) $(PY-MOIN_IPK)
