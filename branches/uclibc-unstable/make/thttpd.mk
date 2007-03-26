###########################################################
#
# thttpd
#
###########################################################

# You must replace "thttpd" and "THTTPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# THTTPD_VERSION, THTTPD_SITE and THTTPD_SOURCE define
# the upstream location of the source code for the package.
# THTTPD_DIR is the directory which is created when the source
# archive is unpacked.
# THTTPD_UNZIP is the command used to unzip the source.
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
THTTPD_SITE=http://www.acme.com/software/thttpd
THTTPD_VERSION=2.25b
THTTPD_SOURCE=thttpd-$(THTTPD_VERSION).tar.gz
THTTPD_DIR=thttpd-$(THTTPD_VERSION)
THTTPD_UNZIP=zcat
THTTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
THTTPD_DESCRIPTION=thttpd is a lightweight http server
THTTPD_SECTION=net
THTTPD_PRIORITY=optional
THTTPD_DEPENDS=
THTTPD_CONFLICTS=

#
# THTTPD_IPK_VERSION should be incremented when the ipk changes.
#
THTTPD_IPK_VERSION=5

#
# THTTPD_CONFFILES should be a list of user-editable files
THTTPD_CONFFILES=/opt/etc/init.d/S80thttpd /opt/etc/thttpd.conf

#
# THTTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
THTTPD_PATCHES=$(THTTPD_SOURCE_DIR)/Makefile.in.patch \
		$(THTTPD_SOURCE_DIR)/configure.patch \
		$(THTTPD_SOURCE_DIR)/config.h.patch \
		$(THTTPD_SOURCE_DIR)/mime_types.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
THTTPD_CPPFLAGS=
THTTPD_LDFLAGS=

#
# THTTPD_BUILD_DIR is the directory in which the build is done.
# THTTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# THTTPD_IPK_DIR is the directory in which the ipk is built.
# THTTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
THTTPD_BUILD_DIR=$(BUILD_DIR)/thttpd
THTTPD_SOURCE_DIR=$(SOURCE_DIR)/thttpd
THTTPD_IPK_DIR=$(BUILD_DIR)/thttpd-$(THTTPD_VERSION)-ipk
THTTPD_IPK=$(BUILD_DIR)/thttpd_$(THTTPD_VERSION)-$(THTTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(THTTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(THTTPD_SITE)/$(THTTPD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
thttpd-source: $(DL_DIR)/$(THTTPD_SOURCE) $(THTTPD_PATCHES)

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
$(THTTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(THTTPD_SOURCE) $(THTTPD_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(THTTPD_DIR) $(THTTPD_BUILD_DIR)
	$(THTTPD_UNZIP) $(DL_DIR)/$(THTTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(THTTPD_PATCHES) | patch -d $(BUILD_DIR)/$(THTTPD_DIR) -p1
	mv $(BUILD_DIR)/$(THTTPD_DIR) $(THTTPD_BUILD_DIR)
	(cd $(THTTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(THTTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(THTTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(THTTPD_BUILD_DIR)/.configured

thttpd-unpack: $(THTTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(THTTPD_BUILD_DIR)/.built: $(THTTPD_BUILD_DIR)/.configured
	rm -f $(THTTPD_BUILD_DIR)/.built
	$(MAKE) -C $(THTTPD_BUILD_DIR)
	touch $(THTTPD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
thttpd: $(THTTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(THTTPD_BUILD_DIR)/.staged: $(THTTPD_BUILD_DIR)/.built
	rm -f $(THTTPD_BUILD_DIR)/.staged
	$(MAKE) -C $(THTTPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(THTTPD_BUILD_DIR)/.staged

thttpd-stage: $(THTTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/thttpd
#
$(THTTPD_IPK_DIR)/CONTROL/control:
	@install -d $(THTTPD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: thttpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(THTTPD_PRIORITY)" >>$@
	@echo "Section: $(THTTPD_SECTION)" >>$@
	@echo "Version: $(THTTPD_VERSION)-$(THTTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(THTTPD_MAINTAINER)" >>$@
	@echo "Source: $(THTTPD_SITE)/$(THTTPD_SOURCE)" >>$@
	@echo "Description: $(THTTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(THTTPD_DEPENDS)" >>$@
	@echo "Conflicts: $(THTTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(THTTPD_IPK_DIR)/opt/sbin or $(THTTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(THTTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(THTTPD_IPK_DIR)/opt/etc/thttpd/...
# Documentation files should be installed in $(THTTPD_IPK_DIR)/opt/doc/thttpd/...
# Daemon startup scripts should be installed in $(THTTPD_IPK_DIR)/opt/etc/init.d/S??thttpd
#
# You may need to patch your application to make it use these locations.
#
$(THTTPD_IPK): $(THTTPD_BUILD_DIR)/.built
	rm -rf $(THTTPD_IPK_DIR) $(BUILD_DIR)/thttpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(THTTPD_BUILD_DIR) DESTDIR=$(THTTPD_IPK_DIR) install
	chmod +w $(THTTPD_IPK_DIR)/opt/sbin/thttpd && \
	$(STRIP_COMMAND) $(THTTPD_IPK_DIR)/opt/sbin/thttpd && \
	chmod -w $(THTTPD_IPK_DIR)/opt/sbin/thttpd && \
	$(STRIP_COMMAND) $(THTTPD_IPK_DIR)/opt/sbin/makeweb
	$(STRIP_COMMAND) $(THTTPD_IPK_DIR)/opt/sbin/htpasswd
	$(STRIP_COMMAND) $(THTTPD_IPK_DIR)/opt/share/www/cgi-bin/*
	install -d $(THTTPD_IPK_DIR)/opt/etc/
	install -m 644 $(THTTPD_SOURCE_DIR)/thttpd.conf $(THTTPD_IPK_DIR)/opt/etc/thttpd.conf
	install -d $(THTTPD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(THTTPD_SOURCE_DIR)/rc.thttpd $(THTTPD_IPK_DIR)/opt/etc/init.d/S80thttpd
	$(MAKE) $(THTTPD_IPK_DIR)/CONTROL/control
	install -m 755 $(THTTPD_SOURCE_DIR)/postinst $(THTTPD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(THTTPD_SOURCE_DIR)/prerm $(THTTPD_IPK_DIR)/CONTROL/prerm
	echo $(THTTPD_CONFFILES) | sed -e 's/ /\n/g' > $(THTTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(THTTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
thttpd-ipk: $(THTTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
thttpd-clean:
	-$(MAKE) -C $(THTTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
thttpd-dirclean:
	rm -rf $(BUILD_DIR)/$(THTTPD_DIR) $(THTTPD_BUILD_DIR) $(THTTPD_IPK_DIR) $(THTTPD_IPK)
