###########################################################
#
# mldonkey
#
###########################################################
#
# MLDONKEY_VERSION, MLDONKEY_SITE and MLDONKEY_SOURCE define
# the upstream location of the source code for the package.
# MLDONKEY_DIR is the directory which is created when the source
# archive is unpacked.
# MLDONKEY_UNZIP is the command used to unzip the source.
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
MLDONKEY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mldonkey
MLDONKEY_VERSION=3.0.0
MLDONKEY_SOURCE=mldonkey-$(MLDONKEY_VERSION).tar.bz2
MLDONKEY_DIR=mldonkey-$(MLDONKEY_VERSION)
MLDONKEY_UNZIP=bzcat
MLDONKEY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MLDONKEY_DESCRIPTION=A multi-platform, multi-network peer-to-peer client.
MLDONKEY_SECTION=net
MLDONKEY_PRIORITY=optional
MLDONKEY_DEPENDS=zlib, bzip2, file
MLDONKEY_SUGGESTS=
MLDONKEY_CONFLICTS=

#
# MLDONKEY_IPK_VERSION should be incremented when the ipk changes.
#
MLDONKEY_IPK_VERSION=1

#
# MLDONKEY_CONFFILES should be a list of user-editable files
#MLDONKEY_CONFFILES=/opt/etc/mldonkey.conf /opt/etc/init.d/SXXmldonkey

#
# MLDONKEY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MLDONKEY_PATCHES=$(MLDONKEY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MLDONKEY_CPPFLAGS=
MLDONKEY_LDFLAGS=

#
# MLDONKEY_BUILD_DIR is the directory in which the build is done.
# MLDONKEY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MLDONKEY_IPK_DIR is the directory in which the ipk is built.
# MLDONKEY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MLDONKEY_BUILD_DIR=$(BUILD_DIR)/mldonkey
MLDONKEY_SOURCE_DIR=$(SOURCE_DIR)/mldonkey
MLDONKEY_IPK_DIR=$(BUILD_DIR)/mldonkey-$(MLDONKEY_VERSION)-ipk
MLDONKEY_IPK=$(BUILD_DIR)/mldonkey_$(MLDONKEY_VERSION)-$(MLDONKEY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MLDONKEY_SOURCE):
	$(WGET) -P $(@D) $(MLDONKEY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mldonkey-source: $(DL_DIR)/$(MLDONKEY_SOURCE) $(MLDONKEY_PATCHES)

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
$(MLDONKEY_BUILD_DIR)/.configured: $(DL_DIR)/$(MLDONKEY_SOURCE) $(MLDONKEY_PATCHES)
# make/mldonkey.mk
	$(MAKE) zlib-stage bzip2-stage
	rm -rf $(BUILD_DIR)/$(MLDONKEY_DIR) $(@D)
	$(MLDONKEY_UNZIP) $(DL_DIR)/$(MLDONKEY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MLDONKEY_PATCHES)" ; \
		then cat $(MLDONKEY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MLDONKEY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MLDONKEY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MLDONKEY_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MLDONKEY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MLDONKEY_LDFLAGS)" \
                ac_cv_prog_OCAMLOPT=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
                --disable-gd \
                --disable-gui \
                --disable-donkeysui \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mldonkey-unpack: $(MLDONKEY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MLDONKEY_BUILD_DIR)/.built: $(MLDONKEY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) byte utils.byte
	touch $@

#
# This is the build convenience target.
#
mldonkey: $(MLDONKEY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(MLDONKEY_BUILD_DIR)/.staged: $(MLDONKEY_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(MLDONKEY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#mldonkey-stage: $(MLDONKEY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mldonkey
#
$(MLDONKEY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mldonkey" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MLDONKEY_PRIORITY)" >>$@
	@echo "Section: $(MLDONKEY_SECTION)" >>$@
	@echo "Version: $(MLDONKEY_VERSION)-$(MLDONKEY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MLDONKEY_MAINTAINER)" >>$@
	@echo "Source: $(MLDONKEY_SITE)/$(MLDONKEY_SOURCE)" >>$@
	@echo "Description: $(MLDONKEY_DESCRIPTION)" >>$@
	@echo "Depends: $(MLDONKEY_DEPENDS)" >>$@
	@echo "Suggests: $(MLDONKEY_SUGGESTS)" >>$@
	@echo "Conflicts: $(MLDONKEY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MLDONKEY_IPK_DIR)/opt/sbin or $(MLDONKEY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MLDONKEY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MLDONKEY_IPK_DIR)/opt/etc/mldonkey/...
# Documentation files should be installed in $(MLDONKEY_IPK_DIR)/opt/doc/mldonkey/...
# Daemon startup scripts should be installed in $(MLDONKEY_IPK_DIR)/opt/etc/init.d/S??mldonkey
#
# You may need to patch your application to make it use these locations.
#
$(MLDONKEY_IPK): $(MLDONKEY_BUILD_DIR)/.built
	rm -rf $(MLDONKEY_IPK_DIR) $(BUILD_DIR)/mldonkey_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(MLDONKEY_BUILD_DIR) DESTDIR=$(MLDONKEY_IPK_DIR) install
	install -d $(MLDONKEY_IPK_DIR)/opt/bin
	for f in mlnet copysources get_range make_torrent mld_hash subconv; \
		do install $(MLDONKEY_BUILD_DIR)/$${f}.byte $(MLDONKEY_IPK_DIR)/opt/bin/; done
	for l in mlslsk mldonkey mlgnut mldc mlbt; \
		do ln -s mlnet.byte $(MLDONKEY_IPK_DIR)/opt/bin/$${l}.byte; done
	$(MAKE) $(MLDONKEY_IPK_DIR)/CONTROL/control
	echo $(MLDONKEY_CONFFILES) | sed -e 's/ /\n/g' > $(MLDONKEY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MLDONKEY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mldonkey-ipk: $(MLDONKEY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mldonkey-clean:
	rm -f $(MLDONKEY_BUILD_DIR)/.built
	-$(MAKE) -C $(MLDONKEY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mldonkey-dirclean:
	rm -rf $(BUILD_DIR)/$(MLDONKEY_DIR) $(MLDONKEY_BUILD_DIR) $(MLDONKEY_IPK_DIR) $(MLDONKEY_IPK)
