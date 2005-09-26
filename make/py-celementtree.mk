###########################################################
#
# py-celementtree
#
###########################################################

#
# PY-CELEMENTTREE_VERSION, PY-CELEMENTTREE_SITE and PY-CELEMENTTREE_SOURCE define
# the upstream location of the source code for the package.
# PY-CELEMENTTREE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CELEMENTTREE_UNZIP is the command used to unzip the source.
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
PY-CELEMENTTREE_SITE=http://effbot.org/downloads
PY-CELEMENTTREE_VERSION=1.0.2-20050302
PY-CELEMENTTREE_SOURCE=cElementTree-$(PY-CELEMENTTREE_VERSION).tar.gz
PY-CELEMENTTREE_DIR=cElementTree-$(PY-CELEMENTTREE_VERSION)
PY-CELEMENTTREE_UNZIP=zcat
PY-CELEMENTTREE_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-CELEMENTTREE_DESCRIPTION=A toolkit that contains a number of light-weight components for working with XML (C implementation).
PY-CELEMENTTREE_SECTION=misc
PY-CELEMENTTREE_PRIORITY=optional
PY-CELEMENTTREE_DEPENDS=python
PY-CELEMENTTREE_CONFLICTS=

#
# PY-CELEMENTTREE_IPK_VERSION should be incremented when the ipk changes.
#
PY-CELEMENTTREE_IPK_VERSION=1

#
# PY-CELEMENTTREE_CONFFILES should be a list of user-editable files
#PY-CELEMENTTREE_CONFFILES=/opt/etc/py-celementtree.conf /opt/etc/init.d/SXXpy-celementtree

#
# PY-CELEMENTTREE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CELEMENTTREE_PATCHES=$(PY-CELEMENTTREE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CELEMENTTREE_CPPFLAGS=
PY-CELEMENTTREE_LDFLAGS=

#
# PY-CELEMENTTREE_BUILD_DIR is the directory in which the build is done.
# PY-CELEMENTTREE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CELEMENTTREE_IPK_DIR is the directory in which the ipk is built.
# PY-CELEMENTTREE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CELEMENTTREE_BUILD_DIR=$(BUILD_DIR)/py-celementtree
PY-CELEMENTTREE_SOURCE_DIR=$(SOURCE_DIR)/py-celementtree
PY-CELEMENTTREE_IPK_DIR=$(BUILD_DIR)/py-celementtree-$(PY-CELEMENTTREE_VERSION)-ipk
PY-CELEMENTTREE_IPK=$(BUILD_DIR)/py-celementtree$(PY-CELEMENTTREE_VERSION)-$(PY-CELEMENTTREE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CELEMENTTREE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CELEMENTTREE_SITE)/$(PY-CELEMENTTREE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-celementtree-source: $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) $(PY-CELEMENTTREE_PATCHES)

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
$(PY-CELEMENTTREE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) $(PY-CELEMENTTREE_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) $(PY-CELEMENTTREE_BUILD_DIR)
	$(PY-CELEMENTTREE_UNZIP) $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CELEMENTTREE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) -p1
#	    echo "libraries=sqlite3"; 
	mv $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) $(PY-CELEMENTTREE_BUILD_DIR)
	(cd $(PY-CELEMENTTREE_BUILD_DIR); \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_DIR)/opt/include"; \
	    echo "library-dirs=$(STAGING_DIR)/opt/lib"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") > setup.cfg \
	)
	touch $(PY-CELEMENTTREE_BUILD_DIR)/.configured

py-celementtree-unpack: $(PY-CELEMENTTREE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CELEMENTTREE_BUILD_DIR)/.built: $(PY-CELEMENTTREE_BUILD_DIR)/.configured
	rm -f $(PY-CELEMENTTREE_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR)
	(cd $(PY-CELEMENTTREE_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-CELEMENTTREE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-celementtree: $(PY-CELEMENTTREE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CELEMENTTREE_BUILD_DIR)/.staged: $(PY-CELEMENTTREE_BUILD_DIR)/.built
	rm -f $(PY-CELEMENTTREE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CELEMENTTREE_BUILD_DIR)/.staged

py-celementtree-stage: $(PY-CELEMENTTREE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-celementtree
#
$(PY-CELEMENTTREE_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CELEMENTTREE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-celementtree" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CELEMENTTREE_PRIORITY)" >>$@
	@echo "Section: $(PY-CELEMENTTREE_SECTION)" >>$@
	@echo "Version: $(PY-CELEMENTTREE_VERSION)-$(PY-CELEMENTTREE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CELEMENTTREE_MAINTAINER)" >>$@
	@echo "Source: $(PY-CELEMENTTREE_SITE)/$(PY-CELEMENTTREE_SOURCE)" >>$@
	@echo "Description: $(PY-CELEMENTTREE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CELEMENTTREE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CELEMENTTREE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CELEMENTTREE_IPK_DIR)/opt/sbin or $(PY-CELEMENTTREE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CELEMENTTREE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/py-celementtree/...
# Documentation files should be installed in $(PY-CELEMENTTREE_IPK_DIR)/opt/doc/py-celementtree/...
# Daemon startup scripts should be installed in $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/init.d/S??py-celementtree
#
# You may need to patch your application to make it use these locations.
#
$(PY-CELEMENTTREE_IPK): $(PY-CELEMENTTREE_BUILD_DIR)/.built
	rm -rf $(PY-CELEMENTTREE_IPK_DIR) $(BUILD_DIR)/py-celementtree_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR) DESTDIR=$(PY-CELEMENTTREE_IPK_DIR) install
	(cd $(PY-CELEMENTTREE_BUILD_DIR); \
	python2.4 setup.py install --prefix=$(PY-CELEMENTTREE_IPK_DIR)/opt)
	$(STRIP_COMMAND) $(PY-CELEMENTTREE_IPK_DIR)/opt/lib/python2.4/site-packages/*.so
#	install -d $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-CELEMENTTREE_SOURCE_DIR)/py-celementtree.conf $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/py-celementtree.conf
#	install -d $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-CELEMENTTREE_SOURCE_DIR)/rc.py-celementtree $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/init.d/SXXpy-celementtree
	$(MAKE) $(PY-CELEMENTTREE_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-CELEMENTTREE_SOURCE_DIR)/postinst $(PY-CELEMENTTREE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-CELEMENTTREE_SOURCE_DIR)/prerm $(PY-CELEMENTTREE_IPK_DIR)/CONTROL/prerm
#	echo $(PY-CELEMENTTREE_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CELEMENTTREE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CELEMENTTREE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-celementtree-ipk: $(PY-CELEMENTTREE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-celementtree-clean:
	-$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-celementtree-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) $(PY-CELEMENTTREE_BUILD_DIR) $(PY-CELEMENTTREE_IPK_DIR) $(PY-CELEMENTTREE_IPK)
