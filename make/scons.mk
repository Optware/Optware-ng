###########################################################
#
# scons
#
###########################################################

# You must replace "scons" and "SCONS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SCONS_VERSION, SCONS_SITE and SCONS_SOURCE define
# the upstream location of the source code for the package.
# SCONS_DIR is the directory which is created when the source
# archive is unpacked.
# SCONS_UNZIP is the command used to unzip the source.
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
SCONS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/scons
SCONS_VERSION=1.0.0
SCONS_SOURCE=scons-$(SCONS_VERSION).tar.gz
SCONS_DIR=scons-$(SCONS_VERSION)
SCONS_UNZIP=zcat
SCONS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SCONS_DESCRIPTION=An improved, cross-platform substitute for the classic Make utility with integrated functionality similar to autoconf/automake and compiler caches such as ccache.
SCONS_SECTION=devel
SCONS_PRIORITY=optional
SCONS_DEPENDS=python
SCONS_SUGGESTS=
SCONS_CONFLICTS=

#
# SCONS_IPK_VERSION should be incremented when the ipk changes.
#
SCONS_IPK_VERSION=1

#
# SCONS_CONFFILES should be a list of user-editable files
#SCONS_CONFFILES=/opt/etc/scons.conf /opt/etc/init.d/SXXscons

#
# SCONS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SCONS_PATCHES=$(SCONS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCONS_CPPFLAGS=
SCONS_LDFLAGS=

#
# SCONS_BUILD_DIR is the directory in which the build is done.
# SCONS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCONS_IPK_DIR is the directory in which the ipk is built.
# SCONS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCONS_SOURCE_DIR=$(SOURCE_DIR)/scons

SCONS_BUILD_DIR=$(BUILD_DIR)/scons
SCONS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/scons

SCONS_IPK_DIR=$(BUILD_DIR)/scons-$(SCONS_VERSION)-ipk
SCONS_IPK=$(BUILD_DIR)/scons_$(SCONS_VERSION)-$(SCONS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCONS_SOURCE):
	$(WGET) -P $(@D) $(SCONS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
scons-source: $(DL_DIR)/$(SCONS_SOURCE) $(SCONS_PATCHES)

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
$(SCONS_BUILD_DIR)/.configured: $(DL_DIR)/$(SCONS_SOURCE) $(SCONS_PATCHES) make/scons.mk
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(SCONS_DIR) $(@D)
	$(SCONS_UNZIP) $(DL_DIR)/$(SCONS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SCONS_PATCHES)" ; \
		then cat $(SCONS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SCONS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SCONS_DIR)" != "$(SCONS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SCONS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	    chmod +w setup.cfg ; \
	    ( \
		echo ; \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
	    ) >> setup.cfg; \
	)
	touch $@

scons-unpack: $(SCONS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SCONS_BUILD_DIR)/.built: $(SCONS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
        )
	touch $@

#
# This is the build convenience target.
#
scons: $(SCONS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SCONS_BUILD_DIR)/.staged: $(SCONS_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D); \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
			--root=$(STAGING_DIR) --prefix=/opt; \
        )
	touch $@

scons-stage: $(SCONS_BUILD_DIR)/.staged

$(SCONS_HOST_BUILD_DIR)/.staged: host/.configured make/scons.mk
	rm -f $@
	rm -rf $(HOST_STAGING_PREFIX)/bin/scons* \
		$(HOST_STAGING_LIB_DIR)/scons-*
	$(MAKE) python-stage
	rm -rf $(HOST_BUILD_DIR)/$(SCONS_DIR) $(@D)
	$(SCONS_UNZIP) $(DL_DIR)/$(SCONS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(SCONS_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(SCONS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	    chmod +w setup.cfg ; \
	    ( \
		echo ; \
		echo "[build_ext]"; \
		echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D); \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
			--root=$(HOST_STAGING_DIR) --prefix=/opt; \
        )
	touch $@

scons-host-stage: $(SCONS_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/scons
#
$(SCONS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: scons" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SCONS_PRIORITY)" >>$@
	@echo "Section: $(SCONS_SECTION)" >>$@
	@echo "Version: $(SCONS_VERSION)-$(SCONS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SCONS_MAINTAINER)" >>$@
	@echo "Source: $(SCONS_SITE)/$(SCONS_SOURCE)" >>$@
	@echo "Description: $(SCONS_DESCRIPTION)" >>$@
	@echo "Depends: $(SCONS_DEPENDS)" >>$@
	@echo "Suggests: $(SCONS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SCONS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SCONS_IPK_DIR)/opt/sbin or $(SCONS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCONS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCONS_IPK_DIR)/opt/etc/scons/...
# Documentation files should be installed in $(SCONS_IPK_DIR)/opt/doc/scons/...
# Daemon startup scripts should be installed in $(SCONS_IPK_DIR)/opt/etc/init.d/S??scons
#
# You may need to patch your application to make it use these locations.
#
$(SCONS_IPK): $(SCONS_BUILD_DIR)/.built
	rm -rf $(SCONS_IPK_DIR) $(BUILD_DIR)/scons_*_$(TARGET_ARCH).ipk
	(cd $(SCONS_BUILD_DIR); \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
			--root=$(SCONS_IPK_DIR) --prefix=/opt; \
        )
	install -d $(SCONS_IPK_DIR)/opt/etc/
	$(MAKE) $(SCONS_IPK_DIR)/CONTROL/control
	echo $(SCONS_CONFFILES) | sed -e 's/ /\n/g' > $(SCONS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCONS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
scons-ipk: $(SCONS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
scons-clean:
	rm -f $(SCONS_BUILD_DIR)/.built
	-$(MAKE) -C $(SCONS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
scons-dirclean:
	rm -rf $(BUILD_DIR)/$(SCONS_DIR) $(SCONS_BUILD_DIR) $(SCONS_IPK_DIR) $(SCONS_IPK)
