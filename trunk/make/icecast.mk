###########################################################
#
# icecast
#
###########################################################
#
# ICECAST_VERSION, ICECAST_SITE and ICECAST_SOURCE define
# the upstream location of the source code for the package.
# ICECAST_DIR is the directory which is created when the source
# archive is unpacked.
# ICECAST_UNZIP is the command used to unzip the source.
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
ICECAST_SITE=http://downloads.xiph.org/releases/icecast
ICECAST_VERSION=2.3.2
ICECAST_SOURCE=icecast-$(ICECAST_VERSION).tar.gz
ICECAST_DIR=icecast-$(ICECAST_VERSION)
ICECAST_UNZIP=zcat
ICECAST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ICECAST_DESCRIPTION=A free server software for streaming multimedia.
ICECAST_SECTION=multimedia
ICECAST_PRIORITY=optional
ICECAST_DEPENDS=libcurl, libogg, libvorbis, libxslt, speex
ICECAST_SUGGESTS=
ICECAST_CONFLICTS=

#
# ICECAST_IPK_VERSION should be incremented when the ipk changes.
#
ICECAST_IPK_VERSION=1

#
# ICECAST_CONFFILES should be a list of user-editable files
#ICECAST_CONFFILES=/opt/etc/icecast.conf /opt/etc/init.d/SXXicecast

#
# ICECAST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ICECAST_PATCHES=\
$(ICECAST_SOURCE_DIR)/configure.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ICECAST_CPPFLAGS=
ICECAST_LDFLAGS=

#
# ICECAST_BUILD_DIR is the directory in which the build is done.
# ICECAST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ICECAST_IPK_DIR is the directory in which the ipk is built.
# ICECAST_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ICECAST_BUILD_DIR=$(BUILD_DIR)/icecast
ICECAST_SOURCE_DIR=$(SOURCE_DIR)/icecast
ICECAST_IPK_DIR=$(BUILD_DIR)/icecast-$(ICECAST_VERSION)-ipk
ICECAST_IPK=$(BUILD_DIR)/icecast_$(ICECAST_VERSION)-$(ICECAST_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: icecast-source icecast-unpack icecast icecast-stage icecast-ipk icecast-clean icecast-dirclean icecast-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ICECAST_SOURCE):
	$(WGET) -P $(@D) $(ICECAST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
icecast-source: $(DL_DIR)/$(ICECAST_SOURCE) $(ICECAST_PATCHES)

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
$(ICECAST_BUILD_DIR)/.configured: $(DL_DIR)/$(ICECAST_SOURCE) $(ICECAST_PATCHES) make/icecast.mk
	$(MAKE) libcurl-stage
	$(MAKE) libogg-stage
	$(MAKE) libvorbis-stage
	$(MAKE) libxslt-stage
	$(MAKE) speex-stage
	rm -rf $(BUILD_DIR)/$(ICECAST_DIR) $(@D)
	$(ICECAST_UNZIP) $(DL_DIR)/$(ICECAST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ICECAST_PATCHES)" ; \
		then cat $(ICECAST_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ICECAST_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ICECAST_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ICECAST_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ICECAST_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ICECAST_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-curl=$(STAGING_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--with-speex=$(STAGING_PREFIX) \
		--without-theora \
		--with-vorbis=$(STAGING_PREFIX) \
		--with-xslt-config=$(STAGING_PREFIX)/bin/xslt-config \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

icecast-unpack: $(ICECAST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ICECAST_BUILD_DIR)/.built: $(ICECAST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
icecast: $(ICECAST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ICECAST_BUILD_DIR)/.staged: $(ICECAST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

icecast-stage: $(ICECAST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/icecast
#
$(ICECAST_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: icecast" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ICECAST_PRIORITY)" >>$@
	@echo "Section: $(ICECAST_SECTION)" >>$@
	@echo "Version: $(ICECAST_VERSION)-$(ICECAST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ICECAST_MAINTAINER)" >>$@
	@echo "Source: $(ICECAST_SITE)/$(ICECAST_SOURCE)" >>$@
	@echo "Description: $(ICECAST_DESCRIPTION)" >>$@
	@echo "Depends: $(ICECAST_DEPENDS)" >>$@
	@echo "Suggests: $(ICECAST_SUGGESTS)" >>$@
	@echo "Conflicts: $(ICECAST_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ICECAST_IPK_DIR)/opt/sbin or $(ICECAST_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ICECAST_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ICECAST_IPK_DIR)/opt/etc/icecast/...
# Documentation files should be installed in $(ICECAST_IPK_DIR)/opt/doc/icecast/...
# Daemon startup scripts should be installed in $(ICECAST_IPK_DIR)/opt/etc/init.d/S??icecast
#
# You may need to patch your application to make it use these locations.
#
$(ICECAST_IPK): $(ICECAST_BUILD_DIR)/.built
	rm -rf $(ICECAST_IPK_DIR) $(BUILD_DIR)/icecast_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ICECAST_BUILD_DIR) DESTDIR=$(ICECAST_IPK_DIR) install-strip
#	install -d $(ICECAST_IPK_DIR)/opt/etc/
#	install -m 644 $(ICECAST_SOURCE_DIR)/icecast.conf $(ICECAST_IPK_DIR)/opt/etc/icecast.conf
#	install -d $(ICECAST_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ICECAST_SOURCE_DIR)/rc.icecast $(ICECAST_IPK_DIR)/opt/etc/init.d/SXXicecast
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICECAST_IPK_DIR)/opt/etc/init.d/SXXicecast
	$(MAKE) $(ICECAST_IPK_DIR)/CONTROL/control
#	install -m 755 $(ICECAST_SOURCE_DIR)/postinst $(ICECAST_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICECAST_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ICECAST_SOURCE_DIR)/prerm $(ICECAST_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICECAST_IPK_DIR)/CONTROL/prerm
	echo $(ICECAST_CONFFILES) | sed -e 's/ /\n/g' > $(ICECAST_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ICECAST_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
icecast-ipk: $(ICECAST_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
icecast-clean:
	rm -f $(ICECAST_BUILD_DIR)/.built
	-$(MAKE) -C $(ICECAST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
icecast-dirclean:
	rm -rf $(BUILD_DIR)/$(ICECAST_DIR) $(ICECAST_BUILD_DIR) $(ICECAST_IPK_DIR) $(ICECAST_IPK)
#
#
# Some sanity check for the package.
#
icecast-check: $(ICECAST_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ICECAST_IPK)
