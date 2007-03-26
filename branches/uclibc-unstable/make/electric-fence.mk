###########################################################
#
# electric-fence
#
###########################################################
#
# ELECTRIC_FENCE_VERSION, ELECTRIC_FENCE_SITE and ELECTRIC_FENCE_SOURCE define
# the upstream location of the source code for the package.
# ELECTRIC_FENCE_DIR is the directory which is created when the source
# archive is unpacked.
# ELECTRIC_FENCE_UNZIP is the command used to unzip the source.
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
# ELECTRIC_FENCE_SITE=http://perens.com/FreeSoftware/ElectricFence
ELECTRIC_FENCE_SITE=http://ftp.debian.org/debian/pool/main/e/electric-fence
ELECTRIC_FENCE_VERSION=2.1.14.1
ELECTRIC_FENCE_SOURCE=electric-fence_$(ELECTRIC_FENCE_VERSION).tar.gz
ELECTRIC_FENCE_DIR=electric-fence-$(ELECTRIC_FENCE_VERSION)
ELECTRIC_FENCE_UNZIP=zcat
ELECTRIC_FENCE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ELECTRIC_FENCE_DESCRIPTION=C memory debugging library
ELECTRIC_FENCE_SECTION=lib
ELECTRIC_FENCE_PRIORITY=optional
ELECTRIC_FENCE_DEPENDS=
ELECTRIC_FENCE_SUGGESTS=
ELECTRIC_FENCE_CONFLICTS=

#
# ELECTRIC_FENCE_IPK_VERSION should be incremented when the ipk changes.
#
ELECTRIC_FENCE_IPK_VERSION=1

#
# ELECTRIC_FENCE_CONFFILES should be a list of user-editable files
# ELECTRIC_FENCE_CONFFILES=/opt/etc/electric-fence.conf /opt/etc/init.d/SXXelectric-fence

#
# ELECTRIC_FENCE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# ELECTRIC_FENCE_PATCHES=$(ELECTRIC_FENCE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ELECTRIC_FENCE_CPPFLAGS=-g
ELECTRIC_FENCE_LDFLAGS=

#
# ELECTRIC_FENCE_BUILD_DIR is the directory in which the build is done.
# ELECTRIC_FENCE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ELECTRIC_FENCE_IPK_DIR is the directory in which the ipk is built.
# ELECTRIC_FENCE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ELECTRIC_FENCE_BUILD_DIR=$(BUILD_DIR)/electric-fence
ELECTRIC_FENCE_SOURCE_DIR=$(SOURCE_DIR)/electric-fence
ELECTRIC_FENCE_IPK_DIR=$(BUILD_DIR)/electric-fence-$(ELECTRIC_FENCE_VERSION)-ipk
ELECTRIC_FENCE_IPK=$(BUILD_DIR)/electric-fence_$(ELECTRIC_FENCE_VERSION)-$(ELECTRIC_FENCE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: electric-fence-source electric-fence-unpack electric-fence electric-fence-stage electric-fence-ipk electric-fence-clean electric-fence-dirclean electric-fence-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ELECTRIC_FENCE_SOURCE):
	$(WGET) -P $(DL_DIR) $(ELECTRIC_FENCE_SITE)/$(ELECTRIC_FENCE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
electric-fence-source: $(DL_DIR)/$(ELECTRIC_FENCE_SOURCE) $(ELECTRIC_FENCE_PATCHES)

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
$(ELECTRIC_FENCE_BUILD_DIR)/.configured: $(DL_DIR)/$(ELECTRIC_FENCE_SOURCE) $(ELECTRIC_FENCE_PATCHES) make/electric-fence.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ELECTRIC_FENCE_DIR) $(ELECTRIC_FENCE_BUILD_DIR)
	$(ELECTRIC_FENCE_UNZIP) $(DL_DIR)/$(ELECTRIC_FENCE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ELECTRIC_FENCE_PATCHES)" ; \
		then cat $(ELECTRIC_FENCE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ELECTRIC_FENCE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ELECTRIC_FENCE_DIR)" != "$(ELECTRIC_FENCE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ELECTRIC_FENCE_DIR) $(ELECTRIC_FENCE_BUILD_DIR) ; \
	fi
	(cd $(ELECTRIC_FENCE_BUILD_DIR); \
		sed -i -e '/^CC/d;/^AR/d;/^CFLAGS/d' \
		-e '/^LIB_INSTALL_DIR/d;/^MAN_INSTALL_DIR/d' Makefile \
	)
	touch $(ELECTRIC_FENCE_BUILD_DIR)/.configured

