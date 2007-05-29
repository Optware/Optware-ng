###########################################################
#
# cherokee
#
###########################################################

#
# CHEROKEE_VERSION, CHEROKEE_SITE and CHEROKEE_SOURCE define
# the upstream location of the source code for the package.
# CHEROKEE_DIR is the directory which is created when the source
# archive is unpacked.
# CHEROKEE_UNZIP is the command used to unzip the source.
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
CHEROKEE_VERSION=0.5.6
CHEROKEE_SITE=http://www.0x50.org/download/0.5/$(CHEROKEE_VERSION)
CHEROKEE_SOURCE=cherokee-$(CHEROKEE_VERSION).tar.gz
CHEROKEE_DIR=cherokee-$(CHEROKEE_VERSION)
CHEROKEE_UNZIP=zcat
CHEROKEE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CHEROKEE_DESCRIPTION=A flexible, very fast, lightweight web server.
CHEROKEE_SECTION=web
CHEROKEE_PRIORITY=optional
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
CHEROKEE_DEPENDS=libstdc++, libtasn1, gnutls, libgcrypt, pcre
else
CHEROKEE_DEPENDS=libtasn1, gnutls, libgcrypt, pcre
endif
CHEROKEE_SUGGESTS=
CHEROKEE_CONFLICTS=

#
# CHEROKEE_IPK_VERSION should be incremented when the ipk changes.
#
CHEROKEE_IPK_VERSION=3

#
# CHEROKEE_CONFFILES should be a list of user-editable files
CHEROKEE_CONFFILES=\
	/opt/etc/cherokee/mods-available/ssl \
	/opt/etc/cherokee/sites-available/default \
	/opt/etc/cherokee/sites-available/example.com \
	/opt/etc/cherokee/cherokee.conf \
	/opt/etc/cherokee/advanced.conf \
	/opt/etc/cherokee/icons.conf \
	/opt/etc/cherokee/mime.conf \
	/opt/etc/cherokee/mime.types \
	/opt/etc/cherokee/mime.compression.types \
	/opt/etc/init.d/S80cherokee \
	/opt/share/www/cherokee/index.html \

#
# CHEROKEE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(OPTWARE_TARGET), wl500g)
CHEROKEE_PATCHES=\
	$(CHEROKEE_SOURCE_DIR)/configure.in.patch \
	$(CHEROKEE_SOURCE_DIR)/cherokee-Makefile.in.patch \
	$(CHEROKEE_SOURCE_DIR)/cget-Makefile.in.patch
else
CHEROKEE_PATCHES=\
	$(CHEROKEE_SOURCE_DIR)/configure.in.patch \
	$(CHEROKEE_SOURCE_DIR)/cherokee-Makefile.in.patch \
	$(CHEROKEE_SOURCE_DIR)/cget-Makefile.in.patch \
	$(CHEROKEE_SOURCE_DIR)/old_uclibc_tm_gmtoff.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CHEROKEE_CPPFLAGS=
CHEROKEE_LDFLAGS=

ifeq (no, $(IPV6))
CHEROKEE_CONFIGURE_OPTIONS+=--disable-ipv6
endif

#
# CHEROKEE_BUILD_DIR is the directory in which the build is done.
# CHEROKEE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CHEROKEE_IPK_DIR is the directory in which the ipk is built.
# CHEROKEE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CHEROKEE_BUILD_DIR=$(BUILD_DIR)/cherokee
CHEROKEE_SOURCE_DIR=$(SOURCE_DIR)/cherokee
CHEROKEE_IPK_DIR=$(BUILD_DIR)/cherokee-$(CHEROKEE_VERSION)-ipk
CHEROKEE_IPK=$(BUILD_DIR)/cherokee_$(CHEROKEE_VERSION)-$(CHEROKEE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cherokee-source cherokee-unpack cherokee cherokee-stage cherokee-ipk cherokee-clean cherokee-dirclean cherokee-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CHEROKEE_SOURCE):
	$(WGET) -P $(DL_DIR) $(CHEROKEE_SITE)/$(CHEROKEE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cherokee-source: $(DL_DIR)/$(CHEROKEE_SOURCE) $(CHEROKEE_PATCHES)

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
$(CHEROKEE_BUILD_DIR)/.configured: $(DL_DIR)/$(CHEROKEE_SOURCE) $(CHEROKEE_PATCHES)
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) gnutls-stage libtasn1-stage libgcrypt-stage pcre-stage
	rm -rf $(BUILD_DIR)/$(CHEROKEE_DIR) $(CHEROKEE_BUILD_DIR)
	$(CHEROKEE_UNZIP) $(DL_DIR)/$(CHEROKEE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CHEROKEE_PATCHES)"; then \
	    cat $(CHEROKEE_PATCHES) | patch -d $(BUILD_DIR)/$(CHEROKEE_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(CHEROKEE_DIR) $(CHEROKEE_BUILD_DIR)
	(cd $(CHEROKEE_BUILD_DIR); \
		autoconf configure.in > configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CHEROKEE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CHEROKEE_LDFLAGS)" \
		LIBGNUTLS_CONFIG=`find $(STAGING_DIR) -name '*libgnutls-config'` \
		ac_cv_what_readdir_r=POSIX \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-wwwroot=/opt/share/www/cherokee \
		$(CHEROKEE_CONFIGURE_OPTIONS) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(CHEROKEE_BUILD_DIR)/libtool
	sed -i 's|^hardcode_libdir_flag_spec=.*$$|hardcode_libdir_flag_spec=""|' $(CHEROKEE_BUILD_DIR)/libtool
	touch $(CHEROKEE_BUILD_DIR)/.configured

