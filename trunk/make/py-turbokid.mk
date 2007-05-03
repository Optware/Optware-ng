###########################################################
#
# py-turbokid
#
###########################################################

#
# PY-TURBOKID_VERSION, PY-TURBOKID_SITE and PY-TURBOKID_SOURCE define
# the upstream location of the source code for the package.
# PY-TURBOKID_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TURBOKID_UNZIP is the command used to unzip the source.
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
PY-TURBOKID_VERSION=1.0.1
#PY-TURBOKID_SVN_TAG=$(PY-TURBOKID_VERSION)
#PY-TURBOKID_REPOSITORY=http://svn.turbogears.org/projects/TurboKid/tags/$(PY-TURBOKID_SVN_TAG)
PY-TURBOKID_SITE=http://cheeseshop.python.org/packages/source/T/TurboKid
PY-TURBOKID_DIR=TurboKid-$(PY-TURBOKID_VERSION)
PY-TURBOKID_SOURCE=TurboKid-$(PY-TURBOKID_VERSION).tar.gz
PY-TURBOKID_UNZIP=zcat
PY-TURBOKID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TURBOKID_DESCRIPTION=Python template plugin that supports Kid templates.
PY-TURBOKID_SECTION=misc
PY-TURBOKID_PRIORITY=optional
PY24-TURBOKID_DEPENDS=python24, py-kid
PY25-TURBOKID_DEPENDS=python25, py25-kid
PY-TURBOKID_CONFLICTS=

#
# PY-TURBOKID_IPK_VERSION should be incremented when the ipk changes.
#
PY-TURBOKID_IPK_VERSION=1

#
# PY-TURBOKID_CONFFILES should be a list of user-editable files
#PY-TURBOKID_CONFFILES=/opt/etc/py-turbokid.conf /opt/etc/init.d/SXXpy-turbokid

#
# PY-TURBOKID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TURBOKID_PATCHES=$(PY-TURBOKID_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TURBOKID_CPPFLAGS=
PY-TURBOKID_LDFLAGS=

#
# PY-TURBOKID_BUILD_DIR is the directory in which the build is done.
# PY-TURBOKID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TURBOKID_IPK_DIR is the directory in which the ipk is built.
# PY-TURBOKID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TURBOKID_BUILD_DIR=$(BUILD_DIR)/py-turbokid
PY-TURBOKID_SOURCE_DIR=$(SOURCE_DIR)/py-turbokid

