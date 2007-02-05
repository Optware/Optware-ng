###########################################################
#
# tzcode
#
###########################################################
#
# TZCODE_VERSION, TZCODE_SITE and TZCODE_SOURCE define
# the upstream location of the source code for the package.
# TZCODE_DIR is the directory which is created when the source
# archive is unpacked.
# TZCODE_UNZIP is the command used to unzip the source.
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
TZCODE_SITE=ftp://elsie.nci.nih.gov/pub
TZCODE_VERSION=2007a
TZCODE_SOURCE=tzcode$(TZCODE_VERSION).tar.gz
TZCODE_TZDATA_TARBALL=tzdata$(TZCODE_VERSION).tar.gz
TZCODE_DIR=tzcode$(TZCODE_VERSION)
TZCODE_UNZIP=zcat
TZCODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TZCODE_DESCRIPTION=Describe tzcode here.
TZCODE_SECTION=sysadmin
TZCODE_PRIORITY=optional
TZCODE_DEPENDS=
TZCODE_SUGGESTS=
TZCODE_CONFLICTS=

#
# TZCODE_IPK_VERSION should be incremented when the ipk changes.
#
TZCODE_IPK_VERSION=1

#
# TZCODE_CONFFILES should be a list of user-editable files
#TZCODE_CONFFILES=/opt/etc/tzcode.conf /opt/etc/init.d/SXXtzcode

#
# TZCODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TZCODE_PATCHES=$(TZCODE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TZCODE_CPPFLAGS=
TZCODE_LDFLAGS=

#
# TZCODE_BUILD_DIR is the directory in which the build is done.
# TZCODE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TZCODE_IPK_DIR is the directory in which the ipk is built.
# TZCODE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TZCODE_BUILD_DIR=$(BUILD_DIR)/tzcode
TZCODE_SOURCE_DIR=$(SOURCE_DIR)/tzcode

TZCODE_IPK_DIR=$(BUILD_DIR)/tzcode-$(TZCODE_VERSION)-ipk
TZCODE_IPK=$(BUILD_DIR)/tzcode_$(TZCODE_VERSION)-$(TZCODE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tzcode-source tzcode-unpack tzcode tzcode-stage tzcode-ipk tzcode-clean tzcode-dirclean tzcode-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TZCODE_SOURCE):
	$(WGET) -P $(DL_DIR) $(TZCODE_SITE)/$(TZCODE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TZCODE_SOURCE)

