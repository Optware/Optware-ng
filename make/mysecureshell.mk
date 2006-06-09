###########################################################
#
# mysecureshell
#
###########################################################

# You must replace "mysecureshell" and "MYSECURESHELL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MYSECURESHELL_VERSION, MYSECURESHELL_SITE and MYSECURESHELL_SOURCE define
# the upstream location of the source code for the package.
# MYSECURESHELL_DIR is the directory which is created when the source
# archive is unpacked.
# MYSECURESHELL_UNZIP is the command used to unzip the source.
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
MYSECURESHELL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mysecureshell
MYSECURESHELL_VERSION=0.8
MYSECURESHELL_SOURCE=MySecureShell-$(MYSECURESHELL_VERSION)_source.tgz
MYSECURESHELL_DIR=MySecureShell_$(MYSECURESHELL_VERSION)
MYSECURESHELL_UNZIP=zcat
MYSECURESHELL_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
MYSECURESHELL_DESCRIPTION=SFTP server with configuration options
MYSECURESHELL_SECTION=net
MYSECURESHELL_PRIORITY=optional
MYSECURESHELL_DEPENDS=openssh
MYSECURESHELL_SUGGESTS=
MYSECURESHELL_CONFLICTS=

#
# MYSECURESHELL_IPK_VERSION should be incremented when the ipk changes.
#
MYSECURESHELL_IPK_VERSION=1

#
# MYSECURESHELL_CONFFILES should be a list of user-editable files
MYSECURESHELL_CONFFILES=/opt/etc/ssh/sftp_config

#
# MYSECURESHELL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MYSECURESHELL_PATCHES=$(MYSECURESHELL_SOURCE_DIR)/install.sh.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYSECURESHELL_CPPFLAGS=
MYSECURESHELL_LDFLAGS=

