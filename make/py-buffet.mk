###########################################################
#
# py-buffet
#
###########################################################

#
# PY-BUFFET_VERSION, PY-BUFFET_SITE and PY-BUFFET_SOURCE define
# the upstream location of the source code for the package.
# PY-BUFFET_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BUFFET_UNZIP is the command used to unzip the source.
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
PY-BUFFET_SITE=http://cheeseshop.python.org/packages/source/B/Buffet
PY-BUFFET_VERSION=1.0
PY-BUFFET_SOURCE=Buffet-$(PY-BUFFET_VERSION).zip
PY-BUFFET_DIR=Buffet-$(PY-BUFFET_VERSION)
PY-BUFFET_UNZIP=unzip
PY-BUFFET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BUFFET_DESCRIPTION=A universal templating system for CherryPy.
PY-BUFFET_SECTION=misc
PY-BUFFET_PRIORITY=optional
PY24-BUFFET_DEPENDS=python24, py24-cherrypy
PY25-BUFFET_DEPENDS=python25, py25-cherrypy
PY-BUFFET_CONFLICTS=

#
# PY-BUFFET_IPK_VERSION should be incremented when the ipk changes.
#
PY-BUFFET_IPK_VERSION=1

#
# PY-BUFFET_CONFFILES should be a list of user-editable files
#PY-BUFFET_CONFFILES=/opt/etc/py-buffet.conf /opt/etc/init.d/SXXpy-buffet

#
# PY-BUFFET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BUFFET_PATCHES=$(PY-BUFFET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BUFFET_CPPFLAGS=
PY-BUFFET_LDFLAGS=

#
# PY-BUFFET_BUILD_DIR is the directory in which the build is done.
# PY-BUFFET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BUFFET_IPK_DIR is the directory in which the ipk is built.
# PY-BUFFET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BUFFET_BUILD_DIR=$(BUILD_DIR)/py-buffet
PY-BUFFET_SOURCE_DIR=$(SOURCE_DIR)/py-buffet

PY24-BUFFET_IPK_DIR=$(BUILD_DIR)/py24-buffet-$(PY-BUFFET_VERSION)-ipk
PY24-BUFFET_IPK=$(BUILD_DIR)/py24-buffet_$(PY-BUFFET_VERSION)-$(PY-BUFFET_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-BUFFET_IPK_DIR=$(BUILD_DIR)/py25-buffet-$(PY-BUFFET_VERSION)-ipk
PY25-BUFFET_IPK=$(BUILD_DIR)/py25-buffet_$(PY-BUFFET_VERSION)-$(PY-BUFFET_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BUFFET_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-BUFFET_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-buffet-source: $(DL_DIR)/$(PY-BUFFET_SOURCE) $(PY-BUFFET_PATCHES)

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
$(PY-BUFFET_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BUFFET_SOURCE) $(PY-BUFFET_PATCHES) make/py-buffet.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-BUFFET_DIR) $(PY-BUFFET_BUILD_DIR)
	cd $(BUILD_DIR) && $(PY-BUFFET_UNZIP) $(DL_DIR)/$(PY-BUFFET_SOURCE)
#	cat $(PY-BUFFET_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BUFFET_DIR) -p1
	mv $(BUILD_DIR)/$(PY-BUFFET_DIR) $(PY-BUFFET_BUILD_DIR)
	(cd $(PY-BUFFET_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $@

py-buffet-unpack: $(PY-BUFFET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BUFFET_BUILD_DIR)/.built: $(PY-BUFFET_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-BUFFET_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py build)
#	$(MAKE) -C $(PY-BUFFET_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
py-buffet: $(PY-BUFFET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-BUFFET_BUILD_DIR)/.staged: $(PY-BUFFET_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-BUFFET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-buffet-stage: $(PY-BUFFET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-buffet
#
$(PY24-BUFFET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-buffet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BUFFET_PRIORITY)" >>$@
	@echo "Section: $(PY-BUFFET_SECTION)" >>$@
	@echo "Version: $(PY-BUFFET_VERSION)-$(PY-BUFFET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BUFFET_MAINTAINER)" >>$@
	@echo "Source: $(PY-BUFFET_SITE)/$(PY-BUFFET_SOURCE)" >>$@
	@echo "Description: $(PY-BUFFET_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-BUFFET_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BUFFET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BUFFET_IPK_DIR)/opt/sbin or $(PY-BUFFET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BUFFET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BUFFET_IPK_DIR)/opt/etc/py-buffet/...
# Documentation files should be installed in $(PY-BUFFET_IPK_DIR)/opt/doc/py-buffet/...
# Daemon startup scripts should be installed in $(PY-BUFFET_IPK_DIR)/opt/etc/init.d/S??py-buffet
#
# You may need to patch your application to make it use these locations.
#
$(PY-BUFFET_IPK): $(PY-BUFFET_BUILD_DIR)/.built
	rm -rf $(PY-BUFFET_IPK_DIR) $(BUILD_DIR)/py-buffet_*_$(TARGET_ARCH).ipk
	(cd $(PY-BUFFET_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-BUFFET_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-BUFFET_IPK_DIR)/CONTROL/control
	echo $(PY-BUFFET_CONFFILES) | sed -e 's/ /\n/g' > $(PY-BUFFET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-BUFFET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-buffet-ipk: $(PY-BUFFET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-buffet-clean:
	-$(MAKE) -C $(PY-BUFFET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-buffet-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BUFFET_DIR) $(PY-BUFFET_BUILD_DIR) $(PY-BUFFET_IPK_DIR) $(PY-BUFFET_IPK)

#
# Some sanity check for the package.
#
py-buffet-check: $(PY-BUFFET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-BUFFET_IPK)
