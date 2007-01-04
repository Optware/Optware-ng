###########################################################
#
# nbench-byte
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
NBENCH_BYTE_SITE=http://www.tux.org/~mayer/linux
NBENCH_BYTE_VERSION=2.2.2
NBENCH_BYTE_SOURCE=nbench-byte-$(NBENCH_BYTE_VERSION).tar.gz
NBENCH_BYTE_DIR=nbench-byte-$(NBENCH_BYTE_VERSION)
NBENCH_BYTE_UNZIP=zcat
NBENCH_BYTE_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
NBENCH_BYTE_DESCRIPTION=BYTE's Native Mode Benchmarks
NBENCH_BYTE_SECTION=admin
NBENCH_BYTE_PRIORITY=optional
NBENCH_BYTE_DEPENDS=
NBENCH_BYTE_SUGGESTS=
NBENCH_BYTE_CONFLICTS=

#
# NBENCH_BYTE_IPK_VERSION should be incremented when the ipk changes.
#
NBENCH_BYTE_IPK_VERSION=1

#
# NBENCH_BYTE_CONFFILES should be a list of user-editable files
# NBENCH_BYTE_CONFFILES=/opt/etc/nbench-byte.conf /opt/etc/init.d/SXXnbench-byte

#
# NBENCH_BYTE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NBENCH_BYTE_PATCHES=$(NBENCH_BYTE_SOURCE_DIR)/Makefile.diff $(NBENCH_BYTE_SOURCE_DIR)/nbench1_h.diff

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NBENCH_BYTE_CPPFLAGS=-O3
NBENCH_BYTE_LDFLAGS=-s

