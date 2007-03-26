###########################################################
#
# libao
#
###########################################################

# You must replace "libao" and "LIBAO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBAO_VERSION, LIBAO_SITE and LIBAO_SOURCE define
# the upstream location of the source code for the package.
# LIBAO_DIR is the directory which is created when the source
# archive is unpacked.
# LIBAO_UNZIP is the command used to unzip the source.
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
LIBAO_SITE=http://downloads.xiph.org/releases/ao
LIBAO_VERSION=0.8.6
LIBAO_SOURCE=libao-$(LIBAO_VERSION).tar.gz
LIBAO_DIR=libao-$(LIBAO_VERSION)
LIBAO_UNZIP=zcat
LIBAO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBAO_DESCRIPTION=Cross Platform Audio Library.
LIBAO_SECTION=lib
LIBAO_PRIORITY=optional
LIBAO_DEPENDS=
LIBAO_CONFLICTS=

#
# LIBAO_IPK_VERSION should be incremented when the ipk changes.
#
LIBAO_IPK_VERSION=2

#
# LIBAO_CONFFILES should be a list of user-editable files
LIBAO_CONFFILES=#/opt/etc/libao.conf /opt/etc/init.d/SXXlibao

#
# LIBAO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBAO_PATCHES=#$(LIBAO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBAO_CPPFLAGS=
LIBAO_LDFLAGS=

#
# LIBAO_BUILD_DIR is the directory in which the build is done.
# LIBAO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBAO_IPK_DIR is the directory in which the ipk is built.
# LIBAO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBAO_BUILD_DIR=$(BUILD_DIR)/libao
LIBAO_SOURCE_DIR=$(SOURCE_DIR)/libao
LIBAO_IPK_DIR=$(BUILD_DIR)/libao-$(LIBAO_VERSION)-ipk
LIBAO_IPK=$(BUILD_DIR)/libao_$(LIBAO_VERSION)-$(LIBAO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBAO_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBAO_SITE)/$(LIBAO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libao-source: $(DL_DIR)/$(LIBAO_SOURCE) $(LIBAO_PATCHES)

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
$(LIBAO_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBAO_SOURCE) $(LIBAO_PATCHES)
	$(MAKE) audiofile-stage esound-stage
	rm -rf $(BUILD_DIR)/$(LIBAO_DIR) $(LIBAO_BUILD_DIR)
	$(LIBAO_UNZIP) $(DL_DIR)/$(LIBAO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBAO_PATCHES) | patch -d $(BUILD_DIR)/$(LIBAO_DIR) -p1
	mv $(BUILD_DIR)/$(LIBAO_DIR) $(LIBAO_BUILD_DIR)
	(cd $(LIBAO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBAO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBAO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-esd \
		--disable-esdtest \
	        --disable-alsa \
		--disable-alsa09 \
	 	--disable-arts \
		--disable-nas \
	)
	touch $(LIBAO_BUILD_DIR)/.configured

libao-unpack: $(LIBAO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBAO_BUILD_DIR)/.built: $(LIBAO_BUILD_DIR)/.configured
	rm -f $(LIBAO_BUILD_DIR)/.built
	$(MAKE) -C $(LIBAO_BUILD_DIR)
	touch $(LIBAO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libao: $(LIBAO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBAO_BUILD_DIR)/.staged: $(LIBAO_BUILD_DIR)/.built
	rm -f $(LIBAO_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBAO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/ao.pc
	touch $(LIBAO_BUILD_DIR)/.staged

libao-stage: $(LIBAO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libao
#
$(LIBAO_IPK_DIR)/CONTROL/control:
	@install -d $(LIBAO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libao" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBAO_PRIORITY)" >>$@
	@echo "Section: $(LIBAO_SECTION)" >>$@
	@echo "Version: $(LIBAO_VERSION)-$(LIBAO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBAO_MAINTAINER)" >>$@
	@echo "Source: $(LIBAO_SITE)/$(LIBAO_SOURCE)" >>$@
	@echo "Description: $(LIBAO_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBAO_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBAO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBAO_IPK_DIR)/opt/sbin or $(LIBAO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBAO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBAO_IPK_DIR)/opt/etc/libao/...
# Documentation files should be installed in $(LIBAO_IPK_DIR)/opt/doc/libao/...
# Daemon startup scripts should be installed in $(LIBAO_IPK_DIR)/opt/etc/init.d/S??libao
#
# You may need to patch your application to make it use these locations.
#
$(LIBAO_IPK): $(LIBAO_BUILD_DIR)/.built
	rm -rf $(LIBAO_IPK_DIR) $(BUILD_DIR)/libao_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBAO_BUILD_DIR) DESTDIR=$(LIBAO_IPK_DIR) install
	#install -d $(LIBAO_IPK_DIR)/opt/etc/
	#install -m 644 $(LIBAO_SOURCE_DIR)/libao.conf $(LIBAO_IPK_DIR)/opt/etc/libao.conf
	#install -d $(LIBAO_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LIBAO_SOURCE_DIR)/rc.libao $(LIBAO_IPK_DIR)/opt/etc/init.d/SXXlibao
	$(MAKE) $(LIBAO_IPK_DIR)/CONTROL/control
	#install -m 755 $(LIBAO_SOURCE_DIR)/postinst $(LIBAO_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LIBAO_SOURCE_DIR)/prerm $(LIBAO_IPK_DIR)/CONTROL/prerm
	echo $(LIBAO_CONFFILES) | sed -e 's/ /\n/g' > $(LIBAO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBAO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libao-ipk: $(LIBAO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libao-clean:
	-$(MAKE) -C $(LIBAO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libao-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBAO_DIR) $(LIBAO_BUILD_DIR) $(LIBAO_IPK_DIR) $(LIBAO_IPK)
