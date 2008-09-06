###########################################################
#
# py-django
#
###########################################################

#
# PY-DJANGO_VERSION, PY-DJANGO_SITE and PY-DJANGO_SOURCE define
# the upstream location of the source code for the package.
# PY-DJANGO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-DJANGO_UNZIP is the command used to unzip the source.
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
PY-DJANGO_VERSION=1.0
PY-DJANGO_SITE=http://www.djangoproject.com/download/$(PY-DJANGO_VERSION)/tarball/
PY-DJANGO_SOURCE=Django-$(PY-DJANGO_VERSION).tar.gz
PY-DJANGO_DIR=Django-$(PY-DJANGO_VERSION)
PY-DJANGO_UNZIP=zcat
PY-DJANGO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-DJANGO_DESCRIPTION=A high-level Python Web framework that encourages rapid development and clean, pragmatic design.
PY-DJANGO_SECTION=misc
PY-DJANGO_PRIORITY=optional
PY24-DJANGO_DEPENDS=python24
PY25-DJANGO_DEPENDS=python25
PY-DJANGO_CONFLICTS=

#
# PY-DJANGO_IPK_VERSION should be incremented when the ipk changes.
#
PY-DJANGO_IPK_VERSION=1

#
# PY-DJANGO_CONFFILES should be a list of user-editable files
#PY-DJANGO_CONFFILES=/opt/etc/py-django.conf /opt/etc/init.d/SXXpy-django

#
# PY-DJANGO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-DJANGO_PATCHES=$(PY-DJANGO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-DJANGO_CPPFLAGS=
PY-DJANGO_LDFLAGS=

#
# PY-DJANGO_BUILD_DIR is the directory in which the build is done.
# PY-DJANGO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-DJANGO_IPK_DIR is the directory in which the ipk is built.
# PY-DJANGO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-DJANGO_BUILD_DIR=$(BUILD_DIR)/py-django
PY-DJANGO_SOURCE_DIR=$(SOURCE_DIR)/py-django

PY24-DJANGO_IPK_DIR=$(BUILD_DIR)/py24-django-$(PY-DJANGO_VERSION)-ipk
PY24-DJANGO_IPK=$(BUILD_DIR)/py24-django_$(PY-DJANGO_VERSION)-$(PY-DJANGO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-DJANGO_IPK_DIR=$(BUILD_DIR)/py25-django-$(PY-DJANGO_VERSION)-ipk
PY25-DJANGO_IPK=$(BUILD_DIR)/py25-django_$(PY-DJANGO_VERSION)-$(PY-DJANGO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-django-source py-django-unpack py-django py-django-stage py-django-ipk py-django-clean py-django-dirclean py-django-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-DJANGO_SOURCE):
	$(WGET) -O $(@D)/$(@F) $(PY-DJANGO_SITE) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-django-source: $(DL_DIR)/$(PY-DJANGO_SOURCE) $(PY-DJANGO_PATCHES)

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
$(PY-DJANGO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-DJANGO_SOURCE) $(PY-DJANGO_PATCHES) make/py-django.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-DJANGO_DIR) $(@D)
	mkdir -p $(PY-DJANGO_BUILD_DIR)
	$(PY-DJANGO_UNZIP) $(DL_DIR)/$(PY-DJANGO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DJANGO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DJANGO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DJANGO_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-DJANGO_UNZIP) $(DL_DIR)/$(PY-DJANGO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DJANGO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DJANGO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DJANGO_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-django-unpack: $(PY-DJANGO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-DJANGO_BUILD_DIR)/.built: $(PY-DJANGO_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-django: $(PY-DJANGO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-DJANGO_BUILD_DIR)/.staged: $(PY-DJANGO_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-DJANGO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-django-stage: $(PY-DJANGO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-django
#
$(PY24-DJANGO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-django" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DJANGO_PRIORITY)" >>$@
	@echo "Section: $(PY-DJANGO_SECTION)" >>$@
	@echo "Version: $(PY-DJANGO_VERSION)-$(PY-DJANGO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DJANGO_MAINTAINER)" >>$@
	@echo "Source: $(PY-DJANGO_SITE)/$(PY-DJANGO_SOURCE)" >>$@
	@echo "Description: $(PY-DJANGO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-DJANGO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DJANGO_CONFLICTS)" >>$@

$(PY25-DJANGO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-django" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DJANGO_PRIORITY)" >>$@
	@echo "Section: $(PY-DJANGO_SECTION)" >>$@
	@echo "Version: $(PY-DJANGO_VERSION)-$(PY-DJANGO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DJANGO_MAINTAINER)" >>$@
	@echo "Source: $(PY-DJANGO_SITE)/$(PY-DJANGO_SOURCE)" >>$@
	@echo "Description: $(PY-DJANGO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-DJANGO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DJANGO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-DJANGO_IPK_DIR)/opt/sbin or $(PY-DJANGO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-DJANGO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-DJANGO_IPK_DIR)/opt/etc/py-django/...
# Documentation files should be installed in $(PY-DJANGO_IPK_DIR)/opt/doc/py-django/...
# Daemon startup scripts should be installed in $(PY-DJANGO_IPK_DIR)/opt/etc/init.d/S??py-django
#
# You may need to patch your application to make it use these locations.
#
$(PY24-DJANGO_IPK): $(PY-DJANGO_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-django_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-DJANGO_IPK_DIR) $(BUILD_DIR)/py24-django_*_$(TARGET_ARCH).ipk
	(cd $(PY-DJANGO_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-DJANGO_IPK_DIR) --prefix=/opt)
	for f in $(PY24-DJANGO_IPK_DIR)/opt/*bin/*; \
	    do mv $$f `echo $$f | sed 's|\.py|-2.4.py|'`; done
	$(MAKE) $(PY24-DJANGO_IPK_DIR)/CONTROL/control
	echo $(PY-DJANGO_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-DJANGO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-DJANGO_IPK_DIR)

$(PY25-DJANGO_IPK): $(PY-DJANGO_BUILD_DIR)/.built
	rm -rf $(PY25-DJANGO_IPK_DIR) $(BUILD_DIR)/py25-django_*_$(TARGET_ARCH).ipk
	(cd $(PY-DJANGO_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-DJANGO_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-DJANGO_IPK_DIR)/CONTROL/control
	echo $(PY-DJANGO_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-DJANGO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-DJANGO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-django-ipk: $(PY24-DJANGO_IPK) $(PY25-DJANGO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-django-clean:
	-$(MAKE) -C $(PY-DJANGO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-django-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-DJANGO_DIR) $(PY-DJANGO_BUILD_DIR) \
	$(PY24-DJANGO_IPK_DIR) $(PY24-DJANGO_IPK) \
	$(PY25-DJANGO_IPK_DIR) $(PY25-DJANGO_IPK) \

#
# Some sanity check for the package.
#
py-django-check: $(PY24-DJANGO_IPK) $(PY25-DJANGO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-DJANGO_IPK) $(PY25-DJANGO_IPK)
