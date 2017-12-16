###########################################################
#
# cups
#
###########################################################

# You must replace "cups" and "CUPS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CUPS_VERSION, CUPS_SITE and CUPS_SOURCE define
# the upstream location of the source code for the package.
# CUPS_DIR is the directory which is created when the source
# archive is unpacked.
# CUPS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CUPS_VERSION=2.2.6
CUPS_SITE=https://github.com/apple/cups/releases/download/v$(CUPS_VERSION)
CUPS_SOURCE=cups-$(CUPS_VERSION)-source.tar.gz
CUPS_DIR=cups-$(CUPS_VERSION)
CUPS_UNZIP=zcat
CUPS_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
CUPS_DESCRIPTION=Common Unix Printing System
LIBCUPS_DESCRIPTION=Common Unix Printing System - Core library
LIBCUPSCGI_DESCRIPTION=Common Unix Printing System - CGI library
LIBCUPSIMAGE_DESCRIPTION=Common Unix Printing System - IMAGE library
LIBCUPSMIME_DESCRIPTION=Common Unix Printing System - MIME library
LIBCUPSPPDC_DESCRIPTION=Common Unix Printing System - PPDC library
CUPS_SECTION=net
CUPS_PRIORITY=optional
LIBCUPS_DEPENDS=zlib, libavahi-common, libavahi-client
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBCUPS_DEPENDS+=, libiconv
endif
ifeq (gnutls, $(filter gnutls, $(PACKAGES)))
LIBCUPS_DEPENDS+=, gnutls
endif
LIBCUPSCGI_DEPENDS=libcups
LIBCUPSIMAGE_DEPENDS=libcups
LIBCUPSMIME_DEPENDS=libcups
LIBCUPSPPDC_DEPENDS=libcups, libstdc++
CUPS_DEPENDS=libcups, libcupscgi, libcupsimage, libcupsmime, libcupsppdc, libjpeg, libpng, libtiff, openssl, psmisc, libusb1, dbus, avahi, libacl, start-stop-daemon
ifeq (openldap, $(filter openldap, $(PACKAGES)))
CUPS_DEPENDS+=, openldap-libs
endif

CUPS_SUGGESTS=xinetd, samba36
CUPS_CONFLICTS=

#
# CUPS_IPK_VERSION should be incremented when the ipk changes.
#
CUPS_IPK_VERSION=3

CUPS_DOC_DESCRIPTION=Common Unix Printing System documentation.
CUPS-DEV_DESCRIPTION=Development files for CUPS

#
# CUPS_CONFFILES should be a list of user-editable files
CUPS_CONFFILES=$(TARGET_PREFIX)/etc/cups/cupsd.conf $(TARGET_PREFIX)/etc/cups/printers.conf \
		$(TARGET_PREFIX)/etc/cups/cups-files.conf $(TARGET_PREFIX)/etc/cups/printers.conf \
		$(TARGET_PREFIX)/etc/cups/snmp.conf $(TARGET_PREFIX)/share/cups/mime/mime.types $(TARGET_PREFIX)/share/cups/mime/mime.convs \
		$(TARGET_PREFIX)/etc/init.d/S88cupsd \
		$(TARGET_PREFIX)/etc/xinetd.d/cups-lpd

