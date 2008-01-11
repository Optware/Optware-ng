###########################################################
#
# picocom
#
###########################################################
#
# PICOCOM_VERSION, PICOCOM_SITE and PICOCOM_SOURCE define
# the upstream location of the source code for the package.
# PICOCOM_DIR is the directory which is created when the source
# archive is unpacked.
# PICOCOM_UNZIP is the command used to unzip the source.
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
PICOCOM_SITE=http://efault.net/npat/hacks/picocom/dist/
PICOCOM_VERSION=1.4
PICOCOM_SOURCE=picocom-$(PICOCOM_VERSION).tar.gz
PICOCOM_DIR=picocom-$(PICOCOM_VERSION)
PICOCOM_UNZIP=zcat
PICOCOM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PICOCOM_DESCRIPTION=A minimal dumb-terminal emulation program.
PICOCOM_SECTION=comm
PICOCOM_PRIORITY=optional
PICOCOM_DEPENDS=
PICOCOM_SUGGESTS=
PICOCOM_CONFLICTS=

#
# PICOCOM_IPK_VERSION should be incremented when the ipk changes.
#
PICOCOM_IPK_VERSION=1

#
# PICOCOM_CONFFILES should be a list of user-editable files
#PICOCOM_CONFFILES=/opt/etc/picocom.conf /opt/etc/init.d/SXXpicocom

#
# PICOCOM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PICOCOM_PATCHES=$(PICOCOM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PICOCOM_CPPFLAGS=-DVERSION_STR=\\\"$(PICOCOM_VERSION)\\\" -DUUCP_LOCK_DIR=\\\"/opt/var/lock\\\"
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
PICOCOM_CPPFLAGS+= -D_POSIX_PATH_MAX=4096
endif
PICOCOM_LDFLAGS=

#
# PICOCOM_BUILD_DIR is the directory in which the build is done.
# PICOCOM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PICOCOM_IPK_DIR is the directory in which the ipk is built.
# PICOCOM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PICOCOM_BUILD_DIR=$(BUILD_DIR)/picocom
PICOCOM_SOURCE_DIR=$(SOURCE_DIR)/picocom
PICOCOM_IPK_DIR=$(BUILD_DIR)/picocom-$(PICOCOM_VERSION)-ipk
PICOCOM_IPK=$(BUILD_DIR)/picocom_$(PICOCOM_VERSION)-$(PICOCOM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: picocom-source picocom-unpack picocom picocom-stage picocom-ipk picocom-clean picocom-dirclean picocom-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PICOCOM_SOURCE):
	$(WGET) -P $(DL_DIR) $(PICOCOM_SITE)/$(PICOCOM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
picocom-source: $(DL_DIR)/$(PICOCOM_SOURCE) $(PICOCOM_PATCHES)

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
$(PICOCOM_BUILD_DIR)/.configured: $(DL_DIR)/$(PICOCOM_SOURCE) $(PICOCOM_PATCHES) make/picocom.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PICOCOM_DIR) $(PICOCOM_BUILD_DIR)
	$(PICOCOM_UNZIP) $(DL_DIR)/$(PICOCOM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PICOCOM_PATCHES)" ; \
		then cat $(PICOCOM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PICOCOM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PICOCOM_DIR)" != "$(PICOCOM_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PICOCOM_DIR) $(PICOCOM_BUILD_DIR) ; \
	fi
#	(cd $(PICOCOM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PICOCOM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PICOCOM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(PICOCOM_BUILD_DIR)/libtool
	touch $(PICOCOM_BUILD_DIR)/.configured

picocom-unpack: $(PICOCOM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PICOCOM_BUILD_DIR)/.built: $(PICOCOM_BUILD_DIR)/.configured
	rm -f $(PICOCOM_BUILD_DIR)/.built
	$(MAKE) -C $(PICOCOM_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PICOCOM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PICOCOM_LDFLAGS)"
	touch $(PICOCOM_BUILD_DIR)/.built

