###########################################################
#
# py-htconsole
#
###########################################################

#
# PY-HTCONSOLE_VERSION, PY-HTCONSOLE_SITE and PY-HTCONSOLE_SOURCE define
# the upstream location of the source code for the package.
# PY-HTCONSOLE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-HTCONSOLE_UNZIP is the command used to unzip the source.
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
PY-HTCONSOLE_SITE=http://cheeseshop.python.org/packages/source/H/HTConsole
PY-HTCONSOLE_VERSION=0.2
PY-HTCONSOLE_SOURCE=HTConsole-$(PY-HTCONSOLE_VERSION).tar.gz
PY-HTCONSOLE_DIR=HTConsole-$(PY-HTCONSOLE_VERSION)
PY-HTCONSOLE_UNZIP=zcat
PY-HTCONSOLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-HTCONSOLE_DESCRIPTION=An interactive, explorative Python console available as a web page.
PY-HTCONSOLE_SECTION=misc
PY-HTCONSOLE_PRIORITY=optional
PY-HTCONSOLE_DEPENDS=python
PY-HTCONSOLE_CONFLICTS=

#
# PY-HTCONSOLE_IPK_VERSION should be incremented when the ipk changes.
#
PY-HTCONSOLE_IPK_VERSION=1

#
# PY-HTCONSOLE_CONFFILES should be a list of user-editable files
#PY-HTCONSOLE_CONFFILES=/opt/etc/py-htconsole.conf /opt/etc/init.d/SXXpy-htconsole

#
# PY-HTCONSOLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-HTCONSOLE_PATCHES=$(PY-HTCONSOLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-HTCONSOLE_CPPFLAGS=
PY-HTCONSOLE_LDFLAGS=

#
# PY-HTCONSOLE_BUILD_DIR is the directory in which the build is done.
# PY-HTCONSOLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-HTCONSOLE_IPK_DIR is the directory in which the ipk is built.
# PY-HTCONSOLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-HTCONSOLE_BUILD_DIR=$(BUILD_DIR)/py-htconsole
PY-HTCONSOLE_SOURCE_DIR=$(SOURCE_DIR)/py-htconsole
PY-HTCONSOLE_IPK_DIR=$(BUILD_DIR)/py-htconsole-$(PY-HTCONSOLE_VERSION)-ipk
PY-HTCONSOLE_IPK=$(BUILD_DIR)/py-htconsole_$(PY-HTCONSOLE_VERSION)-$(PY-HTCONSOLE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-HTCONSOLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-HTCONSOLE_SITE)/$(PY-HTCONSOLE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-htconsole-source: $(DL_DIR)/$(PY-HTCONSOLE_SOURCE) $(PY-HTCONSOLE_PATCHES)

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
$(PY-HTCONSOLE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-HTCONSOLE_SOURCE) $(PY-HTCONSOLE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-HTCONSOLE_DIR) $(PY-HTCONSOLE_BUILD_DIR)
	$(PY-HTCONSOLE_UNZIP) $(DL_DIR)/$(PY-HTCONSOLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HTCONSOLE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-HTCONSOLE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HTCONSOLE_DIR) $(PY-HTCONSOLE_BUILD_DIR)
	(cd $(PY-HTCONSOLE_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-HTCONSOLE_BUILD_DIR)/.configured

py-htconsole-unpack: $(PY-HTCONSOLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-HTCONSOLE_BUILD_DIR)/.built: $(PY-HTCONSOLE_BUILD_DIR)/.configured
	rm -f $(PY-HTCONSOLE_BUILD_DIR)/.built
	(cd $(PY-HTCONSOLE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py build)
	touch $(PY-HTCONSOLE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-htconsole: $(PY-HTCONSOLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-HTCONSOLE_BUILD_DIR)/.staged: $(PY-HTCONSOLE_BUILD_DIR)/.built
	rm -f $(PY-HTCONSOLE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-HTCONSOLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-HTCONSOLE_BUILD_DIR)/.staged

py-htconsole-stage: $(PY-HTCONSOLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-htconsole
#
$(PY-HTCONSOLE_IPK_DIR)/CONTROL/control:
	@install -d $(PY-HTCONSOLE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-htconsole" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HTCONSOLE_PRIORITY)" >>$@
	@echo "Section: $(PY-HTCONSOLE_SECTION)" >>$@
	@echo "Version: $(PY-HTCONSOLE_VERSION)-$(PY-HTCONSOLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HTCONSOLE_MAINTAINER)" >>$@
	@echo "Source: $(PY-HTCONSOLE_SITE)/$(PY-HTCONSOLE_SOURCE)" >>$@
	@echo "Description: $(PY-HTCONSOLE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-HTCONSOLE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HTCONSOLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-HTCONSOLE_IPK_DIR)/opt/sbin or $(PY-HTCONSOLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-HTCONSOLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-HTCONSOLE_IPK_DIR)/opt/etc/py-htconsole/...
# Documentation files should be installed in $(PY-HTCONSOLE_IPK_DIR)/opt/doc/py-htconsole/...
# Daemon startup scripts should be installed in $(PY-HTCONSOLE_IPK_DIR)/opt/etc/init.d/S??py-htconsole
#
# You may need to patch your application to make it use these locations.
#
$(PY-HTCONSOLE_IPK): $(PY-HTCONSOLE_BUILD_DIR)/.built
	rm -rf $(PY-HTCONSOLE_IPK_DIR) $(BUILD_DIR)/py-htconsole_*_$(TARGET_ARCH).ipk
	(cd $(PY-HTCONSOLE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-HTCONSOLE_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-HTCONSOLE_IPK_DIR)/CONTROL/control
#	echo $(PY-HTCONSOLE_CONFFILES) | sed -e 's/ /\n/g' > $(PY-HTCONSOLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-HTCONSOLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-htconsole-ipk: $(PY-HTCONSOLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-htconsole-clean:
	-$(MAKE) -C $(PY-HTCONSOLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-htconsole-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-HTCONSOLE_DIR) $(PY-HTCONSOLE_BUILD_DIR) $(PY-HTCONSOLE_IPK_DIR) $(PY-HTCONSOLE_IPK)
