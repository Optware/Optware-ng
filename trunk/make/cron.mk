###########################################################
#
# cron
#
###########################################################

#
# CRON_VERSION, CRON_SITE and CRON_SOURCE define
# the upstream location of the source code for the package.
# CRON_DIR is the directory which is created when the source
# archive is unpacked.
# CRON_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CRON_SITE=ftp://ftp.isc.org/isc/cron
CRON_VERSION=4.1
CRON_SOURCE=cron_$(CRON_VERSION).shar
CRON_DIR=cron-$(CRON_VERSION)
CRON_UNZIP=cat
CRON_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
CRON_DESCRIPTION=Standard vixie cron, with cron.d addition
CRON_SECTION=sys
CRON_PRIORITY=optional
CRON_DEPENDS=

.PHONY: cron-source cron-unpack cron cron-stage cron-ipk cron-clean cron-dirclean cron-check

#
# CRON_IPK_VERSION should be incremented when the ipk changes.
#
CRON_IPK_VERSION=6

#
# CRON_CONFFILES should be a list of user-editable files
CRON_CONFFILES=/opt/etc/crontab /opt/etc/init.d/S10cron

#
# CRON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CRON_PATCHES=$(CRON_SOURCE_DIR)/Makefile.patch $(CRON_SOURCE_DIR)/pathnames.h.patch $(CRON_SOURCE_DIR)/crond.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CRON_CPPFLAGS=
CRON_LDFLAGS=

#
# CRON_BUILD_DIR is the directory in which the build is done.
# CRON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CRON_IPK_DIR is the directory in which the ipk is built.
# CRON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CRON_BUILD_DIR=$(BUILD_DIR)/cron
CRON_SOURCE_DIR=$(SOURCE_DIR)/cron
CRON_IPK_DIR=$(BUILD_DIR)/cron-$(CRON_VERSION)-ipk
CRON_IPK=$(BUILD_DIR)/cron_$(CRON_VERSION)-$(CRON_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CRON_SOURCE):
	$(WGET) -P $(DL_DIR) $(CRON_SITE)/$(CRON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cron-source: $(DL_DIR)/$(CRON_SOURCE) $(CRON_PATCHES)

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
$(CRON_BUILD_DIR)/.configured: $(DL_DIR)/$(CRON_SOURCE) $(CRON_PATCHES)
	rm -rf $(BUILD_DIR)/$(CRON_DIR) $(CRON_BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(CRON_DIR)
	(cd $(BUILD_DIR)/$(CRON_DIR); \
		$(CRON_UNZIP) $(DL_DIR)/$(CRON_SOURCE) | sh -x)
	cat $(CRON_PATCHES) | patch -d $(BUILD_DIR)/$(CRON_DIR) -p1
	mv $(BUILD_DIR)/$(CRON_DIR) $(CRON_BUILD_DIR)
	touch $(CRON_BUILD_DIR)/.configured

cron-unpack: $(CRON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CRON_BUILD_DIR)/.built: $(CRON_BUILD_DIR)/.configured
	rm -f $(CRON_BUILD_DIR)/.built
	$(MAKE) -C $(CRON_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
	touch $(CRON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cron: $(CRON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CRON_BUILD_DIR)/.staged: $(CRON_BUILD_DIR)/.built
	rm -f $(CRON_BUILD_DIR)/.staged
#	$(MAKE) -C $(CRON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CRON_BUILD_DIR)/.staged

cron-stage: $(CRON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cron
#
$(CRON_IPK_DIR)/CONTROL/control:
	@install -d $(CRON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cron" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CRON_PRIORITY)" >>$@
	@echo "Section: $(CRON_SECTION)" >>$@
	@echo "Version: $(CRON_VERSION)-$(CRON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CRON_MAINTAINER)" >>$@
	@echo "Source: $(CRON_SITE)/$(CRON_SOURCE)" >>$@
	@echo "Description: $(CRON_DESCRIPTION)" >>$@
	@echo "Depends: $(CRON_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CRON_IPK_DIR)/opt/sbin or $(CRON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CRON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CRON_IPK_DIR)/opt/etc/cron/...
# Documentation files should be installed in $(CRON_IPK_DIR)/opt/doc/cron/...
# Daemon startup scripts should be installed in $(CRON_IPK_DIR)/opt/etc/init.d/S??cron
#
# You may need to patch your application to make it use these locations.
#
$(CRON_IPK): $(CRON_BUILD_DIR)/.built
	rm -rf $(CRON_IPK_DIR) $(BUILD_DIR)/cron_*_$(TARGET_ARCH).ipk
# 	Install and strip the two executables
	install -d $(CRON_IPK_DIR)/opt/bin
	install -m  755 $(CRON_BUILD_DIR)/crontab $(CRON_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(CRON_IPK_DIR)/opt/bin/crontab
	install -d $(CRON_IPK_DIR)/opt/sbin
	install -m  755 $(CRON_BUILD_DIR)/cron $(CRON_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(CRON_IPK_DIR)/opt/sbin/cron
# 	Install manuals
	install -d $(CRON_IPK_DIR)/opt/man/man1
	install -d $(CRON_IPK_DIR)/opt/man/man5
	install -d $(CRON_IPK_DIR)/opt/man/man8
	install -m 644 $(CRON_BUILD_DIR)/crontab.1 $(CRON_IPK_DIR)/opt/man/man1
	install -m 644 $(CRON_BUILD_DIR)/crontab.5 $(CRON_IPK_DIR)/opt/man/man5
	install -m 644 $(CRON_BUILD_DIR)/cron.8    $(CRON_IPK_DIR)/opt/man/man8
#	Install default crontab
	install -d $(CRON_IPK_DIR)/opt/etc
	install -m 600 $(CRON_SOURCE_DIR)/crontab $(CRON_IPK_DIR)/opt/etc/crontab
#	Install daemon startup file
	install -d $(CRON_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CRON_SOURCE_DIR)/rc.cron $(CRON_IPK_DIR)/opt/etc/init.d/S10cron
	$(MAKE) $(CRON_IPK_DIR)/CONTROL/control
	install -m 755 $(CRON_SOURCE_DIR)/postinst $(CRON_IPK_DIR)/CONTROL/postinst
	install -m 644 $(CRON_SOURCE_DIR)/prerm $(CRON_IPK_DIR)/CONTROL/
	echo $(CRON_CONFFILES) | sed -e 's/ /\n/g' > $(CRON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CRON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cron-ipk: $(CRON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cron-clean:
	-$(MAKE) -C $(CRON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cron-dirclean:
	rm -rf $(BUILD_DIR)/$(CRON_DIR) $(CRON_BUILD_DIR) $(CRON_IPK_DIR) $(CRON_IPK)
leon@achilles:~/p/wl/wl500gx$ gx/
