###########################################################
#
# nfs-utils
#
###########################################################

#
# NFS-UTILS_VERSION, NFS-UTILS_SITE and NFS-UTILS_SOURCE define
# the upstream location of the source code for the package.
# NFS-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# NFS-UTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NFS-UTILS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nfs
NFS-UTILS_VERSION=1.1.1
NFS-UTILS_SOURCE=nfs-utils-$(NFS-UTILS_VERSION).tar.gz
NFS-UTILS_DIR=nfs-utils-$(NFS-UTILS_VERSION)
NFS-UTILS_UNZIP=zcat
NFS-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NFS-UTILS_DESCRIPTION=Kernel NFS Server
NFS-UTILS_SECTION=net
NFS-UTILS_PRIORITY=optional
NFS-UTILS_DEPENDS=portmap, e2fsprogs
NFS-UTILS_SUGGESTS=
NFS-UTILS_CONFLICTS=

#
# NFS-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
NFS-UTILS_IPK_VERSION=1

#
# NFS-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NFS-UTILS_PATCHES=$(NFS-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NFS-UTILS_CPPFLAGS=
NFS-UTILS_LDFLAGS=

#
# NFS-UTILS_BUILD_DIR is the directory in which the build is done.
# NFS-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NFS-UTILS_IPK_DIR is the directory in which the ipk is built.
# NFS-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NFS-UTILS_BUILD_DIR=$(BUILD_DIR)/nfs-utils
NFS-UTILS_SOURCE_DIR=$(SOURCE_DIR)/nfs-utils
NFS-UTILS_IPK_DIR=$(BUILD_DIR)/nfs-utils-$(NFS-UTILS_VERSION)-ipk
NFS-UTILS_IPK=$(BUILD_DIR)/nfs-utils_$(NFS-UTILS_VERSION)-$(NFS-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NFS-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(NFS-UTILS_SITE)/$(NFS-UTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nfs-utils-source: $(DL_DIR)/$(NFS-UTILS_SOURCE) $(NFS-UTILS_PATCHES)

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
$(NFS-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(NFS-UTILS_SOURCE) $(NFS-UTILS_PATCHES)
	$(MAKE) e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(NFS-UTILS_DIR) $(NFS-UTILS_BUILD_DIR)
	$(NFS-UTILS_UNZIP) $(DL_DIR)/$(NFS-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	chmod u+w $(BUILD_DIR)/$(NFS-UTILS_DIR)/*
	if test -n "$(NFS-UTILS_PATCHES)"; then \
		cat $(NFS-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(NFS-UTILS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(NFS-UTILS_DIR) $(NFS-UTILS_BUILD_DIR)
	(cd $(NFS-UTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NFS-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NFS-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-statduser=nobody \
		--enable-nfsv3 \
		--disable-nfsv4 \
		--disable-gss \
		--without-tcp-wrappers \
	)
	touch $@

nfs-utils-unpack: $(NFS-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NFS-UTILS_BUILD_DIR)/.built: $(NFS-UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
nfs-utils: $(NFS-UTILS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nfs-utils
#
$(NFS-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nfs-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NFS-UTILS_PRIORITY)" >>$@
	@echo "Section: $(NFS-UTILS_SECTION)" >>$@
	@echo "Version: $(NFS-UTILS_VERSION)-$(NFS-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NFS-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(NFS-UTILS_SITE)/$(NFS-UTILS_SOURCE)" >>$@
	@echo "Description: $(NFS-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(NFS-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(NFS-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NFS-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NFS-UTILS_IPK_DIR)/opt/sbin or $(NFS-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NFS-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NFS-UTILS_IPK_DIR)/opt/etc/nfs-utils/...
# Documentation files should be installed in $(NFS-UTILS_IPK_DIR)/opt/doc/nfs-utils/...
# Daemon startup scripts should be installed in $(NFS-UTILS_IPK_DIR)/opt/etc/init.d/S??nfs-utils
#
# You may need to patch your application to make it use these locations.
#
$(NFS-UTILS_IPK): $(NFS-UTILS_BUILD_DIR)/.built
	rm -rf $(NFS-UTILS_IPK_DIR) $(BUILD_DIR)/nfs-utils_*_$(TARGET_ARCH).ipk
	install -d $(NFS-UTILS_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/nfsd/nfsd -o $(NFS-UTILS_IPK_DIR)/opt/sbin/nfsd
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/mountd/mountd -o $(NFS-UTILS_IPK_DIR)/opt/sbin/mountd
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/lockd/lockd -o $(NFS-UTILS_IPK_DIR)/opt/sbin/lockd
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/rquotad/rquotad -o $(NFS-UTILS_IPK_DIR)/opt/sbin/rquotad
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/statd/statd -o $(NFS-UTILS_IPK_DIR)/opt/sbin/statd
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/exportfs/exportfs -o $(NFS-UTILS_IPK_DIR)/opt/sbin/exportfs
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/showmount/showmount -o $(NFS-UTILS_IPK_DIR)/opt/sbin/showmount
	$(STRIP_COMMAND) $(NFS-UTILS_BUILD_DIR)/utils/nfsstat/nfsstat -o $(NFS-UTILS_IPK_DIR)/opt/sbin/nfsstat
	install -d $(NFS-UTILS_IPK_DIR)/opt/doc/nfs-utils
	install -m 644 $(NFS-UTILS_SOURCE_DIR)/exports $(NFS-UTILS_IPK_DIR)/opt/doc/nfs-utils/exports
	install -d $(NFS-UTILS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NFS-UTILS_SOURCE_DIR)/rc.nfs-utils $(NFS-UTILS_IPK_DIR)/opt/etc/init.d/S56nfs-utils
	$(MAKE) $(NFS-UTILS_IPK_DIR)/CONTROL/control
	install -m 644 $(NFS-UTILS_SOURCE_DIR)/postinst $(NFS-UTILS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(NFS-UTILS_SOURCE_DIR)/prerm $(NFS-UTILS_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NFS-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nfs-utils-ipk: $(NFS-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nfs-utils-clean:
	-$(MAKE) -C $(NFS-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nfs-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(NFS-UTILS_DIR) $(NFS-UTILS_BUILD_DIR) $(NFS-UTILS_IPK_DIR) $(NFS-UTILS_IPK)

#
# Some sanity check for the package.
#
nfs-utils-check: $(NFS-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NFS-UTILS_IPK)
