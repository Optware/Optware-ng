###########################################################
#
# bzflag
#
###########################################################

#
# BZFLAG_VERSION, BZFLAG_SITE and BZFLAG_SOURCE define
# the upstream location of the source code for the package.
# BZFLAG_DIR is the directory which is created when the source
# archive is unpacked.
# BZFLAG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
BZFLAG_SITE=http://ftp.bzflag.org/bzflag
BZFLAG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/bzflag
BZFLAG_VERSION=2.0.12
BZFLAG_SOURCE=bzflag-$(BZFLAG_VERSION).tar.gz
BZFLAG_DIR=bzflag-$(BZFLAG_VERSION)
BZFLAG_UNZIP=zcat
BZFLAG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BZFLAG_DESCRIPTION=bzflag server
BZFLAG_SECTION=games
BZFLAG_PRIORITY=optional
BZFLAG_DEPENDS=libstdc++, c-ares, libcurl, ncurses, openssl, zlib
BZFLAG_SUGGESTS=
BZFLAG_CONFLICTS=

#
# BZFLAG_IPK_VERSION should be incremented when the ipk changes.
#
BZFLAG_IPK_VERSION=1

#
# BZFLAG_CONFFILES should be a list of user-editable files
BZFLAG_CONFFILES=

#
# BZFLAG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BZFLAG_PATCHES=$(BZFLAG_SOURCE_DIR)/bzflag-configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BZFLAG_CPPFLAGS=
BZFLAG_LDFLAGS=

#
# BZFLAG_BUILD_DIR is the directory in which the build is done.
# BZFLAG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BZFLAG_IPK_DIR is the directory in which the ipk is built.
# BZFLAG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BZFLAG_BUILD_DIR=$(BUILD_DIR)/bzflag
BZFLAG_SOURCE_DIR=$(SOURCE_DIR)/bzflag
BZFLAG_IPK_DIR=$(BUILD_DIR)/bzflag-$(BZFLAG_VERSION)-ipk
BZFLAG_IPK=$(BUILD_DIR)/bzflag_$(BZFLAG_VERSION)-$(BZFLAG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bzflag-source bzflag-unpack bzflag bzflag-stage bzflag-ipk bzflag-clean bzflag-dirclean bzflag-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BZFLAG_SOURCE):
	$(WGET) -P $(@D) $(BZFLAG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bzflag-source: $(DL_DIR)/$(BZFLAG_SOURCE) $(BZFLAG_PATCHES)

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
$(BZFLAG_BUILD_DIR)/.configured: $(DL_DIR)/$(BZFLAG_SOURCE) $(BZFLAG_PATCHES) make/bzflag.mk
	$(MAKE) c-ares-stage libstdc++-stage
	$(MAKE) zlib-stage libcurl-stage ncurses-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(BZFLAG_DIR) $(BZFLAG_BUILD_DIR)
	$(BZFLAG_UNZIP) $(DL_DIR)/$(BZFLAG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZFLAG_PATCHES) | patch -d $(BUILD_DIR)/$(BZFLAG_DIR) -p1
	mv $(BUILD_DIR)/$(BZFLAG_DIR) $(@D)
	# install gl headers needed by bzadmin
#	install -d $(@D)/include/GL
#	install -m 644 $(BZFLAG_SOURCE_DIR)/*.h $(@D)/include/GL
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/bin:$(PATH)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BZFLAG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BZFLAG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--disable-nls \
		--disable-client \
		--without-SDL \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bzflag-unpack: $(BZFLAG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BZFLAG_BUILD_DIR)/.built: $(BZFLAG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bzflag: $(BZFLAG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BZFLAG_BUILD_DIR)/.staged: $(BZFLAG_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bzflag-stage: $(BZFLAG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bzflag
#
$(BZFLAG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bzflag" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZFLAG_PRIORITY)" >>$@
	@echo "Section: $(BZFLAG_SECTION)" >>$@
	@echo "Version: $(BZFLAG_VERSION)-$(BZFLAG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZFLAG_MAINTAINER)" >>$@
	@echo "Source: $(BZFLAG_SITE)/$(BZFLAG_SOURCE)" >>$@
	@echo "Description: $(BZFLAG_DESCRIPTION)" >>$@
	@echo "Depends: $(BZFLAG_DEPENDS)" >>$@
	@echo "Suggests: $(BZFLAG_SUGGESTS)" >>$@
	@echo "Conflicts: $(BZFLAG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BZFLAG_IPK_DIR)/opt/sbin or $(BZFLAG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BZFLAG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BZFLAG_IPK_DIR)/opt/etc/bzflag/...
# Documentation files should be installed in $(BZFLAG_IPK_DIR)/opt/doc/bzflag/...
# Daemon startup scripts should be installed in $(BZFLAG_IPK_DIR)/opt/etc/init.d/S??bzflag
#
# You may need to patch your application to make it use these locations.
#
$(BZFLAG_IPK): $(BZFLAG_BUILD_DIR)/.built
	rm -rf $(BZFLAG_IPK_DIR) $(BUILD_DIR)/bzflag_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BZFLAG_BUILD_DIR) DESTDIR=$(BZFLAG_IPK_DIR) install
	# contents of /share are not needed by a dedicated server
	rm -rf $(BZFLAG_IPK_DIR)/opt/share
	# strip binaries
	$(STRIP_COMMAND) $(BZFLAG_IPK_DIR)/opt/bin/bzfs $(BZFLAG_IPK_DIR)/opt/bin/bzadmin
#	install -d $(BZFLAG_IPK_DIR)/opt/etc/
#	install -m 755 $(BZFLAG_SOURCE_DIR)/bzflag.conf $(BZFLAG_IPK_DIR)/opt/etc/bzflag.conf
#	install -d $(BZFLAG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(BZFLAG_SOURCE_DIR)/rc.bzflag $(BZFLAG_IPK_DIR)/opt/etc/init.d/SXXbzflag
	$(MAKE) $(BZFLAG_IPK_DIR)/CONTROL/control
#	install -m 644 $(BZFLAG_SOURCE_DIR)/postinst $(BZFLAG_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(BZFLAG_SOURCE_DIR)/prerm $(BZFLAG_IPK_DIR)/CONTROL/prerm
#	echo $(BZFLAG_CONFFILES) | sed -e 's/ /\n/g' > $(BZFLAG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BZFLAG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bzflag-ipk: $(BZFLAG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bzflag-clean:
	-$(MAKE) -C $(BZFLAG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bzflag-dirclean:
	rm -rf $(BUILD_DIR)/$(BZFLAG_DIR) $(BZFLAG_BUILD_DIR) $(BZFLAG_IPK_DIR) $(BZFLAG_IPK)

#
# Some sanity check for the package.
#
bzflag-check: $(BZFLAG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
