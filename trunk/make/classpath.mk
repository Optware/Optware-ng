###########################################################
#
# classpath
#
###########################################################

# You must replace "classpath" and "CLASSPATH" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CLASSPATH_VERSION, CLASSPATH_SITE and CLASSPATH_SOURCE define
# the upstream location of the source code for the package.
# CLASSPATH_DIR is the directory which is created when the source
# archive is unpacked.
# CLASSPATH_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CLASSPATH_SITE=http://ftp.gnu.org/gnu/classpath
CLASSPATH_VERSION=0.98
CLASSPATH_SOURCE=classpath-$(CLASSPATH_VERSION).tar.gz
CLASSPATH_DIR=classpath-$(CLASSPATH_VERSION)
CLASSPATH_UNZIP=zcat
CLASSPATH_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
CLASSPATH_DESCRIPTION=GNU Classpath for java
CLASSPATH_SECTION=language
CLASSPATH_PRIORITY=optional
CLASSPATH_DEPENDS=file, libgmp
CLASSPATH_CONFLICTS=sablevm

#
# CLASSPATH_IPK_VERSION should be incremented when the ipk changes.
#
CLASSPATH_IPK_VERSION=1

#
# CLASSPATH_CONFFILES should be a list of user-editable files
#CLASSPATH_CONFFILES=/opt/etc/classpath.conf /opt/etc/init.d/SXXclasspath

#
# CLASSPATH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CLASSPATH_PATCHES=$(CLASSPATH_SOURCE_DIR)/EnumSet.java.patch
ifeq ($(OPTWARE_TARGET), $(filter syno-x07, $(OPTWARE_TARGET)))
CLASSPATH_PATCHES += $(CLASSPATH_SOURCE_DIR)/old-epoll-h.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CLASSPATH_CPPFLAGS=
CLASSPATH_LDFLAGS=

#
# CLASSPATH_BUILD_DIR is the directory in which the build is done.
# CLASSPATH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CLASSPATH_IPK_DIR is the directory in which the ipk is built.
# CLASSPATH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CLASSPATH_BUILD_DIR=$(BUILD_DIR)/classpath
CLASSPATH_SOURCE_DIR=$(SOURCE_DIR)/classpath
CLASSPATH_IPK_DIR=$(BUILD_DIR)/classpath-$(CLASSPATH_VERSION)-ipk
CLASSPATH_IPK=$(BUILD_DIR)/classpath_$(CLASSPATH_VERSION)-$(CLASSPATH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: classpath-source classpath-unpack classpath classpath-stage classpath-ipk classpath-clean classpath-dirclean classpath-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CLASSPATH_SOURCE):
	$(WGET) -P $(@D) $(CLASSPATH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

CLASSPATH_ANTLR_SITE=http://www.antlr.org/download
CLASSPATH_ANTLR_JAR=antlr-3.1.3.jar

$(DL_DIR)/$(CLASSPATH_ANTLR_JAR):
	$(WGET) -P $(@D) $(CLASSPATH_ANTLR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
classpath-source: $(DL_DIR)/$(CLASSPATH_SOURCE) $(DL_DIR)/$(CLASSPATH_ANTLR_JAR) $(CLASSPATH_PATCHES)

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
$(CLASSPATH_BUILD_DIR)/.configured: $(DL_DIR)/$(CLASSPATH_SOURCE) $(DL_DIR)/$(CLASSPATH_ANTLR_JAR) $(CLASSPATH_PATCHES) make/classpath.mk
	$(MAKE) file-stage libgmp-stage
	rm -rf $(BUILD_DIR)/$(CLASSPATH_DIR) $(@D)
	$(CLASSPATH_UNZIP) $(DL_DIR)/$(CLASSPATH_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(CLASSPATH_PATCHES)"; then \
		cat $(CLASSPATH_PATCHES) | patch -d $(BUILD_DIR)/$(CLASSPATH_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(CLASSPATH_DIR) $(@D)
	sed -i -e 's/$$JAVAC conftest/$$JAVAC $$JAVAC_OPTS conftest/' \
	       -e 's|GMP_CFLAGS=-I/usr/include|GMP_CFLAGS=-I$(STAGING_INCLUDE_DIR)|' \
	       -e 's|for ac_prog in cacao$$EXEEXT|for ac_prog in java$$EXEEXT cacao$$EXEEXT|' \
		$(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CLASSPATH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CLASSPATH_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		JAVAC_OPTS=-J-Xmx512M \
		./configure \
		--with-glibj=zip \
		--enable-jni \
		--disable-gtk-peer \
		--disable-gconf-peer \
		--disable-plugin \
		--disable-Werror \
		--enable-gmp \
		--with-antlr-jar=$(DL_DIR)/$(CLASSPATH_ANTLR_JAR) \
		--disable-examples \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		; \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

classpath-unpack: $(CLASSPATH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CLASSPATH_BUILD_DIR)/.built: $(CLASSPATH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
classpath: $(CLASSPATH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CLASSPATH_BUILD_DIR)/.staged: $(CLASSPATH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install transform="" prefix=$(STAGING_PREFIX)
	touch $@

classpath-stage: $(CLASSPATH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/classpath
#
$(CLASSPATH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: classpath" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CLASSPATH_PRIORITY)" >>$@
	@echo "Section: $(CLASSPATH_SECTION)" >>$@
	@echo "Version: $(CLASSPATH_VERSION)-$(CLASSPATH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CLASSPATH_MAINTAINER)" >>$@
	@echo "Source: $(CLASSPATH_SITE)/$(CLASSPATH_SOURCE)" >>$@
	@echo "Description: $(CLASSPATH_DESCRIPTION)" >>$@
	@echo "Depends: $(CLASSPATH_DEPENDS)" >>$@
	@echo "Conflicts: $(CLASSPATH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CLASSPATH_IPK_DIR)/opt/sbin or $(CLASSPATH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CLASSPATH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CLASSPATH_IPK_DIR)/opt/etc/classpath/...
# Documentation files should be installed in $(CLASSPATH_IPK_DIR)/opt/doc/classpath/...
# Daemon startup scripts should be installed in $(CLASSPATH_IPK_DIR)/opt/etc/init.d/S??classpath
#
# You may need to patch your application to make it use these locations.
#
$(CLASSPATH_IPK): $(CLASSPATH_BUILD_DIR)/.built
	rm -rf $(CLASSPATH_IPK_DIR) $(BUILD_DIR)/classpath_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CLASSPATH_BUILD_DIR) install-strip transform="" prefix=$(CLASSPATH_IPK_DIR)/opt
	$(MAKE) $(CLASSPATH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CLASSPATH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
classpath-ipk: $(CLASSPATH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
classpath-clean:
	-$(MAKE) -C $(CLASSPATH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
classpath-dirclean:
	rm -rf $(BUILD_DIR)/$(CLASSPATH_DIR) $(CLASSPATH_BUILD_DIR) $(CLASSPATH_IPK_DIR) $(CLASSPATH_IPK)

#
# Some sanity check for the package.
#
classpath-check: $(CLASSPATH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
