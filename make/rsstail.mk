###########################################################
#
# rsstail
#
###########################################################
#
# RSSTAIL_VERSION, RSSTAIL_SITE and RSSTAIL_SOURCE define
# the upstream location of the source code for the package.
# RSSTAIL_DIR is the directory which is created when the source
# archive is unpacked.
# RSSTAIL_UNZIP is the command used to unzip the source.
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
RSSTAIL_SITE=http://www.vanheusden.com/rsstail
RSSTAIL_VERSION=1.4
RSSTAIL_SOURCE=rsstail-$(RSSTAIL_VERSION).tgz
RSSTAIL_DIR=rsstail-$(RSSTAIL_VERSION)
RSSTAIL_UNZIP=zcat
RSSTAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RSSTAIL_DESCRIPTION=RSSTail is more or less an rss reader.
RSSTAIL_SECTION=web
RSSTAIL_PRIORITY=optional
RSSTAIL_DEPENDS=libmrss
RSSTAIL_SUGGESTS=
RSSTAIL_CONFLICTS=

#
# RSSTAIL_IPK_VERSION should be incremented when the ipk changes.
#
RSSTAIL_IPK_VERSION=1

#
# RSSTAIL_CONFFILES should be a list of user-editable files
#RSSTAIL_CONFFILES=/opt/etc/rsstail.conf /opt/etc/init.d/SXXrsstail

#
# RSSTAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RSSTAIL_PATCHES=$(RSSTAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RSSTAIL_CPPFLAGS=
RSSTAIL_LDFLAGS=-lmrss

#
# RSSTAIL_BUILD_DIR is the directory in which the build is done.
# RSSTAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RSSTAIL_IPK_DIR is the directory in which the ipk is built.
# RSSTAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RSSTAIL_BUILD_DIR=$(BUILD_DIR)/rsstail
RSSTAIL_SOURCE_DIR=$(SOURCE_DIR)/rsstail
RSSTAIL_IPK_DIR=$(BUILD_DIR)/rsstail-$(RSSTAIL_VERSION)-ipk
RSSTAIL_IPK=$(BUILD_DIR)/rsstail_$(RSSTAIL_VERSION)-$(RSSTAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rsstail-source rsstail-unpack rsstail rsstail-stage rsstail-ipk rsstail-clean rsstail-dirclean rsstail-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RSSTAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(RSSTAIL_SITE)/$(RSSTAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rsstail-source: $(DL_DIR)/$(RSSTAIL_SOURCE) $(RSSTAIL_PATCHES)

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
$(RSSTAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(RSSTAIL_SOURCE) $(RSSTAIL_PATCHES) make/rsstail.mk
	$(MAKE) libmrss-stage
	rm -rf $(BUILD_DIR)/$(RSSTAIL_DIR) $(RSSTAIL_BUILD_DIR)
	$(RSSTAIL_UNZIP) $(DL_DIR)/$(RSSTAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RSSTAIL_PATCHES)" ; \
		then cat $(RSSTAIL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RSSTAIL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RSSTAIL_DIR)" != "$(RSSTAIL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RSSTAIL_DIR) $(RSSTAIL_BUILD_DIR) ; \
	fi
#	(cd $(RSSTAIL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RSSTAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RSSTAIL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(RSSTAIL_BUILD_DIR)/libtool
	touch $@

rsstail-unpack: $(RSSTAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RSSTAIL_BUILD_DIR)/.built: $(RSSTAIL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(RSSTAIL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RSSTAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RSSTAIL_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
rsstail: $(RSSTAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RSSTAIL_BUILD_DIR)/.staged: $(RSSTAIL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(RSSTAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

rsstail-stage: $(RSSTAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rsstail
#
$(RSSTAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rsstail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RSSTAIL_PRIORITY)" >>$@
	@echo "Section: $(RSSTAIL_SECTION)" >>$@
	@echo "Version: $(RSSTAIL_VERSION)-$(RSSTAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RSSTAIL_MAINTAINER)" >>$@
	@echo "Source: $(RSSTAIL_SITE)/$(RSSTAIL_SOURCE)" >>$@
	@echo "Description: $(RSSTAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(RSSTAIL_DEPENDS)" >>$@
	@echo "Suggests: $(RSSTAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(RSSTAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RSSTAIL_IPK_DIR)/opt/sbin or $(RSSTAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RSSTAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RSSTAIL_IPK_DIR)/opt/etc/rsstail/...
# Documentation files should be installed in $(RSSTAIL_IPK_DIR)/opt/doc/rsstail/...
# Daemon startup scripts should be installed in $(RSSTAIL_IPK_DIR)/opt/etc/init.d/S??rsstail
#
# You may need to patch your application to make it use these locations.
#
$(RSSTAIL_IPK): $(RSSTAIL_BUILD_DIR)/.built
	rm -rf $(RSSTAIL_IPK_DIR) $(BUILD_DIR)/rsstail_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(RSSTAIL_BUILD_DIR) DESTDIR=$(RSSTAIL_IPK_DIR) install-strip
	install -d $(RSSTAIL_IPK_DIR)/opt/bin/
	install $(RSSTAIL_BUILD_DIR)/rsstail $(RSSTAIL_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(RSSTAIL_IPK_DIR)/opt/bin/rsstail
	$(MAKE) $(RSSTAIL_IPK_DIR)/CONTROL/control
#	echo $(RSSTAIL_CONFFILES) | sed -e 's/ /\n/g' > $(RSSTAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RSSTAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rsstail-ipk: $(RSSTAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rsstail-clean:
	rm -f $(RSSTAIL_BUILD_DIR)/.built
	-$(MAKE) -C $(RSSTAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rsstail-dirclean:
	rm -rf $(BUILD_DIR)/$(RSSTAIL_DIR) $(RSSTAIL_BUILD_DIR) $(RSSTAIL_IPK_DIR) $(RSSTAIL_IPK)
#
#
# Some sanity check for the package.
#
rsstail-check: $(RSSTAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RSSTAIL_IPK)
