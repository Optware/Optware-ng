###########################################################
#
# tethereal
#
###########################################################

# You must replace "tethereal" and "TETHEREAL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TETHEREAL_VERSION, TETHEREAL_SITE and TETHEREAL_SOURCE define
# the upstream location of the source code for the package.
# TETHEREAL_DIR is the directory which is created when the source
# archive is unpacked.
# TETHEREAL_UNZIP is the command used to unzip the source.
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
TETHEREAL_SITE=http://www.ethereal.com/distribution/all-versions/
TETHEREAL_VERSION=0.10.14
TETHEREAL_SOURCE=ethereal-$(TETHEREAL_VERSION).tar.gz
TETHEREAL_DIR=ethereal-$(TETHEREAL_VERSION)
TETHEREAL_UNZIP=zcat
TETHEREAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TETHEREAL_DESCRIPTION=Terminal based ethereal to dump and analyze network traffic
TETHEREAL_SECTION=net
TETHEREAL_PRIORITY=optional
TETHEREAL_DEPENDS=adns, glib, pcre, zlib
TETHEREAL_SUGGESTS=
TETHEREAL_CONFLICTS=

#
# TETHEREAL_IPK_VERSION should be incremented when the ipk changes.
#
TETHEREAL_IPK_VERSION=3

#
# TETHEREAL_CONFFILES should be a list of user-editable files
#TETHEREAL_CONFFILES=/opt/etc/tethereal.conf /opt/etc/init.d/SXXtethereal

#
# TETHEREAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TETHEREAL_PATCHES=$(TETHEREAL_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TETHEREAL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
TETHEREAL_LDFLAGS=-lglib-2.0 -lgmodule-2.0

