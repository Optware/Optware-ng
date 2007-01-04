###########################################################
#
# mysql5
#
###########################################################
#
# $Id$
#
# Warning:
#	This is work in progress
#	At this moment it compiles but it doesn't work!!!
#
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
MYSQL5_SITE=ftp://ftp.orst.edu/pub/mysql/Downloads/MySQL-5.1
MYSQL5_VERSION=5.1.11-beta
MYSQL5_SOURCE=mysql-$(MYSQL5_VERSION).tar.gz
MYSQL5_DIR=mysql-$(MYSQL5_VERSION)
MYSQL5_UNZIP=zcat
MYSQL5_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
MYSQL5_DESCRIPTION=Version 5.X of the (my)sql database system
MYSQL5_SECTION=misc
MYSQL5_PRIORITY=optional
MYSQL5_DEPENDS=zlib, ncurses, openssl, readline, libstdc++
MYSQL5_SUGGESTS=
MYSQL5_CONFLICTS=mysql

#
# MYSQL5_IPK_VERSION should be incremented when the ipk changes.
#
MYSQL5_IPK_VERSION=1

#
# MYSQL5_CONFFILES should be a list of user-editable files
MYSQL5_CONFFILES=/opt/etc/my.cnf /opt/etc/init.d/K30mysqld /opt/etc/init.d/S70mysqld

#
# MYSQL5_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MYSQL5_CROSS_PATCHES=$(MYSQL5_SOURCE_DIR)/configure.patch	\
			$(MYSQL5_SOURCE_DIR)/comp_err.patch	\
			$(MYSQL5_SOURCE_DIR)/gen_lex_hash.patch
MYSQL5_NATIVE_PATCHES=
MYSQL5_ALL_PATCHES=

ifneq ($(HOST_MACHINE),armv5b)
	MYSQL5_PATCHES=$(MYSQL5_CROSS_PATCHES) $(MYSQL5_ALL_PATCHES)
else
	MYSQL5_PATCHES=$(MYSQL5_NATIVE_PATCHES) $(MYSQL5_ALL_PATCHES)
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYSQL5_CPPFLAGS=
MYSQL5_LDFLAGS=

