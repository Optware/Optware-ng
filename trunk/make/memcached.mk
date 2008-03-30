###########################################################
#
# memcached
#
###########################################################

# You must replace "memcached" and "MEMCACHED" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MEMCACHED_VERSION, MEMCACHED_SITE and MEMCACHED_SOURCE define
# the upstream location of the source code for the package.
# MEMCACHED_DIR is the directory which is created when the source
# archive is unpacked.
# MEMCACHED_UNZIP is the command used to unzip the source.
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
MEMCACHED_SITE=http://www.danga.com/memcached/dist
MEMCACHED_VERSION=1.2.5
MEMCACHED_SOURCE=memcached-$(MEMCACHED_VERSION).tar.gz
MEMCACHED_DIR=memcached-$(MEMCACHED_VERSION)
MEMCACHED_UNZIP=zcat
MEMCACHED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MEMCACHED_DESCRIPTION=memcached is a high-performance, distributed memory object caching system.
MEMCACHED_SECTION=misc
MEMCACHED_PRIORITY=optional
MEMCACHED_DEPENDS=libevent
MEMCACHED_SUGGESTS=
MEMCACHED_CONFLICTS=

#
# MEMCACHED_IPK_VERSION should be incremented when the ipk changes.
#
MEMCACHED_IPK_VERSION=1

#
# MEMCACHED_CONFFILES should be a list of user-editable files
#MEMCACHED_CONFFILES=/opt/etc/memcached.conf /opt/etc/init.d/SXXmemcached

#
# MEMCACHED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MEMCACHED_PATCHES=$(MEMCACHED_SOURCE_DIR)/AI_ADDRCONFIG.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEMCACHED_CPPFLAGS=
MEMCACHED_LDFLAGS=
ifneq ($(OPTWARE_TARGET), wl500g)
MEMCACHED_CONFIGURE_OPTS=
else
MEMCACHED_CONFIGURE_OPTS=ac_cv_member_struct_mallinfo_arena=no
endif

#
# MEMCACHED_BUILD_DIR is the directory in which the build is done.
# MEMCACHED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEMCACHED_IPK_DIR is the directory in which the ipk is built.
# MEMCACHED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEMCACHED_BUILD_DIR=$(BUILD_DIR)/memcached
MEMCACHED_SOURCE_DIR=$(SOURCE_DIR)/memcached
MEMCACHED_IPK_DIR=$(BUILD_DIR)/memcached-$(MEMCACHED_VERSION)-ipk
MEMCACHED_IPK=$(BUILD_DIR)/memcached_$(MEMCACHED_VERSION)-$(MEMCACHED_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MEMCACHED_SOURCE):
	$(WGET) -P $(@D) $(MEMCACHED_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
memcached-source: $(DL_DIR)/$(MEMCACHED_SOURCE) $(MEMCACHED_PATCHES)

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
$(MEMCACHED_BUILD_DIR)/.configured: $(DL_DIR)/$(MEMCACHED_SOURCE) $(MEMCACHED_PATCHES) make/memcached.mk
	$(MAKE) libevent-stage
	rm -rf $(BUILD_DIR)/$(MEMCACHED_DIR) $(MEMCACHED_BUILD_DIR)
	$(MEMCACHED_UNZIP) $(DL_DIR)/$(MEMCACHED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MEMCACHED_PATCHES)" ; \
		then cat $(MEMCACHED_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MEMCACHED_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MEMCACHED_DIR)" != "$(MEMCACHED_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MEMCACHED_DIR) $(MEMCACHED_BUILD_DIR) ; \
	fi
	(cd $(@D); \
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q 'puts.*BIG_ENDIAN'; \
	then export ac_cv_c_endian=big; \
	else export ac_cv_c_endian=little; \
	fi; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MEMCACHED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MEMCACHED_LDFLAGS)" \
		$(MEMCACHED_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-libevent=$(STAGING_PREFIX) \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

memcached-unpack: $(MEMCACHED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEMCACHED_BUILD_DIR)/.built: $(MEMCACHED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
memcached: $(MEMCACHED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEMCACHED_BUILD_DIR)/.staged: $(MEMCACHED_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

memcached-stage: $(MEMCACHED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/memcached
#
$(MEMCACHED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: memcached" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEMCACHED_PRIORITY)" >>$@
	@echo "Section: $(MEMCACHED_SECTION)" >>$@
	@echo "Version: $(MEMCACHED_VERSION)-$(MEMCACHED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEMCACHED_MAINTAINER)" >>$@
	@echo "Source: $(MEMCACHED_SITE)/$(MEMCACHED_SOURCE)" >>$@
	@echo "Description: $(MEMCACHED_DESCRIPTION)" >>$@
	@echo "Depends: $(MEMCACHED_DEPENDS)" >>$@
	@echo "Suggests: $(MEMCACHED_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEMCACHED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEMCACHED_IPK_DIR)/opt/sbin or $(MEMCACHED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEMCACHED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MEMCACHED_IPK_DIR)/opt/etc/memcached/...
# Documentation files should be installed in $(MEMCACHED_IPK_DIR)/opt/doc/memcached/...
# Daemon startup scripts should be installed in $(MEMCACHED_IPK_DIR)/opt/etc/init.d/S??memcached
#
# You may need to patch your application to make it use these locations.
#
$(MEMCACHED_IPK): $(MEMCACHED_BUILD_DIR)/.built
	rm -rf $(MEMCACHED_IPK_DIR) $(BUILD_DIR)/memcached_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MEMCACHED_BUILD_DIR) DESTDIR=$(MEMCACHED_IPK_DIR) transform="" install
	$(STRIP_COMMAND) $(MEMCACHED_IPK_DIR)/opt/bin/memcached*
	$(MAKE) $(MEMCACHED_IPK_DIR)/CONTROL/control
	echo $(MEMCACHED_CONFFILES) | sed -e 's/ /\n/g' > $(MEMCACHED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEMCACHED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
memcached-ipk: $(MEMCACHED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
memcached-clean:
	rm -f $(MEMCACHED_BUILD_DIR)/.built
	-$(MAKE) -C $(MEMCACHED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
memcached-dirclean:
	rm -rf $(BUILD_DIR)/$(MEMCACHED_DIR) $(MEMCACHED_BUILD_DIR) $(MEMCACHED_IPK_DIR) $(MEMCACHED_IPK)

#
# Some sanity check for the package.
#
memcached-check: $(MEMCACHED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MEMCACHED_IPK)