cherokee-unpack: $(CHEROKEE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CHEROKEE_BUILD_DIR)/.built: $(CHEROKEE_BUILD_DIR)/.configured
	rm -f $(CHEROKEE_BUILD_DIR)/.built
	$(MAKE) -C $(CHEROKEE_BUILD_DIR)
	cd $(CHEROKEE_BUILD_DIR); $(HOSTCC) -DHAVE_SYS_STAT_H -o cherokee_replace cherokee_replace.c
	touch $(CHEROKEE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cherokee: $(CHEROKEE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CHEROKEE_BUILD_DIR)/.staged: $(CHEROKEE_BUILD_DIR)/.built
	rm -f $(CHEROKEE_BUILD_DIR)/.staged
	$(MAKE) -C $(CHEROKEE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CHEROKEE_BUILD_DIR)/.staged

cherokee-stage: $(CHEROKEE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cherokee
#
$(CHEROKEE_IPK_DIR)/CONTROL/control:
	@install -d $(CHEROKEE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cherokee" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHEROKEE_PRIORITY)" >>$@
	@echo "Section: $(CHEROKEE_SECTION)" >>$@
	@echo "Version: $(CHEROKEE_VERSION)-$(CHEROKEE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHEROKEE_MAINTAINER)" >>$@
	@echo "Source: $(CHEROKEE_SITE)/$(CHEROKEE_SOURCE)" >>$@
	@echo "Description: $(CHEROKEE_DESCRIPTION)" >>$@
	@echo "Depends: $(CHEROKEE_DEPENDS)" >>$@
	@echo "Suggests: $(CHEROKEE_SUGGESTS)" >>$@
	@echo "Conflicts: $(CHEROKEE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CHEROKEE_IPK_DIR)/opt/sbin or $(CHEROKEE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CHEROKEE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CHEROKEE_IPK_DIR)/opt/etc/cherokee/...
# Documentation files should be installed in $(CHEROKEE_IPK_DIR)/opt/doc/cherokee/...
# Daemon startup scripts should be installed in $(CHEROKEE_IPK_DIR)/opt/etc/init.d/S??cherokee
#
# You may need to patch your application to make it use these locations.
#
$(CHEROKEE_IPK): $(CHEROKEE_BUILD_DIR)/.built
	rm -rf $(CHEROKEE_IPK_DIR) $(BUILD_DIR)/cherokee_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CHEROKEE_BUILD_DIR) DESTDIR=$(CHEROKEE_IPK_DIR) install-strip
	rm $(CHEROKEE_IPK_DIR)/opt/lib/*.la $(CHEROKEE_IPK_DIR)/opt/lib/cherokee/*.la
	install -d $(CHEROKEE_IPK_DIR)/opt/share/cherokee/cgi-bin
	sed -i -e 's|/usr/lib/|/opt/share/cherokee/|' $(CHEROKEE_IPK_DIR)/opt/etc/cherokee/sites-available/default
	sed -i -e 's|^Port.*|Port 8008|; s|^Timeout.*|Timeout 60|' $(CHEROKEE_IPK_DIR)/opt/etc/cherokee/cherokee.conf
	sed -i -e 's|^MaxFds.*|MaxFds 1024|' $(CHEROKEE_IPK_DIR)/opt/etc/cherokee/advanced.conf
	touch $(CHEROKEE_IPK_DIR)/opt/etc/cherokee/mime.conf
	install -d $(CHEROKEE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CHEROKEE_SOURCE_DIR)/rc.cherokee $(CHEROKEE_IPK_DIR)/opt/etc/init.d/S80cherokee
	$(MAKE) $(CHEROKEE_IPK_DIR)/CONTROL/control
	install -m 755 $(CHEROKEE_SOURCE_DIR)/postinst $(CHEROKEE_IPK_DIR)/CONTROL/postinst
	install -m 755 $(CHEROKEE_SOURCE_DIR)/prerm $(CHEROKEE_IPK_DIR)/CONTROL/prerm
	echo $(CHEROKEE_CONFFILES) | sed -e 's/ /\n/g' > $(CHEROKEE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CHEROKEE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cherokee-ipk: $(CHEROKEE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cherokee-clean:
	rm -f $(CHEROKEE_BUILD_DIR)/.built
	-$(MAKE) -C $(CHEROKEE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cherokee-dirclean:
	rm -rf $(BUILD_DIR)/$(CHEROKEE_DIR) $(CHEROKEE_BUILD_DIR) $(CHEROKEE_IPK_DIR) $(CHEROKEE_IPK)

#
# Some sanity check for the package.
#
cherokee-check: $(CHEROKEE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CHEROKEE_IPK)
