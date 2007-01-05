###########################################################
#
# py-pudge
#
###########################################################

#
# PY-PUDGE_VERSION, PY-PUDGE_SITE and PY-PUDGE_SOURCE define
# the upstream location of the source code for the package.
# PY-PUDGE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PUDGE_UNZIP is the command used to unzip the source.
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
# PY-PUDGE_IPK_VERSION should be incremented when the ipk changes.
#
PY-PUDGE_SITE=http://cheeseshop.python.org/packages/source/p/pudge
PY-PUDGE_VERSION=0.1.2
PY-PUDGE_IPK_VERSION=1
PY-PUDGE_SOURCE=pudge-$(PY-PUDGE_VERSION).tar.gz
PY-PUDGE_DIR=pudge-$(PY-PUDGE_VERSION)
PY-PUDGE_UNZIP=zcat
PY-PUDGE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PUDGE_DESCRIPTION=A documentation generator for Python projects, using Restructured Text.
PY-PUDGE_SECTION=misc
PY-PUDGE_PRIORITY=optional
PY24-PUDGE_DEPENDS=python24
PY25-PUDGE_DEPENDS=python25
PY-PUDGE_SUGGESTS=
PY-PUDGE_CONFLICTS=


#
# PY-PUDGE_CONFFILES should be a list of user-editable files
#PY-PUDGE_CONFFILES=/opt/etc/py-pudge.conf /opt/etc/init.d/SXXpy-pudge

#
# PY-PUDGE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PUDGE_PATCHES=$(PY-PUDGE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PUDGE_CPPFLAGS=
PY-PUDGE_LDFLAGS=

#
# PY-PUDGE_BUILD_DIR is the directory in which the build is done.
# PY-PUDGE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PUDGE_IPK_DIR is the directory in which the ipk is built.
# PY-PUDGE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PUDGE_BUILD_DIR=$(BUILD_DIR)/py-pudge
PY-PUDGE_SOURCE_DIR=$(SOURCE_DIR)/py-pudge

PY24-PUDGE_IPK_DIR=$(BUILD_DIR)/py-pudge-$(PY-PUDGE_VERSION)-ipk
PY24-PUDGE_IPK=$(BUILD_DIR)/py-pudge_$(PY-PUDGE_VERSION)-$(PY-PUDGE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PUDGE_IPK_DIR=$(BUILD_DIR)/py25-pudge-$(PY-PUDGE_VERSION)-ipk
PY25-PUDGE_IPK=$(BUILD_DIR)/py25-pudge_$(PY-PUDGE_VERSION)-$(PY-PUDGE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pudge-source py-pudge-unpack py-pudge py-pudge-stage py-pudge-ipk py-pudge-clean py-pudge-dirclean py-pudge-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PUDGE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PUDGE_SITE)/$(PY-PUDGE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pudge-source: $(DL_DIR)/$(PY-PUDGE_SOURCE) $(PY-PUDGE_PATCHES)

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
$(PY-PUDGE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PUDGE_SOURCE) $(PY-PUDGE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-PUDGE_BUILD_DIR)
	mkdir -p $(PY-PUDGE_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PUDGE_DIR)
	$(PY-PUDGE_UNZIP) $(DL_DIR)/$(PY-PUDGE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PUDGE_PATCHES)" ; then \
	    cat $(PY-PUDGE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PUDGE_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PUDGE_DIR) $(PY-PUDGE_BUILD_DIR)/2.4
	(cd $(PY-PUDGE_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PUDGE_DIR)
	$(PY-PUDGE_UNZIP) $(DL_DIR)/$(PY-PUDGE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PUDGE_PATCHES)" ; then \
	    cat $(PY-PUDGE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PUDGE_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PUDGE_DIR) $(PY-PUDGE_BUILD_DIR)/2.5
	(cd $(PY-PUDGE_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-pudge-unpack: $(PY-PUDGE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PUDGE_BUILD_DIR)/.built: $(PY-PUDGE_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(PY-PUDGE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
py-pudge: $(PY-PUDGE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PUDGE_BUILD_DIR)/.staged: $(PY-PUDGE_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-PUDGE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-pudge-stage: $(PY-PUDGE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pudge
#
$(PY24-PUDGE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-pudge" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PUDGE_PRIORITY)" >>$@
	@echo "Section: $(PY-PUDGE_SECTION)" >>$@
	@echo "Version: $(PY-PUDGE_VERSION)-$(PY-PUDGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PUDGE_MAINTAINER)" >>$@
	@echo "Source: $(PY-PUDGE_SITE)/$(PY-PUDGE_SOURCE)" >>$@
	@echo "Description: $(PY-PUDGE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-PUDGE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PUDGE_CONFLICTS)" >>$@

$(PY25-PUDGE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pudge" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PUDGE_PRIORITY)" >>$@
	@echo "Section: $(PY-PUDGE_SECTION)" >>$@
	@echo "Version: $(PY-PUDGE_VERSION)-$(PY-PUDGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PUDGE_MAINTAINER)" >>$@
	@echo "Source: $(PY-PUDGE_SITE)/$(PY-PUDGE_SOURCE)" >>$@
	@echo "Description: $(PY-PUDGE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PUDGE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PUDGE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PUDGE_IPK_DIR)/opt/sbin or $(PY-PUDGE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PUDGE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PUDGE_IPK_DIR)/opt/etc/py-pudge/...
# Documentation files should be installed in $(PY-PUDGE_IPK_DIR)/opt/doc/py-pudge/...
# Daemon startup scripts should be installed in $(PY-PUDGE_IPK_DIR)/opt/etc/init.d/S??py-pudge
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PUDGE_IPK): $(PY-PUDGE_BUILD_DIR)/.built
	rm -rf $(PY24-PUDGE_IPK_DIR) $(BUILD_DIR)/py-pudge_*_$(TARGET_ARCH).ipk
	(cd $(PY-PUDGE_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-PUDGE_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PUDGE_IPK_DIR)/CONTROL/control
#	echo $(PY-PUDGE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PUDGE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PUDGE_IPK_DIR)

$(PY25-PUDGE_IPK): $(PY-PUDGE_BUILD_DIR)/.built
	rm -rf $(PY25-PUDGE_IPK_DIR) $(BUILD_DIR)/py25-pudge_*_$(TARGET_ARCH).ipk
	(cd $(PY-PUDGE_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-PUDGE_IPK_DIR) --prefix=/opt)
	for f in $(PY25-PUDGE_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-PUDGE_IPK_DIR)/CONTROL/control
#	echo $(PY-PUDGE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PUDGE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PUDGE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pudge-ipk: $(PY24-PUDGE_IPK) $(PY25-PUDGE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pudge-clean:
	-$(MAKE) -C $(PY-PUDGE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pudge-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PUDGE_DIR) $(PY-PUDGE_BUILD_DIR)
	rm -rf $(PY24-PUDGE_IPK_DIR) $(PY24-PUDGE_IPK)
	rm -rf $(PY25-PUDGE_IPK_DIR) $(PY25-PUDGE_IPK)

#
# Some sanity check for the package.
#
py-pudge-check: $(PY24-PUDGE_IPK) $(PY25-PUDGE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PUDGE_IPK) $(PY25-PUDGE_IPK)
