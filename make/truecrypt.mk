###########################################################
#
# truecrypt
#
###########################################################
#
# TRUECRYPT_VERSION, TRUECRYPT_SITE and TRUECRYPT_SOURCE define
# the upstream location of the source code for the package.
# TRUECRYPT_DIR is the directory which is created when the source
# archive is unpacked.
# TRUECRYPT_UNZIP is the command used to unzip the source.
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
TRUECRYPT_SITE=http://www.truecrypt.org/downloads
TRUECRYPT_VERSION=4.3a
TRUECRYPT_SOURCE=truecrypt-$(TRUECRYPT_VERSION)-source-code.tar.gz
TRUECRYPT_DIR=truecrypt-$(TRUECRYPT_VERSION)-source-code
TRUECRYPT_UNZIP=zcat
TRUECRYPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TRUECRYPT_DESCRIPTION=Open-source and platform-independent On-The-Fly disk encryption software.
TRUECRYPT_SECTION=misc
TRUECRYPT_PRIORITY=optional
TRUECRYPT_DEPENDS=dmsetup
TRUECRYPT_SUGGESTS=module-init-tools
TRUECRYPT_CONFLICTS=

#
# TRUECRYPT_IPK_VERSION should be incremented when the ipk changes.
#
TRUECRYPT_IPK_VERSION=1

#
# TRUECRYPT_CONFFILES should be a list of user-editable files
#TRUECRYPT_CONFFILES=/opt/etc/truecrypt.conf /opt/etc/init.d/SXXtruecrypt

#
# TRUECRYPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TRUECRYPT_PATCHES=$(TRUECRYPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRUECRYPT_CPPFLAGS=
TRUECRYPT_LDFLAGS=

#
# TRUECRYPT_BUILD_DIR is the directory in which the build is done.
# TRUECRYPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRUECRYPT_IPK_DIR is the directory in which the ipk is built.
# TRUECRYPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRUECRYPT_BUILD_DIR=$(BUILD_DIR)/truecrypt
TRUECRYPT_SOURCE_DIR=$(SOURCE_DIR)/truecrypt
TRUECRYPT_IPK_DIR=$(BUILD_DIR)/truecrypt-$(TRUECRYPT_VERSION)-ipk
TRUECRYPT_IPK=$(BUILD_DIR)/truecrypt_$(TRUECRYPT_VERSION)-$(TRUECRYPT_IPK_VERSION)_$(TARGET_ARCH).ipk

TRUECRYPT_MODDIR=$(TRUECRYPT_IPK_DIR)/opt/lib/modules/2.6.12.6-arm1/extra