#
# CUPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CUPS_PATCHES=$(CUPS_SOURCE_DIR)/man-Makefile.patch $(CUPS_SOURCE_DIR)/ppdc-Makefile.patch
CUPS_PATCHES=\
$(CUPS_SOURCE_DIR)/debian/pwg-raster-attributes.patch \
$(CUPS_SOURCE_DIR)/debian/manpage-hyphen-minus.patch \
$(CUPS_SOURCE_DIR)/debian/rootbackends-worldreadable.patch \
$(CUPS_SOURCE_DIR)/debian/fixes-for-jobs-with-multiple-files-and-multiple-formats.patch \
$(CUPS_SOURCE_DIR)/debian/tests-ignore-warnings.patch \
$(CUPS_SOURCE_DIR)/debian/tests-ignore-usb-crash.patch \
$(CUPS_SOURCE_DIR)/debian/tests-ignore-kfreebsd-amd64-not-a-pdf.patch \
$(CUPS_SOURCE_DIR)/debian/tests-ignore-ipv6-address-family-not-supported.patch \
$(CUPS_SOURCE_DIR)/debian/tests-ignore-kfreebsd-unable-to-write-uncompressed-print-data.patch \
$(CUPS_SOURCE_DIR)/debian/test-i18n-nonlinux.patch \
$(CUPS_SOURCE_DIR)/debian/tests-wait-on-unfinished-jobs-everytime.patch \
$(CUPS_SOURCE_DIR)/debian/tests-fix-ppdLocalize-on-unclean-env.patch \
$(CUPS_SOURCE_DIR)/debian/tests-use-ipv4-lo-address.patch \
$(CUPS_SOURCE_DIR)/debian/tests-make-lpstat-call-reproducible.patch \
$(CUPS_SOURCE_DIR)/debian/tests-no-pdftourf.patch \
$(CUPS_SOURCE_DIR)/debian/move-cupsd-conf-default-to-share.patch \
$(CUPS_SOURCE_DIR)/debian/drop_unnecessary_dependencies.patch \
$(CUPS_SOURCE_DIR)/debian/read-embedded-options-from-incoming-postscript-and-add-to-ipp-attrs.patch \
$(CUPS_SOURCE_DIR)/debian/cups-deviced-allow-device-ids-with-newline.patch \
$(CUPS_SOURCE_DIR)/debian/airprint-support.patch \
$(CUPS_SOURCE_DIR)/debian/cups-snmp-oids-device-id-hp-ricoh.patch \
$(CUPS_SOURCE_DIR)/debian/no-conffile-timestamp.patch \
$(CUPS_SOURCE_DIR)/debian/removecvstag.patch \
$(CUPS_SOURCE_DIR)/debian/rename-systemd-units.patch \
$(CUPS_SOURCE_DIR)/debian/do-not-broadcast-with-hostnames.patch \
$(CUPS_SOURCE_DIR)/debian/reactivate_recommended_driver.patch \
$(CUPS_SOURCE_DIR)/debian/logfiles_adm_readable.patch \
$(CUPS_SOURCE_DIR)/debian/default_log_settings.patch \
$(CUPS_SOURCE_DIR)/debian/confdirperms.patch \
$(CUPS_SOURCE_DIR)/debian/printer-filtering.patch \
$(CUPS_SOURCE_DIR)/debian/show-compile-command-lines.patch \
$(CUPS_SOURCE_DIR)/debian/log-debug-history-nearly-unlimited.patch \
$(CUPS_SOURCE_DIR)/debian/cupsd-set-default-for-SyncOnClose-to-Yes.patch \
$(CUPS_SOURCE_DIR)/debian/cups-set-default-error-policy-retry-job.patch \
$(CUPS_SOURCE_DIR)/debian/man-cups-lpd-drop-dangling-references.patch \
$(CUPS_SOURCE_DIR)/debian/debianize_cups-config.patch \
$(CUPS_SOURCE_DIR)/debian/0037-Build-mantohtml-with-the-build-architecture-compiler.patch \
$(CUPS_SOURCE_DIR)/debian/manpage-translations.patch \
$(CUPS_SOURCE_DIR)/debian/0039-The-lp-and-lpr-commands-now-provide-better-error-mes.patch \
$(CUPS_SOURCE_DIR)/manpage-po4a.patch \
$(CUPS_SOURCE_DIR)/cupsd-set-default-for-RIPCache-to-auto.patch \
#$(CUPS_SOURCE_DIR)/optware_pidfile.patch \
#$(CUPS_SOURCE_DIR)/build_without_gnutls.patch

CUPS_HOST_PATCHES=\
$(CUPS_PATCHES) \

CUPS_TARGET_PATCHES=\
$(CUPS_PATCHES) \
$(CUPS_SOURCE_DIR)/ppdc.patch \

ifeq ($(LIBC_STYLE), uclibc)
ifneq ($(OPTWARE_TARGET), ts101)
#CUPS_PATCHES+=$(CUPS_SOURCE_DIR)/uclibc-backend-lpd.c.patch
endif
endif

ifeq ($(OPTWARE_TARGET), openwrt-brcm24)
CUPS_LIBS=-luclibcnotimpl
CUPS_PATCHES+=	$(CUPS_SOURCE_DIR)/filter-image-colorspace-c-cbrt.patch
else
CUPS_LIBS=
endif

