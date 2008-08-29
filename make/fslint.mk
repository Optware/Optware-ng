###########################################################
#
# fslint
#
###########################################################
#
# FSLINT_VERSION, FSLINT_SITE and FSLINT_SOURCE define
# the upstream location of the source code for the package.
# FSLINT_DIR is the directory which is created when the source
# archive is unpacked.
# FSLINT_UNZIP is the command used to unzip the source.
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
FSLINT_SITE=http://www.pixelbeat.org/fslint
FSLINT_VERSION=2.26
FSLINT_SOURCE=fslint-$(FSLINT_VERSION).tar.gz
FSLINT_DIR=fslint-$(FSLINT_VERSION)
FSLINT_UNZIP=zcat
FSLINT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FSLINT_DESCRIPTION=A utility to find and clean various forms of lint on a filesystem.
FSLINT_SECTION=utils
FSLINT_PRIORITY=optional
FSLINT_DEPENDS=bash, coreutils, python
FSLINT_SUGGESTS=
FSLINT_CONFLICTS=

#
# FSLINT_IPK_VERSION should be incremented when the ipk changes.
#
FSLINT_IPK_VERSION=1

#
# FSLINT_CONFFILES should be a list of user-editable files
#FSLINT_CONFFILES=/opt/etc/fslint.conf /opt/etc/init.d/SXXfslint

#
# FSLINT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FSLINT_PATCHES=$(FSLINT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FSLINT_CPPFLAGS=
FSLINT_LDFLAGS=

#
# FSLINT_BUILD_DIR is the directory in which the build is done.
# FSLINT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FSLINT_IPK_DIR is the directory in which the ipk is built.
# FSLINT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FSLINT_BUILD_DIR=$(BUILD_DIR)/fslint
FSLINT_SOURCE_DIR=$(SOURCE_DIR)/fslint
FSLINT_IPK_DIR=$(BUILD_DIR)/fslint-$(FSLINT_VERSION)-ipk
FSLINT_IPK=$(BUILD_DIR)/fslint_$(FSLINT_VERSION)-$(FSLINT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fslint-source fslint-unpack fslint fslint-stage fslint-ipk fslint-clean fslint-dirclean fslint-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FSLINT_SOURCE):
	$(WGET) -P $(@D) $(FSLINT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fslint-source: $(DL_DIR)/$(FSLINT_SOURCE) $(FSLINT_PATCHES)

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
$(FSLINT_BUILD_DIR)/.configured: $(DL_DIR)/$(FSLINT_SOURCE) $(FSLINT_PATCHES) make/fslint.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FSLINT_DIR) $(@D)
	$(FSLINT_UNZIP) $(DL_DIR)/$(FSLINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FSLINT_PATCHES)" ; \
		then cat $(FSLINT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FSLINT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FSLINT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FSLINT_DIR) $(@D) ; \
	fi
	sed -i -e '1s|^#!.*|#!/usr/bin/env python|' $(@D)/fslint/supprt/md5sum_approx
	find $(@D)/fslint -type f | xargs sed -i -e '1s|#!/bin/bash|#!/opt/bin/bash|'
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FSLINT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FSLINT_LDFLAGS)" \
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

fslint-unpack: $(FSLINT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FSLINT_BUILD_DIR)/.built: $(FSLINT_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
fslint: $(FSLINT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(FSLINT_BUILD_DIR)/.staged: $(FSLINT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#fslint-stage: $(FSLINT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fslint
#
$(FSLINT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fslint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FSLINT_PRIORITY)" >>$@
	@echo "Section: $(FSLINT_SECTION)" >>$@
	@echo "Version: $(FSLINT_VERSION)-$(FSLINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FSLINT_MAINTAINER)" >>$@
	@echo "Source: $(FSLINT_SITE)/$(FSLINT_SOURCE)" >>$@
	@echo "Description: $(FSLINT_DESCRIPTION)" >>$@
	@echo "Depends: $(FSLINT_DEPENDS)" >>$@
	@echo "Suggests: $(FSLINT_SUGGESTS)" >>$@
	@echo "Conflicts: $(FSLINT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FSLINT_IPK_DIR)/opt/sbin or $(FSLINT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FSLINT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FSLINT_IPK_DIR)/opt/etc/fslint/...
# Documentation files should be installed in $(FSLINT_IPK_DIR)/opt/doc/fslint/...
# Daemon startup scripts should be installed in $(FSLINT_IPK_DIR)/opt/etc/init.d/S??fslint
#
# You may need to patch your application to make it use these locations.
#
$(FSLINT_IPK): $(FSLINT_BUILD_DIR)/.built
	rm -rf $(FSLINT_IPK_DIR) $(BUILD_DIR)/fslint_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FSLINT_BUILD_DIR) DESTDIR=$(FSLINT_IPK_DIR) install-strip
	install -d $(FSLINT_IPK_DIR)/opt/bin
	cp -a $(FSLINT_BUILD_DIR)/fslint/* $(FSLINT_IPK_DIR)/opt/bin
	install -d $(FSLINT_IPK_DIR)/opt/man/man1
	install -m644 $(FSLINT_BUILD_DIR)/man/fslint.1 $(FSLINT_IPK_DIR)/opt/man/man1
	install -d $(FSLINT_IPK_DIR)/opt/share/doc/fslint
	install -m644 $(FSLINT_BUILD_DIR)/doc/* $(FSLINT_IPK_DIR)/opt/share/doc/fslint/
#	install -d $(FSLINT_IPK_DIR)/opt/etc/
#	install -m 644 $(FSLINT_SOURCE_DIR)/fslint.conf $(FSLINT_IPK_DIR)/opt/etc/fslint.conf
#	install -d $(FSLINT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FSLINT_SOURCE_DIR)/rc.fslint $(FSLINT_IPK_DIR)/opt/etc/init.d/SXXfslint
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FSLINT_IPK_DIR)/opt/etc/init.d/SXXfslint
	$(MAKE) $(FSLINT_IPK_DIR)/CONTROL/control
#	install -m 755 $(FSLINT_SOURCE_DIR)/postinst $(FSLINT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FSLINT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FSLINT_SOURCE_DIR)/prerm $(FSLINT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FSLINT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FSLINT_IPK_DIR)/CONTROL/postinst $(FSLINT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FSLINT_CONFFILES) | sed -e 's/ /\n/g' > $(FSLINT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FSLINT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fslint-ipk: $(FSLINT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fslint-clean:
	rm -f $(FSLINT_BUILD_DIR)/.built
	-$(MAKE) -C $(FSLINT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fslint-dirclean:
	rm -rf $(BUILD_DIR)/$(FSLINT_DIR) $(FSLINT_BUILD_DIR) $(FSLINT_IPK_DIR) $(FSLINT_IPK)
#
#
# Some sanity check for the package.
#
fslint-check: $(FSLINT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FSLINT_IPK)
