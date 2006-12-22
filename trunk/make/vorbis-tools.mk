###########################################################
#
# vorbis-tools
#
###########################################################

# You must replace "vorbis-tools" and "VORBIS-TOOLS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# VORBIS-TOOLS_VERSION, VORBIS-TOOLS_SITE and VORBIS-TOOLS_SOURCE define
# the upstream location of the source code for the package.
# VORBIS-TOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# VORBIS-TOOLS_UNZIP is the command used to unzip the source.
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
VORBIS-TOOLS_SITE=http://downloads.xiph.org/releases/vorbis
VORBIS-TOOLS_VERSION=1.1.1
VORBIS-TOOLS_SOURCE=vorbis-tools-$(VORBIS-TOOLS_VERSION).tar.gz
VORBIS-TOOLS_DIR=vorbis-tools-$(VORBIS-TOOLS_VERSION)
VORBIS-TOOLS_UNZIP=zcat
VORBIS-TOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VORBIS-TOOLS_DESCRIPTION=A set of tools to manipulate ogg-vorbis files.
VORBIS-TOOLS_SECTION=misc
VORBIS-TOOLS_PRIORITY=optional
VORBIS-TOOLS_DEPENDS=
VORBIS-TOOLS_CONFLICTS=

#
# VORBIS-TOOLS_IPK_VERSION should be incremented when the ipk changes.
#
VORBIS-TOOLS_IPK_VERSION=4

#
# VORBIS-TOOLS_CONFFILES should be a list of user-editable files
VORBIS-TOOLS_CONFFILES=

#
# VORBIS-TOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#VORBIS-TOOLS_PATCHES=$(VORBIS-TOOLS_SOURCE_DIR)/configure.ac.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VORBIS-TOOLS_CPPFLAGS=
VORBIS-TOOLS_LDFLAGS=

#
# VORBIS-TOOLS_BUILD_DIR is the directory in which the build is done.
# VORBIS-TOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VORBIS-TOOLS_IPK_DIR is the directory in which the ipk is built.
# VORBIS-TOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VORBIS-TOOLS_BUILD_DIR=$(BUILD_DIR)/vorbis-tools
VORBIS-TOOLS_SOURCE_DIR=$(SOURCE_DIR)/vorbis-tools
VORBIS-TOOLS_IPK_DIR=$(BUILD_DIR)/vorbis-tools-$(VORBIS-TOOLS_VERSION)-ipk
VORBIS-TOOLS_IPK=$(BUILD_DIR)/vorbis-tools_$(VORBIS-TOOLS_VERSION)-$(VORBIS-TOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VORBIS-TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(VORBIS-TOOLS_SITE)/$(VORBIS-TOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vorbis-tools-source: $(DL_DIR)/$(VORBIS-TOOLS_SOURCE) $(VORBIS-TOOLS_PATCHES)

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
$(VORBIS-TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(VORBIS-TOOLS_SOURCE) $(VORBIS-TOOLS_PATCHES)
	$(MAKE) libogg-stage libao-stage audiofile-stage esound-stage libcurl-stage libvorbis-stage
	rm -rf $(BUILD_DIR)/$(VORBIS-TOOLS_DIR) $(VORBIS-TOOLS_BUILD_DIR)
	$(VORBIS-TOOLS_UNZIP) $(DL_DIR)/$(VORBIS-TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VORBIS-TOOLS_PATCHES)" ; \
		then cat $(VORBIS-TOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VORBIS-TOOLS_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(VORBIS-TOOLS_DIR) $(VORBIS-TOOLS_BUILD_DIR)
	(cd $(VORBIS-TOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VORBIS-TOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VORBIS-TOOLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--without-speex \
		--without-flac \
		--with-ogg-libraries=$(STAGING_LIB_DIR) \
		--with-ogg-includes=$(STAGING_INCLUDE_DIR) \
		--with-vorbis-libraries=$(STAGING_LIB_DIR) \
		--with-vorbis-includes=$(STAGING_INCLUDE_DIR) \
		--with-ao-libraries=$(STAGING_LIB_DIR) \
		--with-ao-includes=$(STAGING_INCLUDE_DIR) \
		--with-curl-libraries=$(STAGING_LIB_DIR) \
	       	--with-curl-includes=$(STAGING_INCLUDE_DIR) \
	)
#	cat $(VORBIS-TOOLS_PATCHES) | patch -d $(VORBIS-TOOLS_BUILD_DIR) -p1
	touch $(VORBIS-TOOLS_BUILD_DIR)/.configured

vorbis-tools-unpack: $(VORBIS-TOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VORBIS-TOOLS_BUILD_DIR)/.built: $(VORBIS-TOOLS_BUILD_DIR)/.configured
	rm -f $(VORBIS-TOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(VORBIS-TOOLS_BUILD_DIR)
	touch $(VORBIS-TOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
vorbis-tools: $(VORBIS-TOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VORBIS-TOOLS_BUILD_DIR)/.staged: $(VORBIS-TOOLS_BUILD_DIR)/.built
	rm -f $(VORBIS-TOOLS_BUILD_DIR)/.staged
	$(MAKE) -C $(VORBIS-TOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(VORBIS-TOOLS_BUILD_DIR)/.staged

vorbis-tools-stage: $(VORBIS-TOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vorbis-tools
#
$(VORBIS-TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(VORBIS-TOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: vorbis-tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VORBIS-TOOLS_PRIORITY)" >>$@
	@echo "Section: $(VORBIS-TOOLS_SECTION)" >>$@
	@echo "Version: $(VORBIS-TOOLS_VERSION)-$(VORBIS-TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VORBIS-TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(VORBIS-TOOLS_SITE)/$(VORBIS-TOOLS_SOURCE)" >>$@
	@echo "Description: $(VORBIS-TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(VORBIS-TOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(VORBIS-TOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VORBIS-TOOLS_IPK_DIR)/opt/sbin or $(VORBIS-TOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VORBIS-TOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VORBIS-TOOLS_IPK_DIR)/opt/etc/vorbis-tools/...
# Documentation files should be installed in $(VORBIS-TOOLS_IPK_DIR)/opt/doc/vorbis-tools/...
# Daemon startup scripts should be installed in $(VORBIS-TOOLS_IPK_DIR)/opt/etc/init.d/S??vorbis-tools
#
# You may need to patch your application to make it use these locations.
#
$(VORBIS-TOOLS_IPK): $(VORBIS-TOOLS_BUILD_DIR)/.built
	rm -rf $(VORBIS-TOOLS_IPK_DIR) $(BUILD_DIR)/vorbis-tools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(VORBIS-TOOLS_BUILD_DIR) DESTDIR=$(VORBIS-TOOLS_IPK_DIR) program_transform_name="" install-strip
	$(MAKE) $(VORBIS-TOOLS_IPK_DIR)/CONTROL/control
	echo $(VORBIS-TOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(VORBIS-TOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VORBIS-TOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vorbis-tools-ipk: $(VORBIS-TOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vorbis-tools-clean:
	-$(MAKE) -C $(VORBIS-TOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vorbis-tools-dirclean:
	rm -rf $(BUILD_DIR)/$(VORBIS-TOOLS_DIR) $(VORBIS-TOOLS_BUILD_DIR) $(VORBIS-TOOLS_IPK_DIR) $(VORBIS-TOOLS_IPK)
