###########################################################
#
# portmap
#
###########################################################

# You must replace "portmap" and "PORTMAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PORTMAP_VERSION, PORTMAP_SITE and PORTMAP_SOURCE define
# the upstream location of the source code for the package.
# PORTMAP_DIR is the directory which is created when the source
# archive is unpacked.
# PORTMAP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PORTMAP_SITE=https://launchpad.net/ubuntu/+archive/primary/+files
PORTMAP_VERSION=6.0.0
PORTMAP_SOURCE=portmap_$(PORTMAP_VERSION).orig.tar.gz
PORTMAP_DIR=portmap-$(PORTMAP_VERSION)
PORTMAP_UNZIP=zcat
PORTMAP_MAINTAINER=Roy Silvernail <roy@rant-central.com>
PORTMAP_DESCRIPTION=Portmap daemon for NFS
PORTMAP_SECTION=net
PORTMAP_PRIORITY=optional
PORTMAP_DEPENDS=
PORTMAP_CONFLICTS=

#
# PORTMAP_IPK_VERSION should be incremented when the ipk changes.
#
PORTMAP_IPK_VERSION=1

#
# PORTMAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PORTMAP_PATCHES=$(PORTMAP_SOURCE_DIR)/Makefile.patch \
		$(PORTMAP_SOURCE_DIR)/strerror.c.patch \
		$(PORTMAP_SOURCE_DIR)/portmap-errno.patch
PORTMAP_PATCHES=\
$(PORTMAP_SOURCE_DIR)/00-420514.portmap.8.patch \
$(PORTMAP_SOURCE_DIR)/01-437892-portmap.8.patch \
$(PORTMAP_SOURCE_DIR)/02-448470-pidfile.patch \
$(PORTMAP_SOURCE_DIR)/03-356784-lotsofinterfaces.patch \
$(PORTMAP_SOURCE_DIR)/04-460156-no-pie.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PORTMAP_CPPFLAGS=
PORTMAP_LDFLAGS=

#
# PORTMAP_BUILD_DIR is the directory in which the build is done.
# PORTMAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PORTMAP_IPK_DIR is the directory in which the ipk is built.
# PORTMAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PORTMAP_BUILD_DIR=$(BUILD_DIR)/portmap
PORTMAP_SOURCE_DIR=$(SOURCE_DIR)/portmap
PORTMAP_IPK_DIR=$(BUILD_DIR)/portmap-$(PORTMAP_VERSION)-ipk
PORTMAP_IPK=$(BUILD_DIR)/portmap_$(PORTMAP_VERSION)-$(PORTMAP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PORTMAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PORTMAP_SITE)/$(PORTMAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
portmap-source: $(DL_DIR)/$(PORTMAP_SOURCE) $(PORTMAP_PATCHES)

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
$(PORTMAP_BUILD_DIR)/.configured: $(DL_DIR)/$(PORTMAP_SOURCE) $(PORTMAP_PATCHES) make/portmap.mk
	$(MAKE) tcpwrappers-stage
	rm -rf $(BUILD_DIR)/$(PORTMAP_DIR) $(@D)
	$(PORTMAP_UNZIP) $(DL_DIR)/$(PORTMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PORTMAP_PATCHES) | patch -d $(BUILD_DIR)/$(PORTMAP_DIR) -p1
	mv $(BUILD_DIR)/$(PORTMAP_DIR) $(@D)
	touch $@

portmap-unpack: $(PORTMAP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PORTMAP_BUILD_DIR)/.built: $(PORTMAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PORTMAP_CPPFLAGS) -DFACILITY=LOG_DAEMON" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PORTMAP_LDFLAGS)"
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
portmap: $(PORTMAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(STAGING_LIB_DIR)/libportmap.so.$(PORTMAP_VERSION): $(PORTMAP_BUILD_DIR)/.built
#	install -d $(STAGING_INCLUDE_DIR)
#	install -m 644 $(PORTMAP_BUILD_DIR)/portmap.h $(STAGING_INCLUDE_DIR)
#	install -d $(STAGING_LIB_DIR)
#	install -m 644 $(PORTMAP_BUILD_DIR)/libportmap.a $(STAGING_LIB_DIR)
#	install -m 644 $(PORTMAP_BUILD_DIR)/libportmap.so.$(PORTMAP_VERSION) $(STAGING_LIB_DIR)
#	cd $(STAGING_LIB_DIR) && ln -fs libportmap.so.$(PORTMAP_VERSION) libportmap.so.1
#	cd $(STAGING_LIB_DIR) && ln -fs libportmap.so.$(PORTMAP_VERSION) libportmap.so
#
#portmap-stage: $(STAGING_LIB_DIR)/libportmap.so.$(PORTMAP_VERSION)
#

# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/portmap
# 
$(PORTMAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: portmap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PORTMAP_PRIORITY)" >>$@
	@echo "Section: $(PORTMAP_SECTION)" >>$@
	@echo "Version: $(PORTMAP_VERSION)-$(PORTMAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PORTMAP_MAINTAINER)" >>$@
	@echo "Source: $(PORTMAP_SITE)/$(PORTMAP_SOURCE)" >>$@
	@echo "Description: $(PORTMAP_DESCRIPTION)" >>$@
	@echo "Depends: $(PORTMAP_DEPENDS)" >>$@
	@echo "Conflicts: $(PORTMAP_CONFLICTS)" >>$@


# This builds the IPK file.
#
# Binaries should be installed into $(PORTMAP_IPK_DIR)/opt/sbin or $(PORTMAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PORTMAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PORTMAP_IPK_DIR)/opt/etc/portmap/...
# Documentation files should be installed in $(PORTMAP_IPK_DIR)/opt/doc/portmap/...
# Daemon startup scripts should be installed in $(PORTMAP_IPK_DIR)/opt/etc/init.d/S??portmap
#
# You may need to patch your application to make it use these locations.
#
$(PORTMAP_IPK): $(PORTMAP_BUILD_DIR)/.built
	rm -rf $(PORTMAP_IPK_DIR) $(BUILD_DIR)/portmap_*_$(TARGET_ARCH).ipk
	install -d $(PORTMAP_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(PORTMAP_BUILD_DIR)/portmap -o $(PORTMAP_IPK_DIR)/opt/sbin/portmap
	install -d $(PORTMAP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(PORTMAP_SOURCE_DIR)/rc.portmap $(PORTMAP_IPK_DIR)/opt/etc/init.d/S55portmap
	$(MAKE) $(PORTMAP_IPK_DIR)/CONTROL/control
	install -m 644 $(PORTMAP_SOURCE_DIR)/postinst $(PORTMAP_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PORTMAP_SOURCE_DIR)/prerm $(PORTMAP_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PORTMAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
portmap-ipk: $(PORTMAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
portmap-clean:
	-$(MAKE) -C $(PORTMAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
portmap-dirclean:
	rm -rf $(BUILD_DIR)/$(PORTMAP_DIR) $(PORTMAP_BUILD_DIR) $(PORTMAP_IPK_DIR) $(PORTMAP_IPK)
