###########################################################
#
# spindown
#
###########################################################
#
# SPINDOWN_VERSION, SPINDOWN_SITE and SPINDOWN_SOURCE define
# the upstream location of the source code for the package.
# SPINDOWN_DIR is the directory which is created when the source
# archive is unpacked.
# SPINDOWN_UNZIP is the command used to unzip the source.
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
SPINDOWN_SITE=http://vladimir.grouzdev.free.fr/public/spindown/src
SPINDOWN_VERSION=1.0
SPINDOWN_SOURCE=spindown-$(SPINDOWN_VERSION).tar.gz
SPINDOWN_DIR=spindown-$(SPINDOWN_VERSION)
SPINDOWN_UNZIP=zcat
SPINDOWN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPINDOWN_DESCRIPTION=The spindown program stops spinning a SCSI disk if it is idle for a while.
SPINDOWN_SECTION=utils
SPINDOWN_PRIORITY=optional
SPINDOWN_DEPENDS=
SPINDOWN_SUGGESTS=
SPINDOWN_CONFLICTS=

#
# SPINDOWN_IPK_VERSION should be incremented when the ipk changes.
#
SPINDOWN_IPK_VERSION=1

#
# SPINDOWN_CONFFILES should be a list of user-editable files
#SPINDOWN_CONFFILES=/opt/etc/spindown.conf /opt/etc/init.d/SXXspindown

#
# SPINDOWN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPINDOWN_PATCHES=$(SPINDOWN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPINDOWN_CPPFLAGS=
SPINDOWN_LDFLAGS=

#
# SPINDOWN_BUILD_DIR is the directory in which the build is done.
# SPINDOWN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPINDOWN_IPK_DIR is the directory in which the ipk is built.
# SPINDOWN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPINDOWN_BUILD_DIR=$(BUILD_DIR)/spindown
SPINDOWN_SOURCE_DIR=$(SOURCE_DIR)/spindown
SPINDOWN_IPK_DIR=$(BUILD_DIR)/spindown-$(SPINDOWN_VERSION)-ipk
SPINDOWN_IPK=$(BUILD_DIR)/spindown_$(SPINDOWN_VERSION)-$(SPINDOWN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: spindown-source spindown-unpack spindown spindown-stage spindown-ipk spindown-clean spindown-dirclean spindown-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPINDOWN_SOURCE):
	$(WGET) -P $(DL_DIR) $(SPINDOWN_SITE)/$(SPINDOWN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SPINDOWN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
spindown-source: $(DL_DIR)/$(SPINDOWN_SOURCE) $(SPINDOWN_PATCHES)

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
$(SPINDOWN_BUILD_DIR)/.configured: $(DL_DIR)/$(SPINDOWN_SOURCE) $(SPINDOWN_PATCHES) make/spindown.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SPINDOWN_DIR) $(SPINDOWN_BUILD_DIR)
	$(SPINDOWN_UNZIP) $(DL_DIR)/$(SPINDOWN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPINDOWN_PATCHES)" ; \
		then cat $(SPINDOWN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPINDOWN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SPINDOWN_DIR)" != "$(SPINDOWN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SPINDOWN_DIR) $(SPINDOWN_BUILD_DIR) ; \
	fi
	(cd $(SPINDOWN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPINDOWN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPINDOWN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SPINDOWN_BUILD_DIR)/libtool
	touch $@

spindown-unpack: $(SPINDOWN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPINDOWN_BUILD_DIR)/.built: $(SPINDOWN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SPINDOWN_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
spindown: $(SPINDOWN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPINDOWN_BUILD_DIR)/.staged: $(SPINDOWN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SPINDOWN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

spindown-stage: $(SPINDOWN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/spindown
#
$(SPINDOWN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: spindown" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPINDOWN_PRIORITY)" >>$@
	@echo "Section: $(SPINDOWN_SECTION)" >>$@
	@echo "Version: $(SPINDOWN_VERSION)-$(SPINDOWN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPINDOWN_MAINTAINER)" >>$@
	@echo "Source: $(SPINDOWN_SITE)/$(SPINDOWN_SOURCE)" >>$@
	@echo "Description: $(SPINDOWN_DESCRIPTION)" >>$@
	@echo "Depends: $(SPINDOWN_DEPENDS)" >>$@
	@echo "Suggests: $(SPINDOWN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPINDOWN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPINDOWN_IPK_DIR)/opt/sbin or $(SPINDOWN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPINDOWN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPINDOWN_IPK_DIR)/opt/etc/spindown/...
# Documentation files should be installed in $(SPINDOWN_IPK_DIR)/opt/doc/spindown/...
# Daemon startup scripts should be installed in $(SPINDOWN_IPK_DIR)/opt/etc/init.d/S??spindown
#
# You may need to patch your application to make it use these locations.
#
$(SPINDOWN_IPK): $(SPINDOWN_BUILD_DIR)/.built
	rm -rf $(SPINDOWN_IPK_DIR) $(BUILD_DIR)/spindown_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPINDOWN_BUILD_DIR) DESTDIR=$(SPINDOWN_IPK_DIR) install-strip
	install -d $(SPINDOWN_IPK_DIR)/opt/share/doc/spindown
	install $(SPINDOWN_BUILD_DIR)/README $(SPINDOWN_IPK_DIR)/opt/share/doc/spindown/
#	install -d $(SPINDOWN_IPK_DIR)/opt/etc/
#	install -m 644 $(SPINDOWN_SOURCE_DIR)/spindown.conf $(SPINDOWN_IPK_DIR)/opt/etc/spindown.conf
#	install -d $(SPINDOWN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SPINDOWN_SOURCE_DIR)/rc.spindown $(SPINDOWN_IPK_DIR)/opt/etc/init.d/SXXspindown
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPINDOWN_IPK_DIR)/opt/etc/init.d/SXXspindown
	$(MAKE) $(SPINDOWN_IPK_DIR)/CONTROL/control
#	install -m 755 $(SPINDOWN_SOURCE_DIR)/postinst $(SPINDOWN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPINDOWN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SPINDOWN_SOURCE_DIR)/prerm $(SPINDOWN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPINDOWN_IPK_DIR)/CONTROL/prerm
	echo $(SPINDOWN_CONFFILES) | sed -e 's/ /\n/g' > $(SPINDOWN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPINDOWN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
spindown-ipk: $(SPINDOWN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
spindown-clean:
	rm -f $(SPINDOWN_BUILD_DIR)/.built
	-$(MAKE) -C $(SPINDOWN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
spindown-dirclean:
	rm -rf $(BUILD_DIR)/$(SPINDOWN_DIR) $(SPINDOWN_BUILD_DIR) $(SPINDOWN_IPK_DIR) $(SPINDOWN_IPK)
#
#
# Some sanity check for the package.
#
spindown-check: $(SPINDOWN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SPINDOWN_IPK)
