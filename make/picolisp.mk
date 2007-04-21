###########################################################
#
# picolisp
#
###########################################################
#
# PICOLISP_VERSION, PICOLISP_SITE and PICOLISP_SOURCE define
# the upstream location of the source code for the package.
# PICOLISP_DIR is the directory which is created when the source
# archive is unpacked.
# PICOLISP_UNZIP is the command used to unzip the source.
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
PICOLISP_SITE=http://www.software-lab.biz/1024/?download&
PICOLISP_VERSION=2.2.6
PICOLISP_SOURCE=picoLisp-$(PICOLISP_VERSION).tgz
PICOLISP_DIR=picoLisp-$(PICOLISP_VERSION)
PICOLISP_UNZIP=zcat
PICOLISP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PICOLISP_DESCRIPTION=Describe picolisp here.
PICOLISP_SECTION=lang
PICOLISP_PRIORITY=optional
PICOLISP_DEPENDS=
PICOLISP_SUGGESTS=
PICOLISP_CONFLICTS=

#
# PICOLISP_IPK_VERSION should be incremented when the ipk changes.
#
PICOLISP_IPK_VERSION=1

#
# PICOLISP_CONFFILES should be a list of user-editable files
#PICOLISP_CONFFILES=/opt/etc/picolisp.conf /opt/etc/init.d/SXXpicolisp

#
# PICOLISP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PICOLISP_PATCHES=$(PICOLISP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PICOLISP_CPPFLAGS=
PICOLISP_LDFLAGS=

#
# PICOLISP_BUILD_DIR is the directory in which the build is done.
# PICOLISP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PICOLISP_IPK_DIR is the directory in which the ipk is built.
# PICOLISP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PICOLISP_BUILD_DIR=$(BUILD_DIR)/picolisp
PICOLISP_SOURCE_DIR=$(SOURCE_DIR)/picolisp
PICOLISP_IPK_DIR=$(BUILD_DIR)/picolisp-$(PICOLISP_VERSION)-ipk
PICOLISP_IPK=$(BUILD_DIR)/picolisp_$(PICOLISP_VERSION)-$(PICOLISP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: picolisp-source picolisp-unpack picolisp picolisp-stage picolisp-ipk picolisp-clean picolisp-dirclean picolisp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PICOLISP_SOURCE):
	$(WGET) -O $(DL_DIR)/$(PICOLISP_SOURCE) "$(PICOLISP_SITE)$(PICOLISP_SOURCE)" || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PICOLISP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
picolisp-source: $(DL_DIR)/$(PICOLISP_SOURCE) $(PICOLISP_PATCHES)

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
$(PICOLISP_BUILD_DIR)/.configured: $(DL_DIR)/$(PICOLISP_SOURCE) $(PICOLISP_PATCHES) make/picolisp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PICOLISP_DIR) $(PICOLISP_BUILD_DIR)
	$(PICOLISP_UNZIP) $(DL_DIR)/$(PICOLISP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PICOLISP_PATCHES)" ; \
		then cat $(PICOLISP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PICOLISP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PICOLISP_DIR)" != "$(PICOLISP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PICOLISP_DIR) $(PICOLISP_BUILD_DIR) ; \
	fi
	sed -i -e 's/	gcc /	$$(CC) /' $(PICOLISP_BUILD_DIR)/src/Makefile
#	(cd $(PICOLISP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PICOLISP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PICOLISP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(PICOLISP_BUILD_DIR)/libtool
	touch $@

picolisp-unpack: $(PICOLISP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PICOLISP_BUILD_DIR)/.built: $(PICOLISP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PICOLISP_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PICOLISP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PICOLISP_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
picolisp: $(PICOLISP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PICOLISP_BUILD_DIR)/.staged: $(PICOLISP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PICOLISP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

picolisp-stage: $(PICOLISP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/picolisp
#
$(PICOLISP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: picolisp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PICOLISP_PRIORITY)" >>$@
	@echo "Section: $(PICOLISP_SECTION)" >>$@
	@echo "Version: $(PICOLISP_VERSION)-$(PICOLISP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PICOLISP_MAINTAINER)" >>$@
	@echo "Source: $(PICOLISP_SITE)/$(PICOLISP_SOURCE)" >>$@
	@echo "Description: $(PICOLISP_DESCRIPTION)" >>$@
	@echo "Depends: $(PICOLISP_DEPENDS)" >>$@
	@echo "Suggests: $(PICOLISP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PICOLISP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PICOLISP_IPK_DIR)/opt/sbin or $(PICOLISP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PICOLISP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PICOLISP_IPK_DIR)/opt/etc/picolisp/...
# Documentation files should be installed in $(PICOLISP_IPK_DIR)/opt/doc/picolisp/...
# Daemon startup scripts should be installed in $(PICOLISP_IPK_DIR)/opt/etc/init.d/S??picolisp
#
# You may need to patch your application to make it use these locations.
#
$(PICOLISP_IPK): $(PICOLISP_BUILD_DIR)/.built
	rm -rf $(PICOLISP_IPK_DIR) $(BUILD_DIR)/picolisp_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PICOLISP_BUILD_DIR) DESTDIR=$(PICOLISP_IPK_DIR) install-strip
	install -d $(PICOLISP_IPK_DIR)/opt/lib/picolisp
	cp -a $(PICOLISP_BUILD_DIR)/* $(PICOLISP_IPK_DIR)/opt/lib/picolisp/
	rm -rf $(PICOLISP_IPK_DIR)/opt/lib/picolisp/cygwin
	rm -rf $(PICOLISP_IPK_DIR)/opt/lib/picolisp/src
	$(MAKE) $(PICOLISP_IPK_DIR)/CONTROL/control
	echo "touch /opt/lib/picolisp/.picoHistory" > $(PICOLISP_IPK_DIR)/CONTROL/postinst
	echo "chmod 666 /opt/lib/picolisp/.picoHistory" >> $(PICOLISP_IPK_DIR)/CONTROL/postinst
	echo $(PICOLISP_CONFFILES) | sed -e 's/ /\n/g' > $(PICOLISP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PICOLISP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
picolisp-ipk: $(PICOLISP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
picolisp-clean:
	rm -f $(PICOLISP_BUILD_DIR)/.built
	-$(MAKE) -C $(PICOLISP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
picolisp-dirclean:
	rm -rf $(BUILD_DIR)/$(PICOLISP_DIR) $(PICOLISP_BUILD_DIR) $(PICOLISP_IPK_DIR) $(PICOLISP_IPK)
#
#
# Some sanity check for the package.
#
picolisp-check: $(PICOLISP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PICOLISP_IPK)
