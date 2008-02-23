###########################################################
#
# gpsd
#
###########################################################
#
# GPSD_VERSION, GPSD_SITE and GPSD_SOURCE define
# the upstream location of the source code for the package.
# GPSD_DIR is the directory which is created when the source
# archive is unpacked.
# GPSD_UNZIP is the command used to unzip the source.
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
GPSD_SITE=http://download.berlios.de/gpsd
GPSD_VERSION=2.37
GPSD_SOURCE=gpsd-$(GPSD_VERSION).tar.gz
GPSD_DIR=gpsd-$(GPSD_VERSION)
GPSD_UNZIP=zcat
GPSD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GPSD_DESCRIPTION=A daemon that communicates with GPS receiver and provides data to other applications.
GPSD_SECTION=misc
GPSD_PRIORITY=optional
GPSD_DEPENDS=
GPSD_SUGGESTS=
GPSD_CONFLICTS=

#
# GPSD_IPK_VERSION should be incremented when the ipk changes.
#
GPSD_IPK_VERSION=1

#
# GPSD_CONFFILES should be a list of user-editable files
#GPSD_CONFFILES=/opt/etc/gpsd.conf /opt/etc/init.d/SXXgpsd

#
# GPSD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GPSD_PATCHES=$(GPSD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GPSD_CPPFLAGS=
ifdef NO_BUILTIN_MATH
GPSD_CPPFLAGS += -fno-builtin-rint
endif
GPSD_LDFLAGS=

GPSD_CONFIG_ARGS=
ifneq ($(OPTWARE_TARGET), $(filter angstrombe angstromle slugosbe slugosle, $(OPTWARE_TARGET)))
GPSD_CONFIG_ARGS += --disable-python
endif

#
# GPSD_BUILD_DIR is the directory in which the build is done.
# GPSD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GPSD_IPK_DIR is the directory in which the ipk is built.
# GPSD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GPSD_BUILD_DIR=$(BUILD_DIR)/gpsd
GPSD_SOURCE_DIR=$(SOURCE_DIR)/gpsd
GPSD_IPK_DIR=$(BUILD_DIR)/gpsd-$(GPSD_VERSION)-ipk
GPSD_IPK=$(BUILD_DIR)/gpsd_$(GPSD_VERSION)-$(GPSD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gpsd-source gpsd-unpack gpsd gpsd-stage gpsd-ipk gpsd-clean gpsd-dirclean gpsd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GPSD_SOURCE):
	$(WGET) -P $(DL_DIR) $(GPSD_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gpsd-source: $(DL_DIR)/$(GPSD_SOURCE) $(GPSD_PATCHES)

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
$(GPSD_BUILD_DIR)/.configured: $(DL_DIR)/$(GPSD_SOURCE) $(GPSD_PATCHES) make/gpsd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GPSD_DIR) $(@D)
	$(GPSD_UNZIP) $(DL_DIR)/$(GPSD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GPSD_PATCHES)" ; \
		then cat $(GPSD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GPSD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GPSD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GPSD_DIR) $(@D) ; \
	fi
	sed -i -e 's|$$(PYTHON) setup.py|$$(PYTHON_ENV) &|' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GPSD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GPSD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		$(GPSD_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
		; \
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
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gpsd-unpack: $(GPSD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GPSD_BUILD_DIR)/.built: $(GPSD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PYTHON_ENV='$(TARGET_CONFIGURE_OPTS) LDSHARED="$(TARGET_CC) -shared" CPPFLAGS="$(STAGING_CPPFLAGS)"' \
	PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5
	touch $@

#
# This is the build convenience target.
#
gpsd: $(GPSD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GPSD_BUILD_DIR)/.staged: $(GPSD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gpsd-stage: $(GPSD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gpsd
#
$(GPSD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gpsd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GPSD_PRIORITY)" >>$@
	@echo "Section: $(GPSD_SECTION)" >>$@
	@echo "Version: $(GPSD_VERSION)-$(GPSD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GPSD_MAINTAINER)" >>$@
	@echo "Source: $(GPSD_SITE)/$(GPSD_SOURCE)" >>$@
	@echo "Description: $(GPSD_DESCRIPTION)" >>$@
	@echo "Depends: $(GPSD_DEPENDS)" >>$@
	@echo "Suggests: $(GPSD_SUGGESTS)" >>$@
	@echo "Conflicts: $(GPSD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GPSD_IPK_DIR)/opt/sbin or $(GPSD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GPSD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GPSD_IPK_DIR)/opt/etc/gpsd/...
# Documentation files should be installed in $(GPSD_IPK_DIR)/opt/doc/gpsd/...
# Daemon startup scripts should be installed in $(GPSD_IPK_DIR)/opt/etc/init.d/S??gpsd
#
# You may need to patch your application to make it use these locations.
#
$(GPSD_IPK): $(GPSD_BUILD_DIR)/.built
	rm -rf $(GPSD_IPK_DIR) $(BUILD_DIR)/gpsd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GPSD_BUILD_DIR) DESTDIR=$(GPSD_IPK_DIR) install-strip
	-$(STRIP_COMMAND) $(GPSD_IPK_DIR)/opt/lib/python2.5/site-packages/*.so
	$(MAKE) $(GPSD_IPK_DIR)/CONTROL/control
	echo $(GPSD_CONFFILES) | sed -e 's/ /\n/g' > $(GPSD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GPSD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gpsd-ipk: $(GPSD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gpsd-clean:
	rm -f $(GPSD_BUILD_DIR)/.built
	-$(MAKE) -C $(GPSD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gpsd-dirclean:
	rm -rf $(BUILD_DIR)/$(GPSD_DIR) $(GPSD_BUILD_DIR) $(GPSD_IPK_DIR) $(GPSD_IPK)
#
#
# Some sanity check for the package.
#
gpsd-check: $(GPSD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GPSD_IPK)