electric-fence-unpack: $(ELECTRIC_FENCE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ELECTRIC_FENCE_BUILD_DIR)/.built: $(ELECTRIC_FENCE_BUILD_DIR)/.configured
	rm -f $(ELECTRIC_FENCE_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(ELECTRIC_FENCE_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(ELECTRIC_FENCE_LDFLAGS)" \
	$(MAKE) -C $(ELECTRIC_FENCE_BUILD_DIR) libefence.a tstheap eftest
	touch $(ELECTRIC_FENCE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
electric-fence: $(ELECTRIC_FENCE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ELECTRIC_FENCE_BUILD_DIR)/.staged: $(ELECTRIC_FENCE_BUILD_DIR)/.built
	rm -f $(ELECTRIC_FENCE_BUILD_DIR)/.staged
	install -d $(STAGING_PREFIX)/lib
	install -d $(STAGING_PREFIX)/man/man3
	install -m 644 $(ELECTRIC_FENCE_BUILD_DIR)/libefence.a  $(STAGING_PREFIX)/lib
	install -m 644 $(ELECTRIC_FENCE_BUILD_DIR)/libefence.3  $(STAGING_PREFIX)/man/man3

	touch $(ELECTRIC_FENCE_BUILD_DIR)/.staged

electric-fence-stage: $(ELECTRIC_FENCE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/electric-fence
#
$(ELECTRIC_FENCE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: electric-fence" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELECTRIC_FENCE_PRIORITY)" >>$@
	@echo "Section: $(ELECTRIC_FENCE_SECTION)" >>$@
	@echo "Version: $(ELECTRIC_FENCE_VERSION)-$(ELECTRIC_FENCE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELECTRIC_FENCE_MAINTAINER)" >>$@
	@echo "Source: $(ELECTRIC_FENCE_SITE)/$(ELECTRIC_FENCE_SOURCE)" >>$@
	@echo "Description: $(ELECTRIC_FENCE_DESCRIPTION)" >>$@
	@echo "Depends: $(ELECTRIC_FENCE_DEPENDS)" >>$@
	@echo "Suggests: $(ELECTRIC_FENCE_SUGGESTS)" >>$@
	@echo "Conflicts: $(ELECTRIC_FENCE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ELECTRIC_FENCE_IPK_DIR)/opt/sbin or $(ELECTRIC_FENCE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ELECTRIC_FENCE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ELECTRIC_FENCE_IPK_DIR)/opt/etc/electric-fence/...
# Documentation files should be installed in $(ELECTRIC_FENCE_IPK_DIR)/opt/doc/electric-fence/...
# Daemon startup scripts should be installed in $(ELECTRIC_FENCE_IPK_DIR)/opt/etc/init.d/S??electric-fence
#
# You may need to patch your application to make it use these locations.
#
$(ELECTRIC_FENCE_IPK): $(ELECTRIC_FENCE_BUILD_DIR)/.built
	rm -rf $(ELECTRIC_FENCE_IPK_DIR) $(BUILD_DIR)/electric-fence_*_$(TARGET_ARCH).ipk
	install -d $(ELECTRIC_FENCE_IPK_DIR)/opt/bin
	install -m 755 $(ELECTRIC_FENCE_BUILD_DIR)/eftest $(ELECTRIC_FENCE_IPK_DIR)/opt/bin
	install -m 755 $(ELECTRIC_FENCE_BUILD_DIR)/tstheap $(ELECTRIC_FENCE_IPK_DIR)/opt/bin
	install -d $(ELECTRIC_FENCE_IPK_DIR)/opt/lib
	install -m 644 $(ELECTRIC_FENCE_BUILD_DIR)/libefence.a  $(ELECTRIC_FENCE_IPK_DIR)/opt/lib/
	install -d $(ELECTRIC_FENCE_IPK_DIR)/opt/man/man3
	install -m 644 $(ELECTRIC_FENCE_BUILD_DIR)/libefence.3 $(ELECTRIC_FENCE_IPK_DIR)/opt/man/man3
	$(MAKE) $(ELECTRIC_FENCE_IPK_DIR)/CONTROL/control
	install -m 755 $(ELECTRIC_FENCE_SOURCE_DIR)/postinst $(ELECTRIC_FENCE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ELECTRIC_FENCE_SOURCE_DIR)/prerm $(ELECTRIC_FENCE_IPK_DIR)/CONTROL/prerm
#	echo $(ELECTRIC_FENCE_CONFFILES) | sed -e 's/ /\n/g' > $(ELECTRIC_FENCE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELECTRIC_FENCE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
electric-fence-ipk: $(ELECTRIC_FENCE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
electric-fence-clean:
	rm -f $(ELECTRIC_FENCE_BUILD_DIR)/.built
	-$(MAKE) -C $(ELECTRIC_FENCE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
electric-fence-dirclean:
	rm -rf $(BUILD_DIR)/$(ELECTRIC_FENCE_DIR) $(ELECTRIC_FENCE_BUILD_DIR) $(ELECTRIC_FENCE_IPK_DIR) $(ELECTRIC_FENCE_IPK)
#
#
# Some sanity check for the package.
#
electric-fence-check: $(ELECTRIC_FENCE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ELECTRIC_FENCE_IPK)
