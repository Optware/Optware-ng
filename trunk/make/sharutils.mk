###########################################################
#
# sharutils
#
###########################################################
#
# SHARUTILS_VERSION, SHARUTILS_SITE and SHARUTILS_SOURCE define
# the upstream location of the source code for the package.
# SHARUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# SHARUTILS_UNZIP is the command used to unzip the source.
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
SHARUTILS_VERSION=4.6.3
SHARUTILS_SITE=ftp://ftp.gnu.org/gnu/sharutils/REL-$(SHARUTILS_VERSION)
SHARUTILS_SOURCE=sharutils-$(SHARUTILS_VERSION).tar.bz2
SHARUTILS_DIR=sharutils-$(SHARUTILS_VERSION)
SHARUTILS_UNZIP=bzcat
SHARUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SHARUTILS_DESCRIPTION=Create and unpack shell archives.
SHARUTILS_SECTION=utils
SHARUTILS_PRIORITY=optional
SHARUTILS_DEPENDS=
SHARUTILS_SUGGESTS=
SHARUTILS_CONFLICTS=

#
# SHARUTILS_IPK_VERSION should be incremented when the ipk changes.
#
SHARUTILS_IPK_VERSION=1

#
# SHARUTILS_CONFFILES should be a list of user-editable files
#SHARUTILS_CONFFILES=/opt/etc/sharutils.conf /opt/etc/init.d/SXXsharutils

#
# SHARUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SHARUTILS_PATCHES=$(SHARUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SHARUTILS_CPPFLAGS=
SHARUTILS_LDFLAGS=

#
# SHARUTILS_BUILD_DIR is the directory in which the build is done.
# SHARUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SHARUTILS_IPK_DIR is the directory in which the ipk is built.
# SHARUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SHARUTILS_BUILD_DIR=$(BUILD_DIR)/sharutils
SHARUTILS_SOURCE_DIR=$(SOURCE_DIR)/sharutils
SHARUTILS_IPK_DIR=$(BUILD_DIR)/sharutils-$(SHARUTILS_VERSION)-ipk
SHARUTILS_IPK=$(BUILD_DIR)/sharutils_$(SHARUTILS_VERSION)-$(SHARUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sharutils-source sharutils-unpack sharutils sharutils-stage sharutils-ipk sharutils-clean sharutils-dirclean sharutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SHARUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(SHARUTILS_SITE)/$(SHARUTILS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SHARUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sharutils-source: $(DL_DIR)/$(SHARUTILS_SOURCE) $(SHARUTILS_PATCHES)

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
$(SHARUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(SHARUTILS_SOURCE) $(SHARUTILS_PATCHES) make/sharutils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SHARUTILS_DIR) $(SHARUTILS_BUILD_DIR)
	$(SHARUTILS_UNZIP) $(DL_DIR)/$(SHARUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SHARUTILS_PATCHES)" ; \
		then cat $(SHARUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SHARUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SHARUTILS_DIR)" != "$(SHARUTILS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SHARUTILS_DIR) $(SHARUTILS_BUILD_DIR) ; \
	fi
	(cd $(SHARUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SHARUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SHARUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SHARUTILS_BUILD_DIR)/libtool
	touch $@

sharutils-unpack: $(SHARUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SHARUTILS_BUILD_DIR)/.built: $(SHARUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SHARUTILS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
sharutils: $(SHARUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SHARUTILS_BUILD_DIR)/.staged: $(SHARUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SHARUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

sharutils-stage: $(SHARUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sharutils
#
$(SHARUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sharutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SHARUTILS_PRIORITY)" >>$@
	@echo "Section: $(SHARUTILS_SECTION)" >>$@
	@echo "Version: $(SHARUTILS_VERSION)-$(SHARUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SHARUTILS_MAINTAINER)" >>$@
	@echo "Source: $(SHARUTILS_SITE)/$(SHARUTILS_SOURCE)" >>$@
	@echo "Description: $(SHARUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(SHARUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(SHARUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SHARUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SHARUTILS_IPK_DIR)/opt/sbin or $(SHARUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SHARUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SHARUTILS_IPK_DIR)/opt/etc/sharutils/...
# Documentation files should be installed in $(SHARUTILS_IPK_DIR)/opt/doc/sharutils/...
# Daemon startup scripts should be installed in $(SHARUTILS_IPK_DIR)/opt/etc/init.d/S??sharutils
#
# You may need to patch your application to make it use these locations.
#
$(SHARUTILS_IPK): $(SHARUTILS_BUILD_DIR)/.built
	rm -rf $(SHARUTILS_IPK_DIR) $(BUILD_DIR)/sharutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SHARUTILS_BUILD_DIR) DESTDIR=$(SHARUTILS_IPK_DIR) install-strip
#	install -d $(SHARUTILS_IPK_DIR)/opt/etc/
#	install -m 644 $(SHARUTILS_SOURCE_DIR)/sharutils.conf $(SHARUTILS_IPK_DIR)/opt/etc/sharutils.conf
#	install -d $(SHARUTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SHARUTILS_SOURCE_DIR)/rc.sharutils $(SHARUTILS_IPK_DIR)/opt/etc/init.d/SXXsharutils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHARUTILS_IPK_DIR)/opt/etc/init.d/SXXsharutils
	$(MAKE) $(SHARUTILS_IPK_DIR)/CONTROL/control
#	install -m 755 $(SHARUTILS_SOURCE_DIR)/postinst $(SHARUTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHARUTILS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SHARUTILS_SOURCE_DIR)/prerm $(SHARUTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHARUTILS_IPK_DIR)/CONTROL/prerm
	echo $(SHARUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(SHARUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SHARUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sharutils-ipk: $(SHARUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sharutils-clean:
	rm -f $(SHARUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(SHARUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sharutils-dirclean:
	rm -rf $(BUILD_DIR)/$(SHARUTILS_DIR) $(SHARUTILS_BUILD_DIR) $(SHARUTILS_IPK_DIR) $(SHARUTILS_IPK)
#
#
# Some sanity check for the package.
#
sharutils-check: $(SHARUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SHARUTILS_IPK)
