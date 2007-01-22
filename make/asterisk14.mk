###########################################################
#
# asterisk14
#
###########################################################
#
# ASTERISK14_VERSION, ASTERISK14_SITE and ASTERISK14_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK14_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK14_UNZIP is the command used to unzip the source.
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
ASTERISK14_SITE=http://ftp.digium.com/pub/asterisk/releases
ASTERISK14_VERSION=1.4.0
ASTERISK14_SOURCE=asterisk-$(ASTERISK14_VERSION).tar.gz
ASTERISK14_DIR=asterisk-$(ASTERISK14_VERSION)
ASTERISK14_UNZIP=zcat
ASTERISK14_MAINTAINER=Ovidiu Sas <sip.nslu@gmail.com>
ASTERISK14_DESCRIPTION=Asterisk is an Open Source PBX and telephony toolkit.
ASTERISK14_SECTION=util
ASTERISK14_PRIORITY=optional
ASTERISK14_DEPENDS=openssl,ncurses,libcurl,zlib,termcap,libstdc++
ASTERISK14_SUGGESTS=asterisk14-gui,sqlite2,iksemel
ASTERISK14_CONFLICTS=asterisk,asterisk-sounds

#ASTERISK14_SVN=http://svn.digium.com/svn/asterisk/trunk
#ASTERISK14_SVN_REV=51347
#ASTERISK14_VERSION=1.4.0svn-r$(ASTERISK14_SVN_REV)

#
# ASTERISK14_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK14_IPK_VERSION=5

#
# ASTERISK14_CONFFILES should be a list of user-editable files
#ASTERISK14_CONFFILES=/opt/etc/asterisk14.conf /opt/etc/init.d/SXXasterisk14

#
# ASTERISK14_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK14_PATCHES=$(ASTERISK14_SOURCE_DIR)/main-db1-ast-Makefile.patch\
			$(ASTERISK14_SOURCE_DIR)/gsm.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET), slugosbe)
ASTERISK14_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR) -DPATH_MAX=4096
else
ASTERISK14_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR)
endif
ASTERISK14_LDFLAGS=

