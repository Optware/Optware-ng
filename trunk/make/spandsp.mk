###########################################################
#
# spandsp
#
###########################################################
#
# SPANDSP_VERSION, SPANDSP_SITE and SPANDSP_SOURCE define
# the upstream location of the source code for the package.
# SPANDSP_DIR is the directory which is created when the source
# archive is unpacked.
# SPANDSP_UNZIP is the command used to unzip the source.
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
SPANDSP_SITE=http://www.soft-switch.org/downloads/spandsp
#SPANDSP_VERSION=0.0.4pre12
SPANDSP_PRE_VERSION=pre18
SPANDSP_INITIAL_VERSION=0.0.4
SPANDSP_VERSION=$(SPANDSP_INITIAL_VERSION)$(SPANDSP_PRE_VERSION)
SPANDSP_SOURCE=spandsp-$(SPANDSP_VERSION).tgz
#SPANDSP_DIR=spandsp-$(SPANDSP_VERSION)
SPANDSP_DIR=spandsp-$(SPANDSP_INITIAL_VERSION)
SPANDSP_UNZIP=zcat
SPANDSP_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
SPANDSP_DESCRIPTION=A DSP library for telephony.
SPANDSP_SECTION=telephony
SPANDSP_PRIORITY=optional
SPANDSP_DEPENDS=libtiff, libxml2
SPANDSP_SUGGESTS=
SPANDSP_CONFLICTS=

#
# SPANDSP_IPK_VERSION should be incremented when the ipk changes.
#
SPANDSP_IPK_VERSION=1

#
# SPANDSP_CONFFILES should be a list of user-editable files
#SPANDSP_CONFFILES=/opt/etc/spandsp.conf /opt/etc/init.d/SXXspandsp

#
# SPANDSP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPANDSP_PATCHES=$(SPANDSP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPANDSP_CPPFLAGS=
SPANDSP_LDFLAGS=

#
# SPANDSP_BUILD_DIR is the directory in which the build is done.
# SPANDSP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPANDSP_IPK_DIR is the directory in which the ipk is built.
# SPANDSP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPANDSP_BUILD_DIR=$(BUILD_DIR)/spandsp
SPANDSP_SOURCE_DIR=$(SOURCE_DIR)/spandsp
SPANDSP_IPK_DIR=$(BUILD_DIR)/spandsp-$(SPANDSP_VERSION)-ipk
SPANDSP_IPK=$(BUILD_DIR)/spandsp_$(SPANDSP_VERSION)-$(SPANDSP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: spandsp-source spandsp-unpack spandsp spandsp-stage spandsp-ipk spandsp-clean spandsp-dirclean spandsp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPANDSP_SOURCE):
	$(WGET) -P $(DL_DIR) $(SPANDSP_SITE)/$(SPANDSP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SPANDSP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
spandsp-source: $(DL_DIR)/$(SPANDSP_SOURCE) $(SPANDSP_PATCHES)

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
$(SPANDSP_BUILD_DIR)/.configured: $(DL_DIR)/$(SPANDSP_SOURCE) $(SPANDSP_PATCHES) make/spandsp.mk
	$(MAKE) libtiff-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(SPANDSP_DIR) $(SPANDSP_BUILD_DIR)
	$(SPANDSP_UNZIP) $(DL_DIR)/$(SPANDSP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPANDSP_PATCHES)" ; \
		then cat $(SPANDSP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPANDSP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SPANDSP_DIR)" != "$(SPANDSP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SPANDSP_DIR) $(SPANDSP_BUILD_DIR) ; \
	fi
	(cd $(SPANDSP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPANDSP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPANDSP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(SPANDSP_BUILD_DIR)/libtool
	touch $@

spandsp-unpack: $(SPANDSP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPANDSP_BUILD_DIR)/.built: $(SPANDSP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SPANDSP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
spandsp: $(SPANDSP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPANDSP_BUILD_DIR)/.staged: $(SPANDSP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SPANDSP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

spandsp-stage: $(SPANDSP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/spandsp
#
$(SPANDSP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: spandsp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPANDSP_PRIORITY)" >>$@
	@echo "Section: $(SPANDSP_SECTION)" >>$@
	@echo "Version: $(SPANDSP_VERSION)-$(SPANDSP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPANDSP_MAINTAINER)" >>$@
	@echo "Source: $(SPANDSP_SITE)/$(SPANDSP_SOURCE)" >>$@
	@echo "Description: $(SPANDSP_DESCRIPTION)" >>$@
	@echo "Depends: $(SPANDSP_DEPENDS)" >>$@
	@echo "Suggests: $(SPANDSP_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPANDSP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPANDSP_IPK_DIR)/opt/sbin or $(SPANDSP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPANDSP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPANDSP_IPK_DIR)/opt/etc/spandsp/...
# Documentation files should be installed in $(SPANDSP_IPK_DIR)/opt/doc/spandsp/...
# Daemon startup scripts should be installed in $(SPANDSP_IPK_DIR)/opt/etc/init.d/S??spandsp
#
# You may need to patch your application to make it use these locations.
#
$(SPANDSP_IPK): $(SPANDSP_BUILD_DIR)/.built
	rm -rf $(SPANDSP_IPK_DIR) $(BUILD_DIR)/spandsp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPANDSP_BUILD_DIR) DESTDIR=$(SPANDSP_IPK_DIR) install-strip
	$(MAKE) $(SPANDSP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPANDSP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
spandsp-ipk: $(SPANDSP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
spandsp-clean:
	rm -f $(SPANDSP_BUILD_DIR)/.built
	-$(MAKE) -C $(SPANDSP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
spandsp-dirclean:
	rm -rf $(BUILD_DIR)/$(SPANDSP_DIR) $(SPANDSP_BUILD_DIR) $(SPANDSP_IPK_DIR) $(SPANDSP_IPK)
#
#
# Some sanity check for the package.
#
spandsp-check: $(SPANDSP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SPANDSP_IPK)
