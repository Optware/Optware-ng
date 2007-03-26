###########################################################
#
# nagios-plugins
#
###########################################################
#
# $Id$
#
# TODO:
#	Check all plugins and remove plugins which aren't working
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
NAGIOS_PLUGINS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nagiosplug
NAGIOS_PLUGINS_VERSION=1.4.2
NAGIOS_PLUGINS_SOURCE=nagios-plugins-$(NAGIOS_PLUGINS_VERSION).tar.gz
NAGIOS_PLUGINS_DIR=nagios-plugins-$(NAGIOS_PLUGINS_VERSION)
NAGIOS_PLUGINS_UNZIP=zcat
NAGIOS_PLUGINS_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
NAGIOS_PLUGINS_DESCRIPTION=The nagios (network monitor system) plugins
NAGIOS_PLUGINS_SECTION=net
NAGIOS_PLUGINS_PRIORITY=optional
NAGIOS_PLUGINS_DEPENDS=openssl
NAGIOS_PLUGINS_SUGGESTS=
NAGIOS_PLUGINS_CONFLICTS=

#
# Perl script plugins
#
PERL_PLUGINS=			\
	utils.pm		\
	check_breeze		\
	check_disk_smb		\
	check_file_age		\
	check_flexlm		\
	check_ifoperstatus	\
	check_ifstatus		\
	check_ircd		\
	check_mailq		\
	check_ntp		\
	check_rpc		\
	check_wave		

#
# Shell script plugins
#
SHELL_PLUGINS=			\
	utils.sh		\
	check_log		\
	check_oracle		\
	check_sensors
#
# Plugins that aren't working
#
PLUGINS_REMOVE=			\
	$(PERL_PLUGINS)		\
	$(SHELL_PLUGINS)	\
	check_by_ssh		\
	check_dig		\
	check_dns		\
	check_fping		\
	check_icmp		\
	check_ldaps		\
	check_mrtg		\
	check_mrtgtraf		\
	check_nagios		\
	check_nt		\
	check_overcr		\
	check_pgsql		\
	check_ping		\
	check_procs		\
	check_snmp		\
	check_ups		\
	check_users

#
# NAGIOS_PLUGINS_IPK_VERSION should be incremented when the ipk changes.
#
NAGIOS_PLUGINS_IPK_VERSION=4

#
# NAGIOS_PLUGINS_CONFFILES should be a list of user-editable files
# NAGIOS_PLUGINS_CONFFILES=/opt/etc/nagios-plugins.conf /opt/etc/init.d/SXXnagios-plugins

#
# NAGIOS_PLUGINS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NAGIOS_PLUGINS_PATCHES=$(NAGIOS_PLUGINS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NAGIOS_PLUGINS_CPPFLAGS=
NAGIOS_PLUGINS_LDFLAGS=-lm

