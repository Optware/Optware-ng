###########################################################
#
# dash
#
###########################################################
#
# DASH_VERSION, DASH_SITE and DASH_SOURCE define
# the upstream location of the source code for the package.
# DASH_DIR is the directory which is created when the source
# archive is unpacked.
# DASH_UNZIP is the command used to unzip the source.
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
DASH_SITE=http://ftp.debian.org/debian/pool/main/d/dash
DASH_VERSION=0.5.3
DASH_SOURCE=dash_$(DASH_VERSION).orig.tar.gz
DASH_DIR=dash-$(DASH_VERSION)
DASH_UNZIP=zcat
DASH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DASH_DESCRIPTION=dash (Debian Almquist Shell) is a POSIX compliant shell that is much smaller than bash.
DASH_SECTION=shell
DASH_PRIORITY=optional
DASH_DEPENDS=
DASH_SUGGESTS=
DASH_CONFLICTS=

#
# DASH_IPK_VERSION should be incremented when the ipk changes.
#
DASH_IPK_VERSION=1

#
# DASH_CONFFILES should be a list of user-editable files
#DASH_CONFFILES=/opt/etc/dash.conf /opt/etc/init.d/SXXdash

#
# DASH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DASH_PATCHES=$(DASH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DASH_CPPFLAGS=
DASH_LDFLAGS=

#
# DASH_BUILD_DIR is the directory in which the build is done.
# DASH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DASH_IPK_DIR is the directory in which the ipk is built.
# DASH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DASH_BUILD_DIR=$(BUILD_DIR)/dash
DASH_SOURCE_DIR=$(SOURCE_DIR)/dash
DASH_IPK_DIR=$(BUILD_DIR)/dash-$(DASH_VERSION)-ipk
DASH_IPK=$(BUILD_DIR)/dash_$(DASH_VERSION)-$(DASH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dash-source dash-unpack dash dash-stage dash-ipk dash-clean dash-dirclean dash-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DASH_SOURCE):
	$(WGET) -P $(DL_DIR) $(DASH_SITE)/$(DASH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dash-source: $(DL_DIR)/$(DASH_SOURCE) $(DASH_PATCHES)

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
$(DASH_BUILD_DIR)/.configured: $(DL_DIR)/$(DASH_SOURCE) $(DASH_PATCHES) make/dash.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DASH_DIR) $(DASH_BUILD_DIR)
	$(DASH_UNZIP) $(DL_DIR)/$(DASH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DASH_PATCHES)" ; \
		then cat $(DASH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DASH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DASH_DIR)" != "$(DASH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DASH_DIR) $(DASH_BUILD_DIR) ; \
	fi
	(cd $(DASH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DASH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DASH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(DASH_BUILD_DIR)/libtool
	touch $(DASH_BUILD_DIR)/.configured

dash-unpack: $(DASH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DASH_BUILD_DIR)/.built: $(DASH_BUILD_DIR)/.configured
	rm -f $(DASH_BUILD_DIR)/.built
	$(MAKE) -C $(DASH_BUILD_DIR)
	touch $(DASH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dash: $(DASH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DASH_BUILD_DIR)/.staged: $(DASH_BUILD_DIR)/.built
	rm -f $(DASH_BUILD_DIR)/.staged
	$(MAKE) -C $(DASH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(DASH_BUILD_DIR)/.staged

dash-stage: $(DASH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dash
#
$(DASH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dash" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DASH_PRIORITY)" >>$@
	@echo "Section: $(DASH_SECTION)" >>$@
	@echo "Version: $(DASH_VERSION)-$(DASH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DASH_MAINTAINER)" >>$@
	@echo "Source: $(DASH_SITE)/$(DASH_SOURCE)" >>$@
	@echo "Description: $(DASH_DESCRIPTION)" >>$@
	@echo "Depends: $(DASH_DEPENDS)" >>$@
	@echo "Suggests: $(DASH_SUGGESTS)" >>$@
	@echo "Conflicts: $(DASH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DASH_IPK_DIR)/opt/sbin or $(DASH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DASH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DASH_IPK_DIR)/opt/etc/dash/...
# Documentation files should be installed in $(DASH_IPK_DIR)/opt/doc/dash/...
# Daemon startup scripts should be installed in $(DASH_IPK_DIR)/opt/etc/init.d/S??dash
#
# You may need to patch your application to make it use these locations.
#
$(DASH_IPK): $(DASH_BUILD_DIR)/.built
	rm -rf $(DASH_IPK_DIR) $(BUILD_DIR)/dash_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DASH_BUILD_DIR) DESTDIR=$(DASH_IPK_DIR) install-strip
#	install -d $(DASH_IPK_DIR)/opt/etc/
#	install -m 644 $(DASH_SOURCE_DIR)/dash.conf $(DASH_IPK_DIR)/opt/etc/dash.conf
#	install -d $(DASH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DASH_SOURCE_DIR)/rc.dash $(DASH_IPK_DIR)/opt/etc/init.d/SXXdash
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXdash
	$(MAKE) $(DASH_IPK_DIR)/CONTROL/control
#	install -m 755 $(DASH_SOURCE_DIR)/postinst $(DASH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DASH_SOURCE_DIR)/prerm $(DASH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(DASH_CONFFILES) | sed -e 's/ /\n/g' > $(DASH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DASH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dash-ipk: $(DASH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dash-clean:
	rm -f $(DASH_BUILD_DIR)/.built
	-$(MAKE) -C $(DASH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dash-dirclean:
	rm -rf $(BUILD_DIR)/$(DASH_DIR) $(DASH_BUILD_DIR) $(DASH_IPK_DIR) $(DASH_IPK)
#
#
# Some sanity check for the package.
#
dash-check: $(DASH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DASH_IPK)
