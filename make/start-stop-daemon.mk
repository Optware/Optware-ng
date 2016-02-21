###########################################################
#
# start-stop-daemon
#
###########################################################

# You must replace "start-stop-daemon" and "START-STOP-DAEMON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# START-STOP-DAEMON_VERSION, START-STOP-DAEMON_SITE and START-STOP-DAEMON_SOURCE define
# the upstream location of the source code for the package.
# START-STOP-DAEMON_DIR is the directory which is created when the source
# archive is unpacked.
# START-STOP-DAEMON_UNZIP is the command used to unzip the source.
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
START-STOP-DAEMON_SITE=http://ftp.debian.org/debian/pool/main/d/dpkg
START-STOP-DAEMON_VERSION=1.18.4
START-STOP-DAEMON_SOURCE=dpkg_$(START-STOP-DAEMON_VERSION).tar.xz
START-STOP-DAEMON_DIR=dpkg-$(START-STOP-DAEMON_VERSION)
START-STOP-DAEMON_UNZIP=xzcat
START-STOP-DAEMON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
START-STOP-DAEMON_DESCRIPTION=Debian dpkg utility to start and stop daemon programs.
START-STOP-DAEMON_SECTION=misc
START-STOP-DAEMON_PRIORITY=optional
START-STOP-DAEMON_DEPENDS=
START-STOP-DAEMON_SUGGESTS=
START-STOP-DAEMON_CONFLICTS=

#
# START-STOP-DAEMON_IPK_VERSION should be incremented when the ipk changes.
#
START-STOP-DAEMON_IPK_VERSION=1

#
# START-STOP-DAEMON_CONFFILES should be a list of user-editable files
#START-STOP-DAEMON_CONFFILES=$(TARGET_PREFIX)/etc/start-stop-daemon.conf $(TARGET_PREFIX)/etc/init.d/SXXstart-stop-daemon

#
# START-STOP-DAEMON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#START-STOP-DAEMON_PATCHES=$(START-STOP-DAEMON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
START-STOP-DAEMON_CPPFLAGS=
START-STOP-DAEMON_LDFLAGS=