#

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CUPS_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), openwrt-ixp4xx)
CUPS_PATCHES+=$(CUPS_SOURCE_DIR)/filter-image-colorspace-c-cbrt.patch
CUPS_CPPFLAGS+=-fno-builtin-ceil -fno-builtin-cbrt
endif
CUPS_LDFLAGS=
ifeq ($(OPTWARE_TARGET), openwrt-ixp4xx)
CUPS_LDFLAGS+= -lm
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
CUPS_LDFLAGS+= -liconv
endif

ifeq (gnutls, $(filter gnutls, $(PACKAGES)))
CUPS_CONFIG_OPTS+= --enable-gnutls
else
CUPS_CONFIG_OPTS+= --disable-gnutls
endif

ifeq ($(OPTWARE_TARGET), $(filter cs05q1armel, $(OPTWARE_TARGET)))
CUPS_CONFIG_ENV=ac_cv_func_epoll_create=no
endif

#
# CUPS_BUILD_DIR is the directory in which the build is done.
# CUPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUPS_IPK_DIR is the directory in which the ipk is built.
# CUPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUPS_SOURCE_DIR=$(SOURCE_DIR)/cups

CUPS_BUILD_DIR=$(BUILD_DIR)/cups
CUPS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/cups

CUPS_IPK_DIR=$(BUILD_DIR)/cups-$(CUPS_VERSION)-ipk
CUPS_IPK=$(BUILD_DIR)/cups_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPS_IPK_DIR=$(BUILD_DIR)/libcups-$(CUPS_VERSION)-ipk
LIBCUPS_IPK=$(BUILD_DIR)/libcups_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPSCGI_IPK_DIR=$(BUILD_DIR)/libcupscgi-$(CUPS_VERSION)-ipk
LIBCUPSCGI_IPK=$(BUILD_DIR)/libcupscgi_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPSIMAGE_IPK_DIR=$(BUILD_DIR)/libcupsimage-$(CUPS_VERSION)-ipk
LIBCUPSIMAGE_IPK=$(BUILD_DIR)/libcupsimage_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPSMIME_IPK_DIR=$(BUILD_DIR)/libcupsmime-$(CUPS_VERSION)-ipk
LIBCUPSMIME_IPK=$(BUILD_DIR)/libcupsmime_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPSPPDC_IPK_DIR=$(BUILD_DIR)/libcupsppdc-$(CUPS_VERSION)-ipk
LIBCUPSPPDC_IPK=$(BUILD_DIR)/libcupsppdc_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

CUPS-DEV_IPK=$(BUILD_DIR)/cups-dev_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_IPK=$(BUILD_DIR)/cups-doc_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cups-source cups-unpack cups cups-stage cups-ipk cups-clean cups-dirclean cups-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CUPS_SOURCE):
	$(WGET) -P $(@D) $(CUPS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cups-source: $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_PATCHES)

