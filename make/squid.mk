###########################################################
#
# squid
#
###########################################################

# You must replace "squid" and "SQUID" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SQUID_VERSION, SQUID_SITE and SQUID_SOURCE define
# the upstream location of the source code for the package.
# SQUID_DIR is the directory which is created when the source
# archive is unpacked.
# SQUID_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SQUID_SITE=http://www.squid-cache.org/Versions/v2/2.5/
SQUID_VERSION=2.5.STABLE7
SQUID_SOURCE=squid-2.5.STABLE7.tar.gz
SQUID_DIR=squid-2.5.STABLE7
SQUID_UNZIP=zcat

#
# SQUID_IPK_VERSION should be incremented when the ipk changes.
#
SQUID_IPK_VERSION=2

#
# SQUID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SQUID_PATCHES=$(SQUID_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQUID_CPPFLAGS=
SQUID_LDFLAGS=

#
# SQUID_BUILD_DIR is the directory in which the build is done.
# SQUID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQUID_IPK_DIR is the directory in which the ipk is built.
# SQUID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQUID_BUILD_DIR=$(BUILD_DIR)/squid
SQUID_SOURCE_DIR=$(SOURCE_DIR)/squid
SQUID_IPK_DIR=$(BUILD_DIR)/squid-$(SQUID_VERSION)-ipk
SQUID_IPK=$(BUILD_DIR)/squid_$(SQUID_VERSION)-$(SQUID_IPK_VERSION)_armeb.ipk

SQUID_INST_DIR=/opt
SQUID_BIN_DIR=$(SQUID_INST_DIR)/bin
SQUID_SBIN_DIR=$(SQUID_INST_DIR)/sbin
SQUID_LIBEXEC_DIR=$(SQUID_INST_DIR)/libexec
SQUID_DATA_DIR=$(SQUID_INST_DIR)/share/squid
SQUID_SYSCONF_DIR=$(SQUID_INST_DIR)/etc/squid
SQUID_SHAREDSTATE_DIR=$(SQUID_INST_DIR)/com/squid
SQUID_LOCALSTATE_DIR=$(SQUID_INST_DIR)/var/squid
SQUID_LIB_DIR=$(SQUID_INST_DIR)/lib
SQUID_INCLUDE_DIR=$(SQUID_INST_DIR)/include
SQUID_INFO_DIR=$(SQUID_INST_DIR)/info
SQUID_MAN_DIR=$(SQUID_INST_DIR)/man


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SQUID_SOURCE):
	$(WGET) -P $(DL_DIR) $(SQUID_SITE)/$(SQUID_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
squid-source: $(DL_DIR)/$(SQUID_SOURCE) $(SQUID_PATCHES)

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
$(SQUID_BUILD_DIR)/.configured: $(DL_DIR)/$(SQUID_SOURCE) $(SQUID_PATCHES)
	rm -rf $(BUILD_DIR)/$(SQUID_DIR) $(SQUID_BUILD_DIR)
	$(SQUID_UNZIP) $(DL_DIR)/$(SQUID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(SQUID_DIR) $(SQUID_BUILD_DIR)
	(cd $(SQUID_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SQUID_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQUID_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(SQUID_INST_DIR) \
		--bindir=$(SQUID_BIN_DIR) \
		--sbindir=$(SQUID_SBIN_DIR) \
		--libexecdir=$(SQUID_LIBEXEC_DIR) \
		--datadir=$(SQUID_DATA_DIR) \
		--sysconfdir=$(SQUID_SYSCONF_DIR) \
		--sharedstatedir=$(SQUID_SHAREDSTATE_DIR) \
		--localstatedir=$(SQUID_LOCALSTATE_DIR) \
		--libdir=$(SQUID_LIB_DIR) \
		--includedir=$(SQUID_INCLUDE_DIR) \
		--oldincludedir=$(SQUID_INCLUDE_DIR) \
		--infodir=$(SQUID_INFO_DIR) \
		--mandir=$(SQUID_MAN_DIR) \
		--disable-nls \
	)
	touch $(SQUID_BUILD_DIR)/.configured

squid-unpack: $(SQUID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQUID_BUILD_DIR)/.built: $(SQUID_BUILD_DIR)/.configured
	rm -f $(SQUID_BUILD_DIR)/.built
	$(MAKE) -C $(SQUID_BUILD_DIR)
	touch $(SQUID_BUILD_DIR)/.built

#
# This is the build convenience target.
#
squid: $(SQUID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SQUID_BUILD_DIR)/.staged: $(SQUID_BUILD_DIR)/.built
	rm -f $(SQUID_BUILD_DIR)/.staged
	$(MAKE) -C $(SQUID_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SQUID_BUILD_DIR)/.staged

squid-stage: $(SQUID_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQUID_IPK_DIR)/opt/sbin or $(SQUID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQUID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SQUID_IPK_DIR)/opt/etc/squid/...
# Documentation files should be installed in $(SQUID_IPK_DIR)/opt/doc/squid/...
# Daemon startup scripts should be installed in $(SQUID_IPK_DIR)/opt/etc/init.d/S??squid
#
# You may need to patch your application to make it use these locations.
#
$(SQUID_IPK): $(SQUID_BUILD_DIR)/.built
	rm -rf $(SQUID_IPK_DIR) $(BUILD_DIR)/squid_*_armeb.ipk
	$(MAKE) -C $(SQUID_BUILD_DIR) DESTDIR=$(SQUID_IPK_DIR) install
	install -d $(SQUID_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SQUID_SOURCE_DIR)/rc.squid $(SQUID_IPK_DIR)/opt/etc/init.d/S80squid
	ln -sf /opt/etc/init.d/S80squid $(SQUID_IPK_DIR)/opt/etc/init.d/K80squid 
	install -m 755 $(SQUID_SOURCE_DIR)/squid.delay-start.sh $(SQUID_IPK_DIR)$(SQUID_SYSCONF_DIR)/squid.delay-start.sh
	install -d $(SQUID_IPK_DIR)/CONTROL
	install -m 644 $(SQUID_SOURCE_DIR)/control $(SQUID_IPK_DIR)/CONTROL/control
	install -m 644 $(SQUID_SOURCE_DIR)/postinst $(SQUID_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SQUID_SOURCE_DIR)/preinst $(SQUID_IPK_DIR)/CONTROL/preinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQUID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
squid-ipk: $(SQUID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
squid-clean:
	-$(MAKE) -C $(SQUID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
squid-dirclean:
	rm -rf $(BUILD_DIR)/$(SQUID_DIR) $(SQUID_BUILD_DIR) $(SQUID_IPK_DIR) $(SQUID_IPK)
