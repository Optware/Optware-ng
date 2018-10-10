###########################################################
#
# ldd
#
###########################################################
#
# LDD_VERSION, LDD_SITE and LDD_SOURCE define
# the upstream location of the source code for the package.
# LDD_DIR is the directory which is created when the source
# archive is unpacked.
# LDD_UNZIP is the command used to unzip the source.
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
ifeq ($(LIBC_STYLE), uclibc)
LDD_URL=https://downloads.uclibc-ng.org/releases/$(LDD_VERSION)/uClibc-ng-$(LDD_VERSION).tar.bz2
LDD_VERSION=1.0.15
else
LDD_URL=http://ftp.gnu.org.ua/gnu/libc/glibc-$(LDD_VERSION).tar.bz2
LDD_VERSION=2.20
endif
LDD_UNZIP=zcat
LDD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LDD_DESCRIPTION=This is the ldd command, which lists what shared libraries are used by given dynamically-linked executables
LDD_SECTION=dev
LDD_PRIORITY=optional
ifeq ($(LIBC_STYLE), uclibc)
LDD_DEPENDS=
else
LDD_DEPENDS=bash
endif
LDD_SUGGESTS=
LDD_CONFLICTS=

#
# LDD_IPK_VERSION should be incremented when the ipk changes.
#
LDD_IPK_VERSION=1

#
# LDD_CONFFILES should be a list of user-editable files
#LDD_CONFFILES=$(TARGET_PREFIX)/etc/ldd.conf $(TARGET_PREFIX)/etc/init.d/SXXldd

#
# LDD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LDD_PATCHES=$(LDD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LDD_CPPFLAGS=
LDD_LDFLAGS=

#
# LDD_BUILD_DIR is the directory in which the build is done.
# LDD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LDD_IPK_DIR is the directory in which the ipk is built.
# LDD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LDD_BUILD_DIR=$(BUILD_DIR)/ldd
LDD_SOURCE_DIR=$(SOURCE_DIR)/ldd
LDD_IPK_DIR=$(BUILD_DIR)/ldd-$(LDD_VERSION)-ipk
LDD_IPK=$(BUILD_DIR)/ldd_$(LDD_VERSION)-$(LDD_IPK_VERSION)_$(TARGET_ARCH).ipk

LDD_LD=$(strip \
    $(if $(filter buildroot-armeabihf, $(OPTWARE_TARGET)), ld-linux-armhf.so.3, \
    $(if $(filter buildroot-i686, $(OPTWARE_TARGET)), ld-linux.so.2, \
    $(if $(filter buildroot-x86_64, $(OPTWARE_TARGET)), ld-linux-x86-64.so.2, \
    $(if $(filter ct-ng-ppc-e500v2 buildroot-ppc-603e, $(OPTWARE_TARGET)), ld.so.1, \
    ld-uClibc.so.1)))))

.PHONY: ldd-source ldd-unpack ldd ldd-ipk ldd-clean ldd-dirclean ldd-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ldd-source: $(LDD_SOURCE_DIR)/ldd.c $(LDD_SOURCE_DIR)/porting.h $(LDD_SOURCE_DIR)/ldd.sh

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
$(LDD_BUILD_DIR)/.configured: $(LDD_SOURCE_DIR)/ldd.c $(LDD_SOURCE_DIR)/porting.h \
				$(LDD_SOURCE_DIR)/ldd.sh make/ldd.mk
	rm -rf $(@D)
	mkdir -p $(@D)
ifeq ($(LIBC_STYLE), uclibc)
	cp -af $(LDD_SOURCE_DIR)/ldd.c $(LDD_SOURCE_DIR)/porting.h $(@D)
else
	$(INSTALL) -m755 $(LDD_SOURCE_DIR)/ldd.sh $(@D)/ldd
	sed -i -e 's/%OPTWARE_TARGET_LD%/$(LDD_LD)/' $(@D)/ldd
endif
	touch $@

ldd-unpack: $(LDD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LDD_BUILD_DIR)/.built: $(LDD_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(LIBC_STYLE), uclibc)
	$(TARGET_CC) $(STAGING_CPPFLAGS) $(LDD_CPPFLAGS) \
			$(STAGING_LDFLAGS) $(LDD_LDFLAGS) \
		$(@D)/ldd.c -o $(@D)/ldd
endif
	touch $@

#
# This is the build convenience target.
#
ldd: $(LDD_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ldd
#
$(LDD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ldd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LDD_PRIORITY)" >>$@
	@echo "Section: $(LDD_SECTION)" >>$@
	@echo "Version: $(LDD_VERSION)-$(LDD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LDD_MAINTAINER)" >>$@
	@echo "Source: $(LDD_URL)" >>$@
	@echo "Description: $(LDD_DESCRIPTION)" >>$@
	@echo "Depends: $(LDD_DEPENDS)" >>$@
	@echo "Suggests: $(LDD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LDD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LDD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LDD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LDD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/ldd/...
# Documentation files should be installed in $(LDD_IPK_DIR)$(TARGET_PREFIX)/doc/ldd/...
# Daemon startup scripts should be installed in $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ldd
#
# You may need to patch your application to make it use these locations.
#
$(LDD_IPK): $(LDD_BUILD_DIR)/.built
	rm -rf $(LDD_IPK_DIR) $(BUILD_DIR)/ldd_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LDD_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m755 $(LDD_BUILD_DIR)/ldd $(LDD_IPK_DIR)$(TARGET_PREFIX)/bin/
ifeq ($(LIBC_STYLE), uclibc)
	$(STRIP_COMMAND) $(LDD_IPK_DIR)$(TARGET_PREFIX)/bin/ldd
endif
#	$(INSTALL) -d $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LDD_SOURCE_DIR)/ldd.conf $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/ldd.conf
#	$(INSTALL) -d $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LDD_SOURCE_DIR)/rc.ldd $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXldd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXldd
	$(MAKE) $(LDD_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LDD_SOURCE_DIR)/postinst $(LDD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LDD_SOURCE_DIR)/prerm $(LDD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LDD_IPK_DIR)/CONTROL/postinst $(LDD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LDD_CONFFILES) | sed -e 's/ /\n/g' > $(LDD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LDD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LDD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ldd-ipk: $(LDD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ldd-clean:
	rm -f $(LDD_BUILD_DIR)/.built
	-$(MAKE) -C $(LDD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ldd-dirclean:
	rm -rf $(LDD_BUILD_DIR) $(LDD_IPK_DIR) $(LDD_IPK)
#
#
# Some sanity check for the package.
#
ldd-check: $(LDD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
