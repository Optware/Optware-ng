###########################################################
#
# doxygen
#
###########################################################

# You must replace "doxygen" and "DOXYGEN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DOXYGEN_VERSION, DOXYGEN_SITE and DOXYGEN_SOURCE define
# the upstream location of the source code for the package.
# DOXYGEN_DIR is the directory which is created when the source
# archive is unpacked.
# DOXYGEN_UNZIP is the command used to unzip the source.
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
DOXYGEN_SITE=ftp://ftp.stack.nl/pub/users/dimitri/
DOXYGEN_VERSION=1.4.6
DOXYGEN_SOURCE=doxygen-$(DOXYGEN_VERSION).src.tar.gz
DOXYGEN_DIR=doxygen-$(DOXYGEN_VERSION)
DOXYGEN_UNZIP=zcat
DOXYGEN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DOXYGEN_DESCRIPTION=A documentation system for C++, C, Java, Objective-C, Python, IDL, PHP, C#, and D.
DOXYGEN_SECTION=misc
DOXYGEN_PRIORITY=optional
DOXYGEN_DEPENDS=
DOXYGEN_SUGGESTS=
DOXYGEN_CONFLICTS=

#
# DOXYGEN_IPK_VERSION should be incremented when the ipk changes.
#
DOXYGEN_IPK_VERSION=1

#
# DOXYGEN_CONFFILES should be a list of user-editable files
#DOXYGEN_CONFFILES=/opt/etc/doxygen.conf /opt/etc/init.d/SXXdoxygen

#
# DOXYGEN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DOXYGEN_PATCHES=$(DOXYGEN_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DOXYGEN_CPPFLAGS=
DOXYGEN_LDFLAGS=

#
# DOXYGEN_BUILD_DIR is the directory in which the build is done.
# DOXYGEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DOXYGEN_IPK_DIR is the directory in which the ipk is built.
# DOXYGEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DOXYGEN_BUILD_DIR=$(BUILD_DIR)/doxygen
DOXYGEN_SOURCE_DIR=$(SOURCE_DIR)/doxygen
DOXYGEN_IPK_DIR=$(BUILD_DIR)/doxygen-$(DOXYGEN_VERSION)-ipk
DOXYGEN_IPK=$(BUILD_DIR)/doxygen_$(DOXYGEN_VERSION)-$(DOXYGEN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DOXYGEN_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOXYGEN_SITE)/$(DOXYGEN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
doxygen-source: $(DL_DIR)/$(DOXYGEN_SOURCE) $(DOXYGEN_PATCHES)

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
$(DOXYGEN_BUILD_DIR)/.configured: $(DL_DIR)/$(DOXYGEN_SOURCE) $(DOXYGEN_PATCHES) make/doxygen.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DOXYGEN_DIR) $(DOXYGEN_BUILD_DIR)
	$(DOXYGEN_UNZIP) $(DL_DIR)/$(DOXYGEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DOXYGEN_PATCHES)" ; \
		then cat $(DOXYGEN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DOXYGEN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DOXYGEN_DIR)" != "$(DOXYGEN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DOXYGEN_DIR) $(DOXYGEN_BUILD_DIR) ; \
	fi
	(cd $(DOXYGEN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DOXYGEN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DOXYGEN_LDFLAGS)" \
		./configure \
		--prefix /opt \
	)
#	$(PATCH_LIBTOOL) $(DOXYGEN_BUILD_DIR)/libtool
	touch $(DOXYGEN_BUILD_DIR)/.configured

doxygen-unpack: $(DOXYGEN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DOXYGEN_BUILD_DIR)/.built: $(DOXYGEN_BUILD_DIR)/.configured
	rm -f $(DOXYGEN_BUILD_DIR)/.built
	$(MAKE) -C $(DOXYGEN_BUILD_DIR)
	touch $(DOXYGEN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
doxygen: $(DOXYGEN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DOXYGEN_BUILD_DIR)/.staged: $(DOXYGEN_BUILD_DIR)/.built
	rm -f $(DOXYGEN_BUILD_DIR)/.staged
	$(MAKE) -C $(DOXYGEN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(DOXYGEN_BUILD_DIR)/.staged

doxygen-stage: $(DOXYGEN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/doxygen
#
$(DOXYGEN_IPK_DIR)/CONTROL/control:
	@install -d $(DOXYGEN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: doxygen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOXYGEN_PRIORITY)" >>$@
	@echo "Section: $(DOXYGEN_SECTION)" >>$@
	@echo "Version: $(DOXYGEN_VERSION)-$(DOXYGEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOXYGEN_MAINTAINER)" >>$@
	@echo "Source: $(DOXYGEN_SITE)/$(DOXYGEN_SOURCE)" >>$@
	@echo "Description: $(DOXYGEN_DESCRIPTION)" >>$@
	@echo "Depends: $(DOXYGEN_DEPENDS)" >>$@
	@echo "Suggests: $(DOXYGEN_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOXYGEN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DOXYGEN_IPK_DIR)/opt/sbin or $(DOXYGEN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DOXYGEN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DOXYGEN_IPK_DIR)/opt/etc/doxygen/...
# Documentation files should be installed in $(DOXYGEN_IPK_DIR)/opt/doc/doxygen/...
# Daemon startup scripts should be installed in $(DOXYGEN_IPK_DIR)/opt/etc/init.d/S??doxygen
#
# You may need to patch your application to make it use these locations.
#
$(DOXYGEN_IPK): $(DOXYGEN_BUILD_DIR)/.built
	rm -rf $(DOXYGEN_IPK_DIR) $(BUILD_DIR)/doxygen_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DOXYGEN_BUILD_DIR) DESTDIR=$(DOXYGEN_IPK_DIR) install
#	install -d $(DOXYGEN_IPK_DIR)/opt/etc/
#	install -m 644 $(DOXYGEN_SOURCE_DIR)/doxygen.conf $(DOXYGEN_IPK_DIR)/opt/etc/doxygen.conf
#	install -d $(DOXYGEN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DOXYGEN_SOURCE_DIR)/rc.doxygen $(DOXYGEN_IPK_DIR)/opt/etc/init.d/SXXdoxygen
	$(MAKE) $(DOXYGEN_IPK_DIR)/CONTROL/control
#	install -m 755 $(DOXYGEN_SOURCE_DIR)/postinst $(DOXYGEN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DOXYGEN_SOURCE_DIR)/prerm $(DOXYGEN_IPK_DIR)/CONTROL/prerm
	echo $(DOXYGEN_CONFFILES) | sed -e 's/ /\n/g' > $(DOXYGEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOXYGEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
doxygen-ipk: $(DOXYGEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
doxygen-clean:
	rm -f $(DOXYGEN_BUILD_DIR)/.built
	-$(MAKE) -C $(DOXYGEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
doxygen-dirclean:
	rm -rf $(BUILD_DIR)/$(DOXYGEN_DIR) $(DOXYGEN_BUILD_DIR) $(DOXYGEN_IPK_DIR) $(DOXYGEN_IPK)
