###########################################################
#
# ftpd-topfield
#
###########################################################

# You must replace "ftpd-topfield" and "FTPD-TOPFIELD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FTPD-TOPFIELD_VERSION, FTPD-TOPFIELD_SITE and FTPD-TOPFIELD_SOURCE define
# the upstream location of the source code for the package.
# FTPD-TOPFIELD_DIR is the directory which is created when the source
# archive is unpacked.
# FTPD-TOPFIELD_UNZIP is the command used to unzip the source.
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
FTPD-TOPFIELD_REPOSITORY=:pserver:anonymous@puppy.cvs.sf.net:/cvsroot/puppy
FTPD-TOPFIELD_VERSION=0.7.4
FTPD-TOPFIELD_SOURCE=ftpd-topfield-$(FTPD-TOPFIELD_VERSION).tar.gz
FTPD-TOPFIELD_TAG=-r FTPD_TOPFIELD_0_7_4
FTPD-TOPFIELD_MODULE=ftpd-topfield
FTPD-TOPFIELD_LIBTOPFIELD_MODULE=libtopfield
FTPD-TOPFIELD_DIR=ftpd-topfield-$(FTPD-TOPFIELD_VERSION)
FTPD-TOPFIELD_UNZIP=zcat
FTPD-TOPFIELD_MAINTAINER=Steve Bennett <steveb@workware.net.au>
FTPD-TOPFIELD_DESCRIPTION=FTPD for the Topfield TF5000PVRt
FTPD-TOPFIELD_SECTION=net
FTPD-TOPFIELD_PRIORITY=optional

#
# FTPD-TOPFIELD_IPK_VERSION should be incremented when the ipk changes.
#
FTPD-TOPFIELD_IPK_VERSION=1

#
# FTPD-TOPFIELD_CONFFILES should be a list of user-editable files
# FTPD-TOPFIELD_CONFFILES=/opt/etc/ftpd-topfield.conf /opt/etc/init.d/SXXftpd-topfield

#
# FTPD-TOPFIELD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FTPD-TOPFIELD_PATCHES=$(FTPD-TOPFIELD_SOURCE_DIR)/usb_io.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FTPD-TOPFIELD_CPPFLAGS=
FTPD-TOPFIELD_LDFLAGS=

