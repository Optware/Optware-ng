###########################################################
#
# nfs-server
#
###########################################################

# You must replace "nfs-server" and "NFS_SERVER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NFS_SERVER_VERSION, NFS_SERVER_SITE and NFS_SERVER_SOURCE define
# the upstream location of the source code for the package.
# NFS_SERVER_DIR is the directory which is created when the source
# archive is unpacked.
# NFS_SERVER_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NFS_SERVER_SITE=http://linux.mathematik.tu-darmstadt.de/linux/people/okir
NFS_SERVER_VERSION=2.2beta47
NFS_SERVER_SOURCE=nfs-server-$(NFS_SERVER_VERSION).tar.gz
NFS_SERVER_DIR=nfs-server-$(NFS_SERVER_VERSION)
NFS_SERVER_UNZIP=zcat

#
# NFS_SERVER_IPK_VERSION should be incremented when the ipk changes.
#
NFS_SERVER_IPK_VERSION=2

#
# NFS_SERVER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NFS_SERVER_PATCHES=$(NFS_SERVER_SOURCE_DIR)/nfs-server.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NFS_SERVER_CPPFLAGS=
NFS_SERVER_LDFLAGS=

#
# NFS_SERVER_BUILD_DIR is the directory in which the build is done.
# NFS_SERVER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NFS_SERVER_IPK_DIR is the directory in which the ipk is built.
# NFS_SERVER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NFS_SERVER_BUILD_DIR=$(BUILD_DIR)/nfs-server
NFS_SERVER_SOURCE_DIR=$(SOURCE_DIR)/nfs-server
NFS_SERVER_IPK_DIR=$(BUILD_DIR)/nfs-server-$(NFS_SERVER_VERSION)-ipk
NFS_SERVER_IPK=$(BUILD_DIR)/nfs-server_$(NFS_SERVER_VERSION)-$(NFS_SERVER_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NFS_SERVER_SOURCE):
	$(WGET) -P $(DL_DIR) $(NFS_SERVER_SITE)/$(NFS_SERVER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nfs-server-source: $(DL_DIR)/$(NFS_SERVER_SOURCE) $(NFS_SERVER_PATCHES)

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
$(NFS_SERVER_BUILD_DIR)/.configured: $(DL_DIR)/$(NFS_SERVER_SOURCE) $(NFS_SERVER_PATCHES)
	rm -rf $(BUILD_DIR)/$(NFS_SERVER_DIR) $(NFS_SERVER_BUILD_DIR)
	$(NFS_SERVER_UNZIP) $(DL_DIR)/$(NFS_SERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NFS_SERVER_DIR) $(NFS_SERVER_BUILD_DIR)
	(cd $(NFS_SERVER_BUILD_DIR); \
	./BUILD --batch \
		--multi \
		--devtab=no \
		--ugidd=no \
		--nis=no \
		--hosts-access=no \
		--exports-uid=0 \
		--exports-gid=0 \
		--log-mounts=yes)
	cat $(NFS_SERVER_PATCHES) | patch -d $(NFS_SERVER_BUILD_DIR) -p1
	@if [ -a /usr/bin/hdiutil ]; \
	then \
	rm $(NFS_SERVER_BUILD_DIR)/config.h; \
	cp $(NFS_SERVER_SOURCE_DIR)/nfs-server-darwin.config $(NFS_SERVER_BUILD_DIR)/config.h; \
	fi;
	touch $(NFS_SERVER_BUILD_DIR)/.configured

nfs-server-unpack: $(NFS_SERVER_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NFS_SERVER_BUILD_DIR)/rpc.nfsd: $(NFS_SERVER_BUILD_DIR)/.configured
	$(MAKE) -C $(NFS_SERVER_BUILD_DIR) \
		CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
nfs-server: $(NFS_SERVER_BUILD_DIR)/rpc.nfsd

#
# This builds the IPK file.
#
# Binaries should be installed into $(NFS_SERVER_IPK_DIR)/opt/sbin or $(NFS_SERVER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NFS_SERVER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NFS_SERVER_IPK_DIR)/opt/etc/nfs-server/...
# Documentation files should be installed in $(NFS_SERVER_IPK_DIR)/opt/doc/nfs-server/...
# Daemon startup scripts should be installed in $(NFS_SERVER_IPK_DIR)/opt/etc/init.d/S??nfs-server
#
# You may need to patch your application to make it use these locations.
#
$(NFS_SERVER_IPK): $(NFS_SERVER_BUILD_DIR)/rpc.nfsd
	rm -rf $(NFS_SERVER_IPK_DIR) $(NFS_SERVER_IPK)
	install -d $(NFS_SERVER_IPK_DIR)/opt/sbin
	$(STRIP) $(NFS_SERVER_BUILD_DIR)/rpc.nfsd -o $(NFS_SERVER_IPK_DIR)/opt/sbin/rpc.nfsd
	$(STRIP) $(NFS_SERVER_BUILD_DIR)/rpc.mountd -o $(NFS_SERVER_IPK_DIR)/opt/sbin/rpc.mountd
	install -d $(NFS_SERVER_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NFS_SERVER_SOURCE_DIR)/rc.nfs-server $(NFS_SERVER_IPK_DIR)/opt/etc/init.d/S56nfsd
	install -d $(NFS_SERVER_IPK_DIR)/CONTROL
	install -m 644 $(NFS_SERVER_SOURCE_DIR)/control $(NFS_SERVER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NFS_SERVER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nfs-server-ipk: $(NFS_SERVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nfs-server-clean:
	-$(MAKE) -C $(NFS_SERVER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nfs-server-dirclean:
	rm -rf $(BUILD_DIR)/$(NFS_SERVER_DIR) $(NFS_SERVER_BUILD_DIR) $(NFS_SERVER_IPK_DIR) $(NFS_SERVER_IPK)
