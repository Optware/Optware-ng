###########################################################
#
# recode
#
###########################################################
#
# RECODE_VERSION, RECODE_SITE and RECODE_SOURCE define
# the upstream location of the source code for the package.
# RECODE_DIR is the directory which is created when the source
# archive is unpacked.
# RECODE_UNZIP is the command used to unzip the source.
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
RECODE_SITE=http://ftp.gnu.org/pub/gnu/recode/
RECODE_VERSION=3.6
RECODE_SOURCE=recode-$(RECODE_VERSION).tar.gz
RECODE_DIR=recode-$(RECODE_VERSION)
RECODE_UNZIP=zcat
RECODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RECODE_DESCRIPTION=The recode library converts files between character sets and usages.
RECODE_SECTION=lib
RECODE_PRIORITY=optional
RECODE_DEPENDS=
RECODE_SUGGESTS=
RECODE_CONFLICTS=

#
# RECODE_IPK_VERSION should be incremented when the ipk changes.
#
RECODE_IPK_VERSION=1

#
# RECODE_CONFFILES should be a list of user-editable files
#RECODE_CONFFILES=/opt/etc/recode.conf /opt/etc/init.d/SXXrecode

#
# RECODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RECODE_PATCHES=$(RECODE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RECODE_CPPFLAGS=
RECODE_LDFLAGS=

#
# RECODE_BUILD_DIR is the directory in which the build is done.
# RECODE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RECODE_IPK_DIR is the directory in which the ipk is built.
# RECODE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RECODE_BUILD_DIR=$(BUILD_DIR)/recode
RECODE_SOURCE_DIR=$(SOURCE_DIR)/recode
RECODE_IPK_DIR=$(BUILD_DIR)/recode-$(RECODE_VERSION)-ipk
RECODE_IPK=$(BUILD_DIR)/recode_$(RECODE_VERSION)-$(RECODE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RECODE_SOURCE):
	$(WGET) -P $(DL_DIR) $(RECODE_SITE)/$(RECODE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
recode-source: $(DL_DIR)/$(RECODE_SOURCE) $(RECODE_PATCHES)

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
$(RECODE_BUILD_DIR)/.configured: $(DL_DIR)/$(RECODE_SOURCE) $(RECODE_PATCHES) make/recode.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RECODE_DIR) $(RECODE_BUILD_DIR)
	$(RECODE_UNZIP) $(DL_DIR)/$(RECODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RECODE_PATCHES)" ; \
		then cat $(RECODE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RECODE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RECODE_DIR)" != "$(RECODE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RECODE_DIR) $(RECODE_BUILD_DIR) ; \
	fi
	(cd $(RECODE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RECODE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RECODE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(RECODE_BUILD_DIR)/libtool
	touch $(RECODE_BUILD_DIR)/.configured

recode-unpack: $(RECODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RECODE_BUILD_DIR)/.built: $(RECODE_BUILD_DIR)/.configured
	rm -f $(RECODE_BUILD_DIR)/.built
	$(MAKE) -C $(RECODE_BUILD_DIR)
	touch $(RECODE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
recode: $(RECODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RECODE_BUILD_DIR)/.staged: $(RECODE_BUILD_DIR)/.built
	rm -f $(RECODE_BUILD_DIR)/.staged
	$(MAKE) -C $(RECODE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RECODE_BUILD_DIR)/.staged

recode-stage: $(RECODE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/recode
#
$(RECODE_IPK_DIR)/CONTROL/control:
	@install -d $(RECODE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: recode" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RECODE_PRIORITY)" >>$@
	@echo "Section: $(RECODE_SECTION)" >>$@
	@echo "Version: $(RECODE_VERSION)-$(RECODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RECODE_MAINTAINER)" >>$@
	@echo "Source: $(RECODE_SITE)/$(RECODE_SOURCE)" >>$@
	@echo "Description: $(RECODE_DESCRIPTION)" >>$@
	@echo "Depends: $(RECODE_DEPENDS)" >>$@
	@echo "Suggests: $(RECODE_SUGGESTS)" >>$@
	@echo "Conflicts: $(RECODE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RECODE_IPK_DIR)/opt/sbin or $(RECODE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RECODE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RECODE_IPK_DIR)/opt/etc/recode/...
# Documentation files should be installed in $(RECODE_IPK_DIR)/opt/doc/recode/...
# Daemon startup scripts should be installed in $(RECODE_IPK_DIR)/opt/etc/init.d/S??recode
#
# You may need to patch your application to make it use these locations.
#
$(RECODE_IPK): $(RECODE_BUILD_DIR)/.built
	rm -rf $(RECODE_IPK_DIR) $(BUILD_DIR)/recode_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RECODE_BUILD_DIR) DESTDIR=$(RECODE_IPK_DIR) install
	$(STRIP_COMMAND) $(RECODE_IPK_DIR)/opt/bin/recode
#	install -d $(RECODE_IPK_DIR)/opt/etc/
#	install -m 644 $(RECODE_SOURCE_DIR)/recode.conf $(RECODE_IPK_DIR)/opt/etc/recode.conf
#	install -d $(RECODE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RECODE_SOURCE_DIR)/rc.recode $(RECODE_IPK_DIR)/opt/etc/init.d/SXXrecode
	$(MAKE) $(RECODE_IPK_DIR)/CONTROL/control
#	install -m 755 $(RECODE_SOURCE_DIR)/postinst $(RECODE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RECODE_SOURCE_DIR)/prerm $(RECODE_IPK_DIR)/CONTROL/prerm
	echo $(RECODE_CONFFILES) | sed -e 's/ /\n/g' > $(RECODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RECODE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
recode-ipk: $(RECODE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
recode-clean:
	rm -f $(RECODE_BUILD_DIR)/.built
	-$(MAKE) -C $(RECODE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
recode-dirclean:
	rm -rf $(BUILD_DIR)/$(RECODE_DIR) $(RECODE_BUILD_DIR) $(RECODE_IPK_DIR) $(RECODE_IPK)
