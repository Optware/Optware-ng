###########################################################
#
# cryptcat
#
###########################################################
#
# CRYPTCAT_VERSION, CRYPTCAT_SITE and CRYPTCAT_SOURCE define
# the upstream location of the source code for the package.
# CRYPTCAT_DIR is the directory which is created when the source
# archive is unpacked.
# CRYPTCAT_UNZIP is the command used to unzip the source.
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
CRYPTCAT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/cryptcat
CRYPTCAT_VERSION=1.2.1
CRYPTCAT_SOURCE=cryptcat-unix-$(CRYPTCAT_VERSION).tar
CRYPTCAT_DIR=unix
CRYPTCAT_UNZIP=cat
CRYPTCAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CRYPTCAT_DESCRIPTION=Cryptcat is the standard netcat enhanced with twofish encryption
CRYPTCAT_SECTION=net
CRYPTCAT_PRIORITY=optional
CRYPTCAT_DEPENDS=
CRYPTCAT_SUGGESTS=
CRYPTCAT_CONFLICTS=

#
# CRYPTCAT_IPK_VERSION should be incremented when the ipk changes.
#
CRYPTCAT_IPK_VERSION=1

#
# CRYPTCAT_CONFFILES should be a list of user-editable files
#CRYPTCAT_CONFFILES=/opt/etc/cryptcat.conf /opt/etc/init.d/SXXcryptcat

#
# CRYPTCAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CRYPTCAT_PATCHES=$(CRYPTCAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CRYPTCAT_CPPFLAGS=
CRYPTCAT_LDFLAGS=

#
# CRYPTCAT_BUILD_DIR is the directory in which the build is done.
# CRYPTCAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CRYPTCAT_IPK_DIR is the directory in which the ipk is built.
# CRYPTCAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CRYPTCAT_BUILD_DIR=$(BUILD_DIR)/cryptcat
CRYPTCAT_SOURCE_DIR=$(SOURCE_DIR)/cryptcat
CRYPTCAT_IPK_DIR=$(BUILD_DIR)/cryptcat-$(CRYPTCAT_VERSION)-ipk
CRYPTCAT_IPK=$(BUILD_DIR)/cryptcat_$(CRYPTCAT_VERSION)-$(CRYPTCAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cryptcat-source cryptcat-unpack cryptcat cryptcat-stage cryptcat-ipk cryptcat-clean cryptcat-dirclean cryptcat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CRYPTCAT_SOURCE):
	$(WGET) -P $(@D) $(CRYPTCAT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cryptcat-source: $(DL_DIR)/$(CRYPTCAT_SOURCE) $(CRYPTCAT_PATCHES)

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
$(CRYPTCAT_BUILD_DIR)/.configured: $(DL_DIR)/$(CRYPTCAT_SOURCE) $(CRYPTCAT_PATCHES) make/cryptcat.mk
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(CRYPTCAT_DIR) $(@D)
	$(CRYPTCAT_UNZIP) $(DL_DIR)/$(CRYPTCAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CRYPTCAT_PATCHES)" ; \
		then cat $(CRYPTCAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CRYPTCAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CRYPTCAT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CRYPTCAT_DIR) $(@D) ; \
	fi
#	sed -i -e '/DLINUX/s|STATIC=-static ||' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CRYPTCAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CRYPTCAT_LDFLAGS)" \
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

cryptcat-unpack: $(CRYPTCAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CRYPTCAT_BUILD_DIR)/.built: $(CRYPTCAT_BUILD_DIR)/.configured
	rm -f $@
#		LD='$(TARGET_CC) $$(LDFLAGS)'
	$(MAKE) -C $(@D) linux \
		$(TARGET_CONFIGURE_OPTS) \
		CC='$(TARGET_CXX) -O' \
		LD='$(TARGET_CC)' \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CRYPTCAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CRYPTCAT_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
cryptcat: $(CRYPTCAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(CRYPTCAT_BUILD_DIR)/.staged: $(CRYPTCAT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#cryptcat-stage: $(CRYPTCAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cryptcat
#
$(CRYPTCAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cryptcat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CRYPTCAT_PRIORITY)" >>$@
	@echo "Section: $(CRYPTCAT_SECTION)" >>$@
	@echo "Version: $(CRYPTCAT_VERSION)-$(CRYPTCAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CRYPTCAT_MAINTAINER)" >>$@
	@echo "Source: $(CRYPTCAT_SITE)/$(CRYPTCAT_SOURCE)" >>$@
	@echo "Description: $(CRYPTCAT_DESCRIPTION)" >>$@
	@echo "Depends: $(CRYPTCAT_DEPENDS)" >>$@
	@echo "Suggests: $(CRYPTCAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CRYPTCAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CRYPTCAT_IPK_DIR)/opt/sbin or $(CRYPTCAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CRYPTCAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CRYPTCAT_IPK_DIR)/opt/etc/cryptcat/...
# Documentation files should be installed in $(CRYPTCAT_IPK_DIR)/opt/doc/cryptcat/...
# Daemon startup scripts should be installed in $(CRYPTCAT_IPK_DIR)/opt/etc/init.d/S??cryptcat
#
# You may need to patch your application to make it use these locations.
#
$(CRYPTCAT_IPK): $(CRYPTCAT_BUILD_DIR)/.built
	rm -rf $(CRYPTCAT_IPK_DIR) $(BUILD_DIR)/cryptcat_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(CRYPTCAT_BUILD_DIR) DESTDIR=$(CRYPTCAT_IPK_DIR) install-strip
	install -d $(CRYPTCAT_IPK_DIR)/opt/bin/
	install -m 755 $(CRYPTCAT_BUILD_DIR)/cryptcat $(CRYPTCAT_IPK_DIR)/opt/bin/
	install -d $(CRYPTCAT_IPK_DIR)/opt/share/doc/cryptcat
	install -m 644 $(CRYPTCAT_BUILD_DIR)/[CR]* $(CRYPTCAT_IPK_DIR)/opt/share/doc/cryptcat/
	$(STRIP_COMMAND) $(CRYPTCAT_IPK_DIR)/opt/bin/cryptcat
	$(MAKE) $(CRYPTCAT_IPK_DIR)/CONTROL/control
	echo $(CRYPTCAT_CONFFILES) | sed -e 's/ /\n/g' > $(CRYPTCAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CRYPTCAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cryptcat-ipk: $(CRYPTCAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cryptcat-clean:
	rm -f $(CRYPTCAT_BUILD_DIR)/.built
	-$(MAKE) -C $(CRYPTCAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cryptcat-dirclean:
	rm -rf $(BUILD_DIR)/$(CRYPTCAT_DIR) $(CRYPTCAT_BUILD_DIR) $(CRYPTCAT_IPK_DIR) $(CRYPTCAT_IPK)
#
#
# Some sanity check for the package.
#
cryptcat-check: $(CRYPTCAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
