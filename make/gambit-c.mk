###########################################################
#
# gambit-c
#
###########################################################

# You must replace "gambit-c" and "GAMBIT-C" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GAMBIT-C_VERSION, GAMBIT-C_SITE and GAMBIT-C_SOURCE define
# the upstream location of the source code for the package.
# GAMBIT-C_DIR is the directory which is created when the source
# archive is unpacked.
# GAMBIT-C_UNZIP is the command used to unzip the source.
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
GAMBIT-C_SITE=http://www.iro.umontreal.ca/~gambit/download/gambit/v4.1/source
GAMBIT-C_UPSTREAM_VERSION=v4_1_0
GAMBIT-C_VERSION=4.1.0
GAMBIT-C_SOURCE=gambc-$(GAMBIT-C_UPSTREAM_VERSION).tgz
GAMBIT-C_DIR=gambc-$(GAMBIT-C_UPSTREAM_VERSION)
GAMBIT-C_UNZIP=zcat
GAMBIT-C_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GAMBIT-C_DESCRIPTION=A portable implementation of Scheme.
GAMBIT-C_SECTION=lang
GAMBIT-C_PRIORITY=optional
GAMBIT-C_DEPENDS=
ifneq (, $filter(crosstool-native, $(PACKAGES)))
GAMBIT-C_SUGGESTS=crosstool-native
endif
GAMBIT-C_CONFLICTS=

#
# GAMBIT-C_IPK_VERSION should be incremented when the ipk changes.
#
GAMBIT-C_IPK_VERSION=1

#
# GAMBIT-C_CONFFILES should be a list of user-editable files
#GAMBIT-C_CONFFILES=/opt/etc/gambit-c.conf /opt/etc/init.d/SXXgambit-c

#
# GAMBIT-C_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GAMBIT-C_PATCHES=$(GAMBIT-C_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GAMBIT-C_CPPFLAGS=
GAMBIT-C_LDFLAGS=

#
# GAMBIT-C_BUILD_DIR is the directory in which the build is done.
# GAMBIT-C_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GAMBIT-C_IPK_DIR is the directory in which the ipk is built.
# GAMBIT-C_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GAMBIT-C_BUILD_DIR=$(BUILD_DIR)/gambit-c
GAMBIT-C_SOURCE_DIR=$(SOURCE_DIR)/gambit-c
GAMBIT-C_IPK_DIR=$(BUILD_DIR)/gambit-c-$(GAMBIT-C_VERSION)-ipk
GAMBIT-C_IPK=$(BUILD_DIR)/gambit-c_$(GAMBIT-C_VERSION)-$(GAMBIT-C_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GAMBIT-C_SOURCE):
	$(WGET) -P $(DL_DIR) $(GAMBIT-C_SITE)/$(GAMBIT-C_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gambit-c-source: $(DL_DIR)/$(GAMBIT-C_SOURCE) $(GAMBIT-C_PATCHES)

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
$(GAMBIT-C_BUILD_DIR)/.configured: $(DL_DIR)/$(GAMBIT-C_SOURCE) $(GAMBIT-C_PATCHES) make/gambit-c.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GAMBIT-C_DIR) $(@D)
	$(GAMBIT-C_UNZIP) $(DL_DIR)/$(GAMBIT-C_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GAMBIT-C_PATCHES)" ; \
		then cat $(GAMBIT-C_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GAMBIT-C_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GAMBIT-C_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GAMBIT-C_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GAMBIT-C_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GAMBIT-C_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-single-host \
		--enable-gcc-opts \
		--enable-shared \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(GAMBIT-C_BUILD_DIR)/libtool
	touch $@

