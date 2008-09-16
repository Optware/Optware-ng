###########################################################
#
# cacao
#
###########################################################
#
# CACAO_VERSION, CACAO_SITE and CACAO_SOURCE define
# the upstream location of the source code for the package.
# CACAO_DIR is the directory which is created when the source
# archive is unpacked.
# CACAO_UNZIP is the command used to unzip the source.
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
CACAO_VERSION=0.99.3
CACAO_SITE=http://www.complang.tuwien.ac.at/cacaojvm/download/cacao-$(CACAO_VERSION)
CACAO_SOURCE=cacao-$(CACAO_VERSION).tar.bz2
CACAO_DIR=cacao-$(CACAO_VERSION)
CACAO_UNZIP=bzcat
CACAO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CACAO_DESCRIPTION=A JVM with JIT compilation.
CACAO_SECTION=java
CACAO_PRIORITY=optional
CACAO_DEPENDS=classpath
CACAO_SUGGESTS=
CACAO_CONFLICTS=jamvm

#
# CACAO_IPK_VERSION should be incremented when the ipk changes.
#
CACAO_IPK_VERSION=1

#
# CACAO_CONFFILES should be a list of user-editable files
#CACAO_CONFFILES=/opt/etc/cacao.conf /opt/etc/init.d/SXXcacao

#
# CACAO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CACAO_PATCHES=$(CACAO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CACAO_CPPFLAGS=
CACAO_LDFLAGS=

ifeq ($(OPTWARE_TARGET), $(filter cs05q3armel cs08q1armel, $(OPTWARE_TARGET)))
CACAO_CONFIG_ARGS=--enable-softfloat
endif

ifeq (armeb-linux, $(GNU_TARGET_NAME))
CACAO_TARGET_NAME=arm-linux
else
CACAO_TARGET_NAME=$(GNU_TARGET_NAME)
endif

#
# CACAO_BUILD_DIR is the directory in which the build is done.
# CACAO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CACAO_IPK_DIR is the directory in which the ipk is built.
# CACAO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CACAO_SOURCE_DIR=$(SOURCE_DIR)/cacao
CACAO_BUILD_DIR=$(BUILD_DIR)/cacao
CACAO_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/cacao
CACAO_IPK_DIR=$(BUILD_DIR)/cacao-$(CACAO_VERSION)-ipk
CACAO_IPK=$(BUILD_DIR)/cacao_$(CACAO_VERSION)-$(CACAO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cacao-source cacao-unpack cacao cacao-stage cacao-ipk cacao-clean cacao-dirclean cacao-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CACAO_SOURCE):
	$(WGET) -P $(@D) $(CACAO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cacao-source: $(DL_DIR)/$(CACAO_SOURCE) $(CACAO_PATCHES)

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(CACAO_BUILD_DIR)/.configured: $(DL_DIR)/$(CACAO_SOURCE) $(CACAO_PATCHES) make/cacao.mk
else
$(CACAO_BUILD_DIR)/.configured: $(CACAO_HOST_BUILD_DIR)/.built $(CACAO_PATCHES)
endif
	$(MAKE) classpath-stage
	rm -rf $(BUILD_DIR)/$(CACAO_DIR) $(@D)
	$(CACAO_UNZIP) $(DL_DIR)/$(CACAO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CACAO_PATCHES)" ; \
		then cat $(CACAO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CACAO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CACAO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CACAO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CACAO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CACAO_LDFLAGS)" \
		JAVAC="javac -bootclasspath $(STAGING_PREFIX)/share/classpath/glibj.zip" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(CACAO_TARGET_NAME) \
		--target=$(CACAO_TARGET_NAME) \
		--prefix=/opt \
		$(CACAO_CONFIG_ARGS) \
		--with-build-java-runtime-library-classes=$(STAGING_PREFIX)/share/classpath/glibj.zip \
		--with-jni_md_h=$(STAGING_INCLUDE_DIR) \
		--with-jni_h=$(STAGING_INCLUDE_DIR) \
		--with-java-runtime-library-prefix=/opt \
		--with-cacaoh=$(CACAO_HOST_BUILD_DIR)/src/cacaoh/cacaoh \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cacao-unpack: $(CACAO_BUILD_DIR)/.configured

$(CACAO_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(CACAO_SOURCE) make/cacao.mk
	$(MAKE) classpath-stage
	rm -rf $(HOST_BUILD_DIR)/$(CACAO_DIR) $(@D)
	$(CACAO_UNZIP) $(DL_DIR)/$(CACAO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xf -
	if test "$(HOST_BUILD_DIR)/$(CACAO_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(CACAO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		JAVAC="javac -bootclasspath $(STAGING_PREFIX)/share/classpath/glibj.zip" \
		./configure \
		--prefix=/opt \
		--with-java-runtime-library-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	$(MAKE) -C $(@D)
	touch $@

cacao-host: $(CACAO_HOST_BUILD_DIR)/.built

#
# This builds the actual binary.
#
$(CACAO_BUILD_DIR)/.built: $(CACAO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cacao: $(CACAO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CACAO_BUILD_DIR)/.staged: $(CACAO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

cacao-stage: $(CACAO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cacao
#
$(CACAO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cacao" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CACAO_PRIORITY)" >>$@
	@echo "Section: $(CACAO_SECTION)" >>$@
	@echo "Version: $(CACAO_VERSION)-$(CACAO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CACAO_MAINTAINER)" >>$@
	@echo "Source: $(CACAO_SITE)/$(CACAO_SOURCE)" >>$@
	@echo "Description: $(CACAO_DESCRIPTION)" >>$@
	@echo "Depends: $(CACAO_DEPENDS)" >>$@
	@echo "Suggests: $(CACAO_SUGGESTS)" >>$@
	@echo "Conflicts: $(CACAO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CACAO_IPK_DIR)/opt/sbin or $(CACAO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CACAO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CACAO_IPK_DIR)/opt/etc/cacao/...
# Documentation files should be installed in $(CACAO_IPK_DIR)/opt/doc/cacao/...
# Daemon startup scripts should be installed in $(CACAO_IPK_DIR)/opt/etc/init.d/S??cacao
#
# You may need to patch your application to make it use these locations.
#
$(CACAO_IPK): $(CACAO_BUILD_DIR)/.built
	rm -rf $(CACAO_IPK_DIR) $(BUILD_DIR)/cacao_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CACAO_BUILD_DIR) DESTDIR=$(CACAO_IPK_DIR) install-strip
	$(MAKE) $(CACAO_IPK_DIR)/CONTROL/control
	echo $(CACAO_CONFFILES) | sed -e 's/ /\n/g' > $(CACAO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CACAO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cacao-ipk: $(CACAO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cacao-clean:
	rm -f $(CACAO_BUILD_DIR)/.built
	-$(MAKE) -C $(CACAO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cacao-dirclean:
	rm -rf $(BUILD_DIR)/$(CACAO_DIR) $(CACAO_BUILD_DIR) $(CACAO_IPK_DIR) $(CACAO_IPK)
#
#
# Some sanity check for the package.
#
cacao-check: $(CACAO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CACAO_IPK)
