###########################################################
#
# dump
#
###########################################################
#
# DUMP_VERSION, DUMP_SITE and DUMP_SOURCE define
# the upstream location of the source code for the package.
# DUMP_DIR is the directory which is created when the source
# archive is unpacked.
# DUMP_UNZIP is the command used to unzip the source.
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
DUMP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dump
DUMP_VERSION=0.4b41
DUMP_SOURCE=dump-$(DUMP_VERSION).tar.gz
DUMP_DIR=dump-$(DUMP_VERSION)
DUMP_UNZIP=zcat
DUMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DUMP_DESCRIPTION=Dump/Restore ext2/ext3 filesystem backup
DUMP_SECTION=misc
DUMP_PRIORITY=optional
DUMP_DEPENDS=zlib, bzip2, readline
DUMP_SUGGESTS=
DUMP_CONFLICTS=

#
# DUMP_IPK_VERSION should be incremented when the ipk changes.
#
DUMP_IPK_VERSION=1

#
# DUMP_CONFFILES should be a list of user-editable files
#DUMP_CONFFILES=/opt/etc/dump.conf /opt/etc/init.d/SXXdump

#
# DUMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DUMP_PATCHES=$(DUMP_SOURCE_DIR)/mainc-uclibc.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DUMP_CPPFLAGS=
DUMP_LDFLAGS=

#
# DUMP_BUILD_DIR is the directory in which the build is done.
# DUMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DUMP_IPK_DIR is the directory in which the ipk is built.
# DUMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DUMP_BUILD_DIR=$(BUILD_DIR)/dump
DUMP_SOURCE_DIR=$(SOURCE_DIR)/dump
DUMP_IPK_DIR=$(BUILD_DIR)/dump-$(DUMP_VERSION)-ipk
DUMP_IPK=$(BUILD_DIR)/dump_$(DUMP_VERSION)-$(DUMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dump-source dump-unpack dump dump-stage dump-ipk dump-clean dump-dirclean dump-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DUMP_SOURCE):
	$(WGET) -P $(DL_DIR) $(DUMP_SITE)/$(DUMP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dump-source: $(DL_DIR)/$(DUMP_SOURCE) $(DUMP_PATCHES)

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
$(DUMP_BUILD_DIR)/.configured: $(DL_DIR)/$(DUMP_SOURCE) $(DUMP_PATCHES) make/dump.mk
	$(MAKE) bzip2-stage e2fsprogs-stage readline-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(DUMP_DIR) $(DUMP_BUILD_DIR)
	$(DUMP_UNZIP) $(DL_DIR)/$(DUMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DUMP_PATCHES)" ; \
		then cat $(DUMP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DUMP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DUMP_DIR)" != "$(DUMP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DUMP_DIR) $(DUMP_BUILD_DIR) ; \
	fi
	(cd $(DUMP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DUMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DUMP_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		PKG_CONFIG_LIBDIR=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
#	$(PATCH_LIBTOOL) $(DUMP_BUILD_DIR)/libtool
	touch $(DUMP_BUILD_DIR)/.configured

dump-unpack: $(DUMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DUMP_BUILD_DIR)/.built: $(DUMP_BUILD_DIR)/.configured
	rm -f $(DUMP_BUILD_DIR)/.built
	$(MAKE) -C $(DUMP_BUILD_DIR) LD=$(TARGET_CC)
	touch $(DUMP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dump: $(DUMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DUMP_BUILD_DIR)/.staged: $(DUMP_BUILD_DIR)/.built
	rm -f $(DUMP_BUILD_DIR)/.staged
	$(MAKE) -C $(DUMP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(DUMP_BUILD_DIR)/.staged

dump-stage: $(DUMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dump
#
$(DUMP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dump" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DUMP_PRIORITY)" >>$@
	@echo "Section: $(DUMP_SECTION)" >>$@
	@echo "Version: $(DUMP_VERSION)-$(DUMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DUMP_MAINTAINER)" >>$@
	@echo "Source: $(DUMP_SITE)/$(DUMP_SOURCE)" >>$@
	@echo "Description: $(DUMP_DESCRIPTION)" >>$@
	@echo "Depends: $(DUMP_DEPENDS)" >>$@
	@echo "Suggests: $(DUMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(DUMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DUMP_IPK_DIR)/opt/sbin or $(DUMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DUMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DUMP_IPK_DIR)/opt/etc/dump/...
# Documentation files should be installed in $(DUMP_IPK_DIR)/opt/doc/dump/...
# Daemon startup scripts should be installed in $(DUMP_IPK_DIR)/opt/etc/init.d/S??dump
#
# You may need to patch your application to make it use these locations.
#
$(DUMP_IPK): $(DUMP_BUILD_DIR)/.built
	rm -rf $(DUMP_IPK_DIR) $(BUILD_DIR)/dump_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DUMP_BUILD_DIR) install \
	    prefix=$(DUMP_IPK_DIR)/opt \
	    INSTALLBIN='/usr/bin/install -m 0755' \
	    INSTALLMAN='/usr/bin/install -m 0644'
	$(STRIP_COMMAND) $(DUMP_IPK_DIR)/opt/sbin/dump $(DUMP_IPK_DIR)/opt/sbin/restore $(DUMP_IPK_DIR)/opt/sbin/rmt
	$(MAKE) $(DUMP_IPK_DIR)/CONTROL/control
	echo $(DUMP_CONFFILES) | sed -e 's/ /\n/g' > $(DUMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DUMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dump-ipk: $(DUMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dump-clean:
	rm -f $(DUMP_BUILD_DIR)/.built
	-$(MAKE) -C $(DUMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dump-dirclean:
	rm -rf $(BUILD_DIR)/$(DUMP_DIR) $(DUMP_BUILD_DIR) $(DUMP_IPK_DIR) $(DUMP_IPK)
#
#
# Some sanity check for the package.
#
dump-check: $(DUMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DUMP_IPK)
