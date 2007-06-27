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
CUPS_VERSION=1.2.10
CUPS_SITE=ftp://ftp3.easysw.com/pub/cups/$(CUPS_VERSION)
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
CUPS_IPK_VERSION=2

CUPS_DOC_DESCRIPTION=Common Unix Printing System documentation.
CUPS_DOC_PL_DESCRIPTION=Polish documentation for CUPS
CUPS_DOC_FR_DESCRIPTION=French documentation for CUPS
CUPS_DOC_ES_DESCRIPTION=Spanish documentation for CUPS
CUPS_DOC_DE_DESCRIPTION=German documentation for CUPS

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
CUPS_LDFLAGS=

#
# CUPS_BUILD_DIR is the directory in which the build is done.
# CUPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUPS_IPK_DIR is the directory in which the ipk is built.
# CUPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUPS_BUILD_DIR=$(BUILD_DIR)/cups
CUPS_SOURCE_DIR=$(SOURCE_DIR)/cups
CUPS_IPK_DIR=$(BUILD_DIR)/cups-$(CUPS_VERSION)-ipk
CUPS_IPK=$(BUILD_DIR)/cups_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_IPK=$(BUILD_DIR)/cups-doc_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_FR_IPK=$(BUILD_DIR)/cups-doc-fr_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_ES_IPK=$(BUILD_DIR)/cups-doc-es_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_PL_IPK=$(BUILD_DIR)/cups-doc-pl_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk
CUPS_DOC_DE_IPK=$(BUILD_DIR)/cups-doc-de_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

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
$(CUPS_BUILD_DIR)/.configured: $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_PATCHES)
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

	touch $(CUPS_BUILD_DIR)/.configured

