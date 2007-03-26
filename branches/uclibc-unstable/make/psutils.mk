###########################################################
#
# psutils
#
###########################################################
#
# PSUTILS_VERSION, PSUTILS_SITE and PSUTILS_SOURCE define
# the upstream location of the source code for the package.
# PSUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PSUTILS_UNZIP is the command used to unzip the source.
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
PSUTILS_SITE=ftp://ftp.gwdg.de/pub/dante/support/psutils/
PSUTILS_VERSION=p17
PSUTILS_SOURCE=psutils-$(PSUTILS_VERSION).tar.gz
PSUTILS_DIR=psutils
PSUTILS_UNZIP=zcat
PSUTILS_MAINTAINER=Bernhard Walle <bernhard.walle@gmx.de>
PSUTILS_DESCRIPTION=Describe psutils here.
PSUTILS_SECTION=tool
PSUTILS_PRIORITY=optional
PSUTILS_DEPENDS=
PSUTILS_SUGGESTS=
PSUTILS_CONFLICTS=

#
# PSUTILS_IPK_VERSION should be incremented when the ipk changes.
#
PSUTILS_IPK_VERSION=1

#
# PSUTILS_CONFFILES should be a list of user-editable files
PSUTILS_CONFFILES=

#
# PSUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PSUTILS_PATCHES=$(PSUTILS_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PSUTILS_CPPFLAGS=
PSUTILS_LDFLAGS=

#
# PSUTILS_BUILD_DIR is the directory in which the build is done.
# PSUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PSUTILS_IPK_DIR is the directory in which the ipk is built.
# PSUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PSUTILS_BUILD_DIR=$(BUILD_DIR)/psutils
PSUTILS_SOURCE_DIR=$(SOURCE_DIR)/psutils
PSUTILS_IPK_DIR=$(BUILD_DIR)/psutils-$(PSUTILS_VERSION)-ipk
PSUTILS_IPK=$(BUILD_DIR)/psutils_$(PSUTILS_VERSION)-$(PSUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PSUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PSUTILS_SITE)/$(PSUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
psutils-source: $(DL_DIR)/$(PSUTILS_SOURCE) $(PSUTILS_PATCHES)

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
$(PSUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PSUTILS_SOURCE) $(PSUTILS_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PSUTILS_DIR) $(PSUTILS_BUILD_DIR)
	$(PSUTILS_UNZIP) $(DL_DIR)/$(PSUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PSUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PSUTILS_DIR) -p1
	#mv $(BUILD_DIR)/$(PSUTILS_DIR) $(PSUTILS_BUILD_DIR)
	(cd $(PSUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		INCLUDEDIR=/opt/share/psutils \
		$(MAKE) -e -f Makefile.unix \
	)
	#$(PATCH_LIBTOOL) $(PSUTILS_BUILD_DIR)/libtool
	touch $(PSUTILS_BUILD_DIR)/.configured

psutils-unpack: $(PSUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PSUTILS_BUILD_DIR)/.built: $(PSUTILS_BUILD_DIR)/.configured
	rm -f $(PSUTILS_BUILD_DIR)/.built
	#$(MAKE) -C $(PSUTILS_BUILD_DIR)
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -e -C $(PSUTILS_BUILD_DIR) -f $(PSUTILS_BUILD_DIR)/Makefile.unix
	touch $(PSUTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
psutils: $(PSUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PSUTILS_BUILD_DIR)/.staged: $(PSUTILS_BUILD_DIR)/.built
	rm -f $(PSUTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(PSUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PSUTILS_BUILD_DIR)/.staged

psutils-stage: $(PSUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/psutils
#
$(PSUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(PSUTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: psutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PSUTILS_PRIORITY)" >>$@
	@echo "Section: $(PSUTILS_SECTION)" >>$@
	@echo "Version: $(PSUTILS_VERSION)-$(PSUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PSUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PSUTILS_SITE)/$(PSUTILS_SOURCE)" >>$@
	@echo "Description: $(PSUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PSUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(PSUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PSUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PSUTILS_IPK_DIR)/opt/sbin or $(PSUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PSUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PSUTILS_IPK_DIR)/opt/etc/psutils/...
# Documentation files should be installed in $(PSUTILS_IPK_DIR)/opt/doc/psutils/...
# Daemon startup scripts should be installed in $(PSUTILS_IPK_DIR)/opt/etc/init.d/S??psutils
#
# You may need to patch your application to make it use these locations.
#
$(PSUTILS_IPK): $(PSUTILS_BUILD_DIR)/.built
	rm -rf $(PSUTILS_IPK_DIR) $(BUILD_DIR)/psutils_*_$(TARGET_ARCH).ipk
	mkdir -p $(PSUTILS_IPK_DIR)/opt/bin $(PSUTILS_IPK_DIR)/opt/share/man/man1 \
		$(PSUTILS_IPK_DIR)/opt/share/psutils
	BINDIR=$(PSUTILS_IPK_DIR)/opt/bin \
		INCLUDEDIR=$(PSUTILS_IPK_DIR)/opt/share/psutils \
		MANDIR=$(PSUTILS_IPK_DIR)/opt/share/man/man1/ \
		$(MAKE) -C $(PSUTILS_BUILD_DIR) -e -f $(PSUTILS_BUILD_DIR)/Makefile.unix install
	$(STRIP_COMMAND) $(PSUTILS_IPK_DIR)/opt/bin/psbook  \
		$(PSUTILS_IPK_DIR)/opt/bin/psselect \
		$(PSUTILS_IPK_DIR)/opt/bin/pstops \
		$(PSUTILS_IPK_DIR)/opt/bin/epsffit \
		$(PSUTILS_IPK_DIR)/opt/bin/psnup \
		$(PSUTILS_IPK_DIR)/opt/bin/psresize 

	#install -m 755 $(PSUTILS_SOURCE_DIR)/rc.psutils $(PSUTILS_IPK_DIR)/opt/etc/init.d/SXXpsutils
	$(MAKE) $(PSUTILS_IPK_DIR)/CONTROL/control
	#install -m 755 $(PSUTILS_SOURCE_DIR)/postinst $(PSUTILS_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(PSUTILS_SOURCE_DIR)/prerm $(PSUTILS_IPK_DIR)/CONTROL/prerm
	echo $(PSUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(PSUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PSUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
psutils-ipk: $(PSUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
psutils-clean:
	rm -f $(PSUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(PSUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
psutils-dirclean:
	rm -rf $(BUILD_DIR)/$(PSUTILS_DIR) $(PSUTILS_BUILD_DIR) $(PSUTILS_IPK_DIR) $(PSUTILS_IPK)
