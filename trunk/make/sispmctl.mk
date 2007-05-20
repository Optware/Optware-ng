###########################################################
#
# sispmctl
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
SISPMCTL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/sispmctl
SISPMCTL_VERSION=2.4b
SISPMCTL_SOURCE=sispmctl-$(SISPMCTL_VERSION).tar.gz
SISPMCTL_DIR=sispmctl-$(SISPMCTL_VERSION)
SISPMCTL_UNZIP=zcat
SISPMCTL_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
SISPMCTL_DESCRIPTION=Control software for the SiS-PM intiligent power supply
SISPMCTL_SECTION=tool
SISPMCTL_PRIORITY=optional
SISPMCTL_DEPENDS=libusb
SISPMCTL_SUGGESTS=
SISPMCTL_CONFLICTS=

#
# SISPMCTL_IPK_VERSION should be incremented when the ipk changes.
#
SISPMCTL_IPK_VERSION=1

#
# SISPMCTL_CONFFILES should be a list of user-editable files
#SISPMCTL_CONFFILES=/opt/etc/sispmctl.conf /opt/etc/init.d/SXXsispmctl

#
# SISPMCTL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SISPMCTL_PATCHES=$(SISPMCTL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SISPMCTL_CPPFLAGS=
SISPMCTL_LDFLAGS=

#
# SISPMCTL_BUILD_DIR is the directory in which the build is done.
# SISPMCTL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SISPMCTL_IPK_DIR is the directory in which the ipk is built.
# SISPMCTL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SISPMCTL_BUILD_DIR=$(BUILD_DIR)/sispmctl
SISPMCTL_SOURCE_DIR=$(SOURCE_DIR)/sispmctl
SISPMCTL_IPK_DIR=$(BUILD_DIR)/sispmctl-$(SISPMCTL_VERSION)-ipk
SISPMCTL_IPK=$(BUILD_DIR)/sispmctl_$(SISPMCTL_VERSION)-$(SISPMCTL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sispmctl-source sispmctl-unpack sispmctl sispmctl-stage sispmctl-ipk sispmctl-clean sispmctl-dirclean sispmctl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SISPMCTL_SOURCE):
	$(WGET) -P $(DL_DIR) $(SISPMCTL_SITE)/$(SISPMCTL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SISPMCTL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sispmctl-source: $(DL_DIR)/$(SISPMCTL_SOURCE) $(SISPMCTL_PATCHES)

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
$(SISPMCTL_BUILD_DIR)/.configured: $(DL_DIR)/$(SISPMCTL_SOURCE) $(SISPMCTL_PATCHES) make/sispmctl.mk
	$(MAKE) libusb-stage
	rm -rf $(BUILD_DIR)/$(SISPMCTL_DIR) $(SISPMCTL_BUILD_DIR)
	$(SISPMCTL_UNZIP) $(DL_DIR)/$(SISPMCTL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SISPMCTL_PATCHES)" ; \
		then cat $(SISPMCTL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SISPMCTL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SISPMCTL_DIR)" != "$(SISPMCTL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SISPMCTL_DIR) $(SISPMCTL_BUILD_DIR) ; \
	fi
	(cd $(SISPMCTL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SISPMCTL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SISPMCTL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	# $(PATCH_LIBTOOL) $(SISPMCTL_BUILD_DIR)/libtool
	sed -i -e 's/HAVE_MALLOC 0/HAVE_MALLOC 1/' -e '/^#.*rpl_malloc/s/^\(.*\)/\/* \1 *\//' $(SISPMCTL_BUILD_DIR)/src/config.h

	touch $@

sispmctl-unpack: $(SISPMCTL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SISPMCTL_BUILD_DIR)/.built: $(SISPMCTL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SISPMCTL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
sispmctl: $(SISPMCTL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SISPMCTL_BUILD_DIR)/.staged: $(SISPMCTL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SISPMCTL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

sispmctl-stage: $(SISPMCTL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sispmctl
#
$(SISPMCTL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sispmctl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SISPMCTL_PRIORITY)" >>$@
	@echo "Section: $(SISPMCTL_SECTION)" >>$@
	@echo "Version: $(SISPMCTL_VERSION)-$(SISPMCTL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SISPMCTL_MAINTAINER)" >>$@
	@echo "Source: $(SISPMCTL_SITE)/$(SISPMCTL_SOURCE)" >>$@
	@echo "Description: $(SISPMCTL_DESCRIPTION)" >>$@
	@echo "Depends: $(SISPMCTL_DEPENDS)" >>$@
	@echo "Suggests: $(SISPMCTL_SUGGESTS)" >>$@
	@echo "Conflicts: $(SISPMCTL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SISPMCTL_IPK_DIR)/opt/sbin or $(SISPMCTL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SISPMCTL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SISPMCTL_IPK_DIR)/opt/etc/sispmctl/...
# Documentation files should be installed in $(SISPMCTL_IPK_DIR)/opt/doc/sispmctl/...
# Daemon startup scripts should be installed in $(SISPMCTL_IPK_DIR)/opt/etc/init.d/S??sispmctl
#
# You may need to patch your application to make it use these locations.
#
$(SISPMCTL_IPK): $(SISPMCTL_BUILD_DIR)/.built
	rm -rf $(SISPMCTL_IPK_DIR) $(BUILD_DIR)/sispmctl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SISPMCTL_BUILD_DIR) DESTDIR=$(SISPMCTL_IPK_DIR) install-strip
	install -d $(SISPMCTL_IPK_DIR)/opt/etc/
	# install -m 644 $(SISPMCTL_SOURCE_DIR)/sispmctl.conf $(SISPMCTL_IPK_DIR)/opt/etc/sispmctl.conf
	# install -d $(SISPMCTL_IPK_DIR)/opt/etc/init.d
	# install -m 755 $(SISPMCTL_SOURCE_DIR)/rc.sispmctl $(SISPMCTL_IPK_DIR)/opt/etc/init.d/SXXsispmctl
	# sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SISPMCTL_IPK_DIR)/opt/etc/init.d/SXXsispmctl
	$(MAKE) $(SISPMCTL_IPK_DIR)/CONTROL/control
	# install -m 755 $(SISPMCTL_SOURCE_DIR)/postinst $(SISPMCTL_IPK_DIR)/CONTROL/postinst
	# sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SISPMCTL_IPK_DIR)/CONTROL/postinst
	# install -m 755 $(SISPMCTL_SOURCE_DIR)/prerm $(SISPMCTL_IPK_DIR)/CONTROL/prerm
	# sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SISPMCTL_IPK_DIR)/CONTROL/prerm
	# echo $(SISPMCTL_CONFFILES) | sed -e 's/ /\n/g' > $(SISPMCTL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SISPMCTL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sispmctl-ipk: $(SISPMCTL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sispmctl-clean:
	rm -f $(SISPMCTL_BUILD_DIR)/.built
	-$(MAKE) -C $(SISPMCTL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sispmctl-dirclean:
	rm -rf $(BUILD_DIR)/$(SISPMCTL_DIR) $(SISPMCTL_BUILD_DIR) $(SISPMCTL_IPK_DIR) $(SISPMCTL_IPK)
#
#
# Some sanity check for the package.
#
sispmctl-check: $(SISPMCTL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SISPMCTL_IPK)
