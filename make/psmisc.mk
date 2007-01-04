###########################################################
#
# psmisc
#
###########################################################
#
# PSMISC_VERSION, PSMISC_SITE and PSMISC_SOURCE define
# the upstream location of the source code for the package.
# PSMISC_DIR is the directory which is created when the source
# archive is unpacked.
# PSMISC_UNZIP is the command used to unzip the source.
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
PSMISC_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/psmisc
PSMISC_VERSION=21.2
PSMISC_SOURCE=psmisc-$(PSMISC_VERSION).tar.gz
PSMISC_DIR=psmisc-$(PSMISC_VERSION)
PSMISC_UNZIP=zcat
PSMISC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PSMISC_DESCRIPTION=A set of some small useful utilities that use the proc filesystem.
PSMISC_SECTION=misc
PSMISC_PRIORITY=optional
PSMISC_DEPENDS=ncurses
PSMISC_SUGGESTS=
PSMISC_CONFLICTS=

#
# PSMISC_IPK_VERSION should be incremented when the ipk changes.
#
PSMISC_IPK_VERSION=1

#
# PSMISC_CONFFILES should be a list of user-editable files
#PSMISC_CONFFILES=/opt/etc/psmisc.conf /opt/etc/init.d/SXXpsmisc

#
# PSMISC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PSMISC_PATCHES=$(PSMISC_SOURCE_DIR)/src-killall.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PSMISC_CPPFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
PSMISC_LDFLAGS=-lintl
else
PSMISC_LDFLAGS=
endif

#
# PSMISC_BUILD_DIR is the directory in which the build is done.
# PSMISC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PSMISC_IPK_DIR is the directory in which the ipk is built.
# PSMISC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PSMISC_BUILD_DIR=$(BUILD_DIR)/psmisc
PSMISC_SOURCE_DIR=$(SOURCE_DIR)/psmisc
PSMISC_IPK_DIR=$(BUILD_DIR)/psmisc-$(PSMISC_VERSION)-ipk
PSMISC_IPK=$(BUILD_DIR)/psmisc_$(PSMISC_VERSION)-$(PSMISC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: psmisc-source psmisc-unpack psmisc psmisc-stage psmisc-ipk psmisc-clean psmisc-dirclean psmisc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PSMISC_SOURCE):
	$(WGET) -P $(DL_DIR) $(PSMISC_SITE)/$(PSMISC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
psmisc-source: $(DL_DIR)/$(PSMISC_SOURCE) $(PSMISC_PATCHES)

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
$(PSMISC_BUILD_DIR)/.configured: $(DL_DIR)/$(PSMISC_SOURCE) $(PSMISC_PATCHES) make/psmisc.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(PSMISC_DIR) $(PSMISC_BUILD_DIR)
	$(PSMISC_UNZIP) $(DL_DIR)/$(PSMISC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PSMISC_PATCHES)" ; \
		then cat $(PSMISC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PSMISC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PSMISC_DIR)" != "$(PSMISC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PSMISC_DIR) $(PSMISC_BUILD_DIR) ; \
	fi
	sed -ie 's|/usr/share/locale|/opt/share/locale|' $(PSMISC_BUILD_DIR)/src/Makefile.in
	(cd $(PSMISC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PSMISC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PSMISC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(PSMISC_BUILD_DIR)/libtool
	touch $@

psmisc-unpack: $(PSMISC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PSMISC_BUILD_DIR)/.built: $(PSMISC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PSMISC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
psmisc: $(PSMISC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PSMISC_BUILD_DIR)/.staged: $(PSMISC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PSMISC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

psmisc-stage: $(PSMISC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/psmisc
#
$(PSMISC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: psmisc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PSMISC_PRIORITY)" >>$@
	@echo "Section: $(PSMISC_SECTION)" >>$@
	@echo "Version: $(PSMISC_VERSION)-$(PSMISC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PSMISC_MAINTAINER)" >>$@
	@echo "Source: $(PSMISC_SITE)/$(PSMISC_SOURCE)" >>$@
	@echo "Description: $(PSMISC_DESCRIPTION)" >>$@
	@echo "Depends: $(PSMISC_DEPENDS)" >>$@
	@echo "Suggests: $(PSMISC_SUGGESTS)" >>$@
	@echo "Conflicts: $(PSMISC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PSMISC_IPK_DIR)/opt/sbin or $(PSMISC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PSMISC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PSMISC_IPK_DIR)/opt/etc/psmisc/...
# Documentation files should be installed in $(PSMISC_IPK_DIR)/opt/doc/psmisc/...
# Daemon startup scripts should be installed in $(PSMISC_IPK_DIR)/opt/etc/init.d/S??psmisc
#
# You may need to patch your application to make it use these locations.
#
$(PSMISC_IPK): $(PSMISC_BUILD_DIR)/.built
	rm -rf $(PSMISC_IPK_DIR) $(BUILD_DIR)/psmisc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PSMISC_BUILD_DIR) DESTDIR=$(PSMISC_IPK_DIR) install-strip
#	install -d $(PSMISC_IPK_DIR)/opt/etc/
#	install -m 644 $(PSMISC_SOURCE_DIR)/psmisc.conf $(PSMISC_IPK_DIR)/opt/etc/psmisc.conf
#	install -d $(PSMISC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PSMISC_SOURCE_DIR)/rc.psmisc $(PSMISC_IPK_DIR)/opt/etc/init.d/SXXpsmisc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXpsmisc
	$(MAKE) $(PSMISC_IPK_DIR)/CONTROL/control
#	install -m 755 $(PSMISC_SOURCE_DIR)/postinst $(PSMISC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PSMISC_SOURCE_DIR)/prerm $(PSMISC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(PSMISC_CONFFILES) | sed -e 's/ /\n/g' > $(PSMISC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PSMISC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
psmisc-ipk: $(PSMISC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
psmisc-clean:
	rm -f $(PSMISC_BUILD_DIR)/.built
	-$(MAKE) -C $(PSMISC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
psmisc-dirclean:
	rm -rf $(BUILD_DIR)/$(PSMISC_DIR) $(PSMISC_BUILD_DIR) $(PSMISC_IPK_DIR) $(PSMISC_IPK)
#
#
# Some sanity check for the package.
#
psmisc-check: $(PSMISC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PSMISC_IPK)
