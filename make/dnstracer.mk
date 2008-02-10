###########################################################
#
# dnstracer
#
###########################################################
#
# DNSTRACER_VERSION, DNSTRACER_SITE and DNSTRACER_SOURCE define
# the upstream location of the source code for the package.
# DNSTRACER_DIR is the directory which is created when the source
# archive is unpacked.
# DNSTRACER_UNZIP is the command used to unzip the source.
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
DNSTRACER_SITE=http://www.mavetju.org/download
DNSTRACER_VERSION=1.9
DNSTRACER_SOURCE=dnstracer-$(DNSTRACER_VERSION).tar.gz
DNSTRACER_DIR=dnstracer-$(DNSTRACER_VERSION)
DNSTRACER_UNZIP=zcat
DNSTRACER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DNSTRACER_DESCRIPTION=dnstracer determines where a given Domain Name Server (DNS) gets its information from, and follows the chain of DNS servers back to the servers which know the data.
DNSTRACER_SECTION=utils
DNSTRACER_PRIORITY=optional
DNSTRACER_DEPENDS=
DNSTRACER_SUGGESTS=
DNSTRACER_CONFLICTS=

#
# DNSTRACER_IPK_VERSION should be incremented when the ipk changes.
#
DNSTRACER_IPK_VERSION=1

#
# DNSTRACER_CONFFILES should be a list of user-editable files
#DNSTRACER_CONFFILES=/opt/etc/dnstracer.conf /opt/etc/init.d/SXXdnstracer

#
# DNSTRACER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DNSTRACER_PATCHES=$(DNSTRACER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DNSTRACER_CPPFLAGS=
DNSTRACER_LDFLAGS=

#
# DNSTRACER_BUILD_DIR is the directory in which the build is done.
# DNSTRACER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DNSTRACER_IPK_DIR is the directory in which the ipk is built.
# DNSTRACER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DNSTRACER_BUILD_DIR=$(BUILD_DIR)/dnstracer
DNSTRACER_SOURCE_DIR=$(SOURCE_DIR)/dnstracer
DNSTRACER_IPK_DIR=$(BUILD_DIR)/dnstracer-$(DNSTRACER_VERSION)-ipk
DNSTRACER_IPK=$(BUILD_DIR)/dnstracer_$(DNSTRACER_VERSION)-$(DNSTRACER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dnstracer-source dnstracer-unpack dnstracer dnstracer-stage dnstracer-ipk dnstracer-clean dnstracer-dirclean dnstracer-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DNSTRACER_SOURCE):
	$(WGET) -P $(DL_DIR) $(DNSTRACER_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dnstracer-source: $(DL_DIR)/$(DNSTRACER_SOURCE) $(DNSTRACER_PATCHES)

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
$(DNSTRACER_BUILD_DIR)/.configured: $(DL_DIR)/$(DNSTRACER_SOURCE) $(DNSTRACER_PATCHES) make/dnstracer.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DNSTRACER_DIR) $(@D)
	$(DNSTRACER_UNZIP) $(DL_DIR)/$(DNSTRACER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DNSTRACER_PATCHES)" ; \
		then cat $(DNSTRACER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DNSTRACER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DNSTRACER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DNSTRACER_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DNSTRACER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DNSTRACER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-ipv6 \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

dnstracer-unpack: $(DNSTRACER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DNSTRACER_BUILD_DIR)/.built: $(DNSTRACER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
dnstracer: $(DNSTRACER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DNSTRACER_BUILD_DIR)/.staged: $(DNSTRACER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

dnstracer-stage: $(DNSTRACER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dnstracer
#
$(DNSTRACER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dnstracer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DNSTRACER_PRIORITY)" >>$@
	@echo "Section: $(DNSTRACER_SECTION)" >>$@
	@echo "Version: $(DNSTRACER_VERSION)-$(DNSTRACER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DNSTRACER_MAINTAINER)" >>$@
	@echo "Source: $(DNSTRACER_SITE)/$(DNSTRACER_SOURCE)" >>$@
	@echo "Description: $(DNSTRACER_DESCRIPTION)" >>$@
	@echo "Depends: $(DNSTRACER_DEPENDS)" >>$@
	@echo "Suggests: $(DNSTRACER_SUGGESTS)" >>$@
	@echo "Conflicts: $(DNSTRACER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DNSTRACER_IPK_DIR)/opt/sbin or $(DNSTRACER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DNSTRACER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DNSTRACER_IPK_DIR)/opt/etc/dnstracer/...
# Documentation files should be installed in $(DNSTRACER_IPK_DIR)/opt/doc/dnstracer/...
# Daemon startup scripts should be installed in $(DNSTRACER_IPK_DIR)/opt/etc/init.d/S??dnstracer
#
# You may need to patch your application to make it use these locations.
#
$(DNSTRACER_IPK): $(DNSTRACER_BUILD_DIR)/.built
	rm -rf $(DNSTRACER_IPK_DIR) $(BUILD_DIR)/dnstracer_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DNSTRACER_BUILD_DIR) DESTDIR=$(DNSTRACER_IPK_DIR) install
	$(STRIP_COMMAND) $(DNSTRACER_IPK_DIR)/opt/bin/dnstracer
	$(MAKE) $(DNSTRACER_IPK_DIR)/CONTROL/control
	echo $(DNSTRACER_CONFFILES) | sed -e 's/ /\n/g' > $(DNSTRACER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DNSTRACER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dnstracer-ipk: $(DNSTRACER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dnstracer-clean:
	rm -f $(DNSTRACER_BUILD_DIR)/.built
	-$(MAKE) -C $(DNSTRACER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dnstracer-dirclean:
	rm -rf $(BUILD_DIR)/$(DNSTRACER_DIR) $(DNSTRACER_BUILD_DIR) $(DNSTRACER_IPK_DIR) $(DNSTRACER_IPK)
#
#
# Some sanity check for the package.
#
dnstracer-check: $(DNSTRACER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DNSTRACER_IPK)
