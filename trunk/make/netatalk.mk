###########################################################
#
# netatalk
#
###########################################################
#
# NETATALK_VERSION, NETATALK_SITE and NETATALK_SOURCE define
# the upstream location of the source code for the package.
# NETATALK_DIR is the directory which is created when the source
# archive is unpacked.
# NETATALK_UNZIP is the command used to unzip the source.
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
NETATALK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/netatalk
NETATALK_VERSION=2.2.0
NETATALK_SOURCE=netatalk-$(NETATALK_VERSION).tar.gz
NETATALK_DIR=netatalk-$(NETATALK_VERSION)
NETATALK_UNZIP=zcat
NETATALK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NETATALK_DESCRIPTION=Apple talk networking daemon.
NETATALK_SECTION=networking
NETATALK_PRIORITY=optional
NETATALK_DEPENDS=libdb52
NETATALK_SUGGESTS=libgcrypt
NETATALK_CONFLICTS=

#
# SYMBOL POSTFIX FOR GIVEN LIBDB (BUILD WITH UNIQUENAMES)
#
DB_VERSION="_5002"

#
# NETATALK_IPK_VERSION should be incremented when the ipk changes.
#
NETATALK_IPK_VERSION=2

#
# NETATALK_CONFFILES should be a list of user-editable files
#NETATALK_CONFFILES=/opt/etc/netatalk.conf /opt/etc/init.d/SXXnetatalk

#
# NETATALK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NETATALK_PATCHES = $(NETATALK_SOURCE_DIR)/dbd_def_AI_NUMERICSERV.patch
NETATALK_PATCHES+= $(NETATALK_SOURCE_DIR)/afp_asp_include.patch
NETATALK_PATCHES+=#$(NETATALK_SOURCE_DIR)/db3-check.patch

NETATALK_CONFIG_ARGS ?=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#NETATALK_CPPFLAGS+= -I$(@D)/include/atalk/
#NETATALK_LDFLAGS += 
ifeq ($(OPTWARE_TARGET), $(filter cs05q3armel, $(OPTWARE_TARGET)))
NETATALK_LDFLAGS += -L$(TARGET_USRLIBDIR)
endif

#
# NETATALK_BUILD_DIR is the directory in which the build is done.
# NETATALK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETATALK_IPK_DIR is the directory in which the ipk is built.
# NETATALK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETATALK_BUILD_DIR=$(BUILD_DIR)/netatalk
NETATALK_SOURCE_DIR=$(SOURCE_DIR)/netatalk
NETATALK_IPK_DIR=$(BUILD_DIR)/netatalk-$(NETATALK_VERSION)-ipk
NETATALK_IPK=$(BUILD_DIR)/netatalk_$(NETATALK_VERSION)-$(NETATALK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: netatalk-source netatalk-unpack netatalk netatalk-stage netatalk-ipk netatalk-clean netatalk-dirclean netatalk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETATALK_SOURCE):
	$(WGET) -P $(@D) $(NETATALK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netatalk-source: $(DL_DIR)/$(NETATALK_SOURCE) $(NETATALK_PATCHES)

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
$(NETATALK_BUILD_DIR)/.configured: $(DL_DIR)/$(NETATALK_SOURCE) $(NETATALK_PATCHES) make/netatalk.mk
	$(MAKE) libdb52-stage libgcrypt-stage libtool-stage
	rm -rf $(BUILD_DIR)/$(NETATALK_DIR) $(@D)
	$(NETATALK_UNZIP) $(DL_DIR)/$(NETATALK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NETATALK_PATCHES)" ; \
		then cat $(NETATALK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NETATALK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NETATALK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NETATALK_DIR) $(@D) ; \
	fi
	cd $(@D) && aclocal -I macros 
	cd $(@D) && autoheader
	cd $(@D) && autoconf
	cd $(@D) && libtoolize --automake
	cd $(@D) && automake --add-missing --force-missing
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETATALK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETATALK_LDFLAGS)" \
		netatalk_cv_SIZEOF_OFF_T=yes \
		$(NETATALK_CONFIG_ARGS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-bdb=$(STAGING_PREFIX) \
		--with-libgcrypt-dir=$(STAGING_PREFIX) \
		--with-ssl-dir=$(STAGING_PREFIX) \
		--without-shadow \
		--without-ldap \
		--enable-afp3 \
		--enable-ddp \
		--enable-timelord \
		--enable-a2boot \
		--disable-quota \
		--disable-tcp-wrappers \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e "s/db_strerror/db_strerror$(DB_VERSION)/g" $(@D)/etc/cnid_dbd/dbif.c
	sed -i -e "s/db_create/db_create$(DB_VERSION)/g" $(@D)/etc/cnid_dbd/dbif.c
	sed -i -e "s/db_env_create/db_env_create$(DB_VERSION)/g" $(@D)/etc/cnid_dbd/dbif.c
	touch $@

