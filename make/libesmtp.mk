###########################################################
#
# libesmtp
#
###########################################################

#
# LIBESMTP_VERSION, LIBESMTP_SITE and LIBESMTP_SOURCE define
# the upstream location of the source code for the package.
# LIBESMTP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBESMTP_UNZIP is the command used to unzip the source.
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
LIBESMTP_SITE=http://www.stafford.uklinux.net/libesmtp
LIBESMTP_VERSION=1.0.3r1
LIBESMTP_SOURCE=libesmtp-$(LIBESMTP_VERSION).tar.bz2
LIBESMTP_DIR=libesmtp-$(LIBESMTP_VERSION)
LIBESMTP_UNZIP=bzcat
LIBESMTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBESMTP_DESCRIPTION=libESMTP is a library to manage posting electronic mail using SMTP to a preconfigured Mail Transport Agent (MTA).
LIBESMTP_SECTION=mail
LIBESMTP_PRIORITY=optional
LIBESMTP_DEPENDS=
LIBESMTP_SUGGESTS=
LIBESMTP_CONFLICTS=

#
# LIBESMTP_IPK_VERSION should be incremented when the ipk changes.
#
LIBESMTP_IPK_VERSION=1

#
# LIBESMTP_CONFFILES should be a list of user-editable files
#LIBESMTP_CONFFILES=/opt/etc/libesmtp.conf /opt/etc/init.d/SXXlibesmtp

#
# LIBESMTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBESMTP_PATCHES=$(LIBESMTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBESMTP_CPPFLAGS=
LIBESMTP_LDFLAGS=

#
# LIBESMTP_BUILD_DIR is the directory in which the build is done.
# LIBESMTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBESMTP_IPK_DIR is the directory in which the ipk is built.
# LIBESMTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBESMTP_BUILD_DIR=$(BUILD_DIR)/libesmtp
LIBESMTP_SOURCE_DIR=$(SOURCE_DIR)/libesmtp
LIBESMTP_IPK_DIR=$(BUILD_DIR)/libesmtp-$(LIBESMTP_VERSION)-ipk
LIBESMTP_IPK=$(BUILD_DIR)/libesmtp_$(LIBESMTP_VERSION)-$(LIBESMTP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBESMTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBESMTP_SITE)/$(LIBESMTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libesmtp-source: $(DL_DIR)/$(LIBESMTP_SOURCE) $(LIBESMTP_PATCHES)

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
$(LIBESMTP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBESMTP_SOURCE) $(LIBESMTP_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(LIBESMTP_DIR) $(LIBESMTP_BUILD_DIR)
	$(LIBESMTP_UNZIP) $(DL_DIR)/$(LIBESMTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(LIBESMTP_PATCHES) | patch -d $(BUILD_DIR)/$(LIBESMTP_DIR) -p1
	mv $(BUILD_DIR)/$(LIBESMTP_DIR) $(LIBESMTP_BUILD_DIR)
	(cd $(LIBESMTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBESMTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBESMTP_LDFLAGS)" \
		acx_working_snprintf=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LIBESMTP_BUILD_DIR)/.configured

libesmtp-unpack: $(LIBESMTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBESMTP_BUILD_DIR)/.built: $(LIBESMTP_BUILD_DIR)/.configured
	rm -f $(LIBESMTP_BUILD_DIR)/.built
	$(MAKE) -C $(LIBESMTP_BUILD_DIR)
	touch $(LIBESMTP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libesmtp: $(LIBESMTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBESMTP_BUILD_DIR)/.staged: $(LIBESMTP_BUILD_DIR)/.built
	rm -f $(LIBESMTP_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBESMTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBESMTP_BUILD_DIR)/.staged

libesmtp-stage: $(LIBESMTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libesmtp
#
$(LIBESMTP_IPK_DIR)/CONTROL/control:
	@install -d $(LIBESMTP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libesmtp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBESMTP_PRIORITY)" >>$@
	@echo "Section: $(LIBESMTP_SECTION)" >>$@
	@echo "Version: $(LIBESMTP_VERSION)-$(LIBESMTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBESMTP_MAINTAINER)" >>$@
	@echo "Source: $(LIBESMTP_SITE)/$(LIBESMTP_SOURCE)" >>$@
	@echo "Description: $(LIBESMTP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBESMTP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBESMTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBESMTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBESMTP_IPK_DIR)/opt/sbin or $(LIBESMTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBESMTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBESMTP_IPK_DIR)/opt/etc/libesmtp/...
# Documentation files should be installed in $(LIBESMTP_IPK_DIR)/opt/doc/libesmtp/...
# Daemon startup scripts should be installed in $(LIBESMTP_IPK_DIR)/opt/etc/init.d/S??libesmtp
#
# You may need to patch your application to make it use these locations.
#
$(LIBESMTP_IPK): $(LIBESMTP_BUILD_DIR)/.built
	rm -rf $(LIBESMTP_IPK_DIR) $(BUILD_DIR)/libesmtp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBESMTP_BUILD_DIR) DESTDIR=$(LIBESMTP_IPK_DIR) install-strip
	install -d $(LIBESMTP_IPK_DIR)/opt/etc/
	#install -m 644 $(LIBESMTP_SOURCE_DIR)/libesmtp.conf $(LIBESMTP_IPK_DIR)/opt/etc/libesmtp.conf
	#install -d $(LIBESMTP_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LIBESMTP_SOURCE_DIR)/rc.libesmtp $(LIBESMTP_IPK_DIR)/opt/etc/init.d/SXXlibesmtp
	$(MAKE) $(LIBESMTP_IPK_DIR)/CONTROL/control
	#install -m 755 $(LIBESMTP_SOURCE_DIR)/postinst $(LIBESMTP_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LIBESMTP_SOURCE_DIR)/prerm $(LIBESMTP_IPK_DIR)/CONTROL/prerm
	#echo $(LIBESMTP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBESMTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBESMTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libesmtp-ipk: $(LIBESMTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libesmtp-clean:
	-$(MAKE) -C $(LIBESMTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libesmtp-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBESMTP_DIR) $(LIBESMTP_BUILD_DIR) $(LIBESMTP_IPK_DIR) $(LIBESMTP_IPK)
