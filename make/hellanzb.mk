###########################################################
#
# hellanzb
#
###########################################################
#
# HELLANZB_VERSION, HELLANZB_SITE and HELLANZB_SOURCE define
# the upstream location of the source code for the package.
# HELLANZB_DIR is the directory which is created when the source
# archive is unpacked.
# HELLANZB_UNZIP is the command used to unzip the source.
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
HELLANZB_SITE=http://www.hellanzb.com/distfiles/
HELLANZB_VERSION=0.13
HELLANZB_SOURCE=hellanzb-$(HELLANZB_VERSION).tar.gz
HELLANZB_DIR=hellanzb-$(HELLANZB_VERSION)
HELLANZB_UNZIP=zcat
HELLANZB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HELLANZB_DESCRIPTION=Hellanzb is a Python application designed for *nix environments that retrieves nzb files and fully processes them
HELLANZB_SECTION=net
HELLANZB_PRIORITY=optional
HELLANZB_PY24_DEPENDS=python24, py-twisted, py-yenc, par2cmdline, unrar
HELLANZB_PY25_DEPENDS=python25, py25-twisted, py25-yenc, par2cmdline, unrar
HELLANZB_SUGGESTS=
HELLANZB_CONFLICTS=

#
# HELLANZB_IPK_VERSION should be incremented when the ipk changes.
#
HELLANZB_IPK_VERSION=1

#
# HELLANZB_CONFFILES should be a list of user-editable files
HELLANZB_CONFFILES=/opt/etc/hellanzb.conf /opt/etc/init.d/S71hellanzb

#
# HELLANZB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HELLANZB_PATCHES=$(HELLANZB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HELLANZB_CPPFLAGS=
HELLANZB_LDFLAGS=

