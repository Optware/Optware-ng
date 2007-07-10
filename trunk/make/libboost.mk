###########################################################
#
# libboost
#
###########################################################

#
# LIBBOOST_VERSION, LIBBOOST_SITE and LIBBOOST_SOURCE define
# the upstream location of the source code for the package.
# LIBBOOST_DIR is the directory which is created when the source
# archive is unpacked.
# LIBBOOST_UNZIP is the command used to unzip the source.
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
LIBBOOST_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/boost
LIBBOOST_VERSION=1_33_1
LIBBOOST_SOURCE=boost_$(LIBBOOST_VERSION).tar.bz2
LIBBOOST_DIR=boost_$(LIBBOOST_VERSION)
LIBBOOST_UNZIP=bzcat
LIBBOOST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBBOOST_DESCRIPTION=Portable C++ source libraries
LIBBOOST_SECTION=misc
LIBBOOST_PRIORITY=optional
LIBBOOST_DEPENDS=
LIBBOOST_SUGGESTS=
LIBBOOST_CONFLICTS=

#
# LIBBOOST_IPK_VERSION should be incremented when the ipk changes.
#
LIBBOOST_IPK_VERSION=1

#
# LIBBOOST_CONFFILES should be a list of user-editable files
#LIBBOOST_CONFFILES=/opt/etc/libboost.conf /opt/etc/init.d/SXXlibboost

#
# LIBBOOST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBBOOST_PATCHES=$(LIBBOOST_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBBOOST_CPPFLAGS=
LIBBOOST_LDFLAGS=

#
# LIBBOOST_BUILD_DIR is the directory in which the build is done.
# LIBBOOST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBBOOST_IPK_DIR is the directory in which the ipk is built.
# LIBBOOST_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBBOOST_BUILD_DIR=$(BUILD_DIR)/libboost
LIBBOOST_SOURCE_DIR=$(SOURCE_DIR)/libboost
LIBBOOST_IPK_DIR=$(BUILD_DIR)/libboost-$(LIBBOOST_VERSION)-ipk
LIBBOOST_IPK=$(BUILD_DIR)/libboost_$(LIBBOOST_VERSION)-$(LIBBOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBBOOST_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBBOOST_SITE)/$(LIBBOOST_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libboost-source: $(DL_DIR)/$(LIBBOOST_SOURCE) $(LIBBOOST_PATCHES)

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
$(LIBBOOST_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBBOOST_SOURCE) $(LIBBOOST_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBBOOST_DIR) $(LIBBOOST_BUILD_DIR)
	$(LIBBOOST_UNZIP) $(DL_DIR)/$(LIBBOOST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(LIBBOOST_PATCHES) | patch -d $(BUILD_DIR)/$(LIBBOOST_DIR) -p1
	mv $(BUILD_DIR)/$(LIBBOOST_DIR) $(LIBBOOST_BUILD_DIR)
	(cd $(LIBBOOST_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBBOOST_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBBOOST_LDFLAGS)" \
		./configure \
		--prefix=/opt \
	)
	touch $(LIBBOOST_BUILD_DIR)/.configured

libboost-unpack: $(LIBBOOST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBBOOST_BUILD_DIR)/.built: $(LIBBOOST_BUILD_DIR)/.configured
	rm -f $(LIBBOOST_BUILD_DIR)/.built
	(cd $(LIBBOOST_BUILD_DIR)/tools/build/jam_src; \
		./build.sh; \
	)
	(cd $(LIBBOOST_BUILD_DIR); \
		PATH=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/bin:$$PATH; \
		BJAM=`find tools/build/jam_src/ -name bjam -a -type f`; \
		$$BJAM "-sBUILD=release <threading>single <optimization>speed <runtime-link>static"; \
		for i in `find bin -type d -a -name \*.a`; do \
      			for j in `find $$i -type f -a -name \*.a`; do \
        			mv $$j libs/`basename $$i`; \
      			done; \
		done; \
		$(TARGET_RANLIB) libs/*.a; \
	)
	touch $(LIBBOOST_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libboost: $(LIBBOOST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBBOOST_BUILD_DIR)/.staged: $(LIBBOOST_BUILD_DIR)/.built
	rm -f $(LIBBOOST_BUILD_DIR)/.staged
	#$(MAKE) -C $(LIBBOOST_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	install -d $(STAGING_DIR)/boost
	install -d $(STAGING_INCLUDE_DIR)/boost
	install $(LIBBOOST_BUILD_DIR)/libs/libboost_* $(STAGING_LIB_DIR)
	cp -rp $(LIBBOOST_BUILD_DIR)/boost $(STAGING_INCLUDE_DIR)
#	(cd $(LIBBOOST_BUILD_DIR); \
		PATH=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/bin:$$PATH; \
		BJAM=`find tools/build/jam_src/ -name bjam -a -type f`; \
		$$BJAM \
		--stagedir=$(STAGING_DIR)/boost \
		"-sBUILD=release <threading>single <optimization>speed <runtime-link>static" \
		stage; \
	)
	touch $(LIBBOOST_BUILD_DIR)/.staged

libboost-stage: $(LIBBOOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libboost
#
$(LIBBOOST_IPK_DIR)/CONTROL/control:
	@install -d $(LIBBOOST_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libboost" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBBOOST_PRIORITY)" >>$@
	@echo "Section: $(LIBBOOST_SECTION)" >>$@
	@echo "Version: $(LIBBOOST_VERSION)-$(LIBBOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBBOOST_MAINTAINER)" >>$@
	@echo "Source: $(LIBBOOST_SITE)/$(LIBBOOST_SOURCE)" >>$@
	@echo "Description: $(LIBBOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBBOOST_DEPENDS)" >>$@
	@echo "Suggests: $(LIBBOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBBOOST_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBBOOST_IPK_DIR)/opt/sbin or $(LIBBOOST_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBBOOST_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBBOOST_IPK_DIR)/opt/etc/libboost/...
# Documentation files should be installed in $(LIBBOOST_IPK_DIR)/opt/doc/libboost/...
# Daemon startup scripts should be installed in $(LIBBOOST_IPK_DIR)/opt/etc/init.d/S??libboost
#
# You may need to patch your application to make it use these locations.
#
$(LIBBOOST_IPK): $(LIBBOOST_BUILD_DIR)/.built
	rm -rf $(LIBBOOST_IPK_DIR) $(BUILD_DIR)/libboost_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBBOOST_BUILD_DIR) DESTDIR=$(LIBBOOST_IPK_DIR) install
	install -d $(LIBBOOST_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBBOOST_SOURCE_DIR)/libboost.conf $(LIBBOOST_IPK_DIR)/opt/etc/libboost.conf
#	install -d $(LIBBOOST_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBBOOST_SOURCE_DIR)/rc.libboost $(LIBBOOST_IPK_DIR)/opt/etc/init.d/SXXlibboost
	$(MAKE) $(LIBBOOST_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBBOOST_SOURCE_DIR)/postinst $(LIBBOOST_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBBOOST_SOURCE_DIR)/prerm $(LIBBOOST_IPK_DIR)/CONTROL/prerm
#	echo $(LIBBOOST_CONFFILES) | sed -e 's/ /\n/g' > $(LIBBOOST_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBBOOST_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libboost-ipk: $(LIBBOOST_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libboost-clean:
	-$(MAKE) -C $(LIBBOOST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libboost-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBBOOST_DIR) $(LIBBOOST_BUILD_DIR) $(LIBBOOST_IPK_DIR) $(LIBBOOST_IPK)
