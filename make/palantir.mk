###########################################################
#
# palantir
#
###########################################################
#
# PALANTIR_VERSION, PALANTIR_SITE and PALANTIR_SOURCE define
# the upstream location of the source code for the package.
# PALANTIR_DIR is the directory which is created when the source
# archive is unpacked.
# PALANTIR_UNZIP is the command used to unzip the source.
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
PALANTIR_SITE=http://www.fastpath.it/products/palantir/pub
PALANTIR_VERSION=2.6
PALANTIR_SOURCE=palantir-$(PALANTIR_VERSION).tgz
PALANTIR_DIR=palantir-$(PALANTIR_VERSION)
PALANTIR_UNZIP=zcat
PALANTIR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PALANTIR_DESCRIPTION=Multichannel interactive streaming solution
PALANTIR_SECTION=net
PALANTIR_PRIORITY=optional
PALANTIR_DEPENDS=libjpeg
PALANTIR_SUGGESTS=
PALANTIR_CONFLICTS=

#
# PALANTIR_IPK_VERSION should be incremented when the ipk changes.
#
PALANTIR_IPK_VERSION=1

#
# PALANTIR_CONFFILES should be a list of user-editable files
PALANTIR_CONFFILES=/opt/etc/palantir.conf

#
# PALANTIR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PALANTIR_PATCHES=$(PALANTIR_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PALANTIR_CPPFLAGS=
PALANTIR_LDFLAGS=

