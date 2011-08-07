###########################################################
#
# libdb52
#
###########################################################
#
# LIBDB52_VERSION, LIBDB52_SITE and LIBDB52_SOURCE define
# the upstream location of the source code for the package.
# LIBDB52_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDB52_UNZIP is the command used to unzip the source.
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
LIBDB52_SITE=http://download.oracle.com/berkeley-db
LIBDB52_VERSION=5.2.28
LIBDB52_SOURCE=db-$(LIBDB52_VERSION).tar.gz
LIBDB52_DIR=db-$(LIBDB52_VERSION)
LIBDB52_UNZIP=zcat
LIBDB52_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDB52_DESCRIPTION=Describe libdb52 here.
LIBDB52_SECTION=lib
LIBDB52_PRIORITY=optional
LIBDB52_DEPENDS=
LIBDB52_SUGGESTS=
LIBDB52_CONFLICTS=

#
# LIBDB52_IPK_VERSION should be incremented when the ipk changes.
#
LIBDB52_IPK_VERSION=1

#
# LIBDB52_CONFFILES should be a list of user-editable files
#LIBDB52_CONFFILES=/opt/etc/libdb52.conf /opt/etc/init.d/SXXlibdb52

#
# LIBDB52_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDB52_PATCHES=$(LIBDB52_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDB52_CPPFLAGS=
LIBDB52_LDFLAGS=
LIBDB52_MUTEX=$(strip \
	$(if $(filter arm armeb, $(TARGET_ARCH)), --with-mutex=ARM/gcc-assembly, \
	$(if $(filter powerpc ppc, $(TARGET_ARCH)), --with-mutex=PPC/gcc-assembly, \
	$(if $(filter x86 i386 i686, $(TARGET_ARCH)), --with-mutex=x86/gcc-assembly, \
	))) \
)

#
# LIBDB52_BUILD_DIR is the directory in which the build is done.
# LIBDB52_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDB52_IPK_DIR is the directory in which the ipk is built.
# LIBDB52_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDB52_BUILD_DIR=$(BUILD_DIR)/libdb52
LIBDB52_SOURCE_DIR=$(SOURCE_DIR)/libdb52
LIBDB52_IPK_DIR=$(BUILD_DIR)/libdb52-$(LIBDB52_VERSION)-ipk
LIBDB52_IPK=$(BUILD_DIR)/libdb52_$(LIBDB52_VERSION)-$(LIBDB52_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdb52-source libdb52-unpack libdb52 libdb52-stage libdb52-ipk libdb52-clean libdb52-dirclean libdb52-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDB52_SOURCE):
	$(WGET) -P $(@D) $(LIBDB52_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdb52-source: $(DL_DIR)/$(LIBDB52_SOURCE) $(LIBDB52_PATCHES)

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
$(LIBDB52_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDB52_SOURCE) $(LIBDB52_PATCHES) make/libdb52.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBDB52_DIR) $(@D)
	$(LIBDB52_UNZIP) $(DL_DIR)/$(LIBDB52_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDB52_PATCHES)" ; \
		then cat $(LIBDB52_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBDB52_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDB52_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBDB52_DIR) $(@D) ; \
	fi
	(cd $(@D)/build_unix; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDB52_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDB52_LDFLAGS)" \
		../dist/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--includedir=/opt/include/db5 \
		--enable-compat185 \
		$(LIBDB52_MUTEX) \
		--with-uniquename \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/LN.*-s .*libso_default/d' $(@D)/build_unix/Makefile
	$(PATCH_LIBTOOL) $(@D)/build_unix/libtool
	touch $@

libdb52-unpack: $(LIBDB52_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDB52_BUILD_DIR)/.built: $(LIBDB52_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/build_unix
	touch $@

#
# This is the build convenience target.
#
libdb52: $(LIBDB52_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDB52_BUILD_DIR)/.staged: $(LIBDB52_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/build_unix DESTDIR=$(STAGING_DIR) \
		install_setup install_include install_lib # install_utilities
	rm -f $(STAGING_LIB_DIR)/libdb-5.2.la
	touch $@

libdb52-stage: $(LIBDB52_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdb52
#
$(LIBDB52_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdb52" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDB52_PRIORITY)" >>$@
	@echo "Section: $(LIBDB52_SECTION)" >>$@
	@echo "Version: $(LIBDB52_VERSION)-$(LIBDB52_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDB52_MAINTAINER)" >>$@
	@echo "Source: $(LIBDB52_SITE)/$(LIBDB52_SOURCE)" >>$@
	@echo "Description: $(LIBDB52_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDB52_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDB52_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDB52_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDB52_IPK_DIR)/opt/sbin or $(LIBDB52_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDB52_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDB52_IPK_DIR)/opt/etc/libdb52/...
# Documentation files should be installed in $(LIBDB52_IPK_DIR)/opt/doc/libdb52/...
# Daemon startup scripts should be installed in $(LIBDB52_IPK_DIR)/opt/etc/init.d/S??libdb52
#
# You may need to patch your application to make it use these locations.
#
$(LIBDB52_IPK): $(LIBDB52_BUILD_DIR)/.built
	rm -rf $(LIBDB52_IPK_DIR) $(BUILD_DIR)/libdb52_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDB52_BUILD_DIR)/build_unix DESTDIR=$(LIBDB52_IPK_DIR) \
		install_setup install_include install_lib # install_utilities
	$(STRIP_COMMAND) $(LIBDB52_IPK_DIR)/opt/lib/libdb-5.2.so
	$(MAKE) $(LIBDB52_IPK_DIR)/CONTROL/control
	echo $(LIBDB52_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDB52_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDB52_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBDB52_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdb52-ipk: $(LIBDB52_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdb52-clean:
	rm -f $(LIBDB52_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDB52_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdb52-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDB52_DIR) $(LIBDB52_BUILD_DIR) $(LIBDB52_IPK_DIR) $(LIBDB52_IPK)
#
#
# Some sanity check for the package.
#
libdb52-check: $(LIBDB52_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
