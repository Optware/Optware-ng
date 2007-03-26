###########################################################
#
# libnet10
#
###########################################################
#
# LIBNET10_VERSION, LIBNET10_SITE and LIBNET10_SOURCE define
# the upstream location of the source code for the package.
# LIBNET10_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNET10_UNZIP is the command used to unzip the source.
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
LIBNET10_SITE=http://www.packetfactory.net/libnet/dist/deprecated
# nemesis requires specificly 1.0.2a
LIBNET10_VERSION=1.0.2a
LIBNET10_SOURCE=libnet-$(LIBNET10_VERSION).tar.gz
LIBNET10_DIR=Libnet-$(LIBNET10_VERSION)
LIBNET10_UNZIP=zcat
LIBNET10_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNET10_DESCRIPTION=A high-level API (toolkit) allowing the application programmer to construct and inject network packets.
LIBNET10_SECTION=net
LIBNET10_PRIORITY=optional
LIBNET10_DEPENDS=
LIBNET10_SUGGESTS=
LIBNET10_CONFLICTS=

#
# LIBNET10_IPK_VERSION should be incremented when the ipk changes.
#
LIBNET10_IPK_VERSION=1

#
# LIBNET10_CONFFILES should be a list of user-editable files
#LIBNET10_CONFFILES=/opt/etc/libnet10.conf /opt/etc/init.d/SXXlibnet10

#
# LIBNET10_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBNET10_PATCHES=$(LIBNET10_SOURCE_DIR)/multiline-comment.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNET10_CPPFLAGS=
LIBNET10_LDFLAGS=

#
# LIBNET10_BUILD_DIR is the directory in which the build is done.
# LIBNET10_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNET10_IPK_DIR is the directory in which the ipk is built.
# LIBNET10_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNET10_BUILD_DIR=$(BUILD_DIR)/libnet10
LIBNET10_SOURCE_DIR=$(SOURCE_DIR)/libnet10
LIBNET10_IPK_DIR=$(BUILD_DIR)/libnet10-$(LIBNET10_VERSION)-ipk
LIBNET10_IPK=$(BUILD_DIR)/libnet10_$(LIBNET10_VERSION)-$(LIBNET10_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnet10-source libnet10-unpack libnet10 libnet10-stage libnet10-ipk libnet10-clean libnet10-dirclean libnet10-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNET10_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNET10_SITE)/$(LIBNET10_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNET10_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnet10-source: $(DL_DIR)/$(LIBNET10_SOURCE) $(LIBNET10_PATCHES)

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
$(LIBNET10_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNET10_SOURCE) $(LIBNET10_PATCHES) make/libnet10.mk
	rm -rf $(BUILD_DIR)/$(LIBNET10_DIR) $(LIBNET10_BUILD_DIR)
	$(LIBNET10_UNZIP) $(DL_DIR)/$(LIBNET10_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNET10_PATCHES)" ; \
		then cat $(LIBNET10_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBNET10_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNET10_DIR)" != "$(LIBNET10_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNET10_DIR) $(LIBNET10_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
	then sed -i -e 's|result=`cat conftest.out`|result=B|' $(LIBNET10_BUILD_DIR)/configure; \
	else sed -i -e 's|result=`cat conftest.out`|result=L|' $(LIBNET10_BUILD_DIR)/configure; \
	fi
endif
	(cd $(LIBNET10_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNET10_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNET10_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

libnet10-unpack: $(LIBNET10_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNET10_BUILD_DIR)/.built: $(LIBNET10_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNET10_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnet10: $(LIBNET10_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNET10_BUILD_DIR)/.staged: $(LIBNET10_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNET10_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libnet10-stage: $(LIBNET10_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnet10
#
$(LIBNET10_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libnet10" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNET10_PRIORITY)" >>$@
	@echo "Section: $(LIBNET10_SECTION)" >>$@
	@echo "Version: $(LIBNET10_VERSION)-$(LIBNET10_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNET10_MAINTAINER)" >>$@
	@echo "Source: $(LIBNET10_SITE)/$(LIBNET10_SOURCE)" >>$@
	@echo "Description: $(LIBNET10_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNET10_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNET10_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNET10_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNET10_IPK_DIR)/opt/sbin or $(LIBNET10_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNET10_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBNET10_IPK_DIR)/opt/etc/libnet10/...
# Documentation files should be installed in $(LIBNET10_IPK_DIR)/opt/doc/libnet10/...
# Daemon startup scripts should be installed in $(LIBNET10_IPK_DIR)/opt/etc/init.d/S??libnet10
#
# You may need to patch your application to make it use these locations.
#
$(LIBNET10_IPK): $(LIBNET10_BUILD_DIR)/.built
	rm -rf $(LIBNET10_IPK_DIR) $(BUILD_DIR)/libnet10_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNET10_BUILD_DIR) DESTDIR=$(LIBNET10_IPK_DIR) install-strip
#	install -d $(LIBNET10_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBNET10_SOURCE_DIR)/libnet10.conf $(LIBNET10_IPK_DIR)/opt/etc/libnet10.conf
#	install -d $(LIBNET10_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBNET10_SOURCE_DIR)/rc.libnet10 $(LIBNET10_IPK_DIR)/opt/etc/init.d/SXXlibnet10
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNET10_IPK_DIR)/opt/etc/init.d/SXXlibnet10
	$(MAKE) $(LIBNET10_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBNET10_SOURCE_DIR)/postinst $(LIBNET10_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNET10_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBNET10_SOURCE_DIR)/prerm $(LIBNET10_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNET10_IPK_DIR)/CONTROL/prerm
	echo $(LIBNET10_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNET10_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNET10_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnet10-ipk: $(LIBNET10_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnet10-clean:
	rm -f $(LIBNET10_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNET10_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnet10-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNET10_DIR) $(LIBNET10_BUILD_DIR) $(LIBNET10_IPK_DIR) $(LIBNET10_IPK)
#
#
# Some sanity check for the package.
#
libnet10-check: $(LIBNET10_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNET10_IPK)
