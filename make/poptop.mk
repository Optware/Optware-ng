###########################################################
#
# PoPToP
#
###########################################################

# You must replace "poptop" and "POPTOP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# POPTOP_VERSION, POPTOP_SITE and POPTOP_SOURCE define
# the upstream location of the source code for the package.
# POPTOP_DIR is the directory which is created when the source
# archive is unpacked.
# POPTOP_UNZIP is the command used to unzip the source.
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
POPTOP_SITE=http://dl.sourceforge.net/sourceforge/poptop
POPTOP_VERSION=1.2.1
POPTOP_SOURCE=pptpd-$(POPTOP_VERSION).tar.gz
POPTOP_DIR=pptpd-$(POPTOP_VERSION)
POPTOP_UNZIP=zcat
POPTOP_MAINTAINER=M. van Cuijk <mark@phedny.net>
POPTOP_DESCRIPTION=Poptop is the PPTP server solution for Linux.
POPTOP_SECTION=net
POPTOP_PRIORITY=optional
POPTOP_DEPENDS=
POPTOP_SUGGESTS=
POPTOP_CONFLICTS=

#
# POPTOP_IPK_VERSION should be incremented when the ipk changes.
#
POPTOP_IPK_VERSION=1

#
# POPTOP_CONFFILES should be a list of user-editable files
POPTOP_CONFFILES=/opt/etc/init.d/S20poptop /opt/etc/pptpd.conf /opt/etc/ppp/options.pptpd

#
# POPTOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
POPTOP_PATCHES=$(POPTOP_SOURCE_DIR)/poptop_configure_patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POPTOP_CPPFLAGS=
POPTOP_LDFLAGS=

#
# POPTOP_BUILD_DIR is the directory in which the build is done.
# POPTOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POPTOP_IPK_DIR is the directory in which the ipk is built.
# POPTOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POPTOP_BUILD_DIR=$(BUILD_DIR)/poptop
POPTOP_SOURCE_DIR=$(SOURCE_DIR)/poptop
POPTOP_IPK_DIR=$(BUILD_DIR)/poptop-$(POPTOP_VERSION)-ipk
POPTOP_IPK=$(BUILD_DIR)/poptop_$(POPTOP_VERSION)-$(POPTOP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POPTOP_SOURCE):
	$(WGET) -P $(DL_DIR) $(POPTOP_SITE)/$(POPTOP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
poptop-source: $(DL_DIR)/$(POPTOP_SOURCE) $(POPTOP_PATCHES)

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
$(POPTOP_BUILD_DIR)/.configured: $(DL_DIR)/$(POPTOP_SOURCE)
	rm -rf $(BUILD_DIR)/$(POPTOP_DIR) $(POPTOP_BUILD_DIR)
	$(POPTOP_UNZIP) $(DL_DIR)/$(POPTOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(POPTOP_PATCHES) | patch -d $(BUILD_DIR)/$(POPTOP_DIR) -p1
	mv $(BUILD_DIR)/$(POPTOP_DIR) $(POPTOP_BUILD_DIR)
	(cd $(POPTOP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POPTOP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POPTOP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-bcrelay \
	)
	sed -ie 's|gcc|$(TARGET_CC)|' $(POPTOP_BUILD_DIR)/plugins/Makefile
	sed -ie 's|/usr/local|/opt|' $(POPTOP_BUILD_DIR)/plugins/Makefile
	touch $(POPTOP_BUILD_DIR)/.configured

poptop-unpack: $(POPTOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POPTOP_BUILD_DIR)/.built: $(POPTOP_BUILD_DIR)/.configured
	rm -f $(POPTOP_BUILD_DIR)/.built
	$(MAKE) -C $(POPTOP_BUILD_DIR)
	touch $(POPTOP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
poptop: $(POPTOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POPTOP_BUILD_DIR)/.staged: $(POPTOP_BUILD_DIR)/.built
	rm -f $(POPTOP_BUILD_DIR)/.staged
	$(MAKE) -C $(POPTOP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(POPTOP_BUILD_DIR)/.staged

poptop-stage: $(POPTOP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/poptop
#
$(POPTOP_IPK_DIR)/CONTROL/control:
	@install -d $(POPTOP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: poptop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POPTOP_PRIORITY)" >>$@
	@echo "Section: $(POPTOP_SECTION)" >>$@
	@echo "Version: $(POPTOP_VERSION)-$(POPTOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POPTOP_MAINTAINER)" >>$@
	@echo "Source: $(POPTOP_SITE)/$(POPTOP_SOURCE)" >>$@
	@echo "Description: $(POPTOP_DESCRIPTION)" >>$@
	@echo "Depends: $(POPTOP_DEPENDS)" >>$@
	@echo "Suggests: $(POPTOP_SUGGESTS)" >>$@
	@echo "Conflicts: $(POPTOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POPTOP_IPK_DIR)/opt/sbin or $(POPTOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POPTOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POPTOP_IPK_DIR)/opt/etc/poptop/...
# Documentation files should be installed in $(POPTOP_IPK_DIR)/opt/doc/poptop/...
# Daemon startup scripts should be installed in $(POPTOP_IPK_DIR)/opt/etc/init.d/S??poptop
#
# You may need to patch your application to make it use these locations.
#
$(POPTOP_IPK): $(POPTOP_BUILD_DIR)/.built
	rm -rf $(POPTOP_IPK_DIR) $(BUILD_DIR)/poptop_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POPTOP_BUILD_DIR) DESTDIR=$(POPTOP_IPK_DIR) install
	$(STRIP_COMMAND) $(POPTOP_IPK_DIR)/opt/sbin/bcrelay
	$(STRIP_COMMAND) $(POPTOP_IPK_DIR)/opt/sbin/pptpd
	$(STRIP_COMMAND) $(POPTOP_IPK_DIR)/opt/sbin/pptpctrl
	$(STRIP_COMMAND) $(POPTOP_IPK_DIR)/opt/lib/pptpd/*.so
	install -d $(POPTOP_IPK_DIR)/opt/etc/
	install -m 644 $(POPTOP_SOURCE_DIR)/pptpd.conf $(POPTOP_IPK_DIR)/opt/etc/pptpd.conf
	install -d $(POPTOP_IPK_DIR)/opt/etc/ppp
	install -m 644 $(POPTOP_SOURCE_DIR)/options.pptpd $(POPTOP_IPK_DIR)/opt/etc/ppp/options.pptpd
	install -d $(POPTOP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(POPTOP_SOURCE_DIR)/rc.poptop $(POPTOP_IPK_DIR)/opt/etc/init.d/S20poptop
	$(MAKE) $(POPTOP_IPK_DIR)/CONTROL/control
#	install -m 755 $(POPTOP_SOURCE_DIR)/postinst $(POPTOP_IPK_DIR)/CONTROL/postinst
	install -m 755 $(POPTOP_SOURCE_DIR)/prerm $(POPTOP_IPK_DIR)/CONTROL/prerm
	echo $(POPTOP_CONFFILES) | sed -e 's/ /\n/g' > $(POPTOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POPTOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
poptop-ipk: $(POPTOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
poptop-clean:
	-$(MAKE) -C $(POPTOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
poptop-dirclean:
	rm -rf $(BUILD_DIR)/$(POPTOP_DIR) $(POPTOP_BUILD_DIR) $(POPTOP_IPK_DIR) $(POPTOP_IPK)
