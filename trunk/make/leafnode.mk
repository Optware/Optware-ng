###########################################################
#
# leafnode
#
###########################################################
#
# LEAFNODE_VERSION, LEAFNODE_SITE and LEAFNODE_SOURCE define
# the upstream location of the source code for the package.
# LEAFNODE_DIR is the directory which is created when the source
# archive is unpacked.
# LEAFNODE_UNZIP is the command used to unzip the source.
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
LEAFNODE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/leafnode
LEAFNODE_VERSION=1.11.7
LEAFNODE_SOURCE=leafnode-$(LEAFNODE_VERSION).tar.bz2
LEAFNODE_DIR=leafnode-$(LEAFNODE_VERSION)
LEAFNODE_UNZIP=bzcat
LEAFNODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LEAFNODE_DESCRIPTION=Leafnode is a caching Usenet news proxy that enables online newsreaders to read news off-line. It is designed for zero (full-automatic) maintenance.
LEAFNODE_SECTION=news
LEAFNODE_PRIORITY=optional
LEAFNODE_DEPENDS=pcre
LEAFNODE_SUGGESTS=
LEAFNODE_CONFLICTS=

#
# LEAFNODE_IPK_VERSION should be incremented when the ipk changes.
#
LEAFNODE_IPK_VERSION=2

#
# LEAFNODE_CONFFILES should be a list of user-editable files
#LEAFNODE_CONFFILES=/opt/etc/leafnode.conf /opt/etc/init.d/SXXleafnode

#
# LEAFNODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LEAFNODE_PATCHES=$(LEAFNODE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LEAFNODE_CPPFLAGS=
LEAFNODE_LDFLAGS=

#
# LEAFNODE_BUILD_DIR is the directory in which the build is done.
# LEAFNODE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LEAFNODE_IPK_DIR is the directory in which the ipk is built.
# LEAFNODE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LEAFNODE_BUILD_DIR=$(BUILD_DIR)/leafnode
LEAFNODE_SOURCE_DIR=$(SOURCE_DIR)/leafnode
LEAFNODE_IPK_DIR=$(BUILD_DIR)/leafnode-$(LEAFNODE_VERSION)-ipk
LEAFNODE_IPK=$(BUILD_DIR)/leafnode_$(LEAFNODE_VERSION)-$(LEAFNODE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: leafnode-source leafnode-unpack leafnode leafnode-stage leafnode-ipk leafnode-clean leafnode-dirclean leafnode-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LEAFNODE_SOURCE):
	$(WGET) -P $(@D) $(LEAFNODE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
leafnode-source: $(DL_DIR)/$(LEAFNODE_SOURCE) $(LEAFNODE_PATCHES)

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
$(LEAFNODE_BUILD_DIR)/.configured: $(DL_DIR)/$(LEAFNODE_SOURCE) $(LEAFNODE_PATCHES) make/leafnode.mk
	$(MAKE) pcre-stage
	rm -rf $(BUILD_DIR)/$(LEAFNODE_DIR) $(LEAFNODE_BUILD_DIR)
	$(LEAFNODE_UNZIP) $(DL_DIR)/$(LEAFNODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LEAFNODE_PATCHES)" ; \
		then cat $(LEAFNODE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LEAFNODE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LEAFNODE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LEAFNODE_DIR) $(@D) ; \
	fi
	sed -i -e 's|\./amiroot|false|' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LEAFNODE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LEAFNODE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PCRECONFIG=$(STAGING_PREFIX)/bin/pcre-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

leafnode-unpack: $(LEAFNODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LEAFNODE_BUILD_DIR)/.built: $(LEAFNODE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
leafnode: $(LEAFNODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LEAFNODE_BUILD_DIR)/.staged: $(LEAFNODE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

leafnode-stage: $(LEAFNODE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/leafnode
#
$(LEAFNODE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: leafnode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LEAFNODE_PRIORITY)" >>$@
	@echo "Section: $(LEAFNODE_SECTION)" >>$@
	@echo "Version: $(LEAFNODE_VERSION)-$(LEAFNODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LEAFNODE_MAINTAINER)" >>$@
	@echo "Source: $(LEAFNODE_SITE)/$(LEAFNODE_SOURCE)" >>$@
	@echo "Description: $(LEAFNODE_DESCRIPTION)" >>$@
	@echo "Depends: $(LEAFNODE_DEPENDS)" >>$@
	@echo "Suggests: $(LEAFNODE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LEAFNODE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LEAFNODE_IPK_DIR)/opt/sbin or $(LEAFNODE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LEAFNODE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LEAFNODE_IPK_DIR)/opt/etc/leafnode/...
# Documentation files should be installed in $(LEAFNODE_IPK_DIR)/opt/doc/leafnode/...
# Daemon startup scripts should be installed in $(LEAFNODE_IPK_DIR)/opt/etc/init.d/S??leafnode
#
# You may need to patch your application to make it use these locations.
#
$(LEAFNODE_IPK): $(LEAFNODE_BUILD_DIR)/.built
	rm -rf $(LEAFNODE_IPK_DIR) $(BUILD_DIR)/leafnode_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LEAFNODE_BUILD_DIR) DESTDIR=$(LEAFNODE_IPK_DIR) install-strip
	$(MAKE) $(LEAFNODE_IPK_DIR)/CONTROL/control
	echo $(LEAFNODE_CONFFILES) | sed -e 's/ /\n/g' > $(LEAFNODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LEAFNODE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
leafnode-ipk: $(LEAFNODE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
leafnode-clean:
	rm -f $(LEAFNODE_BUILD_DIR)/.built
	-$(MAKE) -C $(LEAFNODE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
leafnode-dirclean:
	rm -rf $(BUILD_DIR)/$(LEAFNODE_DIR) $(LEAFNODE_BUILD_DIR) $(LEAFNODE_IPK_DIR) $(LEAFNODE_IPK)
#
#
# Some sanity check for the package.
#
leafnode-check: $(LEAFNODE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
