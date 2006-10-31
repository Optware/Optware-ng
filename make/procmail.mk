###########################################################
#
# procmail
#
###########################################################

#
# PROCMAIL_VERSION, PROCMAIL_SITE and PROCMAIL_SOURCE define
# the upstream location of the source code for the package.
# PROCMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# PROCMAIL_UNZIP is the command used to unzip the source.
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
PROCMAIL_SITE=http://www.procmail.org
PROCMAIL_VERSION=3.22
PROCMAIL_SOURCE=procmail-$(PROCMAIL_VERSION).tar.gz
PROCMAIL_DIR=procmail-$(PROCMAIL_VERSION)
PROCMAIL_UNZIP=zcat
PROCMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PROCMAIL_DESCRIPTION=Versatile email processor.
PROCMAIL_SECTION=mail
PROCMAIL_PRIORITY=optional
PROCMAIL_DEPENDS=
PROCMAIL_CONFLICTS=

#
# PROCMAIL_IPK_VERSION should be incremented when the ipk changes.
#
PROCMAIL_IPK_VERSION=2

#
# PROCMAIL_CONFFILES should be a list of user-editable files
#PROCMAIL_CONFFILES=/opt/etc/procmail.conf /opt/etc/init.d/SXXprocmail

#
# PROCMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PROCMAIL_PATCHES=$(PROCMAIL_SOURCE_DIR)/src-Makefile.0.patch $(PROCMAIL_SOURCE_DIR)/src-autoconf.patch $(PROCMAIL_SOURCE_DIR)/config.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PROCMAIL_CPPFLAGS=
PROCMAIL_LDFLAGS=

#
# PROCMAIL_BUILD_DIR is the directory in which the build is done.
# PROCMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PROCMAIL_IPK_DIR is the directory in which the ipk is built.
# PROCMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PROCMAIL_BUILD_DIR=$(BUILD_DIR)/procmail
PROCMAIL_SOURCE_DIR=$(SOURCE_DIR)/procmail
PROCMAIL_IPK_DIR=$(BUILD_DIR)/procmail-$(PROCMAIL_VERSION)-ipk
PROCMAIL_IPK=$(BUILD_DIR)/procmail_$(PROCMAIL_VERSION)-$(PROCMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PROCMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PROCMAIL_SITE)/$(PROCMAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
procmail-source: $(DL_DIR)/$(PROCMAIL_SOURCE) $(PROCMAIL_PATCHES)

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
$(PROCMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(PROCMAIL_SOURCE) $(PROCMAIL_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PROCMAIL_DIR) $(PROCMAIL_BUILD_DIR)
	$(PROCMAIL_UNZIP) $(DL_DIR)/$(PROCMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PROCMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(PROCMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(PROCMAIL_DIR) $(PROCMAIL_BUILD_DIR)
	cp $(PROCMAIL_SOURCE_DIR)/autoconf.h $(PROCMAIL_BUILD_DIR)
	touch $(PROCMAIL_BUILD_DIR)/.configured

procmail-unpack: $(PROCMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PROCMAIL_BUILD_DIR)/.built: $(PROCMAIL_BUILD_DIR)/.configured
	rm -f $(PROCMAIL_BUILD_DIR)/.built
	$(MAKE) -C $(PROCMAIL_BUILD_DIR) \
		BASENAME=/opt \
		LIBPATHS=$(STAGING_LIB_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROCMAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROCMAIL_LDFLAGS)" \
		INSTALL=install \
		MKDIRS="install -d"
	touch $(PROCMAIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
procmail: $(PROCMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PROCMAIL_BUILD_DIR)/.staged: $(PROCMAIL_BUILD_DIR)/.built
	rm -f $(PROCMAIL_BUILD_DIR)/.staged
	$(MAKE) -C $(PROCMAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PROCMAIL_BUILD_DIR)/.staged

procmail-stage: $(PROCMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/procmail
#
$(PROCMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(PROCMAIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: procmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PROCMAIL_PRIORITY)" >>$@
	@echo "Section: $(PROCMAIL_SECTION)" >>$@
	@echo "Version: $(PROCMAIL_VERSION)-$(PROCMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PROCMAIL_MAINTAINER)" >>$@
	@echo "Source: $(PROCMAIL_SITE)/$(PROCMAIL_SOURCE)" >>$@
	@echo "Description: $(PROCMAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(PROCMAIL_DEPENDS)" >>$@
	@echo "Conflicts: $(PROCMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PROCMAIL_IPK_DIR)/opt/sbin or $(PROCMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PROCMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PROCMAIL_IPK_DIR)/opt/etc/procmail/...
# Documentation files should be installed in $(PROCMAIL_IPK_DIR)/opt/doc/procmail/...
# Daemon startup scripts should be installed in $(PROCMAIL_IPK_DIR)/opt/etc/init.d/S??procmail
#
# You may need to patch your application to make it use these locations.
#
$(PROCMAIL_IPK): $(PROCMAIL_BUILD_DIR)/.built
	rm -rf $(PROCMAIL_IPK_DIR) $(BUILD_DIR)/procmail_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PROCMAIL_BUILD_DIR) install \
		BASENAME=$(PROCMAIL_IPK_DIR)/opt \
		VISIBLE_BASENAME=/opt \
		LIBPATHS=$(STAGING_LIB_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROCMAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROCMAIL_LDFLAGS)" \
		INSTALL=install \
		MKDIRS="install -d"
	#install -d $(PROCMAIL_IPK_DIR)/opt/etc/
	#install -m 644 $(PROCMAIL_SOURCE_DIR)/procmail.conf $(PROCMAIL_IPK_DIR)/opt/etc/procmail.conf
	#install -d $(PROCMAIL_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(PROCMAIL_SOURCE_DIR)/rc.procmail $(PROCMAIL_IPK_DIR)/opt/etc/init.d/SXXprocmail
	$(MAKE) $(PROCMAIL_IPK_DIR)/CONTROL/control
	#install -m 755 $(PROCMAIL_SOURCE_DIR)/postinst $(PROCMAIL_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(PROCMAIL_SOURCE_DIR)/prerm $(PROCMAIL_IPK_DIR)/CONTROL/prerm
	#echo $(PROCMAIL_CONFFILES) | sed -e 's/ /\n/g' > $(PROCMAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PROCMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
procmail-ipk: $(PROCMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
procmail-clean:
	-$(MAKE) -C $(PROCMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
procmail-dirclean:
	rm -rf $(BUILD_DIR)/$(PROCMAIL_DIR) $(PROCMAIL_BUILD_DIR) $(PROCMAIL_IPK_DIR) $(PROCMAIL_IPK)
