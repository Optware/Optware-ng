###########################################################
#
# gcc
#
###########################################################

# You must replace "gcc" and "GCC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GCC_VERSION, GCC_SITE and GCC_SOURCE define
# the upstream location of the source code for the package.
# GCC_DIR is the directory which is created when the source
# archive is unpacked.
# GCC_UNZIP is the command used to unzip the source.
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
ifdef NATIVE_GCC_VERSION
GCC_VERSION=$(NATIVE_GCC_VERSION)
else
GCC_VERSION:=$(shell test -x "$(TARGET_CC)" && $(TARGET_CC) -dumpversion)
endif
GCC_SITE?=http://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VERSION)
GCC_SOURCE?=gcc-$(GCC_VERSION).tar.bz2
GCC_DIR?=gcc-$(GCC_VERSION)
GCC_UNZIP?=bzcat
GCC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GCC_DESCRIPTION=The GNU Compiler Collection. C and C++ compilers are included in the package.
GCCGO_DESCRIPTION=GNU Go Compiler.
GCC_SECTION=base
GCC_PRIORITY=optional
GCC_DEPENDS=binutils, libc-dev, libgmp, libmpfr, libmpc
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GCC_DEPENDS+=, libiconv
endif
GCCGO_DEPENDS=gcc, libgo
GCC_SUGGESTS=
GCC_CONFLICTS=
GCCGO_SUGGESTS=
GCCGO_CONFLICTS=

ifdef NATIVE_GCC_ADDITIONAL_DEPS
GCC_DEPENDS+=, $(NATIVE_GCC_ADDITIONAL_DEPS)
endif

#
# GCC_IPK_VERSION should be incremented when the ipk changes.
#
GCC_IPK_VERSION ?= 7

GCC_HOST_VERSION=7.2.0
GCC_HOST_SOURCE=gcc-$(GCC_HOST_VERSION).tar.xz
GCC_HOST_DIR=gcc-$(GCC_HOST_VERSION)
GCC_HOST_UNZIP=xzcat

#
# GCC_CONFFILES should be a list of user-editable files
#GCC_CONFFILES=$(TARGET_PREFIX)/etc/gcc.conf $(TARGET_PREFIX)/etc/init.d/SXXgcc

GCC_BUILD_DIR=$(BUILD_DIR)/gcc
GCC_SOURCE_DIR=$(SOURCE_DIR)/gcc

