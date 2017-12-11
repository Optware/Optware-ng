###########################################################
#
# udpxy
#
###########################################################

# You must replace "udpxy" and "UDPXY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UDPXY_VERSION, UDPXY_SITE and UDPXY_SOURCE define
# the upstream location of the source code for the package.
# UDPXY_DIR is the directory which is created when the source
# archive is unpacked.
# UDPXY_UNZIP is the command used to unzip the source.
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
#UDPXY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/udpxy
#UDPXY_VERSION=1.0-Chipmunk-19
UDPXY_REPOSITORY=git://github.com/pcherenkov/udpxy.git
UDPXY_GIT_DATE=20140803
UDPXY_VERSION=git$(UDPXY_GIT_DATE)
UDPXY_TREEISH=`git rev-list --max-count=1 --until=2014-08-03 HEAD`
UDPXY_SOURCE=udpxy.$(UDPXY_VERSION).tgz
UDPXY_DIR=udpxy-$(UDPXY_VERSION)
UDPXY_UNZIP=zcat
UDPXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UDPXY_DESCRIPTION=Convert UDP IPTV streams into HTTP streams. 
UDPXY_SECTION=net
UDPXY_PRIORITY=optional
UDPXY_DEPENDS=
UDPXY_SUGGESTS=
UDPXY_CONFLICTS=

#
# UDPXY_IPK_VERSION should be incremented when the ipk changes.
#
UDPXY_IPK_VERSION=1

#
# UDPXY_CONFFILES should be a list of user-editable files
UDPXY_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S29udpxy

#
# UDPXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UDPXY_PATCHES=\
$(UDPXY_SOURCE_DIR)/Makefile.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UDPXY_CPPFLAGS=
UDPXY_LDFLAGS=

#
# UDPXY_BUILD_DIR is the directory in which the build is done.
# UDPXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UDPXY_IPK_DIR is the directory in which the ipk is built.
# UDPXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UDPXY_BUILD_DIR=$(BUILD_DIR)/udpxy
UDPXY_SOURCE_DIR=$(SOURCE_DIR)/udpxy
UDPXY_IPK_DIR=$(BUILD_DIR)/udpxy-$(UDPXY_VERSION)-ipk
UDPXY_IPK=$(BUILD_DIR)/udpxy_$(UDPXY_VERSION)-$(UDPXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: udpxy-source udpxy-unpack udpxy udpxy-stage udpxy-ipk udpxy-clean udpxy-dirclean udpxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using git.
#
$(DL_DIR)/$(UDPXY_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf udpxy && \
		git clone --bare $(UDPXY_REPOSITORY) udpxy && \
		(cd udpxy && \
		git archive --format=tar --prefix=$(UDPXY_DIR)/ $(UDPXY_TREEISH) | gzip > $@) && \
		rm -rf udpxy ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
udpxy-source: $(DL_DIR)/$(UDPXY_SOURCE) $(UDPXY_PATCHES)

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
$(UDPXY_BUILD_DIR)/.configured: $(DL_DIR)/$(UDPXY_SOURCE) $(UDPXY_PATCHES) make/udpxy.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UDPXY_DIR) $(@D)
	$(UDPXY_UNZIP) $(DL_DIR)/$(UDPXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UDPXY_PATCHES)" ; \
		then cat $(UDPXY_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(UDPXY_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(UDPXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UDPXY_DIR) $(@D) ; \
	fi
	mv -f $(@D)/chipmunk/* $(@D)
	#sometimes a large buffer is required to get decent video quality
	sed -i -e 's|^static const ssize_t MAX_MCACHE_LEN    = 2048 |static const ssize_t MAX_MCACHE_LEN    = 20480 |' $(@D)/uopt.h 
	#$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

udpxy-unpack: $(UDPXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UDPXY_BUILD_DIR)/.built: $(UDPXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CC=$(TARGET_CC) \
		CFLAGS="$(STAGING_CPPFLAGS) $(UDPXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UDPXY_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
udpxy: $(UDPXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UDPXY_BUILD_DIR)/.staged: $(UDPXY_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) install
	touch $@

udpxy-stage: $(UDPXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/udpxy
#
$(UDPXY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: udpxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UDPXY_PRIORITY)" >>$@
	@echo "Section: $(UDPXY_SECTION)" >>$@
	@echo "Version: $(UDPXY_VERSION)-$(UDPXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UDPXY_MAINTAINER)" >>$@
	@echo "Source: $(UDPXY_REPOSITORY)" >>$@
	@echo "Description: $(UDPXY_DESCRIPTION)" >>$@
	@echo "Depends: $(UDPXY_DEPENDS)" >>$@
	@echo "Suggests: $(UDPXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(UDPXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/udpxy/...
# Documentation files should be installed in $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/doc/udpxy/...
# Daemon startup scripts should be installed in $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??udpxy
#
# You may need to patch your application to make it use these locations.
#
$(UDPXY_IPK): $(UDPXY_BUILD_DIR)/.built
	rm -rf $(UDPXY_IPK_DIR) $(BUILD_DIR)/udpxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UDPXY_BUILD_DIR) install \
		INSTALLROOT=$(UDPXY_IPK_DIR)$(TARGET_PREFIX) \
		MANPAGE_DIR=$(UDPXY_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(STRIP_COMMAND) $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/bin/{udpxy,udpxrec}
#	$(INSTALL) -d $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(UDPXY_SOURCE_DIR)/udpxy.conf $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/udpxy.conf
	$(INSTALL) -d $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(UDPXY_SOURCE_DIR)/rc.udpxy $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S29udpxy
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDPXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXudpxy
	$(MAKE) $(UDPXY_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(UDPXY_SOURCE_DIR)/postinst $(UDPXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDPXY_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(UDPXY_SOURCE_DIR)/prerm $(UDPXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDPXY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(UDPXY_IPK_DIR)/CONTROL/postinst $(UDPXY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(UDPXY_CONFFILES) | sed -e 's/ /\n/g' > $(UDPXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UDPXY_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(UDPXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
udpxy-ipk: $(UDPXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
udpxy-clean:
	rm -f $(UDPXY_BUILD_DIR)/.built
	-$(MAKE) -C $(UDPXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
udpxy-dirclean:
	rm -rf $(BUILD_DIR)/$(UDPXY_DIR) $(UDPXY_BUILD_DIR) $(UDPXY_IPK_DIR) $(UDPXY_IPK)
#
#
# Some sanity check for the package.
#
udpxy-check: $(UDPXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