#
# MYSECURESHELL_BUILD_DIR is the directory in which the build is done.
# MYSECURESHELL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MYSECURESHELL_IPK_DIR is the directory in which the ipk is built.
# MYSECURESHELL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MYSECURESHELL_BUILD_DIR=$(BUILD_DIR)/mysecureshell
MYSECURESHELL_SOURCE_DIR=$(SOURCE_DIR)/mysecureshell
MYSECURESHELL_IPK_DIR=$(BUILD_DIR)/mysecureshell-$(MYSECURESHELL_VERSION)-ipk
MYSECURESHELL_IPK=$(BUILD_DIR)/mysecureshell_$(MYSECURESHELL_VERSION)-$(MYSECURESHELL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MYSECURESHELL_SOURCE):
	$(WGET) -P $(DL_DIR) $(MYSECURESHELL_SITE)/$(MYSECURESHELL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mysecureshell-source: $(DL_DIR)/$(MYSECURESHELL_SOURCE) $(MYSECURESHELL_PATCHES)

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
$(MYSECURESHELL_BUILD_DIR)/.configured: $(DL_DIR)/$(MYSECURESHELL_SOURCE) $(MYSECURESHELL_PATCHES) make/mysecureshell.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MYSECURESHELL_DIR) $(MYSECURESHELL_BUILD_DIR)
	$(MYSECURESHELL_UNZIP) $(DL_DIR)/$(MYSECURESHELL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MYSECURESHELL_PATCHES)" ; \
		then cat $(MYSECURESHELL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MYSECURESHELL_DIR) -p1 -b ; \
	fi
	if test "$(BUILD_DIR)/$(MYSECURESHELL_DIR)" != "$(MYSECURESHELL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MYSECURESHELL_DIR) $(MYSECURESHELL_BUILD_DIR) ; \
	fi
	(cd $(MYSECURESHELL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MYSECURESHELL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MYSECURESHELL_LDFLAGS)" \
		BINDIR="/opt/bin" \
		MSS_LOG="/opt/var/log/sftp-server.log" \
		MSS_CONF="/opt/etc/ssh/sftp_config" \
		MSS_SHUT="/opt/etc/sftp.shut" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MYSECURESHELL_BUILD_DIR)/libtool
	touch $(MYSECURESHELL_BUILD_DIR)/.configured

mysecureshell-unpack: $(MYSECURESHELL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MYSECURESHELL_BUILD_DIR)/.built: $(MYSECURESHELL_BUILD_DIR)/.configured
	rm -f $(MYSECURESHELL_BUILD_DIR)/.built
	$(MAKE) -C $(MYSECURESHELL_BUILD_DIR)
	touch $(MYSECURESHELL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mysecureshell: $(MYSECURESHELL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MYSECURESHELL_BUILD_DIR)/.staged: $(MYSECURESHELL_BUILD_DIR)/.built
	rm -f $(MYSECURESHELL_BUILD_DIR)/.staged
	$(MAKE) -C $(MYSECURESHELL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MYSECURESHELL_BUILD_DIR)/.staged

mysecureshell-stage: $(MYSECURESHELL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mysecureshell
#
$(MYSECURESHELL_IPK_DIR)/CONTROL/control:
	@install -d $(MYSECURESHELL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mysecureshell" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MYSECURESHELL_PRIORITY)" >>$@
	@echo "Section: $(MYSECURESHELL_SECTION)" >>$@
	@echo "Version: $(MYSECURESHELL_VERSION)-$(MYSECURESHELL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MYSECURESHELL_MAINTAINER)" >>$@
	@echo "Source: $(MYSECURESHELL_SITE)/$(MYSECURESHELL_SOURCE)" >>$@
	@echo "Description: $(MYSECURESHELL_DESCRIPTION)" >>$@
	@echo "Depends: $(MYSECURESHELL_DEPENDS)" >>$@
	@echo "Suggests: $(MYSECURESHELL_SUGGESTS)" >>$@
	@echo "Conflicts: $(MYSECURESHELL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MYSECURESHELL_IPK_DIR)/opt/sbin or $(MYSECURESHELL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYSECURESHELL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MYSECURESHELL_IPK_DIR)/opt/etc/mysecureshell/...
# Documentation files should be installed in $(MYSECURESHELL_IPK_DIR)/opt/doc/mysecureshell/...
# Daemon startup scripts should be installed in $(MYSECURESHELL_IPK_DIR)/opt/etc/init.d/S??mysecureshell
#
# You may need to patch your application to make it use these locations.
#
$(MYSECURESHELL_IPK): $(MYSECURESHELL_BUILD_DIR)/.built
	rm -rf $(MYSECURESHELL_IPK_DIR) $(BUILD_DIR)/mysecureshell_*_$(TARGET_ARCH).ipk
	install -d $(MYSECURESHELL_IPK_DIR)/opt/etc/
	install -d $(MYSECURESHELL_IPK_DIR)/opt/bin/
	install -d $(MYSECURESHELL_IPK_DIR)/opt/libexec/
	DESTDIR="$(MYSECURESHELL_IPK_DIR)" ; $(MAKE) -C $(MYSECURESHELL_BUILD_DIR)  install
	install -d $(MYSECURESHELL_IPK_DIR)/opt/doc/mysecureshell/
	install -m 644 $(MYSECURESHELL_BUILD_DIR)/README-en $(MYSECURESHELL_IPK_DIR)/opt/doc/mysecureshell/
	install -m 644 $(MYSECURESHELL_BUILD_DIR)/README-fr $(MYSECURESHELL_IPK_DIR)/opt/doc/mysecureshell/
# 	install -m 644 $(MYSECURESHELL_SOURCE_DIR)/mysecureshell.conf $(MYSECURESHELL_IPK_DIR)/opt/etc/mysecureshell.conf
#	install -d $(MYSECURESHELL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MYSECURESHELL_SOURCE_DIR)/rc.mysecureshell $(MYSECURESHELL_IPK_DIR)/opt/etc/init.d/SXXmysecureshell
	$(MAKE) $(MYSECURESHELL_IPK_DIR)/CONTROL/control
#	install -m 755 $(MYSECURESHELL_SOURCE_DIR)/postinst $(MYSECURESHELL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MYSECURESHELL_SOURCE_DIR)/prerm $(MYSECURESHELL_IPK_DIR)/CONTROL/prerm
#	echo $(MYSECURESHELL_CONFFILES) | sed -e 's/ /\n/g' > $(MYSECURESHELL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MYSECURESHELL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mysecureshell-ipk: $(MYSECURESHELL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mysecureshell-clean:
	rm -f $(MYSECURESHELL_BUILD_DIR)/.built
	-$(MAKE) -C $(MYSECURESHELL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mysecureshell-dirclean:
	rm -rf $(BUILD_DIR)/$(MYSECURESHELL_DIR) $(MYSECURESHELL_BUILD_DIR) $(MYSECURESHELL_IPK_DIR) $(MYSECURESHELL_IPK)
