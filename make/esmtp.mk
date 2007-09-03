###########################################################
#
# esmtp
#
###########################################################

# You must replace "esmtp" and "ESMTP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ESMTP_VERSION, ESMTP_SITE and ESMTP_SOURCE define
# the upstream location of the source code for the package.
# ESMTP_DIR is the directory which is created when the source
# archive is unpacked.
# ESMTP_UNZIP is the command used to unzip the source.
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
ESMTP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/esmtp
ESMTP_VERSION=0.6.0
ESMTP_SOURCE=esmtp-$(ESMTP_VERSION).tar.bz2
ESMTP_DIR=esmtp-$(ESMTP_VERSION)
ESMTP_UNZIP=bzcat
ESMTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ESMTP_DESCRIPTION=esmtp is a user configurable relay-only Mail Transfer Agent (MTA) with a sendmail compatible syntax.
ESMTP_SECTION=mail
ESMTP_PRIORITY=optional
ESMTP_DEPENDS=libesmtp
ESMTP_SUGGESTS=
ESMTP_CONFLICTS=postfix

#
# ESMTP_IPK_VERSION should be incremented when the ipk changes.
#
ESMTP_IPK_VERSION=1

#
# ESMTP_CONFFILES should be a list of user-editable files
#ESMTP_CONFFILES=/opt/etc/esmtp.conf /opt/etc/init.d/SXXesmtp

#
# ESMTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ESMTP_PATCHES=$(ESMTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ESMTP_CPPFLAGS=
ESMTP_LDFLAGS=

#
# ESMTP_BUILD_DIR is the directory in which the build is done.
# ESMTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ESMTP_IPK_DIR is the directory in which the ipk is built.
# ESMTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ESMTP_BUILD_DIR=$(BUILD_DIR)/esmtp
ESMTP_SOURCE_DIR=$(SOURCE_DIR)/esmtp
ESMTP_IPK_DIR=$(BUILD_DIR)/esmtp-$(ESMTP_VERSION)-ipk
ESMTP_IPK=$(BUILD_DIR)/esmtp_$(ESMTP_VERSION)-$(ESMTP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ESMTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(ESMTP_SITE)/$(ESMTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
esmtp-source: $(DL_DIR)/$(ESMTP_SOURCE) $(ESMTP_PATCHES)

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
$(ESMTP_BUILD_DIR)/.configured: $(DL_DIR)/$(ESMTP_SOURCE) $(ESMTP_PATCHES)
	$(MAKE) libesmtp-stage
	rm -rf $(BUILD_DIR)/$(ESMTP_DIR) $(ESMTP_BUILD_DIR)
	$(ESMTP_UNZIP) $(DL_DIR)/$(ESMTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(ESMTP_PATCHES) | patch -d $(BUILD_DIR)/$(ESMTP_DIR) -p1
	mv $(BUILD_DIR)/$(ESMTP_DIR) $(ESMTP_BUILD_DIR)
	(cd $(ESMTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ESMTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ESMTP_LDFLAGS)" \
		PATH=$(STAGING_DIR)/opt/bin:$$PATH \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libesmtp=$(STAGING_LIB_DIR) \
		--disable-nls \
	)
	touch $(ESMTP_BUILD_DIR)/.configured

esmtp-unpack: $(ESMTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ESMTP_BUILD_DIR)/.built: $(ESMTP_BUILD_DIR)/.configured
	rm -f $(ESMTP_BUILD_DIR)/.built
	$(MAKE) -C $(ESMTP_BUILD_DIR)
	touch $(ESMTP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
esmtp: $(ESMTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ESMTP_BUILD_DIR)/.staged: $(ESMTP_BUILD_DIR)/.built
	rm -f $(ESMTP_BUILD_DIR)/.staged
	$(MAKE) -C $(ESMTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ESMTP_BUILD_DIR)/.staged

esmtp-stage: $(ESMTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/esmtp
#
$(ESMTP_IPK_DIR)/CONTROL/control:
	@install -d $(ESMTP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: esmtp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ESMTP_PRIORITY)" >>$@
	@echo "Section: $(ESMTP_SECTION)" >>$@
	@echo "Version: $(ESMTP_VERSION)-$(ESMTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ESMTP_MAINTAINER)" >>$@
	@echo "Source: $(ESMTP_SITE)/$(ESMTP_SOURCE)" >>$@
	@echo "Description: $(ESMTP_DESCRIPTION)" >>$@
	@echo "Depends: $(ESMTP_DEPENDS)" >>$@
	@echo "Suggests: $(ESMTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(ESMTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ESMTP_IPK_DIR)/opt/sbin or $(ESMTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ESMTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ESMTP_IPK_DIR)/opt/etc/esmtp/...
# Documentation files should be installed in $(ESMTP_IPK_DIR)/opt/doc/esmtp/...
# Daemon startup scripts should be installed in $(ESMTP_IPK_DIR)/opt/etc/init.d/S??esmtp
#
# You may need to patch your application to make it use these locations.
#
$(ESMTP_IPK): $(ESMTP_BUILD_DIR)/.built
	rm -rf $(ESMTP_IPK_DIR) $(BUILD_DIR)/esmtp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ESMTP_BUILD_DIR) DESTDIR=$(ESMTP_IPK_DIR) install-strip
	install -d $(ESMTP_IPK_DIR)/opt/etc/
	#install -m 644 $(ESMTP_SOURCE_DIR)/esmtp.conf $(ESMTP_IPK_DIR)/opt/etc/esmtp.conf
	#install -d $(ESMTP_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(ESMTP_SOURCE_DIR)/rc.esmtp $(ESMTP_IPK_DIR)/opt/etc/init.d/SXXesmtp
	$(MAKE) $(ESMTP_IPK_DIR)/CONTROL/control
	#install -m 755 $(ESMTP_SOURCE_DIR)/postinst $(ESMTP_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(ESMTP_SOURCE_DIR)/prerm $(ESMTP_IPK_DIR)/CONTROL/prerm
	#echo $(ESMTP_CONFFILES) | sed -e 's/ /\n/g' > $(ESMTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ESMTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
esmtp-ipk: $(ESMTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
esmtp-clean:
	-$(MAKE) -C $(ESMTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
esmtp-dirclean:
	rm -rf $(BUILD_DIR)/$(ESMTP_DIR) $(ESMTP_BUILD_DIR) $(ESMTP_IPK_DIR) $(ESMTP_IPK)

#
# Some sanity check for the package.
#
esmtp-check: $(ESMTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ESMTP_IPK)
