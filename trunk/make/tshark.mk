###########################################################
#
# tshark
#
###########################################################

# You must replace "tshark" and "TSHARK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TSHARK_VERSION, TSHARK_SITE and TSHARK_SOURCE define
# the upstream location of the source code for the package.
# TSHARK_DIR is the directory which is created when the source
# archive is unpacked.
# TSHARK_UNZIP is the command used to unzip the source.
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
TSHARK_SITE=http://www.wireshark.org/download/src
TSHARK_VERSION=0.99.7
TSHARK_SOURCE=wireshark-$(TSHARK_VERSION).tar.bz2
TSHARK_DIR=wireshark-$(TSHARK_VERSION)
TSHARK_UNZIP=bzcat
TSHARK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TSHARK_DESCRIPTION=Terminal based wireshark to dump and analyze network traffic
TSHARK_SECTION=net
TSHARK_PRIORITY=optional
TSHARK_DEPENDS=adns, glib, pcre, zlib
TSHARK_SUGGESTS=
TSHARK_CONFLICTS=

#
# TSHARK_IPK_VERSION should be incremented when the ipk changes.
#
TSHARK_IPK_VERSION=1

#
# TSHARK_CONFFILES should be a list of user-editable files
#TSHARK_CONFFILES=/opt/etc/tshark.conf /opt/etc/init.d/SXXtshark

#
# TSHARK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TSHARK_PATCHES=$(TSHARK_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TSHARK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
TSHARK_LDFLAGS=-lglib-2.0 -lgmodule-2.0
ifeq ($(LIBC_STYLE), uclibc)
TSHARK_LDFLAGS+=-lm
endif

#
# TSHARK_BUILD_DIR is the directory in which the build is done.
# TSHARK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TSHARK_IPK_DIR is the directory in which the ipk is built.
# TSHARK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TSHARK_BUILD_DIR=$(BUILD_DIR)/tshark
TSHARK_SOURCE_DIR=$(SOURCE_DIR)/tshark
TSHARK_IPK_DIR=$(BUILD_DIR)/tshark-$(TSHARK_VERSION)-ipk
TSHARK_IPK=$(BUILD_DIR)/tshark_$(TSHARK_VERSION)-$(TSHARK_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TSHARK_SOURCE):
	$(WGET) -P $(DL_DIR) $(TSHARK_SITE)/$(TSHARK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tshark-source: $(DL_DIR)/$(TSHARK_SOURCE) $(TSHARK_PATCHES)

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
$(TSHARK_BUILD_DIR)/.configured: $(DL_DIR)/$(TSHARK_SOURCE) $(TSHARK_PATCHES)
	$(MAKE) adns-stage glib-stage libpcap-stage pcre-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(TSHARK_DIR) $(TSHARK_BUILD_DIR)
	$(TSHARK_UNZIP) $(DL_DIR)/$(TSHARK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TSHARK_PATCHES)" ; \
		then cat $(TSHARK_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(TSHARK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TSHARK_DIR)" != "$(TSHARK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TSHARK_DIR) $(TSHARK_BUILD_DIR) ; \
	fi
	(cd $(TSHARK_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TSHARK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TSHARK_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_wireshark_inttypes_h_defines_formats=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-wireshark \
		--with-glib-prefix=$(STAGING_PREFIX) \
		--disable-gtk2 \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^INCLUDES/s|-I$$(includedir)|-I$(STAGING_INCLUDE_DIR)|' $(TSHARK_BUILD_DIR)/plugins/*/Makefile
	$(PATCH_LIBTOOL) $(TSHARK_BUILD_DIR)/libtool
	touch $(TSHARK_BUILD_DIR)/.configured

tshark-unpack: $(TSHARK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TSHARK_BUILD_DIR)/.built: $(TSHARK_BUILD_DIR)/.configured
	rm -f $(TSHARK_BUILD_DIR)/.built
	$(MAKE) CC_FOR_BUILD=$(HOSTCC) CC=$(HOSTCC) -C $(TSHARK_BUILD_DIR) rdps
	$(MAKE) CC_FOR_BUILD=$(HOSTCC) CC=$(HOSTCC) -C $(TSHARK_BUILD_DIR)/tools/lemon lemon
	$(MAKE) -C $(TSHARK_BUILD_DIR)
	touch $(TSHARK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tshark: $(TSHARK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TSHARK_BUILD_DIR)/.staged: $(TSHARK_BUILD_DIR)/.built
	rm -f $(TSHARK_BUILD_DIR)/.staged
	$(MAKE) -C $(TSHARK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TSHARK_BUILD_DIR)/.staged

tshark-stage: $(TSHARK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tshark
#
$(TSHARK_IPK_DIR)/CONTROL/control:
	@install -d $(TSHARK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tshark" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TSHARK_PRIORITY)" >>$@
	@echo "Section: $(TSHARK_SECTION)" >>$@
	@echo "Version: $(TSHARK_VERSION)-$(TSHARK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TSHARK_MAINTAINER)" >>$@
	@echo "Source: $(TSHARK_SITE)/$(TSHARK_SOURCE)" >>$@
	@echo "Description: $(TSHARK_DESCRIPTION)" >>$@
	@echo "Depends: $(TSHARK_DEPENDS)" >>$@
	@echo "Suggests: $(TSHARK_SUGGESTS)" >>$@
	@echo "Conflicts: $(TSHARK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TSHARK_IPK_DIR)/opt/sbin or $(TSHARK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TSHARK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TSHARK_IPK_DIR)/opt/etc/wireshark/...
# Documentation files should be installed in $(TSHARK_IPK_DIR)/opt/doc/wireshark/...
# Daemon startup scripts should be installed in $(TSHARK_IPK_DIR)/opt/etc/init.d/S??wireshark
#
# You may need to patch your application to make it use these locations.
#
$(TSHARK_IPK): $(TSHARK_BUILD_DIR)/.built
	rm -rf $(TSHARK_IPK_DIR) $(BUILD_DIR)/tshark_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TSHARK_BUILD_DIR) \
		DESTDIR=$(TSHARK_IPK_DIR) \
		program_transform_name="" \
		install-strip
	rm -f $(TSHARK_IPK_DIR)/opt/lib/*.la
	rm -f $(TSHARK_IPK_DIR)/opt/lib/wireshark/plugins/*/*.la
	install -d $(TSHARK_IPK_DIR)/opt/etc/
#	install -m 644 $(TSHARK_SOURCE_DIR)/tshark.conf $(TSHARK_IPK_DIR)/opt/etc/tshark.conf
#	install -d $(TSHARK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TSHARK_SOURCE_DIR)/rc.tshark $(TSHARK_IPK_DIR)/opt/etc/init.d/SXXtshark
	$(MAKE) $(TSHARK_IPK_DIR)/CONTROL/control
#	install -m 755 $(TSHARK_SOURCE_DIR)/postinst $(TSHARK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TSHARK_SOURCE_DIR)/prerm $(TSHARK_IPK_DIR)/CONTROL/prerm
	echo $(TSHARK_CONFFILES) | sed -e 's/ /\n/g' > $(TSHARK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TSHARK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tshark-ipk: $(TSHARK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tshark-clean:
	rm -f $(TSHARK_BUILD_DIR)/.built
	-$(MAKE) -C $(TSHARK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tshark-dirclean:
	rm -rf $(BUILD_DIR)/$(TSHARK_DIR) $(TSHARK_BUILD_DIR) $(TSHARK_IPK_DIR) $(TSHARK_IPK)

#
# Some sanity check for the package.
#
tshark-check: $(TSHARK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TSHARK_IPK)