cups-unpack: $(CUPS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CUPS_BUILD_DIR)/.built: $(CUPS_BUILD_DIR)/.configured
	rm -f $(CUPS_BUILD_DIR)/.built
	$(MAKE) -C $(CUPS_BUILD_DIR)
	$(MAKE) install -C $(CUPS_BUILD_DIR) \
	BUILDROOT=$(CUPS_BUILD_DIR)/install/ INSTALL_BIN="install -m 755"
	touch $(CUPS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
cups: $(CUPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libcups.so.$(CUPS_VERSION): $(CUPS_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include/cups
	install -d $(STAGING_DIR)/opt/include/filter
	install -m 644 $(CUPS_BUILD_DIR)/cups/*.h \
		$(STAGING_DIR)/opt/include/cups
	install -m 644 $(CUPS_BUILD_DIR)/filter/*.h \
		$(STAGING_DIR)/opt/include/cups
	install -d $(STAGING_DIR)/opt/lib
	install -m 755 $(CUPS_BUILD_DIR)/install/opt/bin/cups-config \
		$(STAGING_DIR)/opt/bin
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

cups-stage: $(STAGING_DIR)/opt/lib/libcups.so.$(CUPS_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cups
#
$(CUPS_IPK_DIR)/CONTROL/control:
	@install -d $(CUPS_IPK_DIR)/CONTROL
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
	@install -d $(CUPS_IPK_DIR)-doc/CONTROL
	@rm -f $@
	@echo "Package: cups-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DOC_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_CONFLICTS)" >>$@

$(CUPS_IPK_DIR)-doc-pl/CONTROL/control:
	@install -d $(CUPS_IPK_DIR)-doc-pl/CONTROL
	@rm -f $@
	@echo "Package: cups-doc-pl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DOC_PL_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_CONFLICTS)" >>$@

$(CUPS_IPK_DIR)-doc-de/CONTROL/control:
	@install -d $(CUPS_IPK_DIR)-doc-de/CONTROL
	@rm -f $@
	@echo "Package: cups-doc-de" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DOC_DE_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_CONFLICTS)" >>$@

$(CUPS_IPK_DIR)-doc-es/CONTROL/control:
	@install -d $(CUPS_IPK_DIR)-doc-es/CONTROL
	@rm -f $@
	@echo "Package: cups-doc-es" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DOC_ES_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_CONFLICTS)" >>$@

$(CUPS_IPK_DIR)-doc-fr/CONTROL/control:
	@install -d $(CUPS_IPK_DIR)-doc-fr/CONTROL
	@rm -f $@
	@echo "Package: cups-doc-fr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_SECTION)" >>$@
	@echo "Version: $(CUPS_VERSION)-$(CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_SITE)/$(CUPS_SOURCE)" >>$@
	@echo "Description: $(CUPS_DOC_FR_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_CONFLICTS)" >>$@

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
$(CUPS_IPK): $(CUPS_BUILD_DIR)/.built
	rm -rf $(CUPS_IPK_DIR) $(BUILD_DIR)/cups_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)
# Make sure /opt/var/spool has correct permissions
	install -m 0755 -d $(CUPS_IPK_DIR)/opt/var/spool
	cp -rf $(CUPS_BUILD_DIR)/install/* $(CUPS_IPK_DIR)
	rm -f $(CUPS_IPK_DIR)/opt/lib/*.a
	rm -rf $(CUPS_IPK_DIR)/etc
	rm -rf $(CUPS_IPK_DIR)/opt/share/doc/cups
	rm -rf $(CUPS_IPK_DIR)/opt/man
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
	$(MAKE) $(CUPS_IPK_DIR)/CONTROL/control
#	install -m 644 $(CUPS_SOURCE_DIR)/postinst $(CUPS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(CUPS_SOURCE_DIR)/prerm $(CUPS_IPK_DIR)/CONTROL/prerm
	echo $(CUPS_CONFFILES) | sed -e 's/ /\n/g' > \
		$(CUPS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)

$(CUPS_DOC_DE_IPK): $(CUPS_BUILD_DIR)/.built
	# German
	rm -rf $(CUPS_IPK_DIR)-doc-de \
		$(BUILD_DIR)/cups-doc-de_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)-doc-de
	install -d $(CUPS_IPK_DIR)-doc-de/opt/share/doc/cups/de
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/de \
		$(CUPS_IPK_DIR)-doc-de/opt/share/doc/cups
	$(MAKE) $(CUPS_IPK_DIR)-doc-de/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-doc-de

$(CUPS_DOC_PL_IPK): $(CUPS_BUILD_DIR)/.built
	# Polish
	rm -rf $(CUPS_IPK_DIR)-doc-pl \
		$(BUILD_DIR)/cups-doc-pl_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)-doc-pl
	install -d $(CUPS_IPK_DIR)-doc-pl/opt/share/doc/cups/pl
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/pl \
		$(CUPS_IPK_DIR)-doc-pl/opt/share/doc/cups
	$(MAKE) $(CUPS_IPK_DIR)-doc-pl/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-doc-pl

$(CUPS_DOC_FR_IPK): $(CUPS_BUILD_DIR)/.built
	# French
	rm -rf $(CUPS_IPK_DIR)-doc-fr $(BUILD_DIR)/cups-doc-fr_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)-doc-fr
	install -d $(CUPS_IPK_DIR)-doc-fr/opt/share/doc/cups/fr
	install -d $(CUPS_IPK_DIR)-doc-fr/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/man $(CUPS_IPK_DIR)-doc-fr/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/fr \
		$(CUPS_IPK_DIR)-doc-fr/opt/share/doc/cups
	$(MAKE) $(CUPS_IPK_DIR)-doc-fr/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-doc-fr

$(CUPS_DOC_ES_IPK): $(CUPS_BUILD_DIR)/.built
	# Spanish
	rm -rf $(CUPS_IPK_DIR)-doc-es \
		$(BUILD_DIR)/cups-doc-es_*_$(TARGET_ARCH).ipk
	install -d $(CUPS_IPK_DIR)-doc-es
	install -d $(CUPS_IPK_DIR)-doc-es/opt/share/doc/cups/es
	install -d $(CUPS_IPK_DIR)-doc-es/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/man $(CUPS_IPK_DIR)-doc-es/opt/man
	cp -rf $(CUPS_BUILD_DIR)/install/opt/share/doc/cups/es \
		$(CUPS_IPK_DIR)-doc-es/opt/share/doc/cups
	$(MAKE) $(CUPS_IPK_DIR)-doc-es/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)-doc-es

$(CUPS_DOC_IPK): $(CUPS_BUILD_DIR)/.built
	# English
	rm -rf $(CUPS_IPK_DIR)-doc $(BUILD_DIR)/cups-doc_*_$(TARGET_ARCH).ipk
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
cups-ipk: $(CUPS_IPK) $(CUPS_DOC_IPK)  $(CUPS_DOC_DE_IPK)  \
		$(CUPS_DOC_ES_IPK) $(CUPS_DOC_DE_IPK) 

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
	rm -rf $(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR) \
		$(CUPS_IPK_DIR) $(CUPS_IPK) \
		$(CUPS_DOC_IPK) $(CUPS_DOC_DE_IPK) $(CUPS_DOC_FR_IPK)\
		$(CUPS_DOC_ES_IPK) $(CUPS_DOC_PL_IPK) \
		$(CUPS_IPK_DIR)-doc $(CUPS_IPK_DIR)-doc-de \
		$(CUPS_IPK_DIR)-doc-fr $(CUPS_IPK_DIR)-doc-es \
		$(CUPS_IPK_DIR)-doc-pl

#
# Some sanity check for the package.
#
cups-check: $(CUPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CUPS_IPK)
