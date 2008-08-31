###########################################################
#
# llink
#
###########################################################
#
# LLINK_VERSION, LLINK_SITE and LLINK_SOURCE define
# the upstream location of the source code for the package.
# LLINK_DIR is the directory which is created when the source
# archive is unpacked.
# LLINK_UNZIP is the command used to unzip the source.
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

# default to no, not sure about the licensing
LLINK_WITH_LIBDVDCSS=no

LLINK_VERSION=2.1.1
LLINK_SITE=http://www.lundman.net/ftp/llink
LLINK_SOURCE=llink-$(LLINK_VERSION).tar.gz
LLINK_DIR=llink-$(LLINK_VERSION)
LLINK_UNZIP=zcat
LLINK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LLINK_DESCRIPTION=A media streamer using the HTTP protocol and should work with most Syabas middleware hardware.
LLINK_SECTION=media
LLINK_PRIORITY=optional
LLINK_DEPENDS=unrar, libdvdread
ifeq (yes, $(LLINK_WITH_LIBDVDCSS))
LLINK_DEPENDS +=, libdvdcss
endif
LLINK_SUGGESTS=
LLINK_CONFLICTS=

#
# LLINK_IPK_VERSION should be incremented when the ipk changes.
#
LLINK_IPK_VERSION=3

#
# LLINK_CONFFILES should be a list of user-editable files
LLINK_CONFFILES=/opt/share/llink/llink.conf /opt/share/llink/jukebox.conf

#
# LLINK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LLINK_PATCHES=$(LLINK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LLINK_CPPFLAGS=
LLINK_LDFLAGS=

ifeq (yes, $(LLINK_WITH_LIBDVDCSS))
LLINK_CONFIG_ARGS= --with-libdvdcss-includes=$(STAGING_INCLUDE_DIR) --with-libdvdcss-libs=$(STAGING_LIB_DIR)
else
LLINK_CONFIG_ARGS= --disable-dvdcss
endif

#
# LLINK_BUILD_DIR is the directory in which the build is done.
# LLINK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LLINK_IPK_DIR is the directory in which the ipk is built.
# LLINK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LLINK_BUILD_DIR=$(BUILD_DIR)/llink
LLINK_SOURCE_DIR=$(SOURCE_DIR)/llink

