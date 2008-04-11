###########################################################
#
# distcc
#
###########################################################

# You must replace "distcc" and "DISTCC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DISTCC_VERSION, DISTCC_SITE and DISTCC_SOURCE define
# the upstream location of the source code for the package.
# DISTCC_DIR is the directory which is created when the source
# archive is unpacked.
# DISTCC_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
DISTCC_SITE=http://distcc.samba.org/ftp/distcc
DISTCC_VERSION=2.18.3
DISTCC_SOURCE=distcc-$(DISTCC_VERSION).tar.bz2
DISTCC_DIR=distcc-$(DISTCC_VERSION)
DISTCC_UNZIP=bzcat
DISTCC_MAINTAINER=Jeremy Eglen <jieglen@sbcglobal.net>
DISTCC_DESCRIPTION=distributes builds across a local network
DISTCC_SECTION=util
DISTCC_PRIORITY=optional
DISTCC_DEPENDS=popt
DISTCC_CONFLICTS=

#
# DISTCC_IPK_VERSION should be incremented when the ipk changes.
#
DISTCC_IPK_VERSION=3

#
# DISTCC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DISTCC_PATCHES=$(DISTCC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DISTCC_CPPFLAGS=
DISTCC_LDFLAGS=

#
# DISTCC_BUILD_DIR is the directory in which the build is done.
# DISTCC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DISTCC_IPK_DIR is the directory in which the ipk is built.
# DISTCC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DISTCC_BUILD_DIR=$(BUILD_DIR)/distcc
DISTCC_SOURCE_DIR=$(SOURCE_DIR)/distcc
DISTCC_IPK_DIR=$(BUILD_DIR)/distcc-$(DISTCC_VERSION)-ipk
DISTCC_IPK=$(BUILD_DIR)/distcc_$(DISTCC_VERSION)-$(DISTCC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DISTCC_SOURCE):
	$(WGET) -P $(DL_DIR) $(DISTCC_SITE)/$(DISTCC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
distcc-source: $(DL_DIR)/$(DISTCC_SOURCE) $(DISTCC_PATCHES)

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
$(DISTCC_BUILD_DIR)/.configured: $(DL_DIR)/$(DISTCC_SOURCE) $(DISTCC_PATCHES)
	$(MAKE) popt-stage
	rm -rf $(BUILD_DIR)/$(DISTCC_DIR) $(DISTCC_BUILD_DIR)
	$(DISTCC_UNZIP) $(DL_DIR)/$(DISTCC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(DISTCC_PATCHES) | patch -d $(BUILD_DIR)/$(DISTCC_DIR) -p1
	mv $(BUILD_DIR)/$(DISTCC_DIR) $(DISTCC_BUILD_DIR)
	(cd $(DISTCC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DISTCC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DISTCC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(DISTCC_BUILD_DIR)/.configured

distcc-unpack: $(DISTCC_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(DISTCC_BUILD_DIR)/distcc: $(DISTCC_BUILD_DIR)/.configured
	$(MAKE) -C $(DISTCC_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
distcc: $(DISTCC_BUILD_DIR)/distcc

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/distcc
#
$(DISTCC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: distcc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DISTCC_PRIORITY)" >>$@
	@echo "Section: $(DISTCC_SECTION)" >>$@
	@echo "Version: $(DISTCC_VERSION)-$(DISTCC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DISTCC_MAINTAINER)" >>$@
	@echo "Source: $(DISTCC_SITE)/$(DISTCC_SOURCE)" >>$@
	@echo "Description: $(DISTCC_DESCRIPTION)" >>$@
	@echo "Depends: $(DISTCC_DEPENDS)" >>$@
	@echo "Conflicts: $(DISTCC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DISTCC_IPK_DIR)/opt/sbin or $(DISTCC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DISTCC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DISTCC_IPK_DIR)/opt/etc/distcc/...
# Documentation files should be installed in $(DISTCC_IPK_DIR)/opt/doc/distcc/...
# Daemon startup scripts should be installed in $(DISTCC_IPK_DIR)/opt/etc/init.d/S??distcc
#
# You may need to patch your application to make it use these locations.
#
$(DISTCC_IPK): $(DISTCC_BUILD_DIR)/distcc
	rm -rf $(DISTCC_IPK_DIR) $(DISTCC_IPK)
	install -d $(DISTCC_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(DISTCC_BUILD_DIR)/distcc -o $(DISTCC_IPK_DIR)/opt/bin/distcc
	$(STRIP_COMMAND) $(DISTCC_BUILD_DIR)/distccd -o $(DISTCC_IPK_DIR)/opt/bin/distccd
	$(STRIP_COMMAND) $(DISTCC_BUILD_DIR)/distccmon-text -o $(DISTCC_IPK_DIR)/opt/bin/distccmon-text
#	install -d $(DISTCC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DISTCC_SOURCE_DIR)/rc.distcc $(DISTCC_IPK_DIR)/opt/etc/init.d/SXXdistcc
	$(MAKE) $(DISTCC_IPK_DIR)/CONTROL/control
#	install -m 644 $(DISTCC_SOURCE_DIR)/postinst $(DISTCC_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(DISTCC_SOURCE_DIR)/prerm $(DISTCC_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DISTCC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
distcc-ipk: $(DISTCC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
distcc-clean:
	-$(MAKE) -C $(DISTCC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
distcc-dirclean:
	rm -rf $(BUILD_DIR)/$(DISTCC_DIR) $(DISTCC_BUILD_DIR) $(DISTCC_IPK_DIR) $(DISTCC_IPK)

#
# Some sanity check for the package.
#
distcc-check: $(DISTCC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DISTCC_IPK)
