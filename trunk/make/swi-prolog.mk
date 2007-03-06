###########################################################
#
# swi-prolog
#
###########################################################

#
# SWI-PROLOG_VERSION, SWI-PROLOG_SITE and SWI-PROLOG_SOURCE define
# the upstream location of the source code for the package.
# SWI-PROLOG_DIR is the directory which is created when the source
# archive is unpacked.
# SWI-PROLOG_UNZIP is the command used to unzip the source.
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
SWI-PROLOG_SITE=ftp://gollem.science.uva.nl/SWI-Prolog
SWI-PROLOG_VERSION=5.6.29
SWI-PROLOG_SOURCE=pl-$(SWI-PROLOG_VERSION).tar.gz
SWI-PROLOG_DIR=pl-$(SWI-PROLOG_VERSION)
SWI-PROLOG_UNZIP=zcat
SWI-PROLOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SWI-PROLOG_DESCRIPTION=An LGPL comprehensive portable Prolog implementation.
SWI-PROLOG_SECTION=lang
SWI-PROLOG_PRIORITY=optional
SWI-PROLOG_DEPENDS=libgmp, ncursesw, readline, zlib
SWI-PROLOG_SUGGESTS=
SWI-PROLOG_CONFLICTS=

#
# SWI-PROLOG_IPK_VERSION should be incremented when the ipk changes.
#
SWI-PROLOG_IPK_VERSION=1

#
# SWI-PROLOG_CONFFILES should be a list of user-editable files
#SWI-PROLOG_CONFFILES=/opt/etc/swi-prolog.conf /opt/etc/init.d/SXXswi-prolog

#
# SWI-PROLOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
SWI-PROLOG_PATCHES=$(SWI-PROLOG_SOURCE_DIR)/src-configure.in.patch $(SWI-PROLOG_SOURCE_DIR)/packages-plld.sh.in.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SWI-PROLOG_TARGET=$(shell $(TARGET_CC) -dumpmachine | sed 's/-.*//')-linux
SWI-PROLOG_CPPFLAGS=
SWI-PROLOG_LDFLAGS=-L$(SWI-PROLOG_BUILD_DIR)/lib/$(SWI-PROLOG_TARGET)
ifeq ($(LIBC_STYLE), uclibc)
SWI-PROLOG_LDFLAGS += -lpthread
endif

SWI-PROLOG_PL=swipl

ifeq ($(HOST_MACHINE), x86_64)
SWI-PROLOG_HOST32=--host=i586-pc-linux-gnu
SWI-PROLOG_M32=-m32
else
SWI-PROLOG_HOST32=
SWI-PROLOG_M32=
endif

#
# SWI-PROLOG_BUILD_DIR is the directory in which the build is done.
# SWI-PROLOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SWI-PROLOG_IPK_DIR is the directory in which the ipk is built.
# SWI-PROLOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SWI-PROLOG_BUILD_DIR=$(BUILD_DIR)/swi-prolog
SWI-PROLOG_SOURCE_DIR=$(SOURCE_DIR)/swi-prolog
SWI-PROLOG_IPK_DIR=$(BUILD_DIR)/swi-prolog-$(SWI-PROLOG_VERSION)-ipk
SWI-PROLOG_IPK=$(BUILD_DIR)/swi-prolog_$(SWI-PROLOG_VERSION)-$(SWI-PROLOG_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(HOSTCC), $(TARGET_CC))
SWI-PROLOG_LD_LIBRARY_PATH=LD_LIBRARY_PATH=$(STAGING_LIB_DIR)
else
SWI-PROLOG_LD_LIBRARY_PATH=LD_LIBRARY_PATH=$(SWI-PROLOG_BUILD_DIR)/hostbuild/opt/lib
endif

