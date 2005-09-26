###########################################################
#
# py-cherrytemplate
#
###########################################################

#
# PY-CHERRYTEMPLATE_VERSION, PY-CHERRYTEMPLATE_SITE and PY-CHERRYTEMPLATE_SOURCE define
# the upstream location of the source code for the package.
# PY-CHERRYTEMPLATE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CHERRYTEMPLATE_UNZIP is the command used to unzip the source.
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
PY-CHERRYTEMPLATE_SITE=http://dl.sf.net/sourceforge/cherrypy
PY-CHERRYTEMPLATE_VERSION=1.0.0
PY-CHERRYTEMPLATE_SOURCE=CherryTemplate-$(PY-CHERRYTEMPLATE_VERSION).tar.gz
PY-CHERRYTEMPLATE_DIR=CherryTemplate-$(PY-CHERRYTEMPLATE_VERSION)
PY-CHERRYTEMPLATE_UNZIP=zcat
PY-CHERRYTEMPLATE_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-CHERRYTEMPLATE_DESCRIPTION=CherryTemplate is an easy and powerful templating module for Python.
PY-CHERRYTEMPLATE_SECTION=web
PY-CHERRYTEMPLATE_PRIORITY=optional
PY-CHERRYTEMPLATE_DEPENDS=python
PY-CHERRYTEMPLATE_CONFLICTS=

#
# PY-CHERRYTEMPLATE_IPK_VERSION should be incremented when the ipk changes.
#
PY-CHERRYTEMPLATE_IPK_VERSION=1

#
# PY-CHERRYTEMPLATE_CONFFILES should be a list of user-editable files
#PY-CHERRYTEMPLATE_CONFFILES=/opt/etc/py-cherrytemplate.conf /opt/etc/init.d/SXXpy-cherrytemplate

#
# PY-CHERRYTEMPLATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CHERRYTEMPLATE_PATCHES=$(PY-CHERRYTEMPLATE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CHERRYTEMPLATE_CPPFLAGS=
PY-CHERRYTEMPLATE_LDFLAGS=

#
# PY-CHERRYTEMPLATE_BUILD_DIR is the directory in which the build is done.
# PY-CHERRYTEMPLATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CHERRYTEMPLATE_IPK_DIR is the directory in which the ipk is built.
# PY-CHERRYTEMPLATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CHERRYTEMPLATE_BUILD_DIR=$(BUILD_DIR)/py-cherrytemplate
PY-CHERRYTEMPLATE_SOURCE_DIR=$(SOURCE_DIR)/py-cherrytemplate
PY-CHERRYTEMPLATE_IPK_DIR=$(BUILD_DIR)/py-cherrytemplate-$(PY-CHERRYTEMPLATE_VERSION)-ipk
PY-CHERRYTEMPLATE_IPK=$(BUILD_DIR)/py-cherrytemplate_$(PY-CHERRYTEMPLATE_VERSION)-$(PY-CHERRYTEMPLATE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CHERRYTEMPLATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CHERRYTEMPLATE_SITE)/$(PY-CHERRYTEMPLATE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cherrytemplate-source: $(DL_DIR)/$(PY-CHERRYTEMPLATE_SOURCE) $(PY-CHERRYTEMPLATE_PATCHES)

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
$(PY-CHERRYTEMPLATE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CHERRYTEMPLATE_SOURCE) $(PY-CHERRYTEMPLATE_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-CHERRYTEMPLATE_DIR) $(PY-CHERRYTEMPLATE_BUILD_DIR)
	$(PY-CHERRYTEMPLATE_UNZIP) $(DL_DIR)/$(PY-CHERRYTEMPLATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHERRYTEMPLATE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CHERRYTEMPLATE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHERRYTEMPLATE_DIR) $(PY-CHERRYTEMPLATE_BUILD_DIR)
	(cd $(PY-CHERRYTEMPLATE_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") > setup.cfg \
	)
	touch $(PY-CHERRYTEMPLATE_BUILD_DIR)/.configured

py-cherrytemplate-unpack: $(PY-CHERRYTEMPLATE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CHERRYTEMPLATE_BUILD_DIR)/.built: $(PY-CHERRYTEMPLATE_BUILD_DIR)/.configured
	rm -f $(PY-CHERRYTEMPLATE_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-CHERRYTEMPLATE_BUILD_DIR)
	touch $(PY-CHERRYTEMPLATE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-cherrytemplate: $(PY-CHERRYTEMPLATE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CHERRYTEMPLATE_BUILD_DIR)/.staged: $(PY-CHERRYTEMPLATE_BUILD_DIR)/.built
	rm -f $(PY-CHERRYTEMPLATE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-CHERRYTEMPLATE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CHERRYTEMPLATE_BUILD_DIR)/.staged

py-cherrytemplate-stage: $(PY-CHERRYTEMPLATE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cherrytemplate
#
$(PY-CHERRYTEMPLATE_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CHERRYTEMPLATE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-cherrytemplate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHERRYTEMPLATE_PRIORITY)" >>$@
	@echo "Section: $(PY-CHERRYTEMPLATE_SECTION)" >>$@
	@echo "Version: $(PY-CHERRYTEMPLATE_VERSION)-$(PY-CHERRYTEMPLATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHERRYTEMPLATE_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHERRYTEMPLATE_SITE)/$(PY-CHERRYTEMPLATE_SOURCE)" >>$@
	@echo "Description: $(PY-CHERRYTEMPLATE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CHERRYTEMPLATE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHERRYTEMPLATE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/sbin or $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/etc/py-cherrytemplate/...
# Documentation files should be installed in $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/doc/py-cherrytemplate/...
# Daemon startup scripts should be installed in $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/etc/init.d/S??py-cherrytemplate
#
# You may need to patch your application to make it use these locations.
#
$(PY-CHERRYTEMPLATE_IPK): $(PY-CHERRYTEMPLATE_BUILD_DIR)/.built
	rm -rf $(PY-CHERRYTEMPLATE_IPK_DIR) $(BUILD_DIR)/py-cherrytemplate_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-CHERRYTEMPLATE_BUILD_DIR) DESTDIR=$(PY-CHERRYTEMPLATE_IPK_DIR) install
	(cd $(PY-CHERRYTEMPLATE_BUILD_DIR); \
	python2.4 setup.py install --prefix=$(PY-CHERRYTEMPLATE_IPK_DIR)/opt)
#	install -d $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-CHERRYTEMPLATE_SOURCE_DIR)/py-cherrytemplate.conf $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/etc/py-cherrytemplate.conf
#	install -d $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-CHERRYTEMPLATE_SOURCE_DIR)/rc.py-cherrytemplate $(PY-CHERRYTEMPLATE_IPK_DIR)/opt/etc/init.d/SXXpy-cherrytemplate
	$(MAKE) $(PY-CHERRYTEMPLATE_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-CHERRYTEMPLATE_SOURCE_DIR)/postinst $(PY-CHERRYTEMPLATE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-CHERRYTEMPLATE_SOURCE_DIR)/prerm $(PY-CHERRYTEMPLATE_IPK_DIR)/CONTROL/prerm
#	echo $(PY-CHERRYTEMPLATE_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CHERRYTEMPLATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CHERRYTEMPLATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cherrytemplate-ipk: $(PY-CHERRYTEMPLATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cherrytemplate-clean:
	-$(MAKE) -C $(PY-CHERRYTEMPLATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cherrytemplate-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CHERRYTEMPLATE_DIR) $(PY-CHERRYTEMPLATE_BUILD_DIR) $(PY-CHERRYTEMPLATE_IPK_DIR) $(PY-CHERRYTEMPLATE_IPK)
