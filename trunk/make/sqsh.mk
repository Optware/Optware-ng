###########################################################
#
# sqsh
#
###########################################################

#
# SQSH_VERSION, SQSH_SITE and SQSH_SOURCE define
# the upstream location of the source code for the package.
# SQSH_DIR is the directory which is created when the source
# archive is unpacked.
# SQSH_UNZIP is the command used to unzip the source.
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
SQSH_SITE=http://dl.sf.net/sourceforge/sqsh
SQSH_VERSION=2.1.3
SQSH_SOURCE=sqsh-$(SQSH_VERSION).tar.gz
SQSH_DIR=sqsh-$(SQSH_VERSION)
SQSH_UNZIP=zcat
SQSH_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
SQSH_DESCRIPTION=Command line SQL client for MS SQL and Sybase servers.
SQSH_SECTION=misc
SQSH_PRIORITY=optional
SQSH_DEPENDS=freetds, readline, ncurses
SQSH_SUGGESTS=
SQSH_CONFLICTS=

#
# SQSH_IPK_VERSION should be incremented when the ipk changes.
#
SQSH_IPK_VERSION=1

#
# SQSH_CONFFILES should be a list of user-editable files
SQSH_CONFFILES=/opt/etc/sqshrc

#
# SQSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SQSH_PATCHES=$(SQSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQSH_CPPFLAGS=
SQSH_LDFLAGS=

#
# SQSH_BUILD_DIR is the directory in which the build is done.
# SQSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQSH_IPK_DIR is the directory in which the ipk is built.
# SQSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQSH_BUILD_DIR=$(BUILD_DIR)/sqsh
SQSH_SOURCE_DIR=$(SOURCE_DIR)/sqsh
SQSH_IPK_DIR=$(BUILD_DIR)/sqsh-$(SQSH_VERSION)-ipk
SQSH_IPK=$(BUILD_DIR)/sqsh_$(SQSH_VERSION)-$(SQSH_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SQSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(SQSH_SITE)/$(SQSH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sqsh-source: $(DL_DIR)/$(SQSH_SOURCE) $(SQSH_PATCHES)

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
$(SQSH_BUILD_DIR)/.configured: $(DL_DIR)/$(SQSH_SOURCE) $(SQSH_PATCHES)
	$(MAKE) freetds-stage readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(SQSH_DIR) $(SQSH_BUILD_DIR)
	$(SQSH_UNZIP) $(DL_DIR)/$(SQSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(SQSH_PATCHES) | patch -d $(BUILD_DIR)/$(SQSH_DIR) -p1
	mv $(BUILD_DIR)/$(SQSH_DIR) $(SQSH_BUILD_DIR)
	(cd $(SQSH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SQSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQSH_LDFLAGS)" \
		SYBASE="$(STAGING_PREFIX)" \
		INCDIRS="$(STAGING_INCLUDE_DIR)" \
		LIBDIRS="$(STAGING_LIB_DIR)" \
		ac_cv_signal_behaviour=SYSV \
		ac_cv_func_sigaction=yes \
		ac_cv_func_strcasecmp=yes \
		ac_cv_func_strerror=yes \
		ac_cv_func_strftime=yes \
		ac_cv_func_memcpy=yes \
		ac_cv_func_memmove=yes \
		ac_cv_func_localtime=yes \
		ac_cv_func_timelocal=yes \
		ac_cv_func_strchr=yes \
		ac_cv_func_gettimeofday=yes \
		ac_cv_func_poll=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-readline \
		--without-x \
	)
#	cp $(SQSH_SOURCE_DIR)/config.h $(SQSH_BUILD_DIR)/src
#	$(PATCH_LIBTOOL) $(SQSH_BUILD_DIR)/libtool
	touch $(SQSH_BUILD_DIR)/.configured

sqsh-unpack: $(SQSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQSH_BUILD_DIR)/.built: $(SQSH_BUILD_DIR)/.configured
	rm -f $(SQSH_BUILD_DIR)/.built
	$(MAKE) -C $(SQSH_BUILD_DIR) \
		SYBASE_LIBS="-ldl -lm -lct -lsybdb -ltds" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQSH_LDFLAGS)"
	touch $(SQSH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
sqsh: $(SQSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SQSH_BUILD_DIR)/.staged: $(SQSH_BUILD_DIR)/.built
	rm -f $(SQSH_BUILD_DIR)/.staged
	$(MAKE) -C $(SQSH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SQSH_BUILD_DIR)/.staged

sqsh-stage: $(SQSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sqsh
#
$(SQSH_IPK_DIR)/CONTROL/control:
	@install -d $(SQSH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sqsh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQSH_PRIORITY)" >>$@
	@echo "Section: $(SQSH_SECTION)" >>$@
	@echo "Version: $(SQSH_VERSION)-$(SQSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQSH_MAINTAINER)" >>$@
	@echo "Source: $(SQSH_SITE)/$(SQSH_SOURCE)" >>$@
	@echo "Description: $(SQSH_DESCRIPTION)" >>$@
	@echo "Depends: $(SQSH_DEPENDS)" >>$@
	@echo "Suggests: $(SQSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(SQSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQSH_IPK_DIR)/opt/sbin or $(SQSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SQSH_IPK_DIR)/opt/etc/sqsh/...
# Documentation files should be installed in $(SQSH_IPK_DIR)/opt/doc/sqsh/...
# Daemon startup scripts should be installed in $(SQSH_IPK_DIR)/opt/etc/init.d/S??sqsh
#
# You may need to patch your application to make it use these locations.
#
$(SQSH_IPK): $(SQSH_BUILD_DIR)/.built
	rm -rf $(SQSH_IPK_DIR) $(BUILD_DIR)/sqsh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SQSH_BUILD_DIR) prefix=$(SQSH_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(SQSH_IPK_DIR)/opt/bin/sqsh
#	install -d $(SQSH_IPK_DIR)/opt/etc/
#	install -m 644 $(SQSH_SOURCE_DIR)/sqsh.conf $(SQSH_IPK_DIR)/opt/etc/sqsh.conf
#	install -d $(SQSH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SQSH_SOURCE_DIR)/rc.sqsh $(SQSH_IPK_DIR)/opt/etc/init.d/SXXsqsh
	$(MAKE) $(SQSH_IPK_DIR)/CONTROL/control
#	install -m 755 $(SQSH_SOURCE_DIR)/postinst $(SQSH_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SQSH_SOURCE_DIR)/prerm $(SQSH_IPK_DIR)/CONTROL/prerm
	echo $(SQSH_CONFFILES) | sed -e 's/ /\n/g' > $(SQSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sqsh-ipk: $(SQSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sqsh-clean:
	rm -f $(SQSH_BUILD_DIR)/.built
	-$(MAKE) -C $(SQSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sqsh-dirclean:
	rm -rf $(BUILD_DIR)/$(SQSH_DIR) $(SQSH_BUILD_DIR) $(SQSH_IPK_DIR) $(SQSH_IPK)