.PHONY: swi-prolog-source swi-prolog-unpack swi-prolog swi-prolog-stage swi-prolog-ipk swi-prolog-clean swi-prolog-dirclean swi-prolog-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SWI-PROLOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(SWI-PROLOG_SITE)/$(SWI-PROLOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
swi-prolog-source: $(DL_DIR)/$(SWI-PROLOG_SOURCE) $(SWI-PROLOG_PATCHES)

$(SWI-PROLOG_BUILD_DIR)/.unpacked: $(DL_DIR)/$(LIBGMP_SOURCE) $(DL_DIR)/$(SWI-PROLOG_SOURCE)
	rm -rf $(BUILD_DIR)/$(SWI-PROLOG_DIR) $(SWI-PROLOG_BUILD_DIR)
	$(SWI-PROLOG_UNZIP) $(DL_DIR)/$(SWI-PROLOG_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test "$(BUILD_DIR)/$(SWI-PROLOG_DIR)" != "$(SWI-PROLOG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SWI-PROLOG_DIR) $(SWI-PROLOG_BUILD_DIR) ; \
	fi
	if test -n "$(SWI-PROLOG_PATCHES)" ; then \
		cat $(SWI-PROLOG_PATCHES) | \
		patch -d $(SWI-PROLOG_BUILD_DIR) -p1 ; \
	fi
	touch $(SWI-PROLOG_BUILD_DIR)/.unpacked

$(SWI-PROLOG_BUILD_DIR)/.hostbuilt: $(SWI-PROLOG_BUILD_DIR)/.unpacked
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) libgmp-host-stage
	@echo "=============== host swi-prolog ============"
	mkdir -p $(SWI-PROLOG_BUILD_DIR)/hostbuild
	$(SWI-PROLOG_UNZIP) $(DL_DIR)/$(SWI-PROLOG_SOURCE) | tar -C $(SWI-PROLOG_BUILD_DIR)/hostbuild -xf -
	( \
	    cd $(SWI-PROLOG_BUILD_DIR)/hostbuild/$(SWI-PROLOG_DIR); \
	    cp $(SWI-PROLOG_BUILD_DIR)/packages/plld.sh.in packages/; \
	    CIFLAGS="$(SWI-PROLOG_M32) -I$(HOST_STAGING_INCLUDE_DIR)" \
	    LDFLAGS="$(SWI-PROLOG_M32) -L$(HOST_STAGING_LIB_DIR)" \
	    ac_cv_lib_ncursesw_main=no \
	    ./configure \
		--prefix=/opt $(SWI-PROLOG_HOST32) \
		--disable-readline \
		--disable-nls \
		--disable-shared; \
	)
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR)/hostbuild/$(SWI-PROLOG_DIR)/src parms.h \
		LNLIBS="-ldl -lm -lrt -lgmp -lncurses -lreadline" \
		CMFLAGS="-fPIC" \
		CIFLAGS="-O2 -pipe -I$(STAGING_INCLUDE_DIR)" \
		LDFLAGS="-O2 $(STAGING_LDFLAGS) $(SWI-PROLOG_LDFLAGS)"
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR)/hostbuild/$(SWI-PROLOG_DIR) all install DESTDIR=$(SWI-PROLOG_BUILD_DIR)/hostbuild
endif
	touch $(SWI-PROLOG_BUILD_DIR)/.hostbuilt

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
$(SWI-PROLOG_BUILD_DIR)/.configured: $(DL_DIR)/$(SWI-PROLOG_SOURCE) $(SWI-PROLOG_PATCHES) $(SWI-PROLOG_BUILD_DIR)/.hostbuilt 
	@echo "=============== target swi-prolog configure ============"
	$(MAKE) libgmp-stage ncurses-stage ncursesw-stage openssl-stage readline-stage zlib-stage
ifneq ($(HOSTCC), $(TARGET_CC))
ifeq ($(LIBC_STYLE), uclibc)
	sed -i -e '/ac_pthread_cpuclocks=/s/yes/no/g' $(SWI-PROLOG_BUILD_DIR)/src/configure.in
endif
	(cd $(SWI-PROLOG_BUILD_DIR)/src; autoconf)
