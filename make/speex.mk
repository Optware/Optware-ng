###########################################################
#
# speex
#
###########################################################
#
# SPEEX_VERSION, SPEEX_SITE and SPEEX_SOURCE define
# the upstream location of the source code for the package.
# SPEEX_DIR is the directory which is created when the source
# archive is unpacked.
# SPEEX_UNZIP is the command used to unzip the source.
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
SPEEX_SITE=http://downloads.us.xiph.org/releases/speex
SPEEX_VERSION=1.2beta1
SPEEX_SOURCE=speex-$(SPEEX_VERSION).tar.gz
SPEEX_DIR=speex-$(SPEEX_VERSION)
SPEEX_UNZIP=zcat
SPEEX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPEEX_DESCRIPTION=Speex is an Open Source/Free Software  patent-free audio compression format designed for speech.
SPEEX_SECTION=audio
SPEEX_PRIORITY=optional
SPEEX_DEPENDS=libogg
SPEEX_SUGGESTS=
SPEEX_CONFLICTS=

#
# SPEEX_IPK_VERSION should be incremented when the ipk changes.
#
SPEEX_IPK_VERSION=1

#
# SPEEX_CONFFILES should be a list of user-editable files
#SPEEX_CONFFILES=/opt/etc/speex.conf /opt/etc/init.d/SXXspeex

#
# SPEEX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPEEX_PATCHES=$(SPEEX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPEEX_CPPFLAGS=
SPEEX_LDFLAGS=

ifeq ($(TARGET_ARCH), armeb)
SPEEX_CONFIG_ARGS=--enable-fixed-point --enable-arm5e-asm
endif

#
# SPEEX_BUILD_DIR is the directory in which the build is done.
# SPEEX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPEEX_IPK_DIR is the directory in which the ipk is built.
# SPEEX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPEEX_BUILD_DIR=$(BUILD_DIR)/speex
SPEEX_SOURCE_DIR=$(SOURCE_DIR)/speex
SPEEX_IPK_DIR=$(BUILD_DIR)/speex-$(SPEEX_VERSION)-ipk
SPEEX_IPK=$(BUILD_DIR)/speex_$(SPEEX_VERSION)-$(SPEEX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: speex-source speex-unpack speex speex-stage speex-ipk speex-clean speex-dirclean speex-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPEEX_SOURCE):
	$(WGET) -P $(DL_DIR) $(SPEEX_SITE)/$(SPEEX_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SPEEX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
speex-source: $(DL_DIR)/$(SPEEX_SOURCE) $(SPEEX_PATCHES)

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
$(SPEEX_BUILD_DIR)/.configured: $(DL_DIR)/$(SPEEX_SOURCE) $(SPEEX_PATCHES) make/speex.mk
	$(MAKE) libogg-stage
	rm -rf $(BUILD_DIR)/$(SPEEX_DIR) $(SPEEX_BUILD_DIR)
	$(SPEEX_UNZIP) $(DL_DIR)/$(SPEEX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPEEX_PATCHES)" ; \
		then cat $(SPEEX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPEEX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SPEEX_DIR)" != "$(SPEEX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SPEEX_DIR) $(SPEEX_BUILD_DIR) ; \
	fi
	(cd $(SPEEX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPEEX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPEEX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		\
		--with-ogg=$(STAGING_PREFIX) \
		$(SPEEX_CONFIG_ARGS) \
	)
	$(PATCH_LIBTOOL) $(SPEEX_BUILD_DIR)/libtool
	touch $@

speex-unpack: $(SPEEX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPEEX_BUILD_DIR)/.built: $(SPEEX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SPEEX_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
speex: $(SPEEX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPEEX_BUILD_DIR)/.staged: $(SPEEX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SPEEX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/speex.pc
	touch $@

speex-stage: $(SPEEX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/speex
#
$(SPEEX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: speex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPEEX_PRIORITY)" >>$@
	@echo "Section: $(SPEEX_SECTION)" >>$@
	@echo "Version: $(SPEEX_VERSION)-$(SPEEX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPEEX_MAINTAINER)" >>$@
	@echo "Source: $(SPEEX_SITE)/$(SPEEX_SOURCE)" >>$@
	@echo "Description: $(SPEEX_DESCRIPTION)" >>$@
	@echo "Depends: $(SPEEX_DEPENDS)" >>$@
	@echo "Suggests: $(SPEEX_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPEEX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPEEX_IPK_DIR)/opt/sbin or $(SPEEX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPEEX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPEEX_IPK_DIR)/opt/etc/speex/...
# Documentation files should be installed in $(SPEEX_IPK_DIR)/opt/doc/speex/...
# Daemon startup scripts should be installed in $(SPEEX_IPK_DIR)/opt/etc/init.d/S??speex
#
# You may need to patch your application to make it use these locations.
#
$(SPEEX_IPK): $(SPEEX_BUILD_DIR)/.built
	rm -rf $(SPEEX_IPK_DIR) $(BUILD_DIR)/speex_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPEEX_BUILD_DIR) DESTDIR=$(SPEEX_IPK_DIR) install-strip
#	install -d $(SPEEX_IPK_DIR)/opt/etc/
#	install -m 644 $(SPEEX_SOURCE_DIR)/speex.conf $(SPEEX_IPK_DIR)/opt/etc/speex.conf
#	install -d $(SPEEX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SPEEX_SOURCE_DIR)/rc.speex $(SPEEX_IPK_DIR)/opt/etc/init.d/SXXspeex
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPEEX_IPK_DIR)/opt/etc/init.d/SXXspeex
	$(MAKE) $(SPEEX_IPK_DIR)/CONTROL/control
#	install -m 755 $(SPEEX_SOURCE_DIR)/postinst $(SPEEX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPEEX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SPEEX_SOURCE_DIR)/prerm $(SPEEX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPEEX_IPK_DIR)/CONTROL/prerm
	echo $(SPEEX_CONFFILES) | sed -e 's/ /\n/g' > $(SPEEX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPEEX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
speex-ipk: $(SPEEX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
speex-clean:
	rm -f $(SPEEX_BUILD_DIR)/.built
	-$(MAKE) -C $(SPEEX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
speex-dirclean:
	rm -rf $(BUILD_DIR)/$(SPEEX_DIR) $(SPEEX_BUILD_DIR) $(SPEEX_IPK_DIR) $(SPEEX_IPK)
#
#
# Some sanity check for the package.
#
speex-check: $(SPEEX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SPEEX_IPK)
