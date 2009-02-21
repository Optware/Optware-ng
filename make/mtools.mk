###########################################################
#
# mtools
#
###########################################################
#
# MTOOLS_VERSION, MTOOLS_SITE and MTOOLS_SOURCE define
# the upstream location of the source code for the package.
# MTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# MTOOLS_UNZIP is the command used to unzip the source.
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
MTOOLS_SITE=http://mtools.linux.lu
MTOOLS_VERSION=4.0.5
MTOOLS_SOURCE=mtools-$(MTOOLS_VERSION).tar.bz2
MTOOLS_DIR=mtools-$(MTOOLS_VERSION)
MTOOLS_UNZIP=bzcat
MTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MTOOLS_DESCRIPTION=A collection of utilities to access MS-DOS disks from Unix without mounting them.
MTOOLS_SECTION=misc
MTOOLS_PRIORITY=optional
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MTOOLS_DEPENDS=libiconv
endif
MTOOLS_SUGGESTS=
MTOOLS_CONFLICTS=

#
# MTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
MTOOLS_IPK_VERSION=1

#
# MTOOLS_CONFFILES should be a list of user-editable files
#MTOOLS_CONFFILES=/opt/etc/mtools.conf /opt/etc/init.d/SXXmtools

#
# MTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MTOOLS_PATCHES=$(MTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MTOOLS_CPPFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MTOOLS_LDFLAGS=-liconv
endif

#
# MTOOLS_BUILD_DIR is the directory in which the build is done.
# MTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MTOOLS_IPK_DIR is the directory in which the ipk is built.
# MTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MTOOLS_BUILD_DIR=$(BUILD_DIR)/mtools
MTOOLS_SOURCE_DIR=$(SOURCE_DIR)/mtools
MTOOLS_IPK_DIR=$(BUILD_DIR)/mtools-$(MTOOLS_VERSION)-ipk
MTOOLS_IPK=$(BUILD_DIR)/mtools_$(MTOOLS_VERSION)-$(MTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mtools-source mtools-unpack mtools mtools-stage mtools-ipk mtools-clean mtools-dirclean mtools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MTOOLS_SOURCE):
	$(WGET) -P $(@D) $(MTOOLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mtools-source: $(DL_DIR)/$(MTOOLS_SOURCE) $(MTOOLS_PATCHES)

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
$(MTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(MTOOLS_SOURCE) $(MTOOLS_PATCHES) make/mtools.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(MTOOLS_DIR) $(@D)
	$(MTOOLS_UNZIP) $(DL_DIR)/$(MTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MTOOLS_PATCHES)" ; \
		then cat $(MTOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MTOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MTOOLS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MTOOLS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MTOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MTOOLS_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mtools-unpack: $(MTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MTOOLS_BUILD_DIR)/.built: $(MTOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mtools: $(MTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(MTOOLS_BUILD_DIR)/.staged: $(MTOOLS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#mtools-stage: $(MTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mtools
#
$(MTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mtools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MTOOLS_PRIORITY)" >>$@
	@echo "Section: $(MTOOLS_SECTION)" >>$@
	@echo "Version: $(MTOOLS_VERSION)-$(MTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(MTOOLS_SITE)/$(MTOOLS_SOURCE)" >>$@
	@echo "Description: $(MTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(MTOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(MTOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(MTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MTOOLS_IPK_DIR)/opt/sbin or $(MTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MTOOLS_IPK_DIR)/opt/etc/mtools/...
# Documentation files should be installed in $(MTOOLS_IPK_DIR)/opt/doc/mtools/...
# Daemon startup scripts should be installed in $(MTOOLS_IPK_DIR)/opt/etc/init.d/S??mtools
#
# You may need to patch your application to make it use these locations.
#
$(MTOOLS_IPK): $(MTOOLS_BUILD_DIR)/.built
	rm -rf $(MTOOLS_IPK_DIR) $(BUILD_DIR)/mtools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MTOOLS_BUILD_DIR) prefix=$(MTOOLS_IPK_DIR)/opt install INSTALL_INFO=:
	$(STRIP_COMMAND) $(MTOOLS_IPK_DIR)/opt/bin/mtools $(MTOOLS_IPK_DIR)/opt/bin/mkmanifest
#	install -d $(MTOOLS_IPK_DIR)/opt/etc/
#	install -m 644 $(MTOOLS_SOURCE_DIR)/mtools.conf $(MTOOLS_IPK_DIR)/opt/etc/mtools.conf
#	install -d $(MTOOLS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MTOOLS_SOURCE_DIR)/rc.mtools $(MTOOLS_IPK_DIR)/opt/etc/init.d/SXXmtools
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXmtools
	$(MAKE) $(MTOOLS_IPK_DIR)/CONTROL/control
#	install -m 755 $(MTOOLS_SOURCE_DIR)/postinst $(MTOOLS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MTOOLS_SOURCE_DIR)/prerm $(MTOOLS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(MTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(MTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mtools-ipk: $(MTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mtools-clean:
	rm -f $(MTOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(MTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mtools-dirclean:
	rm -rf $(BUILD_DIR)/$(MTOOLS_DIR) $(MTOOLS_BUILD_DIR) $(MTOOLS_IPK_DIR) $(MTOOLS_IPK)
#
#
# Some sanity check for the package.
#
mtools-check: $(MTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
