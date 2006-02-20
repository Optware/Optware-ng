###########################################################
#
# py-elementtree
#
###########################################################

#
# PY-ELEMENTTREE_VERSION, PY-ELEMENTTREE_SITE and PY-ELEMENTTREE_SOURCE define
# the upstream location of the source code for the package.
# PY-ELEMENTTREE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ELEMENTTREE_UNZIP is the command used to unzip the source.
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
PY-ELEMENTTREE_SITE=http://effbot.org/downloads
PY-ELEMENTTREE_VERSION=1.2.6-20050316
PY-ELEMENTTREE_SOURCE=elementtree-$(PY-ELEMENTTREE_VERSION).tar.gz
PY-ELEMENTTREE_DIR=elementtree-$(PY-ELEMENTTREE_VERSION)
PY-ELEMENTTREE_UNZIP=zcat
PY-ELEMENTTREE_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-ELEMENTTREE_DESCRIPTION=A toolkit that contains a number of light-weight components for working with XML.
PY-ELEMENTTREE_SECTION=misc
PY-ELEMENTTREE_PRIORITY=optional
PY-ELEMENTTREE_DEPENDS=python
PY-ELEMENTTREE_CONFLICTS=

#
# PY-ELEMENTTREE_IPK_VERSION should be incremented when the ipk changes.
#
PY-ELEMENTTREE_IPK_VERSION=2

#
# PY-ELEMENTTREE_CONFFILES should be a list of user-editable files
#PY-ELEMENTTREE_CONFFILES=/opt/etc/py-elementtree.conf /opt/etc/init.d/SXXpy-elementtree

#
# PY-ELEMENTTREE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ELEMENTTREE_PATCHES=$(PY-ELEMENTTREE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ELEMENTTREE_CPPFLAGS=
PY-ELEMENTTREE_LDFLAGS=

#
# PY-ELEMENTTREE_BUILD_DIR is the directory in which the build is done.
# PY-ELEMENTTREE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ELEMENTTREE_IPK_DIR is the directory in which the ipk is built.
# PY-ELEMENTTREE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ELEMENTTREE_BUILD_DIR=$(BUILD_DIR)/py-elementtree
PY-ELEMENTTREE_SOURCE_DIR=$(SOURCE_DIR)/py-elementtree
PY-ELEMENTTREE_IPK_DIR=$(BUILD_DIR)/py-elementtree-$(PY-ELEMENTTREE_VERSION)-ipk
PY-ELEMENTTREE_IPK=$(BUILD_DIR)/py-elementtree_$(PY-ELEMENTTREE_VERSION)-$(PY-ELEMENTTREE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ELEMENTTREE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-ELEMENTTREE_SITE)/$(PY-ELEMENTTREE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-elementtree-source: $(DL_DIR)/$(PY-ELEMENTTREE_SOURCE) $(PY-ELEMENTTREE_PATCHES)

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
$(PY-ELEMENTTREE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ELEMENTTREE_SOURCE) $(PY-ELEMENTTREE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-ELEMENTTREE_DIR) $(PY-ELEMENTTREE_BUILD_DIR)
	$(PY-ELEMENTTREE_UNZIP) $(DL_DIR)/$(PY-ELEMENTTREE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ELEMENTTREE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-ELEMENTTREE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ELEMENTTREE_DIR) $(PY-ELEMENTTREE_BUILD_DIR)
	(cd $(PY-ELEMENTTREE_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") > setup.cfg \
	)
	touch $(PY-ELEMENTTREE_BUILD_DIR)/.configured

py-elementtree-unpack: $(PY-ELEMENTTREE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ELEMENTTREE_BUILD_DIR)/.built: $(PY-ELEMENTTREE_BUILD_DIR)/.configured
	rm -f $(PY-ELEMENTTREE_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-ELEMENTTREE_BUILD_DIR)
	touch $(PY-ELEMENTTREE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-elementtree: $(PY-ELEMENTTREE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ELEMENTTREE_BUILD_DIR)/.staged: $(PY-ELEMENTTREE_BUILD_DIR)/.built
	rm -f $(PY-ELEMENTTREE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-ELEMENTTREE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-ELEMENTTREE_BUILD_DIR)/.staged

py-elementtree-stage: $(PY-ELEMENTTREE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-elementtree
#
$(PY-ELEMENTTREE_IPK_DIR)/CONTROL/control:
	@install -d $(PY-ELEMENTTREE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-elementtree" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ELEMENTTREE_PRIORITY)" >>$@
	@echo "Section: $(PY-ELEMENTTREE_SECTION)" >>$@
	@echo "Version: $(PY-ELEMENTTREE_VERSION)-$(PY-ELEMENTTREE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ELEMENTTREE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ELEMENTTREE_SITE)/$(PY-ELEMENTTREE_SOURCE)" >>$@
	@echo "Description: $(PY-ELEMENTTREE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-ELEMENTTREE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ELEMENTTREE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ELEMENTTREE_IPK_DIR)/opt/sbin or $(PY-ELEMENTTREE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ELEMENTTREE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-ELEMENTTREE_IPK_DIR)/opt/etc/py-elementtree/...
# Documentation files should be installed in $(PY-ELEMENTTREE_IPK_DIR)/opt/doc/py-elementtree/...
# Daemon startup scripts should be installed in $(PY-ELEMENTTREE_IPK_DIR)/opt/etc/init.d/S??py-elementtree
#
# You may need to patch your application to make it use these locations.
#
$(PY-ELEMENTTREE_IPK): $(PY-ELEMENTTREE_BUILD_DIR)/.built
	rm -rf $(PY-ELEMENTTREE_IPK_DIR) $(BUILD_DIR)/py-elementtree_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-ELEMENTTREE_BUILD_DIR) DESTDIR=$(PY-ELEMENTTREE_IPK_DIR) install
	(cd $(PY-ELEMENTTREE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY-ELEMENTTREE_IPK_DIR) --prefix=/opt --single-version-externally-managed)
#	install -d $(PY-ELEMENTTREE_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-ELEMENTTREE_SOURCE_DIR)/py-elementtree.conf $(PY-ELEMENTTREE_IPK_DIR)/opt/etc/py-elementtree.conf
#	install -d $(PY-ELEMENTTREE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-ELEMENTTREE_SOURCE_DIR)/rc.py-elementtree $(PY-ELEMENTTREE_IPK_DIR)/opt/etc/init.d/SXXpy-elementtree
	$(MAKE) $(PY-ELEMENTTREE_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-ELEMENTTREE_SOURCE_DIR)/postinst $(PY-ELEMENTTREE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-ELEMENTTREE_SOURCE_DIR)/prerm $(PY-ELEMENTTREE_IPK_DIR)/CONTROL/prerm
#	echo $(PY-ELEMENTTREE_CONFFILES) | sed -e 's/ /\n/g' > $(PY-ELEMENTTREE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-ELEMENTTREE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-elementtree-ipk: $(PY-ELEMENTTREE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-elementtree-clean:
	-$(MAKE) -C $(PY-ELEMENTTREE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-elementtree-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ELEMENTTREE_DIR) $(PY-ELEMENTTREE_BUILD_DIR) $(PY-ELEMENTTREE_IPK_DIR) $(PY-ELEMENTTREE_IPK)
