###########################################################
#
# stgit
#
###########################################################

#
# STGIT_VERSION, STGIT_SITE and STGIT_SOURCE define
# the upstream location of the source code for the package.
# STGIT_DIR is the directory which is created when the source
# archive is unpacked.
# STGIT_UNZIP is the command used to unzip the source.
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
STGIT_SITE=http://download.gna.org/stgit
STGIT_VERSION=0.15
STGIT_SOURCE=stgit-$(STGIT_VERSION).tar.gz
STGIT_DIR=stgit-$(STGIT_VERSION)
STGIT_UNZIP=zcat
STGIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
STGIT_DESCRIPTION=StGit is a Python application providing similar functionality to Quilt (i.e. pushing/popping patches to/from a stack) on top of Git.
STGIT_SECTION=util
STGIT_PRIORITY=optional
STGIT_DEPENDS=python25, git
STGIT_SUGGESTS=
STGIT_CONFLICTS=

#
# STGIT_IPK_VERSION should be incremented when the ipk changes.
#
STGIT_IPK_VERSION=1

#
# STGIT_CONFFILES should be a list of user-editable files
#STGIT_CONFFILES=/opt/etc/stgit.conf /opt/etc/init.d/SXXstgit

#
# STGIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# STGIT_PATCHES=$(STGIT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
STGIT_CPPFLAGS=
STGIT_LDFLAGS=

#
# STGIT_BUILD_DIR is the directory in which the build is done.
# STGIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STGIT_IPK_DIR is the directory in which the ipk is built.
# STGIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STGIT_BUILD_DIR=$(BUILD_DIR)/stgit
STGIT_SOURCE_DIR=$(SOURCE_DIR)/stgit
STGIT_IPK_DIR=$(BUILD_DIR)/stgit-$(STGIT_VERSION)-ipk
STGIT_IPK=$(BUILD_DIR)/stgit_$(STGIT_VERSION)-$(STGIT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: stgit-source stgit-unpack stgit stgit-stage stgit-ipk stgit-clean stgit-dirclean stgit-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STGIT_SOURCE):
	$(WGET) -P $(@D) $(STGIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
stgit-source: $(DL_DIR)/$(STGIT_SOURCE) $(STGIT_PATCHES)

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
$(STGIT_BUILD_DIR)/.configured: $(DL_DIR)/$(STGIT_SOURCE) $(STGIT_PATCHES) make/stgit.mk
	$(MAKE) python25-host-stage
	rm -rf $(BUILD_DIR)/$(STGIT_DIR) $(@D)
	$(STGIT_UNZIP) $(DL_DIR)/$(STGIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(STGIT_PATCHES)" ; \
		then cat $(STGIT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(STGIT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(STGIT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(STGIT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) > setup.cfg; \
	)
	touch $@

stgit-unpack: $(STGIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(STGIT_BUILD_DIR)/.built: $(STGIT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5 prefix=/opt
	touch $@

#
# This is the build convenience target.
#
stgit: $(STGIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STGIT_BUILD_DIR)/.staged: $(STGIT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

stgit-stage: $(STGIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/stgit
#
$(STGIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: stgit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STGIT_PRIORITY)" >>$@
	@echo "Section: $(STGIT_SECTION)" >>$@
	@echo "Version: $(STGIT_VERSION)-$(STGIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STGIT_MAINTAINER)" >>$@
	@echo "Source: $(STGIT_SITE)/$(STGIT_SOURCE)" >>$@
	@echo "Description: $(STGIT_DESCRIPTION)" >>$@
	@echo "Depends: $(STGIT_DEPENDS)" >>$@
	@echo "Suggests: $(STGIT_SUGGESTS)" >>$@
	@echo "Conflicts: $(STGIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(STGIT_IPK_DIR)/opt/sbin or $(STGIT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STGIT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STGIT_IPK_DIR)/opt/etc/stgit/...
# Documentation files should be installed in $(STGIT_IPK_DIR)/opt/doc/stgit/...
# Daemon startup scripts should be installed in $(STGIT_IPK_DIR)/opt/etc/init.d/S??stgit
#
# You may need to patch your application to make it use these locations.
#
$(STGIT_IPK): $(STGIT_BUILD_DIR)/.built
	rm -rf $(STGIT_IPK_DIR) $(BUILD_DIR)/stgit_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(STGIT_BUILD_DIR) install \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		prefix=/opt \
		DESTDIR=$(STGIT_IPK_DIR)
	$(MAKE) $(STGIT_IPK_DIR)/CONTROL/control
	echo $(STGIT_CONFFILES) | sed -e 's/ /\n/g' > $(STGIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STGIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
stgit-ipk: $(STGIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
stgit-clean:
	rm -f $(STGIT_BUILD_DIR)/.built
	-$(MAKE) -C $(STGIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
stgit-dirclean:
	rm -rf $(BUILD_DIR)/$(STGIT_DIR) $(STGIT_BUILD_DIR) $(STGIT_IPK_DIR) $(STGIT_IPK)
#
#
# Some sanity check for the package.
#
stgit-check: $(STGIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
