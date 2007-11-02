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
CUPS_VERSION=1.3.4
CUPS_SITE=http://ftp.easysw.com/pub/cups/$(CUPS_VERSION)
CUPS_SOURCE=cups-$(CUPS_VERSION)-source.tar.bz2
CUPS_DIR=cups-$(CUPS_VERSION)
CUPS_UNZIP=bzcat
CUPS_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
CUPS_DESCRIPTION=Common Unix Printing System
CUPS_SECTION=net
CUPS_PRIORITY=optional
CUPS_DEPENDS=libjpeg, libpng, libtiff, openssl, zlib
ifeq (openldap, $(filter openldap, $(PACKAGES)))
CUPS_DEPENDS+=, openldap-libs
else
endif
CUPS_SUGGESTS=
CUPS_CONFLICTS=

#
# CUPS_IPK_VERSION should be incremented when the ipk changes.
#
CUPS_IPK_VERSION=1

CUPS_DOC_DESCRIPTION=Common Unix Printing System documentation.
CUPS-DEV_DESCRIPTION=Development files for CUPS

#
# CUPS_CONFFILES should be a list of user-editable files
CUPS_CONFFILES=/opt/etc/cups/cupsd.conf /opt/etc/cups/printers.conf

#
# CUPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CUPS_PATCHES=$(CUPS_SOURCE_DIR)/man-Makefile.patch \
	$(CUPS_SOURCE_DIR)/Makefile.patch \

ifeq ($(LIBC_STYLE), uclibc)
ifneq ($(OPTWARE_TARGET), ts101)
CUPS_PATCHES+=$(CUPS_SOURCE_DIR)/uclibc-backend-lpd.c.patch
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
CUPS_LDFLAGS+=-lm
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
CUPS-DEV_IPK=$(BUILD_DIR)/cups-dev_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_IPK=$(BUILD_DIR)/cups-doc_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cups-source cups-unpack cups cups-stage cups-ipk cups-clean cups-dirclean cups-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CUPS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CUPS_SITE)/$(CUPS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CUPS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cups-source: $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_PATCHES)