#
# PALANTIR_BUILD_DIR is the directory in which the build is done.
# PALANTIR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PALANTIR_IPK_DIR is the directory in which the ipk is built.
# PALANTIR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PALANTIR_BUILD_DIR=$(BUILD_DIR)/palantir
PALANTIR_SOURCE_DIR=$(SOURCE_DIR)/palantir
PALANTIR_IPK_DIR=$(BUILD_DIR)/palantir-$(PALANTIR_VERSION)-ipk
PALANTIR_IPK=$(BUILD_DIR)/palantir_$(PALANTIR_VERSION)-$(PALANTIR_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PALANTIR_SOURCE):
	$(WGET) -P $(DL_DIR) $(PALANTIR_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
palantir-source: $(DL_DIR)/$(PALANTIR_SOURCE) $(PALANTIR_PATCHES)

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
$(PALANTIR_BUILD_DIR)/.configured: $(DL_DIR)/$(PALANTIR_SOURCE) $(PALANTIR_PATCHES)
	$(MAKE) libjpeg-stage
	rm -rf $(BUILD_DIR)/$(PALANTIR_DIR) $(PALANTIR_BUILD_DIR)
	$(PALANTIR_UNZIP) $(DL_DIR)/$(PALANTIR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PALANTIR_PATCHES)" ; \
		then cat $(PALANTIR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PALANTIR_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PALANTIR_DIR)" != "$(PALANTIR_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PALANTIR_DIR) $(PALANTIR_BUILD_DIR) ; \
	fi
#	(cd $(PALANTIR_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(PALANTIR_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(PALANTIR_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
#	$(PATCH_LIBTOOL) $(PALANTIR_BUILD_DIR)/libtool
	touch $(PALANTIR_BUILD_DIR)/.configured

palantir-unpack: $(PALANTIR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PALANTIR_BUILD_DIR)/.built: $(PALANTIR_BUILD_DIR)/.configured
	rm -f $(PALANTIR_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(PALANTIR_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(PALANTIR_LDFLAGS)" \
	$(MAKE) -C $(PALANTIR_BUILD_DIR)/server
	touch $(PALANTIR_BUILD_DIR)/.built

#
# This is the build convenience target.
#
palantir: $(PALANTIR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PALANTIR_BUILD_DIR)/.staged: $(PALANTIR_BUILD_DIR)/.built
	rm -f $(PALANTIR_BUILD_DIR)/.staged
	$(MAKE) -C $(PALANTIR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PALANTIR_BUILD_DIR)/.staged

palantir-stage: $(PALANTIR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/palantir
#
$(PALANTIR_IPK_DIR)/CONTROL/control:
	@install -d $(PALANTIR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: palantir" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PALANTIR_PRIORITY)" >>$@
	@echo "Section: $(PALANTIR_SECTION)" >>$@
	@echo "Version: $(PALANTIR_VERSION)-$(PALANTIR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PALANTIR_MAINTAINER)" >>$@
	@echo "Source: $(PALANTIR_SITE)/$(PALANTIR_SOURCE)" >>$@
	@echo "Description: $(PALANTIR_DESCRIPTION)" >>$@
	@echo "Depends: $(PALANTIR_DEPENDS)" >>$@
	@echo "Suggests: $(PALANTIR_SUGGESTS)" >>$@
	@echo "Conflicts: $(PALANTIR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PALANTIR_IPK_DIR)/opt/sbin or $(PALANTIR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PALANTIR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PALANTIR_IPK_DIR)/opt/etc/palantir/...
# Documentation files should be installed in $(PALANTIR_IPK_DIR)/opt/doc/palantir/...
# Daemon startup scripts should be installed in $(PALANTIR_IPK_DIR)/opt/etc/init.d/S??palantir
#
# You may need to patch your application to make it use these locations.


#
$(PALANTIR_IPK): $(PALANTIR_BUILD_DIR)/.built
	rm -rf $(PALANTIR_IPK_DIR) $(BUILD_DIR)/palantir_*_$(TARGET_ARCH).ipk
	install -d $(PALANTIR_IPK_DIR)/opt/bin
	install -m 755 $(PALANTIR_BUILD_DIR)/server/palantir $(PALANTIR_IPK_DIR)/opt/bin
	install -m 755 $(PALANTIR_BUILD_DIR)/server/tools/sysfeed $(PALANTIR_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PALANTIR_IPK_DIR)/opt/bin/palantir
	$(STRIP_COMMAND) $(PALANTIR_IPK_DIR)/opt/bin/sysfeed
	install -d $(PALANTIR_IPK_DIR)/opt/etc/
	install -m 644 $(PALANTIR_BUILD_DIR)/server/palantir-mips.conf.sample $(PALANTIR_IPK_DIR)/opt/etc/palantir.conf
	install -d $(PALANTIR_IPK_DIR)/opt/share/palantir
	install -m 644 $(PALANTIR_BUILD_DIR)/server/pict/unavail.jpg $(PALANTIR_IPK_DIR)/opt/share/palantir
	mkfifo $(PALANTIR_IPK_DIR)/opt/share/palantir/telmu_pipe
	install -d $(PALANTIR_IPK_DIR)/opt/man/man1
	install -d $(PALANTIR_IPK_DIR)/opt/man/man5
	install -m 644 $(PALANTIR_BUILD_DIR)/server/man/palantir.1 $(PALANTIR_IPK_DIR)/opt/man/man1
	install -m 644 $(PALANTIR_BUILD_DIR)/server/man/palantir.conf.5 $(PALANTIR_IPK_DIR)/opt/man/man5
#	install -d $(PALANTIR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PALANTIR_SOURCE_DIR)/rc.palantir $(PALANTIR_IPK_DIR)/opt/etc/init.d/SXXpalantir
	$(MAKE) $(PALANTIR_IPK_DIR)/CONTROL/control
#	install -m 755 $(PALANTIR_SOURCE_DIR)/postinst $(PALANTIR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PALANTIR_SOURCE_DIR)/prerm $(PALANTIR_IPK_DIR)/CONTROL/prerm
	echo $(PALANTIR_CONFFILES) | sed -e 's/ /\n/g' > $(PALANTIR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PALANTIR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
palantir-ipk: $(PALANTIR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
palantir-clean:
	rm -f $(PALANTIR_BUILD_DIR)/.built
	-$(MAKE) -C $(PALANTIR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
palantir-dirclean:
	rm -rf $(BUILD_DIR)/$(PALANTIR_DIR) $(PALANTIR_BUILD_DIR) $(PALANTIR_IPK_DIR) $(PALANTIR_IPK)