#
# ASTERISK14_BUILD_DIR is the directory in which the build is done.
# ASTERISK14_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK14_IPK_DIR is the directory in which the ipk is built.
# ASTERISK14_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK14_BUILD_DIR=$(BUILD_DIR)/asterisk14
ASTERISK14_SOURCE_DIR=$(SOURCE_DIR)/asterisk14
ASTERISK14_IPK_DIR=$(BUILD_DIR)/asterisk14-$(ASTERISK14_VERSION)-ipk
ASTERISK14_IPK=$(BUILD_DIR)/asterisk14_$(ASTERISK14_VERSION)-$(ASTERISK14_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk14-source asterisk14-unpack asterisk14 asterisk14-stage asterisk14-ipk asterisk14-clean asterisk14-dirclean asterisk14-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK14_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK14_SITE)/$(ASTERISK14_SOURCE)
#	( cd $(BUILD_DIR) ; \
#		rm -rf $(ASTERISK14_DIR) && \
#		svn co -r $(ASTERISK14_SVN_REV) $(ASTERISK14_SVN) \
#			$(ASTERISK14_DIR) && \
#		tar -czf $@ $(ASTERISK14_DIR) && \
#		rm -rf $(ASTERISK14_DIR) \
#	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk14-source: $(DL_DIR)/$(ASTERISK14_SOURCE) $(ASTERISK14_PATCHES)

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
$(ASTERISK14_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK14_SOURCE) $(ASTERISK14_PATCHES) make/asterisk14.mk
	$(MAKE) ncurses-stage openssl-stage libcurl-stage zlib-stage termcap-stage libstdc++-stage sqlite2-stage iksemel-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR)
	$(ASTERISK14_UNZIP) $(DL_DIR)/$(ASTERISK14_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK14_PATCHES)" ; \
		then cat $(ASTERISK14_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK14_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK14_DIR)" != "$(ASTERISK14_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR) ; \
	fi

	(cd $(ASTERISK14_BUILD_DIR)/menuselect; \
		./configure \
	)
	(cd $(ASTERISK14_BUILD_DIR)/main/editline; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK14_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc \
	)

	(cd $(ASTERISK14_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK14_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$(PATH)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-pwlib \
		--with-ssl=$(STAGING_PREFIX) \
		--with-z=$(STAGING_PREFIX) \
		--with-termcap=$(STAGING_PREFIX) \
		--with-curl=$(STAGING_PREFIX) \
		--without-popt \
		--without-ogg \
		--without-popt \
		--without-tds \
		--with-sqlite=$(STAGING_PREFIX) \
		--without-postgres \
		--with-iksemel=$(STAGING_PREFIX) \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc \
	)
	touch $(ASTERISK14_BUILD_DIR)/.configured

asterisk14-unpack: $(ASTERISK14_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK14_BUILD_DIR)/.built: $(ASTERISK14_BUILD_DIR)/.configured
	rm -f $(ASTERISK14_BUILD_DIR)/.built
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK14_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR)
	touch $(ASTERISK14_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk14: $(ASTERISK14_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK14_BUILD_DIR)/.staged: $(ASTERISK14_BUILD_DIR)/.built
	rm -f $(ASTERISK14_BUILD_DIR)/.staged
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK14_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=/opt/sbin install
	touch $(ASTERISK14_BUILD_DIR)/.staged

asterisk14-stage: $(ASTERISK14_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk14
#
$(ASTERISK14_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk14" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK14_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK14_SECTION)" >>$@
	@echo "Version: $(ASTERISK14_VERSION)-$(ASTERISK14_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK14_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK14_SITE)/$(ASTERISK14_SOURCE)" >>$@
	@echo "Description: $(ASTERISK14_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK14_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK14_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK14_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK14_IPK_DIR)/opt/sbin or $(ASTERISK14_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK14_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK14_IPK_DIR)/opt/etc/asterisk14/...
# Documentation files should be installed in $(ASTERISK14_IPK_DIR)/opt/doc/asterisk14/...
# Daemon startup scripts should be installed in $(ASTERISK14_IPK_DIR)/opt/etc/init.d/S??asterisk14
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK14_IPK): $(ASTERISK14_BUILD_DIR)/.built
	rm -rf $(ASTERISK14_IPK_DIR) $(BUILD_DIR)/asterisk14_*_$(TARGET_ARCH).ipk
	NOISY_BUILD=yes \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(ASTERISK14_IPK_DIR) ASTSBINDIR=/opt/sbin install
	NOISY_BUILD=yes \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(ASTERISK14_IPK_DIR) samples

	mv $(ASTERISK14_IPK_DIR)/opt/etc/asterisk $(ASTERISK14_IPK_DIR)/opt/etc/samples
	install -d $(ASTERISK14_IPK_DIR)/opt/etc/asterisk
	mv $(ASTERISK14_IPK_DIR)/opt/etc/samples $(ASTERISK14_IPK_DIR)/opt/etc/asterisk
	sed -i -e 's#/var/spool/asterisk#/opt/var/spool/asterisk#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/samples/*
	sed -i -e 's#/var/lib/asterisk#/opt/var/lib/asterisk#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/samples/*
	sed -i -e 's#/var/calls#/opt/var/calls#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/samples/*
	sed -i -e 's#/usr/bin/streamplayer#/opt/sbin/streamplayer#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/samples/*

	$(MAKE) $(ASTERISK14_IPK_DIR)/CONTROL/control

	for filetostrip in $(ASTERISK14_IPK_DIR)/opt/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK14_IPK_DIR)/opt/sbin/aelparse \
			$(ASTERISK14_IPK_DIR)/opt/sbin/asterisk \
			$(ASTERISK14_IPK_DIR)/opt/sbin/muted \
			$(ASTERISK14_IPK_DIR)/opt/sbin/stereorize \
			$(ASTERISK14_IPK_DIR)/opt/sbin/streamplayer ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK14_IPK_DIR)/opt/var/lib/asterisk/agi-bin/*test ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK14_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk14-ipk: $(ASTERISK14_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk14-clean:
	rm -f $(ASTERISK14_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK14_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk14-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR) $(ASTERISK14_IPK_DIR) $(ASTERISK14_IPK)
#
#
# Some sanity check for the package.
#
asterisk14-check: $(ASTERISK14_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK14_IPK)
