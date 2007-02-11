###########################################################
#
# faad2
#
###########################################################
#
# FAAD2_VERSION, FAAD2_SITE and FAAD2_SOURCE define
# the upstream location of the source code for the package.
# FAAD2_DIR is the directory which is created when the source
# archive is unpacked.
# FAAD2_UNZIP is the command used to unzip the source.
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
FAAD2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/faac
FAAD2_VERSION=2.5
FAAD2_SOURCE=faad2-$(FAAD2_VERSION).tar.gz
FAAD2_DIR=faad2
FAAD2_UNZIP=zcat
FAAD2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FAAD2_DESCRIPTION=Freeware Advanced Audio Coder
FAAD2_SECTION=audio
FAAD2_PRIORITY=optional
FAAD2_DEPENDS=
FAAD2_SUGGESTS=
FAAD2_CONFLICTS=

#
# FAAD2_IPK_VERSION should be incremented when the ipk changes.
#
FAAD2_IPK_VERSION=2

#
# FAAD2_CONFFILES should be a list of user-editable files
#FAAD2_CONFFILES=/opt/etc/faad2.conf /opt/etc/init.d/SXXfaad2

#
# FAAD2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FAAD2_PATCHES=$(FAAD2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FAAD2_CPPFLAGS=
FAAD2_LDFLAGS=

#
# FAAD2_BUILD_DIR is the directory in which the build is done.
# FAAD2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FAAD2_IPK_DIR is the directory in which the ipk is built.
# FAAD2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FAAD2_BUILD_DIR=$(BUILD_DIR)/faad2
FAAD2_SOURCE_DIR=$(SOURCE_DIR)/faad2

FAAD2_IPK_DIR=$(BUILD_DIR)/faad2-$(FAAD2_VERSION)-ipk
FAAD2_IPK=$(BUILD_DIR)/faad2_$(FAAD2_VERSION)-$(FAAD2_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(HOSTCC), $(TARGET_CC))
FAAD2_AUTOTOOLS=ACLOCAL=aclocal-$(AUTOMAKE_VERSION) AUTOMAKE=automake-$(AUTOMAKE_VERSION)
else
FAAD2_AUTOTOOLS=
endif

.PHONY: faad2-source faad2-unpack faad2 faad2-stage faad2-ipk faad2-clean faad2-dirclean faad2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FAAD2_SOURCE):
	$(WGET) -P $(DL_DIR) $(FAAD2_SITE)/$(FAAD2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
faad2-source: $(DL_DIR)/$(FAAD2_SOURCE) $(FAAD2_PATCHES)

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
$(FAAD2_BUILD_DIR)/.configured: $(DL_DIR)/$(FAAD2_SOURCE) $(FAAD2_PATCHES) # make/faad2.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FAAD2_DIR) $(FAAD2_BUILD_DIR)
	$(FAAD2_UNZIP) $(DL_DIR)/$(FAAD2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FAAD2_PATCHES)" ; \
		then cat $(FAAD2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FAAD2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FAAD2_DIR)" != "$(FAAD2_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FAAD2_DIR) $(FAAD2_BUILD_DIR) ; \
	fi
	find $(FAAD2_BUILD_DIR) -name \*.am -or -name \*.in | xargs sed -i -e 's/$$//'
	(cd $(FAAD2_BUILD_DIR); \
        	echo > plugins/Makefile.am && \
        	echo > plugins/xmms/src/Makefile.am && \
                sed -i -e '/E_B/d' configure.in && \
                $(FAAD2_AUTOTOOLS) autoreconf -vif; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FAAD2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FAAD2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-bmp \
		--without-drm \
		--without-mpeg4ip \
		--without-xmms \
	)
	$(PATCH_LIBTOOL) $(FAAD2_BUILD_DIR)/libtool
	sed -ie '/^SUBDIRS/s/ frontend / /' $(FAAD2_BUILD_DIR)/Makefile
	touch $@

faad2-unpack: $(FAAD2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FAAD2_BUILD_DIR)/.built: $(FAAD2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FAAD2_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
faad2: $(FAAD2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FAAD2_BUILD_DIR)/.staged: $(FAAD2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FAAD2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

faad2-stage: $(FAAD2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/faad2
#
$(FAAD2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: faad2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FAAD2_PRIORITY)" >>$@
	@echo "Section: $(FAAD2_SECTION)" >>$@
	@echo "Version: $(FAAD2_VERSION)-$(FAAD2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FAAD2_MAINTAINER)" >>$@
	@echo "Source: $(FAAD2_SITE)/$(FAAD2_SOURCE)" >>$@
	@echo "Description: $(FAAD2_DESCRIPTION)" >>$@
	@echo "Depends: $(FAAD2_DEPENDS)" >>$@
	@echo "Suggests: $(FAAD2_SUGGESTS)" >>$@
	@echo "Conflicts: $(FAAD2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FAAD2_IPK_DIR)/opt/sbin or $(FAAD2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FAAD2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FAAD2_IPK_DIR)/opt/etc/faad2/...
# Documentation files should be installed in $(FAAD2_IPK_DIR)/opt/doc/faad2/...
# Daemon startup scripts should be installed in $(FAAD2_IPK_DIR)/opt/etc/init.d/S??faad2
#
# You may need to patch your application to make it use these locations.
#
$(FAAD2_IPK): $(FAAD2_BUILD_DIR)/.built
	rm -rf $(FAAD2_IPK_DIR) $(BUILD_DIR)/faad2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FAAD2_BUILD_DIR) DESTDIR=$(FAAD2_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(FAAD2_IPK_DIR)/opt/lib/libfaad.so.[0-9].[0-9].[0-9]
#	install -d $(FAAD2_IPK_DIR)/opt/etc/
#	install -m 644 $(FAAD2_SOURCE_DIR)/faad2.conf $(FAAD2_IPK_DIR)/opt/etc/faad2.conf
#	install -d $(FAAD2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FAAD2_SOURCE_DIR)/rc.faad2 $(FAAD2_IPK_DIR)/opt/etc/init.d/SXXfaad2
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXfaad2
	$(MAKE) $(FAAD2_IPK_DIR)/CONTROL/control
#	install -m 755 $(FAAD2_SOURCE_DIR)/postinst $(FAAD2_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FAAD2_SOURCE_DIR)/prerm $(FAAD2_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(FAAD2_CONFFILES) | sed -e 's/ /\n/g' > $(FAAD2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FAAD2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
faad2-ipk: $(FAAD2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
faad2-clean:
	rm -f $(FAAD2_BUILD_DIR)/.built
	-$(MAKE) -C $(FAAD2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
faad2-dirclean:
	rm -rf $(BUILD_DIR)/$(FAAD2_DIR) $(FAAD2_BUILD_DIR) $(FAAD2_IPK_DIR) $(FAAD2_IPK)
#
#
# Some sanity check for the package.
#
faad2-check: $(FAAD2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FAAD2_IPK)