$(CUPS_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_HOST_PATCHES) make/cups.mk
#	$(MAKE) libjpeg-host-stage libpng-host-stage
#	$(MAKE) openssl-host-stage
	rm -rf  $(HOST_BUILD_DIR)/$(CUPS_DIR) $(@D) \
		$(HOST_STAGING_PREFIX)/share/cups $(HOST_STAGING_PREFIX)/etc/cups
	$(CUPS_UNZIP) $(DL_DIR)/$(CUPS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(CUPS_HOST_PATCHES)" ; \
		then cat $(CUPS_HOST_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(CUPS_DIR) -p1 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(CUPS_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(CUPS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=$(HOST_STAGING_PREFIX) \
		--exec_prefix=$(HOST_STAGING_PREFIX) \
		--with-icondir=$(HOST_STAGING_PREFIX)/share/icons \
		--with-menudir=$(HOST_STAGING_PREFIX)/share/applications \
		--libdir=$(HOST_STAGING_LIB_DIR) \
		--disable-nls \
		--disable-dbus \
		--disable-tiff \
		--disable-avahi \
		--with-openssl-libs=/lib  \
		--with-openssl-includes=/usr/include/openssl \
		--without-java \
		--without-perl \
		--without-php \
		--without-python \
		--disable-slp \
		--disable-gnutls \
		--disable-gssapi \
	)
	sed -i -e "s/-Wno-tautological-compare//" $(@D)/Makedefs
	sed -i -e "s/^DIRS\t=.*/DIRS\t=\tcups \$$(BUILDDIRS)/" $(@D)/Makefile
	$(MAKE) -C $(@D) CC_FOR_BUILD=$(HOSTCC)
	touch $@

$(CUPS_HOST_BUILD_DIR)/.staged: $(CUPS_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install INITDIR=$(HOST_STAGING_PREFIX)/etc
	touch $@

cups-host-stage: $(CUPS_HOST_BUILD_DIR)/.staged

$(CUPS_BUILD_DIR)/.configured: $(CUPS_HOST_BUILD_DIR)/.built $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_TARGET_PATCHES) make/cups.mk
	$(MAKE) openssl-stage zlib-stage libpng-stage \
		libjpeg-stage libtiff-stage \
		libusb1-stage dbus-stage libstdc++-stage avahi-stage libacl-stage
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (gnutls, $(filter gnutls, $(PACKAGES)))
	$(MAKE) gnutls-stage
endif
	rm -rf  $(BUILD_DIR)/$(CUPS_DIR) $(@D) \
		$(STAGING_PREFIX)/share/cups $(STAGING_PREFIX)/etc/cups
	$(CUPS_UNZIP) $(DL_DIR)/$(CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CUPS_TARGET_PATCHES)" ; \
		then cat $(CUPS_TARGET_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CUPS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CUPS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CUPS_DIR) $(@D) ; \
	fi
	sed -i -e '/OPTIM=/s/ -fstack-protector//' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(CUPS_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(CUPS_LDFLAGS) $(STAGING_LDFLAGS)" \
		LIBS="$(CUPS_LIBS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		$(CUPS_CONFIG_ENV) \
		./configure \
		--verbose \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--exec_prefix=$(TARGET_PREFIX) \
		--with-icondir=$(TARGET_PREFIX)/share/icons \
		--with-menudir=$(TARGET_PREFIX)/share/applications \
		--libdir=$(TARGET_PREFIX)/lib \
		--with-printcap=$(TARGET_PREFIX)/etc/printcap \
		--with-local-protocols="dnssd" \
		--disable-nls \
		--disable-dbus \
		--disable-pam \
		--with-rundir=$(TARGET_PREFIX)/var/run/cups \
		--with-logdir=$(TARGET_PREFIX)/var/log/cups \
		$(CUPS_CONFIG_OPTS) \
		--with-openssl-libs=$(STAGING_LIB_DIR) \
		--with-openssl-includes=$(STAGING_INCLUDE_DIR) \
		--without-java \
		--without-perl \
		--without-php \
		--without-python \
		--disable-slp \
		--disable-gssapi \
		--with-cups-user=nobody \
		--with-cups-group=nobody \
		--with-system-groups="root sys system" \
		--with-lpdconfigfile=xinetd://$(TARGET_PREFIX)/etc/xinetd.d/cups-lpd \
		--with-smbconfigfile=samba://$(TARGET_PREFIX)/etc/samba/smb.conf \
	)
ifdef CUPS_GCC_DOES_NOT_SUPPORT_PIE
	sed -i -e 's/ -pie -fPIE//' $(@D)/Makedefs
endif
#	sed -i -e '/^GENSTRINGS_DIR/s|=.*| = $(CUPS_HOST_BUILD_DIR)/ppdc|' $(@D)/ppdc/Makefile
	sed -i -e "s/-Wno-tautological-compare//" -e\
		"s|^DSOFLAGS\t=\t|DSOFLAGS\t=\t-L$(STAGING_LIB_DIR) -Wl,-rpath,$(TARGET_PREFIX)/lib -Wl,-rpath-link,$(STAGING_LIB_DIR) |" $(@D)/Makedefs
	sed -i -e "s/^DIRS\t=.*/DIRS\t=\tcups \$$(BUILDDIRS)/" $(@D)/Makefile
	sed -i -e 's|\./genstrings|$(CUPS_HOST_BUILD_DIR)/ppdc/genstrings|' $(@D)/ppdc/Makefile
	sed -i -e 's|\./mantohtml|$(CUPS_HOST_BUILD_DIR)/man/mantohtml|' $(@D)/man/Makefile
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	sed -i -e 's/^COMMONLIBS\t=\t/COMMONLIBS\t=\t-liconv /' $(@D)/Makedefs
endif
	touch $@

cups-unpack: $(CUPS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CUPS_BUILD_DIR)/.built: $(CUPS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) CC_FOR_BUILD=$(HOSTCC)
	$(MAKE) install -C $(@D) \
		BUILDROOT=$(CUPS_BUILD_DIR)/install/ \
		datarootdir='$${prefix}' \
		INSTALL_BIN="install -m 755"
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
cups: $(CUPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CUPS_BUILD_DIR)/.staged: $(CUPS_BUILD_DIR)/.built
	rm -f $@
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)/cups
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)/filter
	$(INSTALL) -m 644 $(CUPS_BUILD_DIR)/cups/*.h \
		$(STAGING_INCLUDE_DIR)/cups
	$(INSTALL) -m 644 $(CUPS_BUILD_DIR)/filter/*.h \
		$(STAGING_INCLUDE_DIR)/cups
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 755 $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/bin/cups-config \
		$(STAGING_PREFIX)/bin
	sed -i -e 's|^prefix=$(TARGET_PREFIX)|prefix=$(STAGING_PREFIX)|' \
	       -e 's|^libdir=$(TARGET_PREFIX)|libdir=$${prefix}|' \
		$(STAGING_PREFIX)/bin/cups-config
	$(INSTALL) -m 644 $(CUPS_BUILD_DIR)/filter/libcupsimage.a \
		$(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(CUPS_BUILD_DIR)/cups/libcups.a $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(CUPS_BUILD_DIR)/filter/libcupsimage.so.2 \
		$(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(CUPS_BUILD_DIR)/cups/libcups.so.2 \
		$(STAGING_LIB_DIR)
	cd $(STAGING_LIB_DIR) && ln -fs libcupsimage.so.2 libcupsimage.so.1
	cd $(STAGING_LIB_DIR) && ln -fs libcups.so.2 libcups.so.1
	cd $(STAGING_LIB_DIR) && ln -fs libcups.so.2 libcups.so
	cd $(STAGING_LIB_DIR) && ln -fs libcupsimage.so.2 libcupsimage.so
	touch $@

cups-stage: $(CUPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cups
#
$(CUPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_CONFLICTS)" >>$@

$(BUILD_DIR)/libcups-$(CUPS_VERSION)-ipk/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libcups$*" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(LIBCUPS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCUPS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCUPS_CONFLICTS)" >>$@

$(BUILD_DIR)/libcups%-$(CUPS_VERSION)-ipk/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libcups$*" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(LIBCUPS$(shell echo $* | tr a-z A-Z)_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCUPS$(shell echo $* | tr a-z A-Z)_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCUPS$(shell echo $* | tr a-z A-Z)_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCUPS$(shell echo $* | tr a-z A-Z)_CONFLICTS)" >>$@


$(CUPS_IPK_DIR)-doc/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DOC_DESCRIPTION)" >>$@
	@echo "Depends: cups" >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

$(CUPS_IPK_DIR)-locale-%/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups-locale-$*" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: CUPS documentation, template and locale files for $*" >>$@
	@echo "Depends: cups-doc" >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

$(CUPS_IPK_DIR)-dev/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS-DEV_DESCRIPTION)" >>$@
	@echo "Depends: cups" >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CUPS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUPS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/cups/...
# Documentation files should be installed in $(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups/...
# Daemon startup scripts should be installed in $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cups
#
# You may need to patch your application to make it use these locations.
#

$(BUILD_DIR)/libcups_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk:
	rm -rf  $(LIBCUPS_IPK_DIR) \
		$(BUILD_DIR)/libcups_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBCUPS_IPK_DIR)$(TARGET_PREFIX)/lib
	cp -af $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/lib/libcups.so* $(LIBCUPS_IPK_DIR)$(TARGET_PREFIX)/lib
	chmod u+w $(LIBCUPS_IPK_DIR)$(TARGET_PREFIX)/lib/libcups.so*
	$(STRIP_COMMAND) $(LIBCUPS_IPK_DIR)$(TARGET_PREFIX)/lib/libcups.so*
	$(MAKE) $(LIBCUPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCUPS_IPK_DIR)

$(BUILD_DIR)/libcups%_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk:
	rm -rf  $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk \
		$(BUILD_DIR)/libcups$*_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk$(TARGET_PREFIX)/lib
	cp -af $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/lib/libcups$*.so* $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk$(TARGET_PREFIX)/lib
	chmod u+w $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk$(TARGET_PREFIX)/lib/libcups$*.so*
	$(STRIP_COMMAND) $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk$(TARGET_PREFIX)/lib/libcups$*.so*
	$(MAKE) $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUILD_DIR)/libcups$*-$(CUPS_VERSION)-ipk

$(CUPS_IPK) $(CUPS-DEV_IPK): $(CUPS_BUILD_DIR)/.locales
	rm -rf $(CUPS_IPK_DIR) $(BUILD_DIR)/cups_*_$(TARGET_ARCH).ipk
	rm -rf $(CUPS_IPK_DIR)-dev $(BUILD_DIR)/cups-dev_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(CUPS_IPK_DIR)
	$(INSTALL) -d $(CUPS_IPK_DIR)-dev$(TARGET_PREFIX)
# Make sure $(TARGET_PREFIX)/var/spool has correct permissions
	$(INSTALL) -m 0755 -d $(CUPS_IPK_DIR)$(TARGET_PREFIX)/var/spool
	cp -af $(CUPS_BUILD_DIR)/install/* $(CUPS_IPK_DIR)
	rm -f $(CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/*{.a,.so{,.*}}
	rm -rf $(CUPS_IPK_DIR)/etc
	rm -rf $(CUPS_IPK_DIR)$(TARGET_PREFIX)/share/doc/cups
	rm -rf $(CUPS_IPK_DIR)$(TARGET_PREFIX)/man
	rm -rf `find $(CUPS_IPK_DIR)$(TARGET_PREFIX)/share/cups/templates -mindepth 1 -type d`
	rm -rf $(CUPS_IPK_DIR)$(TARGET_PREFIX)/share/locale/*
# Create binary directories
	$(INSTALL) -d $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -d $(CUPS_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups
	chmod u+w $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin/cupsd && \
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin/* && \
	chmod u-w $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin/cupsd
	mv $(CUPS_IPK_DIR)$(TARGET_PREFIX)/bin/cups-config $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin/
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)$(TARGET_PREFIX)/bin/*
	mv $(CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin/cups-config $(CUPS_IPK_DIR)$(TARGET_PREFIX)/bin/
	for d in backend cgi-bin daemon filter monitor notifier; do \
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/cups/$$d/*; \
	done
	chmod 755 $(CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/cups/*
	chmod 700 $(CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/cups/backend/*
#	$(INSTALL) -m 644 $(CUPS_SOURCE_DIR)/mime.types $(CUPS_IPK_DIR)$(TARGET_PREFIX)/share/cups/mime
#	$(INSTALL) -m 644 $(CUPS_SOURCE_DIR)/mime.convs $(CUPS_IPK_DIR)$(TARGET_PREFIX)/share/cups/mime
# Copy the configuration file
	$(INSTALL) -m 644 $(CUPS_SOURCE_DIR)/cupsd.conf $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/cups
	$(INSTALL) -m 644 $(CUPS_SOURCE_DIR)/printers.conf $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/cups
# Copy the init.d startup file
	$(INSTALL) -d $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/rc.cups $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S88cupsd
# Install etc/xinetd.d/cups-lpd
	$(INSTALL) -d $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/xinetd.d
	$(INSTALL) -m 644 $(CUPS_SOURCE_DIR)/xinetd.d/cups-lpd $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/xinetd.d/cups-lpd
# Copy lpd startup files
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/S89cups-lpd \
		$(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/rc.xinetd.linksys \
		$(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups
	$(INSTALL) -m 644 $(CUPS_SOURCE_DIR)/cups-install.doc \
		$(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/cups-lpd $(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/rc.samba $(CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/cups
	mv $(CUPS_IPK_DIR)$(TARGET_PREFIX)/include $(CUPS_IPK_DIR)-dev$(TARGET_PREFIX)/
	sed -i -e '/^SystemGroup/s/^/#/' $(CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/cups/cups-files.conf
	$(MAKE) $(CUPS_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/postinst $(CUPS_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(CUPS_SOURCE_DIR)/prerm $(CUPS_IPK_DIR)/CONTROL/prerm
	echo $(CUPS_CONFFILES) | sed -e 's/ /\n/g' > $(CUPS_IPK_DIR)/CONTROL/conffiles
	$(MAKE) $(CUPS_IPK_DIR)-dev/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-dev

$(CUPS_BUILD_DIR)/.locales: $(CUPS_BUILD_DIR)/.built
	rm -f $@
	for l in `find builds/cups/install$(TARGET_PREFIX)/share/locale/ -mindepth 1 -type d | xargs -l1 basename`; do \
	    p=`echo $$l | tr [A-Z_] [a-z-]`; \
	    rm -rf $(CUPS_IPK_DIR)-locale-$$p \
		$(BUILD_DIR)/cups-locale-$${p}_*_$(TARGET_ARCH).ipk; \
	    $(INSTALL) -d $(CUPS_IPK_DIR)-locale-$$p$(TARGET_PREFIX)/share/locale/; \
	    cp -rf $(@D)/install$(TARGET_PREFIX)/share/locale/$$l \
		$(CUPS_IPK_DIR)-locale-$$p$(TARGET_PREFIX)/share/locale/; \
	    $(INSTALL) -d $(CUPS_IPK_DIR)-locale-$$p$(TARGET_PREFIX)/share/doc/cups/$$l; \
	    cp -rf $(@D)/install$(TARGET_PREFIX)/share/doc/cups/$$l \
		$(CUPS_IPK_DIR)-locale-$$p$(TARGET_PREFIX)/share/doc/cups/; \
	    $(INSTALL) -d $(CUPS_IPK_DIR)-locale-$$p$(TARGET_PREFIX)/share/cups/templates; \
	    cp -rf $(@D)/install$(TARGET_PREFIX)/share/cups/templates/$$l \
		$(CUPS_IPK_DIR)-locale-$$p$(TARGET_PREFIX)/share/cups/templates/; \
	    $(MAKE) $(CUPS_IPK_DIR)-locale-$$p/CONTROL/control; \
	    cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-locale-$$p; cd -; \
	done
	touch $@

cups-locales: $(CUPS_BUILD_DIR)/.locales

$(CUPS_DOC_IPK): $(CUPS_BUILD_DIR)/.built
	rm -rf $(CUPS_IPK_DIR)-doc* $(BUILD_DIR)/cups-doc*_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(CUPS_IPK_DIR)-doc
	$(INSTALL) -d $(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cups
	$(INSTALL) -d $(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/man
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/man/man1 \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/man
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/man/man5 \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/man
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/man/man8 \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/man
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/share/doc/cups/*.css \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cups
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/share/doc/cups/*.*html \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cups
#	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/share/doc/cups/*.pdf \
#		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cups
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/share/doc/cups/*.txt \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cups
	cp -rf $(CUPS_BUILD_DIR)/install$(TARGET_PREFIX)/share/doc/cups/images \
		$(CUPS_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cups
	$(MAKE) $(CUPS_IPK_DIR)-doc/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-doc

#
# This is called from the top level makefile to create the IPK file.
#
cups-ipk: 	$(CUPS_BUILD_DIR)/.locales $(CUPS_IPK) $(CUPS_DEV_IPK) $(CUPS_DOC_IPK) \
		$(LIBCUPS_IPK) $(LIBCUPSCGI_IPK) $(LIBCUPSIMAGE_IPK) $(LIBCUPSMIME_IPK) $(LIBCUPSPPDC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cups-clean:
	-$(MAKE) -C $(CUPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cups-dirclean:
	rm -rf	$(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR) \
	$(CUPS_IPK_DIR) $(CUPS_IPK) \
	$(CUPS_IPK_DIR)-dev $(CUPS-DEV_IPK) \
	$(CUPS_IPK_DIR)-doc $(CUPS_DOC_IPK) \
	$(CUPS_IPK_DIR)-locale-* \
	$(BUILD_DIR)/cups-locale-*_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk \
	$(LIBCUPS_IPK_DIR) $(LIBCUPS_IPK) \
	$(LIBCUPSCGI_IPK_DIR) $(LIBCUPSCGI_IPK) \
	$(LIBCUPSIMAGE_IPK_DIR) $(LIBCUPSIMAGE_IPK) \
	$(LIBCUPSMIME_IPK_DIR) $(LIBCUPSMIME_IPK) \
	$(LIBCUPSPPDC_IPK_DIR) $(LIBCUPSPPDC_IPK)

#
# Some sanity check for the package.
#
cups-check: $(CUPS_IPK) $(LIBCUPS_IPK) $(LIBCUPSCGI_IPK) $(LIBCUPSIMAGE_IPK) $(LIBCUPSMIME_IPK) $(LIBCUPSPPDC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
