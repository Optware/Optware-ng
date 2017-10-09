###########################################################
#
# quagga
#
###########################################################

# You must replace "quagga" and "QUAGGA" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# QUAGGA_VERSION, QUAGGA_SITE and QUAGGA_SOURCE define
# the upstream location of the source code for the package.
# QUAGGA_DIR is the directory which is created when the source
# archive is unpacked.
# QUAGGA_UNZIP is the command used to unzip the source.
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
QUAGGA_SITE=http://www.quagga.net/download
QUAGGA_VERSION=0.99.16
QUAGGA_SOURCE=quagga-$(QUAGGA_VERSION).tar.gz
QUAGGA_DIR=quagga-$(QUAGGA_VERSION)
QUAGGA_UNZIP=zcat
QUAGGA_MAINTAINER=Louis Lagendijk <louis.lagendijk@gmail.com>
QUAGGA_DESCRIPTION=The quagga routing suite, including ospf, rip, and bgp (ospf6d and ripngd are included if library has IPv6 support).
QUAGGA_SECTION=net
QUAGGA_PRIORITY=optional
QUAGGA_DEPENDS=adduser, readline, termcap, libcap
QUAGGA_SUGGESTS=
QUAGGA_CONFLICTS=

#
# QUAGGA_IPK_VERSION should be incremented when the ipk changes.
#
QUAGGA_IPK_VERSION=3

#
# QUAGGA_CONFFILES should be a list of user-editable files
#QUAGGA_CONFFILES=

#
# QUAGGA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
QUAGGA_PATCHES=$(QUAGGA_SOURCE_DIR)/configure.ac.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QUAGGA_CPPFLAGS=-U__STRICT_ANSI__
QUAGGA_LDFLAGS=-lreadline -ltermcap

#
# QUAGGA_BUILD_DIR is the directory in which the build is done.
# QUAGGA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QUAGGA_IPK_DIR is the directory in which the ipk is built.
# QUAGGA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QUAGGA_BUILD_DIR=$(BUILD_DIR)/quagga
QUAGGA_SOURCE_DIR=$(SOURCE_DIR)/quagga
QUAGGA_IPK_DIR=$(BUILD_DIR)/quagga-$(QUAGGA_VERSION)-ipk
QUAGGA_IPK=$(BUILD_DIR)/quagga_$(QUAGGA_VERSION)-$(QUAGGA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: quagga-source quagga-unpack quagga quagga-stage quagga-ipk quagga-clean quagga-dirclean quagga-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QUAGGA_SOURCE):
	$(WGET) -P $(@D) $(QUAGGA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
quagga-source: $(DL_DIR)/$(QUAGGA_SOURCE) $(QUAGGA_PATCHES)

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
$(QUAGGA_BUILD_DIR)/.configured: $(DL_DIR)/$(QUAGGA_SOURCE) $(QUAGGA_PATCHES) make/quagga.mk
	$(MAKE) readline-stage termcap-stage libcap-stage
	rm -rf $(BUILD_DIR)/$(QUAGGA_DIR) $(@D)
	$(QUAGGA_UNZIP) $(DL_DIR)/$(QUAGGA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(QUAGGA_PATCHES)"; then \
		cat $(QUAGGA_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(QUAGGA_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(QUAGGA_DIR) $(@D)
	# Cross compilation requires checks for include files to point to target include dirictory
	sed -i -e 's!/usr/include/!$(TARGET_INCDIR)/!g' $(@D)/configure.ac
	# Some gdb header defines struct user, so let's patch the definition in quagga vtysh_user
	sed -i -e 's!struct user!struct vtysh_user!g' $(@D)/vtysh/vtysh_user.c
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		touch aclocal.m4 Makefile.in config.h.in; \
		touch configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QUAGGA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QUAGGA_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--sysconfdir=$(TARGET_PREFIX)/etc/quagga \
		--localstatedir=$(TARGET_PREFIX)/var/run/quagga \
		--disable-nls \
		--disable-isisd \
		--disable-static \
		--enable-vtysh \
	)
	touch $@

quagga-unpack: $(QUAGGA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QUAGGA_BUILD_DIR)/.built: $(QUAGGA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
quagga: $(QUAGGA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(QUAGGA_BUILD_DIR)/.staged: $(QUAGGA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

quagga-stage: $(QUAGGA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/quagga
#
$(QUAGGA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: quagga" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QUAGGA_PRIORITY)" >>$@
	@echo "Section: $(QUAGGA_SECTION)" >>$@
	@echo "Version: $(QUAGGA_VERSION)-$(QUAGGA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QUAGGA_MAINTAINER)" >>$@
	@echo "Source: $(QUAGGA_SITE)/$(QUAGGA_SOURCE)" >>$@
	@echo "Description: $(QUAGGA_DESCRIPTION)" >>$@
	@echo "Depends: $(QUAGGA_DEPENDS)" >>$@
	@echo "Suggests: $(QUAGGA_SUGGESTS)" >>$@
	@echo "Conflicts: $(QUAGGA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/etc/quagga/...
# Documentation files should be installed in $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/doc/quagga/...
# Daemon startup scripts should be installed in $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??quagga
#
# You may need to patch your application to make it use these locations.
#
$(QUAGGA_IPK): $(QUAGGA_BUILD_DIR)/.built
	rm -rf $(QUAGGA_IPK_DIR) $(BUILD_DIR)/quagga_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(QUAGGA_BUILD_DIR) DESTDIR=$(QUAGGA_IPK_DIR) install
	rm -f $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	$(STRIP_COMMAND) $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(STRIP_COMMAND) $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(STRIP_COMMAND) $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/lib/*.so*
	$(INSTALL) -d $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/var/run/quagga
	$(INSTALL) -d $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(QUAGGA_SOURCE_DIR)/rc.quagga $(QUAGGA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S50quagga
	$(MAKE) $(QUAGGA_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(QUAGGA_SOURCE_DIR)/postinst $(QUAGGA_IPK_DIR)/CONTROL/postinst
	#echo $(QUAGGA_CONFFILES) | sed -e 's/ /\n/g' > $(QUAGGA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QUAGGA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
quagga-ipk: $(QUAGGA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
quagga-clean:
	-$(MAKE) -C $(QUAGGA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
quagga-dirclean:
	rm -rf $(BUILD_DIR)/$(QUAGGA_DIR) $(QUAGGA_BUILD_DIR) $(QUAGGA_IPK_DIR) $(QUAGGA_IPK)

#
# Some sanity check for the package.
#
quagga-check: $(QUAGGA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
