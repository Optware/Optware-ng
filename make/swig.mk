###########################################################
#
# swig
#
###########################################################
#
# SWIG_VERSION, SWIG_SITE and SWIG_SOURCE define
# the upstream location of the source code for the package.
# SWIG_DIR is the directory which is created when the source
# archive is unpacked.
# SWIG_UNZIP is the command used to unzip the source.
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
SWIG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/swig
SWIG_VERSION=1.3.39
SWIG_SOURCE=swig-$(SWIG_VERSION).tar.gz
SWIG_DIR=swig-$(SWIG_VERSION)
SWIG_UNZIP=zcat
SWIG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SWIG_DESCRIPTION=Simplified Wrapper and Interface Generator
SWIG_SECTION=devel
SWIG_PRIORITY=optional
SWIG_DEPENDS=libstdc++, zlib
SWIG_SUGGESTS=
SWIG_CONFLICTS=

#
# SWIG_IPK_VERSION should be incremented when the ipk changes.
#
SWIG_IPK_VERSION=3

#
# SWIG_CONFFILES should be a list of user-editable files
#SWIG_CONFFILES=$(TARGET_PREFIX)/etc/swig.conf $(TARGET_PREFIX)/etc/init.d/SXXswig

#
# SWIG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SWIG_PATCHES=$(SWIG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SWIG_CPPFLAGS=
SWIG_LDFLAGS=

#
# SWIG_BUILD_DIR is the directory in which the build is done.
# SWIG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SWIG_IPK_DIR is the directory in which the ipk is built.
# SWIG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SWIG_BUILD_DIR=$(BUILD_DIR)/swig
SWIG_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/swig
SWIG_SOURCE_DIR=$(SOURCE_DIR)/swig
SWIG_IPK_DIR=$(BUILD_DIR)/swig-$(SWIG_VERSION)-ipk
SWIG_IPK=$(BUILD_DIR)/swig_$(SWIG_VERSION)-$(SWIG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: swig-source swig-unpack swig swig-stage swig-ipk swig-clean swig-dirclean swig-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SWIG_SOURCE):
	$(WGET) -P $(@D) $(SWIG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
swig-source: $(DL_DIR)/$(SWIG_SOURCE) $(SWIG_PATCHES)

$(SWIG_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(SWIG_SOURCE) $(SWIG_PATCHES) make/swig.mk
	$(MAKE) zlib-stage
	rm -rf $(HOST_BUILD_DIR)/$(SWIG_DIR) $(@D)
	$(SWIG_UNZIP) $(DL_DIR)/$(SWIG_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(SWIG_PATCHES)" ; \
		then cat $(SWIG_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(SWIG_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(SWIG_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(SWIG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	$(MAKE) -C $(@D)
	touch $@

swig-host: $(SWIG_HOST_BUILD_DIR)/.built

$(SWIG_HOST_BUILD_DIR)/.staged: $(SWIG_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(HOST_STAGING_DIR) install
	touch $@

swig-host-stage: $(SWIG_HOST_BUILD_DIR)/.staged

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
$(SWIG_BUILD_DIR)/.configured: $(DL_DIR)/$(SWIG_SOURCE) $(SWIG_PATCHES) make/swig.mk
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(SWIG_DIR) $(@D)
	$(SWIG_UNZIP) $(DL_DIR)/$(SWIG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SWIG_PATCHES)" ; \
		then cat $(SWIG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SWIG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SWIG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SWIG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SWIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SWIG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

swig-unpack: $(SWIG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SWIG_BUILD_DIR)/.built: $(SWIG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SWIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SWIG_LDFLAGS)" \
;
	touch $@

#
# This is the build convenience target.
#
swig: $(SWIG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SWIG_BUILD_DIR)/.staged: $(SWIG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

swig-stage: $(SWIG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/swig
#
$(SWIG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: swig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SWIG_PRIORITY)" >>$@
	@echo "Section: $(SWIG_SECTION)" >>$@
	@echo "Version: $(SWIG_VERSION)-$(SWIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SWIG_MAINTAINER)" >>$@
	@echo "Source: $(SWIG_SITE)/$(SWIG_SOURCE)" >>$@
	@echo "Description: $(SWIG_DESCRIPTION)" >>$@
	@echo "Depends: $(SWIG_DEPENDS)" >>$@
	@echo "Suggests: $(SWIG_SUGGESTS)" >>$@
	@echo "Conflicts: $(SWIG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SWIG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SWIG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SWIG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SWIG_IPK_DIR)$(TARGET_PREFIX)/etc/swig/...
# Documentation files should be installed in $(SWIG_IPK_DIR)$(TARGET_PREFIX)/doc/swig/...
# Daemon startup scripts should be installed in $(SWIG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??swig
#
# You may need to patch your application to make it use these locations.
#
$(SWIG_IPK): $(SWIG_BUILD_DIR)/.built
	rm -rf $(SWIG_IPK_DIR) $(BUILD_DIR)/swig_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SWIG_BUILD_DIR) DESTDIR=$(SWIG_IPK_DIR) install
	$(STRIP_COMMAND) $(SWIG_IPK_DIR)$(TARGET_PREFIX)/bin/*swig
	$(MAKE) $(SWIG_IPK_DIR)/CONTROL/control
	echo $(SWIG_CONFFILES) | sed -e 's/ /\n/g' > $(SWIG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SWIG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
swig-ipk: $(SWIG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
swig-clean:
	rm -f $(SWIG_BUILD_DIR)/.built
	-$(MAKE) -C $(SWIG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
swig-dirclean:
	rm -rf $(BUILD_DIR)/$(SWIG_DIR) $(SWIG_BUILD_DIR) $(SWIG_IPK_DIR) $(SWIG_IPK)
#
#
# Some sanity check for the package.
#
swig-check: $(SWIG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
