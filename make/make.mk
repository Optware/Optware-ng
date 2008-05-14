###########################################################
#
# make
#
###########################################################

# You must replace "make" and "MAKE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MAKE_VERSION, MAKE_SITE and MAKE_SOURCE define
# the upstream location of the source code for the package.
# MAKE_DIR is the directory which is created when the source
# archive is unpacked.
# MAKE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MAKE_SITE=http://ftp.gnu.org/pub/gnu/make
MAKE_VERSION=3.81
MAKE_SOURCE=make-$(MAKE_VERSION).tar.bz2
MAKE_DIR=make-$(MAKE_VERSION)
MAKE_UNZIP=bzcat
MAKE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MAKE_DESCRIPTION=examines files and runs commands necessary for compilation
MAKE_SECTION=util
MAKE_PRIORITY=optional
MAKE_DEPENDS=
MAKE_CONFLICTS=


#
# MAKE_IPK_VERSION should be incremented when the ipk changes.
#
MAKE_IPK_VERSION=2

#
# MAKE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MAKE_PATCHES=$(MAKE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MAKE_CPPFLAGS=
MAKE_LDFLAGS=

#
# MAKE_BUILD_DIR is the directory in which the build is done.
# MAKE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MAKE_IPK_DIR is the directory in which the ipk is built.
# MAKE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MAKE_BUILD_DIR=$(BUILD_DIR)/make
MAKE_SOURCE_DIR=$(SOURCE_DIR)/make
MAKE_IPK_DIR=$(BUILD_DIR)/make-$(MAKE_VERSION)-ipk
MAKE_IPK=$(BUILD_DIR)/make_$(MAKE_VERSION)-$(MAKE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MAKE_SOURCE):
	$(WGET) -P $(@D) $(MAKE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
make-source: $(DL_DIR)/$(MAKE_SOURCE) $(MAKE_PATCHES)

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
$(MAKE_BUILD_DIR)/.configured: $(DL_DIR)/$(MAKE_SOURCE) $(MAKE_PATCHES) make/make.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MAKE_DIR) $(@D)
	$(MAKE_UNZIP) $(DL_DIR)/$(MAKE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MAKE_PATCHES) | patch -d $(BUILD_DIR)/$(MAKE_DIR) -p1
	mv $(BUILD_DIR)/$(MAKE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MAKE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MAKE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-rpath \
		--disable-nls \
		--disable-static \
	)
	touch $@

make-unpack: $(MAKE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(MAKE_BUILD_DIR)/.built: $(MAKE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
make: $(MAKE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libmake.so.$(MAKE_VERSION): $(MAKE_BUILD_DIR)/libmake.so.$(MAKE_VERSION)
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(MAKE_BUILD_DIR)/make.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(MAKE_BUILD_DIR)/libmake.a $(STAGING_DIR)/opt/lib
	install -m 644 $(MAKE_BUILD_DIR)/libmake.so.$(MAKE_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libmake.so.$(MAKE_VERSION) libmake.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libmake.so.$(MAKE_VERSION) libmake.so

make-stage: $(STAGING_DIR)/opt/lib/libmake.so.$(MAKE_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/make
# 
$(MAKE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: make" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MAKE_PRIORITY)" >>$@
	@echo "Section: $(MAKE_SECTION)" >>$@
	@echo "Version: $(MAKE_VERSION)-$(MAKE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MAKE_MAINTAINER)" >>$@
	@echo "Source: $(MAKE_SITE)/$(MAKE_SOURCE)" >>$@
	@echo "Description: $(MAKE_DESCRIPTION)" >>$@
	@echo "Depends: $(MAKE_DEPENDS)" >>$@
	@echo "Conflicts: $(MAKE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MAKE_IPK_DIR)/opt/sbin or $(MAKE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MAKE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MAKE_IPK_DIR)/opt/etc/make/...
# Documentation files should be installed in $(MAKE_IPK_DIR)/opt/doc/make/...
# Daemon startup scripts should be installed in $(MAKE_IPK_DIR)/opt/etc/init.d/S??make
#
# You may need to patch your application to make it use these locations.
#
$(MAKE_IPK): $(MAKE_BUILD_DIR)/.built
	rm -rf $(MAKE_IPK_DIR) $(MAKE_IPK)
	$(MAKE) -C $(MAKE_BUILD_DIR) DESTDIR=$(MAKE_IPK_DIR) install-strip
#	install -d $(MAKE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MAKE_SOURCE_DIR)/rc.make $(MAKE_IPK_DIR)/opt/etc/init.d/SXXmake
	$(MAKE) $(MAKE_IPK_DIR)/CONTROL/control
#	install -m 644 $(MAKE_SOURCE_DIR)/postinst $(MAKE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(MAKE_SOURCE_DIR)/prerm $(MAKE_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MAKE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
make-ipk: $(MAKE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
make-clean:
	-$(MAKE) -C $(MAKE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
make-dirclean:
	rm -rf $(BUILD_DIR)/$(MAKE_DIR) $(MAKE_BUILD_DIR) $(MAKE_IPK_DIR) $(MAKE_IPK)

#
# Some sanity check for the package.
#
make-check: $(MAKE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MAKE_IPK)