$(DL_DIR)/$(TZCODE_TZDATA_TARBALL):
	$(WGET) -P $(DL_DIR) $(TZCODE_SITE)/$(TZCODE_TZDATA_TARBALL) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TZCODE_TZDATA_TARBALL)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tzcode-source: $(DL_DIR)/$(TZCODE_SOURCE) $(DL_DIR)/$(TZCODE_TZDATA_TARBALL) $(TZCODE_PATCHES)

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
$(TZCODE_BUILD_DIR)/.configured: tzcode-source $(TZCODE_PATCHES) make/tzcode.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TZCODE_DIR) $(TZCODE_BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(TZCODE_DIR)
	$(TZCODE_UNZIP) $(DL_DIR)/$(TZCODE_SOURCE) | tar -C $(BUILD_DIR)/$(TZCODE_DIR) -xvf -
	$(TZCODE_UNZIP) $(DL_DIR)/$(TZCODE_TZDATA_TARBALL) | tar -C $(BUILD_DIR)/$(TZCODE_DIR) -xvf -
	if test -n "$(TZCODE_PATCHES)" ; \
		then cat $(TZCODE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TZCODE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TZCODE_DIR)" != "$(TZCODE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TZCODE_DIR) $(TZCODE_BUILD_DIR) ; \
	fi
#	(cd $(TZCODE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TZCODE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TZCODE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

tzcode-unpack: $(TZCODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TZCODE_BUILD_DIR)/.built: $(TZCODE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(TZCODE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TZCODE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TZCODE_LDFLAGS)" \
		cc=$(TARGET_CC) \
		TOPDIR=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
tzcode: $(TZCODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TZCODE_BUILD_DIR)/.staged: $(TZCODE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TZCODE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

tzcode-stage: $(TZCODE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tzcode
#
$(TZCODE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tzcode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TZCODE_PRIORITY)" >>$@
	@echo "Section: $(TZCODE_SECTION)" >>$@
	@echo "Version: $(TZCODE_VERSION)-$(TZCODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TZCODE_MAINTAINER)" >>$@
	@echo "Source: $(TZCODE_SITE)/$(TZCODE_SOURCE)" >>$@
	@echo "Description: $(TZCODE_DESCRIPTION)" >>$@
	@echo "Depends: $(TZCODE_DEPENDS)" >>$@
	@echo "Suggests: $(TZCODE_SUGGESTS)" >>$@
	@echo "Conflicts: $(TZCODE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TZCODE_IPK_DIR)/opt/sbin or $(TZCODE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TZCODE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TZCODE_IPK_DIR)/opt/etc/tzcode/...
# Documentation files should be installed in $(TZCODE_IPK_DIR)/opt/doc/tzcode/...
# Daemon startup scripts should be installed in $(TZCODE_IPK_DIR)/opt/etc/init.d/S??tzcode
#
# You may need to patch your application to make it use these locations.
#
$(TZCODE_IPK): $(TZCODE_BUILD_DIR)/.built
	rm -rf $(TZCODE_IPK_DIR) $(BUILD_DIR)/tzcode_*_$(TARGET_ARCH).ipk
	install -d $(TZCODE_IPK_DIR)/opt/etc/zoneinfo
	install -d $(TZCODE_IPK_DIR)/opt/sbin
	$(MAKE) -C $(TZCODE_BUILD_DIR) TOPDIR=$(TZCODE_IPK_DIR)/opt install zic=true
	rm -f $(TZCODE_IPK_DIR)/opt/etc/tzselect $(TZCODE_IPK_DIR)/opt/man/man8/tzselect.8
	rm -rf $(TZCODE_IPK_DIR)/opt/lib
	mv $(TZCODE_IPK_DIR)/opt/etc/zdump \
	   $(TZCODE_IPK_DIR)/opt/etc/zic \
	   $(TZCODE_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(TZCODE_IPK_DIR)/opt/sbin/*
#	install -d $(TZCODE_IPK_DIR)/opt/etc/
#	install -m 644 $(TZCODE_SOURCE_DIR)/tzcode.conf $(TZCODE_IPK_DIR)/opt/etc/tzcode.conf
#	install -d $(TZCODE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TZCODE_SOURCE_DIR)/rc.tzcode $(TZCODE_IPK_DIR)/opt/etc/init.d/SXXtzcode
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZCODE_IPK_DIR)/opt/etc/init.d/SXXtzcode
	$(MAKE) $(TZCODE_IPK_DIR)/CONTROL/control
#	install -m 755 $(TZCODE_SOURCE_DIR)/postinst $(TZCODE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZCODE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TZCODE_SOURCE_DIR)/prerm $(TZCODE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZCODE_IPK_DIR)/CONTROL/prerm
	echo $(TZCODE_CONFFILES) | sed -e 's/ /\n/g' > $(TZCODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TZCODE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tzcode-ipk: $(TZCODE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tzcode-clean:
	rm -f $(TZCODE_BUILD_DIR)/.built
	-$(MAKE) -C $(TZCODE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tzcode-dirclean:
	rm -rf $(BUILD_DIR)/$(TZCODE_DIR) $(TZCODE_BUILD_DIR) $(TZCODE_IPK_DIR) $(TZCODE_IPK)
#
#
# Some sanity check for the package.
#
tzcode-check: $(TZCODE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TZCODE_IPK)
