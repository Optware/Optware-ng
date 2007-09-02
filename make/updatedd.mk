###########################################################
#
# updatedd
#
###########################################################
#
# UPDATEDD_VERSION, UPDATEDD_SITE and UPDATEDD_SOURCE define
# the upstream location of the source code for the package.
# UPDATEDD_DIR is the directory which is created when the source
# archive is unpacked.
# UPDATEDD_UNZIP is the command used to unzip the source.
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
UPDATEDD_SITE=http://download.savannah.gnu.org/releases/updatedd
UPDATEDD_VERSION=2.6
UPDATEDD_SOURCE=updatedd_$(UPDATEDD_VERSION).tar.gz
UPDATEDD_DIR=updatedd-$(UPDATEDD_VERSION)
UPDATEDD_UNZIP=zcat
UPDATEDD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UPDATEDD_DESCRIPTION=Updatedd is a Dynamic DNS client with plugins for several dynamic dns services.
UPDATEDD_SECTION=net
UPDATEDD_PRIORITY=optional
UPDATEDD_DEPENDS=
UPDATEDD_SUGGESTS=
UPDATEDD_CONFLICTS=

#
# UPDATEDD_IPK_VERSION should be incremented when the ipk changes.
#
UPDATEDD_IPK_VERSION=1

#
# UPDATEDD_CONFFILES should be a list of user-editable files
#UPDATEDD_CONFFILES=/opt/etc/updatedd.conf /opt/etc/init.d/SXXupdatedd

#
# UPDATEDD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UPDATEDD_PATCHES=$(UPDATEDD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UPDATEDD_CPPFLAGS=
UPDATEDD_LDFLAGS=

#
# UPDATEDD_BUILD_DIR is the directory in which the build is done.
# UPDATEDD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UPDATEDD_IPK_DIR is the directory in which the ipk is built.
# UPDATEDD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UPDATEDD_BUILD_DIR=$(BUILD_DIR)/updatedd
UPDATEDD_SOURCE_DIR=$(SOURCE_DIR)/updatedd
UPDATEDD_IPK_DIR=$(BUILD_DIR)/updatedd-$(UPDATEDD_VERSION)-ipk
UPDATEDD_IPK=$(BUILD_DIR)/updatedd_$(UPDATEDD_VERSION)-$(UPDATEDD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: updatedd-source updatedd-unpack updatedd updatedd-stage updatedd-ipk updatedd-clean updatedd-dirclean updatedd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UPDATEDD_SOURCE):
	$(WGET) -P $(DL_DIR) $(UPDATEDD_SITE)/$(UPDATEDD_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UPDATEDD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
updatedd-source: $(DL_DIR)/$(UPDATEDD_SOURCE) $(UPDATEDD_PATCHES)

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
$(UPDATEDD_BUILD_DIR)/.configured: $(DL_DIR)/$(UPDATEDD_SOURCE) $(UPDATEDD_PATCHES) make/updatedd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UPDATEDD_DIR) $(UPDATEDD_BUILD_DIR)
	$(UPDATEDD_UNZIP) $(DL_DIR)/$(UPDATEDD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UPDATEDD_PATCHES)" ; \
		then cat $(UPDATEDD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UPDATEDD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UPDATEDD_DIR)" != "$(UPDATEDD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UPDATEDD_DIR) $(UPDATEDD_BUILD_DIR) ; \
	fi
	(cd $(UPDATEDD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UPDATEDD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UPDATEDD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(UPDATEDD_BUILD_DIR)/libtool
	touch $@

updatedd-unpack: $(UPDATEDD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UPDATEDD_BUILD_DIR)/.built: $(UPDATEDD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UPDATEDD_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
updatedd: $(UPDATEDD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UPDATEDD_BUILD_DIR)/.staged: $(UPDATEDD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(UPDATEDD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

updatedd-stage: $(UPDATEDD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/updatedd
#
$(UPDATEDD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: updatedd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UPDATEDD_PRIORITY)" >>$@
	@echo "Section: $(UPDATEDD_SECTION)" >>$@
	@echo "Version: $(UPDATEDD_VERSION)-$(UPDATEDD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UPDATEDD_MAINTAINER)" >>$@
	@echo "Source: $(UPDATEDD_SITE)/$(UPDATEDD_SOURCE)" >>$@
	@echo "Description: $(UPDATEDD_DESCRIPTION)" >>$@
	@echo "Depends: $(UPDATEDD_DEPENDS)" >>$@
	@echo "Suggests: $(UPDATEDD_SUGGESTS)" >>$@
	@echo "Conflicts: $(UPDATEDD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UPDATEDD_IPK_DIR)/opt/sbin or $(UPDATEDD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UPDATEDD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UPDATEDD_IPK_DIR)/opt/etc/updatedd/...
# Documentation files should be installed in $(UPDATEDD_IPK_DIR)/opt/doc/updatedd/...
# Daemon startup scripts should be installed in $(UPDATEDD_IPK_DIR)/opt/etc/init.d/S??updatedd
#
# You may need to patch your application to make it use these locations.
#
$(UPDATEDD_IPK): $(UPDATEDD_BUILD_DIR)/.built
	rm -rf $(UPDATEDD_IPK_DIR) $(BUILD_DIR)/updatedd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UPDATEDD_BUILD_DIR) DESTDIR=$(UPDATEDD_IPK_DIR) transform='' install-strip
	$(MAKE) $(UPDATEDD_IPK_DIR)/CONTROL/control
	echo $(UPDATEDD_CONFFILES) | sed -e 's/ /\n/g' > $(UPDATEDD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UPDATEDD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
updatedd-ipk: $(UPDATEDD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
updatedd-clean:
	rm -f $(UPDATEDD_BUILD_DIR)/.built
	-$(MAKE) -C $(UPDATEDD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
updatedd-dirclean:
	rm -rf $(BUILD_DIR)/$(UPDATEDD_DIR) $(UPDATEDD_BUILD_DIR) $(UPDATEDD_IPK_DIR) $(UPDATEDD_IPK)
#
#
# Some sanity check for the package.
#
updatedd-check: $(UPDATEDD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UPDATEDD_IPK)
