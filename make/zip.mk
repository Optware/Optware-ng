###########################################################
#
# zip
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
ZIP_SITE=ftp://ctan.unik.no/tex-archive/tools/zip/info-zip/src
ZIP_VERSION_MAJOR=2
ZIP_VERSION_MINOR=32
ZIP_VERSION=$(ZIP_VERSION_MAJOR).$(ZIP_VERSION_MINOR)
ZIP_VERSION_FILE=$(ZIP_VERSION_MAJOR)$(ZIP_VERSION_MINOR)
ZIP_SOURCE=zip$(ZIP_VERSION_FILE).tar.gz
ZIP_DIR=zip-$(ZIP_VERSION)
ZIP_UNZIP=zcat
ZIP_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
ZIP_DESCRIPTION=a compression and file packaging utility.
ZIP_SECTION=admin
ZIP_PRIORITY=optional
ZIP_DEPENDS=
ZIP_SUGGESTS=
ZIP_CONFLICTS=

#
# ZIP_IPK_VERSION should be incremented when the ipk changes.
#
ZIP_IPK_VERSION=1

#
# ZIP_CONFFILES should be a list of user-editable files
ZIP_CONFFILES=

#
# ZIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ZIP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ZIP_CPPFLAGS=
ZIP_LDFLAGS=

#
# ZIP_BUILD_DIR is the directory in which the build is done.
# ZIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ZIP_IPK_DIR is the directory in which the ipk is built.
# ZIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ZIP_BUILD_DIR=$(BUILD_DIR)/zip
ZIP_SOURCE_DIR=$(SOURCE_DIR)/zip
ZIP_IPK_DIR=$(BUILD_DIR)/zip-$(ZIP_VERSION)-ipk
ZIP_IPK=$(BUILD_DIR)/zip_$(ZIP_VERSION)-$(ZIP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ZIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZIP_SITE)/$(ZIP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
zip-source: $(DL_DIR)/$(ZIP_SOURCE) $(ZIP_PATCHES)

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
$(ZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(ZIP_SOURCE) $(ZIP_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ZIP_DIR) $(ZIP_BUILD_DIR)
	$(ZIP_UNZIP) $(DL_DIR)/$(ZIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ZIP_PATCHES)" ; \
		then cat $(ZIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ZIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ZIP_DIR)" != "$(ZIP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ZIP_DIR) $(ZIP_BUILD_DIR) ; \
	fi
	#(cd $(ZIP_BUILD_DIR); \
	#	$(TARGET_CONFIGURE_OPTS) \
	#	CPPFLAGS="$(STAGING_CPPFLAGS) $(ZIP_CPPFLAGS)" \
	#	LDFLAGS="$(STAGING_LDFLAGS) $(ZIP_LDFLAGS)" \
	#	./configure \
	#	--build=$(GNU_HOST_NAME) \
	#	--host=$(GNU_TARGET_NAME) \
	#	--target=$(GNU_TARGET_NAME) \
	#	--prefix=/opt \
	#	--disable-nls \
	#	--disable-static \
	#)
	#$(PATCH_LIBTOOL) $(ZIP_BUILD_DIR)/libtool
	touch $(ZIP_BUILD_DIR)/.configured

zip-unpack: $(ZIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ZIP_BUILD_DIR)/.built: $(ZIP_BUILD_DIR)/.configured
	rm -f $(ZIP_BUILD_DIR)/.built
	$(MAKE) -C $(ZIP_BUILD_DIR) -f unix/Makefile generic	\
		$(TARGET_CONFIGURE_OPTS) 			\
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ZIP_CPPFLAGS)"	\
		LDFLAGS="$(STAGING_LDFLAGS) $(ZIP_LDFLAGS)"
		
	touch $(ZIP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
zip: $(ZIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ZIP_BUILD_DIR)/.staged: $(ZIP_BUILD_DIR)/.built
	rm -f $(ZIP_BUILD_DIR)/.staged
	$(MAKE) -C $(ZIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ZIP_BUILD_DIR)/.staged

zip-stage: $(ZIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/zip
#
$(ZIP_IPK_DIR)/CONTROL/control:
	@install -d $(ZIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: zip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZIP_PRIORITY)" >>$@
	@echo "Section: $(ZIP_SECTION)" >>$@
	@echo "Version: $(ZIP_VERSION)-$(ZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZIP_MAINTAINER)" >>$@
	@echo "Source: $(ZIP_SITE)/$(ZIP_SOURCE)" >>$@
	@echo "Description: $(ZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(ZIP_DEPENDS)" >>$@
	@echo "Suggests: $(ZIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(ZIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ZIP_IPK_DIR)/opt/sbin or $(ZIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ZIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ZIP_IPK_DIR)/opt/etc/zip/...
# Documentation files should be installed in $(ZIP_IPK_DIR)/opt/doc/zip/...
# Daemon startup scripts should be installed in $(ZIP_IPK_DIR)/opt/etc/init.d/S??zip
#
# You may need to patch your application to make it use these locations.
#
$(ZIP_IPK): $(ZIP_BUILD_DIR)/.built
	rm -rf $(ZIP_IPK_DIR) $(BUILD_DIR)/zip_*_$(TARGET_ARCH).ipk
	install -d $(ZIP_IPK_DIR)/opt/bin
	install -m 755 $(ZIP_BUILD_DIR)/zip $(ZIP_IPK_DIR)/opt/bin
	install -m 755 $(ZIP_BUILD_DIR)/zipsplit $(ZIP_IPK_DIR)/opt/bin
	install -m 755 $(ZIP_BUILD_DIR)/zipnote $(ZIP_IPK_DIR)/opt/bin
	install -m 755 $(ZIP_BUILD_DIR)/zipcloak $(ZIP_IPK_DIR)/opt/bin
	$(STRIP_COMMAND)  $(ZIP_IPK_DIR)/opt/bin/*
	$(MAKE) $(ZIP_IPK_DIR)/CONTROL/control
	# install -m 755 $(ZIP_SOURCE_DIR)/postinst $(ZIP_IPK_DIR)/CONTROL/postinst
	# install -m 755 $(ZIP_SOURCE_DIR)/prerm $(ZIP_IPK_DIR)/CONTROL/prerm
	echo $(ZIP_CONFFILES) | sed -e 's/ /\n/g' > $(ZIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
zip-ipk: $(ZIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
zip-clean:
	rm -f $(ZIP_BUILD_DIR)/.built
	-$(MAKE) -C $(ZIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
zip-dirclean:
	rm -rf $(BUILD_DIR)/$(ZIP_DIR) $(ZIP_BUILD_DIR) $(ZIP_IPK_DIR) $(ZIP_IPK)
