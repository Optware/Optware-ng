###########################################################
#
# esniper
#
###########################################################
# ESNIPER_VERSION, ESNIPER_SITE and ESNIPER_SOURCE define
# the upstream location of the source code for the package.
# ESNIPER_DIR is the directory which is created when the source
# archive is unpacked.
# ESNIPER_UNZIP is the command used to unzip the source.
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
ESNIPER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/esniper
ESNIPER_UPSTREAM_VERSION=2-18-1
ESNIPER_VERSION=2.18.1
ESNIPER_SOURCE=esniper-$(ESNIPER_UPSTREAM_VERSION).tgz
ESNIPER_DIR=esniper-$(ESNIPER_UPSTREAM_VERSION)
ESNIPER_UNZIP=zcat
ESNIPER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ESNIPER_DESCRIPTION=A lightweight eBay sniping tool
ESNIPER_SECTION=net
ESNIPER_PRIORITY=optional
ESNIPER_DEPENDS=openssl, libcurl
ESNIPER_SUGGESTS=
ESNIPER_CONFLICTS=

#
# ESNIPER_IPK_VERSION should be incremented when the ipk changes.
#
ESNIPER_IPK_VERSION=1

#
# ESNIPER_CONFFILES should be a list of user-editable files
#ESNIPER_CONFFILES=/opt/etc/esniper.conf /opt/etc/init.d/SXXesniper

#
# ESNIPER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# ESNIPER_PATCHES=$(ESNIPER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ESNIPER_CPPFLAGS=
ESNIPER_LDFLAGS=

#
# ESNIPER_BUILD_DIR is the directory in which the build is done.
# ESNIPER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ESNIPER_IPK_DIR is the directory in which the ipk is built.
# ESNIPER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ESNIPER_BUILD_DIR=$(BUILD_DIR)/esniper
ESNIPER_SOURCE_DIR=$(SOURCE_DIR)/esniper
ESNIPER_IPK_DIR=$(BUILD_DIR)/esniper-$(ESNIPER_VERSION)-ipk
ESNIPER_IPK=$(BUILD_DIR)/esniper_$(ESNIPER_VERSION)-$(ESNIPER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: esniper-source esniper-unpack esniper esniper-stage esniper-ipk esniper-clean esniper-dirclean esniper-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ESNIPER_SOURCE):
	$(WGET) -P $(DL_DIR) $(ESNIPER_SITE)/$(ESNIPER_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(ESNIPER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
esniper-source: $(DL_DIR)/$(ESNIPER_SOURCE) $(ESNIPER_PATCHES)

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
$(ESNIPER_BUILD_DIR)/.configured: $(DL_DIR)/$(ESNIPER_SOURCE) $(ESNIPER_PATCHES) make/esniper.mk
	$(MAKE) openssl-stage libcurl-stage
	rm -rf $(BUILD_DIR)/$(ESNIPER_DIR) $(ESNIPER_BUILD_DIR)
	$(ESNIPER_UNZIP) $(DL_DIR)/$(ESNIPER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ESNIPER_PATCHES)" ; \
		then cat $(ESNIPER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ESNIPER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ESNIPER_DIR)" != "$(ESNIPER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ESNIPER_DIR) $(ESNIPER_BUILD_DIR) ; \
	fi
	(cd $(ESNIPER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ESNIPER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ESNIPER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-curl-config=$(STAGING_DIR)/bin/curl-config \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(ESNIPER_BUILD_DIR)/libtool
	touch $@

esniper-unpack: $(ESNIPER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ESNIPER_BUILD_DIR)/.built: $(ESNIPER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(ESNIPER_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
esniper: $(ESNIPER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ESNIPER_BUILD_DIR)/.staged: $(ESNIPER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(ESNIPER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

esniper-stage: $(ESNIPER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/esniper
#
$(ESNIPER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: esniper" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ESNIPER_PRIORITY)" >>$@
	@echo "Section: $(ESNIPER_SECTION)" >>$@
	@echo "Version: $(ESNIPER_VERSION)-$(ESNIPER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ESNIPER_MAINTAINER)" >>$@
	@echo "Source: $(ESNIPER_SITE)/$(ESNIPER_SOURCE)" >>$@
	@echo "Description: $(ESNIPER_DESCRIPTION)" >>$@
	@echo "Depends: $(ESNIPER_DEPENDS)" >>$@
	@echo "Suggests: $(ESNIPER_SUGGESTS)" >>$@
	@echo "Conflicts: $(ESNIPER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ESNIPER_IPK_DIR)/opt/sbin or $(ESNIPER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ESNIPER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ESNIPER_IPK_DIR)/opt/etc/esniper/...
# Documentation files should be installed in $(ESNIPER_IPK_DIR)/opt/doc/esniper/...
# Daemon startup scripts should be installed in $(ESNIPER_IPK_DIR)/opt/etc/init.d/S??esniper
#
# You may need to patch your application to make it use these locations.
#
$(ESNIPER_IPK): $(ESNIPER_BUILD_DIR)/.built
	rm -rf $(ESNIPER_IPK_DIR) $(BUILD_DIR)/esniper_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ESNIPER_BUILD_DIR) DESTDIR=$(ESNIPER_IPK_DIR) install-strip
	install -d $(ESNIPER_IPK_DIR)/opt/etc/
	$(MAKE) $(ESNIPER_IPK_DIR)/CONTROL/control
#	echo $(ESNIPER_CONFFILES) | sed -e 's/ /\n/g' > $(ESNIPER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ESNIPER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
esniper-ipk: $(ESNIPER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
esniper-clean:
	rm -f $(ESNIPER_BUILD_DIR)/.built
	-$(MAKE) -C $(ESNIPER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
esniper-dirclean:
	rm -rf $(BUILD_DIR)/$(ESNIPER_DIR) $(ESNIPER_BUILD_DIR) $(ESNIPER_IPK_DIR) $(ESNIPER_IPK)
#
#
# Some sanity check for the package.
#
esniper-check: $(ESNIPER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ESNIPER_IPK)