$(CUPS_HOST_BUILD_DIR)/.built: $(DL_DIR)/$(CUPS_SOURCE) make/cups.mk
#	$(MAKE) libjpeg-host-stage libpng-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(CUPS_DIR) $(@D)
	$(CUPS_UNZIP) $(DL_DIR)/$(CUPS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(CUPS_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(CUPS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/opt \
		--exec_prefix=/opt \
		--with-icondir=/opt/share/icons \
		--with-menudir=/opt/share/applications \
		--libdir=/opt/lib \
		--disable-nls \
		--disable-dbus \
		--disable-tiff \
		--without-openssl \
		--without-java \
		--without-perl \
		--without-php \
		--without-python \
		--disable-slp \
		--disable-gnutls \
	)
	$(MAKE) -C $(@D)
	touch $@

$(CUPS_HOST_BUILD_DIR)/.staged: $(CUPS_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install DSTROOT=$(HOST_STAGING_DIR)
	sed -i -e 's|=/opt|=$(HOST_STAGING_PREFIX)|' $(HOST_STAGING_PREFIX)/bin/cups-config
	touch $@

cups-host-stage: $(CUPS_HOST_BUILD_DIR)/.staged

$(CUPS_BUILD_DIR)/.configured: $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_PATCHES) make/cups.mk
	$(MAKE) openssl-stage zlib-stage libpng-stage
	$(MAKE) libjpeg-stage libtiff-stage
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage
endif
	rm -rf $(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR)
	$(CUPS_UNZIP) $(DL_DIR)/$(CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CUPS_PATCHES)" ; \
		then cat $(CUPS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CUPS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CUPS_DIR)" != "$(CUPS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR) ; \
	fi
	(cd $(CUPS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(CUPS_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(CUPS_LDFLAGS) $(STAGING_LDFLAGS)" \
		LIBS="$(CUPS_LIBS)" \
		./configure \
		--verbose \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--exec_prefix=/opt \
		--with-icondir=/opt/share/icons \
		--with-menudir=/opt/share/applications \
		--libdir=/opt/lib \
		--disable-nls \
		--disable-dbus \
		--with-openssl-libs=$(STAGING_DIR)/opt/lib \
		--with-openssl-includes=$(STAGING_DIR)/opt/include \
		--without-java \
		--without-perl \
		--without-php \
		--without-python \
		--disable-slp \
		--disable-gnutls \
	)
	touch $@

cups-unpack: $(CUPS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CUPS_BUILD_DIR)/.built: $(CUPS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CUPS_BUILD_DIR)
	$(MAKE) install -C $(CUPS_BUILD_DIR) \
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
	install -d $(STAGING_DIR)/opt/include/cups
	install -d $(STAGING_DIR)/opt/include/filter
	install -m 644 $(CUPS_BUILD_DIR)/cups/*.h \
		$(STAGING_DIR)/opt/include/cups
	install -m 644 $(CUPS_BUILD_DIR)/filter/*.h \
		$(STAGING_DIR)/opt/include/cups
	install -d $(STAGING_DIR)/opt/lib
	install -m 755 $(CUPS_BUILD_DIR)/install/opt/bin/cups-config \
		$(STAGING_PREFIX)/bin
	sed -i -e 's|^prefix=/opt|prefix=$(STAGING_PREFIX)|' \
	       -e 's|^libdir=/opt|libdir=$${prefix}|' \
		$(STAGING_PREFIX)/bin/cups-config
	install -m 644 $(CUPS_BUILD_DIR)/filter/libcupsimage.a \
		$(STAGING_DIR)/opt/lib
	install -m 644 $(CUPS_BUILD_DIR)/cups/libcups.a $(STAGING_DIR)/opt/lib
	install -m 644 $(CUPS_BUILD_DIR)/filter/libcupsimage.so.2 \
		$(STAGING_DIR)/opt/lib
	install -m 644 $(CUPS_BUILD_DIR)/cups/libcups.so.2 \
		$(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libcupsimage.so.2 libcupsimage.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libcups.so.2 libcups.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libcups.so.2 libcups.so
	cd $(STAGING_DIR)/opt/lib && ln -fs libcupsimage.so.2 libcupsimage.so
	touch $@

cups-stage: $(CUPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cups
#
$(CUPS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(CUPS_IPK_DIR)-doc/CONTROL/control:
	@install -d $(@D)
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
	@install -d $(@D)
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
	@install -d $(@D)
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
# Binaries should be installed into $(CUPS_IPK_DIR)/opt/sbin or $(CUPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CUPS_IPK_DIR)/opt/etc/cups/...
# Documentation files should be installed in $(CUPS_IPK_DIR)/opt/doc/cups/...
# Daemon startup scripts should be installed in $(CUPS_IPK_DIR)/opt/etc/init.d/S??cups
#
# You may need to patch your application to make it use these locations.
#
$(CUPS_IPK) $(CUPS-DEV_IPK): $(CUPS_BUILD_DIR)/.locales
	rm -rf $(CUPS_IPK_DIR) $(BUILD_DIR)/cups_*_$(TARGET_ARCH).ipk
	rm -rf $(CUPS_IPK_DIR)-dev $(BUILD_DIR)/cups-dev_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)
	install -d $(CUPS_IPK_DIR)-dev/opt
# Make sure /opt/var/spool has correct permissions
	install -m 0755 -d $(CUPS_IPK_DIR)/opt/var/spool
	cp -rf $(CUPS_BUILD_DIR)/install/* $(CUPS_IPK_DIR)
	rm -f $(CUPS_IPK_DIR)/opt/lib/*.a
	rm -rf $(CUPS_IPK_DIR)/etc
	rm -rf $(CUPS_IPK_DIR)/opt/share/doc/cups
	rm -rf $(CUPS_IPK_DIR)/opt/man
	rm -rf `find $(CUPS_IPK_DIR)/opt/share/cups/templates -mindepth 1 -type d`
	rm -rf $(CUPS_IPK_DIR)/opt/share/locale/*
# Create binary directories
	install -d $(CUPS_IPK_DIR)/opt/sbin
	install -d $(CUPS_IPK_DIR)/opt/bin
	install -d $(CUPS_IPK_DIR)/opt/doc/cups
	install -d $(CUPS_IPK_DIR)/opt/lib/modules
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)/opt/sbin/*
	mv $(CUPS_IPK_DIR)/opt/bin/cups-config $(CUPS_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)/opt/bin/*
	mv $(CUPS_IPK_DIR)/opt/sbin/cups-config $(CUPS_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)/opt/lib/lib*.so.*
	$(STRIP_COMMAND) $(CUPS_IPK_DIR)/opt/lib/cups/{backend,cgi-bin,daemon,filter,monitor,notifier}/*
# Copy the configuration file
	cp $(CUPS_SOURCE_DIR)/cupsd.conf $(CUPS_IPK_DIR)/opt/etc/cups
	cp $(CUPS_SOURCE_DIR)/printers.conf $(CUPS_IPK_DIR)/opt/etc/cups
	cp $(CUPS_SOURCE_DIR)/mime.types $(CUPS_IPK_DIR)/opt/etc/cups
	cp $(CUPS_SOURCE_DIR)/mime.convs $(CUPS_IPK_DIR)/opt/etc/cups
# Copy the init.d startup file
	install -m 755 $(CUPS_SOURCE_DIR)/S88cups $(CUPS_IPK_DIR)/opt/doc/cups
# Copy lpd startup files
	install -m 755 $(CUPS_SOURCE_DIR)/S89cups-lpd \
		$(CUPS_IPK_DIR)/opt/doc/cups
	install -m 755 $(CUPS_SOURCE_DIR)/rc.xinetd.linksys \
		$(CUPS_IPK_DIR)/opt/doc/cups
	install -m 644 $(CUPS_SOURCE_DIR)/cups-install.doc \
		$(CUPS_IPK_DIR)/opt/doc/cups
	install -m 755 $(CUPS_SOURCE_DIR)/cups-lpd $(CUPS_IPK_DIR)/opt/doc/cups
	install -m 755 $(CUPS_SOURCE_DIR)/rc.samba $(CUPS_IPK_DIR)/opt/doc/cups
# Install printer module
	cp $(CUPS_SOURCE_DIR)/printer.o $(CUPS_IPK_DIR)/opt/lib/modules
	mv $(CUPS_IPK_DIR)/opt/include $(CUPS_IPK_DIR)-dev/opt/
	$(MAKE) $(CUPS_IPK_DIR)/CONTROL/control
#	install -m 644 $(CUPS_SOURCE_DIR)/postinst $(CUPS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(CUPS_SOURCE_DIR)/prerm $(CUPS_IPK_DIR)/CONTROL/prerm
	echo $(CUPS_CONFFILES) | sed -e 's/ /\n/g' > $(CUPS_IPK_DIR)/CONTROL/conffiles
	$(MAKE) $(CUPS_IPK_DIR)-dev/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-dev

$(CUPS_BUILD_DIR)/.locales: $(CUPS_BUILD_DIR)/.built
	rm -f $@
	for l in `find builds/cups/install/opt/share/locale/ -mindepth 1 -type d | xargs -l1 basename`; do \
	    p=`echo $$l | tr [A-Z_] [a-z-]`; \
	    rm -rf $(CUPS_IPK_DIR)-locale-$$p \
		$(BUILD_DIR)/cups-locale-$${p}_*_$(TARGET_ARCH).ipk; \
	    install -d $(CUPS_IPK_DIR)-locale-$$p/opt/share/locale/; \
	    cp -rf $(@D)/install/opt/share/locale/$$l \
		$(CUPS_IPK_DIR)-locale-$$p/opt/share/locale/; \
	    install -d $(CUPS_IPK_DIR)-locale-$$p/opt/share/doc/cups/$$l; \
	    cp -rf $(@D)/install/opt/share/doc/cups/$$l \
		$(CUPS_IPK_DIR)-locale-$$p/opt/share/doc/cups/; \
	    install -d $(CUPS_IPK_DIR)-locale-$$p/opt/share/cups/templates; \
	    cp -rf $(@D)/install/opt/share/cups/templates/$$l \
		$(CUPS_IPK_DIR)-locale-$$p/opt/share/cups/templates/; \
	    $(MAKE) $(CUPS_IPK_DIR)-locale-$$p/CONTROL/control; \
	    cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-locale-$$p; cd -; \
	done
	touch $@

cups-locales: $(CUPS_BUILD_DIR)/.locales

$(CUPS_DOC_IPK): $(CUPS_BUILD_DIR)/.built
	rm -rf $(CUPS_IPK_DIR)-doc* $(BUILD_DIR)/cups-doc*_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)-doc
	install -d $(CUPS_IPK_DIR)-doc/opt/share/doc/cups
	install -d $(CUPS_IPK_DIR)-doc/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/man/man1 \
		$(CUPS_IPK_DIR)-doc/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/man/man5 \
		$(CUPS_IPK_DIR)-doc/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/man/man8 \
		$(CUPS_IPK_DIR)-doc/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/*.css \
		$(CUPS_IPK_DIR)-doc/opt/share/doc/cups
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/*.*html \
		$(CUPS_IPK_DIR)-doc/opt/share/doc/cups
#	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/*.pdf \
#		$(CUPS_IPK_DIR)-doc/opt/share/doc/cups
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/*.txt \
		$(CUPS_IPK_DIR)-doc/opt/share/doc/cups
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/images \
		$(CUPS_IPK_DIR)-doc/opt/share/doc/cups
	$(MAKE) $(CUPS_IPK_DIR)-doc/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-doc

#
# This is called from the top level makefile to create the IPK file.
#
cups-ipk: $(CUPS_BUILD_DIR)/.locales $(CUPS_IPK) $(CUPS_DEV_IPK) $(CUPS_DOC_IPK)

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
	$(BUILD_DIR)/cups-locale-*_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Some sanity check for the package.
#
cups-check: $(CUPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CUPS_IPK)
