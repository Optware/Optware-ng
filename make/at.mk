###########################################################
#
# at
#
###########################################################
#
# AT_VERSION, AT_SITE and AT_SOURCE define
# the upstream location of the source code for the package.
# AT_DIR is the directory which is created when the source
# archive is unpacked.
# AT_UNZIP is the command used to unzip the source.
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
AT_SITE=http://pkgs.fedoraproject.org/repo/pkgs/at/$(AT_SOURCE)/f5194baac29a30b0d90604422dad7037
AT_VERSION=3.1.8
AT_SOURCE=at-$(AT_VERSION).tar.bz2
AT_DIR=at-$(AT_VERSION)
AT_UNZIP=bzcat
AT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AT_DESCRIPTION=Delayed job execution and batch processing.
AT_SECTION=misc
AT_PRIORITY=optional
AT_DEPENDS=psmisc, flex
AT_SUGGESTS=
AT_CONFLICTS=

#
# AT_IPK_VERSION should be incremented when the ipk changes.
#
AT_IPK_VERSION=6

#
# AT_CONFFILES should be a list of user-editable files
AT_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S20at

#
# AT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
AT_PATCHES=$(AT_SOURCE_DIR)/Makefile.in.patch

ifneq ($(HOSTCC), $(TARGET_CC))
AT_PATCHES+= $(AT_SOURCE_DIR)/configure.patch
endif

ifeq ($(OPTWARE_TARGET), slugosbe)
AT_DAEMON=daemon
else
AT_DAEMON=nobody
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AT_CPPFLAGS=
AT_LDFLAGS=

#
# AT_BUILD_DIR is the directory in which the build is done.
# AT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AT_IPK_DIR is the directory in which the ipk is built.
# AT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AT_BUILD_DIR=$(BUILD_DIR)/at
AT_SOURCE_DIR=$(SOURCE_DIR)/at
AT_IPK_DIR=$(BUILD_DIR)/at-$(AT_VERSION)-ipk
AT_IPK=$(BUILD_DIR)/at_$(AT_VERSION)-$(AT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: at-source at-unpack at at-stage at-ipk at-clean at-dirclean at-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AT_SOURCE):
	$(WGET) -P $(DL_DIR) $(AT_SITE)/$(AT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
at-source: $(DL_DIR)/$(AT_SOURCE) $(AT_PATCHES)

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
$(AT_BUILD_DIR)/.configured: $(DL_DIR)/$(AT_SOURCE) $(AT_PATCHES) make/at.mk
	$(MAKE) flex-stage
	rm -rf $(BUILD_DIR)/$(AT_DIR) $(@D)
	$(AT_UNZIP) $(DL_DIR)/$(AT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AT_PATCHES)" ; \
		then cat $(AT_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(AT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(AT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(AT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AT_LDFLAGS)" \
		ac_cv_path_SENDMAIL=$(TARGET_PREFIX)/sbin/sendmail \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		\
		--with-etcdir=$(TARGET_PREFIX)/etc \
		--with-jobdir=$(TARGET_PREFIX)/var/spool/cron/atjobs \
		--with-atspool=$(TARGET_PREFIX)/var/spool/cron/atspool \
		--with-daemon_username=$(AT_DAEMON) \
		--with-daemon_groupname=$(AT_DAEMON) \
		\
		--disable-nls \
		--disable-static \
	)
#	sed -i -e '/^LIBS/s|$$| $$(LDFLAGS)|' \
		$(@D)/Makefile
	touch $@

at-unpack: $(AT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AT_BUILD_DIR)/.built: $(AT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LEXLIB="-lfl"
	touch $@

#
# This is the build convenience target.
#
at: $(AT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AT_BUILD_DIR)/.staged: $(AT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

at-stage: $(AT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/at
#
$(AT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: at" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AT_PRIORITY)" >>$@
	@echo "Section: $(AT_SECTION)" >>$@
	@echo "Version: $(AT_VERSION)-$(AT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AT_MAINTAINER)" >>$@
	@echo "Source: $(AT_SITE)/$(AT_SOURCE)" >>$@
	@echo "Description: $(AT_DESCRIPTION)" >>$@
	@echo "Depends: $(AT_DEPENDS)" >>$@
	@echo "Suggests: $(AT_SUGGESTS)" >>$@
	@echo "Conflicts: $(AT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(AT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(AT_IPK_DIR)$(TARGET_PREFIX)/etc/at/...
# Documentation files should be installed in $(AT_IPK_DIR)$(TARGET_PREFIX)/doc/at/...
# Daemon startup scripts should be installed in $(AT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??at
#
# You may need to patch your application to make it use these locations.
#
$(AT_IPK): $(AT_BUILD_DIR)/.built
	rm -rf $(AT_IPK_DIR) $(BUILD_DIR)/at_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(AT_BUILD_DIR) IROOT=$(AT_IPK_DIR) install
	$(STRIP_COMMAND) $(AT_IPK_DIR)$(TARGET_PREFIX)/bin/at $(AT_IPK_DIR)$(TARGET_PREFIX)/sbin/atd
#	$(INSTALL) -d $(AT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(AT_SOURCE_DIR)/at.conf $(AT_IPK_DIR)$(TARGET_PREFIX)/etc/at.conf
	$(INSTALL) -d $(AT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(AT_SOURCE_DIR)/rc.at $(AT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S20at
	$(MAKE) $(AT_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(AT_SOURCE_DIR)/postinst $(AT_IPK_DIR)/CONTROL/postinst
	sed -ie 's/nobody/$(AT_DAEMON)/g' $(AT_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(AT_SOURCE_DIR)/prerm $(AT_IPK_DIR)/CONTROL/prerm
	echo $(AT_CONFFILES) | sed -e 's/ /\n/g' > $(AT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
at-ipk: $(AT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
at-clean:
	rm -f $(AT_BUILD_DIR)/.built
	-$(MAKE) -C $(AT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
at-dirclean:
	rm -rf $(BUILD_DIR)/$(AT_DIR) $(AT_BUILD_DIR) $(AT_IPK_DIR) $(AT_IPK)
#
#
# Some sanity check for the package.
#
at-check: $(AT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AT_IPK)
