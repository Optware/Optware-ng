###########################################################
#
# dir2ogg
#
###########################################################
#
# DIR2OGG_VERSION, DIR2OGG_SITE and DIR2OGG_SOURCE define
# the upstream location of the source code for the package.
# DIR2OGG_DIR is the directory which is created when the source
# archive is unpacked.
# DIR2OGG_UNZIP is the command used to unzip the source.
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
DIR2OGG_URL=https://github.com/julian-klode/dir2ogg/archive/$(DIR2OGG_VERSION).tar.gz
DIR2OGG_VERSION=0.12
DIR2OGG_SOURCE=dir2ogg-$(DIR2OGG_VERSION).tar.gz
DIR2OGG_DIR=dir2ogg-$(DIR2OGG_VERSION)
DIR2OGG_UNZIP=zcat
DIR2OGG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DIR2OGG_DESCRIPTION=dir2ogg is a GPL'ed python script which converts mp3, m4a, wma, and wav files into ogg-vorbis format.
DIR2OGG_SECTION=misc
DIR2OGG_PRIORITY=optional
DIR2OGG_DEPENDS=python27, py27-mutagen, vorbis-tools, mplayer
DIR2OGG_SUGGESTS=
DIR2OGG_CONFLICTS=

#
# DIR2OGG_IPK_VERSION should be incremented when the ipk changes.
#
DIR2OGG_IPK_VERSION=1

#
# DIR2OGG_CONFFILES should be a list of user-editable files
#DIR2OGG_CONFFILES=$(TARGET_PREFIX)/etc/dir2ogg.conf $(TARGET_PREFIX)/etc/init.d/SXXdir2ogg

#
# DIR2OGG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DIR2OGG_PATCHES=$(DIR2OGG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIR2OGG_CPPFLAGS=
DIR2OGG_LDFLAGS=

#
# DIR2OGG_BUILD_DIR is the directory in which the build is done.
# DIR2OGG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIR2OGG_IPK_DIR is the directory in which the ipk is built.
# DIR2OGG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIR2OGG_BUILD_DIR=$(BUILD_DIR)/dir2ogg
DIR2OGG_SOURCE_DIR=$(SOURCE_DIR)/dir2ogg
DIR2OGG_IPK_DIR=$(BUILD_DIR)/dir2ogg-$(DIR2OGG_VERSION)-ipk
DIR2OGG_IPK=$(BUILD_DIR)/dir2ogg_$(DIR2OGG_VERSION)-$(DIR2OGG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dir2ogg-source dir2ogg-unpack dir2ogg dir2ogg-stage dir2ogg-ipk dir2ogg-clean dir2ogg-dirclean dir2ogg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(DIR2OGG_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(DIR2OGG_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(DIR2OGG_SOURCE).sha512
#
$(DL_DIR)/$(DIR2OGG_SOURCE):
	$(WGET) -O $@ $(DIR2OGG_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dir2ogg-source: $(DL_DIR)/$(DIR2OGG_SOURCE) $(DIR2OGG_PATCHES)

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
$(DIR2OGG_BUILD_DIR)/.configured: $(DL_DIR)/$(DIR2OGG_SOURCE) $(DIR2OGG_PATCHES) make/dir2ogg.mk
	rm -rf $(BUILD_DIR)/$(DIR2OGG_DIR) $(@D)
	$(DIR2OGG_UNZIP) $(DL_DIR)/$(DIR2OGG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DIR2OGG_PATCHES)" ; \
		then cat $(DIR2OGG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DIR2OGG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DIR2OGG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DIR2OGG_DIR) $(@D) ; \
	fi
	sed -i -e 's|^#!/usr/bin/python$$|#!$(TARGET_PREFIX)/bin/python2.7|' $(@D)/dir2ogg
	touch $@

dir2ogg-unpack: $(DIR2OGG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DIR2OGG_BUILD_DIR)/.built: $(DIR2OGG_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
dir2ogg: $(DIR2OGG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DIR2OGG_BUILD_DIR)/.staged: $(DIR2OGG_BUILD_DIR)/.built
	rm -f $@
	touch $@

dir2ogg-stage: $(DIR2OGG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dir2ogg
#
$(DIR2OGG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: dir2ogg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIR2OGG_PRIORITY)" >>$@
	@echo "Section: $(DIR2OGG_SECTION)" >>$@
	@echo "Version: $(DIR2OGG_VERSION)-$(DIR2OGG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIR2OGG_MAINTAINER)" >>$@
	@echo "Source: $(DIR2OGG_URL)" >>$@
	@echo "Description: $(DIR2OGG_DESCRIPTION)" >>$@
	@echo "Depends: $(DIR2OGG_DEPENDS)" >>$@
	@echo "Suggests: $(DIR2OGG_SUGGESTS)" >>$@
	@echo "Conflicts: $(DIR2OGG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/etc/dir2ogg/...
# Documentation files should be installed in $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/doc/dir2ogg/...
# Daemon startup scripts should be installed in $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??dir2ogg
#
# You may need to patch your application to make it use these locations.
#
$(DIR2OGG_IPK): $(DIR2OGG_BUILD_DIR)/.built
	rm -rf $(DIR2OGG_IPK_DIR) $(BUILD_DIR)/dir2ogg_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/bin/ \
		$(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(INSTALL) -m 755 $(DIR2OGG_BUILD_DIR)/dir2ogg $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 644 $(DIR2OGG_BUILD_DIR)/dir2ogg.1 $(DIR2OGG_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(MAKE) $(DIR2OGG_IPK_DIR)/CONTROL/control
	echo $(DIR2OGG_CONFFILES) | sed -e 's/ /\n/g' > $(DIR2OGG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIR2OGG_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DIR2OGG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dir2ogg-ipk: $(DIR2OGG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dir2ogg-clean:
	rm -f $(DIR2OGG_BUILD_DIR)/.built
	-$(MAKE) -C $(DIR2OGG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dir2ogg-dirclean:
	rm -rf $(BUILD_DIR)/$(DIR2OGG_DIR) $(DIR2OGG_BUILD_DIR) $(DIR2OGG_IPK_DIR) $(DIR2OGG_IPK)
#
#
# Some sanity check for the package.
#
dir2ogg-check: $(DIR2OGG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
