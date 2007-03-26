###########################################################
#
# connect
#
###########################################################
#
# CONNECT_VERSION, CONNECT_SITE and CONNECT_SOURCE define
# the upstream location of the source code for the package.
# CONNECT_DIR is the directory which is created when the source
# archive is unpacked.
# CONNECT_UNZIP is the command used to unzip the source.
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
CONNECT_SITE=http://www.taiyo.co.jp/~gotoh/ssh
CONNECT_VERSION=1.96
CONNECT_SOURCE=connect.c
CONNECT_DIR=connect-$(CONNECT_VERSION)
CONNECT_UNZIP=zcat
CONNECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CONNECT_DESCRIPTION=A simple relaying command to make network connection via SOCKS and https proxy.
CONNECT_SECTION=net
CONNECT_PRIORITY=optional
CONNECT_DEPENDS=
CONNECT_SUGGESTS=
CONNECT_CONFLICTS=

#
# CONNECT_IPK_VERSION should be incremented when the ipk changes.
#
CONNECT_IPK_VERSION=1

#
# CONNECT_CONFFILES should be a list of user-editable files
#CONNECT_CONFFILES=/opt/etc/connect.conf /opt/etc/init.d/SXXconnect

#
# CONNECT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CONNECT_PATCHES=$(CONNECT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CONNECT_CPPFLAGS=
CONNECT_LDFLAGS=

#
# CONNECT_BUILD_DIR is the directory in which the build is done.
# CONNECT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CONNECT_IPK_DIR is the directory in which the ipk is built.
# CONNECT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CONNECT_BUILD_DIR=$(BUILD_DIR)/connect
CONNECT_SOURCE_DIR=$(SOURCE_DIR)/connect
CONNECT_IPK_DIR=$(BUILD_DIR)/connect-$(CONNECT_VERSION)-ipk
CONNECT_IPK=$(BUILD_DIR)/connect_$(CONNECT_VERSION)-$(CONNECT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: connect-source connect-unpack connect connect-stage connect-ipk connect-clean connect-dirclean connect-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CONNECT_SOURCE): make/connect.mk
	rm -f $(DL_DIR)/$(CONNECT_SOURCE)
	$(WGET) -P $(DL_DIR) $(CONNECT_SITE)/$(CONNECT_SOURCE)
	touch $(DL_DIR)/$(CONNECT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
connect-source: $(DL_DIR)/$(CONNECT_SOURCE) $(CONNECT_PATCHES)

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
$(CONNECT_BUILD_DIR)/.configured: $(DL_DIR)/$(CONNECT_SOURCE) $(CONNECT_PATCHES) make/connect.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CONNECT_DIR) $(CONNECT_BUILD_DIR)
#	$(CONNECT_UNZIP) $(DL_DIR)/$(CONNECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	if test -n "$(CONNECT_PATCHES)"; then \
		cat $(CONNECT_PATCHES) | patch -d $(BUILD_DIR)/$(CONNECT_DIR) -p0 ; \
	fi
#	if test "$(BUILD_DIR)/$(CONNECT_DIR)" != "$(CONNECT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CONNECT_DIR) $(CONNECT_BUILD_DIR) ; \
	fi
	mkdir -p $(CONNECT_BUILD_DIR)
	cp $(DL_DIR)/$(CONNECT_SOURCE) $(CONNECT_BUILD_DIR)/
#	(cd $(CONNECT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CONNECT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CONNECT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(CONNECT_BUILD_DIR)/libtool
	touch $(CONNECT_BUILD_DIR)/.configured

connect-unpack: $(CONNECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CONNECT_BUILD_DIR)/.built: $(CONNECT_BUILD_DIR)/.configured
	rm -f $(CONNECT_BUILD_DIR)/.built
#	$(MAKE) -C $(CONNECT_BUILD_DIR)
	(cd $(CONNECT_BUILD_DIR); \
	$(TARGET_CC) connect.c -o connect \
		$(STAGING_CPPFLAGS) $(CONNECT_CPPFLAGS) \
		$(STAGING_LDFLAGS) $(CONNECT_LDFLAGS) \
		; \
	)
	touch $(CONNECT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
connect: $(CONNECT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CONNECT_BUILD_DIR)/.staged: $(CONNECT_BUILD_DIR)/.built
	rm -f $(CONNECT_BUILD_DIR)/.staged
#	$(MAKE) -C $(CONNECT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CONNECT_BUILD_DIR)/.staged

connect-stage: $(CONNECT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/connect
#
$(CONNECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: connect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CONNECT_PRIORITY)" >>$@
	@echo "Section: $(CONNECT_SECTION)" >>$@
	@echo "Version: $(CONNECT_VERSION)-$(CONNECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CONNECT_MAINTAINER)" >>$@
	@echo "Source: $(CONNECT_SITE)/$(CONNECT_SOURCE)" >>$@
	@echo "Description: $(CONNECT_DESCRIPTION)" >>$@
	@echo "Depends: $(CONNECT_DEPENDS)" >>$@
	@echo "Suggests: $(CONNECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CONNECT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CONNECT_IPK_DIR)/opt/sbin or $(CONNECT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CONNECT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CONNECT_IPK_DIR)/opt/etc/connect/...
# Documentation files should be installed in $(CONNECT_IPK_DIR)/opt/doc/connect/...
# Daemon startup scripts should be installed in $(CONNECT_IPK_DIR)/opt/etc/init.d/S??connect
#
# You may need to patch your application to make it use these locations.
#
$(CONNECT_IPK): $(CONNECT_BUILD_DIR)/.built
	rm -rf $(CONNECT_IPK_DIR) $(BUILD_DIR)/connect_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(CONNECT_BUILD_DIR) DESTDIR=$(CONNECT_IPK_DIR) install-strip
	install -d $(CONNECT_IPK_DIR)/opt/bin/
	install $(CONNECT_BUILD_DIR)/connect $(CONNECT_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(CONNECT_IPK_DIR)/opt/bin/connect
	$(MAKE) $(CONNECT_IPK_DIR)/CONTROL/control
#	echo $(CONNECT_CONFFILES) | sed -e 's/ /\n/g' > $(CONNECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CONNECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
connect-ipk: $(CONNECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
connect-clean:
	rm -f $(CONNECT_BUILD_DIR)/.built
	-$(MAKE) -C $(CONNECT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
connect-dirclean:
	rm -rf $(BUILD_DIR)/$(CONNECT_DIR) $(CONNECT_BUILD_DIR) $(CONNECT_IPK_DIR) $(CONNECT_IPK)
#
#
# Some sanity check for the package.
#
connect-check: $(CONNECT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CONNECT_IPK)