#
# FTPD-TOPFIELD_BUILD_DIR is the directory in which the build is done.
# FTPD-TOPFIELD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FTPD-TOPFIELD_IPK_DIR is the directory in which the ipk is built.
# FTPD-TOPFIELD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FTPD-TOPFIELD_BUILD_DIR=$(BUILD_DIR)/ftpd-topfield
FTPD-TOPFIELD_SOURCE_DIR=$(SOURCE_DIR)/ftpd-topfield
FTPD-TOPFIELD_IPK_DIR=$(BUILD_DIR)/ftpd-topfield-$(FTPD-TOPFIELD_VERSION)-ipk
FTPD-TOPFIELD_IPK=$(BUILD_DIR)/ftpd-topfield_$(FTPD-TOPFIELD_VERSION)-$(FTPD-TOPFIELD_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FTPD-TOPFIELD_SOURCE):
	cd $(DL_DIR) ; $(CVS) -d $(FTPD-TOPFIELD_REPOSITORY) co $(FTPD-TOPFIELD_TAG) $(FTPD-TOPFIELD_MODULE)
	cd $(DL_DIR)/$(FTPD-TOPFIELD_MODULE) ; $(CVS) -d $(FTPD-TOPFIELD_REPOSITORY) co $(FTPD-TOPFIELD_TAG) $(FTPD-TOPFIELD_LIBTOPFIELD_MODULE)
	mv $(DL_DIR)/$(FTPD-TOPFIELD_MODULE) $(DL_DIR)/$(FTPD-TOPFIELD_DIR)
	cd $(DL_DIR) ; tar zcvf $(FTPD-TOPFIELD_SOURCE) $(FTPD-TOPFIELD_DIR)
	rm -rf $(DL_DIR)/$(FTPD-TOPFIELD_DIR)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ftpd-topfield-source: $(DL_DIR)/$(FTPD-TOPFIELD_SOURCE) $(FTPD-TOPFIELD_PATCHES)

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
$(FTPD-TOPFIELD_BUILD_DIR)/.configured: $(DL_DIR)/$(FTPD-TOPFIELD_SOURCE) $(FTPD-TOPFIELD_PATCHES) make/ftpd-topfield.mk
	rm -rf $(BUILD_DIR)/$(FTPD-TOPFIELD_DIR) $(FTPD-TOPFIELD_BUILD_DIR)
	$(FTPD-TOPFIELD_UNZIP) $(DL_DIR)/$(FTPD-TOPFIELD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(FTPD-TOPFIELD_PATCHES) | patch -d $(BUILD_DIR)/$(FTPD-TOPFIELD_DIR) -p1
	mv $(BUILD_DIR)/$(FTPD-TOPFIELD_DIR) $(FTPD-TOPFIELD_BUILD_DIR)
	touch $(FTPD-TOPFIELD_BUILD_DIR)/.configured

ftpd-topfield-unpack: $(FTPD-TOPFIELD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FTPD-TOPFIELD_BUILD_DIR)/.built: $(FTPD-TOPFIELD_BUILD_DIR)/.configured
	rm -f $(FTPD-TOPFIELD_BUILD_DIR)/.built
	$(MAKE) -C $(FTPD-TOPFIELD_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FTPD-TOPFIELD_CPPFLAGS)" \
		LFLAGS="$(STAGING_LDFLAGS) $(FTPD-TOPFIELD_LDFLAGS)"
	touch $(FTPD-TOPFIELD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ftpd-topfield: $(FTPD-TOPFIELD_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ftpd-topfield
#
$(FTPD-TOPFIELD_IPK_DIR)/CONTROL/control:
	@install -d $(FTPD-TOPFIELD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ftpd-topfield" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FTPD-TOPFIELD_PRIORITY)" >>$@
	@echo "Section: $(FTPD-TOPFIELD_SECTION)" >>$@
	@echo "Version: $(FTPD-TOPFIELD_VERSION)-$(FTPD-TOPFIELD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FTPD-TOPFIELD_MAINTAINER)" >>$@
	@echo "Source: $(FTPD-TOPFIELD_SITE)/$(FTPD-TOPFIELD_SOURCE)" >>$@
	@echo "Description: $(FTPD-TOPFIELD_DESCRIPTION)" >>$@
	@echo "Depends: $(FTPD-TOPFIELD_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FTPD-TOPFIELD_IPK_DIR)/opt/sbin or $(FTPD-TOPFIELD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FTPD-TOPFIELD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FTPD-TOPFIELD_IPK_DIR)/opt/etc/ftpd-topfield/...
# Documentation files should be installed in $(FTPD-TOPFIELD_IPK_DIR)/opt/doc/ftpd-topfield/...
# Daemon startup scripts should be installed in $(FTPD-TOPFIELD_IPK_DIR)/opt/etc/init.d/S??ftpd-topfield
#
# You may need to patch your application to make it use these locations.
#
$(FTPD-TOPFIELD_IPK): $(FTPD-TOPFIELD_BUILD_DIR)/.built
	rm -rf $(FTPD-TOPFIELD_IPK_DIR) $(BUILD_DIR)/ftpd-topfield_*_$(TARGET_ARCH).ipk
	install -d $(FTPD-TOPFIELD_IPK_DIR)/opt/sbin/
	install -m 755 $(FTPD-TOPFIELD_BUILD_DIR)/ftpd $(FTPD-TOPFIELD_IPK_DIR)/opt/sbin/ftpd-topfield
	$(STRIP_COMMAND) $(FTPD-TOPFIELD_IPK_DIR)/opt/sbin/ftpd-topfield
#	install -d $(FTPD-TOPFIELD_IPK_DIR)/opt/etc/
#	install -m 644 $(FTPD-TOPFIELD_SOURCE_DIR)/ftpd-topfield.conf $(FTPD-TOPFIELD_IPK_DIR)/opt/etc/ftpd-topfield.conf
	install -d $(FTPD-TOPFIELD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(FTPD-TOPFIELD_SOURCE_DIR)/rc.ftpd-topfield $(FTPD-TOPFIELD_IPK_DIR)/opt/etc/init.d/S67ftpd-topfield
	$(MAKE) $(FTPD-TOPFIELD_IPK_DIR)/CONTROL/control
	install -m 755 $(FTPD-TOPFIELD_SOURCE_DIR)/postinst $(FTPD-TOPFIELD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(FTPD-TOPFIELD_SOURCE_DIR)/prerm $(FTPD-TOPFIELD_IPK_DIR)/CONTROL/prerm
	echo $(FTPD-TOPFIELD_CONFFILES) | sed -e 's/ /\n/g' > $(FTPD-TOPFIELD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FTPD-TOPFIELD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ftpd-topfield-ipk: $(FTPD-TOPFIELD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ftpd-topfield-clean:
	-$(MAKE) -C $(FTPD-TOPFIELD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ftpd-topfield-dirclean:
	rm -rf $(BUILD_DIR)/$(FTPD-TOPFIELD_DIR) $(FTPD-TOPFIELD_BUILD_DIR) $(FTPD-TOPFIELD_IPK_DIR) $(FTPD-TOPFIELD_IPK)

#
# Some sanity check for the package.
#
ftpd-topfield-check: $(FTPD-TOPFIELD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FTPD-TOPFIELD_IPK)
