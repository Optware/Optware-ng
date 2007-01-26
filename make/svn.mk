###########################################################
#
# svn
#
###########################################################

# You must replace "svn" and "SVN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SVN_VERSION, SVN_SITE and SVN_SOURCE define
# the upstream location of the source code for the package.
# SVN_DIR is the directory which is created when the source
# archive is unpacked.
# SVN_UNZIP is the command used to unzip the source.
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
SVN_SITE=http://subversion.tigris.org/downloads
SVN_VERSION=1.4.3
SVN_SOURCE=subversion-$(SVN_VERSION).tar.bz2
SVN_DIR=subversion-$(SVN_VERSION)
SVN_UNZIP=bzcat
SVN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SVN_DESCRIPTION=a compelling replacement for CVS
SVN_SECTION=net
SVN_PRIORITY=optional
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SVN_DEPENDS=neon, apr, apr-util, openldap-libs, zlib, expat, libxml2
else
SVN_DEPENDS=neon, apr, apr-util, zlib, expat, libxml2
endif
SVN_SUGGESTS=
SVN_CONFLICTS=

#
# SVN_IPK_VERSION should be incremented when the ipk changes.
#
SVN_IPK_VERSION=1

#
# SVN_CONFFILES should be a list of user-editable files
SVN_CONFFILES=

#
# SVN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SVN_PATCHES=$(SVN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SVN_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/neon
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
SVN_IPK=$(BUILD_DIR)/svn_$(SVN_VERSION)-$(SVN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: svn-source svn-unpack svn svn-stage svn-ipk svn-clean svn-dirclean svn-check
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
$(SVN_BUILD_DIR)/.configured: $(DL_DIR)/$(SVN_SOURCE) $(SVN_PATCHES)
	$(MAKE) apr-stage
	$(MAKE) apr-util-stage
	$(MAKE) apache-stage
	$(MAKE) expat-stage
	$(MAKE) libxml2-stage
	$(MAKE) neon-stage
	$(MAKE) zlib-stage
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage
endif
	rm -rf $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	$(SVN_UNZIP) $(DL_DIR)/$(SVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(SVN_PATCHES) | patch -d $(BUILD_DIR)/$(SVN_DIR) -p1
	mv $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	(cd $(SVN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SVN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SVN_LDFLAGS)" \
		ac_cv_func_memcmp_working=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-neon=$(STAGING_DIR)/opt \
		--with-apr=$(STAGING_DIR)/opt \
		--with-apr=$(STAGING_DIR)/opt \
		--with-apr-util=$(STAGING_DIR)/opt \
		--with-apxs=$(STAGING_DIR)/opt/sbin/apxs \
		--without-swig \
		--enable-shared \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(SVN_BUILD_DIR)/libtool
	touch $(SVN_BUILD_DIR)/.configured

svn-unpack: $(SVN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SVN_BUILD_DIR)/.built: $(SVN_BUILD_DIR)/.configured
	rm -f $(SVN_BUILD_DIR)/.built
	$(MAKE) -C $(SVN_BUILD_DIR)
	touch $(SVN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
svn: $(SVN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SVN_BUILD_DIR)/.staged: $(SVN_BUILD_DIR)/.built
	rm -f $(SVN_BUILD_DIR)/.staged
	$(MAKE) -C $(SVN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SVN_BUILD_DIR)/.staged

svn-stage: $(SVN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/svn
#
$(SVN_IPK_DIR)/CONTROL/control:
	@install -d $(SVN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: svn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SVN_PRIORITY)" >>$@
	@echo "Section: $(SVN_SECTION)" >>$@
	@echo "Version: $(SVN_VERSION)-$(SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SVN_MAINTAINER)" >>$@
	@echo "Source: $(SVN_SITE)/$(SVN_SOURCE)" >>$@
	@echo "Description: $(SVN_DESCRIPTION)" >>$@
	@echo "Depends: $(SVN_DEPENDS)" >>$@
	@echo "Suggests: $(SVN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SVN_CONFLICTS)" >>$@

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
$(SVN_IPK): $(SVN_BUILD_DIR)/.built
	rm -rf $(SVN_IPK_DIR) $(BUILD_DIR)/svn_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SVN_BUILD_DIR) DESTDIR=$(SVN_IPK_DIR) external-install local-install
	install -d $(SVN_IPK_DIR)/opt/etc/apache2/conf.d
	install -m 644 $(SVN_SOURCE_DIR)/mod_dav_svn.conf $(SVN_IPK_DIR)/opt/etc/apache2/conf.d/mod_dav_svn.conf
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/*
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/lib/*.so
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/libexec/*.so
	rm -f $(SVN_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(SVN_IPK_DIR)/CONTROL/control
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

#
# Some sanity check for the package.
#
svn-check: $(SVN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SVN_IPK)
