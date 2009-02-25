###########################################################
#
# privoxy
#
###########################################################
#
# PRIVOXY_VERSION, PRIVOXY_SITE and PRIVOXY_SOURCE define
# the upstream location of the source code for the package.
# PRIVOXY_DIR is the directory which is created when the source
# archive is unpacked.
# PRIVOXY_UNZIP is the command used to unzip the source.
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
PRIVOXY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ijbswa
PRIVOXY_VERSION=3.0.11
PRIVOXY_SOURCE=privoxy-$(PRIVOXY_VERSION)-stable-src.tar.gz
PRIVOXY_DIR=privoxy-$(PRIVOXY_VERSION)-stable
PRIVOXY_UNZIP=zcat
PRIVOXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PRIVOXY_DESCRIPTION=A Web proxy based on Internet Junkbuster.
PRIVOXY_SECTION=net
PRIVOXY_PRIORITY=optional
PRIVOXY_DEPENDS=
PRIVOXY_SUGGESTS=
PRIVOXY_CONFLICTS=

#
# PRIVOXY_IPK_VERSION should be incremented when the ipk changes.
#
PRIVOXY_IPK_VERSION=1

#
# PRIVOXY_CONFFILES should be a list of user-editable files
#PRIVOXY_CONFFILES=/opt/etc/privoxy.conf /opt/etc/init.d/SXXprivoxy

#
# PRIVOXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PRIVOXY_PATCHES=$(PRIVOXY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PRIVOXY_CPPFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
PRIVOXY_LDFLAGS=-lpthread
else
PRIVOXY_LDFLAGS=-pthread
endif

#
# PRIVOXY_BUILD_DIR is the directory in which the build is done.
# PRIVOXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PRIVOXY_IPK_DIR is the directory in which the ipk is built.
# PRIVOXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PRIVOXY_BUILD_DIR=$(BUILD_DIR)/privoxy
PRIVOXY_SOURCE_DIR=$(SOURCE_DIR)/privoxy
PRIVOXY_IPK_DIR=$(BUILD_DIR)/privoxy-$(PRIVOXY_VERSION)-ipk
PRIVOXY_IPK=$(BUILD_DIR)/privoxy_$(PRIVOXY_VERSION)-$(PRIVOXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: privoxy-source privoxy-unpack privoxy privoxy-stage privoxy-ipk privoxy-clean privoxy-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PRIVOXY_SOURCE):
	$(WGET) -P $(@D) $(PRIVOXY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
privoxy-source: $(DL_DIR)/$(PRIVOXY_SOURCE) $(PRIVOXY_PATCHES)

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
$(PRIVOXY_BUILD_DIR)/.configured: $(DL_DIR)/$(PRIVOXY_SOURCE) $(PRIVOXY_PATCHES) make/privoxy.mk
#	$(MAKE) pcre-stage
	rm -rf $(BUILD_DIR)/$(PRIVOXY_DIR) $(@D)
	$(PRIVOXY_UNZIP) $(DL_DIR)/$(PRIVOXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PRIVOXY_PATCHES)" ; \
		then cat $(PRIVOXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PRIVOXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PRIVOXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PRIVOXY_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		autoheader; autoconf; \
	)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PRIVOXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PRIVOXY_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir='$${prefix}/etc/privoxy' \
		--disable-nls \
		--disable-static \
		--disable-dynamic-pcre \
		--disable-dynamic-pcrs \
		; \
	)
	(cd $(@D); \
		sed -i \
		    -e '/SED.*config/s|$$(CONF_DEST)|/opt/etc/privoxy|' \
		    -e '/SED.*config/s|$$(LOG_DEST)|/opt/var/log/privoxy|' \
		    -e '/SED.*config/s|$$(DOC_DEST)|/opt/share/doc/privoxy|' \
		    -e '/SED.*config/s|$$(prefix)|/opt|' \
		    GNUmakefile; \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

privoxy-unpack: $(PRIVOXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PRIVOXY_BUILD_DIR)/.built: $(PRIVOXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/pcre dftables CC=$(HOSTCC)
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(PRIVOXY_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
privoxy: $(PRIVOXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PRIVOXY_BUILD_DIR)/.staged: $(PRIVOXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

privoxy-stage: $(PRIVOXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/privoxy
#
$(PRIVOXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: privoxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PRIVOXY_PRIORITY)" >>$@
	@echo "Section: $(PRIVOXY_SECTION)" >>$@
	@echo "Version: $(PRIVOXY_VERSION)-$(PRIVOXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PRIVOXY_MAINTAINER)" >>$@
	@echo "Source: $(PRIVOXY_SITE)/$(PRIVOXY_SOURCE)" >>$@
	@echo "Description: $(PRIVOXY_DESCRIPTION)" >>$@
	@echo "Depends: $(PRIVOXY_DEPENDS)" >>$@
	@echo "Suggests: $(PRIVOXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PRIVOXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PRIVOXY_IPK_DIR)/opt/sbin or $(PRIVOXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PRIVOXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PRIVOXY_IPK_DIR)/opt/etc/privoxy/...
# Documentation files should be installed in $(PRIVOXY_IPK_DIR)/opt/doc/privoxy/...
# Daemon startup scripts should be installed in $(PRIVOXY_IPK_DIR)/opt/etc/init.d/S??privoxy
#
# You may need to patch your application to make it use these locations.
#
$(PRIVOXY_IPK): $(PRIVOXY_BUILD_DIR)/.built
	rm -rf $(PRIVOXY_IPK_DIR) $(BUILD_DIR)/privoxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PRIVOXY_BUILD_DIR) prefix=$(PRIVOXY_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(PRIVOXY_IPK_DIR)/opt/sbin/privoxy
#	install -d $(PRIVOXY_IPK_DIR)/opt/etc/
#	install -m 644 $(PRIVOXY_SOURCE_DIR)/privoxy.conf $(PRIVOXY_IPK_DIR)/opt/etc/privoxy.conf
#	install -d $(PRIVOXY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PRIVOXY_SOURCE_DIR)/rc.privoxy $(PRIVOXY_IPK_DIR)/opt/etc/init.d/SXXprivoxy
	$(MAKE) $(PRIVOXY_IPK_DIR)/CONTROL/control
#	install -m 755 $(PRIVOXY_SOURCE_DIR)/postinst $(PRIVOXY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PRIVOXY_SOURCE_DIR)/prerm $(PRIVOXY_IPK_DIR)/CONTROL/prerm
	echo $(PRIVOXY_CONFFILES) | sed -e 's/ /\n/g' > $(PRIVOXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PRIVOXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
privoxy-ipk: $(PRIVOXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
privoxy-clean:
	rm -f $(PRIVOXY_BUILD_DIR)/.built
	-$(MAKE) -C $(PRIVOXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
privoxy-dirclean:
	rm -rf $(BUILD_DIR)/$(PRIVOXY_DIR) $(PRIVOXY_BUILD_DIR) $(PRIVOXY_IPK_DIR) $(PRIVOXY_IPK)

#
# Some sanity check for the package.
#
privoxy-check: $(PRIVOXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PRIVOXY_IPK)
