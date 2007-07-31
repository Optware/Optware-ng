###########################################################
#
# fconfig
#
###########################################################
#
# FCONFIG_VERSION, FCONFIG_SITE and FCONFIG_SOURCE define
# the upstream location of the source code for the package.
# FCONFIG_DIR is the directory which is created when the source
# archive is unpacked.
# FCONFIG_UNZIP is the command used to unzip the source.
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
FCONFIG_SITE=http://andrzejekiert.ovh.org/software/fconfig
FCONFIG_VERSION=20060419
FCONFIG_SOURCE=fconfig-$(FCONFIG_VERSION).tar.gz
FCONFIG_DIR=fconfig
FCONFIG_UNZIP=zcat
FCONFIG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FCONFIG_DESCRIPTION=Tool to edit the Redboot config from userspace.
FCONFIG_SECTION=utils
FCONFIG_PRIORITY=optional
FCONFIG_DEPENDS=
FCONFIG_SUGGESTS=
FCONFIG_CONFLICTS=

#
# FCONFIG_IPK_VERSION should be incremented when the ipk changes.
#
FCONFIG_IPK_VERSION=1

#
# FCONFIG_CONFFILES should be a list of user-editable files
#FCONFIG_CONFFILES=/opt/etc/fconfig.conf /opt/etc/init.d/SXXfconfig

#
# FCONFIG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FCONFIG_PATCHES=$(FCONFIG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FCONFIG_CPPFLAGS=
FCONFIG_LDFLAGS=

#
# FCONFIG_BUILD_DIR is the directory in which the build is done.
# FCONFIG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FCONFIG_IPK_DIR is the directory in which the ipk is built.
# FCONFIG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FCONFIG_BUILD_DIR=$(BUILD_DIR)/fconfig
FCONFIG_SOURCE_DIR=$(SOURCE_DIR)/fconfig
FCONFIG_IPK_DIR=$(BUILD_DIR)/fconfig-$(FCONFIG_VERSION)-ipk
FCONFIG_IPK=$(BUILD_DIR)/fconfig_$(FCONFIG_VERSION)-$(FCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fconfig-source fconfig-unpack fconfig fconfig-stage fconfig-ipk fconfig-clean fconfig-dirclean fconfig-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FCONFIG_SOURCE):
	$(WGET) -P $(DL_DIR) $(FCONFIG_SITE)/$(FCONFIG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FCONFIG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fconfig-source: $(DL_DIR)/$(FCONFIG_SOURCE) $(FCONFIG_PATCHES)

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
$(FCONFIG_BUILD_DIR)/.configured: $(DL_DIR)/$(FCONFIG_SOURCE) $(FCONFIG_PATCHES) make/fconfig.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FCONFIG_DIR) $(FCONFIG_BUILD_DIR)
	$(FCONFIG_UNZIP) $(DL_DIR)/$(FCONFIG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FCONFIG_PATCHES)" ; \
		then cat $(FCONFIG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FCONFIG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FCONFIG_DIR)" != "$(FCONFIG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FCONFIG_DIR) $(FCONFIG_BUILD_DIR) ; \
	fi
#	(cd $(FCONFIG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FCONFIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FCONFIG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(FCONFIG_BUILD_DIR)/libtool
	touch $@

fconfig-unpack: $(FCONFIG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FCONFIG_BUILD_DIR)/.built: $(FCONFIG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FCONFIG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FCONFIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FCONFIG_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
fconfig: $(FCONFIG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FCONFIG_BUILD_DIR)/.staged: $(FCONFIG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FCONFIG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

fconfig-stage: $(FCONFIG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fconfig
#
$(FCONFIG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fconfig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FCONFIG_PRIORITY)" >>$@
	@echo "Section: $(FCONFIG_SECTION)" >>$@
	@echo "Version: $(FCONFIG_VERSION)-$(FCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(FCONFIG_SITE)/$(FCONFIG_SOURCE)" >>$@
	@echo "Description: $(FCONFIG_DESCRIPTION)" >>$@
	@echo "Depends: $(FCONFIG_DEPENDS)" >>$@
	@echo "Suggests: $(FCONFIG_SUGGESTS)" >>$@
	@echo "Conflicts: $(FCONFIG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FCONFIG_IPK_DIR)/opt/sbin or $(FCONFIG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FCONFIG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FCONFIG_IPK_DIR)/opt/etc/fconfig/...
# Documentation files should be installed in $(FCONFIG_IPK_DIR)/opt/doc/fconfig/...
# Daemon startup scripts should be installed in $(FCONFIG_IPK_DIR)/opt/etc/init.d/S??fconfig
#
# You may need to patch your application to make it use these locations.
#
$(FCONFIG_IPK): $(FCONFIG_BUILD_DIR)/.built
	rm -rf $(FCONFIG_IPK_DIR) $(BUILD_DIR)/fconfig_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FCONFIG_BUILD_DIR) DESTDIR=$(FCONFIG_IPK_DIR) install-strip
	install -d $(FCONFIG_IPK_DIR)/opt/sbin/
	install -m 755 $(FCONFIG_BUILD_DIR)/fconfig $(FCONFIG_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(FCONFIG_IPK_DIR)/opt/sbin/fconfig
#	install -m 644 $(FCONFIG_SOURCE_DIR)/fconfig.conf $(FCONFIG_IPK_DIR)/opt/etc/fconfig.conf
#	install -d $(FCONFIG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FCONFIG_SOURCE_DIR)/rc.fconfig $(FCONFIG_IPK_DIR)/opt/etc/init.d/SXXfconfig
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FCONFIG_IPK_DIR)/opt/etc/init.d/SXXfconfig
	$(MAKE) $(FCONFIG_IPK_DIR)/CONTROL/control
#	install -m 755 $(FCONFIG_SOURCE_DIR)/postinst $(FCONFIG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FCONFIG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FCONFIG_SOURCE_DIR)/prerm $(FCONFIG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FCONFIG_IPK_DIR)/CONTROL/prerm
	echo $(FCONFIG_CONFFILES) | sed -e 's/ /\n/g' > $(FCONFIG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FCONFIG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fconfig-ipk: $(FCONFIG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fconfig-clean:
	rm -f $(FCONFIG_BUILD_DIR)/.built
	-$(MAKE) -C $(FCONFIG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fconfig-dirclean:
	rm -rf $(BUILD_DIR)/$(FCONFIG_DIR) $(FCONFIG_BUILD_DIR) $(FCONFIG_IPK_DIR) $(FCONFIG_IPK)
#
#
# Some sanity check for the package.
#
fconfig-check: $(FCONFIG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FCONFIG_IPK)
