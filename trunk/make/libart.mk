###########################################################
#
# libart
#
###########################################################

# You must replace "libart" and "LIBART" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBART_VERSION, LIBART_SITE and LIBART_SOURCE define
# the upstream location of the source code for the package.
# LIBART_DIR is the directory which is created when the source
# archive is unpacked.
# LIBART_UNZIP is the command used to unzip the source.
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
LIBART_SITE=ftp://ftp.gnome.org/pub/GNOME/sources/libart_lgpl/2.3/
LIBART_VERSION=2.3.17
LIBART_SOURCE=libart_lgpl-$(LIBART_VERSION).tar.gz
LIBART_DIR=libart_lgpl-$(LIBART_VERSION)
LIBART_UNZIP=zcat
LIBART_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBART_DESCRIPTION=2-d graphics library.
LIBART_SECTION=libs
LIBART_PRIORITY=optional
LIBART_DEPENDS=
LIBART_SUGGESTS=
LIBART_CONFLICTS=

#
# LIBART_IPK_VERSION should be incremented when the ipk changes.
#
LIBART_IPK_VERSION=1

#
# LIBART_CONFFILES should be a list of user-editable files
#LIBART_CONFFILES=/opt/etc/libart.conf /opt/etc/init.d/SXXlibart

#
# LIBART_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBART_PATCHES=$(LIBART_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBART_CPPFLAGS=
LIBART_LDFLAGS=

#
# LIBART_BUILD_DIR is the directory in which the build is done.
# LIBART_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBART_IPK_DIR is the directory in which the ipk is built.
# LIBART_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBART_BUILD_DIR=$(BUILD_DIR)/libart
LIBART_SOURCE_DIR=$(SOURCE_DIR)/libart
LIBART_IPK_DIR=$(BUILD_DIR)/libart-$(LIBART_VERSION)-ipk
LIBART_IPK=$(BUILD_DIR)/libart_$(LIBART_VERSION)-$(LIBART_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBART_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBART_SITE)/$(LIBART_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libart-source: $(DL_DIR)/$(LIBART_SOURCE) $(LIBART_PATCHES)

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
$(LIBART_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBART_SOURCE) $(LIBART_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBART_DIR) $(LIBART_BUILD_DIR)
	$(LIBART_UNZIP) $(DL_DIR)/$(LIBART_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBART_PATCHES) | patch -d $(BUILD_DIR)/$(LIBART_DIR) -p1
	mv $(BUILD_DIR)/$(LIBART_DIR) $(LIBART_BUILD_DIR)
	(cd $(LIBART_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBART_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBART_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-shared \
		--disable-static \
	)
	touch $(LIBART_BUILD_DIR)/gen_art_config
	cp $(LIBART_SOURCE_DIR)/art_config.h $(LIBART_BUILD_DIR)
	touch $(LIBART_BUILD_DIR)/.configured

libart-unpack: $(LIBART_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBART_BUILD_DIR)/.built: $(LIBART_BUILD_DIR)/.configured
	rm -f $(LIBART_BUILD_DIR)/.built
	$(MAKE) -C $(LIBART_BUILD_DIR)
	touch $(LIBART_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libart: $(LIBART_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBART_BUILD_DIR)/.staged: $(LIBART_BUILD_DIR)/.built
	rm -f $(LIBART_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBART_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBART_BUILD_DIR)/.staged

libart-stage: $(LIBART_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libart
#
$(LIBART_IPK_DIR)/CONTROL/control:
	@install -d $(LIBART_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libart" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBART_PRIORITY)" >>$@
	@echo "Section: $(LIBART_SECTION)" >>$@
	@echo "Version: $(LIBART_VERSION)-$(LIBART_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBART_MAINTAINER)" >>$@
	@echo "Source: $(LIBART_SITE)/$(LIBART_SOURCE)" >>$@
	@echo "Description: $(LIBART_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBART_DEPENDS)" >>$@
	@echo "Suggests: $(LIBART_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBART_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBART_IPK_DIR)/opt/sbin or $(LIBART_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBART_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBART_IPK_DIR)/opt/etc/libart/...
# Documentation files should be installed in $(LIBART_IPK_DIR)/opt/doc/libart/...
# Daemon startup scripts should be installed in $(LIBART_IPK_DIR)/opt/etc/init.d/S??libart
#
# You may need to patch your application to make it use these locations.
#
$(LIBART_IPK): $(LIBART_BUILD_DIR)/.built
	rm -rf $(LIBART_IPK_DIR) $(BUILD_DIR)/libart_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBART_BUILD_DIR) DESTDIR=$(LIBART_IPK_DIR) install-strip
#	install -d $(LIBART_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBART_SOURCE_DIR)/libart.conf $(LIBART_IPK_DIR)/opt/etc/libart.conf
#	install -d $(LIBART_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBART_SOURCE_DIR)/rc.libart $(LIBART_IPK_DIR)/opt/etc/init.d/SXXlibart
	$(MAKE) $(LIBART_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBART_SOURCE_DIR)/postinst $(LIBART_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBART_SOURCE_DIR)/prerm $(LIBART_IPK_DIR)/CONTROL/prerm
	echo $(LIBART_CONFFILES) | sed -e 's/ /\n/g' > $(LIBART_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBART_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libart-ipk: $(LIBART_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libart-clean:
	-$(MAKE) -C $(LIBART_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libart-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBART_DIR) $(LIBART_BUILD_DIR) $(LIBART_IPK_DIR) $(LIBART_IPK)
