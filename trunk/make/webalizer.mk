###########################################################
#
# webalizer
#
###########################################################

# You must replace "webalizer" and "WEBALIZER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WEBALIZER_VERSION, WEBALIZER_SITE and WEBALIZER_SOURCE define
# the upstream location of the source code for the package.
# WEBALIZER_DIR is the directory which is created when the source
# archive is unpacked.
# WEBALIZER_UNZIP is the command used to unzip the source.
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
WEBALIZER_SITE=ftp://ftp.mrunix.net/pub/webalizer
WEBALIZER_VERSION=2.01-10
WEBALIZER_SOURCE=webalizer-$(WEBALIZER_VERSION)-src.tgz
WEBALIZER_DIR=webalizer-$(WEBALIZER_VERSION)
WEBALIZER_UNZIP=zcat
WEBALIZER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WEBALIZER_DESCRIPTION=Webalizer is a webserver stats program. 
WEBALIZER_SECTION=web
WEBALIZER_PRIORITY=optional
WEBALIZER_DEPENDS=libgd
WEBALIZER_SUGGESTS=
WEBALIZER_CONFLICTS=

#
# WEBALIZER_IPK_VERSION should be incremented when the ipk changes.
#
WEBALIZER_IPK_VERSION=2

#
# WEBALIZER_CONFFILES should be a list of user-editable files
WEBALIZER_CONFFILES=/opt/etc/webalizer.conf.sample

#
# WEBALIZER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WEBALIZER_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WEBALIZER_CPPFLAGS=
WEBALIZER_LDFLAGS=

#
# WEBALIZER_BUILD_DIR is the directory in which the build is done.
# WEBALIZER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WEBALIZER_IPK_DIR is the directory in which the ipk is built.
# WEBALIZER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WEBALIZER_BUILD_DIR=$(BUILD_DIR)/webalizer
WEBALIZER_SOURCE_DIR=$(SOURCE_DIR)/webalizer
WEBALIZER_IPK_DIR=$(BUILD_DIR)/webalizer-$(WEBALIZER_VERSION)-ipk
WEBALIZER_IPK=$(BUILD_DIR)/webalizer_$(WEBALIZER_VERSION)-$(WEBALIZER_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WEBALIZER_SOURCE):
	$(WGET) -P $(DL_DIR) $(WEBALIZER_SITE)/$(WEBALIZER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
webalizer-source: $(DL_DIR)/$(WEBALIZER_SOURCE) $(WEBALIZER_PATCHES)

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
$(WEBALIZER_BUILD_DIR)/.configured: $(DL_DIR)/$(WEBALIZER_SOURCE) $(WEBALIZER_PATCHES)
	$(MAKE) libgd-stage
	rm -rf $(BUILD_DIR)/$(WEBALIZER_DIR) $(WEBALIZER_BUILD_DIR)
	$(WEBALIZER_UNZIP) $(DL_DIR)/$(WEBALIZER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(WEBALIZER_PATCHES) | patch -d $(BUILD_DIR)/$(WEBALIZER_DIR) -p1
	mv $(BUILD_DIR)/$(WEBALIZER_DIR) $(WEBALIZER_BUILD_DIR)
	(cd $(WEBALIZER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WEBALIZER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WEBALIZER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-gd=$(STAGING_DIR)/opt/include \
		--with-gdlib=$(STAGING_DIR)/opt/lib \
	)
	touch $(WEBALIZER_BUILD_DIR)/.configured

webalizer-unpack: $(WEBALIZER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WEBALIZER_BUILD_DIR)/.built: $(WEBALIZER_BUILD_DIR)/.configured
	rm -f $(WEBALIZER_BUILD_DIR)/.built
	$(MAKE) -C $(WEBALIZER_BUILD_DIR)
	touch $(WEBALIZER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
webalizer: $(WEBALIZER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WEBALIZER_BUILD_DIR)/.staged: $(WEBALIZER_BUILD_DIR)/.built
	rm -f $(WEBALIZER_BUILD_DIR)/.staged
	$(MAKE) -C $(WEBALIZER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(WEBALIZER_BUILD_DIR)/.staged

webalizer-stage: $(WEBALIZER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/webalizer
#
$(WEBALIZER_IPK_DIR)/CONTROL/control:
	@install -d $(WEBALIZER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: webalizer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WEBALIZER_PRIORITY)" >>$@
	@echo "Section: $(WEBALIZER_SECTION)" >>$@
	@echo "Version: $(WEBALIZER_VERSION)-$(WEBALIZER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WEBALIZER_MAINTAINER)" >>$@
	@echo "Source: $(WEBALIZER_SITE)/$(WEBALIZER_SOURCE)" >>$@
	@echo "Description: $(WEBALIZER_DESCRIPTION)" >>$@
	@echo "Depends: $(WEBALIZER_DEPENDS)" >>$@
	@echo "Suggests: $(WEBALIZER_SUGGESTS)" >>$@
	@echo "Conflicts: $(WEBALIZER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WEBALIZER_IPK_DIR)/opt/sbin or $(WEBALIZER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WEBALIZER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WEBALIZER_IPK_DIR)/opt/etc/webalizer/...
# Documentation files should be installed in $(WEBALIZER_IPK_DIR)/opt/doc/webalizer/...
# Daemon startup scripts should be installed in $(WEBALIZER_IPK_DIR)/opt/etc/init.d/S??webalizer
#
# You may need to patch your application to make it use these locations.
#
$(WEBALIZER_IPK): $(WEBALIZER_BUILD_DIR)/.built
	rm -rf $(WEBALIZER_IPK_DIR) $(BUILD_DIR)/webalizer_*_$(TARGET_ARCH).ipk
	install -d $(WEBALIZER_IPK_DIR)/opt/etc/
	install -d $(WEBALIZER_IPK_DIR)/opt/bin/
	install -m 644 $(WEBALIZER_BUILD_DIR)/sample.conf $(WEBALIZER_IPK_DIR)/opt/etc/webalizer.conf.sample
	install -m 755 $(WEBALIZER_BUILD_DIR)/webalizer $(WEBALIZER_IPK_DIR)/opt/bin/webalizer
	ln -s ./webalizer $(WEBALIZER_IPK_DIR)/opt/bin/webazolver
	$(MAKE) $(WEBALIZER_IPK_DIR)/CONTROL/control
	install -m 755 $(WEBALIZER_SOURCE_DIR)/postinst $(WEBALIZER_IPK_DIR)/CONTROL/postinst
	echo $(WEBALIZER_CONFFILES) | sed -e 's/ /\n/g' > $(WEBALIZER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WEBALIZER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
webalizer-ipk: $(WEBALIZER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
webalizer-clean:
	-$(MAKE) -C $(WEBALIZER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
webalizer-dirclean:
	rm -rf $(BUILD_DIR)/$(WEBALIZER_DIR) $(WEBALIZER_BUILD_DIR) $(WEBALIZER_IPK_DIR) $(WEBALIZER_IPK)
