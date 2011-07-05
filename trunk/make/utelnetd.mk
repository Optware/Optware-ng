###########################################################
#
# utelnetd
#
###########################################################
#
# UTELNETD_VERSION, UTELNETD_SITE and UTELNETD_SOURCE define
# the upstream location of the source code for the package.
# UTELNETD_DIR is the directory which is created when the source
# archive is unpacked.
# UTELNETD_UNZIP is the command used to unzip the source.
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
UTELNETD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/utelnetd
UTELNETD_VERSION=0.1.9
UTELNETD_SOURCE=utelnetd-$(UTELNETD_VERSION).tar.gz
UTELNETD_DIR=utelnetd-$(UTELNETD_VERSION)
UTELNETD_UNZIP=zcat
UTELNETD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UTELNETD_DESCRIPTION=The utelnetd package provides a small and efficient stand alone telnet server daemon.
UTELNETD_SECTION=utils
UTELNETD_PRIORITY=optional
UTELNETD_DEPENDS=
UTELNETD_SUGGESTS=
UTELNETD_CONFLICTS=

#
# UTELNETD_IPK_VERSION should be incremented when the ipk changes.
#
UTELNETD_IPK_VERSION=2

#
# UTELNETD_CONFFILES should be a list of user-editable files
#UTELNETD_CONFFILES=/opt/etc/utelnetd.conf /opt/etc/init.d/SXXutelnetd

#
# UTELNETD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UTELNETD_PATCHES=$(UTELNETD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UTELNETD_CPPFLAGS=
UTELNETD_LDFLAGS=

#
# UTELNETD_BUILD_DIR is the directory in which the build is done.
# UTELNETD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UTELNETD_IPK_DIR is the directory in which the ipk is built.
# UTELNETD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UTELNETD_BUILD_DIR=$(BUILD_DIR)/utelnetd
UTELNETD_SOURCE_DIR=$(SOURCE_DIR)/utelnetd
UTELNETD_IPK_DIR=$(BUILD_DIR)/utelnetd-$(UTELNETD_VERSION)-ipk
UTELNETD_IPK=$(BUILD_DIR)/utelnetd_$(UTELNETD_VERSION)-$(UTELNETD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: utelnetd-source utelnetd-unpack utelnetd utelnetd-stage utelnetd-ipk utelnetd-clean utelnetd-dirclean utelnetd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UTELNETD_SOURCE):
	$(WGET) -P $(@D) $(UTELNETD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
utelnetd-source: $(DL_DIR)/$(UTELNETD_SOURCE) $(UTELNETD_PATCHES)

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
$(UTELNETD_BUILD_DIR)/.configured: $(DL_DIR)/$(UTELNETD_SOURCE) $(UTELNETD_PATCHES) make/utelnetd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UTELNETD_DIR) $(@D)
	$(UTELNETD_UNZIP) $(DL_DIR)/$(UTELNETD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UTELNETD_PATCHES)" ; \
		then cat $(UTELNETD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UTELNETD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UTELNETD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UTELNETD_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UTELNETD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UTELNETD_LDFLAGS)" \
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

utelnetd-unpack: $(UTELNETD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UTELNETD_BUILD_DIR)/.built: $(UTELNETD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UTELNETD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UTELNETD_LDFLAGS)" \
		LOGIN=/bin/login INSTDIR=/opt/bin \
;
	touch $@

#
# This is the build convenience target.
#
utelnetd: $(UTELNETD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(UTELNETD_BUILD_DIR)/.staged: $(UTELNETD_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#utelnetd-stage: $(UTELNETD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/utelnetd
#
$(UTELNETD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: utelnetd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UTELNETD_PRIORITY)" >>$@
	@echo "Section: $(UTELNETD_SECTION)" >>$@
	@echo "Version: $(UTELNETD_VERSION)-$(UTELNETD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UTELNETD_MAINTAINER)" >>$@
	@echo "Source: $(UTELNETD_SITE)/$(UTELNETD_SOURCE)" >>$@
	@echo "Description: $(UTELNETD_DESCRIPTION)" >>$@
	@echo "Depends: $(UTELNETD_DEPENDS)" >>$@
	@echo "Suggests: $(UTELNETD_SUGGESTS)" >>$@
	@echo "Conflicts: $(UTELNETD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UTELNETD_IPK_DIR)/opt/sbin or $(UTELNETD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UTELNETD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UTELNETD_IPK_DIR)/opt/etc/utelnetd/...
# Documentation files should be installed in $(UTELNETD_IPK_DIR)/opt/doc/utelnetd/...
# Daemon startup scripts should be installed in $(UTELNETD_IPK_DIR)/opt/etc/init.d/S??utelnetd
#
# You may need to patch your application to make it use these locations.
#
$(UTELNETD_IPK): $(UTELNETD_BUILD_DIR)/.built
	rm -rf $(UTELNETD_IPK_DIR) $(BUILD_DIR)/utelnetd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UTELNETD_BUILD_DIR) DESTDIR=$(UTELNETD_IPK_DIR) install \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UTELNETD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UTELNETD_LDFLAGS)" \
		LOGIN=/bin/login INSTDIR=$(UTELNETD_IPK_DIR)/opt/bin \
		INSTOWNER=`id -u` INSTGROUP=`id -g` \
;
	$(MAKE) $(UTELNETD_IPK_DIR)/CONTROL/control
	echo $(UTELNETD_CONFFILES) | sed -e 's/ /\n/g' > $(UTELNETD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UTELNETD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(UTELNETD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
utelnetd-ipk: $(UTELNETD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
utelnetd-clean:
	rm -f $(UTELNETD_BUILD_DIR)/.built
	-$(MAKE) -C $(UTELNETD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
utelnetd-dirclean:
	rm -rf $(BUILD_DIR)/$(UTELNETD_DIR) $(UTELNETD_BUILD_DIR) $(UTELNETD_IPK_DIR) $(UTELNETD_IPK)
#
#
# Some sanity check for the package.
#
utelnetd-check: $(UTELNETD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
