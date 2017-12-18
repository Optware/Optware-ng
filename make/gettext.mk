###########################################################
#
# gettext
#
###########################################################

#
# GETTEXT_VERSION_EXACT, GETTEXT_SITE and GETTEXT_SOURCE define
# the upstream location of the source code for the package.
# GETTEXT_DIR is the directory which is created when the source
# archive is unpacked.
# GETTEXT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GETTEXT_SITE=http://ftp.gnu.org/gnu/gettext
GETTEXT_VERSION_EXACT=0.19.8.1
GETTEXT_VERSION=0.19.8
GETTEXT_VERSION_MAJOR=0.19
GETTEXT_SOURCE=gettext-$(GETTEXT_VERSION_EXACT).tar.gz
GETTEXT_DIR=gettext-$(GETTEXT_VERSION_EXACT)
GETTEXT_UNZIP=zcat
GETTEXT_SECTION=devel
LIBINTL_SECTION=libs
GETTEXT_PRIORITY=optional
LIBINTL_PRIORITY=optional
GETTEXT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GETTEXT_DESCRIPTION=Set of tools for producing multi-lingual messages
LIBINTL_DESCRIPTION=gettext libintl
ifneq (libiconv, $(filter libiconv, $(PACKAGES)))
GETTEXT_DEPENDS=libintl, libunistring, ncurses
LIBINTL_DEPENDS=
else
GETTEXT_DEPENDS=libintl, libunistring, ncurses, libiconv
LIBINTL_DEPENDS=libiconv
endif
GETTEXT_SUGGESTS=
GETTEXT_CONFLICTS=

#
# GETTEXT_IPK_VERSION should be incremented when the ipk changes.
#
GETTEXT_IPK_VERSION=5

#
# GETTEXT_CONFFILES should be a list of user-editable files
#GETTEXT_CONFFILES=$(TARGET_PREFIX)/etc/gettext.conf $(TARGET_PREFIX)/etc/init.d/SXXgettext

#
# GETTEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GETTEXT_PATCHES=$(GETTEXT_SOURCE_DIR)/uClibc-error_print_progname.0.19.4.patch
#GETTEXT_PATCHES=$(GETTEXT_SOURCE_DIR)/Makefile.in.patch \
		$(GETTEXT_SOURCE_DIR)/uClibc-error_print_progname.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GETTEXT_CPPFLAGS=
GETTEXT_LDFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
GETTEXT_LDFLAGS += -lrt
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GETTEXT_LDFLAGS += -liconv
endif

#
# GETTEXT_BUILD_DIR is the directory in which the build is done.
# GETTEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GETTEXT_IPK_DIR is the directory in which the ipk is built.
# GETTEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GETTEXT_BUILD_DIR=$(BUILD_DIR)/gettext
GETTEXT_SOURCE_DIR=$(SOURCE_DIR)/gettext

