###########################################################
#
# py-kid
#
###########################################################

#
# PY-KID_VERSION, PY-KID_SITE and PY-KID_SOURCE define
# the upstream location of the source code for the package.
# PY-KID_DIR is the directory which is created when the source
# archive is unpacked.
# PY-KID_UNZIP is the command used to unzip the source.
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
PY-KID_SITE=http://lesscode.org/dist/kid
PY-KID_VERSION=0.6.4
PY-KID_SOURCE=kid-$(PY-KID_VERSION).tar.gz
PY-KID_DIR=kid-$(PY-KID_VERSION)
PY-KID_UNZIP=zcat
PY-KID_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-KID_DESCRIPTION=Pythonic XML-based Templating
PY-KID_SECTION=misc
PY-KID_PRIORITY=optional
PY-KID_DEPENDS=python, py-elementtree
PY-KID_CONFLICTS=

#
# PY-KID_IPK_VERSION should be incremented when the ipk changes.
#
PY-KID_IPK_VERSION=1

#
# PY-KID_CONFFILES should be a list of user-editable files
#PY-KID_CONFFILES=/opt/etc/py-kid.conf /opt/etc/init.d/SXXpy-kid

#
# PY-KID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-KID_PATCHES=$(PY-KID_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-KID_CPPFLAGS=
PY-KID_LDFLAGS=

#
# PY-KID_BUILD_DIR is the directory in which the build is done.
# PY-KID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-KID_IPK_DIR is the directory in which the ipk is built.
# PY-KID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-KID_BUILD_DIR=$(BUILD_DIR)/py-kid
PY-KID_SOURCE_DIR=$(SOURCE_DIR)/py-kid
PY-KID_IPK_DIR=$(BUILD_DIR)/py-kid-$(PY-KID_VERSION)-ipk
PY-KID_IPK=$(BUILD_DIR)/py-kid_$(PY-KID_VERSION)-$(PY-KID_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-KID_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-KID_SITE)/$(PY-KID_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-kid-source: $(DL_DIR)/$(PY-KID_SOURCE) $(PY-KID_PATCHES)

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
$(PY-KID_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-KID_SOURCE) $(PY-KID_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR)
	$(PY-KID_UNZIP) $(DL_DIR)/$(PY-KID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-KID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-KID_DIR) -p1
	mv $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR)
	(cd $(PY-KID_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") > setup.cfg \
	)
	touch $(PY-KID_BUILD_DIR)/.configured

py-kid-unpack: $(PY-KID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-KID_BUILD_DIR)/.built: $(PY-KID_BUILD_DIR)/.configured
	rm -f $(PY-KID_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-KID_BUILD_DIR)
	touch $(PY-KID_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-kid: $(PY-KID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-KID_BUILD_DIR)/.staged: $(PY-KID_BUILD_DIR)/.built
	rm -f $(PY-KID_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-KID_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-KID_BUILD_DIR)/.staged

py-kid-stage: $(PY-KID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-kid
#
$(PY-KID_IPK_DIR)/CONTROL/control:
	@install -d $(PY-KID_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-kid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-KID_PRIORITY)" >>$@
	@echo "Section: $(PY-KID_SECTION)" >>$@
	@echo "Version: $(PY-KID_VERSION)-$(PY-KID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-KID_MAINTAINER)" >>$@
	@echo "Source: $(PY-KID_SITE)/$(PY-KID_SOURCE)" >>$@
	@echo "Description: $(PY-KID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-KID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-KID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-KID_IPK_DIR)/opt/sbin or $(PY-KID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-KID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-KID_IPK_DIR)/opt/etc/py-kid/...
# Documentation files should be installed in $(PY-KID_IPK_DIR)/opt/doc/py-kid/...
# Daemon startup scripts should be installed in $(PY-KID_IPK_DIR)/opt/etc/init.d/S??py-kid
#
# You may need to patch your application to make it use these locations.
#
$(PY-KID_IPK): $(PY-KID_BUILD_DIR)/.built
	rm -rf $(PY-KID_IPK_DIR) $(BUILD_DIR)/py-kid_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-KID_BUILD_DIR) DESTDIR=$(PY-KID_IPK_DIR) install
	(cd $(PY-KID_BUILD_DIR); \
	python2.4 setup.py install --prefix=$(PY-KID_IPK_DIR)/opt)
#	install -d $(PY-KID_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-KID_SOURCE_DIR)/py-kid.conf $(PY-KID_IPK_DIR)/opt/etc/py-kid.conf
#	install -d $(PY-KID_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-KID_SOURCE_DIR)/rc.py-kid $(PY-KID_IPK_DIR)/opt/etc/init.d/SXXpy-kid
	$(MAKE) $(PY-KID_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-KID_SOURCE_DIR)/postinst $(PY-KID_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-KID_SOURCE_DIR)/prerm $(PY-KID_IPK_DIR)/CONTROL/prerm
#	echo $(PY-KID_CONFFILES) | sed -e 's/ /\n/g' > $(PY-KID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-KID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-kid-ipk: $(PY-KID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-kid-clean:
	-$(MAKE) -C $(PY-KID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-kid-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR) $(PY-KID_IPK_DIR) $(PY-KID_IPK)
