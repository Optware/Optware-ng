###########################################################
#
# lddtree
#
###########################################################
#
# LDDTREE_VERSION, LDDTREE_SITE and LDDTREE_SOURCE define
# the upstream location of the source code for the package.
# LDDTREE_DIR is the directory which is created when the source
# archive is unpacked.
# LDDTREE_UNZIP is the command used to unzip the source.
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
LDDTREE_URL=https://github.com/ncopa/lddtree.git
LDDTREE_VERSION=20170314
LDDTREE_HASH=367581e0e867827e736e64e86e521d364b695bcb
LDDTREE_SOURCE=lddtree-$(LDDTREE_VERSION).tar.xz
LDDTREE_DIR=lddtree-$(LDDTREE_VERSION)
LDDTREE_UNZIP=xzcat
LDDTREE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LDDTREE_DESCRIPTION=Fork of pax-utils' bash utility to view hierarchy of shared library dependencies.
LDDTREE_SECTION=system
LDDTREE_PRIORITY=optional
# coreutils: for readlink command
LDDTREE_DEPENDS=bash, sed, binutils, coreutils
LDDTREE_SUGGESTS=
LDDTREE_CONFLICTS=

#
# LDDTREE_IPK_VERSION should be incremented when the ipk changes.
#
LDDTREE_IPK_VERSION=2

#
# LDDTREE_CONFFILES should be a list of user-editable files
#LDDTREE_CONFFILES=$(TARGET_PREFIX)/etc/lddtree.conf $(TARGET_PREFIX)/etc/init.d/SXXlddtree

#
# LDDTREE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LDDTREE_PATCHES=\
$(LDDTREE_SOURCE_DIR)/optware.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LDDTREE_CPPFLAGS=
LDDTREE_LDFLAGS=

#
# LDDTREE_BUILD_DIR is the directory in which the build is done.
# LDDTREE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LDDTREE_IPK_DIR is the directory in which the ipk is built.
# LDDTREE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LDDTREE_BUILD_DIR=$(BUILD_DIR)/lddtree
LDDTREE_SOURCE_DIR=$(SOURCE_DIR)/lddtree
LDDTREE_IPK_DIR=$(BUILD_DIR)/lddtree-$(LDDTREE_VERSION)-ipk
LDDTREE_IPK=$(BUILD_DIR)/lddtree_$(LDDTREE_VERSION)-$(LDDTREE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lddtree-source lddtree-unpack lddtree lddtree-stage lddtree-ipk lddtree-clean lddtree-dirclean lddtree-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LDDTREE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LDDTREE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LDDTREE_SOURCE).sha512
#
$(DL_DIR)/$(LDDTREE_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf $(LDDTREE_DIR) && \
		git clone $(LDDTREE_URL) $(LDDTREE_DIR) && \
		(cd $(LDDTREE_DIR) && \
		git checkout $(LDDTREE_HASH)) && \
		tar -cJf $@ $(LDDTREE_DIR) --exclude .git && \
		rm -rf $(LDDTREE_DIR) ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lddtree-source: $(DL_DIR)/$(LDDTREE_SOURCE) $(LDDTREE_PATCHES)

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
$(LDDTREE_BUILD_DIR)/.configured: $(DL_DIR)/$(LDDTREE_SOURCE) $(LDDTREE_PATCHES) make/lddtree.mk
	rm -rf $(BUILD_DIR)/$(LDDTREE_DIR) $(@D)
	$(LDDTREE_UNZIP) $(DL_DIR)/$(LDDTREE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LDDTREE_PATCHES)" ; \
		then cat $(LDDTREE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LDDTREE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LDDTREE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LDDTREE_DIR) $(@D) ; \
	fi
	touch $@

lddtree-unpack: $(LDDTREE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LDDTREE_BUILD_DIR)/.built: $(LDDTREE_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
lddtree: $(LDDTREE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LDDTREE_BUILD_DIR)/.staged: $(LDDTREE_BUILD_DIR)/.built
	rm -f $@
	touch $@

lddtree-stage: $(LDDTREE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lddtree
#
$(LDDTREE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: lddtree" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LDDTREE_PRIORITY)" >>$@
	@echo "Section: $(LDDTREE_SECTION)" >>$@
	@echo "Version: $(LDDTREE_VERSION)-$(LDDTREE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LDDTREE_MAINTAINER)" >>$@
	@echo "Source: $(LDDTREE_URL)" >>$@
	@echo "Description: $(LDDTREE_DESCRIPTION)" >>$@
	@echo "Depends: $(LDDTREE_DEPENDS)" >>$@
	@echo "Suggests: $(LDDTREE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LDDTREE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/lddtree/...
# Documentation files should be installed in $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/doc/lddtree/...
# Daemon startup scripts should be installed in $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??lddtree
#
# You may need to patch your application to make it use these locations.
#
$(LDDTREE_IPK): $(LDDTREE_BUILD_DIR)/.built
	rm -rf $(LDDTREE_IPK_DIR) $(BUILD_DIR)/lddtree_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/bin/
	$(INSTALL) -m 755 $(LDDTREE_BUILD_DIR)/lddtree.sh $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/bin/lddtree
#	$(INSTALL) -d $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LDDTREE_SOURCE_DIR)/lddtree.conf $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/lddtree.conf
#	$(INSTALL) -d $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LDDTREE_SOURCE_DIR)/rc.lddtree $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlddtree
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDDTREE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlddtree
	$(MAKE) $(LDDTREE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LDDTREE_SOURCE_DIR)/postinst $(LDDTREE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDDTREE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LDDTREE_SOURCE_DIR)/prerm $(LDDTREE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDDTREE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LDDTREE_IPK_DIR)/CONTROL/postinst $(LDDTREE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LDDTREE_CONFFILES) | sed -e 's/ /\n/g' > $(LDDTREE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LDDTREE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LDDTREE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lddtree-ipk: $(LDDTREE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lddtree-clean:
	rm -f $(LDDTREE_BUILD_DIR)/.built
	-$(MAKE) -C $(LDDTREE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lddtree-dirclean:
	rm -rf $(BUILD_DIR)/$(LDDTREE_DIR) $(LDDTREE_BUILD_DIR) $(LDDTREE_IPK_DIR) $(LDDTREE_IPK)
#
#
# Some sanity check for the package.
#
lddtree-check: $(LDDTREE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
