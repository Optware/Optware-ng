###########################################################
#
# svn
#
###########################################################

# SVN_VERSION, SVN_SITE and SVN_SOURCE define
# the upstream location of the source code for the package.
# SVN_DIR is the directory which is created when the source
# archive is unpacked.
# SVN_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SVN_SITE=http://subversion.tigris.org/tarballs
SVN_VERSION=1.1.1
SVN_SOURCE=subversion-$(SVN_VERSION).tar.gz
SVN_DIR=subversion-$(SVN_VERSION)
SVN_UNZIP=zcat

#
# SVN_IPK_VERSION should be incremented when the ipk changes.
#
SVN_IPK_VERSION=2

#
# SVN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SVN_PATCHES=$(SVN_SOURCE_DIR)/svn.patch.gz

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SVN_CPPFLAGS=
SVN_LDFLAGS=

#
# SVN_BUILD_DIR is the directory in which the build is done.
# SVN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SVN_IPK_DIR is the directory in which the ipk is built.
# SVN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SVN_BUILD_DIR=$(BUILD_DIR)/svn
SVN_SOURCE_DIR=$(SOURCE_DIR)/svn
SVN_IPK_DIR=$(BUILD_DIR)/svn-$(SVN_VERSION)-ipk
SVN_IPK=$(BUILD_DIR)/svn_$(SVN_VERSION)-$(SVN_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SVN_SOURCE):
	$(WGET) -P $(DL_DIR) $(SVN_SITE)/$(SVN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
svn-source: $(DL_DIR)/$(SVN_SOURCE) $(SVN_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
#
$(SVN_BUILD_DIR)/.configured: $(DL_DIR)/$(SVN_SOURCE)
	$(MAKE) libdb-stage openssl-stage gdbm-stage
	rm -rf $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	$(SVN_UNZIP) $(DL_DIR)/$(SVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	zcat $(SVN_PATCHES) | patch -d $(BUILD_DIR)/$(SVN_DIR) -p2
	mv $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	(cd $(SVN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SVN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SVN_LDFLAGS)" \
		KRB5_CONFIG=none \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-libs=$(STAGING_DIR)/opt \
		--with-berkeley-db=$(STAGING_DIR)/opt \
		--with-expat=$(SVN_BUILD_DIR)/apr-util/xml/expat \
		--with-ssl=yes \
		--with-apache=no \
		--with-apxs=no \
	)
	touch $(SVN_BUILD_DIR)/.configured

svn-unpack: $(SVN_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(SVN_BUILD_DIR)/subversion/clients/cmdline/svn: $(SVN_BUILD_DIR)/.configured
	$(MAKE) -C $(SVN_BUILD_DIR) all

#
# These are the dependencies for the package (remove svn-dependencies if
# there are no build dependencies for this package.  Again, you should change
# the final dependency to refer directly to the main binary which is built.
#
svn: $(SVN_BUILD_DIR)/subversion/clients/cmdline/svn

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libneon.la: $(SVN_BUILD_DIR)/subversion/clients/cmdline/svn
	$(MAKE) -C $(SVN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -rf $(STAGING_DIR)/opt/{man,info,share}

svn-stage: $(STAGING_DIR)/opt/lib/libneon.la

#
# This builds the IPK file.
#
# Binaries should be installed into $(SVN_IPK_DIR)/opt/sbin or $(SVN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SVN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SVN_IPK_DIR)/opt/etc/svn/...
# Documentation files should be installed in $(SVN_IPK_DIR)/opt/doc/svn/...
# Daemon startup scripts should be installed in $(SVN_IPK_DIR)/opt/etc/init.d/S??svn
#
# You may need to patch your application to make it use these locations.
#
$(SVN_IPK): $(SVN_BUILD_DIR)/subversion/clients/cmdline/svn
	$(MAKE) svn-stage
	rm -rf $(SVN_IPK_DIR) $(SVN_IPK)
	$(MAKE) -C $(SVN_BUILD_DIR) DESTDIR=$(SVN_IPK_DIR) install
	rm -rf $(SVN_IPK_DIR)/opt/{build,include,info,man,share}
	rm -rf $(SVN_IPK_DIR)/opt/lib/*.{a,la,exp}
	rm -rf $(SVN_IPK_DIR)/opt/lib/pkgconfig
	rm -f $(SVN_IPK_DIR)/opt/bin/*-config
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/svn
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/svnadmin
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/svndumpfilter
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/svnlook
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/svnserve
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/svnversion
	install -d $(SVN_IPK_DIR)/CONTROL
	install -m 644 $(SVN_SOURCE_DIR)/control $(SVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SVN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
svn-ipk: $(SVN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
svn-clean:
	-$(MAKE) -C $(SVN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
svn-dirclean:
	rm -rf $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR) $(SVN_IPK_DIR) $(SVN_IPK)
