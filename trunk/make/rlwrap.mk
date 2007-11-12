###########################################################
#
# rlwrap
#
###########################################################
#
# RLWRAP_VERSION, RLWRAP_SITE and RLWRAP_SOURCE define
# the upstream location of the source code for the package.
# RLWRAP_DIR is the directory which is created when the source
# archive is unpacked.
# RLWRAP_UNZIP is the command used to unzip the source.
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
RLWRAP_SITE=http://utopia.knoware.nl/~hlub/uck/rlwrap
RLWRAP_VERSION=0.29
RLWRAP_SOURCE=rlwrap-$(RLWRAP_VERSION).tar.gz
RLWRAP_DIR=rlwrap-$(RLWRAP_VERSION)
RLWRAP_UNZIP=zcat
RLWRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RLWRAP_DESCRIPTION=A 'readline wrapper'.
RLWRAP_SECTION=misc
RLWRAP_PRIORITY=optional
RLWRAP_DEPENDS=ncurses, readline
RLWRAP_SUGGESTS=
RLWRAP_CONFLICTS=

#
# RLWRAP_IPK_VERSION should be incremented when the ipk changes.
#
RLWRAP_IPK_VERSION=1

#
# RLWRAP_CONFFILES should be a list of user-editable files
#RLWRAP_CONFFILES=/opt/etc/rlwrap.conf /opt/etc/init.d/SXXrlwrap

#
# RLWRAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
RLWRAP_PATCHES=$(RLWRAP_SOURCE_DIR)/configure.ac.patch
else
RLWRAP_PATCHES=
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RLWRAP_CPPFLAGS=
RLWRAP_LDFLAGS=

#
# RLWRAP_BUILD_DIR is the directory in which the build is done.
# RLWRAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RLWRAP_IPK_DIR is the directory in which the ipk is built.
# RLWRAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RLWRAP_BUILD_DIR=$(BUILD_DIR)/rlwrap
RLWRAP_SOURCE_DIR=$(SOURCE_DIR)/rlwrap
RLWRAP_IPK_DIR=$(BUILD_DIR)/rlwrap-$(RLWRAP_VERSION)-ipk
RLWRAP_IPK=$(BUILD_DIR)/rlwrap_$(RLWRAP_VERSION)-$(RLWRAP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rlwrap-source rlwrap-unpack rlwrap rlwrap-stage rlwrap-ipk rlwrap-clean rlwrap-dirclean rlwrap-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RLWRAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(RLWRAP_SITE)/$(RLWRAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rlwrap-source: $(DL_DIR)/$(RLWRAP_SOURCE) $(RLWRAP_PATCHES)

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
$(RLWRAP_BUILD_DIR)/.configured: $(DL_DIR)/$(RLWRAP_SOURCE) $(RLWRAP_PATCHES) make/rlwrap.mk
	$(MAKE) ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(RLWRAP_DIR) $(RLWRAP_BUILD_DIR)
	$(RLWRAP_UNZIP) $(DL_DIR)/$(RLWRAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RLWRAP_PATCHES)" ; \
		then cat $(RLWRAP_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(RLWRAP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RLWRAP_DIR)" != "$(RLWRAP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RLWRAP_DIR) $(RLWRAP_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	cd $(RLWRAP_BUILD_DIR); autoconf
endif
	(cd $(RLWRAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RLWRAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RLWRAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(RLWRAP_BUILD_DIR)/libtool
	touch $@

rlwrap-unpack: $(RLWRAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RLWRAP_BUILD_DIR)/.built: $(RLWRAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(RLWRAP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
rlwrap: $(RLWRAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RLWRAP_BUILD_DIR)/.staged: $(RLWRAP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(RLWRAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

rlwrap-stage: $(RLWRAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rlwrap
#
$(RLWRAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rlwrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RLWRAP_PRIORITY)" >>$@
	@echo "Section: $(RLWRAP_SECTION)" >>$@
	@echo "Version: $(RLWRAP_VERSION)-$(RLWRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RLWRAP_MAINTAINER)" >>$@
	@echo "Source: $(RLWRAP_SITE)/$(RLWRAP_SOURCE)" >>$@
	@echo "Description: $(RLWRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(RLWRAP_DEPENDS)" >>$@
	@echo "Suggests: $(RLWRAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(RLWRAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RLWRAP_IPK_DIR)/opt/sbin or $(RLWRAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RLWRAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RLWRAP_IPK_DIR)/opt/etc/rlwrap/...
# Documentation files should be installed in $(RLWRAP_IPK_DIR)/opt/doc/rlwrap/...
# Daemon startup scripts should be installed in $(RLWRAP_IPK_DIR)/opt/etc/init.d/S??rlwrap
#
# You may need to patch your application to make it use these locations.
#
$(RLWRAP_IPK): $(RLWRAP_BUILD_DIR)/.built
	rm -rf $(RLWRAP_IPK_DIR) $(BUILD_DIR)/rlwrap_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RLWRAP_BUILD_DIR) DESTDIR=$(RLWRAP_IPK_DIR) install
	$(STRIP_COMMAND) $(RLWRAP_IPK_DIR)/opt/bin/rlwrap
	$(MAKE) $(RLWRAP_IPK_DIR)/CONTROL/control
	echo $(RLWRAP_CONFFILES) | sed -e 's/ /\n/g' > $(RLWRAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RLWRAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rlwrap-ipk: $(RLWRAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rlwrap-clean:
	rm -f $(RLWRAP_BUILD_DIR)/.built
	-$(MAKE) -C $(RLWRAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rlwrap-dirclean:
	rm -rf $(BUILD_DIR)/$(RLWRAP_DIR) $(RLWRAP_BUILD_DIR) $(RLWRAP_IPK_DIR) $(RLWRAP_IPK)
#
#
# Some sanity check for the package.
#
rlwrap-check: $(RLWRAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RLWRAP_IPK)
