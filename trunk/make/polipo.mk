###########################################################
#
# polipo
#
###########################################################
#
# POLIPO_VERSION, POLIPO_SITE and POLIPO_SOURCE define
# the upstream location of the source code for the package.
# POLIPO_DIR is the directory which is created when the source
# archive is unpacked.
# POLIPO_UNZIP is the command used to unzip the source.
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
POLIPO_SITE=http://www.pps.jussieu.fr/~jch/software/files/polipo
POLIPO_VERSION=1.0.4
POLIPO_SOURCE=polipo-$(POLIPO_VERSION).tar.gz
POLIPO_DIR=polipo-$(POLIPO_VERSION)
POLIPO_UNZIP=zcat
POLIPO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POLIPO_DESCRIPTION=Polipo is a small and fast caching web proxy.
POLIPO_SECTION=web
POLIPO_PRIORITY=optional
POLIPO_DEPENDS=
POLIPO_SUGGESTS=
POLIPO_CONFLICTS=

#
# POLIPO_IPK_VERSION should be incremented when the ipk changes.
#
POLIPO_IPK_VERSION=1

#
# POLIPO_CONFFILES should be a list of user-editable files
#POLIPO_CONFFILES=/opt/etc/polipo.conf /opt/etc/init.d/SXXpolipo

#
# POLIPO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#POLIPO_PATCHES=$(POLIPO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POLIPO_CPPFLAGS=
POLIPO_LDFLAGS=

#
# POLIPO_BUILD_DIR is the directory in which the build is done.
# POLIPO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POLIPO_IPK_DIR is the directory in which the ipk is built.
# POLIPO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POLIPO_BUILD_DIR=$(BUILD_DIR)/polipo
POLIPO_SOURCE_DIR=$(SOURCE_DIR)/polipo
POLIPO_IPK_DIR=$(BUILD_DIR)/polipo-$(POLIPO_VERSION)-ipk
POLIPO_IPK=$(BUILD_DIR)/polipo_$(POLIPO_VERSION)-$(POLIPO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: polipo-source polipo-unpack polipo polipo-stage polipo-ipk polipo-clean polipo-dirclean polipo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POLIPO_SOURCE):
	$(WGET) -P $(DL_DIR) $(POLIPO_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
polipo-source: $(DL_DIR)/$(POLIPO_SOURCE) $(POLIPO_PATCHES)

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
$(POLIPO_BUILD_DIR)/.configured: $(DL_DIR)/$(POLIPO_SOURCE) $(POLIPO_PATCHES) make/polipo.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(POLIPO_DIR) $(@D)
	$(POLIPO_UNZIP) $(DL_DIR)/$(POLIPO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POLIPO_PATCHES)" ; \
		then cat $(POLIPO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(POLIPO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(POLIPO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(POLIPO_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POLIPO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POLIPO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

polipo-unpack: $(POLIPO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POLIPO_BUILD_DIR)/.built: $(POLIPO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POLIPO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POLIPO_LDFLAGS)" \
		PREFIX=/opt \
		LOCAL_ROOT=/opt/share/polipo/www \
		DISK_CACHE_ROOT=/opt/var/cache/polipo \
		;
	touch $@

#
# This is the build convenience target.
#
polipo: $(POLIPO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POLIPO_BUILD_DIR)/.staged: $(POLIPO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

polipo-stage: $(POLIPO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/polipo
#
$(POLIPO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: polipo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POLIPO_PRIORITY)" >>$@
	@echo "Section: $(POLIPO_SECTION)" >>$@
	@echo "Version: $(POLIPO_VERSION)-$(POLIPO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POLIPO_MAINTAINER)" >>$@
	@echo "Source: $(POLIPO_SITE)/$(POLIPO_SOURCE)" >>$@
	@echo "Description: $(POLIPO_DESCRIPTION)" >>$@
	@echo "Depends: $(POLIPO_DEPENDS)" >>$@
	@echo "Suggests: $(POLIPO_SUGGESTS)" >>$@
	@echo "Conflicts: $(POLIPO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POLIPO_IPK_DIR)/opt/sbin or $(POLIPO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POLIPO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POLIPO_IPK_DIR)/opt/etc/polipo/...
# Documentation files should be installed in $(POLIPO_IPK_DIR)/opt/doc/polipo/...
# Daemon startup scripts should be installed in $(POLIPO_IPK_DIR)/opt/etc/init.d/S??polipo
#
# You may need to patch your application to make it use these locations.
#
$(POLIPO_IPK): $(POLIPO_BUILD_DIR)/.built
	rm -rf $(POLIPO_IPK_DIR) $(BUILD_DIR)/polipo_*_$(TARGET_ARCH).ipk
	PATH=/usr/sbin:$$PATH \
	$(MAKE) -C $(POLIPO_BUILD_DIR) install \
		TARGET=$(POLIPO_IPK_DIR) \
		PREFIX=/opt \
		LOCAL_ROOT=/opt/share/polipo/www \
		DISK_CACHE_ROOT=/opt/var/cache/polipo \
		;
	$(STRIP_COMMAND) $(POLIPO_IPK_DIR)/opt/*bin/*
	rm -f $(POLIPO_IPK_DIR)/opt/info/dir*
	install -d $(POLIPO_IPK_DIR)/opt/var/cache/polipo
	$(MAKE) $(POLIPO_IPK_DIR)/CONTROL/control
	echo $(POLIPO_CONFFILES) | sed -e 's/ /\n/g' > $(POLIPO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POLIPO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
polipo-ipk: $(POLIPO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
polipo-clean:
	rm -f $(POLIPO_BUILD_DIR)/.built
	-$(MAKE) -C $(POLIPO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
polipo-dirclean:
	rm -rf $(BUILD_DIR)/$(POLIPO_DIR) $(POLIPO_BUILD_DIR) $(POLIPO_IPK_DIR) $(POLIPO_IPK)
#
#
# Some sanity check for the package.
#
polipo-check: $(POLIPO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POLIPO_IPK)
