###########################################################
#
# redis
#
###########################################################
#
# REDIS_VERSION, REDIS_SITE and REDIS_SOURCE define
# the upstream location of the source code for the package.
# REDIS_DIR is the directory which is created when the source
# archive is unpacked.
# REDIS_UNZIP is the command used to unzip the source.
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
REDIS_SITE=http://redis.googlecode.com/files
REDIS_VERSION ?= 2.4.10
REDIS_SOURCE=redis-$(REDIS_VERSION).tar.gz
REDIS_DIR=redis-$(REDIS_VERSION)
REDIS_UNZIP=zcat
REDIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
REDIS_DESCRIPTION=Redis is an advanced key-value store.
REDIS_SECTION=misc
REDIS_PRIORITY=optional
REDIS_DEPENDS=
REDIS_SUGGESTS=
REDIS_CONFLICTS=

#
# REDIS_IPK_VERSION should be incremented when the ipk changes.
#
REDIS_IPK_VERSION=1

#
# REDIS_CONFFILES should be a list of user-editable files
#REDIS_CONFFILES=/opt/etc/redis.conf /opt/etc/init.d/SXXredis

#
# REDIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#REDIS_PATCHES=$(REDIS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
REDIS_CPPFLAGS=
REDIS_LDFLAGS=

#
# REDIS_BUILD_DIR is the directory in which the build is done.
# REDIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# REDIS_IPK_DIR is the directory in which the ipk is built.
# REDIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
REDIS_BUILD_DIR=$(BUILD_DIR)/redis
REDIS_SOURCE_DIR=$(SOURCE_DIR)/redis
REDIS_IPK_DIR=$(BUILD_DIR)/redis-$(REDIS_VERSION)-ipk
REDIS_IPK=$(BUILD_DIR)/redis_$(REDIS_VERSION)-$(REDIS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: redis-source redis-unpack redis redis-stage redis-ipk redis-clean redis-dirclean redis-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(REDIS_SOURCE):
	$(WGET) -P $(@D) $(REDIS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
redis-source: $(DL_DIR)/$(REDIS_SOURCE) $(REDIS_PATCHES)

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
$(REDIS_BUILD_DIR)/.configured: $(DL_DIR)/$(REDIS_SOURCE) $(REDIS_PATCHES) make/redis.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(REDIS_DIR) $(@D)
	$(REDIS_UNZIP) $(DL_DIR)/$(REDIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(REDIS_PATCHES)" ; \
		then cat $(REDIS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(REDIS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(REDIS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(REDIS_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(REDIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(REDIS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

redis-unpack: $(REDIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(REDIS_BUILD_DIR)/.built: $(REDIS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		FORCE_LIBC_MALLOC=yes \
		PREFIX=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(REDIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(REDIS_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
redis: $(REDIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(REDIS_BUILD_DIR)/.staged: $(REDIS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#redis-stage: $(REDIS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/redis
#
$(REDIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: redis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(REDIS_PRIORITY)" >>$@
	@echo "Section: $(REDIS_SECTION)" >>$@
	@echo "Version: $(REDIS_VERSION)-$(REDIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(REDIS_MAINTAINER)" >>$@
	@echo "Source: $(REDIS_SITE)/$(REDIS_SOURCE)" >>$@
	@echo "Description: $(REDIS_DESCRIPTION)" >>$@
	@echo "Depends: $(REDIS_DEPENDS)" >>$@
	@echo "Suggests: $(REDIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(REDIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(REDIS_IPK_DIR)/opt/sbin or $(REDIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(REDIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(REDIS_IPK_DIR)/opt/etc/redis/...
# Documentation files should be installed in $(REDIS_IPK_DIR)/opt/doc/redis/...
# Daemon startup scripts should be installed in $(REDIS_IPK_DIR)/opt/etc/init.d/S??redis
#
# You may need to patch your application to make it use these locations.
#
$(REDIS_IPK): $(REDIS_BUILD_DIR)/.built
	rm -rf $(REDIS_IPK_DIR) $(BUILD_DIR)/redis_*_$(TARGET_ARCH).ipk
ifeq (2.0.4, $(REDIS_VERSION))
	install -d $(REDIS_IPK_DIR)/opt/bin
	install -m 755 $(<D)/redis-benchmark $(<D)/redis-cli $(<D)/redis-server $(REDIS_IPK_DIR)/opt/bin/
else
	$(MAKE) -C $(REDIS_BUILD_DIR) PREFIX=$(REDIS_IPK_DIR)/opt install \
		FORCE_LIBC_MALLOC=yes \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(REDIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(REDIS_LDFLAGS)" \
		;
endif
	$(STRIP_COMMAND) $(REDIS_IPK_DIR)/opt/bin/*
	install -d $(REDIS_IPK_DIR)/opt/share/doc/redis/examples
	install -m 755 $(<D)/redis.conf $(REDIS_IPK_DIR)/opt/share/doc/redis/examples/
	$(MAKE) $(REDIS_IPK_DIR)/CONTROL/control
	echo $(REDIS_CONFFILES) | sed -e 's/ /\n/g' > $(REDIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(REDIS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(REDIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
redis-ipk: $(REDIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
redis-clean:
	rm -f $(REDIS_BUILD_DIR)/.built
	-$(MAKE) -C $(REDIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
redis-dirclean:
	rm -rf $(BUILD_DIR)/$(REDIS_DIR) $(REDIS_BUILD_DIR) $(REDIS_IPK_DIR) $(REDIS_IPK)
#
#
# Some sanity check for the package.
#
redis-check: $(REDIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
