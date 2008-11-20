###########################################################
#
# py-trac
#
###########################################################

#
# PY-TRAC_VERSION, PY-TRAC_SITE and PY-TRAC_SOURCE define
# the upstream location of the source code for the package.
# PY-TRAC_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TRAC_UNZIP is the command used to unzip the source.
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
#PY-TRAC_SVN_REPO=http://svn.edgewall.com/repos/trac/trunk
#PY-TRAC_SVN_REV=4863
#PY-TRAC_VERSION=0.10+svn$(PY-TRAC_SVN_REV)
PY-TRAC_VERSION=0.11.2.1
PY-TRAC_SITE=http://ftp.edgewall.com/pub/trac
PY-TRAC_SOURCE=Trac-$(PY-TRAC_VERSION).tar.gz
PY-TRAC_DIR=Trac-$(PY-TRAC_VERSION)
PY-TRAC_UNZIP=zcat
PY-TRAC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TRAC_DESCRIPTION=An enhanced wiki and issue tracking system for software development projects.
PY-TRAC_SECTION=misc
PY-TRAC_PRIORITY=optional
PY24-TRAC_DEPENDS=python24, py24-genshi
PY25-TRAC_DEPENDS=python25, py25-genshi
PY24-TRAC_CONFLICTS=py25-trac
PY25-TRAC_CONFLICTS=py24-trac

#
# PY-TRAC_IPK_VERSION should be incremented when the ipk changes.
#
PY-TRAC_IPK_VERSION=1

#
# PY-TRAC_CONFFILES should be a list of user-editable files
#PY-TRAC_CONFFILES=/opt/etc/py-trac.conf /opt/etc/init.d/SXXpy-trac

#
# PY-TRAC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TRAC_PATCHES=$(PY-TRAC_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TRAC_CPPFLAGS=
PY-TRAC_LDFLAGS=

#
# PY-TRAC_BUILD_DIR is the directory in which the build is done.
# PY-TRAC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TRAC_IPK_DIR is the directory in which the ipk is built.
# PY-TRAC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TRAC_BUILD_DIR=$(BUILD_DIR)/py-trac
PY-TRAC_SOURCE_DIR=$(SOURCE_DIR)/py-trac

PY24-TRAC_IPK_DIR=$(BUILD_DIR)/py24-trac-$(PY-TRAC_VERSION)-ipk
PY24-TRAC_IPK=$(BUILD_DIR)/py24-trac_$(PY-TRAC_VERSION)-$(PY-TRAC_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-TRAC_IPK_DIR=$(BUILD_DIR)/py25-trac-$(PY-TRAC_VERSION)-ipk
PY25-TRAC_IPK=$(BUILD_DIR)/py25-trac_$(PY-TRAC_VERSION)-$(PY-TRAC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-trac-source py-trac-unpack py-trac py-trac-stage py-trac-ipk py-trac-clean py-trac-dirclean py-trac-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TRAC_SOURCE):
ifndef PY-TRAC_SVN_REV
	$(WGET) -P $(@D) $(PY-TRAC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(PY-TRAC_DIR) && \
		svn co -r$(PY-TRAC_SVN_REV) $(PY-TRAC_SVN_REPO) $(PY-TRAC_DIR) && \
		tar -czf $@ --exclude=.svn $(PY-TRAC_DIR) && \
		rm -rf $(PY-TRAC_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-trac-source: $(DL_DIR)/$(PY-TRAC_SOURCE) $(PY-TRAC_PATCHES)

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
$(PY-TRAC_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TRAC_SOURCE) $(PY-TRAC_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-TRAC_DIR)
	$(PY-TRAC_UNZIP) $(DL_DIR)/$(PY-TRAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-TRAC_PATCHES)"; then \
	    cat $(PY-TRAC_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TRAC_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-TRAC_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-TRAC_DIR)
	$(PY-TRAC_UNZIP) $(DL_DIR)/$(PY-TRAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-TRAC_PATCHES)"; then \
	    cat $(PY-TRAC_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TRAC_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-TRAC_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-trac-unpack: $(PY-TRAC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TRAC_BUILD_DIR)/.built: $(PY-TRAC_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-trac: $(PY-TRAC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TRAC_BUILD_DIR)/.staged: $(PY-TRAC_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-trac-stage: $(PY-TRAC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-trac
#
$(PY24-TRAC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-trac" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TRAC_PRIORITY)" >>$@
	@echo "Section: $(PY-TRAC_SECTION)" >>$@
	@echo "Version: $(PY-TRAC_VERSION)-$(PY-TRAC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TRAC_MAINTAINER)" >>$@
	@echo "Source: $(PY-TRAC_SITE)/$(PY-TRAC_SOURCE)" >>$@
	@echo "Description: $(PY-TRAC_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-TRAC_DEPENDS)" >>$@
	@echo "Conflicts: $(PY24-TRAC_CONFLICTS)" >>$@

$(PY25-TRAC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-trac" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TRAC_PRIORITY)" >>$@
	@echo "Section: $(PY-TRAC_SECTION)" >>$@
	@echo "Version: $(PY-TRAC_VERSION)-$(PY-TRAC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TRAC_MAINTAINER)" >>$@
	@echo "Source: $(PY-TRAC_SITE)/$(PY-TRAC_SOURCE)" >>$@
	@echo "Description: $(PY-TRAC_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TRAC_DEPENDS)" >>$@
	@echo "Conflicts: $(PY25-TRAC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TRAC_IPK_DIR)/opt/sbin or $(PY-TRAC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TRAC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TRAC_IPK_DIR)/opt/etc/py-trac/...
# Documentation files should be installed in $(PY-TRAC_IPK_DIR)/opt/doc/py-trac/...
# Daemon startup scripts should be installed in $(PY-TRAC_IPK_DIR)/opt/etc/init.d/S??py-trac
#
# You may need to patch your application to make it use these locations.
#		$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
#
$(PY24-TRAC_IPK): $(PY-TRAC_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-trac_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-TRAC_IPK_DIR) $(BUILD_DIR)/py24-trac_*_$(TARGET_ARCH).ipk
	cd $(PY-TRAC_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-TRAC_IPK_DIR) --prefix=/opt
	$(MAKE) $(PY24-TRAC_IPK_DIR)/CONTROL/control
#	echo $(PY-TRAC_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-TRAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-TRAC_IPK_DIR)

$(PY25-TRAC_IPK): $(PY-TRAC_BUILD_DIR)/.built
	rm -rf $(PY25-TRAC_IPK_DIR) $(BUILD_DIR)/py25-trac_*_$(TARGET_ARCH).ipk
	cd $(PY-TRAC_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-TRAC_IPK_DIR) --prefix=/opt
	$(MAKE) $(PY25-TRAC_IPK_DIR)/CONTROL/control
#	echo $(PY-TRAC_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-TRAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-TRAC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-trac-ipk: $(PY24-TRAC_IPK) $(PY25-TRAC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-trac-clean:
	-$(MAKE) -C $(PY-TRAC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-trac-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TRAC_DIR) $(PY-TRAC_BUILD_DIR)
	rm -rf $(PY24-TRAC_IPK_DIR) $(PY24-TRAC_IPK)
	rm -rf $(PY25-TRAC_IPK_DIR) $(PY25-TRAC_IPK)

#
# Some sanity check for the package.
#
py-trac-check: $(PY24-TRAC_IPK) $(PY25-TRAC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-TRAC_IPK) $(PY25-TRAC_IPK)
