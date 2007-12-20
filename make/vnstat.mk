###########################################################
#
# vnstat
#
###########################################################
#
# VNSTAT_VERSION, VNSTAT_SITE and VNSTAT_SOURCE define
# the upstream location of the source code for the package.
# VNSTAT_DIR is the directory which is created when the source
# archive is unpacked.
# VNSTAT_UNZIP is the command used to unzip the source.
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
VNSTAT_SITE=http://humdi.net/vnstat
VNSTAT_VERSION=1.5
VNSTAT_SOURCE=vnstat-$(VNSTAT_VERSION).tar.gz
VNSTAT_DIR=vnstat-$(VNSTAT_VERSION)
VNSTAT_UNZIP=zcat
VNSTAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VNSTAT_DESCRIPTION=Network traffic monitor with log
VNSTAT_SECTION=net
VNSTAT_PRIORITY=optional
VNSTAT_DEPENDS=
VNSTAT_SUGGESTS=
VNSTAT_CONFLICTS=

#
# VNSTAT_IPK_VERSION should be incremented when the ipk changes.
#
VNSTAT_IPK_VERSION=1

#
# VNSTAT_CONFFILES should be a list of user-editable files
VNSTAT_CONFFILES=/opt/etc/cron.d/vnstat /opt/etc/vnstat.conf

#
# VNSTAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VNSTAT_PATCHES=$(VNSTAT_SOURCE_DIR)/vnstat.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VNSTAT_CPPFLAGS=
VNSTAT_LDFLAGS=

#
# VNSTAT_BUILD_DIR is the directory in which the build is done.
# VNSTAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VNSTAT_IPK_DIR is the directory in which the ipk is built.
# VNSTAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VNSTAT_BUILD_DIR=$(BUILD_DIR)/vnstat
VNSTAT_SOURCE_DIR=$(SOURCE_DIR)/vnstat
VNSTAT_IPK_DIR=$(BUILD_DIR)/vnstat-$(VNSTAT_VERSION)-ipk
VNSTAT_IPK=$(BUILD_DIR)/vnstat_$(VNSTAT_VERSION)-$(VNSTAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vnstat-source vnstat-unpack vnstat vnstat-stage vnstat-ipk vnstat-clean vnstat-dirclean vnstat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VNSTAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(VNSTAT_SITE)/$(VNSTAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vnstat-source: $(DL_DIR)/$(VNSTAT_SOURCE) $(VNSTAT_PATCHES)

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
$(VNSTAT_BUILD_DIR)/.configured: $(DL_DIR)/$(VNSTAT_SOURCE) $(VNSTAT_PATCHES) make/vnstat.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(VNSTAT_DIR) $(VNSTAT_BUILD_DIR)
	$(VNSTAT_UNZIP) $(DL_DIR)/$(VNSTAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VNSTAT_PATCHES)" ; \
		then cat $(VNSTAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VNSTAT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(VNSTAT_DIR)" != "$(VNSTAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(VNSTAT_DIR) $(VNSTAT_BUILD_DIR) ; \
	fi
	( cd $(VNSTAT_BUILD_DIR); \
		sed -i -e 's|/usr|/opt|;s|/var/|/opt/var/|' \
		-e 's|/etc|/opt/etc|;s|/share/man|/man|' \
		-e 's|local/bin|bin|' \
		-e 's|install -s|install|' \
		-e '/^CC/d;/^CFLAGS/d'  \
		cron/vnstat pppd/vnstat_ip-down pppd/vnstat_ip-up \
		Makefile src/Makefile src/cfg.c cfg/vnstat.conf \
	)
	touch $(VNSTAT_BUILD_DIR)/.configured

vnstat-unpack: $(VNSTAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VNSTAT_BUILD_DIR)/.built: $(VNSTAT_BUILD_DIR)/.configured
	rm -f $(VNSTAT_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(VNSTAT_BUILD_DIR)
	touch $(VNSTAT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
vnstat: $(VNSTAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VNSTAT_BUILD_DIR)/.staged: $(VNSTAT_BUILD_DIR)/.built
	rm -f $(VNSTAT_BUILD_DIR)/.staged
	$(MAKE) -C $(VNSTAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(VNSTAT_BUILD_DIR)/.staged

vnstat-stage: $(VNSTAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vnstat
#
$(VNSTAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: vnstat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VNSTAT_PRIORITY)" >>$@
	@echo "Section: $(VNSTAT_SECTION)" >>$@
	@echo "Version: $(VNSTAT_VERSION)-$(VNSTAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VNSTAT_MAINTAINER)" >>$@
	@echo "Source: $(VNSTAT_SITE)/$(VNSTAT_SOURCE)" >>$@
	@echo "Description: $(VNSTAT_DESCRIPTION)" >>$@
	@echo "Depends: $(VNSTAT_DEPENDS)" >>$@
	@echo "Suggests: $(VNSTAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(VNSTAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VNSTAT_IPK_DIR)/opt/sbin or $(VNSTAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VNSTAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VNSTAT_IPK_DIR)/opt/etc/vnstat/...
# Documentation files should be installed in $(VNSTAT_IPK_DIR)/opt/doc/vnstat/...
# Daemon startup scripts should be installed in $(VNSTAT_IPK_DIR)/opt/etc/init.d/S??vnstat
#
# You may need to patch your application to make it use these locations.
#
$(VNSTAT_IPK): $(VNSTAT_BUILD_DIR)/.built
	rm -rf $(VNSTAT_IPK_DIR) $(BUILD_DIR)/vnstat_*_$(TARGET_ARCH).ipk
	install -d $(VNSTAT_IPK_DIR)/opt/etc/
	$(MAKE) -C $(VNSTAT_BUILD_DIR) DESTDIR=$(VNSTAT_IPK_DIR) install
	$(STRIP_COMMAND) $(VNSTAT_IPK_DIR)/opt/bin/vnstat
	chmod 600 $(VNSTAT_IPK_DIR)/opt/etc/cron.d/vnstat
#	install -m 644 $(VNSTAT_SOURCE_DIR)/vnstat.conf $(VNSTAT_IPK_DIR)/opt/etc/vnstat.conf
#	install -d $(VNSTAT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(VNSTAT_SOURCE_DIR)/rc.vnstat $(VNSTAT_IPK_DIR)/opt/etc/init.d/SXXvnstat
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXvnstat
	$(MAKE) $(VNSTAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(VNSTAT_SOURCE_DIR)/postinst $(VNSTAT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(VNSTAT_SOURCE_DIR)/prerm $(VNSTAT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(VNSTAT_CONFFILES) | sed -e 's/ /\n/g' > $(VNSTAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VNSTAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vnstat-ipk: $(VNSTAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vnstat-clean:
	rm -f $(VNSTAT_BUILD_DIR)/.built
	-$(MAKE) -C $(VNSTAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vnstat-dirclean:
	rm -rf $(BUILD_DIR)/$(VNSTAT_DIR) $(VNSTAT_BUILD_DIR) $(VNSTAT_IPK_DIR) $(VNSTAT_IPK)
#
#
# Some sanity check for the package.
#
vnstat-check: $(VNSTAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VNSTAT_IPK)
