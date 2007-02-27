###########################################################
#
# multitail
#
###########################################################
#
# MULTITAIL_VERSION, MULTITAIL_SITE and MULTITAIL_SOURCE define
# the upstream location of the source code for the package.
# MULTITAIL_DIR is the directory which is created when the source
# archive is unpacked.
# MULTITAIL_UNZIP is the command used to unzip the source.
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
MULTITAIL_SITE=http://www.vanheusden.com/multitail
MULTITAIL_VERSION=4.3.1
MULTITAIL_SOURCE=multitail-$(MULTITAIL_VERSION).tgz
MULTITAIL_DIR=multitail-$(MULTITAIL_VERSION)
MULTITAIL_UNZIP=zcat
MULTITAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MULTITAIL_DESCRIPTION=MultiTail follows files in style, it is tail on steroids.
MULTITAIL_SECTION=admin
MULTITAIL_PRIORITY=optional
MULTITAIL_DEPENDS=ncurses
MULTITAIL_SUGGESTS=
MULTITAIL_CONFLICTS=

#
# MULTITAIL_IPK_VERSION should be incremented when the ipk changes.
#
MULTITAIL_IPK_VERSION=1

#
# MULTITAIL_CONFFILES should be a list of user-editable files
MULTITAIL_CONFFILES=/opt/etc/multitail.conf

#
# MULTITAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MULTITAIL_PATCHES=$(MULTITAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MULTITAIL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
MULTITAIL_LDFLAGS=-lpanel -lncurses -lutil -lm

#
# MULTITAIL_BUILD_DIR is the directory in which the build is done.
# MULTITAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MULTITAIL_IPK_DIR is the directory in which the ipk is built.
# MULTITAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MULTITAIL_BUILD_DIR=$(BUILD_DIR)/multitail
MULTITAIL_SOURCE_DIR=$(SOURCE_DIR)/multitail
MULTITAIL_IPK_DIR=$(BUILD_DIR)/multitail-$(MULTITAIL_VERSION)-ipk
MULTITAIL_IPK=$(BUILD_DIR)/multitail_$(MULTITAIL_VERSION)-$(MULTITAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: multitail-source multitail-unpack multitail multitail-stage multitail-ipk multitail-clean multitail-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MULTITAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(MULTITAIL_SITE)/$(MULTITAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
multitail-source: $(DL_DIR)/$(MULTITAIL_SOURCE) $(MULTITAIL_PATCHES)

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
$(MULTITAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(MULTITAIL_SOURCE) $(MULTITAIL_PATCHES) make/multitail.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(MULTITAIL_DIR) $(MULTITAIL_BUILD_DIR)
	$(MULTITAIL_UNZIP) $(DL_DIR)/$(MULTITAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MULTITAIL_PATCHES)" ; \
		then cat $(MULTITAIL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MULTITAIL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MULTITAIL_DIR)" != "$(MULTITAIL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MULTITAIL_DIR) $(MULTITAIL_BUILD_DIR) ; \
	fi
#	(cd $(MULTITAIL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MULTITAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MULTITAIL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MULTITAIL_BUILD_DIR)/libtool
	touch $(MULTITAIL_BUILD_DIR)/.configured

multitail-unpack: $(MULTITAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MULTITAIL_BUILD_DIR)/.built: $(MULTITAIL_BUILD_DIR)/.configured
	rm -f $(MULTITAIL_BUILD_DIR)/.built
	$(MAKE) -C $(MULTITAIL_BUILD_DIR) -f makefile.cross-arm-linux \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MULTITAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MULTITAIL_LDFLAGS)" \
		CONFIG_FILE=/opt/etc/multitail.conf
	touch $(MULTITAIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
multitail: $(MULTITAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MULTITAIL_BUILD_DIR)/.staged: $(MULTITAIL_BUILD_DIR)/.built
	rm -f $(MULTITAIL_BUILD_DIR)/.staged
	$(MAKE) -C $(MULTITAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MULTITAIL_BUILD_DIR)/.staged

multitail-stage: $(MULTITAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/multitail
#
$(MULTITAIL_IPK_DIR)/CONTROL/control:
	@install -d $(MULTITAIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: multitail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MULTITAIL_PRIORITY)" >>$@
	@echo "Section: $(MULTITAIL_SECTION)" >>$@
	@echo "Version: $(MULTITAIL_VERSION)-$(MULTITAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MULTITAIL_MAINTAINER)" >>$@
	@echo "Source: $(MULTITAIL_SITE)/$(MULTITAIL_SOURCE)" >>$@
	@echo "Description: $(MULTITAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(MULTITAIL_DEPENDS)" >>$@
	@echo "Suggests: $(MULTITAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(MULTITAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MULTITAIL_IPK_DIR)/opt/sbin or $(MULTITAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MULTITAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MULTITAIL_IPK_DIR)/opt/etc/multitail/...
# Documentation files should be installed in $(MULTITAIL_IPK_DIR)/opt/doc/multitail/...
# Daemon startup scripts should be installed in $(MULTITAIL_IPK_DIR)/opt/etc/init.d/S??multitail
#
# You may need to patch your application to make it use these locations.
#
$(MULTITAIL_IPK): $(MULTITAIL_BUILD_DIR)/.built
	rm -rf $(MULTITAIL_IPK_DIR) $(BUILD_DIR)/multitail_*_$(TARGET_ARCH).ipk
	install -d $(MULTITAIL_IPK_DIR)/opt/bin
	install -m 755 $(MULTITAIL_BUILD_DIR)/multitail $(MULTITAIL_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(MULTITAIL_IPK_DIR)/opt/bin/multitail
	install -d $(MULTITAIL_IPK_DIR)/opt/etc
	install -m 644 $(MULTITAIL_BUILD_DIR)/multitail.conf $(MULTITAIL_IPK_DIR)/opt/etc/
	install -d $(MULTITAIL_IPK_DIR)/opt/man/man1
	install -m 644 $(MULTITAIL_BUILD_DIR)/multitail.1 $(MULTITAIL_IPK_DIR)/opt/man/man1/
#	install -d $(MULTITAIL_IPK_DIR)/opt/etc/
#	install -m 644 $(MULTITAIL_SOURCE_DIR)/multitail.conf $(MULTITAIL_IPK_DIR)/opt/etc/multitail.conf
#	install -d $(MULTITAIL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MULTITAIL_SOURCE_DIR)/rc.multitail $(MULTITAIL_IPK_DIR)/opt/etc/init.d/SXXmultitail
	$(MAKE) $(MULTITAIL_IPK_DIR)/CONTROL/control
#	install -m 755 $(MULTITAIL_SOURCE_DIR)/postinst $(MULTITAIL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MULTITAIL_SOURCE_DIR)/prerm $(MULTITAIL_IPK_DIR)/CONTROL/prerm
	echo $(MULTITAIL_CONFFILES) | sed -e 's/ /\n/g' > $(MULTITAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MULTITAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
multitail-ipk: $(MULTITAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
multitail-clean:
	rm -f $(MULTITAIL_BUILD_DIR)/.built
	-$(MAKE) -C $(MULTITAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
multitail-dirclean:
	rm -rf $(BUILD_DIR)/$(MULTITAIL_DIR) $(MULTITAIL_BUILD_DIR) $(MULTITAIL_IPK_DIR) $(MULTITAIL_IPK)

#
# Some sanity check for the package.
#
multitail-check: $(MULTITAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MULTITAIL_IPK)
