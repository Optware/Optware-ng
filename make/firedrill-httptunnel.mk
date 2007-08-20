###########################################################
#
# firedrill-httptunnel
#
###########################################################
#
# FIREDRILL-HTTPTUNNEL_VERSION, FIREDRILL-HTTPTUNNEL_SITE and FIREDRILL-HTTPTUNNEL_SOURCE define
# the upstream location of the source code for the package.
# FIREDRILL-HTTPTUNNEL_DIR is the directory which is created when the source
# archive is unpacked.
# FIREDRILL-HTTPTUNNEL_UNZIP is the command used to unzip the source.
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
FIREDRILL-HTTPTUNNEL_SITE=http://the-linux-academy.co.uk/downloads
FIREDRILL-HTTPTUNNEL_VERSION=0.9.4
FIREDRILL-HTTPTUNNEL_UPSTREAM_SOURCE=httptunnel-$(FIREDRILL-HTTPTUNNEL_VERSION).tgz
FIREDRILL-HTTPTUNNEL_SOURCE=firedrill-$(FIREDRILL-HTTPTUNNEL_UPSTREAM_SOURCE)
FIREDRILL-HTTPTUNNEL_DIR=httptunnel
FIREDRILL-HTTPTUNNEL_UNZIP=zcat
FIREDRILL-HTTPTUNNEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FIREDRILL-HTTPTUNNEL_DESCRIPTION=A small application for tunnelling an arbitrary TCP socket connection over HTTP.
FIREDRILL-HTTPTUNNEL_SECTION=net
FIREDRILL-HTTPTUNNEL_PRIORITY=optional
FIREDRILL-HTTPTUNNEL_DEPENDS=openssl, libstdc++
FIREDRILL-HTTPTUNNEL_SUGGESTS=
FIREDRILL-HTTPTUNNEL_CONFLICTS=

#
# FIREDRILL-HTTPTUNNEL_IPK_VERSION should be incremented when the ipk changes.
#
FIREDRILL-HTTPTUNNEL_IPK_VERSION=1

#
# FIREDRILL-HTTPTUNNEL_CONFFILES should be a list of user-editable files
#FIREDRILL-HTTPTUNNEL_CONFFILES=/opt/etc/firedrill-httptunnel.conf /opt/etc/init.d/SXXfiredrill-httptunnel

#
# FIREDRILL-HTTPTUNNEL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FIREDRILL-HTTPTUNNEL_PATCHES=$(FIREDRILL-HTTPTUNNEL_SOURCE_DIR)/find_if.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FIREDRILL-HTTPTUNNEL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/openssl
FIREDRILL-HTTPTUNNEL_LDFLAGS=

