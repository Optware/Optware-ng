###########################################################
#
# haproxy
#
###########################################################
#
# HAPROXY_VERSION, HAPROXY_SITE and HAPROXY_SOURCE define
# the upstream location of the source code for the package.
# HAPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# HAPROXY_UNZIP is the command used to unzip the source.
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
HAPROXY_SITE=http://haproxy.1wt.eu/download/1.3/src
HAPROXY_VERSION=1.3.17
HAPROXY_SOURCE=haproxy-$(HAPROXY_VERSION).tar.gz
HAPROXY_DIR=haproxy-$(HAPROXY_VERSION)
HAPROXY_UNZIP=zcat
HAPROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HAPROXY_DESCRIPTION=Reliable, high performance TCP/HTTP load balancer.
HAPROXY_SECTION=net
HAPROXY_PRIORITY=optional
HAPROXY_DEPENDS=pcre
HAPROXY_SUGGESTS=
HAPROXY_CONFLICTS=

#
# HAPROXY_IPK_VERSION should be incremented when the ipk changes.
#
HAPROXY_IPK_VERSION=1

#
# HAPROXY_CONFFILES should be a list of user-editable files
#HAPROXY_CONFFILES=/opt/etc/haproxy.conf /opt/etc/init.d/SXXhaproxy

#
# HAPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HAPROXY_PATCHES=$(HAPROXY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HAPROXY_CPPFLAGS=
HAPROXY_LDFLAGS=

#
# HAPROXY_BUILD_DIR is the directory in which the build is done.
# HAPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HAPROXY_IPK_DIR is the directory in which the ipk is built.
# HAPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HAPROXY_BUILD_DIR=$(BUILD_DIR)/haproxy
HAPROXY_SOURCE_DIR=$(SOURCE_DIR)/haproxy
HAPROXY_IPK_DIR=$(BUILD_DIR)/haproxy-$(HAPROXY_VERSION)-ipk
HAPROXY_IPK=$(BUILD_DIR)/haproxy_$(HAPROXY_VERSION)-$(HAPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

HAPROXY_LINUX_TARGET=$(if $(filter module-init-tools, $(PACKAGES)),linux26,linux24)

.PHONY: haproxy-source haproxy-unpack haproxy haproxy-stage haproxy-ipk haproxy-clean haproxy-dirclean haproxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HAPROXY_SOURCE):
	$(WGET) -P $(@D) $(HAPROXY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
haproxy-source: $(DL_DIR)/$(HAPROXY_SOURCE) $(HAPROXY_PATCHES)

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
$(HAPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(HAPROXY_SOURCE) $(HAPROXY_PATCHES) make/haproxy.mk
	$(MAKE) pcre-stage
	rm -rf $(BUILD_DIR)/$(HAPROXY_DIR) $(@D)
	$(HAPROXY_UNZIP) $(DL_DIR)/$(HAPROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HAPROXY_PATCHES)" ; \
		then cat $(HAPROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HAPROXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HAPROXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HAPROXY_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HAPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HAPROXY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(HAPROXY_BUILD_DIR)/libtool
	touch $@

haproxy-unpack: $(HAPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HAPROXY_BUILD_DIR)/.built: $(HAPROXY_BUILD_DIR)/.configured
	rm -f $@
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(@D) \
		TARGET=$(HAPROXY_LINUX_TARGET) REGEX=pcre \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HAPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HAPROXY_LDFLAGS)" \
		LD=$(TARGET_CC) \
		;
	touch $@

#
# This is the build convenience target.
#
haproxy: $(HAPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HAPROXY_BUILD_DIR)/.staged: $(HAPROXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

haproxy-stage: $(HAPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/haproxy
#
$(HAPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: haproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HAPROXY_PRIORITY)" >>$@
	@echo "Section: $(HAPROXY_SECTION)" >>$@
	@echo "Version: $(HAPROXY_VERSION)-$(HAPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HAPROXY_MAINTAINER)" >>$@
	@echo "Source: $(HAPROXY_SITE)/$(HAPROXY_SOURCE)" >>$@
	@echo "Description: $(HAPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(HAPROXY_DEPENDS)" >>$@
	@echo "Suggests: $(HAPROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(HAPROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HAPROXY_IPK_DIR)/opt/sbin or $(HAPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HAPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HAPROXY_IPK_DIR)/opt/etc/haproxy/...
# Documentation files should be installed in $(HAPROXY_IPK_DIR)/opt/doc/haproxy/...
# Daemon startup scripts should be installed in $(HAPROXY_IPK_DIR)/opt/etc/init.d/S??haproxy
#
# You may need to patch your application to make it use these locations.
#
$(HAPROXY_IPK): $(HAPROXY_BUILD_DIR)/.built
	rm -rf $(HAPROXY_IPK_DIR) $(BUILD_DIR)/haproxy_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(HAPROXY_BUILD_DIR) DESTDIR=$(HAPROXY_IPK_DIR) install-strip
	install -d $(HAPROXY_IPK_DIR)/opt/sbin/
	install -m 755 $(HAPROXY_BUILD_DIR)/haproxy $(HAPROXY_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(HAPROXY_IPK_DIR)/opt/sbin/haproxy
	install -d $(HAPROXY_IPK_DIR)/opt/share/haproxy/
	cp -r $(HAPROXY_BUILD_DIR)/doc $(HAPROXY_IPK_DIR)/opt/share/haproxy/
	cp -r $(HAPROXY_BUILD_DIR)/examples $(HAPROXY_IPK_DIR)/opt/share/haproxy/
#	install -d $(HAPROXY_IPK_DIR)/opt/etc/
#	install -m 644 $(HAPROXY_SOURCE_DIR)/haproxy.conf $(HAPROXY_IPK_DIR)/opt/etc/haproxy.conf
#	install -d $(HAPROXY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HAPROXY_SOURCE_DIR)/rc.haproxy $(HAPROXY_IPK_DIR)/opt/etc/init.d/SXXhaproxy
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HAPROXY_IPK_DIR)/opt/etc/init.d/SXXhaproxy
	$(MAKE) $(HAPROXY_IPK_DIR)/CONTROL/control
#	install -m 755 $(HAPROXY_SOURCE_DIR)/postinst $(HAPROXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HAPROXY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HAPROXY_SOURCE_DIR)/prerm $(HAPROXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HAPROXY_IPK_DIR)/CONTROL/prerm
	echo $(HAPROXY_CONFFILES) | sed -e 's/ /\n/g' > $(HAPROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HAPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
haproxy-ipk: $(HAPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
haproxy-clean:
	rm -f $(HAPROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(HAPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
haproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(HAPROXY_DIR) $(HAPROXY_BUILD_DIR) $(HAPROXY_IPK_DIR) $(HAPROXY_IPK)
#
#
# Some sanity check for the package.
#
haproxy-check: $(HAPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