LLINK_IPK_DIR=$(BUILD_DIR)/llink-$(LLINK_VERSION)-ipk
LLINK_IPK=$(BUILD_DIR)/llink_$(LLINK_VERSION)-$(LLINK_IPK_VERSION)_$(TARGET_ARCH).ipk
LLINK-DEV_IPK_DIR=$(BUILD_DIR)/llink-dev-$(LLINK_VERSION)-ipk
LLINK-DEV_IPK=$(BUILD_DIR)/llink-dev_$(LLINK_VERSION)-$(LLINK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: llink-source llink-unpack llink llink-stage llink-ipk llink-clean llink-dirclean llink-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LLINK_SOURCE):
	$(WGET) -P $(@D) $(LLINK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
llink-source: $(DL_DIR)/$(LLINK_SOURCE) $(LLINK_PATCHES)

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
$(LLINK_BUILD_DIR)/.configured: $(DL_DIR)/$(LLINK_SOURCE) $(LLINK_PATCHES) make/llink.mk
	$(MAKE) libdvdread-stage
ifeq (yes, $(LLINK_WITH_LIBDVDCSS))
	$(MAKE) libdvdcss-stage
endif
	rm -rf $(BUILD_DIR)/$(LLINK_DIR) $(@D)
	$(LLINK_UNZIP) $(DL_DIR)/$(LLINK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LLINK_PATCHES)" ; \
		then cat $(LLINK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LLINK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LLINK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LLINK_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LLINK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LLINK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-openssl \
		--with-dvdread=$(STAGING_PREFIX) \
		$(LLINK_CONFIG_ARGS) \
		--disable-nls \
		--enable-shared \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

llink-unpack: $(LLINK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LLINK_BUILD_DIR)/.built: $(LLINK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
llink: $(LLINK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LLINK_BUILD_DIR)/.staged: $(LLINK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

llink-stage: $(LLINK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/llink
#
$(LLINK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: llink" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LLINK_PRIORITY)" >>$@
	@echo "Section: $(LLINK_SECTION)" >>$@
	@echo "Version: $(LLINK_VERSION)-$(LLINK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LLINK_MAINTAINER)" >>$@
	@echo "Source: $(LLINK_SITE)/$(LLINK_SOURCE)" >>$@
	@echo "Description: $(LLINK_DESCRIPTION)" >>$@
	@echo "Depends: $(LLINK_DEPENDS)" >>$@
	@echo "Suggests: $(LLINK_SUGGESTS)" >>$@
	@echo "Conflicts: $(LLINK_CONFLICTS)" >>$@

$(LLINK-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: llink-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LLINK_PRIORITY)" >>$@
	@echo "Section: $(LLINK_SECTION)" >>$@
	@echo "Version: $(LLINK_VERSION)-$(LLINK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LLINK_MAINTAINER)" >>$@
	@echo "Source: $(LLINK_SITE)/$(LLINK_SOURCE)" >>$@
	@echo "Description: llink development files" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LLINK_IPK_DIR)/opt/sbin or $(LLINK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LLINK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LLINK_IPK_DIR)/opt/etc/llink/...
# Documentation files should be installed in $(LLINK_IPK_DIR)/opt/doc/llink/...
# Daemon startup scripts should be installed in $(LLINK_IPK_DIR)/opt/etc/init.d/S??llink
#
# You may need to patch your application to make it use these locations.
#
$(LLINK_IPK) $(LLINK-DEV_IPK): $(LLINK_BUILD_DIR)/.built
	rm -rf $(LLINK_IPK_DIR) $(BUILD_DIR)/llink_*_$(TARGET_ARCH).ipk
	rm -rf $(LLINK-DEV_IPK_DIR) $(BUILD_DIR)/llink-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LLINK_BUILD_DIR) DESTDIR=$(LLINK_IPK_DIR) install-strip
	install -d $(LLINK_IPK_DIR)/opt/share/llink
	mv $(LLINK_IPK_DIR)/opt/bin/* $(LLINK_IPK_DIR)/opt/share/llink
	rm -rf $(LLINK_IPK_DIR)/opt/bin
	cp -a $(LLINK_BUILD_DIR)/src/skin $(LLINK_IPK_DIR)/opt/share/llink/
	cp -p $(LLINK_BUILD_DIR)/src/*.conf $(LLINK_IPK_DIR)/opt/share/llink/
	install -d $(LLINK_IPK_DIR)/opt/share/doc/llink
	install \
		$(LLINK_BUILD_DIR)/LICENSE \
		$(LLINK_BUILD_DIR)/README.txt \
		$(LLINK_BUILD_DIR)/Example* \
		$(LLINK_IPK_DIR)/opt/share/doc/llink/
	install -d $(LLINK-DEV_IPK_DIR)/opt
	mv $(LLINK_IPK_DIR)/opt/include $(LLINK-DEV_IPK_DIR)/opt
	mv $(LLINK_IPK_DIR)/opt/lib $(LLINK-DEV_IPK_DIR)/opt
	$(MAKE) $(LLINK_IPK_DIR)/CONTROL/control
	echo $(LLINK_CONFFILES) | sed -e 's/ /\n/g' > $(LLINK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LLINK_IPK_DIR)
	$(MAKE) $(LLINK-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LLINK-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
llink-ipk: $(LLINK_IPK) $(LLINK-DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
llink-clean:
	rm -f $(LLINK_BUILD_DIR)/.built
	-$(MAKE) -C $(LLINK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
llink-dirclean:
	rm -rf $(BUILD_DIR)/$(LLINK_DIR) $(LLINK_BUILD_DIR)
	rm -rf $(LLINK_IPK_DIR) $(LLINK_IPK)
	rm -rf $(LLINK-DEV_IPK_DIR) $(LLINK-DEV_IPK)
#
#
# Some sanity check for the package.
#
llink-check: $(LLINK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LLINK_IPK)
