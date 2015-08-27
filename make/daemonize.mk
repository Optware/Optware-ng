###########################################################
#
# daemonize
#
###########################################################
#
# DAEMONIZE_VERSION, DAEMONIZE_SITE and DAEMONIZE_SOURCE define
# the upstream location of the source code for the package.
# DAEMONIZE_DIR is the directory which is created when the source
# archive is unpacked.
# DAEMONIZE_UNZIP is the command used to unzip the source.
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
DAEMONIZE_SITE=https://github.com/bmc/daemonize/archive
DAEMONIZE_VERSION=1.7.6
DAEMONIZE_SOURCE=daemonize-release-$(DAEMONIZE_VERSION).tar.gz
DAEMONIZE_DIR=daemonize-release-$(DAEMONIZE_VERSION)
DAEMONIZE_UNZIP=zcat
DAEMONIZE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DAEMONIZE_DESCRIPTION=A tool to run a command as a daemon.
DAEMONIZE_SECTION=utilities
DAEMONIZE_PRIORITY=optional
DAEMONIZE_DEPENDS=
DAEMONIZE_SUGGESTS=
DAEMONIZE_CONFLICTS=

#
# DAEMONIZE_IPK_VERSION should be incremented when the ipk changes.
#
DAEMONIZE_IPK_VERSION=1

#
# DAEMONIZE_CONFFILES should be a list of user-editable files
#DAEMONIZE_CONFFILES=/opt/etc/daemonize.conf /opt/etc/init.d/SXXdaemonize

#
# DAEMONIZE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DAEMONIZE_PATCHES=$(DAEMONIZE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DAEMONIZE_CPPFLAGS=
DAEMONIZE_LDFLAGS=

#
# DAEMONIZE_BUILD_DIR is the directory in which the build is done.
# DAEMONIZE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DAEMONIZE_IPK_DIR is the directory in which the ipk is built.
# DAEMONIZE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DAEMONIZE_BUILD_DIR=$(BUILD_DIR)/daemonize
DAEMONIZE_SOURCE_DIR=$(SOURCE_DIR)/daemonize
DAEMONIZE_IPK_DIR=$(BUILD_DIR)/daemonize-$(DAEMONIZE_VERSION)-ipk
DAEMONIZE_IPK=$(BUILD_DIR)/daemonize_$(DAEMONIZE_VERSION)-$(DAEMONIZE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: daemonize-source daemonize-unpack daemonize daemonize-stage daemonize-ipk daemonize-clean daemonize-dirclean daemonize-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DAEMONIZE_SOURCE):
	$(WGET) -O $@ $(DAEMONIZE_SITE)/$(shell echo $(@F) | cut -d '-' -f 2-) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
daemonize-source: $(DL_DIR)/$(DAEMONIZE_SOURCE) $(DAEMONIZE_PATCHES)

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
$(DAEMONIZE_BUILD_DIR)/.configured: $(DL_DIR)/$(DAEMONIZE_SOURCE) $(DAEMONIZE_PATCHES) make/daemonize.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DAEMONIZE_DIR) $(@D)
	$(DAEMONIZE_UNZIP) $(DL_DIR)/$(DAEMONIZE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DAEMONIZE_PATCHES)" ; \
		then cat $(DAEMONIZE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DAEMONIZE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DAEMONIZE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DAEMONIZE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DAEMONIZE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DAEMONIZE_LDFLAGS)" \
		ac_cv_func_setpgrp_void=true \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

daemonize-unpack: $(DAEMONIZE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DAEMONIZE_BUILD_DIR)/.built: $(DAEMONIZE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
daemonize: $(DAEMONIZE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DAEMONIZE_BUILD_DIR)/.staged: $(DAEMONIZE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

daemonize-stage: $(DAEMONIZE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/daemonize
#
$(DAEMONIZE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: daemonize" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DAEMONIZE_PRIORITY)" >>$@
	@echo "Section: $(DAEMONIZE_SECTION)" >>$@
	@echo "Version: $(DAEMONIZE_VERSION)-$(DAEMONIZE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DAEMONIZE_MAINTAINER)" >>$@
	@echo "Source: $(DAEMONIZE_SITE)/$(shell echo $(DAEMONIZE_SOURCE) | cut -d '-' -f 2-)" >>$@
	@echo "Description: $(DAEMONIZE_DESCRIPTION)" >>$@
	@echo "Depends: $(DAEMONIZE_DEPENDS)" >>$@
	@echo "Suggests: $(DAEMONIZE_SUGGESTS)" >>$@
	@echo "Conflicts: $(DAEMONIZE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DAEMONIZE_IPK_DIR)/opt/sbin or $(DAEMONIZE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DAEMONIZE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DAEMONIZE_IPK_DIR)/opt/etc/daemonize/...
# Documentation files should be installed in $(DAEMONIZE_IPK_DIR)/opt/doc/daemonize/...
# Daemon startup scripts should be installed in $(DAEMONIZE_IPK_DIR)/opt/etc/init.d/S??daemonize
#
# You may need to patch your application to make it use these locations.
#
$(DAEMONIZE_IPK): $(DAEMONIZE_BUILD_DIR)/.built
	rm -rf $(DAEMONIZE_IPK_DIR) $(BUILD_DIR)/daemonize_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DAEMONIZE_BUILD_DIR) DESTDIR=$(DAEMONIZE_IPK_DIR) install
	$(STRIP_COMMAND) $(DAEMONIZE_IPK_DIR)/opt/sbin/daemonize
#	install -d $(DAEMONIZE_IPK_DIR)/opt/etc/
#	install -m 644 $(DAEMONIZE_SOURCE_DIR)/daemonize.conf $(DAEMONIZE_IPK_DIR)/opt/etc/daemonize.conf
#	install -d $(DAEMONIZE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DAEMONIZE_SOURCE_DIR)/rc.daemonize $(DAEMONIZE_IPK_DIR)/opt/etc/init.d/SXXdaemonize
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DAEMONIZE_IPK_DIR)/opt/etc/init.d/SXXdaemonize
	$(MAKE) $(DAEMONIZE_IPK_DIR)/CONTROL/control
#	install -m 755 $(DAEMONIZE_SOURCE_DIR)/postinst $(DAEMONIZE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DAEMONIZE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DAEMONIZE_SOURCE_DIR)/prerm $(DAEMONIZE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DAEMONIZE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DAEMONIZE_IPK_DIR)/CONTROL/postinst $(DAEMONIZE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(DAEMONIZE_CONFFILES) | sed -e 's/ /\n/g' > $(DAEMONIZE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DAEMONIZE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DAEMONIZE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
daemonize-ipk: $(DAEMONIZE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
daemonize-clean:
	rm -f $(DAEMONIZE_BUILD_DIR)/.built
	-$(MAKE) -C $(DAEMONIZE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
daemonize-dirclean:
	rm -rf $(BUILD_DIR)/$(DAEMONIZE_DIR) $(DAEMONIZE_BUILD_DIR) $(DAEMONIZE_IPK_DIR) $(DAEMONIZE_IPK)
#
#
# Some sanity check for the package.
#
daemonize-check: $(DAEMONIZE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
