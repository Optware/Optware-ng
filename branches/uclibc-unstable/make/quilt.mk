###########################################################
#
# quilt
#
###########################################################
#
# QUILT_VERSION, QUILT_SITE and QUILT_SOURCE define
# the upstream location of the source code for the package.
# QUILT_DIR is the directory which is created when the source
# archive is unpacked.
# QUILT_UNZIP is the command used to unzip the source.
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
QUILT_SITE=http://savannah.nongnu.org/download/quilt
QUILT_VERSION=0.46
QUILT_SOURCE=quilt-$(QUILT_VERSION).tar.gz
QUILT_DIR=quilt-$(QUILT_VERSION)
QUILT_UNZIP=zcat
QUILT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QUILT_DESCRIPTION=A set of scripts to manage a series of patches.
QUILT_SECTION=misc
QUILT_PRIORITY=optional
QUILT_DEPENDS=perl, coreutils
QUILT_SUGGESTS=
QUILT_CONFLICTS=

#
# QUILT_IPK_VERSION should be incremented when the ipk changes.
#
QUILT_IPK_VERSION=1

#
# QUILT_CONFFILES should be a list of user-editable files
#QUILT_CONFFILES=/opt/etc/quilt.conf /opt/etc/init.d/SXXquilt

#
# QUILT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#QUILT_PATCHES=$(QUILT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QUILT_CPPFLAGS=
QUILT_LDFLAGS=

#
# QUILT_BUILD_DIR is the directory in which the build is done.
# QUILT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QUILT_IPK_DIR is the directory in which the ipk is built.
# QUILT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QUILT_BUILD_DIR=$(BUILD_DIR)/quilt
QUILT_SOURCE_DIR=$(SOURCE_DIR)/quilt
QUILT_IPK_DIR=$(BUILD_DIR)/quilt-$(QUILT_VERSION)-ipk
QUILT_IPK=$(BUILD_DIR)/quilt_$(QUILT_VERSION)-$(QUILT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: quilt-source quilt-unpack quilt quilt-stage quilt-ipk quilt-clean quilt-dirclean quilt-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QUILT_SOURCE):
	$(WGET) -P $(DL_DIR) $(QUILT_SITE)/$(QUILT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
quilt-source: $(DL_DIR)/$(QUILT_SOURCE) $(QUILT_PATCHES)

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
$(QUILT_BUILD_DIR)/.configured: $(DL_DIR)/$(QUILT_SOURCE) $(QUILT_PATCHES) make/quilt.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(QUILT_DIR) $(QUILT_BUILD_DIR)
	$(QUILT_UNZIP) $(DL_DIR)/$(QUILT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(QUILT_PATCHES)" ; \
		then cat $(QUILT_PATCHES) | patch -d $(BUILD_DIR)/$(QUILT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(QUILT_DIR)" != "$(QUILT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(QUILT_DIR) $(QUILT_BUILD_DIR) ; \
	fi
	(cd $(QUILT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QUILT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QUILT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(QUILT_BUILD_DIR)/libtool
	touch $(QUILT_BUILD_DIR)/.configured

quilt-unpack: $(QUILT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QUILT_BUILD_DIR)/.built: $(QUILT_BUILD_DIR)/.configured
	rm -f $(QUILT_BUILD_DIR)/.built
	$(MAKE) -C $(QUILT_BUILD_DIR)
	touch $(QUILT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
quilt: $(QUILT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(QUILT_BUILD_DIR)/.staged: $(QUILT_BUILD_DIR)/.built
	rm -f $(QUILT_BUILD_DIR)/.staged
	$(MAKE) -C $(QUILT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(QUILT_BUILD_DIR)/.staged

quilt-stage: $(QUILT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/quilt
#
$(QUILT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: quilt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QUILT_PRIORITY)" >>$@
	@echo "Section: $(QUILT_SECTION)" >>$@
	@echo "Version: $(QUILT_VERSION)-$(QUILT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QUILT_MAINTAINER)" >>$@
	@echo "Source: $(QUILT_SITE)/$(QUILT_SOURCE)" >>$@
	@echo "Description: $(QUILT_DESCRIPTION)" >>$@
	@echo "Depends: $(QUILT_DEPENDS)" >>$@
	@echo "Suggests: $(QUILT_SUGGESTS)" >>$@
	@echo "Conflicts: $(QUILT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QUILT_IPK_DIR)/opt/sbin or $(QUILT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QUILT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(QUILT_IPK_DIR)/opt/etc/quilt/...
# Documentation files should be installed in $(QUILT_IPK_DIR)/opt/doc/quilt/...
# Daemon startup scripts should be installed in $(QUILT_IPK_DIR)/opt/etc/init.d/S??quilt
#
# You may need to patch your application to make it use these locations.
#
$(QUILT_IPK): $(QUILT_BUILD_DIR)/.built
	rm -rf $(QUILT_IPK_DIR) $(BUILD_DIR)/quilt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(QUILT_BUILD_DIR) install BUILD_ROOT=$(QUILT_IPK_DIR) COMPAT_SYMLINKS=""
	$(STRIP_COMMAND) $(QUILT_IPK_DIR)/opt/lib/quilt/backup-files
#	install -d $(QUILT_IPK_DIR)/opt/etc/
#	install -m 644 $(QUILT_SOURCE_DIR)/quilt.conf $(QUILT_IPK_DIR)/opt/etc/quilt.conf
#	install -d $(QUILT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(QUILT_SOURCE_DIR)/rc.quilt $(QUILT_IPK_DIR)/opt/etc/init.d/SXXquilt
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXquilt
	$(MAKE) $(QUILT_IPK_DIR)/CONTROL/control
#	install -m 755 $(QUILT_SOURCE_DIR)/postinst $(QUILT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(QUILT_SOURCE_DIR)/prerm $(QUILT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(QUILT_CONFFILES) | sed -e 's/ /\n/g' > $(QUILT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QUILT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
quilt-ipk: $(QUILT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
quilt-clean:
	rm -f $(QUILT_BUILD_DIR)/.built
	-$(MAKE) -C $(QUILT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
quilt-dirclean:
	rm -rf $(BUILD_DIR)/$(QUILT_DIR) $(QUILT_BUILD_DIR) $(QUILT_IPK_DIR) $(QUILT_IPK)
#
#
# Some sanity check for the package.
#
quilt-check: $(QUILT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(QUILT_IPK)
