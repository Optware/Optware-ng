###########################################################
#
# nget
#
###########################################################

#
# NGET_VERSION, NGET_SITE and NGET_SOURCE define
# the upstream location of the source code for the package.
# NGET_DIR is the directory which is created when the source
# archive is unpacked.
# NGET_UNZIP is the command used to unzip the source.
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
NGET_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nget
NGET_VERSION=0.27.1
NGET_SOURCE=nget-$(NGET_VERSION)+uulib.tar.gz
NGET_DIR=nget-$(NGET_VERSION)
NGET_UNZIP=zcat
NGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NGET_DESCRIPTION=nget is a command line nntp file grabber.
NGET_SECTION=misc
NGET_PRIORITY=optional
NGET_DEPENDS=pcre,popt,zlib
NGET_SUGGESTS=
NGET_CONFLICTS=

#
# NGET_IPK_VERSION should be incremented when the ipk changes.
#
NGET_IPK_VERSION=4

#
# NGET_CONFFILES should be a list of user-editable files
#NGET_CONFFILES=/opt/etc/nget.conf /opt/etc/init.d/SXXnget

#
# NGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NGET_PATCHES=$(NGET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NGET_CPPFLAGS=
NGET_LDFLAGS=

#
# NGET_BUILD_DIR is the directory in which the build is done.
# NGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NGET_IPK_DIR is the directory in which the ipk is built.
# NGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NGET_BUILD_DIR=$(BUILD_DIR)/nget
NGET_SOURCE_DIR=$(SOURCE_DIR)/nget
NGET_IPK_DIR=$(BUILD_DIR)/nget-$(NGET_VERSION)-ipk
NGET_IPK=$(BUILD_DIR)/nget_$(NGET_VERSION)-$(NGET_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NGET_SOURCE):
	$(WGET) -P $(@D) $(NGET_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nget-source: $(DL_DIR)/$(NGET_SOURCE) $(NGET_PATCHES)

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
$(NGET_BUILD_DIR)/.configured: $(DL_DIR)/$(NGET_SOURCE) $(NGET_PATCHES) make/nget.mk
	$(MAKE) pcre-stage popt-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(NGET_DIR) $(@D)
	$(NGET_UNZIP) $(DL_DIR)/$(NGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	case `$(TARGET_CC) -dumpversion` in \
	  4.2.*) cat $(NGET_SOURCE_DIR)/nget-0.27.1-gcc42.patch \
	         | patch -d $(BUILD_DIR)/$(NGET_DIR) -p1 ;; \
	  4.3.*) cat $(NGET_SOURCE_DIR)/nget-0.27.1-gcc43.patch \
	         | patch -d $(BUILD_DIR)/$(NGET_DIR) -p1 ;; \
	esac
	mv $(BUILD_DIR)/$(NGET_DIR) $(@D)
	(cd $(@D)/uulib; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NGET_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NGET_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-gnugetopt \
		--with-pcre \
		--with-popt \
		--with-zlib \
		--disable-nls \
	)
	touch $@

nget-unpack: $(NGET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NGET_BUILD_DIR)/.built: $(NGET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
nget: $(NGET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(NGET_BUILD_DIR)/.staged: $(NGET_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#nget-stage: $(NGET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nget
#
$(NGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NGET_PRIORITY)" >>$@
	@echo "Section: $(NGET_SECTION)" >>$@
	@echo "Version: $(NGET_VERSION)-$(NGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NGET_MAINTAINER)" >>$@
	@echo "Source: $(NGET_SITE)/$(NGET_SOURCE)" >>$@
	@echo "Description: $(NGET_DESCRIPTION)" >>$@
	@echo "Depends: $(NGET_DEPENDS)" >>$@
	@echo "Suggests: $(NGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(NGET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NGET_IPK_DIR)/opt/sbin or $(NGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NGET_IPK_DIR)/opt/etc/nget/...
# Documentation files should be installed in $(NGET_IPK_DIR)/opt/doc/nget/...
# Daemon startup scripts should be installed in $(NGET_IPK_DIR)/opt/etc/init.d/S??nget
#
# You may need to patch your application to make it use these locations.
#
$(NGET_IPK): $(NGET_BUILD_DIR)/.built
	rm -rf $(NGET_IPK_DIR) $(BUILD_DIR)/nget_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NGET_BUILD_DIR) \
		prefix=$(NGET_IPK_DIR)/opt \
		install_bin="install -m 0755" \
		install
	$(STRIP_COMMAND) $(NGET_IPK_DIR)/opt/bin/*
	install -d $(NGET_IPK_DIR)/opt/share/doc/example/nget
	install -m 644 $(NGET_SOURCE_DIR)/example.ngetrc $(NGET_IPK_DIR)/opt/share/doc/example/nget/
	$(MAKE) $(NGET_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NGET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nget-ipk: $(NGET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nget-clean:
	-$(MAKE) -C $(NGET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nget-dirclean:
	rm -rf $(BUILD_DIR)/$(NGET_DIR) $(NGET_BUILD_DIR) $(NGET_IPK_DIR) $(NGET_IPK)

#
# Some sanity check for the package.
#
nget-check: $(NGET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NGET_IPK)
