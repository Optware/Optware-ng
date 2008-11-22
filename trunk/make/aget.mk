###########################################################
#
# aget
#
###########################################################
#
# AGET_VERSION, AGET_SITE and AGET_SOURCE define
# the upstream location of the source code for the package.
# AGET_DIR is the directory which is created when the source
# archive is unpacked.
# AGET_UNZIP is the command used to unzip the source.
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
AGET_SITE=http://www.enderunix.org/aget
AGET_VERSION=0.4
AGET_SOURCE=aget-$(AGET_VERSION).tar.gz
AGET_DIR=aget-$(AGET_VERSION)
AGET_UNZIP=zcat
AGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AGET_DESCRIPTION=Aget is a multithreaded HTTP download accelerator.
AGET_SECTION=net
AGET_PRIORITY=optional
AGET_DEPENDS=
AGET_SUGGESTS=
AGET_CONFLICTS=

#
# AGET_IPK_VERSION should be incremented when the ipk changes.
#
AGET_IPK_VERSION=1

#
# AGET_CONFFILES should be a list of user-editable files
#AGET_CONFFILES=/opt/etc/aget.conf /opt/etc/init.d/SXXaget

#
# AGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#AGET_PATCHES=$(AGET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AGET_CPPFLAGS=
AGET_LDFLAGS=-pthread

#
# AGET_BUILD_DIR is the directory in which the build is done.
# AGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AGET_IPK_DIR is the directory in which the ipk is built.
# AGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AGET_BUILD_DIR=$(BUILD_DIR)/aget
AGET_SOURCE_DIR=$(SOURCE_DIR)/aget
AGET_IPK_DIR=$(BUILD_DIR)/aget-$(AGET_VERSION)-ipk
AGET_IPK=$(BUILD_DIR)/aget_$(AGET_VERSION)-$(AGET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: aget-source aget-unpack aget aget-stage aget-ipk aget-clean aget-dirclean aget-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AGET_SOURCE):
	$(WGET) -P $(@D) $(AGET_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
aget-source: $(DL_DIR)/$(AGET_SOURCE) $(AGET_PATCHES)

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
$(AGET_BUILD_DIR)/.configured: $(DL_DIR)/$(AGET_SOURCE) $(AGET_PATCHES) make/aget.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(AGET_DIR) $(@D)
	$(AGET_UNZIP) $(DL_DIR)/$(AGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AGET_PATCHES)" ; \
		then cat $(AGET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(AGET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(AGET_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(AGET_DIR) $(@D) ; \
	fi
	sed -i.orig -e 's|^extern int errno;|#include <errno.h>|' \
		$(@D)/main.c $(@D)/Aget.c $(@D)/Download.c $(@D)/Head.c
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AGET_LDFLAGS)" \
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

aget-unpack: $(AGET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AGET_BUILD_DIR)/.built: $(AGET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AGET_LDFLAGS)" \
;
	touch $@

#
# This is the build convenience target.
#
aget: $(AGET_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/aget
#
$(AGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: aget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AGET_PRIORITY)" >>$@
	@echo "Section: $(AGET_SECTION)" >>$@
	@echo "Version: $(AGET_VERSION)-$(AGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AGET_MAINTAINER)" >>$@
	@echo "Source: $(AGET_SITE)/$(AGET_SOURCE)" >>$@
	@echo "Description: $(AGET_DESCRIPTION)" >>$@
	@echo "Depends: $(AGET_DEPENDS)" >>$@
	@echo "Suggests: $(AGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(AGET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AGET_IPK_DIR)/opt/sbin or $(AGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AGET_IPK_DIR)/opt/etc/aget/...
# Documentation files should be installed in $(AGET_IPK_DIR)/opt/doc/aget/...
# Daemon startup scripts should be installed in $(AGET_IPK_DIR)/opt/etc/init.d/S??aget
#
# You may need to patch your application to make it use these locations.
#
$(AGET_IPK): $(AGET_BUILD_DIR)/.built
	rm -rf $(AGET_IPK_DIR) $(BUILD_DIR)/aget_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(AGET_BUILD_DIR) DESTDIR=$(AGET_IPK_DIR) install-strip
	install -d $(AGET_IPK_DIR)/opt/bin
	install -m755 $(<D)/aget $(AGET_IPK_DIR)/opt/bin/
	install -d $(AGET_IPK_DIR)/opt/share/doc/aget
	install $(<D)/AUTHORS $(<D)/COPYING $(<D)/ChangeLog $(<D)/INSTALL \
		$(<D)/README* $(<D)/THANKS $(<D)/TODO $(AGET_IPK_DIR)/opt/share/doc/aget/
	$(STRIP_COMMAND) $(AGET_IPK_DIR)/opt/bin/aget
	$(MAKE) $(AGET_IPK_DIR)/CONTROL/control
	echo $(AGET_CONFFILES) | sed -e 's/ /\n/g' > $(AGET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AGET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
aget-ipk: $(AGET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
aget-clean:
	rm -f $(AGET_BUILD_DIR)/.built
	-$(MAKE) -C $(AGET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
aget-dirclean:
	rm -rf $(BUILD_DIR)/$(AGET_DIR) $(AGET_BUILD_DIR) $(AGET_IPK_DIR) $(AGET_IPK)
#
#
# Some sanity check for the package.
#
aget-check: $(AGET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AGET_IPK)
