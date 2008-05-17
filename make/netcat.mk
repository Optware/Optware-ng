###########################################################
#
# netcat
#
###########################################################
#
# NETCAT_VERSION, NETCAT_SITE and NETCAT_SOURCE define
# the upstream location of the source code for the package.
# NETCAT_DIR is the directory which is created when the source
# archive is unpacked.
# NETCAT_UNZIP is the command used to unzip the source.
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
NETCAT_SITE=ftp://ftp.debian.org/debian/pool/main/n/netcat
NETCAT_ORIG_VERSION=1.10
NETCAT_DEBIAN_PATCHLEVEL=32
NETCAT_VERSION=$(NETCAT_ORIG_VERSION)pl$(NETCAT_DEBIAN_PATCHLEVEL)
NETCAT_SOURCE=netcat_$(NETCAT_ORIG_VERSION).orig.tar.gz
NETCAT_DEBIAN_PATCH=netcat_$(NETCAT_ORIG_VERSION)-$(NETCAT_DEBIAN_PATCHLEVEL).diff.gz
NETCAT_DIR=netcat-$(NETCAT_ORIG_VERSION).orig
NETCAT_UNZIP=zcat
NETCAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NETCAT_DESCRIPTION=TCP/IP swiss army knife.
NETCAT_SECTION=net
NETCAT_PRIORITY=optional
NETCAT_DEPENDS=
NETCAT_SUGGESTS=
NETCAT_CONFLICTS=

#
# NETCAT_IPK_VERSION should be incremented when the ipk changes.
#
NETCAT_IPK_VERSION=3

#
# NETCAT_CONFFILES should be a list of user-editable files
#NETCAT_CONFFILES=/opt/etc/netcat.conf /opt/etc/init.d/SXXnetcat

#
# NETCAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NETCAT_PATCHES=$(NETCAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETCAT_CPPFLAGS=
NETCAT_LDFLAGS=

#
# NETCAT_BUILD_DIR is the directory in which the build is done.
# NETCAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETCAT_IPK_DIR is the directory in which the ipk is built.
# NETCAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETCAT_BUILD_DIR=$(BUILD_DIR)/netcat
NETCAT_SOURCE_DIR=$(SOURCE_DIR)/netcat
NETCAT_IPK_DIR=$(BUILD_DIR)/netcat-$(NETCAT_VERSION)-ipk
NETCAT_IPK=$(BUILD_DIR)/netcat_$(NETCAT_VERSION)-$(NETCAT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETCAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(NETCAT_SITE)/$(NETCAT_SOURCE) && \
	$(WGET) -P $(DL_DIR) $(NETCAT_SITE)/$(NETCAT_DEBIAN_PATCH)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netcat-source: $(DL_DIR)/$(NETCAT_SOURCE) $(NETCAT_PATCHES)

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
$(NETCAT_BUILD_DIR)/.configured: $(DL_DIR)/$(NETCAT_SOURCE) $(NETCAT_PATCHES) make/netcat.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(NETCAT_DIR) $(NETCAT_BUILD_DIR)
	$(NETCAT_UNZIP) $(DL_DIR)/$(NETCAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NETCAT_PATCHES)" ; \
		then cat $(NETCAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NETCAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NETCAT_DIR)" != "$(NETCAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NETCAT_DIR) $(NETCAT_BUILD_DIR) ; \
	fi
	(cd $(NETCAT_BUILD_DIR); \
		mkdir -p debian; \
		zcat $(DL_DIR)/$(NETCAT_DEBIAN_PATCH) | patch -d debian; \
		for i in `cat debian/series`; do cat debian/$$i | patch -p1; done; \
		sed -i -e 's|/usr/share|/opt/share|g' debian/nc.1; \
	)
	touch $@

netcat-unpack: $(NETCAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETCAT_BUILD_DIR)/.built: $(NETCAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NETCAT_BUILD_DIR) CC=$(TARGET_CC) linux
	touch $@

#
# This is the build convenience target.
#
netcat: $(NETCAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETCAT_BUILD_DIR)/.staged: $(NETCAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NETCAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

netcat-stage: $(NETCAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/netcat
#
$(NETCAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: netcat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETCAT_PRIORITY)" >>$@
	@echo "Section: $(NETCAT_SECTION)" >>$@
	@echo "Version: $(NETCAT_VERSION)-$(NETCAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETCAT_MAINTAINER)" >>$@
	@echo "Source: $(NETCAT_SITE)/$(NETCAT_SOURCE)" >>$@
	@echo "Description: $(NETCAT_DESCRIPTION)" >>$@
	@echo "Depends: $(NETCAT_DEPENDS)" >>$@
	@echo "Suggests: $(NETCAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETCAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETCAT_IPK_DIR)/opt/sbin or $(NETCAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETCAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETCAT_IPK_DIR)/opt/etc/netcat/...
# Documentation files should be installed in $(NETCAT_IPK_DIR)/opt/doc/netcat/...
# Daemon startup scripts should be installed in $(NETCAT_IPK_DIR)/opt/etc/init.d/S??netcat
#
# You may need to patch your application to make it use these locations.
#
$(NETCAT_IPK): $(NETCAT_BUILD_DIR)/.built
	rm -rf $(NETCAT_IPK_DIR) $(BUILD_DIR)/netcat_*_$(TARGET_ARCH).ipk
	install -d $(NETCAT_IPK_DIR)/opt/bin
	install $(NETCAT_BUILD_DIR)/nc $(NETCAT_IPK_DIR)/opt/bin/netcat-nc
	install -d $(NETCAT_IPK_DIR)/opt/man/man1
	install $(NETCAT_BUILD_DIR)/debian/nc.1 $(NETCAT_IPK_DIR)/opt/man/man1
	install -d $(NETCAT_IPK_DIR)/opt/share/doc/netcat
	gzip -c $(NETCAT_BUILD_DIR)/README > $(NETCAT_IPK_DIR)/opt/share/doc/netcat/README.gz
	$(STRIP_COMMAND) $(NETCAT_IPK_DIR)/opt/bin/netcat-nc
	$(MAKE) $(NETCAT_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/nc nc /opt/bin/netcat-nc 80"; \
	) > $(NETCAT_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove nc /opt/bin/netcat-nc"; \
	) > $(NETCAT_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NETCAT_IPK_DIR)/CONTROL/postinst $(NETCAT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NETCAT_CONFFILES) | sed -e 's/ /\n/g' > $(NETCAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETCAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netcat-ipk: $(NETCAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netcat-clean:
	rm -f $(NETCAT_BUILD_DIR)/.built
	-$(MAKE) -C $(NETCAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netcat-dirclean:
	rm -rf $(BUILD_DIR)/$(NETCAT_DIR) $(NETCAT_BUILD_DIR) $(NETCAT_IPK_DIR) $(NETCAT_IPK)

#
# Some sanity check for the package.
#
netcat-check: $(NETCAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NETCAT_IPK)
