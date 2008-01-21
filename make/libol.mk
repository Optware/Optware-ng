###########################################################
#
# libol
#
###########################################################

# You must replace "libol" and "LIBOL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBOL_VERSION, LIBOL_SITE and LIBOL_SOURCE define
# the upstream location of the source code for the package.
# LIBOL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBOL_SITE=http://www.balabit.com/downloads/libol/0.3
LIBOL_VERSION=0.3.16
LIBOL_SOURCE=libol-$(LIBOL_VERSION).tar.gz
LIBOL_DIR=libol-$(LIBOL_VERSION)
LIBOL_UNZIP=zcat
LIBOL_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
LIBOL_DESCRIPTION=Support library for syslog-ng 
LIBOL_SECTION=lib
LIBOL_PRIORITY=optional
LIBOL_DEPENDS=
LIBOL_CONFLICTS=

#
# LIBOL_IPK_VERSION should be incremented when the ipk changes.
#
LIBOL_IPK_VERSION=2

#
# LIBOL_CONFFILES should be a list of user-editable files
LIBOL_CONFFILES=

#
# LIBOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBOL_PATCHES=
#$(LIBOL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOL_CPPFLAGS=
LIBOL_LDFLAGS=

#
# LIBOL_BUILD_DIR is the directory in which the build is done.
# LIBOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOL_IPK_DIR is the directory in which the ipk is built.
# LIBOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOL_BUILD_DIR=$(BUILD_DIR)/libol
LIBOL_SOURCE_DIR=$(SOURCE_DIR)/libol
LIBOL_IPK_DIR=$(BUILD_DIR)/libol-$(LIBOL_VERSION)-ipk
LIBOL_IPK=$(BUILD_DIR)/libol_$(LIBOL_VERSION)-$(LIBOL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBOL_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libol-source: $(DL_DIR)/$(LIBOL_SOURCE) $(LIBOL_PATCHES)

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
$(LIBOL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOL_SOURCE) $(LIBOL_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBOL_DIR) $(LIBOL_BUILD_DIR)
	$(LIBOL_UNZIP) $(DL_DIR)/$(LIBOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBOL_PATCHES) | patch -d $(BUILD_DIR)/$(LIBOL_DIR) -p1
	mv $(BUILD_DIR)/$(LIBOL_DIR) $(LIBOL_BUILD_DIR)
	(cd $(LIBOL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBOL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LIBOL_BUILD_DIR)/.configured

libol-unpack: $(LIBOL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBOL_BUILD_DIR)/.built: $(LIBOL_BUILD_DIR)/.configured
	rm -f $(LIBOL_BUILD_DIR)/.built
	$(MAKE) -C $(LIBOL_BUILD_DIR)
	touch $(LIBOL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libol: $(LIBOL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOL_BUILD_DIR)/.staged: $(LIBOL_BUILD_DIR)/.built
	rm -f $(LIBOL_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBOL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBOL_BUILD_DIR)/.staged

libol-stage: $(LIBOL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libol
#
$(LIBOL_IPK_DIR)/CONTROL/control:
	@install -d $(LIBOL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libol" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOL_PRIORITY)" >>$@
	@echo "Section: $(LIBOL_SECTION)" >>$@
	@echo "Version: $(LIBOL_VERSION)-$(LIBOL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOL_MAINTAINER)" >>$@
	@echo "Source: $(LIBOL_SITE)/$(LIBOL_SOURCE)" >>$@
	@echo "Description: $(LIBOL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOL_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBOL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOL_IPK_DIR)/opt/sbin or $(LIBOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBOL_IPK_DIR)/opt/etc/libol/...
# Documentation files should be installed in $(LIBOL_IPK_DIR)/opt/doc/libol/...
# Daemon startup scripts should be installed in $(LIBOL_IPK_DIR)/opt/etc/init.d/S??libol
#
# You may need to patch your application to make it use these locations.
#
$(LIBOL_IPK): $(LIBOL_BUILD_DIR)/.built
	rm -rf $(LIBOL_IPK_DIR) $(BUILD_DIR)/libol_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOL_BUILD_DIR) DESTDIR=$(LIBOL_IPK_DIR) install
	$(MAKE) $(LIBOL_IPK_DIR)/CONTROL/control
#	install -m 644 $(LIBOL_SOURCE_DIR)/postinst $(LIBOL_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(LIBOL_SOURCE_DIR)/prerm $(LIBOL_IPK_DIR)/CONTROL/prerm
	echo $(LIBOL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libol-ipk: $(LIBOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libol-clean:
	-$(MAKE) -C $(LIBOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libol-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOL_DIR) $(LIBOL_BUILD_DIR) $(LIBOL_IPK_DIR) $(LIBOL_IPK)
