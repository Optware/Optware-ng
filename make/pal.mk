###########################################################
#
# pal
#
###########################################################
#
# PAL_VERSION, PAL_SITE and PAL_SOURCE define
# the upstream location of the source code for the package.
# PAL_DIR is the directory which is created when the source
# archive is unpacked.
# PAL_UNZIP is the command used to unzip the source.
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
PAL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/palcal
PAL_VERSION=0.3.4
PAL_SOURCE=pal-$(PAL_VERSION).tgz
PAL_DIR=pal-$(PAL_VERSION)
PAL_UNZIP=zcat
PAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PAL_DESCRIPTION=pal is a command-line calendar program that can keep track of events.
PAL_SECTION=utils
PAL_PRIORITY=optional
PAL_DEPENDS=glib, ncurses, readline
PAL_SUGGESTS=
PAL_CONFLICTS=

#
# PAL_IPK_VERSION should be incremented when the ipk changes.
#
PAL_IPK_VERSION=1

#
# PAL_CONFFILES should be a list of user-editable files
#PAL_CONFFILES=/opt/etc/pal.conf /opt/etc/init.d/SXXpal

#
# PAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PAL_PATCHES=$(PAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PAL_CPPFLAGS=
PAL_LDFLAGS=-lglib-2.0 -lreadline -lncurses

#
# PAL_BUILD_DIR is the directory in which the build is done.
# PAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PAL_IPK_DIR is the directory in which the ipk is built.
# PAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PAL_BUILD_DIR=$(BUILD_DIR)/pal
PAL_SOURCE_DIR=$(SOURCE_DIR)/pal
PAL_IPK_DIR=$(BUILD_DIR)/pal-$(PAL_VERSION)-ipk
PAL_IPK=$(BUILD_DIR)/pal_$(PAL_VERSION)-$(PAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pal-source pal-unpack pal pal-stage pal-ipk pal-clean pal-dirclean pal-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PAL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PAL_SITE)/$(PAL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PAL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pal-source: $(DL_DIR)/$(PAL_SOURCE) $(PAL_PATCHES)

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
$(PAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PAL_SOURCE) $(PAL_PATCHES) make/pal.mk
	$(MAKE) glib-stage ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(PAL_DIR) $(PAL_BUILD_DIR)
	$(PAL_UNZIP) $(DL_DIR)/$(PAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PAL_PATCHES)" ; \
		then cat $(PAL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PAL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PAL_DIR)" != "$(PAL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PAL_DIR) $(PAL_BUILD_DIR) ; \
	fi
	sed -i -e 's/strip /: /' \
	       -e 's/-o root//' \
	       -e 's|-I$${prefix}/include ||' \
		$(PAL_BUILD_DIR)/src/Makefile
	sed -i -e 's|/etc|/opt/etc|' \
		$(PAL_BUILD_DIR)/src/input.c \
		$(PAL_BUILD_DIR)/src/Makefile
#	(cd $(PAL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PAL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

pal-unpack: $(PAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PAL_BUILD_DIR)/.built: $(PAL_BUILD_DIR)/.configured
	rm -f $@
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(MAKE) -C $(PAL_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PAL_LDFLAGS)" \
		LIBDIR="$(STAGING_LDFLAGS) $(PAL_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
pal: $(PAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PAL_BUILD_DIR)/.staged: $(PAL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

pal-stage: $(PAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pal
#
$(PAL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pal" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PAL_PRIORITY)" >>$@
	@echo "Section: $(PAL_SECTION)" >>$@
	@echo "Version: $(PAL_VERSION)-$(PAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PAL_MAINTAINER)" >>$@
	@echo "Source: $(PAL_SITE)/$(PAL_SOURCE)" >>$@
	@echo "Description: $(PAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PAL_DEPENDS)" >>$@
	@echo "Suggests: $(PAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PAL_IPK_DIR)/opt/sbin or $(PAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PAL_IPK_DIR)/opt/etc/pal/...
# Documentation files should be installed in $(PAL_IPK_DIR)/opt/doc/pal/...
# Daemon startup scripts should be installed in $(PAL_IPK_DIR)/opt/etc/init.d/S??pal
#
# You may need to patch your application to make it use these locations.
#
$(PAL_IPK): $(PAL_BUILD_DIR)/.built
	rm -rf $(PAL_IPK_DIR) $(BUILD_DIR)/pal_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PAL_BUILD_DIR)/src install-no-rm \
		DESTDIR=$(PAL_IPK_DIR) \
		prefix=/opt \
		;
	$(STRIP_COMMAND) $(PAL_IPK_DIR)/opt/bin/pal
#	install -d $(PAL_IPK_DIR)/opt/etc/
#	install -m 644 $(PAL_SOURCE_DIR)/pal.conf $(PAL_IPK_DIR)/opt/etc/pal.conf
#	install -d $(PAL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PAL_SOURCE_DIR)/rc.pal $(PAL_IPK_DIR)/opt/etc/init.d/SXXpal
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PAL_IPK_DIR)/opt/etc/init.d/SXXpal
	$(MAKE) $(PAL_IPK_DIR)/CONTROL/control
#	install -m 755 $(PAL_SOURCE_DIR)/postinst $(PAL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PAL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PAL_SOURCE_DIR)/prerm $(PAL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PAL_IPK_DIR)/CONTROL/prerm
	echo $(PAL_CONFFILES) | sed -e 's/ /\n/g' > $(PAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pal-ipk: $(PAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pal-clean:
	rm -f $(PAL_BUILD_DIR)/.built
	-$(MAKE) -C $(PAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pal-dirclean:
	rm -rf $(BUILD_DIR)/$(PAL_DIR) $(PAL_BUILD_DIR) $(PAL_IPK_DIR) $(PAL_IPK)
#
#
# Some sanity check for the package.
#
pal-check: $(PAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PAL_IPK)
