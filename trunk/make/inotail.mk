###########################################################
#
# inotail
#
###########################################################
#
# INOTAIL_VERSION, INOTAIL_SITE and INOTAIL_SOURCE define
# the upstream location of the source code for the package.
# INOTAIL_DIR is the directory which is created when the source
# archive is unpacked.
# INOTAIL_UNZIP is the command used to unzip the source.
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
INOTAIL_SITE=http://distanz.ch/inotail
INOTAIL_VERSION=0.4
INOTAIL_SOURCE=inotail-$(INOTAIL_VERSION).tar.bz2
INOTAIL_DIR=inotail-$(INOTAIL_VERSION)
INOTAIL_UNZIP=bzcat
INOTAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INOTAIL_DESCRIPTION=Describe inotail here.
INOTAIL_SECTION=util
INOTAIL_PRIORITY=optional
INOTAIL_DEPENDS=
INOTAIL_SUGGESTS=
INOTAIL_CONFLICTS=

#
# INOTAIL_IPK_VERSION should be incremented when the ipk changes.
#
INOTAIL_IPK_VERSION=1

#
# INOTAIL_CONFFILES should be a list of user-editable files
#INOTAIL_CONFFILES=/opt/etc/inotail.conf /opt/etc/init.d/SXXinotail

#
# INOTAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#INOTAIL_PATCHES=$(INOTAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INOTAIL_CPPFLAGS=
INOTAIL_LDFLAGS=

#
# INOTAIL_BUILD_DIR is the directory in which the build is done.
# INOTAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INOTAIL_IPK_DIR is the directory in which the ipk is built.
# INOTAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INOTAIL_BUILD_DIR=$(BUILD_DIR)/inotail
INOTAIL_SOURCE_DIR=$(SOURCE_DIR)/inotail
INOTAIL_IPK_DIR=$(BUILD_DIR)/inotail-$(INOTAIL_VERSION)-ipk
INOTAIL_IPK=$(BUILD_DIR)/inotail_$(INOTAIL_VERSION)-$(INOTAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: inotail-source inotail-unpack inotail inotail-stage inotail-ipk inotail-clean inotail-dirclean inotail-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INOTAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(INOTAIL_SITE)/$(INOTAIL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(INOTAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
inotail-source: $(DL_DIR)/$(INOTAIL_SOURCE) $(INOTAIL_PATCHES)

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
$(INOTAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(INOTAIL_SOURCE) $(INOTAIL_PATCHES) make/inotail.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(INOTAIL_DIR) $(INOTAIL_BUILD_DIR)
	$(INOTAIL_UNZIP) $(DL_DIR)/$(INOTAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(INOTAIL_PATCHES)" ; \
		then cat $(INOTAIL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INOTAIL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(INOTAIL_DIR)" != "$(INOTAIL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(INOTAIL_DIR) $(INOTAIL_BUILD_DIR) ; \
	fi
#	(cd $(INOTAIL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INOTAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INOTAIL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

inotail-unpack: $(INOTAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INOTAIL_BUILD_DIR)/.built: $(INOTAIL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(INOTAIL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INOTAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INOTAIL_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
inotail: $(INOTAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(INOTAIL_BUILD_DIR)/.staged: $(INOTAIL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(INOTAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

inotail-stage: $(INOTAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/inotail
#
$(INOTAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: inotail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INOTAIL_PRIORITY)" >>$@
	@echo "Section: $(INOTAIL_SECTION)" >>$@
	@echo "Version: $(INOTAIL_VERSION)-$(INOTAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INOTAIL_MAINTAINER)" >>$@
	@echo "Source: $(INOTAIL_SITE)/$(INOTAIL_SOURCE)" >>$@
	@echo "Description: $(INOTAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(INOTAIL_DEPENDS)" >>$@
	@echo "Suggests: $(INOTAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(INOTAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INOTAIL_IPK_DIR)/opt/sbin or $(INOTAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INOTAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INOTAIL_IPK_DIR)/opt/etc/inotail/...
# Documentation files should be installed in $(INOTAIL_IPK_DIR)/opt/doc/inotail/...
# Daemon startup scripts should be installed in $(INOTAIL_IPK_DIR)/opt/etc/init.d/S??inotail
#
# You may need to patch your application to make it use these locations.
#
$(INOTAIL_IPK): $(INOTAIL_BUILD_DIR)/.built
	rm -rf $(INOTAIL_IPK_DIR) $(BUILD_DIR)/inotail_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(INOTAIL_BUILD_DIR) install \
		DESTDIR=$(INOTAIL_IPK_DIR) \
		prefix=$(INOTAIL_IPK_DIR)/opt
	$(STRIP_COMMAND) $(INOTAIL_IPK_DIR)/opt/bin/inotail
	$(MAKE) $(INOTAIL_IPK_DIR)/CONTROL/control
	echo $(INOTAIL_CONFFILES) | sed -e 's/ /\n/g' > $(INOTAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INOTAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
inotail-ipk: $(INOTAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
inotail-clean:
	rm -f $(INOTAIL_BUILD_DIR)/.built
	-$(MAKE) -C $(INOTAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
inotail-dirclean:
	rm -rf $(BUILD_DIR)/$(INOTAIL_DIR) $(INOTAIL_BUILD_DIR) $(INOTAIL_IPK_DIR) $(INOTAIL_IPK)
#
#
# Some sanity check for the package.
#
inotail-check: $(INOTAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(INOTAIL_IPK)