.PHONY: truecrypt-source truecrypt-unpack truecrypt truecrypt-stage truecrypt-ipk truecrypt-clean truecrypt-dirclean truecrypt-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TRUECRYPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(TRUECRYPT_SITE)/$(TRUECRYPT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TRUECRYPT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
truecrypt-source: $(DL_DIR)/$(TRUECRYPT_SOURCE) $(TRUECRYPT_PATCHES)

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
$(TRUECRYPT_BUILD_DIR)/.configured: $(DL_DIR)/$(TRUECRYPT_SOURCE) $(TRUECRYPT_PATCHES) make/truecrypt.mk
	$(MAKE) kernel-modules
	rm -rf $(BUILD_DIR)/$(TRUECRYPT_DIR) $(TRUECRYPT_BUILD_DIR)
	$(TRUECRYPT_UNZIP) $(DL_DIR)/$(TRUECRYPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRUECRYPT_PATCHES)" ; \
		then cat $(TRUECRYPT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TRUECRYPT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TRUECRYPT_DIR)" != "$(TRUECRYPT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TRUECRYPT_DIR) $(TRUECRYPT_BUILD_DIR) ; \
	fi
	sed -i	-e '/id -u/s/^/#/' \
		-e '/^KERNEL_SRC=/s/^/#/' \
		-e '/^KERNEL_VER=/s/^/#/' \
		$(@D)/Linux/build.sh
	sed -i	-e 's|@$$(CMN)/platform >|cp $(TRUECRYPT_SOURCE_DIR)/platform |' \
		-e 's|M=$$(PWD)|& $(KERNEL-MODULES-FLAGS)|' \
		$(@D)/Linux/Kernel/Makefile
	sed -i	-e 's|@strip |$(TARGET_STRIP) |' $(@D)/Linux/Cli/Makefile
	sed -i	-e '/setenv.*PATH/s|"/|"/opt/sbin:/opt/bin:/|' $(@D)/Linux/Cli/Cli.c
	touch $@

truecrypt-unpack: $(TRUECRYPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRUECRYPT_BUILD_DIR)/.built: $(TRUECRYPT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/Linux; \
		$(TARGET_CONFIGURE_OPTS) \
		KERNEL_SRC=$(KERNEL_BUILD_DIR) \
		KERNEL_VER=2.6.12 \
		./build.sh; \
	)
	touch $@

#
# This is the build convenience target.
#
truecrypt: $(TRUECRYPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TRUECRYPT_BUILD_DIR)/.staged: $(TRUECRYPT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TRUECRYPT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

truecrypt-stage: $(TRUECRYPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/truecrypt
#
$(TRUECRYPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: truecrypt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRUECRYPT_PRIORITY)" >>$@
	@echo "Section: $(TRUECRYPT_SECTION)" >>$@
	@echo "Version: $(TRUECRYPT_VERSION)-$(TRUECRYPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TRUECRYPT_MAINTAINER)" >>$@
	@echo "Source: $(TRUECRYPT_SITE)/$(TRUECRYPT_SOURCE)" >>$@
	@echo "Description: $(TRUECRYPT_DESCRIPTION)" >>$@
	@echo "Depends: $(TRUECRYPT_DEPENDS)" >>$@
	@echo "Suggests: $(TRUECRYPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRUECRYPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRUECRYPT_IPK_DIR)/opt/sbin or $(TRUECRYPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRUECRYPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TRUECRYPT_IPK_DIR)/opt/etc/truecrypt/...
# Documentation files should be installed in $(TRUECRYPT_IPK_DIR)/opt/doc/truecrypt/...
# Daemon startup scripts should be installed in $(TRUECRYPT_IPK_DIR)/opt/etc/init.d/S??truecrypt
#
# You may need to patch your application to make it use these locations.
#
$(TRUECRYPT_IPK): $(TRUECRYPT_BUILD_DIR)/.built
	rm -rf $(TRUECRYPT_IPK_DIR) $(BUILD_DIR)/truecrypt_*_$(TARGET_ARCH).ipk
	install -d $(TRUECRYPT_MODDIR)
	$(STRIP_COMMAND) $(TRUECRYPT_BUILD_DIR)/Linux/Kernel/truecrypt.ko \
		-o $(TRUECRYPT_MODDIR)/truecrypt.ko
	install -d $(TRUECRYPT_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(TRUECRYPT_BUILD_DIR)/Linux/Cli/truecrypt \
		-o $(TRUECRYPT_IPK_DIR)/opt/bin/truecrypt
#	$(MAKE) -C $(TRUECRYPT_BUILD_DIR) DESTDIR=$(TRUECRYPT_IPK_DIR) install-strip
	$(MAKE) $(TRUECRYPT_IPK_DIR)/CONTROL/control
	# TODO write postinst/prerm
#	install -m 755 $(TRUECRYPT_SOURCE_DIR)/postinst $(TRUECRYPT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TRUECRYPT_SOURCE_DIR)/prerm $(TRUECRYPT_IPK_DIR)/CONTROL/prerm
	echo $(TRUECRYPT_CONFFILES) | sed -e 's/ /\n/g' > $(TRUECRYPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRUECRYPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
truecrypt-ipk: $(TRUECRYPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
truecrypt-clean:
	rm -f $(TRUECRYPT_BUILD_DIR)/.built
	-$(MAKE) -C $(TRUECRYPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
truecrypt-dirclean:
	rm -rf $(BUILD_DIR)/$(TRUECRYPT_DIR) $(TRUECRYPT_BUILD_DIR) $(TRUECRYPT_IPK_DIR) $(TRUECRYPT_IPK)
#
#
# Some sanity check for the package.
#
truecrypt-check: $(TRUECRYPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TRUECRYPT_IPK)