gambit-c-unpack: $(GAMBIT-C_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GAMBIT-C_BUILD_DIR)/.built: $(GAMBIT-C_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gambit-c: $(GAMBIT-C_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GAMBIT-C_BUILD_DIR)/.staged: $(GAMBIT-C_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gambit-c-stage: $(GAMBIT-C_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gambit-c
#
$(GAMBIT-C_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gambit-c" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GAMBIT-C_PRIORITY)" >>$@
	@echo "Section: $(GAMBIT-C_SECTION)" >>$@
	@echo "Version: $(GAMBIT-C_VERSION)-$(GAMBIT-C_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GAMBIT-C_MAINTAINER)" >>$@
	@echo "Source: $(GAMBIT-C_SITE)/$(GAMBIT-C_SOURCE)" >>$@
	@echo "Description: $(GAMBIT-C_DESCRIPTION)" >>$@
	@echo "Depends: $(GAMBIT-C_DEPENDS)" >>$@
	@echo "Suggests: $(GAMBIT-C_SUGGESTS)" >>$@
	@echo "Conflicts: $(GAMBIT-C_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GAMBIT-C_IPK_DIR)/opt/sbin or $(GAMBIT-C_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GAMBIT-C_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GAMBIT-C_IPK_DIR)/opt/etc/gambit-c/...
# Documentation files should be installed in $(GAMBIT-C_IPK_DIR)/opt/doc/gambit-c/...
# Daemon startup scripts should be installed in $(GAMBIT-C_IPK_DIR)/opt/etc/init.d/S??gambit-c
#
# You may need to patch your application to make it use these locations.
#
$(GAMBIT-C_IPK): $(GAMBIT-C_BUILD_DIR)/.built
	rm -rf $(GAMBIT-C_IPK_DIR) $(BUILD_DIR)/gambit-c_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GAMBIT-C_BUILD_DIR) prefix=$(GAMBIT-C_IPK_DIR)/opt install
	install -d $(GAMBIT-C_IPK_DIR)/opt/lib
	mv $(GAMBIT-C_IPK_DIR)/opt/current/bin $(GAMBIT-C_IPK_DIR)/opt/
	mv $(GAMBIT-C_IPK_DIR)/opt/current/include $(GAMBIT-C_IPK_DIR)/opt/
	mv $(GAMBIT-C_IPK_DIR)/opt/current/lib/lib*.so $(GAMBIT-C_IPK_DIR)/opt/lib/
	mv $(GAMBIT-C_IPK_DIR)/opt/current/share $(GAMBIT-C_IPK_DIR)/opt/
	install -d $(GAMBIT-C_IPK_DIR)/opt/share/doc
	mv $(GAMBIT-C_IPK_DIR)/opt/current/doc $(GAMBIT-C_IPK_DIR)/opt/share/doc/gambit-c
	mv $(GAMBIT-C_IPK_DIR)/opt/current/info $(GAMBIT-C_IPK_DIR)/opt/share/
	mv $(GAMBIT-C_IPK_DIR)/opt/current/lib $(GAMBIT-C_IPK_DIR)/opt/lib/gambit-c
	mv $(GAMBIT-C_IPK_DIR)/opt/current/*.scm $(GAMBIT-C_IPK_DIR)/opt/lib/gambit-c/
	rm -rf $(GAMBIT-C_IPK_DIR)/opt/v$(GAMBIT-C_VERSION) $(GAMBIT-C_IPK_DIR)/opt/current
	$(STRIP_COMMAND) $(GAMBIT-C_IPK_DIR)/opt/bin/gs[ci] $(GAMBIT-C_IPK_DIR)/opt/lib/lib*.so
	sed -i -e 's|$(STAGING_DIR)||g; s|$(TARGET_CC)|/opt/bin/gcc|' $(GAMBIT-C_IPK_DIR)/opt/bin/gsc-cc-o
	$(MAKE) $(GAMBIT-C_IPK_DIR)/CONTROL/control
	echo $(GAMBIT-C_CONFFILES) | sed -e 's/ /\n/g' > $(GAMBIT-C_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GAMBIT-C_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gambit-c-ipk: $(GAMBIT-C_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gambit-c-clean:
	rm -f $(GAMBIT-C_BUILD_DIR)/.built
	-$(MAKE) -C $(GAMBIT-C_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gambit-c-dirclean:
	rm -rf $(BUILD_DIR)/$(GAMBIT-C_DIR) $(GAMBIT-C_BUILD_DIR) $(GAMBIT-C_IPK_DIR) $(GAMBIT-C_IPK)

#
# Some sanity check for the package.
#
gambit-c-check: $(GAMBIT-C_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GAMBIT-C_IPK)
