###########################################################
#
# ltrace
#
###########################################################
#
# LTRACE_VERSION, LTRACE_SITE and LTRACE_SOURCE define
# the upstream location of the source code for the package.
# LTRACE_DIR is the directory which is created when the source
# archive is unpacked.
# LTRACE_UNZIP is the command used to unzip the source.
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
LTRACE_SITE=http://ftp.debian.org/debian/pool/main/l/ltrace
LTRACE_VERSION=0.4
LTRACE_SOURCE=ltrace_$(LTRACE_VERSION).orig.tar.gz
LTRACE_DIR=ltrace-$(LTRACE_VERSION)
LTRACE_UNZIP=zcat
LTRACE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LTRACE_DESCRIPTION=Tracks runtime library calls in dynamically linked programs.
LTRACE_SECTION=misc
LTRACE_PRIORITY=optional
LTRACE_DEPENDS=
LTRACE_SUGGESTS=
LTRACE_CONFLICTS=

#
# LTRACE_IPK_VERSION should be incremented when the ipk changes.
#
LTRACE_IPK_VERSION=1

#
# LTRACE_CONFFILES should be a list of user-editable files
#LTRACE_CONFFILES=/opt/etc/ltrace.conf /opt/etc/init.d/SXXltrace

#
# LTRACE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LTRACE_PATCHES=$(LTRACE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LTRACE_CPPFLAGS=
LTRACE_LDFLAGS=

LTRACE_ARCH=$(strip \
	$(if $(filter armeb arm, $(TARGET_ARCH)), arm, \
	$(if $(filter powerpc, $(TARGET_ARCH)), ppc, \
	$(TARGET_ARCH))))

#
# LTRACE_BUILD_DIR is the directory in which the build is done.
# LTRACE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LTRACE_IPK_DIR is the directory in which the ipk is built.
# LTRACE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LTRACE_BUILD_DIR=$(BUILD_DIR)/ltrace
LTRACE_SOURCE_DIR=$(SOURCE_DIR)/ltrace
LTRACE_IPK_DIR=$(BUILD_DIR)/ltrace-$(LTRACE_VERSION)-ipk
LTRACE_IPK=$(BUILD_DIR)/ltrace_$(LTRACE_VERSION)-$(LTRACE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ltrace-source ltrace-unpack ltrace ltrace-stage ltrace-ipk ltrace-clean ltrace-dirclean ltrace-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LTRACE_SOURCE):
	$(WGET) -P $(DL_DIR) $(LTRACE_SITE)/$(LTRACE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LTRACE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ltrace-source: $(DL_DIR)/$(LTRACE_SOURCE) $(LTRACE_PATCHES)

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
$(LTRACE_BUILD_DIR)/.configured: $(DL_DIR)/$(LTRACE_SOURCE) $(LTRACE_PATCHES) make/ltrace.mk
	$(MAKE) libelf-stage
	rm -rf $(BUILD_DIR)/$(LTRACE_DIR) $(LTRACE_BUILD_DIR)
	$(LTRACE_UNZIP) $(DL_DIR)/$(LTRACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LTRACE_PATCHES)" ; \
		then cat $(LTRACE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LTRACE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LTRACE_DIR)" != "$(LTRACE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LTRACE_DIR) $(LTRACE_BUILD_DIR) ; \
	fi
	(cd $(LTRACE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LTRACE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LTRACE_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e 's/-o root -g root //' $(LTRACE_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(LTRACE_BUILD_DIR)/libtool
	touch $@

ltrace-unpack: $(LTRACE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LTRACE_BUILD_DIR)/.built: $(LTRACE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LTRACE_BUILD_DIR) ARCH=$(LTRACE_ARCH) OS=linux-gnu
	touch $@

#
# This is the build convenience target.
#
ltrace: $(LTRACE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LTRACE_BUILD_DIR)/.staged: $(LTRACE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LTRACE_BUILD_DIR) OS=linux-gnu DESTDIR=$(STAGING_DIR) install
	touch $@

ltrace-stage: $(LTRACE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ltrace
#
$(LTRACE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ltrace" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LTRACE_PRIORITY)" >>$@
	@echo "Section: $(LTRACE_SECTION)" >>$@
	@echo "Version: $(LTRACE_VERSION)-$(LTRACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LTRACE_MAINTAINER)" >>$@
	@echo "Source: $(LTRACE_SITE)/$(LTRACE_SOURCE)" >>$@
	@echo "Description: $(LTRACE_DESCRIPTION)" >>$@
	@echo "Depends: $(LTRACE_DEPENDS)" >>$@
	@echo "Suggests: $(LTRACE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LTRACE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LTRACE_IPK_DIR)/opt/sbin or $(LTRACE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LTRACE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LTRACE_IPK_DIR)/opt/etc/ltrace/...
# Documentation files should be installed in $(LTRACE_IPK_DIR)/opt/doc/ltrace/...
# Daemon startup scripts should be installed in $(LTRACE_IPK_DIR)/opt/etc/init.d/S??ltrace
#
# You may need to patch your application to make it use these locations.
#
$(LTRACE_IPK): $(LTRACE_BUILD_DIR)/.built
	rm -rf $(LTRACE_IPK_DIR) $(BUILD_DIR)/ltrace_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LTRACE_BUILD_DIR) \
		DESTDIR=$(LTRACE_IPK_DIR) ARCH=$(LTRACE_ARCH) OS=linux-gnu \
		install
	$(STRIP_COMMAND) $(LTRACE_IPK_DIR)/opt/bin/ltrace
#	install -d $(LTRACE_IPK_DIR)/opt/etc/
#	install -m 644 $(LTRACE_SOURCE_DIR)/ltrace.conf $(LTRACE_IPK_DIR)/opt/etc/ltrace.conf
#	install -d $(LTRACE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LTRACE_SOURCE_DIR)/rc.ltrace $(LTRACE_IPK_DIR)/opt/etc/init.d/SXXltrace
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LTRACE_IPK_DIR)/opt/etc/init.d/SXXltrace
	$(MAKE) $(LTRACE_IPK_DIR)/CONTROL/control
#	install -m 755 $(LTRACE_SOURCE_DIR)/postinst $(LTRACE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LTRACE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LTRACE_SOURCE_DIR)/prerm $(LTRACE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LTRACE_IPK_DIR)/CONTROL/prerm
	echo $(LTRACE_CONFFILES) | sed -e 's/ /\n/g' > $(LTRACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LTRACE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ltrace-ipk: $(LTRACE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ltrace-clean:
	rm -f $(LTRACE_BUILD_DIR)/.built
	-$(MAKE) -C $(LTRACE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ltrace-dirclean:
	rm -rf $(BUILD_DIR)/$(LTRACE_DIR) $(LTRACE_BUILD_DIR) $(LTRACE_IPK_DIR) $(LTRACE_IPK)
#
#
# Some sanity check for the package.
#
ltrace-check: $(LTRACE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LTRACE_IPK)
