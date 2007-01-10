###########################################################
#
# liba52
#
###########################################################
#
# LIBA52_VERSION, LIBA52_SITE and LIBA52_SOURCE define
# the upstream location of the source code for the package.
# LIBA52_DIR is the directory which is created when the source
# archive is unpacked.
# LIBA52_UNZIP is the command used to unzip the source.
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
LIBA52_SITE=http://liba52.sourceforge.net/files
LIBA52_VERSION=0.7.4
LIBA52_SOURCE=a52dec-$(LIBA52_VERSION).tar.gz
LIBA52_DIR=a52dec-$(LIBA52_VERSION)
LIBA52_UNZIP=zcat
LIBA52_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBA52_DESCRIPTION=a free ATSC A/52 stream decoder.
LIBA52_SECTION=audio
LIBA52_PRIORITY=optional
LIBA52_DEPENDS=
LIBA52_SUGGESTS=
LIBA52_CONFLICTS=

#
# LIBA52_IPK_VERSION should be incremented when the ipk changes.
#
LIBA52_IPK_VERSION=1

#
# LIBA52_CONFFILES should be a list of user-editable files
#LIBA52_CONFFILES=/opt/etc/liba52.conf /opt/etc/init.d/SXXliba52

#
# LIBA52_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBA52_PATCHES=$(LIBA52_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBA52_CPPFLAGS=
LIBA52_LDFLAGS=

#
# LIBA52_BUILD_DIR is the directory in which the build is done.
# LIBA52_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBA52_IPK_DIR is the directory in which the ipk is built.
# LIBA52_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBA52_BUILD_DIR=$(BUILD_DIR)/liba52
LIBA52_SOURCE_DIR=$(SOURCE_DIR)/liba52
LIBA52_IPK_DIR=$(BUILD_DIR)/liba52-$(LIBA52_VERSION)-ipk
LIBA52_IPK=$(BUILD_DIR)/liba52_$(LIBA52_VERSION)-$(LIBA52_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: liba52-source liba52-unpack liba52 liba52-stage liba52-ipk liba52-clean liba52-dirclean liba52-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBA52_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBA52_SITE)/$(LIBA52_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
liba52-source: $(DL_DIR)/$(LIBA52_SOURCE) $(LIBA52_PATCHES)

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
$(LIBA52_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBA52_SOURCE) $(LIBA52_PATCHES) make/liba52.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBA52_DIR) $(LIBA52_BUILD_DIR)
	$(LIBA52_UNZIP) $(DL_DIR)/$(LIBA52_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBA52_PATCHES)" ; \
		then cat $(LIBA52_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBA52_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBA52_DIR)" != "$(LIBA52_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBA52_DIR) $(LIBA52_BUILD_DIR) ; \
	fi
	(cd $(LIBA52_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBA52_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBA52_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBA52_BUILD_DIR)/libtool
	touch $@

liba52-unpack: $(LIBA52_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBA52_BUILD_DIR)/.built: $(LIBA52_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBA52_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
liba52: $(LIBA52_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBA52_BUILD_DIR)/.staged: $(LIBA52_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBA52_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

liba52-stage: $(LIBA52_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/liba52
#
$(LIBA52_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: liba52" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBA52_PRIORITY)" >>$@
	@echo "Section: $(LIBA52_SECTION)" >>$@
	@echo "Version: $(LIBA52_VERSION)-$(LIBA52_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBA52_MAINTAINER)" >>$@
	@echo "Source: $(LIBA52_SITE)/$(LIBA52_SOURCE)" >>$@
	@echo "Description: $(LIBA52_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBA52_DEPENDS)" >>$@
	@echo "Suggests: $(LIBA52_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBA52_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBA52_IPK_DIR)/opt/sbin or $(LIBA52_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBA52_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBA52_IPK_DIR)/opt/etc/liba52/...
# Documentation files should be installed in $(LIBA52_IPK_DIR)/opt/doc/liba52/...
# Daemon startup scripts should be installed in $(LIBA52_IPK_DIR)/opt/etc/init.d/S??liba52
#
# You may need to patch your application to make it use these locations.
#
$(LIBA52_IPK): $(LIBA52_BUILD_DIR)/.built
	rm -rf $(LIBA52_IPK_DIR) $(BUILD_DIR)/liba52_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBA52_BUILD_DIR) DESTDIR=$(LIBA52_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBA52_IPK_DIR)/opt/bin/a52dec \
		$(LIBA52_IPK_DIR)/opt/bin/extract_a52 \
		$(LIBA52_IPK_DIR)/opt/lib/liba52.so.[0-9].[0-9].[0-9]
	$(MAKE) $(LIBA52_IPK_DIR)/CONTROL/control
#	echo $(LIBA52_CONFFILES) | sed -e 's/ /\n/g' > $(LIBA52_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBA52_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
liba52-ipk: $(LIBA52_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
liba52-clean:
	rm -f $(LIBA52_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBA52_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
liba52-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBA52_DIR) $(LIBA52_BUILD_DIR) $(LIBA52_IPK_DIR) $(LIBA52_IPK)
#
#
# Some sanity check for the package.
#
liba52-check: $(LIBA52_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBA52_IPK)