#
# NAGIOS_PLUGINS_BUILD_DIR is the directory in which the build is done.
# NAGIOS_PLUGINS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NAGIOS_PLUGINS_IPK_DIR is the directory in which the ipk is built.
# NAGIOS_PLUGINS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NAGIOS_PLUGINS_BUILD_DIR=$(BUILD_DIR)/nagios-plugins
NAGIOS_PLUGINS_SOURCE_DIR=$(SOURCE_DIR)/nagios-plugins
NAGIOS_PLUGINS_IPK_DIR=$(BUILD_DIR)/nagios-plugins-$(NAGIOS_PLUGINS_VERSION)-ipk
NAGIOS_PLUGINS_IPK=$(BUILD_DIR)/nagios-plugins_$(NAGIOS_PLUGINS_VERSION)-$(NAGIOS_PLUGINS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NAGIOS_PLUGINS_SOURCE):
	$(WGET) -P $(DL_DIR) $(NAGIOS_PLUGINS_SITE)/$(NAGIOS_PLUGINS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nagios-plugins-source: $(DL_DIR)/$(NAGIOS_PLUGINS_SOURCE) $(NAGIOS_PLUGINS_PATCHES)

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
$(NAGIOS_PLUGINS_BUILD_DIR)/.configured: $(DL_DIR)/$(NAGIOS_PLUGINS_SOURCE) $(NAGIOS_PLUGINS_PATCHES) make/nagios-plugins.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(NAGIOS_PLUGINS_DIR) $(NAGIOS_PLUGINS_BUILD_DIR)
	$(NAGIOS_PLUGINS_UNZIP) $(DL_DIR)/$(NAGIOS_PLUGINS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NAGIOS_PLUGINS_PATCHES)" ; \
		then cat $(NAGIOS_PLUGINS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NAGIOS_PLUGINS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NAGIOS_PLUGINS_DIR)" != "$(NAGIOS_PLUGINS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NAGIOS_PLUGINS_DIR) $(NAGIOS_PLUGINS_BUILD_DIR) ; \
	fi
	sed -ie 's|-I/usr|-I$(STAGING_PREFIX)|g' $(NAGIOS_PLUGINS_BUILD_DIR)/configure
	(cd $(NAGIOS_PLUGINS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NAGIOS_PLUGINS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NAGIOS_PLUGINS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	# $(PATCH_LIBTOOL) $(NAGIOS_PLUGINS_BUILD_DIR)/libtool
	touch $(NAGIOS_PLUGINS_BUILD_DIR)/.configured

nagios-plugins-unpack: $(NAGIOS_PLUGINS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NAGIOS_PLUGINS_BUILD_DIR)/.built: $(NAGIOS_PLUGINS_BUILD_DIR)/.configured
	rm -f $(NAGIOS_PLUGINS_BUILD_DIR)/.built
	$(MAKE) -C $(NAGIOS_PLUGINS_BUILD_DIR)
	touch $(NAGIOS_PLUGINS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nagios-plugins: $(NAGIOS_PLUGINS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NAGIOS_PLUGINS_BUILD_DIR)/.staged: $(NAGIOS_PLUGINS_BUILD_DIR)/.built
	rm -f $(NAGIOS_PLUGINS_BUILD_DIR)/.staged
	$(MAKE) -C $(NAGIOS_PLUGINS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NAGIOS_PLUGINS_BUILD_DIR)/.staged

nagios-plugins-stage: $(NAGIOS_PLUGINS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nagios-plugins
#
$(NAGIOS_PLUGINS_IPK_DIR)/CONTROL/control:
	@install -d $(NAGIOS_PLUGINS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nagios-plugins" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NAGIOS_PLUGINS_PRIORITY)" >>$@
	@echo "Section: $(NAGIOS_PLUGINS_SECTION)" >>$@
	@echo "Version: $(NAGIOS_PLUGINS_VERSION)-$(NAGIOS_PLUGINS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NAGIOS_PLUGINS_MAINTAINER)" >>$@
	@echo "Source: $(NAGIOS_PLUGINS_SITE)/$(NAGIOS_PLUGINS_SOURCE)" >>$@
	@echo "Description: $(NAGIOS_PLUGINS_DESCRIPTION)" >>$@
	@echo "Depends: $(NAGIOS_PLUGINS_DEPENDS)" >>$@
	@echo "Suggests: $(NAGIOS_PLUGINS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NAGIOS_PLUGINS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NAGIOS_PLUGINS_IPK_DIR)/opt/sbin or $(NAGIOS_PLUGINS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NAGIOS_PLUGINS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NAGIOS_PLUGINS_IPK_DIR)/opt/etc/nagios-plugins/...
# Documentation files should be installed in $(NAGIOS_PLUGINS_IPK_DIR)/opt/doc/nagios-plugins/...
# Daemon startup scripts should be installed in $(NAGIOS_PLUGINS_IPK_DIR)/opt/etc/init.d/S??nagios-plugins
#
# You may need to patch your application to make it use these locations.
#
$(NAGIOS_PLUGINS_IPK): $(NAGIOS_PLUGINS_BUILD_DIR)/.built
	rm -rf $(NAGIOS_PLUGINS_IPK_DIR) $(BUILD_DIR)/nagios-plugins_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NAGIOS_PLUGINS_BUILD_DIR) DESTDIR=$(NAGIOS_PLUGINS_IPK_DIR) install-strip
	(cd $(NAGIOS_PLUGINS_IPK_DIR)/opt/libexec; rm -f $(PLUGINS_REMOVE)) 
#	install -d $(NAGIOS_PLUGINS_IPK_DIR)/opt/etc/
#	install -m 644 $(NAGIOS_PLUGINS_SOURCE_DIR)/nagios-plugins.conf $(NAGIOS_PLUGINS_IPK_DIR)/opt/etc/nagios-plugins.conf
#	install -d $(NAGIOS_PLUGINS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NAGIOS_PLUGINS_SOURCE_DIR)/rc.nagios-plugins $(NAGIOS_PLUGINS_IPK_DIR)/opt/etc/init.d/SXXnagios-plugins
	$(MAKE) $(NAGIOS_PLUGINS_IPK_DIR)/CONTROL/control
#	install -m 755 $(NAGIOS_PLUGINS_SOURCE_DIR)/postinst $(NAGIOS_PLUGINS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NAGIOS_PLUGINS_SOURCE_DIR)/prerm $(NAGIOS_PLUGINS_IPK_DIR)/CONTROL/prerm
#	echo $(NAGIOS_PLUGINS_CONFFILES) | sed -e 's/ /\n/g' > $(NAGIOS_PLUGINS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NAGIOS_PLUGINS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nagios-plugins-ipk: $(NAGIOS_PLUGINS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nagios-plugins-clean:
	rm -f $(NAGIOS_PLUGINS_BUILD_DIR)/.built
	-$(MAKE) -C $(NAGIOS_PLUGINS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nagios-plugins-dirclean:
	rm -rf $(BUILD_DIR)/$(NAGIOS_PLUGINS_DIR) $(NAGIOS_PLUGINS_BUILD_DIR) $(NAGIOS_PLUGINS_IPK_DIR) $(NAGIOS_PLUGINS_IPK)
