###########################################################
#
# py-mercurial
#
###########################################################

#
# PY-MERCURIAL_VERSION, PY-MERCURIAL_SITE and PY-MERCURIAL_SOURCE define
# the upstream location of the source code for the package.
# PY-MERCURIAL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MERCURIAL_UNZIP is the command used to unzip the source.
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
PY-MERCURIAL_VERSION=1.0.2
PY-MERCURIAL_SITE=http://www.selenic.com/mercurial/release
PY-MERCURIAL_SOURCE=mercurial-$(PY-MERCURIAL_VERSION).tar.gz
PY-MERCURIAL_DIR=mercurial-$(PY-MERCURIAL_VERSION)
PY-MERCURIAL_UNZIP=zcat
PY-MERCURIAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MERCURIAL_DESCRIPTION=A fast, lightweight Source Control Management system designed for efficient handling of very large distributed projects.
PY-MERCURIAL_SECTION=misc
PY-MERCURIAL_PRIORITY=optional
PY24-MERCURIAL_DEPENDS=python24
PY25-MERCURIAL_DEPENDS=python25
PY-MERCURIAL_CONFLICTS=

#
# PY-MERCURIAL_IPK_VERSION should be incremented when the ipk changes.
#
PY-MERCURIAL_IPK_VERSION=1

#
# PY-MERCURIAL_CONFFILES should be a list of user-editable files
#PY-MERCURIAL_CONFFILES=/opt/etc/py-mercurial.conf /opt/etc/init.d/SXXpy-mercurial

#
# PY-MERCURIAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MERCURIAL_PATCHES=$(PY-MERCURIAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MERCURIAL_CPPFLAGS=
PY-MERCURIAL_LDFLAGS=
# to be improved:
PY-MERCURIAL_WITH_INOTIFY=$(strip $(if \
$(filter angstrombe angstromle slugosbe slugosle, $(OPTWARE_TARGET)), True, False))

#
# PY-MERCURIAL_BUILD_DIR is the directory in which the build is done.
# PY-MERCURIAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MERCURIAL_IPK_DIR is the directory in which the ipk is built.
# PY-MERCURIAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MERCURIAL_BUILD_DIR=$(BUILD_DIR)/py-mercurial
PY-MERCURIAL_SOURCE_DIR=$(SOURCE_DIR)/py-mercurial

PY24-MERCURIAL_IPK_DIR=$(BUILD_DIR)/py24-mercurial-$(PY-MERCURIAL_VERSION)-ipk
PY24-MERCURIAL_IPK=$(BUILD_DIR)/py24-mercurial_$(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MERCURIAL_IPK_DIR=$(BUILD_DIR)/py25-mercurial-$(PY-MERCURIAL_VERSION)-ipk
PY25-MERCURIAL_IPK=$(BUILD_DIR)/py25-mercurial_$(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mercurial-source py-mercurial-unpack py-mercurial py-mercurial-stage py-mercurial-ipk py-mercurial-clean py-mercurial-dirclean py-mercurial-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MERCURIAL_SOURCE):
	$(WGET) -P $(@D) $(PY-MERCURIAL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mercurial-source: $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(PY-MERCURIAL_PATCHES)

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
$(PY-MERCURIAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(PY-MERCURIAL_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)
	mkdir -p $(@D)
	# 2.4
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MERCURIAL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MERCURIAL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	sed -i	-e '/linux2/s|if .*|if True:|' \
		-e '/inotify_/s|if .*|if $(PY-MERCURIAL_WITH_INOTIFY):|' $(@D)/2.4/setup.py
	# 2.5
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MERCURIAL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MERCURIAL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	sed -i	-e '/linux2/s|if .*|if True:|' \
		-e '/inotify_/s|if .*|if $(PY-MERCURIAL_WITH_INOTIFY):|' $(@D)/2.5/setup.py
	touch $@

py-mercurial-unpack: $(PY-MERCURIAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MERCURIAL_BUILD_DIR)/.built: $(PY-MERCURIAL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-mercurial: $(PY-MERCURIAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MERCURIAL_BUILD_DIR)/.staged: $(PY-MERCURIAL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-MERCURIAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-mercurial-stage: $(PY-MERCURIAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mercurial
#
$(PY24-MERCURIAL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-mercurial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MERCURIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-MERCURIAL_SECTION)" >>$@
	@echo "Version: $(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MERCURIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE)" >>$@
	@echo "Description: $(PY-MERCURIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-MERCURIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MERCURIAL_CONFLICTS)" >>$@

$(PY25-MERCURIAL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-mercurial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MERCURIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-MERCURIAL_SECTION)" >>$@
	@echo "Version: $(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MERCURIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE)" >>$@
	@echo "Description: $(PY-MERCURIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MERCURIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MERCURIAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MERCURIAL_IPK_DIR)/opt/sbin or $(PY-MERCURIAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MERCURIAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MERCURIAL_IPK_DIR)/opt/etc/py-mercurial/...
# Documentation files should be installed in $(PY-MERCURIAL_IPK_DIR)/opt/doc/py-mercurial/...
# Daemon startup scripts should be installed in $(PY-MERCURIAL_IPK_DIR)/opt/etc/init.d/S??py-mercurial
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MERCURIAL_IPK) $(PY25-MERCURIAL_IPK): $(PY-MERCURIAL_BUILD_DIR)/.built
	# 2.4
	rm -rf $(BUILD_DIR)/py-mercurial_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-MERCURIAL_IPK_DIR) $(BUILD_DIR)/py24-mercurial_*_$(TARGET_ARCH).ipk
	(cd $(PY-MERCURIAL_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-MERCURIAL_IPK_DIR) --prefix=/opt; \
	)
	(cd $(PY24-MERCURIAL_IPK_DIR)/opt/lib/python2.4/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	for f in $(PY24-MERCURIAL_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-MERCURIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MERCURIAL_IPK_DIR)
	# 2.5
	rm -rf $(PY25-MERCURIAL_IPK_DIR) $(BUILD_DIR)/py25-mercurial_*_$(TARGET_ARCH).ipk
	(cd $(PY-MERCURIAL_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-MERCURIAL_IPK_DIR) --prefix=/opt; \
	)
	(cd $(PY25-MERCURIAL_IPK_DIR)/opt/lib/python2.5/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PY25-MERCURIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MERCURIAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mercurial-ipk: $(PY24-MERCURIAL_IPK) $(PY25-MERCURIAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mercurial-clean:
	-$(MAKE) -C $(PY-MERCURIAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mercurial-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(PY-MERCURIAL_BUILD_DIR)
	rm -rf $(PY24-MERCURIAL_IPK_DIR) $(PY24-MERCURIAL_IPK)
	rm -rf $(PY25-MERCURIAL_IPK_DIR) $(PY25-MERCURIAL_IPK)

#
# Some sanity check for the package.
#
py-mercurial-check: $(PY24-MERCURIAL_IPK) $(PY25-MERCURIAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MERCURIAL_IPK) $(PY25-MERCURIAL_IPK)
