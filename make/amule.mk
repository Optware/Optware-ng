###########################################################
#
# amule
#
###########################################################

# You must replace "amule" and "AMULE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# AMULE_VERSION, AMULE_SITE and AMULE_SOURCE define
# the upstream location of the source code for the package.
# AMULE_DIR is the directory which is created when the source
# archive is unpacked.
# AMULE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
# AMULE_SITE=http://download.berlios.de/amule/
# AMULE_VERSION=2.0.0rc8
# AMULE_SOURCE=aMule-$(AMULE_VERSION).tar.bz2
# AMULE_DIR=aMule-$(AMULE_VERSION)

AMULE_SITE=http://amule.hirnriss.net/cvs/
AMULE_VERSION=cvs-20050125
AMULE_PRD_VERSION=2.0.0rc8
AMULE_SOURCE=aMule-$(AMULE_VERSION).tar.bz2
AMULE_DIR=amule-cvs
AMULE_UNZIP=bzcat

#
# AMULE_IPK_VERSION should be incremented when the ipk changes.
#
AMULE_IPK_VERSION=1


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AMULE_CPPFLAGS=-DDEBUG_SERVER_PROTOCOL
AMULE_LDFLAGS=
#
# AMULE_BUILD_DIR is the directory in which the build is done.
# AMULE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AMULE_IPK_DIR is the directory in which the ipk is built.
# AMULE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AMULE_BUILD_DIR=$(BUILD_DIR)/amule
AMULE_SOURCE_DIR=$(SOURCE_DIR)/amule
AMULE_IPK_DIR=$(BUILD_DIR)/amule-$(AMULE_PRD_VERSION)-ipk
AMULE_IPK=$(BUILD_DIR)/amule_$(AMULE_PRD_VERSION)-$(AMULE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# AMULE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
AMULE_PATCHES=$(AMULE_SOURCE_DIR)/configure.patch \
		$(AMULE_SOURCE_DIR)/arm_pragma_pack.patch \
		$(AMULE_SOURCE_DIR)/arm_alignment.patch \
		$(AMULE_SOURCE_DIR)/arm_int64_to_float_cast.patch \
		$(AMULE_SOURCE_DIR)/emule_protocol.patch \
		$(AMULE_SOURCE_DIR)/arm_big_endian.patch
# AMULE_PATCHES=
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AMULE_SOURCE):
	$(WGET) -P $(DL_DIR) $(AMULE_SITE)/$(AMULE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
amule-source: $(DL_DIR)/$(AMULE_SOURCE) $(AMULE_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(AMULE_BUILD_DIR)/.configured: $(DL_DIR)/$(AMULE_SOURCE) 
	$(MAKE) wxbase-stage libstdc++-stage libcurl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(AMULE_DIR) $(AMULE_BUILD_DIR)
	$(AMULE_UNZIP) $(DL_DIR)/$(AMULE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(AMULE_PATCHES) | patch -d $(BUILD_DIR)/$(AMULE_DIR) -p1
	mv $(BUILD_DIR)/$(AMULE_DIR) $(AMULE_BUILD_DIR)
	(cd $(AMULE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AMULE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AMULE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-curl-config=$(STAGING_DIR)/bin/curl-config \
		--with-wxbase-config=$(STAGING_DIR)/opt/bin/wx-config \
		--with-wx-config=$(STAGING_DIR)/opt/bin/wx-config \
		--with-zlib=yes \
		--prefix=/opt \
		--enable-amulecmd \
		--enable-amule-daemon \
		--enable-webserver \
		--disable-monolithic \
		--disable-alc \
		--disable-wxcas \
		--disable-alcc \
		--disable-amulecmdgui \
		--disable-cas \
		--disable-wxcas \
		--disable-systray \
	)
	touch $(AMULE_BUILD_DIR)/.configured

amule-unpack: $(AMULE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(AMULE_BUILD_DIR)/.built: $(AMULE_BUILD_DIR)/.configured
	rm -f $(AMULE_BUILD_DIR)/.built
	$(MAKE) -C $(AMULE_BUILD_DIR)
	touch $(AMULE_BUILD_DIR)/.built

#
# These are the dependencies for the package.  Again, you should change
# the final dependency to refer directly to the main binary which is built.
#
amule: $(AMULE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#
# This builds the IPK file.
#
$(AMULE_IPK): $(AMULE_BUILD_DIR)/.built
	rm -rf $(AMULE_IPK_DIR) $(BUILD_DIR)/amule_*_$(TARGET_ARCH).ipk
	install -d $(AMULE_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(AMULE_BUILD_DIR)/src/amuled -o $(AMULE_IPK_DIR)/opt/bin/amuled
	$(STRIP_COMMAND) $(AMULE_BUILD_DIR)/src/amulecmd -o $(AMULE_IPK_DIR)/opt/bin/amulecmd
	$(STRIP_COMMAND) $(AMULE_BUILD_DIR)/src/amuleweb -o $(AMULE_IPK_DIR)/opt/bin/amuleweb
	install -d $(AMULE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(AMULE_SOURCE_DIR)/rc.amuled  $(AMULE_IPK_DIR)/opt/etc/init.d/S91amuled
	install -m 755 $(AMULE_SOURCE_DIR)/rc.amuleweb $(AMULE_IPK_DIR)/opt/etc/init.d/S92amuleweb
	install -d $(AMULE_IPK_DIR)/CONTROL
	install -m 644 $(AMULE_SOURCE_DIR)/control $(AMULE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AMULE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
amule-ipk: $(AMULE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
amule-clean:
	-$(MAKE) -C $(AMULE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
amule-dirclean: amule-clean
	rm -rf $(AMULE_BUILD_DIR) $(AMULE_IPK_DIR) $(AMULE_IPK)
