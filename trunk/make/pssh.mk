###########################################################
#
# pssh
#
###########################################################

#
# PSSH_VERSION, PSSH_SITE and PSSH_SOURCE define
# the upstream location of the source code for the package.
# PSSH_DIR is the directory which is created when the source
# archive is unpacked.
# PSSH_UNZIP is the command used to unzip the source.
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
PSSH_VERSION=1.4.3
PSSH_SITE=http://www.theether.org/pssh
PSSH_SOURCE=pssh-$(PSSH_VERSION).tar.gz
PSSH_DIR=pssh-$(PSSH_VERSION)
PSSH_UNZIP=zcat
PSSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PSSH_DESCRIPTION=pssh provides parallel versions of openssh tools.
PSSH_SECTION=utils
PSSH_PRIORITY=optional
PSSH_DEPENDS=python25, openssh
PSSH_SUGGESTS=rsync
PSSH_CONFLICTS=

#
# PSSH_IPK_VERSION should be incremented when the ipk changes.
#
PSSH_IPK_VERSION=1

#
# PSSH_CONFFILES should be a list of user-editable files
#PSSH_CONFFILES=/opt/etc/pssh.conf /opt/etc/init.d/SXXpssh

#
# PSSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PSSH_PATCHES=$(PSSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PSSH_CPPFLAGS=
PSSH_LDFLAGS=

#
# PSSH_BUILD_DIR is the directory in which the build is done.
# PSSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PSSH_IPK_DIR is the directory in which the ipk is built.
# PSSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PSSH_BUILD_DIR=$(BUILD_DIR)/pssh
PSSH_SOURCE_DIR=$(SOURCE_DIR)/pssh

PSSH_IPK_DIR=$(BUILD_DIR)/pssh-$(PSSH_VERSION)-ipk
PSSH_IPK=$(BUILD_DIR)/pssh_$(PSSH_VERSION)-$(PSSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pssh-source pssh-unpack pssh pssh-stage pssh-ipk pssh-clean pssh-dirclean pssh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PSSH_SOURCE):
	$(WGET) -P $(@D) $(PSSH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pssh-source: $(DL_DIR)/$(PSSH_SOURCE) $(PSSH_PATCHES)

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
$(PSSH_BUILD_DIR)/.configured: $(DL_DIR)/$(PSSH_SOURCE) $(PSSH_PATCHES) make/pssh.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PSSH_DIR)
	$(PSSH_UNZIP) $(DL_DIR)/$(PSSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PSSH_PATCHES) | patch -d $(BUILD_DIR)/$(PSSH_DIR) -p1
	mv $(BUILD_DIR)/$(PSSH_DIR) $(@D)/2.5
	sed -i -e '1s|#!.*|#!/opt/bin/python2.5|' $(@D)/2.5/bin/p*
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
	touch $@

pssh-unpack: $(PSSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PSSH_BUILD_DIR)/.built: $(PSSH_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
pssh: $(PSSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PSSH_BUILD_DIR)/.staged: $(PSSH_BUILD_DIR)/.built
#	rm -f $@
#	#$(MAKE) -C $(PSSH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#pssh-stage: $(PSSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pssh
#
$(PSSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pssh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PSSH_PRIORITY)" >>$@
	@echo "Section: $(PSSH_SECTION)" >>$@
	@echo "Version: $(PSSH_VERSION)-$(PSSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PSSH_MAINTAINER)" >>$@
	@echo "Source: $(PSSH_SITE)/$(PSSH_SOURCE)" >>$@
	@echo "Description: $(PSSH_DESCRIPTION)" >>$@
	@echo "Depends: $(PSSH_DEPENDS)" >>$@
	@echo "Suggests: $(PSSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(PSSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PSSH_IPK_DIR)/opt/sbin or $(PSSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PSSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PSSH_IPK_DIR)/opt/etc/pssh/...
# Documentation files should be installed in $(PSSH_IPK_DIR)/opt/doc/pssh/...
# Daemon startup scripts should be installed in $(PSSH_IPK_DIR)/opt/etc/init.d/S??pssh
#
# You may need to patch your application to make it use these locations.
#
$(PSSH_IPK): $(PSSH_BUILD_DIR)/.built
	rm -rf $(PSSH_IPK_DIR) $(BUILD_DIR)/pssh_*_$(TARGET_ARCH).ipk
	(cd $(PSSH_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PSSH_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PSSH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PSSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pssh-ipk: $(PSSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pssh-clean:
	-$(MAKE) -C $(PSSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pssh-dirclean:
	rm -rf $(BUILD_DIR)/$(PSSH_DIR) $(PSSH_BUILD_DIR)
	rm -rf $(PSSH_IPK_DIR) $(PSSH_IPK)

#
# Some sanity check for the package.
#
pssh-check: $(PSSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
