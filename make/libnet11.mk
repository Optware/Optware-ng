###########################################################
#
# libnet11
#
###########################################################
#
# LIBNET11_VERSION, LIBNET11_SITE and LIBNET11_SOURCE define
# the upstream location of the source code for the package.
# LIBNET11_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNET11_UNZIP is the command used to unzip the source.
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
LIBNET11_SITE=http://www.packetfactory.net/libnet/dist
LIBNET11_VERSION=1.1.2.1
LIBNET11_SOURCE=libnet-$(LIBNET11_VERSION).tar.gz
LIBNET11_DIR=libnet
LIBNET11_UNZIP=zcat
LIBNET11_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNET11_DESCRIPTION=Libnet is a high-level API (toolkit) allowing the application programmer to construct and inject network packets.
LIBNET11_SECTION=net
LIBNET11_PRIORITY=optional
LIBNET11_DEPENDS=
LIBNET11_SUGGESTS=
LIBNET11_CONFLICTS=

#
# LIBNET11_IPK_VERSION should be incremented when the ipk changes.
#
LIBNET11_IPK_VERSION=1

#
# LIBNET11_CONFFILES should be a list of user-editable files
#LIBNET11_CONFFILES=/opt/etc/libnet11.conf /opt/etc/init.d/SXXlibnet11

#
# LIBNET11_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNET11_PATCHES=$(LIBNET11_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNET11_CPPFLAGS=
LIBNET11_LDFLAGS=
ifneq ($(HOSTCC), $(TARGET_CC))
LIBNET11_CONFIGURE_ENV=ac_libnet_have_packet_socket=yes
LIBNET11_CONFIGURE_ENV+=$(strip \
	$(if $(filter mipsel, $(TARGET_ARCH)), ac_cv_lbl_unaligned_fail=yes, \
		ac_cv_lbl_unaligned_fail=no))
endif

#
# LIBNET11_BUILD_DIR is the directory in which the build is done.
# LIBNET11_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNET11_IPK_DIR is the directory in which the ipk is built.
# LIBNET11_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNET11_BUILD_DIR=$(BUILD_DIR)/libnet11
LIBNET11_SOURCE_DIR=$(SOURCE_DIR)/libnet11
LIBNET11_IPK_DIR=$(BUILD_DIR)/libnet11-$(LIBNET11_VERSION)-ipk
LIBNET11_IPK=$(BUILD_DIR)/libnet11_$(LIBNET11_VERSION)-$(LIBNET11_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnet11-source libnet11-unpack libnet11 libnet11-stage libnet11-ipk libnet11-clean libnet11-dirclean libnet11-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNET11_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNET11_SITE)/$(LIBNET11_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNET11_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnet11-source: $(DL_DIR)/$(LIBNET11_SOURCE) $(LIBNET11_PATCHES)

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
$(LIBNET11_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNET11_SOURCE) $(LIBNET11_PATCHES) make/libnet11.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBNET11_DIR) $(LIBNET11_BUILD_DIR)
	$(LIBNET11_UNZIP) $(DL_DIR)/$(LIBNET11_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNET11_PATCHES)" ; \
		then cat $(LIBNET11_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBNET11_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNET11_DIR)" != "$(LIBNET11_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNET11_DIR) $(LIBNET11_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i -e 's/test ! -x conftest/true/' $(LIBNET11_BUILD_DIR)/configure
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
	then sed -i -e '/^[ 	]*ac_cv_libnet_endianess=/s|=.*|=big|' $(LIBNET11_BUILD_DIR)/configure; \
	else sed -i -e '/^[ 	]*ac_cv_libnet_endianess=/s|=.*|=lil|' $(LIBNET11_BUILD_DIR)/configure; \
	fi
endif
	(cd $(LIBNET11_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNET11_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNET11_LDFLAGS)" \
		$(LIBNET11_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(LIBNET11_BUILD_DIR)/libtool
	touch $@

libnet11-unpack: $(LIBNET11_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNET11_BUILD_DIR)/.built: $(LIBNET11_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNET11_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnet11: $(LIBNET11_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNET11_BUILD_DIR)/.staged: $(LIBNET11_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNET11_BUILD_DIR) install \
		DESTDIR=$(STAGING_DIR) \
		libdir="/opt/lib/libnet11" \
		includedir="/opt/include/libnet11" \
		;
	touch $@

libnet11-stage: $(LIBNET11_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnet11
#
$(LIBNET11_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libnet11" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNET11_PRIORITY)" >>$@
	@echo "Section: $(LIBNET11_SECTION)" >>$@
	@echo "Version: $(LIBNET11_VERSION)-$(LIBNET11_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNET11_MAINTAINER)" >>$@
	@echo "Source: $(LIBNET11_SITE)/$(LIBNET11_SOURCE)" >>$@
	@echo "Description: $(LIBNET11_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNET11_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNET11_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNET11_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNET11_IPK_DIR)/opt/sbin or $(LIBNET11_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNET11_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBNET11_IPK_DIR)/opt/etc/libnet11/...
# Documentation files should be installed in $(LIBNET11_IPK_DIR)/opt/doc/libnet11/...
# Daemon startup scripts should be installed in $(LIBNET11_IPK_DIR)/opt/etc/init.d/S??libnet11
#
# You may need to patch your application to make it use these locations.
#
$(LIBNET11_IPK): $(LIBNET11_BUILD_DIR)/.built
	rm -rf $(LIBNET11_IPK_DIR) $(BUILD_DIR)/libnet11_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNET11_BUILD_DIR) install-strip \
		DESTDIR=$(LIBNET11_IPK_DIR) \
		libdir="/opt/lib/libnet11" \
		includedir="/opt/include/libnet11" \
		;
	$(MAKE) $(LIBNET11_IPK_DIR)/CONTROL/control
	echo $(LIBNET11_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNET11_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNET11_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnet11-ipk: $(LIBNET11_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnet11-clean:
	rm -f $(LIBNET11_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNET11_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnet11-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNET11_DIR) $(LIBNET11_BUILD_DIR) $(LIBNET11_IPK_DIR) $(LIBNET11_IPK)
#
#
# Some sanity check for the package.
#
libnet11-check: $(LIBNET11_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNET11_IPK)
