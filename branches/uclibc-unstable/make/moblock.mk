###########################################################
#
# moblock
#
###########################################################
#
# MOBLOCK_VERSION, MOBLOCK_SITE and MOBLOCK_SOURCE define
# the upstream location of the source code for the package.
# MOBLOCK_DIR is the directory which is created when the source
# archive is unpacked.
# MOBLOCK_UNZIP is the command used to unzip the source.
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
MOBLOCK_SITE=http://download.berlios.de/moblock
MOBLOCK_VERSION=0.8
MOBLOCK_SOURCE=MoBlock-$(MOBLOCK_VERSION)-i586.tar.bz2
MOBLOCK_DIR=MoBlock-$(MOBLOCK_VERSION)
MOBLOCK_UNZIP=bzcat
MOBLOCK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOBLOCK_DESCRIPTION=Blocks connections from/to hosts listed in a file in peerguardian format.
MOBLOCK_SECTION=kernel
MOBLOCK_PRIORITY=optional
MOBLOCK_DEPENDS=libnetfilter-queue
MOBLOCK_SUGGESTS=
MOBLOCK_CONFLICTS=

#
# MOBLOCK_IPK_VERSION should be incremented when the ipk changes.
#
MOBLOCK_IPK_VERSION=1

#
# MOBLOCK_CONFFILES should be a list of user-editable files
#MOBLOCK_CONFFILES=/opt/etc/moblock.conf /opt/etc/init.d/SXXmoblock

#
# MOBLOCK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOBLOCK_PATCHES=$(MOBLOCK_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOBLOCK_CPPFLAGS=
MOBLOCK_LDFLAGS=

#
# MOBLOCK_BUILD_DIR is the directory in which the build is done.
# MOBLOCK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOBLOCK_IPK_DIR is the directory in which the ipk is built.
# MOBLOCK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOBLOCK_BUILD_DIR=$(BUILD_DIR)/moblock
MOBLOCK_SOURCE_DIR=$(SOURCE_DIR)/moblock
MOBLOCK_IPK_DIR=$(BUILD_DIR)/moblock-$(MOBLOCK_VERSION)-ipk
MOBLOCK_IPK=$(BUILD_DIR)/moblock_$(MOBLOCK_VERSION)-$(MOBLOCK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: moblock-source moblock-unpack moblock moblock-stage moblock-ipk moblock-clean moblock-dirclean moblock-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOBLOCK_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOBLOCK_SITE)/$(MOBLOCK_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MOBLOCK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
moblock-source: $(DL_DIR)/$(MOBLOCK_SOURCE) $(MOBLOCK_PATCHES)

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
$(MOBLOCK_BUILD_DIR)/.configured: $(DL_DIR)/$(MOBLOCK_SOURCE) $(MOBLOCK_PATCHES) make/moblock.mk
	$(MAKE) libnetfilter-queue-stage
	rm -rf $(BUILD_DIR)/$(MOBLOCK_DIR) $(MOBLOCK_BUILD_DIR)
	$(MOBLOCK_UNZIP) $(DL_DIR)/$(MOBLOCK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOBLOCK_PATCHES)" ; \
		then cat $(MOBLOCK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOBLOCK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MOBLOCK_DIR)" != "$(MOBLOCK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MOBLOCK_DIR) $(MOBLOCK_BUILD_DIR) ; \
	fi
	sed -i -e 's|./moblock|moblock|' $(MOBLOCK_BUILD_DIR)/MoBlock-nfq.sh
	touch $@

moblock-unpack: $(MOBLOCK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOBLOCK_BUILD_DIR)/.built: $(MOBLOCK_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(MOBLOCK_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(MOBLOCK_LDFLAGS)" \
	$(MAKE) -C $(MOBLOCK_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
moblock: $(MOBLOCK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOBLOCK_BUILD_DIR)/.staged: $(MOBLOCK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MOBLOCK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

moblock-stage: $(MOBLOCK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/moblock
#
$(MOBLOCK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: moblock" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOBLOCK_PRIORITY)" >>$@
	@echo "Section: $(MOBLOCK_SECTION)" >>$@
	@echo "Version: $(MOBLOCK_VERSION)-$(MOBLOCK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOBLOCK_MAINTAINER)" >>$@
	@echo "Source: $(MOBLOCK_SITE)/$(MOBLOCK_SOURCE)" >>$@
	@echo "Description: $(MOBLOCK_DESCRIPTION)" >>$@
	@echo "Depends: $(MOBLOCK_DEPENDS)" >>$@
	@echo "Suggests: $(MOBLOCK_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOBLOCK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOBLOCK_IPK_DIR)/opt/sbin or $(MOBLOCK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOBLOCK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOBLOCK_IPK_DIR)/opt/etc/moblock/...
# Documentation files should be installed in $(MOBLOCK_IPK_DIR)/opt/doc/moblock/...
# Daemon startup scripts should be installed in $(MOBLOCK_IPK_DIR)/opt/etc/init.d/S??moblock
#
# You may need to patch your application to make it use these locations.
#
$(MOBLOCK_IPK): $(MOBLOCK_BUILD_DIR)/.built
	rm -rf $(MOBLOCK_IPK_DIR) $(BUILD_DIR)/moblock_*_$(TARGET_ARCH).ipk
	install -d $(MOBLOCK_IPK_DIR)/opt/bin
	$(MAKE) -C $(MOBLOCK_BUILD_DIR) DESTDIR=$(MOBLOCK_IPK_DIR) install
	install -d $(MOBLOCK_IPK_DIR)/opt/share/doc/moblock
	install -m 644 $(MOBLOCK_BUILD_DIR)/README $(MOBLOCK_IPK_DIR)/opt/share/doc/moblock
	install -m 644 $(MOBLOCK_BUILD_DIR)/MoBlock-nfq.sh $(MOBLOCK_IPK_DIR)/opt/bin
#	install -m 644 $(MOBLOCK_SOURCE_DIR)/moblock.conf $(MOBLOCK_IPK_DIR)/opt/etc/moblock.conf
#	install -d $(MOBLOCK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MOBLOCK_SOURCE_DIR)/rc.moblock $(MOBLOCK_IPK_DIR)/opt/etc/init.d/SXXmoblock
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOBLOCK_IPK_DIR)/opt/etc/init.d/SXXmoblock
	$(MAKE) $(MOBLOCK_IPK_DIR)/CONTROL/control
#	install -m 755 $(MOBLOCK_SOURCE_DIR)/postinst $(MOBLOCK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOBLOCK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MOBLOCK_SOURCE_DIR)/prerm $(MOBLOCK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOBLOCK_IPK_DIR)/CONTROL/prerm
	echo $(MOBLOCK_CONFFILES) | sed -e 's/ /\n/g' > $(MOBLOCK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOBLOCK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
moblock-ipk: $(MOBLOCK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
moblock-clean:
	rm -f $(MOBLOCK_BUILD_DIR)/.built
	-$(MAKE) -C $(MOBLOCK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
moblock-dirclean:
	rm -rf $(BUILD_DIR)/$(MOBLOCK_DIR) $(MOBLOCK_BUILD_DIR) $(MOBLOCK_IPK_DIR) $(MOBLOCK_IPK)
#
#
# Some sanity check for the package.
#
moblock-check: $(MOBLOCK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOBLOCK_IPK)