netatalk-unpack: $(NETATALK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETATALK_BUILD_DIR)/.built: $(NETATALK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
netatalk: $(NETATALK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETATALK_BUILD_DIR)/.staged: $(NETATALK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

netatalk-stage: $(NETATALK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/netatalk
#
$(NETATALK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: netatalk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETATALK_PRIORITY)" >>$@
	@echo "Section: $(NETATALK_SECTION)" >>$@
	@echo "Version: $(NETATALK_VERSION)-$(NETATALK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETATALK_MAINTAINER)" >>$@
	@echo "Source: $(NETATALK_SITE)/$(NETATALK_SOURCE)" >>$@
	@echo "Description: $(NETATALK_DESCRIPTION)" >>$@
	@echo "Depends: $(NETATALK_DEPENDS)" >>$@
	@echo "Suggests: $(NETATALK_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETATALK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETATALK_IPK_DIR)/opt/sbin or $(NETATALK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETATALK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETATALK_IPK_DIR)/opt/etc/netatalk/...
# Documentation files should be installed in $(NETATALK_IPK_DIR)/opt/doc/netatalk/...
# Daemon startup scripts should be installed in $(NETATALK_IPK_DIR)/opt/etc/init.d/S??netatalk
#
# You may need to patch your application to make it use these locations.
#
$(NETATALK_IPK): $(NETATALK_BUILD_DIR)/.built
	rm -rf $(NETATALK_IPK_DIR) $(BUILD_DIR)/netatalk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NETATALK_BUILD_DIR) \
		pamdir=/opt/etc/pam.d \
		DESTDIR=$(NETATALK_IPK_DIR) transform='' install-strip
	rm -f $(NETATALK_IPK_DIR)/opt/lib/*.la \
	      $(NETATALK_IPK_DIR)/opt/etc/netatalk/uams/*.la \
	      $(NETATALK_IPK_DIR)/opt/lib/libatalk.a
#	install -d $(NETATALK_IPK_DIR)/opt/etc/
#	install -m 644 $(NETATALK_SOURCE_DIR)/netatalk.conf $(NETATALK_IPK_DIR)/opt/etc/netatalk.conf
#	install -d $(NETATALK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NETATALK_SOURCE_DIR)/rc.netatalk $(NETATALK_IPK_DIR)/opt/etc/init.d/SXXnetatalk
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETATALK_IPK_DIR)/opt/etc/init.d/SXXnetatalk
	$(MAKE) $(NETATALK_IPK_DIR)/CONTROL/control
#	install -m 755 $(NETATALK_SOURCE_DIR)/postinst $(NETATALK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETATALK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NETATALK_SOURCE_DIR)/prerm $(NETATALK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETATALK_IPK_DIR)/CONTROL/prerm
	echo $(NETATALK_CONFFILES) | sed -e 's/ /\n/g' > $(NETATALK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETATALK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NETATALK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netatalk-ipk: $(NETATALK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netatalk-clean:
	rm -f $(NETATALK_BUILD_DIR)/.built
	-$(MAKE) -C $(NETATALK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netatalk-dirclean:
	rm -rf $(BUILD_DIR)/$(NETATALK_DIR) $(NETATALK_BUILD_DIR) $(NETATALK_IPK_DIR) $(NETATALK_IPK)
#
#
# Some sanity check for the package.
#
netatalk-check: $(NETATALK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
