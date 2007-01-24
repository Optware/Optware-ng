###########################################################
#
# mpc
#
###########################################################
#
# MPC_VERSION, MPC_SITE and MPC_SOURCE define
# the upstream location of the source code for the package.
# MPC_DIR is the directory which is created when the source
# archive is unpacked.
# MPC_UNZIP is the command used to unzip the source.
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
MPC_SITE=http://www.musicpd.org/uploads/files
MPC_VERSION=0.12.0
MPC_SOURCE=mpc-$(MPC_VERSION).tar.bz2
MPC_DIR=mpc-$(MPC_VERSION)
MPC_UNZIP=bzcat
MPC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPC_DESCRIPTION=A command line tool to interface MPD.
MPC_SECTION=audio
MPC_PRIORITY=optional
MPC_DEPENDS=
MPC_SUGGESTS=
MPC_CONFLICTS=

#
# MPC_IPK_VERSION should be incremented when the ipk changes.
#
MPC_IPK_VERSION=1

#
# MPC_CONFFILES should be a list of user-editable files
#MPC_CONFFILES=/opt/etc/mpc.conf /opt/etc/init.d/SXXmpc

#
# MPC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MPC_PATCHES=$(MPC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPC_CPPFLAGS=
MPC_LDFLAGS=
ifeq ($(OPTWARE_TARGET), wl500g)
MPC_CONFIG_ARGS=--disable-iconv
else
MPC_CONFIG_ARGS=
endif

#
# MPC_BUILD_DIR is the directory in which the build is done.
# MPC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPC_IPK_DIR is the directory in which the ipk is built.
# MPC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPC_BUILD_DIR=$(BUILD_DIR)/mpc
MPC_SOURCE_DIR=$(SOURCE_DIR)/mpc
MPC_IPK_DIR=$(BUILD_DIR)/mpc-$(MPC_VERSION)-ipk
MPC_IPK=$(BUILD_DIR)/mpc_$(MPC_VERSION)-$(MPC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpc-source mpc-unpack mpc mpc-stage mpc-ipk mpc-clean mpc-dirclean mpc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPC_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPC_SITE)/$(MPC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpc-source: $(DL_DIR)/$(MPC_SOURCE) $(MPC_PATCHES)

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
$(MPC_BUILD_DIR)/.configured: $(DL_DIR)/$(MPC_SOURCE) $(MPC_PATCHES) make/mpc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MPC_DIR) $(MPC_BUILD_DIR)
	$(MPC_UNZIP) $(DL_DIR)/$(MPC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPC_PATCHES)" ; \
		then cat $(MPC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPC_DIR)" != "$(MPC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MPC_DIR) $(MPC_BUILD_DIR) ; \
	fi
	(cd $(MPC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MPC_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MPC_BUILD_DIR)/libtool
	sed -ie 's| -I$${prefix}/include||g' $(MPC_BUILD_DIR)/src/Makefile
	touch $@

mpc-unpack: $(MPC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPC_BUILD_DIR)/.built: $(MPC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MPC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
mpc: $(MPC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPC_BUILD_DIR)/.staged: $(MPC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MPC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mpc-stage: $(MPC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpc
#
$(MPC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPC_PRIORITY)" >>$@
	@echo "Section: $(MPC_SECTION)" >>$@
	@echo "Version: $(MPC_VERSION)-$(MPC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPC_MAINTAINER)" >>$@
	@echo "Source: $(MPC_SITE)/$(MPC_SOURCE)" >>$@
	@echo "Description: $(MPC_DESCRIPTION)" >>$@
	@echo "Depends: $(MPC_DEPENDS)" >>$@
	@echo "Suggests: $(MPC_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPC_IPK_DIR)/opt/sbin or $(MPC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPC_IPK_DIR)/opt/etc/mpc/...
# Documentation files should be installed in $(MPC_IPK_DIR)/opt/doc/mpc/...
# Daemon startup scripts should be installed in $(MPC_IPK_DIR)/opt/etc/init.d/S??mpc
#
# You may need to patch your application to make it use these locations.
#
$(MPC_IPK): $(MPC_BUILD_DIR)/.built
	rm -rf $(MPC_IPK_DIR) $(BUILD_DIR)/mpc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPC_BUILD_DIR) DESTDIR=$(MPC_IPK_DIR) install-strip
#	install -d $(MPC_IPK_DIR)/opt/etc/
#	install -m 644 $(MPC_SOURCE_DIR)/mpc.conf $(MPC_IPK_DIR)/opt/etc/mpc.conf
#	install -d $(MPC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MPC_SOURCE_DIR)/rc.mpc $(MPC_IPK_DIR)/opt/etc/init.d/SXXmpc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXmpc
	$(MAKE) $(MPC_IPK_DIR)/CONTROL/control
	echo $(MPC_CONFFILES) | sed -e 's/ /\n/g' > $(MPC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpc-ipk: $(MPC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpc-clean:
	rm -f $(MPC_BUILD_DIR)/.built
	-$(MAKE) -C $(MPC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpc-dirclean:
	rm -rf $(BUILD_DIR)/$(MPC_DIR) $(MPC_BUILD_DIR) $(MPC_IPK_DIR) $(MPC_IPK)
#
#
# Some sanity check for the package.
#
mpc-check: $(MPC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPC_IPK)