#
# TETHEREAL_BUILD_DIR is the directory in which the build is done.
# TETHEREAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TETHEREAL_IPK_DIR is the directory in which the ipk is built.
# TETHEREAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TETHEREAL_BUILD_DIR=$(BUILD_DIR)/tethereal
TETHEREAL_SOURCE_DIR=$(SOURCE_DIR)/tethereal
TETHEREAL_IPK_DIR=$(BUILD_DIR)/tethereal-$(TETHEREAL_VERSION)-ipk
TETHEREAL_IPK=$(BUILD_DIR)/tethereal_$(TETHEREAL_VERSION)-$(TETHEREAL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TETHEREAL_SOURCE):
	$(WGET) -P $(DL_DIR) $(TETHEREAL_SITE)/$(TETHEREAL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tethereal-source: $(DL_DIR)/$(TETHEREAL_SOURCE) $(TETHEREAL_PATCHES)

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
$(TETHEREAL_BUILD_DIR)/.configured: $(DL_DIR)/$(TETHEREAL_SOURCE) $(TETHEREAL_PATCHES)
	$(MAKE) adns-stage glib-stage libpcap-stage pcre-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(TETHEREAL_DIR) $(TETHEREAL_BUILD_DIR)
	$(TETHEREAL_UNZIP) $(DL_DIR)/$(TETHEREAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TETHEREAL_PATCHES)" ; \
		then cat $(TETHEREAL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TETHEREAL_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TETHEREAL_DIR)" != "$(TETHEREAL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TETHEREAL_DIR) $(TETHEREAL_BUILD_DIR) ; \
	fi
	(cd $(TETHEREAL_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TETHEREAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TETHEREAL_LDFLAGS)" \
		ac_ethereal_inttypes_h_defines_formats=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-ethereal=no \
		--with-glib-prefix=$(STAGING_PREFIX) \
		--disable-gtk2 \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^INCLUDES/s|-I$$(includedir)|-I$(STAGING_INCLUDE_DIR)|' $(TETHEREAL_BUILD_DIR)/plugins/docsis/Makefile
	$(PATCH_LIBTOOL) $(TETHEREAL_BUILD_DIR)/libtool
	touch $(TETHEREAL_BUILD_DIR)/.configured

tethereal-unpack: $(TETHEREAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TETHEREAL_BUILD_DIR)/.built: $(TETHEREAL_BUILD_DIR)/.configured
	rm -f $(TETHEREAL_BUILD_DIR)/.built
	$(MAKE) CC=$(HOSTCC) -C $(TETHEREAL_BUILD_DIR) rdps
	$(MAKE) CC=$(HOSTCC) -C $(TETHEREAL_BUILD_DIR)/tools/lemon lemon
	$(MAKE) -C $(TETHEREAL_BUILD_DIR)
	touch $(TETHEREAL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tethereal: $(TETHEREAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TETHEREAL_BUILD_DIR)/.staged: $(TETHEREAL_BUILD_DIR)/.built
	rm -f $(TETHEREAL_BUILD_DIR)/.staged
	$(MAKE) -C $(TETHEREAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TETHEREAL_BUILD_DIR)/.staged

tethereal-stage: $(TETHEREAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tethereal
#
$(TETHEREAL_IPK_DIR)/CONTROL/control:
	@install -d $(TETHEREAL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tethereal" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TETHEREAL_PRIORITY)" >>$@
	@echo "Section: $(TETHEREAL_SECTION)" >>$@
	@echo "Version: $(TETHEREAL_VERSION)-$(TETHEREAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TETHEREAL_MAINTAINER)" >>$@
	@echo "Source: $(TETHEREAL_SITE)/$(TETHEREAL_SOURCE)" >>$@
	@echo "Description: $(TETHEREAL_DESCRIPTION)" >>$@
	@echo "Depends: $(TETHEREAL_DEPENDS)" >>$@
	@echo "Suggests: $(TETHEREAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(TETHEREAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TETHEREAL_IPK_DIR)/opt/sbin or $(TETHEREAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TETHEREAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TETHEREAL_IPK_DIR)/opt/etc/ethereal/...
# Documentation files should be installed in $(TETHEREAL_IPK_DIR)/opt/doc/ethereal/...
# Daemon startup scripts should be installed in $(TETHEREAL_IPK_DIR)/opt/etc/init.d/S??ethereal
#
# You may need to patch your application to make it use these locations.
#
$(TETHEREAL_IPK): $(TETHEREAL_BUILD_DIR)/.built
	rm -rf $(TETHEREAL_IPK_DIR) $(BUILD_DIR)/tethereal_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TETHEREAL_BUILD_DIR) \
		DESTDIR=$(TETHEREAL_IPK_DIR) \
		program_transform_name="" \
		install-strip
	rm -f $(TETHEREAL_IPK_DIR)/opt/lib/*.la
	rm -f $(TETHEREAL_IPK_DIR)/opt/lib/ethereal/plugins/*/*.la
	install -d $(TETHEREAL_IPK_DIR)/opt/etc/
#	install -m 644 $(TETHEREAL_SOURCE_DIR)/tethereal.conf $(TETHEREAL_IPK_DIR)/opt/etc/tethereal.conf
#	install -d $(TETHEREAL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TETHEREAL_SOURCE_DIR)/rc.tethereal $(TETHEREAL_IPK_DIR)/opt/etc/init.d/SXXtethereal
	$(MAKE) $(TETHEREAL_IPK_DIR)/CONTROL/control
#	install -m 755 $(TETHEREAL_SOURCE_DIR)/postinst $(TETHEREAL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TETHEREAL_SOURCE_DIR)/prerm $(TETHEREAL_IPK_DIR)/CONTROL/prerm
	echo $(TETHEREAL_CONFFILES) | sed -e 's/ /\n/g' > $(TETHEREAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TETHEREAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tethereal-ipk: $(TETHEREAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tethereal-clean:
	rm -f $(TETHEREAL_BUILD_DIR)/.built
	-$(MAKE) -C $(TETHEREAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tethereal-dirclean:
	rm -rf $(BUILD_DIR)/$(TETHEREAL_DIR) $(TETHEREAL_BUILD_DIR) $(TETHEREAL_IPK_DIR) $(TETHEREAL_IPK)
