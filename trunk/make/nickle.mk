###########################################################
#
# nickle
#
###########################################################
#
# NICKLE_VERSION, NICKLE_SITE and NICKLE_SOURCE define
# the upstream location of the source code for the package.
# NICKLE_DIR is the directory which is created when the source
# archive is unpacked.
# NICKLE_UNZIP is the command used to unzip the source.
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
NICKLE_SITE=http://nickle.org/release
NICKLE_VERSION=2.58
NICKLE_SOURCE=nickle-$(NICKLE_VERSION).tar.gz
NICKLE_DIR=nickle-$(NICKLE_VERSION)
NICKLE_UNZIP=zcat
NICKLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NICKLE_DESCRIPTION=Nickle, a powerful desktop calculator language. Nickle supports many features of advanced languages, as well as arbitrary precision numbers.
NICKLE_SECTION=lang
NICKLE_PRIORITY=optional
NICKLE_DEPENDS=ncurses, readline
NICKLE_SUGGESTS=
NICKLE_CONFLICTS=

#
# NICKLE_IPK_VERSION should be incremented when the ipk changes.
#
NICKLE_IPK_VERSION=1

#
# NICKLE_CONFFILES should be a list of user-editable files
#NICKLE_CONFFILES=/opt/etc/nickle.conf /opt/etc/init.d/SXXnickle

#
# NICKLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NICKLE_PATCHES=$(NICKLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NICKLE_CPPFLAGS=
NICKLE_LDFLAGS=

#
# NICKLE_BUILD_DIR is the directory in which the build is done.
# NICKLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NICKLE_IPK_DIR is the directory in which the ipk is built.
# NICKLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NICKLE_BUILD_DIR=$(BUILD_DIR)/nickle
NICKLE_SOURCE_DIR=$(SOURCE_DIR)/nickle
NICKLE_IPK_DIR=$(BUILD_DIR)/nickle-$(NICKLE_VERSION)-ipk
NICKLE_IPK=$(BUILD_DIR)/nickle_$(NICKLE_VERSION)-$(NICKLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nickle-source nickle-unpack nickle nickle-stage nickle-ipk nickle-clean nickle-dirclean nickle-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NICKLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(NICKLE_SITE)/$(NICKLE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NICKLE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nickle-source: $(DL_DIR)/$(NICKLE_SOURCE) $(NICKLE_PATCHES)

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
$(NICKLE_BUILD_DIR)/.configured: $(DL_DIR)/$(NICKLE_SOURCE) $(NICKLE_PATCHES) make/nickle.mk
	$(MAKE) ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(NICKLE_DIR) $(NICKLE_BUILD_DIR)
	$(NICKLE_UNZIP) $(DL_DIR)/$(NICKLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NICKLE_PATCHES)" ; \
		then cat $(NICKLE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NICKLE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NICKLE_DIR)" != "$(NICKLE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NICKLE_DIR) $(NICKLE_BUILD_DIR) ; \
	fi
	if test `$(TARGET_CC) -dumpversion | sed 's/\..*//'` -lt 4; then \
		sed -i -e 's/ -fwrapv//' $(NICKLE_BUILD_DIR)/Makefile.in; \
	fi
	(cd $(NICKLE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NICKLE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NICKLE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(NICKLE_BUILD_DIR)/libtool
	touch $@

nickle-unpack: $(NICKLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NICKLE_BUILD_DIR)/.built: $(NICKLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NICKLE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
nickle: $(NICKLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NICKLE_BUILD_DIR)/.staged: $(NICKLE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NICKLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

nickle-stage: $(NICKLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nickle
#
$(NICKLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nickle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NICKLE_PRIORITY)" >>$@
	@echo "Section: $(NICKLE_SECTION)" >>$@
	@echo "Version: $(NICKLE_VERSION)-$(NICKLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NICKLE_MAINTAINER)" >>$@
	@echo "Source: $(NICKLE_SITE)/$(NICKLE_SOURCE)" >>$@
	@echo "Description: $(NICKLE_DESCRIPTION)" >>$@
	@echo "Depends: $(NICKLE_DEPENDS)" >>$@
	@echo "Suggests: $(NICKLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(NICKLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NICKLE_IPK_DIR)/opt/sbin or $(NICKLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NICKLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NICKLE_IPK_DIR)/opt/etc/nickle/...
# Documentation files should be installed in $(NICKLE_IPK_DIR)/opt/doc/nickle/...
# Daemon startup scripts should be installed in $(NICKLE_IPK_DIR)/opt/etc/init.d/S??nickle
#
# You may need to patch your application to make it use these locations.
#
$(NICKLE_IPK): $(NICKLE_BUILD_DIR)/.built
	rm -rf $(NICKLE_IPK_DIR) $(BUILD_DIR)/nickle_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NICKLE_BUILD_DIR) DESTDIR=$(NICKLE_IPK_DIR) install-strip
#	install -d $(NICKLE_IPK_DIR)/opt/etc/
#	install -m 644 $(NICKLE_SOURCE_DIR)/nickle.conf $(NICKLE_IPK_DIR)/opt/etc/nickle.conf
#	install -d $(NICKLE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NICKLE_SOURCE_DIR)/rc.nickle $(NICKLE_IPK_DIR)/opt/etc/init.d/SXXnickle
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NICKLE_IPK_DIR)/opt/etc/init.d/SXXnickle
	$(MAKE) $(NICKLE_IPK_DIR)/CONTROL/control
#	install -m 755 $(NICKLE_SOURCE_DIR)/postinst $(NICKLE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NICKLE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NICKLE_SOURCE_DIR)/prerm $(NICKLE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NICKLE_IPK_DIR)/CONTROL/prerm
	echo $(NICKLE_CONFFILES) | sed -e 's/ /\n/g' > $(NICKLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NICKLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nickle-ipk: $(NICKLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nickle-clean:
	rm -f $(NICKLE_BUILD_DIR)/.built
	-$(MAKE) -C $(NICKLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nickle-dirclean:
	rm -rf $(BUILD_DIR)/$(NICKLE_DIR) $(NICKLE_BUILD_DIR) $(NICKLE_IPK_DIR) $(NICKLE_IPK)
#
#
# Some sanity check for the package.
#
nickle-check: $(NICKLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NICKLE_IPK)