#
# MYSQL5_BUILD_DIR is the directory in which the build is done.
# MYSQL5_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MYSQL5_IPK_DIR is the directory in which the ipk is built.
# MYSQL5_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MYSQL5_BUILD_DIR=$(BUILD_DIR)/mysql5
MYSQL5_SOURCE_DIR=$(SOURCE_DIR)/mysql5
MYSQL5_IPK_DIR=$(BUILD_DIR)/mysql5-$(MYSQL5_VERSION)-ipk
MYSQL5_IPK=$(BUILD_DIR)/mysql5_$(MYSQL5_VERSION)-$(MYSQL5_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MYSQL5_SOURCE):
	$(WGET) -P $(DL_DIR) $(MYSQL5_SITE)/$(MYSQL5_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mysql5-source: $(DL_DIR)/$(MYSQL5_SOURCE) $(MYSQL5_PATCHES)

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
$(MYSQL5_BUILD_DIR)/.configured: $(DL_DIR)/$(MYSQL5_SOURCE) $(MYSQL5_PATCHES) make/mysql5.mk
	$(MAKE)			\
		openssl-stage	\
		ncurses-stage	\
		zlib-stage	\
		readline-stage	\
		libstdc++-stage

	rm -rf $(BUILD_DIR)/$(MYSQL5_DIR) $(MYSQL5_BUILD_DIR) $(MYSQL5_BUILD_DIR)-native
	$(MYSQL5_UNZIP) $(DL_DIR)/$(MYSQL5_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MYSQL5_PATCHES)" ; \
		then cat $(MYSQL5_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MYSQL5_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MYSQL5_DIR)" != "$(MYSQL5_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MYSQL5_DIR) $(MYSQL5_BUILD_DIR) ; \
	fi
ifneq ($(HOST_MACHINE),armv5b)
	# Cross compiling but we need a native comp_err?
	$(MAKE) mysql5-native
endif
	AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 autoreconf --install --force -v $(MYSQL5_BUILD_DIR)
	(cd $(MYSQL5_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MYSQL5_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MYSQL5_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(MYSQL5_BUILD_DIR)/libtool
	touch $(MYSQL5_BUILD_DIR)/.configured

mysql5-unpack: $(MYSQL5_BUILD_DIR)/.configured

mysql5-native: $(MYSQL5_BUILD_DIR)-native/extra/comp_err


$(MYSQL5_BUILD_DIR)-native/extra/comp_err:
	rm -rf $(BUILD_DIR)/$(MYSQL5_DIR) $(MYSQL5_BUILD_DIR)-native
	$(MYSQL5_UNZIP) $(DL_DIR)/$(MYSQL5_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(MYSQL5_DIR)" != "$(MYSQL5_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MYSQL5_DIR) $(MYSQL5_BUILD_DIR)-native; \
	fi
	cd $(MYSQL5_BUILD_DIR)-native;				\
	./configure --prefix=$(TOOL_BUILD_DIR);	\
	make;							\
	mkdir -p $(TOOL_BUILD_DIR)/bin;				\
	cp extra/comp_err $(TOOL_BUILD_DIR)/bin/comp_err

#
# This builds the actual binary.
#
$(MYSQL5_BUILD_DIR)/.built: $(MYSQL5_BUILD_DIR)/.configured
	rm -f $(MYSQL5_BUILD_DIR)/.built
	$(MAKE) -C $(MYSQL5_BUILD_DIR)
	touch $(MYSQL5_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mysql5: $(MYSQL5_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MYSQL5_BUILD_DIR)/.staged: $(MYSQL5_BUILD_DIR)/.built
	rm -f $(MYSQL5_BUILD_DIR)/.staged
	$(MAKE) -C $(MYSQL5_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MYSQL5_BUILD_DIR)/.staged

mysql5-stage: $(MYSQL5_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mysql5
#
$(MYSQL5_IPK_DIR)/CONTROL/control:
	@install -d $(MYSQL5_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mysql5" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MYSQL5_PRIORITY)" >>$@
	@echo "Section: $(MYSQL5_SECTION)" >>$@
	@echo "Version: $(MYSQL5_VERSION)-$(MYSQL5_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MYSQL5_MAINTAINER)" >>$@
	@echo "Source: $(MYSQL5_SITE)/$(MYSQL5_SOURCE)" >>$@
	@echo "Description: $(MYSQL5_DESCRIPTION)" >>$@
	@echo "Depends: $(MYSQL5_DEPENDS)" >>$@
	@echo "Suggests: $(MYSQL5_SUGGESTS)" >>$@
	@echo "Conflicts: $(MYSQL5_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MYSQL5_IPK_DIR)/opt/sbin or $(MYSQL5_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYSQL5_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MYSQL5_IPK_DIR)/opt/etc/mysql5/...
# Documentation files should be installed in $(MYSQL5_IPK_DIR)/opt/doc/mysql5/...
# Daemon startup scripts should be installed in $(MYSQL5_IPK_DIR)/opt/etc/init.d/S??mysql5
#
# You may need to patch your application to make it use these locations.
#
$(MYSQL5_IPK): $(MYSQL5_BUILD_DIR)/.built
	rm -rf $(MYSQL5_IPK_DIR) $(BUILD_DIR)/mysql5_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MYSQL5_BUILD_DIR) DESTDIR=$(MYSQL5_IPK_DIR) install-strip
	install -d $(MYSQL5_IPK_DIR)/opt/etc/
	install -m 644 $(MYSQL5_SOURCE_DIR)/my.cnf $(MYSQL5_IPK_DIR)/opt/etc/my.cnf
	install -d $(MYSQL5_IPK_DIR)/opt/etc/init.d
	( cd $(MYSQL5_IPK_DIR)/opt/etc/init.d ; \
		ln -s ../../share/mysql/armv5b-softfloat-linux-mysql.server S70mysqld ; \
		ln -s ../../share/mysql/armv5b-softfloat-linux-mysql.server K30mysqld ; \
	)
	install -d $(MYSQL5_IPK_DIR)/opt/var/lib/mysql
	install -d $(MYSQL5_IPK_DIR)/opt/var/log
	install -d $(MYSQL5_IPK_DIR)/opt/etc
	$(MAKE) $(MYSQL5_IPK_DIR)/CONTROL/control
	install -m 755 $(MYSQL5_SOURCE_DIR)/postinst $(MYSQL5_IPK_DIR)/CONTROL/postinst
	install -m 755 $(MYSQL5_SOURCE_DIR)/prerm $(MYSQL5_IPK_DIR)/CONTROL/prerm
	echo $(MYSQL5_CONFFILES) | sed -e 's/ /\n/g' > $(MYSQL5_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MYSQL5_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mysql5-ipk: $(MYSQL5_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mysql5-clean:
	rm -f $(MYSQL5_BUILD_DIR)/.built
	-$(MAKE) -C $(MYSQL5_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mysql5-dirclean:
	rm -rf $(BUILD_DIR)/$(MYSQL5_DIR) $(MYSQL5_BUILD_DIR) $(MYSQL5_IPK_DIR) $(MYSQL5_IPK)