GETTEXT_IPK_DIR=$(BUILD_DIR)/gettext-$(GETTEXT_VERSION_EXACT)-ipk
GETTEXT_IPK=$(BUILD_DIR)/gettext_$(GETTEXT_VERSION_EXACT)-$(GETTEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBINTL_IPK_DIR=$(BUILD_DIR)/libintl-$(GETTEXT_VERSION_EXACT)-ipk
LIBINTL_IPK=$(BUILD_DIR)/libintl_$(GETTEXT_VERSION_EXACT)-$(GETTEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

GETTEXT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gettext

GETTEXT_NLS ?= disable

.PHONY: gettext-source gettext-host gettext-host-stage gettext-unpack gettext
.PHONY: gettext-stage gettext-ipk gettext-clean gettext-dirclean gettext-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GETTEXT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gettext-source: $(DL_DIR)/$(GETTEXT_SOURCE) $(GETTEXT_PATCHES)


$(GETTEXT_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GETTEXT_SOURCE) make/gettext.mk
	rm -rf $(HOST_BUILD_DIR)/$(GETTEXT_DIR) $(@D)
	$(GETTEXT_UNZIP) $(DL_DIR)/$(GETTEXT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(GETTEXT_DIR) $(@D)
	(cd $(@D); \
		CFLAGS="-fPIC" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--disable-shared \
	)
	$(MAKE) -C $(@D)
	touch $@

gettext-host: $(GETTEXT_HOST_BUILD_DIR)/.built


$(GETTEXT_HOST_BUILD_DIR)/.staged: $(GETTEXT_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	cp -f $(@D)/gettext-tools/intl/.libs/libgnuintl.a $(HOST_STAGING_LIB_DIR)/libintl.a
	touch $@

gettext-host-stage: $(GETTEXT_HOST_BUILD_DIR)/.staged


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
$(GETTEXT_BUILD_DIR)/.configured: $(DL_DIR)/$(GETTEXT_SOURCE) $(GETTEXT_PATCHES) make/gettext.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) libunistring-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(GETTEXT_DIR) $(@D)
	$(GETTEXT_UNZIP) $(DL_DIR)/$(GETTEXT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GETTEXT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(GETTEXT_DIR) -p1
	mv $(BUILD_DIR)/$(GETTEXT_DIR) $(@D)
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GETTEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GETTEXT_LDFLAGS)" \
		ac_cv_func_getline=yes \
		am_cv_func_working_getline=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--$(GETTEXT_NLS)-nls \
		--with-included-libacl \
		--with-included-libcroco \
		--with-included-glib \
		--disable-static \
		--disable-rpath \
		--disable-native-java \
	)
	touch $@

gettext-unpack: $(GETTEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GETTEXT_BUILD_DIR)/.built: $(GETTEXT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gettext: $(GETTEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GETTEXT_BUILD_DIR)/.staged: $(GETTEXT_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_LIB_DIR)/libgettext*.* \
	      $(STAGING_LIB_DIR)/libintl.* \
	      $(STAGING_LIB_DIR)/libgnuintl.* \
	      $(STAGING_LIB_DIR)/libasprintf.*
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgettext*.la \
	      $(STAGING_LIB_DIR)/libintl.la \
	      $(STAGING_LIB_DIR)/libgnuintl.la \
	      $(STAGING_LIB_DIR)/libasprintf.la
	if [ ! -f $(STAGING_LIB_DIR)/libintl.so ]; then \
		cp -af $(@D)/gettext-tools/intl/.libs/*.so* $(STAGING_LIB_DIR); \
		if [ ! -f $(STAGING_LIB_DIR)/libintl.so ]; then \
			ln -s libgnuintl.so $(STAGING_LIB_DIR)/libintl.so; \
		fi; \
	fi
	touch $@

gettext-stage: $(GETTEXT_BUILD_DIR)/.staged


#
# This rule creates a control file for ipkg.
#
$(GETTEXT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(GETTEXT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gettext" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GETTEXT_PRIORITY)" >>$@
	@echo "Section: $(GETTEXT_SECTION)" >>$@
	@echo "Version: $(GETTEXT_VERSION_EXACT)-$(GETTEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GETTEXT_MAINTAINER)" >>$@
	@echo "Source: $(GETTEXT_SITE)/$(GETTEXT_SOURCE)" >>$@
	@echo "Description: $(GETTEXT_DESCRIPTION)" >>$@
	@echo "Depends: $(GETTEXT_DEPENDS)" >>$@
	@echo "Suggests: $(GETTEXT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GETTEXT_CONFLICTS)" >>$@

$(LIBINTL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(LIBINTL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libintl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBINTL_PRIORITY)" >>$@
	@echo "Section: $(LIBINTL_SECTION)" >>$@
	@echo "Version: $(GETTEXT_VERSION_EXACT)-$(GETTEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GETTEXT_MAINTAINER)" >>$@
	@echo "Source: $(GETTEXT_SITE)/$(GETTEXT_SOURCE)" >>$@
	@echo "Description: $(LIBINTL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBINTL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBINTL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBINTL_CONFLICTS)" >>$@


#
# This builds the IPK file.
#
# Binaries should be installed into $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/etc/gettext/...
# Documentation files should be installed in $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/doc/gettext/...
# Daemon startup scripts should be installed in $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gettext
#
# You may need to patch your application to make it use these locations.
#
$(GETTEXT_IPK) $(LIBINTL_IPK): $(GETTEXT_BUILD_DIR)/.built
	rm -rf  $(GETTEXT_IPK_DIR) $(BUILD_DIR)/gettext_*_$(TARGET_ARCH).ipk \
		$(LIBINTL_IPK_DIR) $(BUILD_DIR)/libintl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GETTEXT_BUILD_DIR) DESTDIR=$(GETTEXT_IPK_DIR) install
	rm -f $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	if [ ! -f $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/lib/libintl.so ]; then \
		cp -af $(GETTEXT_BUILD_DIR)/gettext-tools/intl/.libs/*.so* $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/lib; \
		if [ ! -f $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/lib/libintl.so ]; then \
			ln -s libgnuintl.so $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/lib/libintl.so; \
		fi; \
	fi
	-$(STRIP_COMMAND) 	$(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/lib/*.so* \
				$(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/{bin,lib/gettext}/* 2>/dev/null
	$(INSTALL) -d $(LIBINTL_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/lib/lib*intl.so* $(LIBINTL_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBINTL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBINTL_IPK_DIR)
#	$(INSTALL) -d $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 755 $(GETTEXT_SOURCE_DIR)/gettext.conf $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/etc/gettext.conf
#	$(INSTALL) -d $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GETTEXT_SOURCE_DIR)/rc.gettext $(GETTEXT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgettext
	$(MAKE) $(GETTEXT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(GETTEXT_SOURCE_DIR)/postinst $(GETTEXT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 644 $(GETTEXT_SOURCE_DIR)/prerm $(GETTEXT_IPK_DIR)/CONTROL/prerm
#	echo $(GETTEXT_CONFFILES) | sed -e 's/ /\n/g' > $(GETTEXT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GETTEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gettext-ipk: $(GETTEXT_IPK) $(LIBINTL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gettext-clean:
	rm -f $(GETTEXT_BUILD_DIR)/.built
	-$(MAKE) -C $(GETTEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gettext-dirclean:
	rm -rf  $(BUILD_DIR)/$(GETTEXT_DIR) $(GETTEXT_BUILD_DIR) \
		$(GETTEXT_IPK_DIR) $(GETTEXT_IPK) \
		$(LIBINTL_IPK_DIR) $(LIBINTL_IPK)

#
#
# Some sanity check for the package.
#
gettext-check: $(GETTEXT_IPK) $(LIBINTL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