#
# NBENCH_BYTE_BUILD_DIR is the directory in which the build is done.
# NBENCH_BYTE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NBENCH_BYTE_IPK_DIR is the directory in which the ipk is built.
# NBENCH_BYTE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NBENCH_BYTE_BUILD_DIR=$(BUILD_DIR)/nbench-byte
NBENCH_BYTE_SOURCE_DIR=$(SOURCE_DIR)/nbench-byte
NBENCH_BYTE_IPK_DIR=$(BUILD_DIR)/nbench-byte-$(NBENCH_BYTE_VERSION)-ipk
NBENCH_BYTE_IPK=$(BUILD_DIR)/nbench-byte_$(NBENCH_BYTE_VERSION)-$(NBENCH_BYTE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NBENCH_BYTE_SOURCE):
	$(WGET) -P $(DL_DIR) $(NBENCH_BYTE_SITE)/$(NBENCH_BYTE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nbench-byte-source: $(DL_DIR)/$(NBENCH_BYTE_SOURCE) $(NBENCH_BYTE_PATCHES)

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
$(NBENCH_BYTE_BUILD_DIR)/.configured: $(DL_DIR)/$(NBENCH_BYTE_SOURCE) $(NBENCH_BYTE_PATCHES) make/nbench-byte.mk
	rm -rf $(BUILD_DIR)/$(NBENCH_BYTE_DIR) $(NBENCH_BYTE_BUILD_DIR)
	$(NBENCH_BYTE_UNZIP) $(DL_DIR)/$(NBENCH_BYTE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NBENCH_BYTE_PATCHES)" ; \
		then cat $(NBENCH_BYTE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NBENCH_BYTE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NBENCH_BYTE_DIR)" != "$(NBENCH_BYTE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NBENCH_BYTE_DIR) $(NBENCH_BYTE_BUILD_DIR) ; \
	fi
	#(cd $(NBENCH_BYTE_BUILD_DIR); \
	#	$(TARGET_CONFIGURE_OPTS) \
	#	CPPFLAGS="$(STAGING_CPPFLAGS) $(NBENCH_BYTE_CPPFLAGS)" \
	#	LDFLAGS="$(STAGING_LDFLAGS) $(NBENCH_BYTE_LDFLAGS)" \
	#	./configure \
	#	--build=$(GNU_HOST_NAME) \
	#	--host=$(GNU_TARGET_NAME) \
	#	--target=$(GNU_TARGET_NAME) \
	#	--prefix=/opt \
	#	--disable-nls \
	#	--disable-static \
	#)
	#$(PATCH_LIBTOOL) $(NBENCH_BYTE_BUILD_DIR)/libtool
	touch $(NBENCH_BYTE_BUILD_DIR)/.configured

nbench-byte-unpack: $(NBENCH_BYTE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NBENCH_BYTE_BUILD_DIR)/.built: $(NBENCH_BYTE_BUILD_DIR)/.configured
	rm -f $(NBENCH_BYTE_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(NBENCH_BYTE_CPPFLAGS)" \
		LINKFLAGS="$(STAGING_LDFLAGS) $(NBENCH_BYTE_LDFLAGS)" \
		$(MAKE) -C $(NBENCH_BYTE_BUILD_DIR)
	$(STRIP_COMMAND) $(NBENCH_BYTE_BUILD_DIR)/nbench
	touch $(NBENCH_BYTE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nbench-byte: $(NBENCH_BYTE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NBENCH_BYTE_BUILD_DIR)/.staged: $(NBENCH_BYTE_BUILD_DIR)/.built
	rm -f $(NBENCH_BYTE_BUILD_DIR)/.staged
	$(MAKE) -C $(NBENCH_BYTE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NBENCH_BYTE_BUILD_DIR)/.staged

nbench-byte-stage: $(NBENCH_BYTE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nbench-byte
#
$(NBENCH_BYTE_IPK_DIR)/CONTROL/control:
	@install -d $(NBENCH_BYTE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nbench-byte" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NBENCH_BYTE_PRIORITY)" >>$@
	@echo "Section: $(NBENCH_BYTE_SECTION)" >>$@
	@echo "Version: $(NBENCH_BYTE_VERSION)-$(NBENCH_BYTE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NBENCH_BYTE_MAINTAINER)" >>$@
	@echo "Source: $(NBENCH_BYTE_SITE)/$(NBENCH_BYTE_SOURCE)" >>$@
	@echo "Description: $(NBENCH_BYTE_DESCRIPTION)" >>$@
	@echo "Depends: $(NBENCH_BYTE_DEPENDS)" >>$@
	@echo "Suggests: $(NBENCH_BYTE_SUGGESTS)" >>$@
	@echo "Conflicts: $(NBENCH_BYTE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NBENCH_BYTE_IPK_DIR)/opt/sbin or $(NBENCH_BYTE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NBENCH_BYTE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NBENCH_BYTE_IPK_DIR)/opt/etc/nbench-byte/...
# Documentation files should be installed in $(NBENCH_BYTE_IPK_DIR)/opt/doc/nbench-byte/...
# Daemon startup scripts should be installed in $(NBENCH_BYTE_IPK_DIR)/opt/etc/init.d/S??nbench-byte
#
# You may need to patch your application to make it use these locations.
#
$(NBENCH_BYTE_IPK): $(NBENCH_BYTE_BUILD_DIR)/.built
	rm -rf $(NBENCH_BYTE_IPK_DIR) $(BUILD_DIR)/nbench-byte_*_$(TARGET_ARCH).ipk
	mkdir -p $(NBENCH_BYTE_IPK_DIR)/opt/bin
	cp $(NBENCH_BYTE_BUILD_DIR)/nbench $(NBENCH_BYTE_IPK_DIR)/opt/bin
	
	mkdir -p $(NBENCH_BYTE_IPK_DIR)/opt/share
	cp $(NBENCH_BYTE_BUILD_DIR)/NNET.DAT $(NBENCH_BYTE_IPK_DIR)/opt/share/nbench-byte.dat

	$(MAKE) $(NBENCH_BYTE_IPK_DIR)/CONTROL/control
	# install -m 755 $(NBENCH_BYTE_SOURCE_DIR)/postinst $(NBENCH_BYTE_IPK_DIR)/CONTROL/postinst
	# install -m 755 $(NBENCH_BYTE_SOURCE_DIR)/prerm $(NBENCH_BYTE_IPK_DIR)/CONTROL/prerm
	# echo $(NBENCH_BYTE_CONFFILES) | sed -e 's/ /\n/g' > $(NBENCH_BYTE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NBENCH_BYTE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nbench-byte-ipk: $(NBENCH_BYTE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nbench-byte-clean:
	rm -f $(NBENCH_BYTE_BUILD_DIR)/.built
	-$(MAKE) -C $(NBENCH_BYTE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nbench-byte-dirclean:
	rm -rf $(BUILD_DIR)/$(NBENCH_BYTE_DIR) $(NBENCH_BYTE_BUILD_DIR) $(NBENCH_BYTE_IPK_DIR) $(NBENCH_BYTE_IPK)
