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
GCC_UNZIP=bzcat
GCC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GCC_DESCRIPTION=The GNU Compiler Collection.
GCC_SECTION=base
GCC_PRIORITY=optional
GCC_DEPENDS=binutils, libc-dev
GCC_SUGGESTS=
GCC_CONFLICTS=

#
# GCC_IPK_VERSION should be incremented when the ipk changes.
#
GCC_IPK_VERSION ?= 5

#
# GCC_CONFFILES should be a list of user-editable files
#GCC_CONFFILES=/opt/etc/gcc.conf /opt/etc/init.d/SXXgcc

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

GCC_BUILD_EXTRA_ENV ?=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GCC_CPPFLAGS=
GCC_LDFLAGS=

GCC_IPK_DIR=$(BUILD_DIR)/gcc-$(GCC_VERSION)-ipk
GCC_IPK=$(BUILD_DIR)/gcc_$(GCC_VERSION)-$(GCC_IPK_VERSION)_$(TARGET_ARCH).ipk

GCC_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gcc
GCC_HOST_PROGRAM_SUFFIX:=$(shell echo $(GCC_VERSION) | sed 's/\([^.]*\)[.]*\([^.]*\).*/\1.\2/')
GCC_HOST_TOOL_SUFFIX:=$(shell echo $(GCC_VERSION) | sed 's/\([^.]*\)[.]*\([^.]*\).*/\1\2/')

GCC_TARGET_NAME=$(strip \
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
ifeq ($(GCC_DIR), gcc-$(GCC_VERSION))
$(DL_DIR)/$(GCC_SOURCE):
	$(WGET) -P $(@D) $(GCC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gcc-source: $(DL_DIR)/$(GCC_SOURCE) $(GCC_PATCHES)


$(GCC_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GCC_SOURCE) make/gcc.mk
	rm -rf $(HOST_BUILD_DIR)/$(GCC_DIR) $(@D)
	$(GCC_UNZIP) $(DL_DIR)/$(GCC_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(GCC_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--program-suffix="-$(GCC_HOST_PROGRAM_SUFFIX)" \
		--enable-languages=c,c++ \
	)
	$(MAKE) -C $(@D)
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
	rm -rf $(BUILD_DIR)/$(GCC_DIR) $(@D)
	$(GCC_UNZIP) $(DL_DIR)/$(GCC_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(GCC_PATCHES)" ; \
		then cat `echo $(GCC_PATCHES) | sort` | \
		patch -d $(BUILD_DIR)/$(GCC_DIR) -p1 ; \
	fi
	mkdir -p $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GCC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GCC_LDFLAGS)" \
		../$(GCC_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GCC_TARGET_NAME) \
		--target=$(GCC_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-as=$(TARGET_AS) \
		--with-ld=$(TARGET_LD) \
		--enable-languages=c,c++ \
		--disable-multilib \
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
	@install -d $(@D)
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(GCC_IPK_DIR)/opt/sbin or $(GCC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GCC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GCC_IPK_DIR)/opt/etc/gcc/...
# Documentation files should be installed in $(GCC_IPK_DIR)/opt/doc/gcc/...
# Daemon startup scripts should be installed in $(GCC_IPK_DIR)/opt/etc/init.d/S??gcc
#
# You may need to patch your application to make it use these locations.
#
$(GCC_IPK): $(GCC_BUILD_DIR)/.built
	rm -rf $(GCC_IPK_DIR) $(BUILD_DIR)/gcc_*_$(TARGET_ARCH).ipk
	PATH=`dirname $(TARGET_CC)`:$(STAGING_DIR)/bin:$(PATH) \
	$(GCC_BUILD_EXTRA_ENV) \
		$(MAKE) -C $(GCC_BUILD_DIR) DESTDIR=$(GCC_IPK_DIR) install
	rm -f $(GCC_IPK_DIR)/opt/lib/libiberty.a $(GCC_IPK_DIR)/opt/info/dir $(GCC_IPK_DIR)/opt/info/dir.old
	rm -f $(GCC_IPK_DIR)/opt/lib/libstdc++.so*
ifeq (wdtv, $(OPTWARE_TARGET))
	rm -f $(GCC_IPK_DIR)/opt/lib/lib*.so* $(GCC_IPK_DIR)/opt/include/*.h
endif
	-cd $(GCC_IPK_DIR)/opt/libexec/gcc/`$(TARGET_CC) -dumpmachine`/$(GCC_VERSION); \
		$(STRIP_COMMAND) c* install-tools/fixincl
	-cd $(GCC_IPK_DIR)/opt/bin; $(STRIP_COMMAND) cpp gcc g++ gcov
	$(MAKE) $(GCC_IPK_DIR)/CONTROL/control
	echo $(GCC_CONFFILES) | sed -e 's/ /\n/g' > $(GCC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GCC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gcc-ipk: $(GCC_IPK)

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
	rm -rf $(BUILD_DIR)/$(GCC_DIR) $(GCC_BUILD_DIR) $(GCC_IPK_DIR) $(GCC_IPK)
#
#
# Some sanity check for the package.
#
gcc-check: $(GCC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GCC_IPK)
