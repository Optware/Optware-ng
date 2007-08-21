###########################################################
#
# atop
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
ATOP_SITE=http://www.atconsultancy.nl/atop/packages
ATOP_VERSION=1.21
ATOP_SOURCE=atop-$(ATOP_VERSION).tar.gz
ATOP_DIR=atop-$(ATOP_VERSION)
ATOP_UNZIP=zcat
ATOP_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
ATOP_DESCRIPTION=A better top with history monitoring
ATOP_SECTION=util
ATOP_PRIORITY=optional
ATOP_DEPENDS=ncurses, zlib
ATOP_SUGGESTS=
ATOP_CONFLICTS=

#
# ATOP_IPK_VERSION should be incremented when the ipk changes.
#
ATOP_IPK_VERSION=1

#
# ATOP_CONFFILES should be a list of user-editable files
# ATOP_CONFFILES=/opt/etc/atop.conf /opt/etc/init.d/SXXatop

#
# ATOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ATOP_PATCHES=$(ATOP_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
# ATOP_CPPFLAGS=
# ATOP_LDFLAGS=

#
# ATOP_BUILD_DIR is the directory in which the build is done.
# ATOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ATOP_IPK_DIR is the directory in which the ipk is built.
# ATOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ATOP_BUILD_DIR=$(BUILD_DIR)/atop
ATOP_SOURCE_DIR=$(SOURCE_DIR)/atop
ATOP_IPK_DIR=$(BUILD_DIR)/atop-$(ATOP_VERSION)-ipk
ATOP_IPK=$(BUILD_DIR)/atop_$(ATOP_VERSION)-$(ATOP_IPK_VERSION)_$(TARGET_ARCH).ipk
ATOP_MAKEFILE_OPTWARE=$(ATOP_BUILD_DIR)/Makefile.optware

.PHONY: atop-source atop-unpack atop atop-stage atop-ipk atop-clean atop-dirclean atop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ATOP_SOURCE):
	$(WGET) -P $(DL_DIR) $(ATOP_SITE)/$(ATOP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
atop-source: $(DL_DIR)/$(ATOP_SOURCE) $(ATOP_PATCHES)

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
$(ATOP_BUILD_DIR)/.configured: $(DL_DIR)/$(ATOP_SOURCE) $(ATOP_PATCHES) make/atop.mk
	$(MAKE) ncurses-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(ATOP_DIR) $(ATOP_BUILD_DIR)
	$(ATOP_UNZIP) $(DL_DIR)/$(ATOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ATOP_PATCHES)" ; \
		then cat $(ATOP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ATOP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ATOP_DIR)" != "$(ATOP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ATOP_DIR) $(ATOP_BUILD_DIR) ; \
	fi
	echo "AR=$(TARGET_AR)" > $(ATOP_MAKEFILE_OPTWARE)
	echo "AS=$(TARGET_AS)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "LD=$(TARGET_CC) # use gcc as ld" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "NM=$(TARGET_NM)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "CC=$(TARGET_CC)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "CPP=$(TARGET_CPP)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "GCC=$(TARGET_CC)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "CXX=$(TARGET_CXX)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "RANLIB=$(TARGET_RANLIB)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "STRIP=$(TARGET_STRIP)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "OPTWARE_CFLAGS=$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/ncurses" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "OPTWARE_LDFLAGS=$(STAGING_LDFLAGS)" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "" >> $(ATOP_MAKEFILE_OPTWARE)
	echo "DESTDIR=$(ATOP_IPK_DIR)" >> $(ATOP_MAKEFILE_OPTWARE)
        
	touch $(ATOP_BUILD_DIR)/.configured

atop-unpack: $(ATOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ATOP_BUILD_DIR)/.built: $(ATOP_BUILD_DIR)/.configured
	rm -f $(ATOP_BUILD_DIR)/.built
	$(MAKE) -C $(ATOP_BUILD_DIR)
	touch $(ATOP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
atop: $(ATOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ATOP_BUILD_DIR)/.staged: $(ATOP_BUILD_DIR)/.built
	# rm -f $(ATOP_BUILD_DIR)/.staged
	# $(MAKE) -C $(ATOP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ATOP_BUILD_DIR)/.staged

atop-stage: $(ATOP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/atop
#
$(ATOP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: atop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ATOP_PRIORITY)" >>$@
	@echo "Section: $(ATOP_SECTION)" >>$@
	@echo "Version: $(ATOP_VERSION)-$(ATOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ATOP_MAINTAINER)" >>$@
	@echo "Source: $(ATOP_SITE)/$(ATOP_SOURCE)" >>$@
	@echo "Description: $(ATOP_DESCRIPTION)" >>$@
	@echo "Depends: $(ATOP_DEPENDS)" >>$@
	@echo "Suggests: $(ATOP_SUGGESTS)" >>$@
	@echo "Conflicts: $(ATOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ATOP_IPK_DIR)/opt/sbin or $(ATOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ATOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ATOP_IPK_DIR)/opt/etc/atop/...
# Documentation files should be installed in $(ATOP_IPK_DIR)/opt/doc/atop/...
# Daemon startup scripts should be installed in $(ATOP_IPK_DIR)/opt/etc/init.d/S??atop
#
# You may need to patch your application to make it use these locations.
#
$(ATOP_IPK): $(ATOP_BUILD_DIR)/.built
	mkdir -p $(ATOP_IPK_DIR)/opt
	$(MAKE) -C $(ATOP_BUILD_DIR) install
	$(TARGET_STRIP) $(ATOP_IPK_DIR)/opt/bin/atop
	# sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXatop
	$(MAKE) $(ATOP_IPK_DIR)/CONTROL/control
	# install -m 755 $(ATOP_SOURCE_DIR)/postinst $(ATOP_IPK_DIR)/CONTROL/postinst
	# sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
	# install -m 755 $(ATOP_SOURCE_DIR)/prerm $(ATOP_IPK_DIR)/CONTROL/prerm
	# sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	# echo $(ATOP_CONFFILES) | sed -e 's/ /\n/g' > $(ATOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATOP_IPK_DIR)


#
# This is called from the top level makefile to create the IPK file.
#
atop-ipk: $(ATOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
atop-clean:
	rm -f $(ATOP_BUILD_DIR)/.built
	-$(MAKE) -C $(ATOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
atop-dirclean:
	rm -rf $(BUILD_DIR)/$(ATOP_DIR) $(ATOP_BUILD_DIR) $(ATOP_IPK_DIR) $(ATOP_IPK)
#
#
# Some sanity check for the package.
#
atop-check: $(ATOP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ATOP_IPK)