#
# HELLANZB_BUILD_DIR is the directory in which the build is done.
# HELLANZB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HELLANZB_IPK_DIR is the directory in which the ipk is built.
# HELLANZB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HELLANZB_BUILD_DIR=$(BUILD_DIR)/hellanzb
HELLANZB_SOURCE_DIR=$(SOURCE_DIR)/hellanzb
PY24-HELLANZB_IPK_DIR=$(BUILD_DIR)/py-hellanzb-$(HELLANZB_VERSION)-ipk
PY24-HELLANZB_IPK=$(BUILD_DIR)/py-hellanzb_$(HELLANZB_VERSION)-$(HELLANZB_IPK_VERSION)_$(TARGET_ARCH).ipk
PY25-HELLANZB_IPK_DIR=$(BUILD_DIR)/py25-hellanzb-$(HELLANZB_VERSION)-ipk
PY25-HELLANZB_IPK=$(BUILD_DIR)/py25-hellanzb_$(HELLANZB_VERSION)-$(HELLANZB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hellanzb-source hellanzb-unpack hellanzb hellanzb-stage hellanzb-ipk hellanzb-clean hellanzb-dirclean hellanzb-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HELLANZB_SOURCE):
	$(WGET) -P $(DL_DIR) $(HELLANZB_SITE)/$(HELLANZB_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(HELLANZB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hellanzb-source: $(DL_DIR)/$(HELLANZB_SOURCE) $(HELLANZB_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(HELLANZB_BUILD_DIR)/.configured: $(DL_DIR)/$(HELLANZB_SOURCE) $(HELLANZB_PATCHES) make/hellanzb.mk
	$(MAKE) py-setuptools-stage 
	rm -rf $(BUILD_DIR)/$(HELLANZB_DIR) $(HELLANZB_BUILD_DIR)
	mkdir -p $(HELLANZB_BUILD_DIR) 
	# 2.4 
	$(HELLANZB_UNZIP) $(DL_DIR)/$(HELLANZB_SOURCE) | tar -C $(BUILD_DIR) -xvf - 
	#cat $(HELLANZB_PATCHES) | patch -d $(BUILD_DIR)/$(HELLANZB_DIR) -p1 
	mv $(BUILD_DIR)/$(HELLANZB_DIR) $(HELLANZB_BUILD_DIR)/2.4 
	(cd $(HELLANZB_BUILD_DIR)/2.4; \
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
	# 2.5 
	$(HELLANZB_UNZIP) $(DL_DIR)/$(HELLANZB_SOURCE) | tar -C $(BUILD_DIR) -xvf - 
	#cat $(HELLANZB_PATCHES) | patch -d $(BUILD_DIR)/$(HELLANZB_DIR) -p1 
	mv $(BUILD_DIR)/$(HELLANZB_DIR) $(HELLANZB_BUILD_DIR)/2.5 
	(cd $(HELLANZB_BUILD_DIR)/2.5; \
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
	touch $@ 

hellanzb-unpack: $(HELLANZB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HELLANZB_BUILD_DIR)/.built: $(HELLANZB_BUILD_DIR)/.configured
	rm -f $@
	cd $(HELLANZB_BUILD_DIR)/2.4; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build 
	cd $(HELLANZB_BUILD_DIR)/2.5; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build 
	touch $@

#
# This is the build convenience target.
#
hellanzb: $(HELLANZB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HELLANZB_BUILD_DIR)/.staged: $(HELLANZB_BUILD_DIR)/.built
	rm -f $@
	#(MAKE) -C $(HELLANZB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

hellanzb-stage: $(HELLANZB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hellanzb
#
$(PY24-HELLANZB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-hellanzb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HELLANZB_PRIORITY)" >>$@
	@echo "Section: $(HELLANZB_SECTION)" >>$@
	@echo "Version: $(HELLANZB_VERSION)-$(HELLANZB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HELLANZB_MAINTAINER)" >>$@
	@echo "Source: $(HELLANZB_SITE)/$(HELLANZB_SOURCE)" >>$@
	@echo "Description: $(HELLANZB_DESCRIPTION)" >>$@
	@echo "Depends: $(HELLANZB_PY24_DEPENDS)" >>$@
	@echo "Suggests: $(HELLANZB_SUGGESTS)" >>$@
	@echo "Conflicts: $(HELLANZB_CONFLICTS)" >>$@

$(PY25-HELLANZB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-hellanzb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HELLANZB_PRIORITY)" >>$@
	@echo "Section: $(HELLANZB_SECTION)" >>$@
	@echo "Version: $(HELLANZB_VERSION)-$(HELLANZB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HELLANZB_MAINTAINER)" >>$@
	@echo "Source: $(HELLANZB_SITE)/$(HELLANZB_SOURCE)" >>$@
	@echo "Description: $(HELLANZB_DESCRIPTION)" >>$@
	@echo "Depends: $(HELLANZB_PY25_DEPENDS)" >>$@
	@echo "Suggests: $(HELLANZB_SUGGESTS)" >>$@
	@echo "Conflicts: $(HELLANZB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HELLANZB_IPK_DIR)/opt/sbin or $(HELLANZB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HELLANZB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HELLANZB_IPK_DIR)/opt/etc/hellanzb/...
# Documentation files should be installed in $(HELLANZB_IPK_DIR)/opt/doc/hellanzb/...
# Daemon startup scripts should be installed in $(HELLANZB_IPK_DIR)/opt/etc/init.d/S??hellanzb
#
# You may need to patch your application to make it use these locations.
#
$(PY24-HELLANZB_IPK): $(HELLANZB_BUILD_DIR)/.built
	rm -rf $(PY24-HELLANZB_IPK_DIR) $(BUILD_DIR)/py-hellanzb_*_$(TARGET_ARCH).ipk
	cd $(HELLANZB_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-HELLANZB_IPK_DIR) --prefix=/opt 
	install -d $(PY24-HELLANZB_IPK_DIR)/opt/etc/
	install -m 644 $(HELLANZB_SOURCE_DIR)/hellanzb.conf $(PY24-HELLANZB_IPK_DIR)/opt/etc/hellanzb.conf
	install -d $(PY24-HELLANZB_IPK_DIR)/opt/etc/init.d
	install -m 755 $(HELLANZB_SOURCE_DIR)/rc.hellanzb $(PY24-HELLANZB_IPK_DIR)/opt/etc/init.d/S71hellanzb
	$(MAKE) $(PY24-HELLANZB_IPK_DIR)/CONTROL/control 
	install -m 644 $(HELLANZB_SOURCE_DIR)/postinst $(PY24-HELLANZB_IPK_DIR)/CONTROL/postinst
	echo $(HELLANZB_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-HELLANZB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-HELLANZB_IPK_DIR) 

$(PY25-HELLANZB_IPK): $(HELLANZB_BUILD_DIR)/.built
	rm -rf $(PY25-HELLANZB_IPK_DIR) $(BUILD_DIR)/py25-hellanzb_*_$(TARGET_ARCH).ipk
	cd $(HELLANZB_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-HELLANZB_IPK_DIR) --prefix=/opt 
	install -d $(PY25-HELLANZB_IPK_DIR)/opt/etc/
	install -m 644 $(HELLANZB_SOURCE_DIR)/hellanzb.conf $(PY25-HELLANZB_IPK_DIR)/opt/etc/hellanzb.conf
	install -d $(PY25-HELLANZB_IPK_DIR)/opt/etc/init.d
	install -m 755 $(HELLANZB_SOURCE_DIR)/rc.hellanzb $(PY25-HELLANZB_IPK_DIR)/opt/etc/init.d/S71hellanzb
	$(MAKE) $(PY25-HELLANZB_IPK_DIR)/CONTROL/control
	install -m 644 $(HELLANZB_SOURCE_DIR)/postinst $(PY25-HELLANZB_IPK_DIR)/CONTROL/postinst
	echo $(HELLANZB_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-HELLANZB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-HELLANZB_IPK_DIR) 

#
# This is called from the top level makefile to create the IPK file.
#
hellanzb-ipk: $(PY24-HELLANZB_IPK) $(PY25-HELLANZB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hellanzb-clean:
	rm -f $(HELLANZB_BUILD_DIR)/.built
	-$(MAKE) -C $(HELLANZB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hellanzb-dirclean:
	rm -rf $(BUILD_DIR)/$(HELLANZB_DIR) $(HELLANZB_BUILD_DIR)
	rm -rf $(PY24-HELLANZB_IPK_DIR) $(PY24-HELLANZB_IPK)
	rm -rf $(PY25-HELLANZB_IPK_DIR) $(PY25-HELLANZB_IPK)

#
#
# Some sanity check for the package.
#
hellanzb-check: $(PY24-HELLANZB_IPK) $(PY25-HELLANZB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-HELLANZB_IPK) $(PY25-HELLANZB_IPK)