#
# FIREDRILL-HTTPTUNNEL_BUILD_DIR is the directory in which the build is done.
# FIREDRILL-HTTPTUNNEL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FIREDRILL-HTTPTUNNEL_IPK_DIR is the directory in which the ipk is built.
# FIREDRILL-HTTPTUNNEL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FIREDRILL-HTTPTUNNEL_BUILD_DIR=$(BUILD_DIR)/firedrill-httptunnel
FIREDRILL-HTTPTUNNEL_SOURCE_DIR=$(SOURCE_DIR)/firedrill-httptunnel
FIREDRILL-HTTPTUNNEL_IPK_DIR=$(BUILD_DIR)/firedrill-httptunnel-$(FIREDRILL-HTTPTUNNEL_VERSION)-ipk
FIREDRILL-HTTPTUNNEL_IPK=$(BUILD_DIR)/firedrill-httptunnel_$(FIREDRILL-HTTPTUNNEL_VERSION)-$(FIREDRILL-HTTPTUNNEL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: firedrill-httptunnel-source firedrill-httptunnel-unpack firedrill-httptunnel firedrill-httptunnel-stage firedrill-httptunnel-ipk firedrill-httptunnel-clean firedrill-httptunnel-dirclean firedrill-httptunnel-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FIREDRILL-HTTPTUNNEL_SOURCE):
	$(WGET) -O $@ $(FIREDRILL-HTTPTUNNEL_SITE)/$(FIREDRILL-HTTPTUNNEL_UPSTREAM_SOURCE) || \
	$(WGET) -O $@ $(SOURCES_NLO_SITE)/$(FIREDRILL-HTTPTUNNEL_UPSTREAM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
firedrill-httptunnel-source: $(DL_DIR)/$(FIREDRILL-HTTPTUNNEL_SOURCE) $(FIREDRILL-HTTPTUNNEL_PATCHES)

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
$(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.configured: $(DL_DIR)/$(FIREDRILL-HTTPTUNNEL_SOURCE) $(FIREDRILL-HTTPTUNNEL_PATCHES) make/firedrill-httptunnel.mk
	$(MAKE) openssl-stage
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(FIREDRILL-HTTPTUNNEL_DIR) $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)
	$(FIREDRILL-HTTPTUNNEL_UNZIP) $(DL_DIR)/$(FIREDRILL-HTTPTUNNEL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FIREDRILL-HTTPTUNNEL_PATCHES)" ; \
		then cat $(FIREDRILL-HTTPTUNNEL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FIREDRILL-HTTPTUNNEL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FIREDRILL-HTTPTUNNEL_DIR)" != "$(FIREDRILL-HTTPTUNNEL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FIREDRILL-HTTPTUNNEL_DIR) $(FIREDRILL-HTTPTUNNEL_BUILD_DIR) ; \
	fi
	sed -i -e '/^INCLUDES/s/$$/ $$(CPPFLAGS)/' \
	       -e '/^LIBS/s/$$/ $$(LDFLAGS)/' \
		$(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/src/Makefile
#	(cd $(FIREDRILL-HTTPTUNNEL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FIREDRILL-HTTPTUNNEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FIREDRILL-HTTPTUNNEL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/libtool
	touch $@

firedrill-httptunnel-unpack: $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.built: $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CC=$(TARGET_CXX) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FIREDRILL-HTTPTUNNEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FIREDRILL-HTTPTUNNEL_LDFLAGS)" \
		SSL=YES \
		SSLINCLUDES="" \
		SSLDEPENDS="" \
		;
	touch $@

#
# This is the build convenience target.
#
firedrill-httptunnel: $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.staged: $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FIREDRILL-HTTPTUNNEL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

firedrill-httptunnel-stage: $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/firedrill-httptunnel
#
$(FIREDRILL-HTTPTUNNEL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: firedrill-httptunnel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FIREDRILL-HTTPTUNNEL_PRIORITY)" >>$@
	@echo "Section: $(FIREDRILL-HTTPTUNNEL_SECTION)" >>$@
	@echo "Version: $(FIREDRILL-HTTPTUNNEL_VERSION)-$(FIREDRILL-HTTPTUNNEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FIREDRILL-HTTPTUNNEL_MAINTAINER)" >>$@
	@echo "Source: $(FIREDRILL-HTTPTUNNEL_SITE)/$(FIREDRILL-HTTPTUNNEL_SOURCE)" >>$@
	@echo "Description: $(FIREDRILL-HTTPTUNNEL_DESCRIPTION)" >>$@
	@echo "Depends: $(FIREDRILL-HTTPTUNNEL_DEPENDS)" >>$@
	@echo "Suggests: $(FIREDRILL-HTTPTUNNEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(FIREDRILL-HTTPTUNNEL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/sbin or $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/etc/firedrill-httptunnel/...
# Documentation files should be installed in $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/doc/firedrill-httptunnel/...
# Daemon startup scripts should be installed in $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/etc/init.d/S??firedrill-httptunnel
#
# You may need to patch your application to make it use these locations.
#
$(FIREDRILL-HTTPTUNNEL_IPK): $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.built
	rm -rf $(FIREDRILL-HTTPTUNNEL_IPK_DIR) $(BUILD_DIR)/firedrill-httptunnel_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FIREDRILL-HTTPTUNNEL_BUILD_DIR) DESTDIR=$(FIREDRILL-HTTPTUNNEL_IPK_DIR) install-strip
	install -d $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/bin
	install -m 755 $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/src/httptunnel $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/bin/httptunnel
	install -d $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/share/doc/firedrill-httptunnel
	install -m 644 $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/README $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/opt/share/doc/firedrill-httptunnel
	$(MAKE) $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/CONTROL/control
	echo $(FIREDRILL-HTTPTUNNEL_CONFFILES) | sed -e 's/ /\n/g' > $(FIREDRILL-HTTPTUNNEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FIREDRILL-HTTPTUNNEL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
firedrill-httptunnel-ipk: $(FIREDRILL-HTTPTUNNEL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
firedrill-httptunnel-clean:
	rm -f $(FIREDRILL-HTTPTUNNEL_BUILD_DIR)/.built
	-$(MAKE) -C $(FIREDRILL-HTTPTUNNEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
firedrill-httptunnel-dirclean:
	rm -rf $(BUILD_DIR)/$(FIREDRILL-HTTPTUNNEL_DIR) $(FIREDRILL-HTTPTUNNEL_BUILD_DIR) $(FIREDRILL-HTTPTUNNEL_IPK_DIR) $(FIREDRILL-HTTPTUNNEL_IPK)
#
#
# Some sanity check for the package.
#
firedrill-httptunnel-check: $(FIREDRILL-HTTPTUNNEL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FIREDRILL-HTTPTUNNEL_IPK)
