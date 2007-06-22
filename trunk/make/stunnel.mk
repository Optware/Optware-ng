###########################################################
#
# stunnel
#
###########################################################

# You must replace "stunnel" and "STUNNEL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# STUNNEL_VERSION, STUNNEL_SITE and STUNNEL_SOURCE define
# the upstream location of the source code for the package.
# STUNNEL_DIR is the directory which is created when the source
# archive is unpacked.
# STUNNEL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
STUNNEL_SITE=http://www.stunnel.org/download/stunnel/src
STUNNEL_VERSION=4.20
STUNNEL_SOURCE=stunnel-$(STUNNEL_VERSION).tar.gz
STUNNEL_DIR=stunnel-$(STUNNEL_VERSION)
STUNNEL_UNZIP=zcat
STUNNEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
STUNNEL_DESCRIPTION=SSL encryption wrapper for all kinds of servers
STUNNEL_SECTION=net
STUNNEL_PRIORITY=optional
STUNNEL_DEPENDS=openssl
STUNNEL_CONFLICTS=

#
# STUNNEL_IPK_VERSION should be incremented when the ipk changes.
#
STUNNEL_IPK_VERSION=1

#
# STUNNEL_CONFFILES should be a list of user-editable files
#
STUNNEL_CONFFILES=/opt/etc/stunnel/stunnel.conf \
		  /opt/etc/stunnel/stunnel-cert.cnf \
		  /opt/etc/init.d/S68stunnel