#
# This is the build convenience target.
#
picocom: $(PICOCOM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PICOCOM_BUILD_DIR)/.staged: $(PICOCOM_BUILD_DIR)/.built
	rm -f $(PICOCOM_BUILD_DIR)/.staged
	$(MAKE) -C $(PICOCOM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PICOCOM_BUILD_DIR)/.staged

picocom-stage: $(PICOCOM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/picocom
#
$(PICOCOM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: picocom" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PICOCOM_PRIORITY)" >>$@
	@echo "Section: $(PICOCOM_SECTION)" >>$@
	@echo "Version: $(PICOCOM_VERSION)-$(PICOCOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PICOCOM_MAINTAINER)" >>$@
	@echo "Source: $(PICOCOM_SITE)/$(PICOCOM_SOURCE)" >>$@
	@echo "Description: $(PICOCOM_DESCRIPTION)" >>$@
	@echo "Depends: $(PICOCOM_DEPENDS)" >>$@
	@echo "Suggests: $(PICOCOM_SUGGESTS)" >>$@
	@echo "Conflicts: $(PICOCOM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PICOCOM_IPK_DIR)/opt/sbin or $(PICOCOM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PICOCOM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PICOCOM_IPK_DIR)/opt/etc/picocom/...
# Documentation files should be installed in $(PICOCOM_IPK_DIR)/opt/doc/picocom/...
# Daemon startup scripts should be installed in $(PICOCOM_IPK_DIR)/opt/etc/init.d/S??picocom
#
# You may need to patch your application to make it use these locations.
#
$(PICOCOM_IPK): $(PICOCOM_BUILD_DIR)/.built
	rm -rf $(PICOCOM_IPK_DIR) $(BUILD_DIR)/picocom_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PICOCOM_BUILD_DIR) DESTDIR=$(PICOCOM_IPK_DIR) install-strip
	install -d $(PICOCOM_IPK_DIR)/opt/bin $(PICOCOM_IPK_DIR)/opt/share/doc/picocom $(PICOCOM_IPK_DIR)/opt/share/man/man8
	install -m 755 $(PICOCOM_BUILD_DIR)/picocom $(PICOCOM_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(PICOCOM_IPK_DIR)/opt/bin/picocom
	install -m 755 $(PICOCOM_BUILD_DIR)/pc* $(PICOCOM_IPK_DIR)/opt/bin/
	install -m 644 $(PICOCOM_BUILD_DIR)/picocom.8 $(PICOCOM_IPK_DIR)/opt/share/man/man8/
	install -m 644 $(PICOCOM_BUILD_DIR)/picocom.8.html $(PICOCOM_BUILD_DIR)/picocom.8.ps \
		$(PICOCOM_IPK_DIR)/opt/share/doc/picocom/
#	install -m 644 $(PICOCOM_SOURCE_DIR)/picocom.conf $(PICOCOM_IPK_DIR)/opt/etc/picocom.conf
#	install -d $(PICOCOM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PICOCOM_SOURCE_DIR)/rc.picocom $(PICOCOM_IPK_DIR)/opt/etc/init.d/SXXpicocom
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXpicocom
	$(MAKE) $(PICOCOM_IPK_DIR)/CONTROL/control
#	install -m 755 $(PICOCOM_SOURCE_DIR)/postinst $(PICOCOM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PICOCOM_SOURCE_DIR)/prerm $(PICOCOM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(PICOCOM_CONFFILES) | sed -e 's/ /\n/g' > $(PICOCOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PICOCOM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
picocom-ipk: $(PICOCOM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
picocom-clean:
	rm -f $(PICOCOM_BUILD_DIR)/.built
	-$(MAKE) -C $(PICOCOM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
picocom-dirclean:
	rm -rf $(BUILD_DIR)/$(PICOCOM_DIR) $(PICOCOM_BUILD_DIR) $(PICOCOM_IPK_DIR) $(PICOCOM_IPK)
#
#
# Some sanity check for the package.
#
picocom-check: $(PICOCOM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PICOCOM_IPK)