ifeq (nothing, $(GCC_PATCHES))
GCC_PATCHES=
else
GCC_PATCHES:=$(wildcard $(GCC_SOURCE_DIR)/$(GCC_VERSION)/*.patch)
  ifdef NATIVE_GCC_EXTRA_PATCHES
GCC_PATCHES += $(NATIVE_GCC_EXTRA_PATCHES)
  endif
endif

GCC_HOST_PATCHES=$(wildcard $(GCC_SOURCE_DIR)/host/*.patch)

GCC_LINKER ?= $(TARGET_LDFLAGS)
GCC_NATIVE_CFLAGS ?= $(TARGET_CUSTOM_FLAGS)

GCC_BUILD_EXTRA_ENV ?=

GCC_EXTRA_CONF_ENV ?=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GCC_CPPFLAGS ?=
GCC_LDFLAGS=

GCC_IPK_DIR=$(BUILD_DIR)/gcc-$(GCC_VERSION)-ipk
GCC_IPK=$(BUILD_DIR)/gcc_$(GCC_VERSION)-$(GCC_IPK_VERSION)_$(TARGET_ARCH).ipk

GCCGO_IPK_DIR=$(BUILD_DIR)/gccgo-$(GCC_VERSION)-ipk
GCCGO_IPK=$(BUILD_DIR)/gccgo_$(GCC_VERSION)-$(GCC_IPK_VERSION)_$(TARGET_ARCH).ipk

GCC_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gcc
GCC_HOST_BIN_DIR=$(GCC_HOST_BUILD_DIR)/install/bin

GCC_TARGET_NAME ?= $(strip \
$(if $(and \
	$(filter uclibc, $(LIBC_STYLE)), \
	$(filter arm-linux armeb-linux mipsel-linux, $(GNU_TARGET_NAME))), \
$(GNU_TARGET_NAME)-uclibc, $(GNU_TARGET_NAME)))

.PHONY: gcc-source gcc-unpack gcc gcc-stage gcc-ipk gcc-clean gcc-dirclean gcc-check \
gcc-host gcc-host-stage gcc33-host-tool

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GCC_SOURCE):
	$(WGET) -P $(@D) $(GCC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(GCC_HOST_SOURCE), $(GCC_SOURCE))
$(DL_DIR)/$(GCC_HOST_SOURCE):
	$(WGET) -P $(@D) $(GCC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gcc-source: $(DL_DIR)/$(GCC_SOURCE) $(GCC_PATCHES)


$(GCC_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GCC_HOST_SOURCE) $(GCC_HOST_PATCHES)
	$(MAKE) libgmp-host-stage libmpfr-host-stage libmpc-host-stage libelf-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(GCC_HOST_DIR) $(@D)
	$(GCC_HOST_UNZIP) $(DL_DIR)/$(GCC_HOST_SOURCE) | tar -C $(HOST_BUILD_DIR) -xf -
	if test -n "$(GCC_HOST_PATCHES)" ; \
		then cat `echo $(GCC_HOST_PATCHES) | sort` | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(GCC_HOST_DIR) -p1 ; \
	fi
	mv $(HOST_BUILD_DIR)/$(GCC_HOST_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=$(@D)/install	\
		--disable-shared \
		--disable-bootstrap \
		--disable-libstdcxx-pch \
		--enable-languages=c,c++,go \
		--enable-libgomp \
		--enable-lto \
		--enable-threads=posix \
		--enable-tls \
		--with-gmp=$(HOST_STAGING_PREFIX) \
		--with-mpfr=$(HOST_STAGING_PREFIX) \
		--with-mpc=$(HOST_STAGING_PREFIX) \
		--with-libelf=$(HOST_STAGING_PREFIX) \
		--with-fpmath=sse \
	)
	$(MAKE) -C $(@D)
	$(MAKE) install -C $(@D)
	mv -f $(GCC_HOST_BIN_DIR)/gccgo $(GCC_HOST_BIN_DIR)/gccgo.real
	$(INSTALL) -m 755 $(GCC_SOURCE_DIR)/host/gccgo.wrapper $(GCC_HOST_BIN_DIR)/gccgo
	touch $@

gcc-host: $(GCC_HOST_BUILD_DIR)/.built


$(GCC_HOST_BUILD_DIR)/.staged: $(GCC_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	touch $@

gcc-host-stage: $(GCC_HOST_BUILD_DIR)/.staged


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
$(GCC_BUILD_DIR)/.configured: $(DL_DIR)/$(GCC_SOURCE) $(GCC_PATCHES) #make/gcc.mk
	$(MAKE) libgmp-stage libmpfr-stage libmpc-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifdef NATIVE_GCC_ADDITIONAL_STAGE
	$(MAKE) $(NATIVE_GCC_ADDITIONAL_STAGE)
endif
	rm -rf $(BUILD_DIR)/$(GCC_DIR) $(@D)
	$(GCC_UNZIP) $(DL_DIR)/$(GCC_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(GCC_PATCHES)" ; \
		then cat `echo $(GCC_PATCHES) | sort` | \
		$(PATCH) -d $(BUILD_DIR)/$(GCC_DIR) -p1 ; \
	fi
	mkdir -p $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="-fPIC" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GCC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GCC_LDFLAGS)" \
		GCC_FOR_TARGET="$(TARGET_CC)" \
		CC_FOR_TARGET="$(TARGET_CC)" \
		CXX_FOR_TARGET="$(TARGET_CXX)" \
		$(GCC_EXTRA_CONF_ENV) \
		../$(GCC_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GCC_TARGET_NAME) \
		--target=$(GCC_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-as=$(TARGET_PREFIX)/bin/as \
		--with-ld=$(TARGET_PREFIX)/bin/ld \
		--enable-languages=c,c++,go \
		--disable-multilib \
		--disable-werror \
		$(NATIVE_GCC_EXTRA_CONFIG_ARGS) \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gcc-unpack: $(GCC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GCC_BUILD_DIR)/.built: $(GCC_BUILD_DIR)/.configured
	rm -f $@
	rm -f $(STAGING_DIR)/bin/$(GCC_TARGET_NAME)-cc
	ln -s $(TARGET_CC) $(STAGING_DIR)/bin/$(GCC_TARGET_NAME)-cc
	PATH=`dirname $(TARGET_CC)`:$(STAGING_DIR)/bin:$(PATH) \
	$(GCC_BUILD_EXTRA_ENV) \
		$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gcc: $(GCC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GCC_BUILD_DIR)/.staged: $(GCC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gcc-stage: $(GCC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gcc
#
$(GCC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gcc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GCC_PRIORITY)" >>$@
	@echo "Section: $(GCC_SECTION)" >>$@
	@echo "Version: $(GCC_VERSION)-$(GCC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GCC_MAINTAINER)" >>$@
	@echo "Source: $(GCC_SITE)/$(GCC_SOURCE)" >>$@
	@echo "Description: $(GCC_DESCRIPTION)" >>$@
	@echo "Depends: $(GCC_DEPENDS)" >>$@
	@echo "Suggests: $(GCC_SUGGESTS)" >>$@
	@echo "Conflicts: $(GCC_CONFLICTS)" >>$@

$(GCCGO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gccgo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GCC_PRIORITY)" >>$@
	@echo "Section: $(GCC_SECTION)" >>$@
	@echo "Version: $(GCC_VERSION)-$(GCC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GCC_MAINTAINER)" >>$@
	@echo "Source: $(GCC_SITE)/$(GCC_SOURCE)" >>$@
	@echo "Description: $(GCCGO_DESCRIPTION)" >>$@
	@echo "Depends: $(GCCGO_DEPENDS)" >>$@
	@echo "Suggests: $(GCCGO_SUGGESTS)" >>$@
	@echo "Conflicts: $(GCCGO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GCC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GCC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GCC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GCC_IPK_DIR)$(TARGET_PREFIX)/etc/gcc/...
# Documentation files should be installed in $(GCC_IPK_DIR)$(TARGET_PREFIX)/doc/gcc/...
# Daemon startup scripts should be installed in $(GCC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gcc
#
# You may need to patch your application to make it use these locations.
#
$(GCC_IPK) $(GCCGO_IPK): $(GCC_BUILD_DIR)/.built
	rm -rf $(GCC_IPK_DIR) $(BUILD_DIR)/gcc_*_$(TARGET_ARCH).ipk \
		$(GCCGO_IPK_DIR) $(BUILD_DIR)/gccgo_*_$(TARGET_ARCH).ipk
	PATH=`dirname $(TARGET_CC)`:$(STAGING_DIR)/bin:$(PATH) \
	$(GCC_BUILD_EXTRA_ENV) \
		$(MAKE) -C $(GCC_BUILD_DIR) DESTDIR=$(GCC_IPK_DIR) install
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/bits.c | grep -q puts.*64-bit; then \
		cd $(GCC_IPK_DIR)$(TARGET_PREFIX) && \
		mv -f lib64/* lib/ && \
		rm -rf lib64; \
	fi
	ln -s gcc $(GCC_IPK_DIR)$(TARGET_PREFIX)/bin/cc
	rm -f $(GCC_IPK_DIR)$(TARGET_PREFIX)/lib/libiberty.a \
		$(GCC_IPK_DIR)$(TARGET_PREFIX)/share/info/dir \
		$(GCC_IPK_DIR)$(TARGET_PREFIX)/lib/libstdc++.so* \
		$(GCC_IPK_DIR)$(TARGET_PREFIX)/lib/libgcc_s.so* \
		$(GCC_IPK_DIR)$(TARGET_PREFIX)/lib/libgo.so*
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/bin; $(STRIP_COMMAND) cpp c++ gcc g++ gcov gccgo
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/libexec/gcc/$(GCC_TARGET_NAME)/$(GCC_VERSION); \
		$(STRIP_COMMAND) cc1 cc1plus collect2 go1 install-tools/fixincl
	###
	### install gccgo package files
	###
	$(INSTALL) -d $(GCCGO_IPK_DIR)$(TARGET_PREFIX)/bin $(GCCGO_IPK_DIR)$(TARGET_PREFIX)/lib \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/share/man/man1 \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/share/info \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/libexec/gcc/$(GCC_TARGET_NAME)/$(GCC_VERSION)
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/bin; mv -f $(GCC_TARGET_NAME)-gccgo gccgo \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/bin && \
		mv -f go $(GCCGO_IPK_DIR)$(TARGET_PREFIX)/bin/gccgo-go && \
		mv -f gofmt $(GCCGO_IPK_DIR)$(TARGET_PREFIX)/bin/gccgo-gofmt
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/lib; mv -f go libgo.la libgobegin.a libgolibbegin.a \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/share/man/man1; mv -f gccgo.1 go.1 gofmt.1 \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/share/info; mv -f gccgo.info \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/share/info
	cd $(GCC_IPK_DIR)$(TARGET_PREFIX)/libexec/gcc/$(GCC_TARGET_NAME)/$(GCC_VERSION); \
		mv -f cgo go1 \
		$(GCCGO_IPK_DIR)$(TARGET_PREFIX)/libexec/gcc/$(GCC_TARGET_NAME)/$(GCC_VERSION)
	$(MAKE) $(GCCGO_IPK_DIR)/CONTROL/control $(GCC_IPK_DIR)/CONTROL/control
	( \
		echo "update-alternatives --install $(TARGET_PREFIX)/bin/go go $(TARGET_PREFIX)/bin/gccgo-go 80"; \
		echo "update-alternatives --install $(TARGET_PREFIX)/bin/gofmt gofmt $(TARGET_PREFIX)/bin/gccgo-gofmt 80"; \
	) > $(GCCGO_IPK_DIR)/CONTROL/postinst
	( \
		echo "update-alternatives --remove go $(TARGET_PREFIX)/bin/gccgo-go"; \
		echo "update-alternatives --remove gofmt $(TARGET_PREFIX)/bin/gccgo-gofmt"; \
	) > $(GCCGO_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GCCGO_IPK_DIR)/CONTROL/postinst $(GCCGO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GCC_CONFFILES) | sed -e 's/ /\n/g' > $(GCC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GCC_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GCCGO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GCC_IPK_DIR) $(GCCGO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gcc-ipk: $(GCC_IPK) $(GCCGO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gcc-clean:
	rm -f $(GCC_BUILD_DIR)/.built
	-$(MAKE) -C $(GCC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gcc-dirclean:
	rm -rf $(BUILD_DIR)/$(GCC_DIR) $(GCC_BUILD_DIR) \
		$(GCC_IPK_DIR) $(GCC_IPK) \
		$(GCCGO_IPK_DIR) $(GCCGO_IPK)
#
#
# Some sanity check for the package.
#
gcc-check: $(GCC_IPK) $(GCCGO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