#
# STUNNEL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
STUNNEL_PATCHES=$(STUNNEL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
STUNNEL_CPPFLAGS=
STUNNEL_LDFLAGS=

#
# STUNNEL_BUILD_DIR is the directory in which the build is done.
# STUNNEL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STUNNEL_IPK_DIR is the directory in which the ipk is built.
# STUNNEL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STUNNEL_BUILD_DIR=$(BUILD_DIR)/stunnel
STUNNEL_SOURCE_DIR=$(SOURCE_DIR)/stunnel
STUNNEL_IPK_DIR=$(BUILD_DIR)/stunnel-$(STUNNEL_VERSION)-ipk
STUNNEL_IPK=$(BUILD_DIR)/stunnel_$(STUNNEL_VERSION)-$(STUNNEL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: stunnel-source stunnel-unpack stunnel stunnel-stage stunnel-ipk stunnel-clean stunnel-dirclean stunnel-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STUNNEL_SOURCE):
	$(WGET) -P $(DL_DIR) $(STUNNEL_SITE)/$(STUNNEL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
stunnel-source: $(DL_DIR)/$(STUNNEL_SOURCE) $(STUNNEL_PATCHES)

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
$(STUNNEL_BUILD_DIR)/.configured: $(DL_DIR)/$(STUNNEL_SOURCE) $(STUNNEL_PATCHES)
	$(MAKE) openssl-stage 
	rm -rf $(BUILD_DIR)/$(STUNNEL_DIR) $(STUNNEL_BUILD_DIR)
	$(STUNNEL_UNZIP) $(DL_DIR)/$(STUNNEL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(STUNNEL_PATCHES) | patch -d $(BUILD_DIR)/$(STUNNEL_DIR) -p1
	mv $(BUILD_DIR)/$(STUNNEL_DIR) $(STUNNEL_BUILD_DIR)
	(cd $(STUNNEL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STUNNEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(STUNNEL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ssl=$(STAGING_DIR)/opt \
	)
	touch $(STUNNEL_BUILD_DIR)/.configured

stunnel-unpack: $(STUNNEL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(STUNNEL_BUILD_DIR)/.built: $(STUNNEL_BUILD_DIR)/.configured
	rm -f $(STUNNEL_BUILD_DIR)/.built
	$(MAKE) -C $(STUNNEL_BUILD_DIR)
	touch $(STUNNEL_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
stunnel: $(STUNNEL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STUNNEL_BUILD_DIR)/.staged: $(STUNNEL_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(STUNNEL_BUILD_DIR)/stunnel.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(STUNNEL_BUILD_DIR)/libstunnel.a $(STAGING_DIR)/opt/lib
	install -m 644 $(STUNNEL_BUILD_DIR)/libstunnel.so.$(STUNNEL_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libstunnel.so.$(STUNNEL_VERSION) libstunnel.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libstunnel.so.$(STUNNEL_VERSION) libstunnel.so
	touch $@

stunnel-stage: $(STUNNEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/stunnel
#
$(STUNNEL_IPK_DIR)/CONTROL/control:
	@install -d $(STUNNEL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: stunnel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STUNNEL_PRIORITY)" >>$@
	@echo "Section: $(STUNNEL_SECTION)" >>$@
	@echo "Version: $(STUNNEL_VERSION)-$(STUNNEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STUNNEL_MAINTAINER)" >>$@
	@echo "Source: $(STUNNEL_SITE)/$(STUNNEL_SOURCE)" >>$@
	@echo "Description: $(STUNNEL_DESCRIPTION)" >>$@
	@echo "Depends: $(STUNNEL_DEPENDS)" >>$@
	@echo "Conflicts: $(STUNNEL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(STUNNEL_IPK_DIR)/opt/sbin or $(STUNNEL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STUNNEL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STUNNEL_IPK_DIR)/opt/etc/stunnel/...
# Documentation files should be installed in $(STUNNEL_IPK_DIR)/opt/doc/stunnel/...
# Daemon startup scripts should be installed in $(STUNNEL_IPK_DIR)/opt/etc/init.d/S??stunnel
#
# You may need to patch your application to make it use these locations.
#
$(STUNNEL_IPK): $(STUNNEL_BUILD_DIR)/.built
	rm -rf $(STUNNEL_IPK_DIR) $(BUILD_DIR)/stunnel_*_$(TARGET_ARCH).ipk
	install -d $(STUNNEL_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(STUNNEL_BUILD_DIR)/src/stunnel -o $(STUNNEL_IPK_DIR)/opt/sbin/stunnel
	install -d $(STUNNEL_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(STUNNEL_BUILD_DIR)/src/.libs/libstunnel.so -o $(STUNNEL_IPK_DIR)/opt/lib/libstunnel.so
	install -d $(STUNNEL_IPK_DIR)/opt/var/stunnel
	install -d $(STUNNEL_IPK_DIR)/opt/etc/stunnel
	install -m 644 $(STUNNEL_BUILD_DIR)/tools/stunnel.cnf $(STUNNEL_IPK_DIR)/opt/etc/stunnel/stunnel-cert.cnf
	install -m 644 $(STUNNEL_SOURCE_DIR)/stunnel.conf $(STUNNEL_IPK_DIR)/opt/etc/stunnel/stunnel.conf
	install -d $(STUNNEL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(STUNNEL_SOURCE_DIR)/rc.stunnel $(STUNNEL_IPK_DIR)/opt/etc/init.d/S68stunnel
	$(MAKE) $(STUNNEL_IPK_DIR)/CONTROL/control
	install -m 644 $(STUNNEL_SOURCE_DIR)/postinst $(STUNNEL_IPK_DIR)/CONTROL/postinst
	install -m 644 $(STUNNEL_SOURCE_DIR)/prerm $(STUNNEL_IPK_DIR)/CONTROL/prerm
	echo $(STUNNEL_CONFFILES) | sed -e 's/ /\n/g' > $(STUNNEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STUNNEL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
stunnel-ipk: $(STUNNEL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
stunnel-clean:
	-$(MAKE) -C $(STUNNEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
stunnel-dirclean:
	rm -rf $(BUILD_DIR)/$(STUNNEL_DIR) $(STUNNEL_BUILD_DIR) $(STUNNEL_IPK_DIR) $(STUNNEL_IPK)

#
# Some sanity check for the package.
#
stunnel-check: $(STUNNEL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(STUNNEL_IPK)
