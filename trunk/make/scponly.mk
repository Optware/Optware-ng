###########################################################
#
# scponly
#
###########################################################
#
# $Id$
#
SCPONLY_SITE=http://sublimation.org/scponly
SCPONLY_VERSION=4.6
SCPONLY_SOURCE=scponly-$(SCPONLY_VERSION).tgz
SCPONLY_DIR=scponly-$(SCPONLY_VERSION)
SCPONLY_UNZIP=zcat
SCPONLY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SCPONLY_DESCRIPTION=A shell for users with scp/sftp only access
SCPONLY_SECTION=shell
SCPONLY_PRIORITY=optional
SCPONLY_DEPENDS=
SCPONLY_SUGGESTS=
SCPONLY_CONFLICTS=

#
# SCPONLY_IPK_VERSION should be incremented when the ipk changes.
#
SCPONLY_IPK_VERSION=6

#
# SCPONLY_CONFFILES should be a list of user-editable files
# SCPONLY_CONFFILES=/opt/etc/scponly.conf /opt/etc/init.d/SXXscponly

#
# SCPONLY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# SCPONLY_PATCHES=$(SCPONLY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCPONLY_CPPFLAGS=
SCPONLY_LDFLAGS=

#
# SCPONLY_BUILD_DIR is the directory in which the build is done.
# SCPONLY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCPONLY_IPK_DIR is the directory in which the ipk is built.
# SCPONLY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCPONLY_BUILD_DIR=$(BUILD_DIR)/scponly
SCPONLY_SOURCE_DIR=$(SOURCE_DIR)/scponly
SCPONLY_IPK_DIR=$(BUILD_DIR)/scponly-$(SCPONLY_VERSION)-ipk
SCPONLY_IPK=$(BUILD_DIR)/scponly_$(SCPONLY_VERSION)-$(SCPONLY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: scponly-source scponly-unpack scponly scponly-stage scponly-ipk scponly-clean scponly-dirclean scponly-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCPONLY_SOURCE):
	$(WGET) -P $(DL_DIR) $(SCPONLY_SITE)/$(SCPONLY_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SCPONLY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
scponly-source: $(DL_DIR)/$(SCPONLY_SOURCE) $(SCPONLY_PATCHES)

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
$(SCPONLY_BUILD_DIR)/.configured: $(DL_DIR)/$(SCPONLY_SOURCE) $(SCPONLY_PATCHES) make/scponly.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SCPONLY_DIR) $(SCPONLY_BUILD_DIR)
	$(SCPONLY_UNZIP) $(DL_DIR)/$(SCPONLY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SCPONLY_PATCHES)" ; \
		then cat $(SCPONLY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SCPONLY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SCPONLY_DIR)" != "$(SCPONLY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SCPONLY_DIR) $(SCPONLY_BUILD_DIR) ; \
	fi
	cp -f $(SOURCE_DIR)/common/config.* $(SCPONLY_BUILD_DIR)/
#
# Rsync isn't working yet!
#		--enable-rsync-compat \
#
# NOTE
# 	The sed is used to force the path for the sftp-server.
# 	Otherwise configure uses the path it finds on the build system!
#
	(cd $(SCPONLY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SCPONLY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SCPONLY_LDFLAGS)" \
		ac_cv_path_scponly_PROG_SCP=/opt/bin/scp \
		ac_cv_path_scponly_PROG_GROUPS=/opt/bin/groups \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-winscp-compat \
		--enable-sftp-logging-compat \
		--enable-scp-compat \
		--enable-chrooted-binary \
		--with-sftp-server=/usr/libexec/sftp-server; \
		sed -i 's@#define PROG_SFTP_SERVER ".*"@#define PROG_SFTP_SERVER "/usr/libexec/sftp-server"@' config.h \
	)
	# $(PATCH_LIBTOOL) $(SCPONLY_BUILD_DIR)/libtool
	touch $@

scponly-unpack: $(SCPONLY_BUILD_DIR)/.configured

#
# This uilds the actual binary.
#
$(SCPONLY_BUILD_DIR)/.built: $(SCPONLY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SCPONLY_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
scponly: $(SCPONLY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SCPONLY_BUILD_DIR)/.staged: $(SCPONLY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SCPONLY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

scponly-stage: $(SCPONLY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/scponly
#
$(SCPONLY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: scponly" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SCPONLY_PRIORITY)" >>$@
	@echo "Section: $(SCPONLY_SECTION)" >>$@
	@echo "Version: $(SCPONLY_VERSION)-$(SCPONLY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SCPONLY_MAINTAINER)" >>$@
	@echo "Source: $(SCPONLY_SITE)/$(SCPONLY_SOURCE)" >>$@
	@echo "Description: $(SCPONLY_DESCRIPTION)" >>$@
	@echo "Depends: $(SCPONLY_DEPENDS)" >>$@
	@echo "Suggests: $(SCPONLY_SUGGESTS)" >>$@
	@echo "Conflicts: $(SCPONLY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SCPONLY_IPK_DIR)/opt/sbin or $(SCPONLY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCPONLY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCPONLY_IPK_DIR)/opt/etc/scponly/...
# Documentation files should be installed in $(SCPONLY_IPK_DIR)/opt/doc/scponly/...
# Daemon startup scripts should be installed in $(SCPONLY_IPK_DIR)/opt/etc/init.d/S??scponly
#
# You may need to patch your application to make it use these locations.
#
$(SCPONLY_IPK): $(SCPONLY_BUILD_DIR)/.built
	rm -rf $(SCPONLY_IPK_DIR) $(BUILD_DIR)/scponly_*_$(TARGET_ARCH).ipk
	sed -i '/INSTALL/s/ -o 0 -g 0 / /' $(SCPONLY_BUILD_DIR)/Makefile
	$(MAKE) -C $(SCPONLY_BUILD_DIR) DESTDIR=$(SCPONLY_IPK_DIR) install
	$(STRIP_COMMAND) $(SCPONLY_IPK_DIR)/opt/*bin/*
	install -d $(SCPONLY_IPK_DIR)/opt/etc/
	install -m 755 $(SCPONLY_SOURCE_DIR)/mkscproot $(SCPONLY_IPK_DIR)/opt/sbin/mkscproot
#	install -m 644 $(SCPONLY_SOURCE_DIR)/scponly.conf $(SCPONLY_IPK_DIR)/opt/etc/scponly.conf
#	install -d $(SCPONLY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SCPONLY_SOURCE_DIR)/rc.scponly $(SCPONLY_IPK_DIR)/opt/etc/init.d/SXXscponly
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCPONLY_IPK_DIR)/opt/etc/init.d/SXXscponly
	$(MAKE) $(SCPONLY_IPK_DIR)/CONTROL/control
#	install -m 755 $(SCPONLY_SOURCE_DIR)/postinst $(SCPONLY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCPONLY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SCPONLY_SOURCE_DIR)/prerm $(SCPONLY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCPONLY_IPK_DIR)/CONTROL/prerm
	echo $(SCPONLY_CONFFILES) | sed -e 's/ /\n/g' > $(SCPONLY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCPONLY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
scponly-ipk: $(SCPONLY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
scponly-clean:
	rm -f $(SCPONLY_BUILD_DIR)/.built
	-$(MAKE) -C $(SCPONLY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
scponly-dirclean:
	rm -rf $(BUILD_DIR)/$(SCPONLY_DIR) $(SCPONLY_BUILD_DIR) $(SCPONLY_IPK_DIR) $(SCPONLY_IPK)
#
#
# Some sanity check for the package.
#
scponly-check: $(SCPONLY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SCPONLY_IPK)
