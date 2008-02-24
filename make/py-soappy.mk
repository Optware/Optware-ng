###########################################################
#
# py-soappy
#
###########################################################

#
# PY-SOAPPY_VERSION, PY-SOAPPY_SITE and PY-SOAPPY_SOURCE define
# the upstream location of the source code for the package.
# PY-SOAPPY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SOAPPY_UNZIP is the command used to unzip the source.
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
PY-SOAPPY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pywebsvcs
PY-SOAPPY_VERSION=0.12.0
PY-SOAPPY_SOURCE=SOAPpy-$(PY-SOAPPY_VERSION).tar.gz
PY-SOAPPY_DIR=SOAPpy-$(PY-SOAPPY_VERSION)
PY-SOAPPY_UNZIP=zcat
PY-SOAPPY_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-SOAPPY_DESCRIPTION=A SOAP implementation for Python.
PY-SOAPPY_SECTION=misc
PY-SOAPPY_PRIORITY=optional
PY-SOAPPY_DEPENDS=python, py-xml
PY-SOAPPY_CONFLICTS=

PY-SOAPPY_FPCONST_SITE=http://pypi.python.org/packages/source/f/fpconst
PY-SOAPPY_FPCONST_DIR=fpconst-0.7.2
PY-SOAPPY_FPCONST_SOURCE=$(PY-SOAPPY_FPCONST_DIR).tar.gz
#
# PY-SOAPPY_IPK_VERSION should be incremented when the ipk changes.
#
PY-SOAPPY_IPK_VERSION=3

#
# PY-SOAPPY_CONFFILES should be a list of user-editable files
#PY-SOAPPY_CONFFILES=/opt/etc/py-soappy.conf /opt/etc/init.d/SXXpy-soappy

#
# PY-SOAPPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SOAPPY_PATCHES=$(PY-SOAPPY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SOAPPY_CPPFLAGS=
PY-SOAPPY_LDFLAGS=

#
# PY-SOAPPY_BUILD_DIR is the directory in which the build is done.
# PY-SOAPPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SOAPPY_IPK_DIR is the directory in which the ipk is built.
# PY-SOAPPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SOAPPY_BUILD_DIR=$(BUILD_DIR)/py-soappy
PY-SOAPPY_SOURCE_DIR=$(SOURCE_DIR)/py-soappy
PY-SOAPPY_IPK_DIR=$(BUILD_DIR)/py-soappy-$(PY-SOAPPY_VERSION)-ipk
PY-SOAPPY_IPK=$(BUILD_DIR)/py-soappy_$(PY-SOAPPY_VERSION)-$(PY-SOAPPY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SOAPPY_FPCONST_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SOAPPY_FPCONST_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-SOAPPY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SOAPPY_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-soappy-source: $(DL_DIR)/$(PY-SOAPPY_SOURCE) $(DL_DIR)/$(PY-SOAPPY_FPCONST_SOURCE) $(PY-SOAPPY_PATCHES)

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
$(PY-SOAPPY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SOAPPY_SOURCE) $(PY-SOAPPY_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-SOAPPY_DIR) $(PY-SOAPPY_BUILD_DIR)
	$(PY-SOAPPY_UNZIP) $(DL_DIR)/$(PY-SOAPPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-SOAPPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SOAPPY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SOAPPY_DIR) $(PY-SOAPPY_BUILD_DIR)
	$(PY-SOAPPY_UNZIP) $(DL_DIR)/$(PY-SOAPPY_FPCONST_SOURCE) | tar -C $(PY-SOAPPY_BUILD_DIR) -xvf -
	cp $(PY-SOAPPY_BUILD_DIR)/$(PY-SOAPPY_FPCONST_DIR)/fpconst.py $(PY-SOAPPY_BUILD_DIR)/SOAPpy/
	(cd $(PY-SOAPPY_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") > setup.cfg \
	)
	touch $(PY-SOAPPY_BUILD_DIR)/.configured

py-soappy-unpack: $(PY-SOAPPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SOAPPY_BUILD_DIR)/.built: $(PY-SOAPPY_BUILD_DIR)/.configured
	rm -f $(PY-SOAPPY_BUILD_DIR)/.built
	cd $(PY-SOAPPY_BUILD_DIR) &&  python2.4 setup.py build
	touch $(PY-SOAPPY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-soappy: $(PY-SOAPPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SOAPPY_BUILD_DIR)/.staged: $(PY-SOAPPY_BUILD_DIR)/.built
	rm -f $(PY-SOAPPY_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-SOAPPY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-SOAPPY_BUILD_DIR)/.staged

py-soappy-stage: $(PY-SOAPPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-soappy
#
$(PY-SOAPPY_IPK_DIR)/CONTROL/control:
	@install -d $(PY-SOAPPY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-soappy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SOAPPY_PRIORITY)" >>$@
	@echo "Section: $(PY-SOAPPY_SECTION)" >>$@
	@echo "Version: $(PY-SOAPPY_VERSION)-$(PY-SOAPPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SOAPPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SOAPPY_SITE)/$(PY-SOAPPY_SOURCE)" >>$@
	@echo "Description: $(PY-SOAPPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-SOAPPY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SOAPPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SOAPPY_IPK_DIR)/opt/sbin or $(PY-SOAPPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SOAPPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SOAPPY_IPK_DIR)/opt/etc/py-soappy/...
# Documentation files should be installed in $(PY-SOAPPY_IPK_DIR)/opt/doc/py-soappy/...
# Daemon startup scripts should be installed in $(PY-SOAPPY_IPK_DIR)/opt/etc/init.d/S??py-soappy
#
# You may need to patch your application to make it use these locations.
#
$(PY-SOAPPY_IPK): $(PY-SOAPPY_BUILD_DIR)/.built
	rm -rf $(PY-SOAPPY_IPK_DIR) $(BUILD_DIR)/py-soappy_*_$(TARGET_ARCH).ipk
	#$(MAKE) -C $(PY-SOAPPY_BUILD_DIR) DESTDIR=$(PY-SOAPPY_IPK_DIR) install
	(cd $(PY-SOAPPY_BUILD_DIR); \
	python2.4 setup.py install --root=$(PY-SOAPPY_IPK_DIR) --prefix=/opt)
	for d in bid contrib docs tests tools validate fpconst; do \
		install -d $(PY-SOAPPY_IPK_DIR)/opt/share/doc/SOAPpy/$$d; \
		install $(PY-SOAPPY_BUILD_DIR)/$$d*/* $(PY-SOAPPY_IPK_DIR)/opt/share/doc/SOAPpy/$$d; \
	done
	for f in LICENSE README RELEASE_INFO ChangeLog TODO; do \
		install $(PY-SOAPPY_BUILD_DIR)/$$f $(PY-SOAPPY_IPK_DIR)/opt/share/doc/SOAPpy/; \
	done
	$(MAKE) $(PY-SOAPPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-SOAPPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-soappy-ipk: $(PY-SOAPPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-soappy-clean:
	-$(MAKE) -C $(PY-SOAPPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-soappy-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SOAPPY_DIR) $(PY-SOAPPY_BUILD_DIR) $(PY-SOAPPY_IPK_DIR) $(PY-SOAPPY_IPK)
