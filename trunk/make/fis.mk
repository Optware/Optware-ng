###########################################################
#
# fis
#
###########################################################
#
# FIS_VERSION, FIS_SITE and FIS_SOURCE define
# the upstream location of the source code for the package.
# FIS_DIR is the directory which is created when the source
# archive is unpacked.
# FIS_UNZIP is the command used to unzip the source.
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
FIS_REPOSITORY=http://svn.nslu2-linux.org/svnroot/fis/trunk
FIS_DIR=fis
FIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FIS_DESCRIPTION=Tool to edit the Redboot FIS partition layout from userspace.
FIS_SECTION=utils
FIS_PRIORITY=optional
FIS_DEPENDS=
FIS_SUGGESTS=
FIS_CONFLICTS=

FIS_SVN_TAG=6
FIS_VERSION=r${FIS_SVN_TAG}
FIS_SVN_OPTS=-r $(FIS_SVN_TAG)

#
# FIS_IPK_VERSION should be incremented when the ipk changes.
#
FIS_IPK_VERSION=2

#
# FIS_CONFFILES should be a list of user-editable files
#FIS_CONFFILES=/opt/etc/fis.conf /opt/etc/init.d/SXXfis

#
# FIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FIS_PATCHES=$(FIS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FIS_CPPFLAGS=
FIS_LDFLAGS=

#
# FIS_BUILD_DIR is the directory in which the build is done.
# FIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FIS_IPK_DIR is the directory in which the ipk is built.
# FIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FIS_BUILD_DIR=$(BUILD_DIR)/fis
FIS_SOURCE_DIR=$(SOURCE_DIR)/fis
FIS_IPK_DIR=$(BUILD_DIR)/fis-$(FIS_VERSION)-ipk
FIS_IPK=$(BUILD_DIR)/fis_$(FIS_VERSION)-$(FIS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fis-source fis-unpack fis fis-stage fis-ipk fis-clean fis-dirclean fis-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with SVN
#
$(DL_DIR)/fis-$(FIS_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(FIS_DIR) && \
		svn co $(FIS_REPOSITORY) $(FIS_SVN_OPTS) $(FIS_DIR) && \
		tar -czf $@ $(FIS_DIR) && \
		rm -rf $(FIS_DIR) \
	)

fis-source: $(DL_DIR)/fis-$(FIS_VERSION).tar.gz

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
$(FIS_BUILD_DIR)/.configured: $(DL_DIR)/fis-$(FIS_VERSION).tar.gz make/fis.mk
	rm -rf $(BUILD_DIR)/$(FIS_DIR) $(FIS_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzvf $(DL_DIR)/fis-$(FIS_VERSION).tar.gz
	if test -n "$(FIS_PATCHES)" ; \
		then cat $(FIS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FIS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FIS_DIR)" != "$(FIS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FIS_DIR) $(FIS_BUILD_DIR) ; \
	fi
	touch $@

fis-unpack: $(FIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FIS_BUILD_DIR)/.built: $(FIS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FIS_BUILD_DIR) CC=${TARGET_CC}
	touch $@

#
# This is the build convenience target.
#
fis: $(FIS_BUILD_DIR)/.built

fis-stage:

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fis
#
$(FIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FIS_PRIORITY)" >>$@
	@echo "Section: $(FIS_SECTION)" >>$@
	@echo "Version: $(FIS_VERSION)-$(FIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FIS_MAINTAINER)" >>$@
	@echo "Source: $(FIS_SITE)/$(FIS_SOURCE)" >>$@
	@echo "Description: $(FIS_DESCRIPTION)" >>$@
	@echo "Depends: $(FIS_DEPENDS)" >>$@
	@echo "Suggests: $(FIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(FIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FIS_IPK_DIR)/opt/sbin or $(FIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FIS_IPK_DIR)/opt/etc/fis/...
# Documentation files should be installed in $(FIS_IPK_DIR)/opt/doc/fis/...
# Daemon startup scripts should be installed in $(FIS_IPK_DIR)/opt/etc/init.d/S??fis
#
# You may need to patch your application to make it use these locations.
#
$(FIS_IPK): $(FIS_BUILD_DIR)/.built
	rm -rf $(FIS_IPK_DIR) $(BUILD_DIR)/fis_*_$(TARGET_ARCH).ipk
	install -d $(FIS_IPK_DIR)/opt/sbin/
	install -m 755 $(FIS_BUILD_DIR)/fis $(FIS_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(FIS_IPK_DIR)/opt/sbin/fis
	$(MAKE) $(FIS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fis-ipk: $(FIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fis-clean:
	rm -f $(FIS_BUILD_DIR)/.built
	-$(MAKE) -C $(FIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fis-dirclean:
	rm -rf $(BUILD_DIR)/$(FIS_DIR) $(FIS_BUILD_DIR) $(FIS_IPK_DIR) $(FIS_IPK)
#
#
# Some sanity check for the package.
#
fis-check: $(FIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FIS_IPK)