PY24-TURBOKID_IPK_DIR=$(BUILD_DIR)/py-turbokid-$(PY-TURBOKID_VERSION)-ipk
PY24-TURBOKID_IPK=$(BUILD_DIR)/py-turbokid_$(PY-TURBOKID_VERSION)-$(PY-TURBOKID_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-TURBOKID_IPK_DIR=$(BUILD_DIR)/py25-turbokid-$(PY-TURBOKID_VERSION)-ipk
PY25-TURBOKID_IPK=$(BUILD_DIR)/py25-turbokid_$(PY-TURBOKID_VERSION)-$(PY-TURBOKID_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-turbokid-source py-turbokid-unpack py-turbokid py-turbokid-stage py-turbokid-ipk py-turbokid-clean py-turbokid-dirclean py-turbokid-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TURBOKID_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-TURBOKID_SITE)/$(PY-TURBOKID_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PY-TURBOKID_SOURCE)
#	(cd $(BUILD_DIR); \
	    svn co -q $(PY-TURBOKID_REPOSITORY) $(PY-TURBOKID_DIR); \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-turbokid-source: $(PY-TURBOKID_PATCHES)

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
$(PY-TURBOKID_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TURBOKID_SOURCE) $(PY-TURBOKID_PATCHES) make/py-turbokid.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-TURBOKID_BUILD_DIR)
	mkdir -p $(PY-TURBOKID_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-TURBOKID_DIR)
	$(PY-TURBOKID_UNZIP) $(DL_DIR)/$(PY-TURBOKID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TURBOKID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOKID_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOKID_DIR) $(PY-TURBOKID_BUILD_DIR)/2.4
	(cd $(PY-TURBOKID_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-TURBOKID_DIR)
	$(PY-TURBOKID_UNZIP) $(DL_DIR)/$(PY-TURBOKID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TURBOKID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOKID_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOKID_DIR) $(PY-TURBOKID_BUILD_DIR)/2.5
	(cd $(PY-TURBOKID_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-TURBOKID_BUILD_DIR)/.configured

py-turbokid-unpack: $(PY-TURBOKID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TURBOKID_BUILD_DIR)/.built: $(PY-TURBOKID_BUILD_DIR)/.configured
	rm -f $(PY-TURBOKID_BUILD_DIR)/.built
	(cd $(PY-TURBOKID_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-TURBOKID_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-TURBOKID_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-turbokid: $(PY-TURBOKID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TURBOKID_BUILD_DIR)/.staged: $(PY-TURBOKID_BUILD_DIR)/.built
	rm -f $(PY-TURBOKID_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-TURBOKID_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-TURBOKID_BUILD_DIR)/.staged

py-turbokid-stage: $(PY-TURBOKID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-turbokid
#
$(PY24-TURBOKID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-turbokid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOKID_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOKID_SECTION)" >>$@
	@echo "Version: $(PY-TURBOKID_VERSION)-$(PY-TURBOKID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOKID_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOKID_SITE)/$(PY-TURBOKID_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOKID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-TURBOKID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOKID_CONFLICTS)" >>$@

$(PY25-TURBOKID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-turbokid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOKID_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOKID_SECTION)" >>$@
	@echo "Version: $(PY-TURBOKID_VERSION)-$(PY-TURBOKID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOKID_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOKID_SITE)/$(PY-TURBOKID_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOKID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TURBOKID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOKID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TURBOKID_IPK_DIR)/opt/sbin or $(PY-TURBOKID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TURBOKID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TURBOKID_IPK_DIR)/opt/etc/py-turbokid/...
# Documentation files should be installed in $(PY-TURBOKID_IPK_DIR)/opt/doc/py-turbokid/...
# Daemon startup scripts should be installed in $(PY-TURBOKID_IPK_DIR)/opt/etc/init.d/S??py-turbokid
#
# You may need to patch your application to make it use these locations.
#
$(PY24-TURBOKID_IPK): $(PY-TURBOKID_BUILD_DIR)/.built
	rm -rf $(PY24-TURBOKID_IPK_DIR) $(BUILD_DIR)/py-turbokid_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOKID_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-TURBOKID_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-TURBOKID_IPK_DIR)/CONTROL/control
	echo $(PY-TURBOKID_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-TURBOKID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-TURBOKID_IPK_DIR)

$(PY25-TURBOKID_IPK): $(PY-TURBOKID_BUILD_DIR)/.built
	rm -rf $(PY25-TURBOKID_IPK_DIR) $(BUILD_DIR)/py25-turbokid_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOKID_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-TURBOKID_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-TURBOKID_IPK_DIR)/CONTROL/control
	echo $(PY-TURBOKID_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-TURBOKID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-TURBOKID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-turbokid-ipk: $(PY24-TURBOKID_IPK) $(PY25-TURBOKID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-turbokid-clean:
	-$(MAKE) -C $(PY-TURBOKID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-turbokid-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TURBOKID_DIR) $(PY-TURBOKID_BUILD_DIR)
	rm -rf $(PY24-TURBOKID_IPK_DIR) $(PY24-TURBOKID_IPK)
	rm -rf $(PY25-TURBOKID_IPK_DIR) $(PY25-TURBOKID_IPK)

#
# Some sanity check for the package.
#
py-turbokid-check: $(PY24-TURBOKID_IPK) $(PY25-TURBOKID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-TURBOKID_IPK) $(PY25-TURBOKID_IPK)
