###########################################################
#
# sipcalc
#
###########################################################
#
# SIPCALC_VERSION, SIPCALC_SITE and SIPCALC_SOURCE define
# the upstream location of the source code for the package.
# SIPCALC_DIR is the directory which is created when the source
# archive is unpacked.
# SIPCALC_UNZIP is the command used to unzip the source.
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
SIPCALC_SITE=http://www.routemeister.net/projects/sipcalc/files
SIPCALC_VERSION=1.1.4
SIPCALC_SOURCE=sipcalc-$(SIPCALC_VERSION).tar.gz
SIPCALC_DIR=sipcalc-$(SIPCALC_VERSION)
SIPCALC_UNZIP=zcat
SIPCALC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SIPCALC_DESCRIPTION=Sipcalc is an "advanced" console based ip subnet calculator.
SIPCALC_SECTION=util
SIPCALC_PRIORITY=optional
SIPCALC_DEPENDS=
SIPCALC_SUGGESTS=
SIPCALC_CONFLICTS=

#
# SIPCALC_IPK_VERSION should be incremented when the ipk changes.
#
SIPCALC_IPK_VERSION=1

#
# SIPCALC_CONFFILES should be a list of user-editable files
#SIPCALC_CONFFILES=/opt/etc/sipcalc.conf /opt/etc/init.d/SXXsipcalc

#
# SIPCALC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SIPCALC_PATCHES=$(SIPCALC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SIPCALC_CPPFLAGS=
SIPCALC_LDFLAGS=

#
# SIPCALC_BUILD_DIR is the directory in which the build is done.
# SIPCALC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SIPCALC_IPK_DIR is the directory in which the ipk is built.
# SIPCALC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SIPCALC_BUILD_DIR=$(BUILD_DIR)/sipcalc
SIPCALC_SOURCE_DIR=$(SOURCE_DIR)/sipcalc
SIPCALC_IPK_DIR=$(BUILD_DIR)/sipcalc-$(SIPCALC_VERSION)-ipk
SIPCALC_IPK=$(BUILD_DIR)/sipcalc_$(SIPCALC_VERSION)-$(SIPCALC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sipcalc-source sipcalc-unpack sipcalc sipcalc-stage sipcalc-ipk sipcalc-clean sipcalc-dirclean sipcalc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SIPCALC_SOURCE):
	$(WGET) -P $(DL_DIR) $(SIPCALC_SITE)/$(SIPCALC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SIPCALC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sipcalc-source: $(DL_DIR)/$(SIPCALC_SOURCE) $(SIPCALC_PATCHES)

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
$(SIPCALC_BUILD_DIR)/.configured: $(DL_DIR)/$(SIPCALC_SOURCE) $(SIPCALC_PATCHES) make/sipcalc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SIPCALC_DIR) $(SIPCALC_BUILD_DIR)
	$(SIPCALC_UNZIP) $(DL_DIR)/$(SIPCALC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SIPCALC_PATCHES)" ; \
		then cat $(SIPCALC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SIPCALC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SIPCALC_DIR)" != "$(SIPCALC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SIPCALC_DIR) $(SIPCALC_BUILD_DIR) ; \
	fi
	(cd $(SIPCALC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SIPCALC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SIPCALC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SIPCALC_BUILD_DIR)/libtool
	touch $@

sipcalc-unpack: $(SIPCALC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SIPCALC_BUILD_DIR)/.built: $(SIPCALC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SIPCALC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
sipcalc: $(SIPCALC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SIPCALC_BUILD_DIR)/.staged: $(SIPCALC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SIPCALC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

sipcalc-stage: $(SIPCALC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sipcalc
#
$(SIPCALC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sipcalc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SIPCALC_PRIORITY)" >>$@
	@echo "Section: $(SIPCALC_SECTION)" >>$@
	@echo "Version: $(SIPCALC_VERSION)-$(SIPCALC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SIPCALC_MAINTAINER)" >>$@
	@echo "Source: $(SIPCALC_SITE)/$(SIPCALC_SOURCE)" >>$@
	@echo "Description: $(SIPCALC_DESCRIPTION)" >>$@
	@echo "Depends: $(SIPCALC_DEPENDS)" >>$@
	@echo "Suggests: $(SIPCALC_SUGGESTS)" >>$@
	@echo "Conflicts: $(SIPCALC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SIPCALC_IPK_DIR)/opt/sbin or $(SIPCALC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SIPCALC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SIPCALC_IPK_DIR)/opt/etc/sipcalc/...
# Documentation files should be installed in $(SIPCALC_IPK_DIR)/opt/doc/sipcalc/...
# Daemon startup scripts should be installed in $(SIPCALC_IPK_DIR)/opt/etc/init.d/S??sipcalc
#
# You may need to patch your application to make it use these locations.
#
$(SIPCALC_IPK): $(SIPCALC_BUILD_DIR)/.built
	rm -rf $(SIPCALC_IPK_DIR) $(BUILD_DIR)/sipcalc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SIPCALC_BUILD_DIR) DESTDIR=$(SIPCALC_IPK_DIR) install
	$(STRIP_COMMAND) $(SIPCALC_IPK_DIR)/opt/bin/sipcalc
	$(MAKE) $(SIPCALC_IPK_DIR)/CONTROL/control
	echo $(SIPCALC_CONFFILES) | sed -e 's/ /\n/g' > $(SIPCALC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SIPCALC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sipcalc-ipk: $(SIPCALC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sipcalc-clean:
	rm -f $(SIPCALC_BUILD_DIR)/.built
	-$(MAKE) -C $(SIPCALC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sipcalc-dirclean:
	rm -rf $(BUILD_DIR)/$(SIPCALC_DIR) $(SIPCALC_BUILD_DIR) $(SIPCALC_IPK_DIR) $(SIPCALC_IPK)
#
#
# Some sanity check for the package.
#
sipcalc-check: $(SIPCALC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SIPCALC_IPK)
