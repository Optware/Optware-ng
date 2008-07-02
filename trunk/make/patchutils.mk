###########################################################
#
# patchutils
#
###########################################################
#
# PATCHUTILS_VERSION, PATCHUTILS_SITE and PATCHUTILS_SOURCE define
# the upstream location of the source code for the package.
# PATCHUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PATCHUTILS_UNZIP is the command used to unzip the source.
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
PATCHUTILS_SITE=http://cyberelk.net/tim/data/patchutils/stable
PATCHUTILS_VERSION=0.3.0
PATCHUTILS_SOURCE=patchutils-$(PATCHUTILS_VERSION).tar.bz2
PATCHUTILS_DIR=patchutils-$(PATCHUTILS_VERSION)
PATCHUTILS_UNZIP=bzcat
PATCHUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PATCHUTILS_DESCRIPTION=Patchutils is a small collection of programs that operate on patch files.
PATCHUTILS_SECTION=utils
PATCHUTILS_PRIORITY=optional
PATCHUTILS_DEPENDS=bash, patch, perl
PATCHUTILS_SUGGESTS=
PATCHUTILS_CONFLICTS=

#
# PATCHUTILS_IPK_VERSION should be incremented when the ipk changes.
#
PATCHUTILS_IPK_VERSION=1

#
# PATCHUTILS_CONFFILES should be a list of user-editable files
#PATCHUTILS_CONFFILES=/opt/etc/patchutils.conf /opt/etc/init.d/SXXpatchutils

#
# PATCHUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PATCHUTILS_PATCHES=$(PATCHUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PATCHUTILS_CPPFLAGS=
PATCHUTILS_LDFLAGS=

#
# PATCHUTILS_BUILD_DIR is the directory in which the build is done.
# PATCHUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PATCHUTILS_IPK_DIR is the directory in which the ipk is built.
# PATCHUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PATCHUTILS_BUILD_DIR=$(BUILD_DIR)/patchutils
PATCHUTILS_SOURCE_DIR=$(SOURCE_DIR)/patchutils
PATCHUTILS_IPK_DIR=$(BUILD_DIR)/patchutils-$(PATCHUTILS_VERSION)-ipk
PATCHUTILS_IPK=$(BUILD_DIR)/patchutils_$(PATCHUTILS_VERSION)-$(PATCHUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: patchutils-source patchutils-unpack patchutils patchutils-stage patchutils-ipk patchutils-clean patchutils-dirclean patchutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PATCHUTILS_SOURCE):
	$(WGET) -P $(@D) $(PATCHUTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
patchutils-source: $(DL_DIR)/$(PATCHUTILS_SOURCE) $(PATCHUTILS_PATCHES)

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
$(PATCHUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PATCHUTILS_SOURCE) $(PATCHUTILS_PATCHES) make/patchutils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PATCHUTILS_DIR) $(@D)
	$(PATCHUTILS_UNZIP) $(DL_DIR)/$(PATCHUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PATCHUTILS_PATCHES)" ; \
		then cat $(PATCHUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PATCHUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PATCHUTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PATCHUTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PATCHUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PATCHUTILS_LDFLAGS)" \
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

patchutils-unpack: $(PATCHUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PATCHUTILS_BUILD_DIR)/.built: $(PATCHUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
patchutils: $(PATCHUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PATCHUTILS_BUILD_DIR)/.staged: $(PATCHUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

patchutils-stage: $(PATCHUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/patchutils
#
$(PATCHUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: patchutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PATCHUTILS_PRIORITY)" >>$@
	@echo "Section: $(PATCHUTILS_SECTION)" >>$@
	@echo "Version: $(PATCHUTILS_VERSION)-$(PATCHUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PATCHUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PATCHUTILS_SITE)/$(PATCHUTILS_SOURCE)" >>$@
	@echo "Description: $(PATCHUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PATCHUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(PATCHUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PATCHUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PATCHUTILS_IPK_DIR)/opt/sbin or $(PATCHUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PATCHUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PATCHUTILS_IPK_DIR)/opt/etc/patchutils/...
# Documentation files should be installed in $(PATCHUTILS_IPK_DIR)/opt/doc/patchutils/...
# Daemon startup scripts should be installed in $(PATCHUTILS_IPK_DIR)/opt/etc/init.d/S??patchutils
#
# You may need to patch your application to make it use these locations.
#
$(PATCHUTILS_IPK): $(PATCHUTILS_BUILD_DIR)/.built
	rm -rf $(PATCHUTILS_IPK_DIR) $(BUILD_DIR)/patchutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PATCHUTILS_BUILD_DIR) DESTDIR=$(PATCHUTILS_IPK_DIR) install-strip
#	install -d $(PATCHUTILS_IPK_DIR)/opt/etc/
#	install -m 644 $(PATCHUTILS_SOURCE_DIR)/patchutils.conf $(PATCHUTILS_IPK_DIR)/opt/etc/patchutils.conf
#	install -d $(PATCHUTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PATCHUTILS_SOURCE_DIR)/rc.patchutils $(PATCHUTILS_IPK_DIR)/opt/etc/init.d/SXXpatchutils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PATCHUTILS_IPK_DIR)/opt/etc/init.d/SXXpatchutils
	$(MAKE) $(PATCHUTILS_IPK_DIR)/CONTROL/control
#	install -m 755 $(PATCHUTILS_SOURCE_DIR)/postinst $(PATCHUTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PATCHUTILS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PATCHUTILS_SOURCE_DIR)/prerm $(PATCHUTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PATCHUTILS_IPK_DIR)/CONTROL/prerm
	echo $(PATCHUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PATCHUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PATCHUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
patchutils-ipk: $(PATCHUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
patchutils-clean:
	rm -f $(PATCHUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(PATCHUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
patchutils-dirclean:
	rm -rf $(BUILD_DIR)/$(PATCHUTILS_DIR) $(PATCHUTILS_BUILD_DIR) $(PATCHUTILS_IPK_DIR) $(PATCHUTILS_IPK)
#
#
# Some sanity check for the package.
#
patchutils-check: $(PATCHUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PATCHUTILS_IPK)
