###########################################################
#
# devio
#
###########################################################
#
# DEVIO_VERSION, DEVIO_SITE and DEVIO_SOURCE define
# the upstream location of the source code for the package.
# DEVIO_DIR is the directory which is created when the source
# archive is unpacked.
# DEVIO_UNZIP is the command used to unzip the source.
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
DEVIO_SITE=http://ftp.de.debian.org/debian/pool/main/d/devio
DEVIO_VERSION=1.2
DEVIO_SOURCE=devio_$(DEVIO_VERSION).orig.tar.gz
DEVIO_DIR=devio-$(DEVIO_VERSION)
DEVIO_UNZIP=zcat
DEVIO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DEVIO_DESCRIPTION=A command line program intended to read and write from block devices
DEVIO_SECTION=utils
DEVIO_PRIORITY=optional
DEVIO_DEPENDS=
DEVIO_SUGGESTS=
DEVIO_CONFLICTS=

#
# DEVIO_IPK_VERSION should be incremented when the ipk changes.
#
DEVIO_IPK_VERSION=1

#
# DEVIO_CONFFILES should be a list of user-editable files
#DEVIO_CONFFILES=/opt/etc/devio.conf /opt/etc/init.d/SXXdevio

#
# DEVIO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DEVIO_PATCHES=$(DEVIO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEVIO_CPPFLAGS=
DEVIO_LDFLAGS=

#
# DEVIO_BUILD_DIR is the directory in which the build is done.
# DEVIO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DEVIO_IPK_DIR is the directory in which the ipk is built.
# DEVIO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEVIO_BUILD_DIR=$(BUILD_DIR)/devio
DEVIO_SOURCE_DIR=$(SOURCE_DIR)/devio
DEVIO_IPK_DIR=$(BUILD_DIR)/devio-$(DEVIO_VERSION)-ipk
DEVIO_IPK=$(BUILD_DIR)/devio_$(DEVIO_VERSION)-$(DEVIO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: devio-source devio-unpack devio devio-stage devio-ipk devio-clean devio-dirclean devio-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DEVIO_SOURCE):
	$(WGET) -P $(@D) $(DEVIO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
devio-source: $(DL_DIR)/$(DEVIO_SOURCE) $(DEVIO_PATCHES)

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
$(DEVIO_BUILD_DIR)/.configured: $(DL_DIR)/$(DEVIO_SOURCE) $(DEVIO_PATCHES) make/devio.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DEVIO_DIR) $(@D)
	$(DEVIO_UNZIP) $(DL_DIR)/$(DEVIO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DEVIO_PATCHES)" ; \
		then cat $(DEVIO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DEVIO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DEVIO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DEVIO_DIR) $(@D) ; \
	fi
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DEVIO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DEVIO_LDFLAGS)" \
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

devio-unpack: $(DEVIO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DEVIO_BUILD_DIR)/.built: $(DEVIO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
devio: $(DEVIO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DEVIO_BUILD_DIR)/.staged: $(DEVIO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

devio-stage: $(DEVIO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/devio
#
$(DEVIO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: devio" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEVIO_PRIORITY)" >>$@
	@echo "Section: $(DEVIO_SECTION)" >>$@
	@echo "Version: $(DEVIO_VERSION)-$(DEVIO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEVIO_MAINTAINER)" >>$@
	@echo "Source: $(DEVIO_SITE)/$(DEVIO_SOURCE)" >>$@
	@echo "Description: $(DEVIO_DESCRIPTION)" >>$@
	@echo "Depends: $(DEVIO_DEPENDS)" >>$@
	@echo "Suggests: $(DEVIO_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEVIO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DEVIO_IPK_DIR)/opt/sbin or $(DEVIO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DEVIO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DEVIO_IPK_DIR)/opt/etc/devio/...
# Documentation files should be installed in $(DEVIO_IPK_DIR)/opt/doc/devio/...
# Daemon startup scripts should be installed in $(DEVIO_IPK_DIR)/opt/etc/init.d/S??devio
#
# You may need to patch your application to make it use these locations.
#
$(DEVIO_IPK): $(DEVIO_BUILD_DIR)/.built
	rm -rf $(DEVIO_IPK_DIR) $(BUILD_DIR)/devio_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DEVIO_BUILD_DIR) DESTDIR=$(DEVIO_IPK_DIR) install-strip
	$(MAKE) $(DEVIO_IPK_DIR)/CONTROL/control
	echo $(DEVIO_CONFFILES) | sed -e 's/ /\n/g' > $(DEVIO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEVIO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
devio-ipk: $(DEVIO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
devio-clean:
	rm -f $(DEVIO_BUILD_DIR)/.built
	-$(MAKE) -C $(DEVIO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
devio-dirclean:
	rm -rf $(BUILD_DIR)/$(DEVIO_DIR) $(DEVIO_BUILD_DIR) $(DEVIO_IPK_DIR) $(DEVIO_IPK)
#
#
# Some sanity check for the package.
#
devio-check: $(DEVIO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
