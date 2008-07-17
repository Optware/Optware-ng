###########################################################
#
# httping
#
###########################################################
#
# HTTPING_VERSION, HTTPING_SITE and HTTPING_SOURCE define
# the upstream location of the source code for the package.
# HTTPING_DIR is the directory which is created when the source
# archive is unpacked.
# HTTPING_UNZIP is the command used to unzip the source.
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
HTTPING_SITE=http://www.vanheusden.com/httping
HTTPING_VERSION=1.2.9
HTTPING_SOURCE=httping-$(HTTPING_VERSION).tgz
HTTPING_DIR=httping-$(HTTPING_VERSION)
HTTPING_UNZIP=zcat
HTTPING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HTTPING_DESCRIPTION=httping is a "ping"-like tool for HTTP requests. Give it a URL and it will show how long it takes to connect, send a request, and retrieve the reply (only the headers). It can be used for monitoring or statistical purposes (measuring latency).
HTTPING_SECTION=web
HTTPING_PRIORITY=optional
HTTPING_DEPENDS=openssl
HTTPING_SUGGESTS=
HTTPING_CONFLICTS=

#
# HTTPING_IPK_VERSION should be incremented when the ipk changes.
#
HTTPING_IPK_VERSION=1

#
# HTTPING_CONFFILES should be a list of user-editable files
#HTTPING_CONFFILES=/opt/etc/httping.conf /opt/etc/init.d/SXXhttping

#
# HTTPING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HTTPING_PATCHES=$(HTTPING_SOURCE_DIR)/mem.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HTTPING_CPPFLAGS=
HTTPING_LDFLAGS=-lssl -lcrypto

#
# HTTPING_BUILD_DIR is the directory in which the build is done.
# HTTPING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HTTPING_IPK_DIR is the directory in which the ipk is built.
# HTTPING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HTTPING_BUILD_DIR=$(BUILD_DIR)/httping
HTTPING_SOURCE_DIR=$(SOURCE_DIR)/httping
HTTPING_IPK_DIR=$(BUILD_DIR)/httping-$(HTTPING_VERSION)-ipk
HTTPING_IPK=$(BUILD_DIR)/httping_$(HTTPING_VERSION)-$(HTTPING_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: httping-source httping-unpack httping httping-stage httping-ipk httping-clean httping-dirclean httping-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HTTPING_SOURCE):
	$(WGET) -P $(@D) $(HTTPING_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
httping-source: $(DL_DIR)/$(HTTPING_SOURCE) $(HTTPING_PATCHES)

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
$(HTTPING_BUILD_DIR)/.configured: $(DL_DIR)/$(HTTPING_SOURCE) $(HTTPING_PATCHES) make/httping.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(HTTPING_DIR) $(@D)
	$(HTTPING_UNZIP) $(DL_DIR)/$(HTTPING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HTTPING_PATCHES)" ; \
		then cat $(HTTPING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HTTPING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HTTPING_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HTTPING_DIR) $(@D) ; \
	fi
	sed -i -e 's:/usr/:/opt/:g' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HTTPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HTTPING_LDFLAGS)" \
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

httping-unpack: $(HTTPING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HTTPING_BUILD_DIR)/.built: $(HTTPING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HTTPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HTTPING_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
httping: $(HTTPING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HTTPING_BUILD_DIR)/.staged: $(HTTPING_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

httping-stage: $(HTTPING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/httping
#
$(HTTPING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: httping" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HTTPING_PRIORITY)" >>$@
	@echo "Section: $(HTTPING_SECTION)" >>$@
	@echo "Version: $(HTTPING_VERSION)-$(HTTPING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HTTPING_MAINTAINER)" >>$@
	@echo "Source: $(HTTPING_SITE)/$(HTTPING_SOURCE)" >>$@
	@echo "Description: $(HTTPING_DESCRIPTION)" >>$@
	@echo "Depends: $(HTTPING_DEPENDS)" >>$@
	@echo "Suggests: $(HTTPING_SUGGESTS)" >>$@
	@echo "Conflicts: $(HTTPING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HTTPING_IPK_DIR)/opt/sbin or $(HTTPING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HTTPING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HTTPING_IPK_DIR)/opt/etc/httping/...
# Documentation files should be installed in $(HTTPING_IPK_DIR)/opt/doc/httping/...
# Daemon startup scripts should be installed in $(HTTPING_IPK_DIR)/opt/etc/init.d/S??httping
#
# You may need to patch your application to make it use these locations.
#
$(HTTPING_IPK): $(HTTPING_BUILD_DIR)/.built
	rm -rf $(HTTPING_IPK_DIR) $(BUILD_DIR)/httping_*_$(TARGET_ARCH).ipk
	install -d $(HTTPING_IPK_DIR)/opt/bin $(HTTPING_IPK_DIR)/opt/share/man/man1
	$(MAKE) -C $(HTTPING_BUILD_DIR) DESTDIR=$(HTTPING_IPK_DIR) install
	$(STRIP_COMMAND) $(HTTPING_IPK_DIR)/opt/bin/*
#	install -d $(HTTPING_IPK_DIR)/opt/etc/
#	install -m 644 $(HTTPING_SOURCE_DIR)/httping.conf $(HTTPING_IPK_DIR)/opt/etc/httping.conf
#	install -d $(HTTPING_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HTTPING_SOURCE_DIR)/rc.httping $(HTTPING_IPK_DIR)/opt/etc/init.d/SXXhttping
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HTTPING_IPK_DIR)/opt/etc/init.d/SXXhttping
	$(MAKE) $(HTTPING_IPK_DIR)/CONTROL/control
#	install -m 755 $(HTTPING_SOURCE_DIR)/postinst $(HTTPING_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HTTPING_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HTTPING_SOURCE_DIR)/prerm $(HTTPING_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HTTPING_IPK_DIR)/CONTROL/prerm
	echo $(HTTPING_CONFFILES) | sed -e 's/ /\n/g' > $(HTTPING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HTTPING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
httping-ipk: $(HTTPING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
httping-clean:
	rm -f $(HTTPING_BUILD_DIR)/.built
	-$(MAKE) -C $(HTTPING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
httping-dirclean:
	rm -rf $(BUILD_DIR)/$(HTTPING_DIR) $(HTTPING_BUILD_DIR) $(HTTPING_IPK_DIR) $(HTTPING_IPK)
#
#
# Some sanity check for the package.
#
httping-check: $(HTTPING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HTTPING_IPK)