endif
	(cd $(SWI-PROLOG_BUILD_DIR); \
		PL=$(SWI-PROLOG_PL) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SWI-PROLOG_CPPFLAGS)" \
		CIFLAGS="$(STAGING_CPPFLAGS) $(SWI-PROLOG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SWI-PROLOG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
		--disable-nls \
		--disable-static \
	)
ifneq ($(HOSTCC), $(TARGET_CC))
	if test -r "$(SWI-PROLOG_SOURCE_DIR)/config.h-$(OPTWARE_TARGET)" ; then \
		cp "$(SWI-PROLOG_SOURCE_DIR)/config.h-$(OPTWARE_TARGET)" $(SWI-PROLOG_BUILD_DIR)/src/config.h; \
	fi
	cp $(SWI-PROLOG_BUILD_DIR)/hostbuild/$(SWI-PROLOG_DIR)/src/pl.sh $(SWI-PROLOG_BUILD_DIR)/src
	cp $(SWI-PROLOG_BUILD_DIR)/hostbuild/$(SWI-PROLOG_DIR)/packages/pl*.sh $(SWI-PROLOG_BUILD_DIR)/packages
endif
#	$(PATCH_LIBTOOL) $(SWI-PROLOG_BUILD_DIR)/libtool
	touch $(SWI-PROLOG_BUILD_DIR)/.configured

swi-prolog-unpack: $(SWI-PROLOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
$(SWI-PROLOG_BUILD_DIR)/.built: $(SWI-PROLOG_BUILD_DIR)/.configured
	rm -f $(SWI-PROLOG_BUILD_DIR)/.built
	@echo "=============== target swi-prolog build ============"
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR)
	touch $(SWI-PROLOG_BUILD_DIR)/.built

$(SWI-PROLOG_BUILD_DIR)/.packages-built: $(SWI-PROLOG_BUILD_DIR)/.built
	rm -f $(SWI-PROLOG_BUILD_DIR)/.packages-built
	@echo "=============== target swi-prolog packages ============"
	(cd $(SWI-PROLOG_BUILD_DIR)/packages; \
		sed -i -e "s|bdir/plld -pl|bdir/plld -cc $(TARGET_CC) -ld $(TARGET_CC) -pl|" plld.sh; \
		sed -i -e '/cd.*configure)/s|)$$| --build=$(GNU_HOST_NAME) --host=$(GNU_TARGET_NAME) --target=$(GNU_TARGET_NAME))|' clib/configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SWI-PROLOG_CPPFLAGS)" \
		CIFLAGS="$(STAGING_CPPFLAGS) $(SWI-PROLOG_CPPFLAGS)" \
		LDFLAGS="-O2 $(STAGING_LDFLAGS) $(SWI-PROLOG_LDFLAGS)" \
		ac_cv_lib_ssl_SSL_library_init=yes \
		ac_cv_lib_crypto_main=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-jpl \
		--without-odbc \
		--without-xpce \
		; \
	)
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR)/packages LDFLAGS="-shared -O2 $(STAGING_LDFLAGS) $(SWI-PROLOG_LDFLAGS)"
	touch $(SWI-PROLOG_BUILD_DIR)/.packages-built

#
# This is the build convenience target.
#
swi-prolog: $(SWI-PROLOG_BUILD_DIR)/.packages-built

#
# If you are building a library, then you need to stage it too.
#
$(SWI-PROLOG_BUILD_DIR)/.staged: $(SWI-PROLOG_BUILD_DIR)/.built
	rm -f $(SWI-PROLOG_BUILD_DIR)/.staged
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SWI-PROLOG_BUILD_DIR)/.staged