#
# START-STOP-DAEMON_BUILD_DIR is the directory in which the build is done.
# START-STOP-DAEMON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# START-STOP-DAEMON_IPK_DIR is the directory in which the ipk is built.
# START-STOP-DAEMON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
START-STOP-DAEMON_BUILD_DIR=$(BUILD_DIR)/start-stop-daemon
START-STOP-DAEMON_SOURCE_DIR=$(SOURCE_DIR)/start-stop-daemon
START-STOP-DAEMON_IPK_DIR=$(BUILD_DIR)/start-stop-daemon-$(START-STOP-DAEMON_VERSION)-ipk
START-STOP-DAEMON_IPK=$(BUILD_DIR)/start-stop-daemon_$(START-STOP-DAEMON_VERSION)-$(START-STOP-DAEMON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: start-stop-daemon-source start-stop-daemon-unpack start-stop-daemon start-stop-daemon-stage start-stop-daemon-ipk start-stop-daemon-clean start-stop-daemon-dirclean start-stop-daemon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(START-STOP-DAEMON_SOURCE):
	$(WGET) -P $(@D) $(START-STOP-DAEMON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
start-stop-daemon-source: $(DL_DIR)/$(START-STOP-DAEMON_SOURCE) $(START-STOP-DAEMON_PATCHES)

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
$(START-STOP-DAEMON_BUILD_DIR)/.configured: $(DL_DIR)/$(START-STOP-DAEMON_SOURCE) $(START-STOP-DAEMON_PATCHES) make/start-stop-daemon.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(START-STOP-DAEMON_DIR) $(@D)
	$(START-STOP-DAEMON_UNZIP) $(DL_DIR)/$(START-STOP-DAEMON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(START-STOP-DAEMON_PATCHES)" ; \
		then cat $(START-STOP-DAEMON_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(START-STOP-DAEMON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(START-STOP-DAEMON_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(START-STOP-DAEMON_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(START-STOP-DAEMON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(START-STOP-DAEMON_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-update-alternatives \
		--without-zlib \
		--without-bz2 \
		--without-liblzma \
		--without-selinux \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

start-stop-daemon-unpack: $(START-STOP-DAEMON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(START-STOP-DAEMON_BUILD_DIR)/.built: $(START-STOP-DAEMON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/lib/compat libcompat.la
	$(MAKE) -C $(@D)/utils
	touch $@

#
# This is the build convenience target.
#
start-stop-daemon: $(START-STOP-DAEMON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(START-STOP-DAEMON_BUILD_DIR)/.staged: $(START-STOP-DAEMON_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

start-stop-daemon-stage: #$(START-STOP-DAEMON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/start-stop-daemon
#
$(START-STOP-DAEMON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: start-stop-daemon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(START-STOP-DAEMON_PRIORITY)" >>$@
	@echo "Section: $(START-STOP-DAEMON_SECTION)" >>$@
	@echo "Version: $(START-STOP-DAEMON_VERSION)-$(START-STOP-DAEMON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(START-STOP-DAEMON_MAINTAINER)" >>$@
	@echo "Source: $(START-STOP-DAEMON_SITE)/$(START-STOP-DAEMON_SOURCE)" >>$@
	@echo "Description: $(START-STOP-DAEMON_DESCRIPTION)" >>$@
	@echo "Depends: $(START-STOP-DAEMON_DEPENDS)" >>$@
	@echo "Suggests: $(START-STOP-DAEMON_SUGGESTS)" >>$@
	@echo "Conflicts: $(START-STOP-DAEMON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/sbin or $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/start-stop-daemon/...
# Documentation files should be installed in $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/doc/start-stop-daemon/...
# Daemon startup scripts should be installed in $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??start-stop-daemon
#
# You may need to patch your application to make it use these locations.
#
$(START-STOP-DAEMON_IPK): $(START-STOP-DAEMON_BUILD_DIR)/.built
	rm -rf $(START-STOP-DAEMON_IPK_DIR) $(BUILD_DIR)/start-stop-daemon_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(START-STOP-DAEMON_BUILD_DIR) DESTDIR=$(START-STOP-DAEMON_IPK_DIR) install-strip
	$(INSTALL) -d $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/sbin/
	$(STRIP_COMMAND) $(START-STOP-DAEMON_BUILD_DIR)/utils/start-stop-daemon -o \
		$(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/sbin/start-stop-daemon-start-stop-daemon
#	$(INSTALL) -d $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(START-STOP-DAEMON_SOURCE_DIR)/start-stop-daemon.conf $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/start-stop-daemon.conf
#	$(INSTALL) -d $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(START-STOP-DAEMON_SOURCE_DIR)/rc.start-stop-daemon $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXstart-stop-daemon
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(START-STOP-DAEMON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXstart-stop-daemon
	$(MAKE) $(START-STOP-DAEMON_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(START-STOP-DAEMON_SOURCE_DIR)/postinst $(START-STOP-DAEMON_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(START-STOP-DAEMON_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(START-STOP-DAEMON_SOURCE_DIR)/prerm $(START-STOP-DAEMON_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(START-STOP-DAEMON_IPK_DIR)/CONTROL/prerm
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/sbin/start-stop-daemon' 'start-stop-daemon' $(TARGET_PREFIX)/sbin/start-stop-daemon-start-stop-daemon 40" > \
		$(START-STOP-DAEMON_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'start-stop-daemon' $(TARGET_PREFIX)/sbin/start-stop-daemon-start-stop-daemon" > \
		$(START-STOP-DAEMON_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(START-STOP-DAEMON_IPK_DIR)/CONTROL/postinst $(START-STOP-DAEMON_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(START-STOP-DAEMON_CONFFILES) | sed -e 's/ /\n/g' > $(START-STOP-DAEMON_IPK_DIR)/CONTROL/conffiles
	chmod 755 $(START-STOP-DAEMON_IPK_DIR)/CONTROL/postinst
	chmod 755 $(START-STOP-DAEMON_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(START-STOP-DAEMON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
start-stop-daemon-ipk: $(START-STOP-DAEMON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
start-stop-daemon-clean:
	rm -f $(START-STOP-DAEMON_BUILD_DIR)/.built
	-$(MAKE) -C $(START-STOP-DAEMON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
start-stop-daemon-dirclean:
	rm -rf $(BUILD_DIR)/$(START-STOP-DAEMON_DIR) $(START-STOP-DAEMON_BUILD_DIR) $(START-STOP-DAEMON_IPK_DIR) $(START-STOP-DAEMON_IPK)
#
#
# Some sanity check for the package.
#
start-stop-daemon-check: $(START-STOP-DAEMON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
