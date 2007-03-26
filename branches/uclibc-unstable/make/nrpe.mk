###########################################################
#
# nrpe
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
# NOTE 1:
#	At this moment i will only use the nrpe daemon
# NOTE 2:
#	The nagios plugins will follow. First get this working
#
NRPE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nagios
NRPE_VERSION=2.6
NRPE_SOURCE=nrpe-$(NRPE_VERSION).tar.gz
NRPE_DIR=nrpe-$(NRPE_VERSION)
NRPE_UNZIP=zcat
NRPE_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
NRPE_DESCRIPTION=The Nagios Remote Plugin Executor
NRPE_SECTION=net
NRPE_PRIORITY=optional
NRPE_DEPENDS=openssl, tcpwrappers
NRPE_SUGGESTS=
NRPE_CONFLICTS=

#
# NRPE_IPK_VERSION should be incremented when the ipk changes.
#
NRPE_IPK_VERSION=1

#
# NRPE_CONFFILES should be a list of user-editable files
# NRPE_CONFFILES=/opt/etc/nrpe.conf /opt/etc/init.d/SXXnrpe # TODO

#
# NRPE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NRPE_PATCHES=$(NRPE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NRPE_CPPFLAGS=
NRPE_LDFLAGS=

#
# NRPE_BUILD_DIR is the directory in which the build is done.
# NRPE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NRPE_IPK_DIR is the directory in which the ipk is built.
# NRPE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NRPE_BUILD_DIR=$(BUILD_DIR)/nrpe
NRPE_SOURCE_DIR=$(SOURCE_DIR)/nrpe
NRPE_IPK_DIR=$(BUILD_DIR)/nrpe-$(NRPE_VERSION)-ipk
NRPE_IPK=$(BUILD_DIR)/nrpe_$(NRPE_VERSION)-$(NRPE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NRPE_SOURCE):
	$(WGET) -P $(DL_DIR) $(NRPE_SITE)/$(NRPE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nrpe-source: $(DL_DIR)/$(NRPE_SOURCE) $(NRPE_PATCHES)

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
$(NRPE_BUILD_DIR)/.configured: $(DL_DIR)/$(NRPE_SOURCE) $(NRPE_PATCHES)
	$(MAKE) openssl-stage tcpwrappers-stage
	rm -rf $(BUILD_DIR)/$(NRPE_DIR) $(NRPE_BUILD_DIR)
	$(NRPE_UNZIP) $(DL_DIR)/$(NRPE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NRPE_PATCHES)" ; \
		then cat $(NRPE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NRPE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(NRPE_DIR)" != "$(NRPE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NRPE_DIR) $(NRPE_BUILD_DIR) ; \
	fi
	#
	# NOTE: Run a modern autoconf (2.59) to solve cross compile issues.
	#
	(cd $(NRPE_BUILD_DIR); \
		autoconf configure.in > configure; \
		./configure \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(NRPE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NRPE_LDFLAGS)" \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-ssl \
		--with-ssl-inc=$(STAGING_PREFIX) \
		--with-ssl-lib=$(STAGING_PREFIX)/lib \
		--with-nrpe-user=nobody \
		--with-nrpe-group=nobody \
	)
	# $(PATCH_LIBTOOL) $(NRPE_BUILD_DIR)/libtool
	touch $(NRPE_BUILD_DIR)/.configured

nrpe-unpack: $(NRPE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NRPE_BUILD_DIR)/.built: $(NRPE_BUILD_DIR)/.configured
	rm -f $(NRPE_BUILD_DIR)/.built
	$(MAKE) -C $(NRPE_BUILD_DIR)
	touch $(NRPE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nrpe: $(NRPE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NRPE_BUILD_DIR)/.staged: $(NRPE_BUILD_DIR)/.built
	rm -f $(NRPE_BUILD_DIR)/.staged
	$(MAKE) -C $(NRPE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NRPE_BUILD_DIR)/.staged

nrpe-stage: $(NRPE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nrpe
#
$(NRPE_IPK_DIR)/CONTROL/control:
	@install -d $(NRPE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nrpe" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NRPE_PRIORITY)" >>$@
	@echo "Section: $(NRPE_SECTION)" >>$@
	@echo "Version: $(NRPE_VERSION)-$(NRPE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NRPE_MAINTAINER)" >>$@
	@echo "Source: $(NRPE_SITE)/$(NRPE_SOURCE)" >>$@
	@echo "Description: $(NRPE_DESCRIPTION)" >>$@
	@echo "Depends: $(NRPE_DEPENDS)" >>$@
	@echo "Suggests: $(NRPE_SUGGESTS)" >>$@
	@echo "Conflicts: $(NRPE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NRPE_IPK_DIR)/opt/sbin or $(NRPE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NRPE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NRPE_IPK_DIR)/opt/etc/nrpe/...
# Documentation files should be installed in $(NRPE_IPK_DIR)/opt/doc/nrpe/...
# Daemon startup scripts should be installed in $(NRPE_IPK_DIR)/opt/etc/init.d/S??nrpe
#
# You may need to patch your application to make it use these locations.
#
$(NRPE_IPK): $(NRPE_BUILD_DIR)/.built
	rm -rf $(NRPE_IPK_DIR) $(BUILD_DIR)/nrpe_*_$(TARGET_ARCH).ipk
	install -d $(NRPE_IPK_DIR)/opt/sbin/
	cp $(NRPE_BUILD_DIR)/src/nrpe $(NRPE_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(NRPE_IPK_DIR)/opt/sbin/*
	install -d $(NRPE_IPK_DIR)/opt/etc/
	install -m 644 $(NRPE_BUILD_DIR)/sample-config/nrpe.cfg $(NRPE_IPK_DIR)/opt/etc/nrpe.cfg
	install -d $(NRPE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NRPE_BUILD_DIR)/init-script $(NRPE_IPK_DIR)/opt/etc/init.d/S99nrpe
	sed -i 's#/opt/bin#/opt/sbin#' $(NRPE_IPK_DIR)/opt/etc/init.d/S99nrpe
	$(MAKE) $(NRPE_IPK_DIR)/CONTROL/control
	# install -m 755 $(NRPE_SOURCE_DIR)/postinst $(NRPE_IPK_DIR)/CONTROL/postinst
	# install -m 755 $(NRPE_SOURCE_DIR)/prerm $(NRPE_IPK_DIR)/CONTROL/prerm
	echo $(NRPE_CONFFILES) | sed -e 's/ /\n/g' > $(NRPE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NRPE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nrpe-ipk: $(NRPE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nrpe-clean:
	rm -f $(NRPE_BUILD_DIR)/.built
	-$(MAKE) -C $(NRPE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nrpe-dirclean:
	rm -rf $(BUILD_DIR)/$(NRPE_DIR) $(NRPE_BUILD_DIR) $(NRPE_IPK_DIR) $(NRPE_IPK)