swi-prolog-stage: $(SWI-PROLOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/swi-prolog
#
$(SWI-PROLOG_IPK_DIR)/CONTROL/control:
	@install -d $(SWI-PROLOG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: swi-prolog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SWI-PROLOG_PRIORITY)" >>$@
	@echo "Section: $(SWI-PROLOG_SECTION)" >>$@
	@echo "Version: $(SWI-PROLOG_VERSION)-$(SWI-PROLOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SWI-PROLOG_MAINTAINER)" >>$@
	@echo "Source: $(SWI-PROLOG_SITE)/$(SWI-PROLOG_SOURCE)" >>$@
	@echo "Description: $(SWI-PROLOG_DESCRIPTION)" >>$@
	@echo "Depends: $(SWI-PROLOG_DEPENDS)" >>$@
	@echo "Suggests: $(SWI-PROLOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(SWI-PROLOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SWI-PROLOG_IPK_DIR)/opt/sbin or $(SWI-PROLOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SWI-PROLOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SWI-PROLOG_IPK_DIR)/opt/etc/swi-prolog/...
# Documentation files should be installed in $(SWI-PROLOG_IPK_DIR)/opt/doc/swi-prolog/...
# Daemon startup scripts should be installed in $(SWI-PROLOG_IPK_DIR)/opt/etc/init.d/S??swi-prolog
#
# You may need to patch your application to make it use these locations.
#
$(SWI-PROLOG_IPK): $(SWI-PROLOG_BUILD_DIR)/.packages-built
	rm -rf $(SWI-PROLOG_IPK_DIR) $(BUILD_DIR)/swi-prolog_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR) install DESTDIR=$(SWI-PROLOG_IPK_DIR)
	$(STRIP_COMMAND) $(SWI-PROLOG_IPK_DIR)/opt/lib/$(SWI-PROLOG_PL)-$(SWI-PROLOG_VERSION)/bin/$(SWI-PROLOG_TARGET)/*pl*
	$(MAKE) -C $(SWI-PROLOG_BUILD_DIR)/packages install DESTDIR=$(SWI-PROLOG_IPK_DIR)
	$(STRIP_COMMAND) $(SWI-PROLOG_IPK_DIR)/opt/lib/$(SWI-PROLOG_PL)-$(SWI-PROLOG_VERSION)/lib/$(SWI-PROLOG_TARGET)/*.so
	rm $(SWI-PROLOG_IPK_DIR)/opt/lib/$(SWI-PROLOG_PL)-$(SWI-PROLOG_VERSION)/lib/$(SWI-PROLOG_TARGET)/lib*.a
	install -d $(SWI-PROLOG_IPK_DIR)/opt/share/doc/swi-prolog/demo
	install -m 644 $(SWI-PROLOG_BUILD_DIR)/demo/* $(SWI-PROLOG_IPK_DIR)/opt/share/doc/swi-prolog/demo
#	install -d $(SWI-PROLOG_IPK_DIR)/opt/etc/
#	install -m 644 $(SWI-PROLOG_SOURCE_DIR)/swi-prolog.conf $(SWI-PROLOG_IPK_DIR)/opt/etc/swi-prolog.conf
#	install -d $(SWI-PROLOG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SWI-PROLOG_SOURCE_DIR)/rc.swi-prolog $(SWI-PROLOG_IPK_DIR)/opt/etc/init.d/SXXswi-prolog
	$(MAKE) $(SWI-PROLOG_IPK_DIR)/CONTROL/control
#	install -m 755 $(SWI-PROLOG_SOURCE_DIR)/postinst $(SWI-PROLOG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SWI-PROLOG_SOURCE_DIR)/prerm $(SWI-PROLOG_IPK_DIR)/CONTROL/prerm
	echo $(SWI-PROLOG_CONFFILES) | sed -e 's/ /\n/g' > $(SWI-PROLOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SWI-PROLOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
swi-prolog-ipk: $(SWI-PROLOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
swi-prolog-clean:
	rm -f $(SWI-PROLOG_BUILD_DIR)/.built
	-$(MAKE) -C $(SWI-PROLOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
swi-prolog-dirclean:
	rm -rf $(BUILD_DIR)/$(SWI-PROLOG_DIR) $(SWI-PROLOG_BUILD_DIR) $(SWI-PROLOG_IPK_DIR) $(SWI-PROLOG_IPK)

#
# Some sanity check for the package.
#
swi-prolog-check: $(SWI-PROLOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SWI-PROLOG_IPK)
