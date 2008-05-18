###########################################################
#
# md5deep
#
###########################################################
#
# MD5DEEP_VERSION, MD5DEEP_SITE and MD5DEEP_SOURCE define
# the upstream location of the source code for the package.
# MD5DEEP_DIR is the directory which is created when the source
# archive is unpacked.
# MD5DEEP_UNZIP is the command used to unzip the source.
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
MD5DEEP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/md5deep
MD5DEEP_VERSION=3.0
MD5DEEP_SOURCE=md5deep-$(MD5DEEP_VERSION).tar.gz
MD5DEEP_DIR=md5deep-$(MD5DEEP_VERSION)
MD5DEEP_UNZIP=zcat
MD5DEEP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MD5DEEP_DESCRIPTION=md5deep is a cross-platform set of programs to compute MD5, SHA-1, SHA-256 Tiger, or Whirlpool message digests on an arbitrary number of files.
MD5DEEP_SECTION=utils
MD5DEEP_PRIORITY=optional
MD5DEEP_DEPENDS=
MD5DEEP_SUGGESTS=
MD5DEEP_CONFLICTS=

#
# MD5DEEP_IPK_VERSION should be incremented when the ipk changes.
#
MD5DEEP_IPK_VERSION=1

#
# MD5DEEP_CONFFILES should be a list of user-editable files
#MD5DEEP_CONFFILES=/opt/etc/md5deep.conf /opt/etc/init.d/SXXmd5deep

#
# MD5DEEP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MD5DEEP_PATCHES=$(MD5DEEP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MD5DEEP_CPPFLAGS=
MD5DEEP_LDFLAGS=

#
# MD5DEEP_BUILD_DIR is the directory in which the build is done.
# MD5DEEP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MD5DEEP_IPK_DIR is the directory in which the ipk is built.
# MD5DEEP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MD5DEEP_BUILD_DIR=$(BUILD_DIR)/md5deep
MD5DEEP_SOURCE_DIR=$(SOURCE_DIR)/md5deep
MD5DEEP_IPK_DIR=$(BUILD_DIR)/md5deep-$(MD5DEEP_VERSION)-ipk
MD5DEEP_IPK=$(BUILD_DIR)/md5deep_$(MD5DEEP_VERSION)-$(MD5DEEP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: md5deep-source md5deep-unpack md5deep md5deep-stage md5deep-ipk md5deep-clean md5deep-dirclean md5deep-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MD5DEEP_SOURCE):
	$(WGET) -P $(@D) $(MD5DEEP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
md5deep-source: $(DL_DIR)/$(MD5DEEP_SOURCE) $(MD5DEEP_PATCHES)

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
$(MD5DEEP_BUILD_DIR)/.configured: $(DL_DIR)/$(MD5DEEP_SOURCE) $(MD5DEEP_PATCHES) make/md5deep.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MD5DEEP_DIR) $(@D)
	$(MD5DEEP_UNZIP) $(DL_DIR)/$(MD5DEEP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MD5DEEP_PATCHES)" ; \
		then cat $(MD5DEEP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MD5DEEP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MD5DEEP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MD5DEEP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MD5DEEP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MD5DEEP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

md5deep-unpack: $(MD5DEEP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MD5DEEP_BUILD_DIR)/.built: $(MD5DEEP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
md5deep: $(MD5DEEP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MD5DEEP_BUILD_DIR)/.staged: $(MD5DEEP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

md5deep-stage: $(MD5DEEP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/md5deep
#
$(MD5DEEP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: md5deep" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MD5DEEP_PRIORITY)" >>$@
	@echo "Section: $(MD5DEEP_SECTION)" >>$@
	@echo "Version: $(MD5DEEP_VERSION)-$(MD5DEEP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MD5DEEP_MAINTAINER)" >>$@
	@echo "Source: $(MD5DEEP_SITE)/$(MD5DEEP_SOURCE)" >>$@
	@echo "Description: $(MD5DEEP_DESCRIPTION)" >>$@
	@echo "Depends: $(MD5DEEP_DEPENDS)" >>$@
	@echo "Suggests: $(MD5DEEP_SUGGESTS)" >>$@
	@echo "Conflicts: $(MD5DEEP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MD5DEEP_IPK_DIR)/opt/sbin or $(MD5DEEP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MD5DEEP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MD5DEEP_IPK_DIR)/opt/etc/md5deep/...
# Documentation files should be installed in $(MD5DEEP_IPK_DIR)/opt/doc/md5deep/...
# Daemon startup scripts should be installed in $(MD5DEEP_IPK_DIR)/opt/etc/init.d/S??md5deep
#
# You may need to patch your application to make it use these locations.
#
$(MD5DEEP_IPK): $(MD5DEEP_BUILD_DIR)/.built
	rm -rf $(MD5DEEP_IPK_DIR) $(BUILD_DIR)/md5deep_*_$(TARGET_ARCH).ipk
	install -d $(MD5DEEP_BUILD_DIR)/opt/bin $(MD5DEEP_BUILD_DIR)/opt/man/man1
	$(MAKE) -C $(MD5DEEP_BUILD_DIR) install-strip DESTDIR=$(MD5DEEP_IPK_DIR)
#	install -d $(MD5DEEP_IPK_DIR)/opt/etc/
#	install -m 644 $(MD5DEEP_SOURCE_DIR)/md5deep.conf $(MD5DEEP_IPK_DIR)/opt/etc/md5deep.conf
#	install -d $(MD5DEEP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MD5DEEP_SOURCE_DIR)/rc.md5deep $(MD5DEEP_IPK_DIR)/opt/etc/init.d/SXXmd5deep
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MD5DEEP_IPK_DIR)/opt/etc/init.d/SXXmd5deep
	$(MAKE) $(MD5DEEP_IPK_DIR)/CONTROL/control
#	install -m 755 $(MD5DEEP_SOURCE_DIR)/postinst $(MD5DEEP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MD5DEEP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MD5DEEP_SOURCE_DIR)/prerm $(MD5DEEP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MD5DEEP_IPK_DIR)/CONTROL/prerm
	echo $(MD5DEEP_CONFFILES) | sed -e 's/ /\n/g' > $(MD5DEEP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MD5DEEP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
md5deep-ipk: $(MD5DEEP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
md5deep-clean:
	rm -f $(MD5DEEP_BUILD_DIR)/.built
	-$(MAKE) -C $(MD5DEEP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
md5deep-dirclean:
	rm -rf $(BUILD_DIR)/$(MD5DEEP_DIR) $(MD5DEEP_BUILD_DIR) $(MD5DEEP_IPK_DIR) $(MD5DEEP_IPK)
#
#
# Some sanity check for the package.
#
md5deep-check: $(MD5DEEP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MD5DEEP_IPK)
