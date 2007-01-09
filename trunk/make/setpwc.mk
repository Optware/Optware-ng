###########################################################
#
# setpwc
#
###########################################################
#
# SETPWC_VERSION, SETPWC_SITE and SETPWC_SOURCE define
# the upstream location of the source code for the package.
# SETPWC_DIR is the directory which is created when the source
# archive is unpacked.
# SETPWC_UNZIP is the command used to unzip the source.
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
SETPWC_SITE=http://www.vanheusden.com/setpwc
SETPWC_VERSION=1.2
SETPWC_SOURCE=setpwc-$(SETPWC_VERSION).tgz
SETPWC_DIR=setpwc-$(SETPWC_VERSION)
SETPWC_UNZIP=zcat
SETPWC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SETPWC_DESCRIPTION=Set and list settings of WebCams with the 'PWC chipset'
SETPWC_SECTION=misc
SETPWC_PRIORITY=optional
SETPWC_DEPENDS=
SETPWC_SUGGESTS=
SETPWC_CONFLICTS=

#
# SETPWC_IPK_VERSION should be incremented when the ipk changes.
#
SETPWC_IPK_VERSION=1

#
# SETPWC_CONFFILES should be a list of user-editable files
#SETPWC_CONFFILES=/opt/etc/setpwc.conf /opt/etc/init.d/SXXsetpwc

#
# SETPWC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SETPWC_PATCHES=$(SETPWC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SETPWC_CPPFLAGS=
SETPWC_LDFLAGS=

#
# SETPWC_BUILD_DIR is the directory in which the build is done.
# SETPWC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SETPWC_IPK_DIR is the directory in which the ipk is built.
# SETPWC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SETPWC_BUILD_DIR=$(BUILD_DIR)/setpwc
SETPWC_SOURCE_DIR=$(SOURCE_DIR)/setpwc
SETPWC_IPK_DIR=$(BUILD_DIR)/setpwc-$(SETPWC_VERSION)-ipk
SETPWC_IPK=$(BUILD_DIR)/setpwc_$(SETPWC_VERSION)-$(SETPWC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SETPWC_SOURCE):
	$(WGET) -P $(DL_DIR) $(SETPWC_SITE)/$(SETPWC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
setpwc-source: $(DL_DIR)/$(SETPWC_SOURCE) $(SETPWC_PATCHES)

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
$(SETPWC_BUILD_DIR)/.configured: $(DL_DIR)/$(SETPWC_SOURCE) $(SETPWC_PATCHES) make/setpwc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SETPWC_DIR) $(SETPWC_BUILD_DIR)
	$(SETPWC_UNZIP) $(DL_DIR)/$(SETPWC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SETPWC_PATCHES)" ; \
		then cat $(SETPWC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SETPWC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SETPWC_DIR)" != "$(SETPWC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SETPWC_DIR) $(SETPWC_BUILD_DIR) ; \
	fi
	sed -i -e '/strip/d' $(SETPWC_BUILD_DIR)/Makefile
	touch $(SETPWC_BUILD_DIR)/.configured

setpwc-unpack: $(SETPWC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SETPWC_BUILD_DIR)/.built: $(SETPWC_BUILD_DIR)/.configured
	rm -f $(SETPWC_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(SETPWC_BUILD_DIR)
	touch $(SETPWC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
setpwc: $(SETPWC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SETPWC_BUILD_DIR)/.staged: $(SETPWC_BUILD_DIR)/.built
	rm -f $(SETPWC_BUILD_DIR)/.staged
	$(MAKE) -C $(SETPWC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SETPWC_BUILD_DIR)/.staged

setpwc-stage: $(SETPWC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/setpwc
#
$(SETPWC_IPK_DIR)/CONTROL/control:
	@install -d $(SETPWC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: setpwc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SETPWC_PRIORITY)" >>$@
	@echo "Section: $(SETPWC_SECTION)" >>$@
	@echo "Version: $(SETPWC_VERSION)-$(SETPWC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SETPWC_MAINTAINER)" >>$@
	@echo "Source: $(SETPWC_SITE)/$(SETPWC_SOURCE)" >>$@
	@echo "Description: $(SETPWC_DESCRIPTION)" >>$@
	@echo "Depends: $(SETPWC_DEPENDS)" >>$@
	@echo "Suggests: $(SETPWC_SUGGESTS)" >>$@
	@echo "Conflicts: $(SETPWC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SETPWC_IPK_DIR)/opt/sbin or $(SETPWC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SETPWC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SETPWC_IPK_DIR)/opt/etc/setpwc/...
# Documentation files should be installed in $(SETPWC_IPK_DIR)/opt/doc/setpwc/...
# Daemon startup scripts should be installed in $(SETPWC_IPK_DIR)/opt/etc/init.d/S??setpwc
#
# You may need to patch your application to make it use these locations.
#
$(SETPWC_IPK): $(SETPWC_BUILD_DIR)/.built
	rm -rf $(SETPWC_IPK_DIR) $(BUILD_DIR)/setpwc_*_$(TARGET_ARCH).ipk
	install -d $(SETPWC_IPK_DIR)/opt/bin
	install -m 755 $(SETPWC_BUILD_DIR)/setpwc $(SETPWC_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(SETPWC_IPK_DIR)/opt/bin/setpwc
	install -d $(SETPWC_IPK_DIR)/opt/man/man1
	install -m 644 $(SETPWC_BUILD_DIR)/setpwc.1 $(SETPWC_IPK_DIR)/opt/man/man1
	$(MAKE) $(SETPWC_IPK_DIR)/CONTROL/control
	echo $(SETPWC_CONFFILES) | sed -e 's/ /\n/g' > $(SETPWC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SETPWC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
setpwc-ipk: $(SETPWC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
setpwc-clean:
	rm -f $(SETPWC_BUILD_DIR)/.built
	-$(MAKE) -C $(SETPWC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
setpwc-dirclean:
	rm -rf $(BUILD_DIR)/$(SETPWC_DIR) $(SETPWC_BUILD_DIR) $(SETPWC_IPK_DIR) $(SETPWC_IPK)
