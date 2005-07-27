###########################################################
#
# rcs
#
###########################################################

#
# RCS_VERSION, RCS_SITE and RCS_SOURCE define
# the upstream location of the source code for the package.
# RCS_DIR is the directory which is created when the source
# archive is unpacked.
# RCS_UNZIP is the command used to unzip the source.
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
RCS_SITE=http://www.cs.purdue.edu/homes/trinkle/RCS
RCS_VERSION=5.7
RCS_SOURCE=rcs-$(RCS_VERSION).tar.Z
RCS_DIR=rcs-$(RCS_VERSION)
RCS_UNZIP=zcat
RCS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RCS_DESCRIPTION=The Revision Control System (RCS) manages multiple revisions of files.
RCS_SECTION=misc
RCS_PRIORITY=optional
RCS_DEPENDS=
RCS_SUGGESTS=
RCS_CONFLICTS=

#
# RCS_IPK_VERSION should be incremented when the ipk changes.
#
RCS_IPK_VERSION=1

#
# RCS_CONFFILES should be a list of user-editable files
#RCS_CONFFILES=/opt/etc/rcs.conf /opt/etc/init.d/SXXrcs

#
# RCS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RCS_PATCHES=$(RCS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RCS_CPPFLAGS=
RCS_LDFLAGS=

#
# RCS_BUILD_DIR is the directory in which the build is done.
# RCS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RCS_IPK_DIR is the directory in which the ipk is built.
# RCS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RCS_BUILD_DIR=$(BUILD_DIR)/rcs
RCS_SOURCE_DIR=$(SOURCE_DIR)/rcs
RCS_IPK_DIR=$(BUILD_DIR)/rcs-$(RCS_VERSION)-ipk
RCS_IPK=$(BUILD_DIR)/rcs_$(RCS_VERSION)-$(RCS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RCS_SOURCE):
	$(WGET) -P $(DL_DIR) $(RCS_SITE)/$(RCS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rcs-source: $(DL_DIR)/$(RCS_SOURCE) $(RCS_PATCHES)

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
$(RCS_BUILD_DIR)/.configured: $(DL_DIR)/$(RCS_SOURCE) $(RCS_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RCS_DIR) $(RCS_BUILD_DIR)
	$(RCS_UNZIP) $(DL_DIR)/$(RCS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(RCS_PATCHES) | patch -d $(BUILD_DIR)/$(RCS_DIR) -p1
	mv $(BUILD_DIR)/$(RCS_DIR) $(RCS_BUILD_DIR)
	(cd $(RCS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RCS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RCS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
ifneq ($(HOSTCC),$(TARGET_CC))
ifeq ($(OPTWARE_TARGET),nslu2)
	cp $(RCS_SOURCE_DIR)/slug-src-conf.h $(RCS_BUILD_DIR)/src/conf.h
else
	cp $(RCS_SOURCE_DIR)/wiley-src-conf.h $(RCS_BUILD_DIR)/src/conf.h
endif
endif
	touch $(RCS_BUILD_DIR)/.configured

rcs-unpack: $(RCS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RCS_BUILD_DIR)/.built: $(RCS_BUILD_DIR)/.configured
	rm -f $(RCS_BUILD_DIR)/.built
	$(MAKE) -C $(RCS_BUILD_DIR)
	touch $(RCS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rcs: $(RCS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RCS_BUILD_DIR)/.staged: $(RCS_BUILD_DIR)/.built
	rm -f $(RCS_BUILD_DIR)/.staged
	$(MAKE) -C $(RCS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RCS_BUILD_DIR)/.staged

rcs-stage: $(RCS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rcs
#
$(RCS_IPK_DIR)/CONTROL/control:
	@install -d $(RCS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rcs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RCS_PRIORITY)" >>$@
	@echo "Section: $(RCS_SECTION)" >>$@
	@echo "Version: $(RCS_VERSION)-$(RCS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RCS_MAINTAINER)" >>$@
	@echo "Source: $(RCS_SITE)/$(RCS_SOURCE)" >>$@
	@echo "Description: $(RCS_DESCRIPTION)" >>$@
	@echo "Depends: $(RCS_DEPENDS)" >>$@
	@echo "Suggests: $(RCS_SUGGESTS)" >>$@
	@echo "Conflicts: $(RCS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RCS_IPK_DIR)/opt/sbin or $(RCS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RCS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RCS_IPK_DIR)/opt/etc/rcs/...
# Documentation files should be installed in $(RCS_IPK_DIR)/opt/doc/rcs/...
# Daemon startup scripts should be installed in $(RCS_IPK_DIR)/opt/etc/init.d/S??rcs
#
# You may need to patch your application to make it use these locations.
#
$(RCS_IPK): $(RCS_BUILD_DIR)/.built
	rm -rf $(RCS_IPK_DIR) $(BUILD_DIR)/rcs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RCS_BUILD_DIR) DESTDIR=$(RCS_IPK_DIR) prefix=$(RCS_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(RCS_IPK_DIR)/opt/bin/*
	$(MAKE) $(RCS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RCS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rcs-ipk: $(RCS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rcs-clean:
	-$(MAKE) -C $(RCS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rcs-dirclean:
	rm -rf $(BUILD_DIR)/$(RCS_DIR) $(RCS_BUILD_DIR) $(RCS_IPK_DIR) $(RCS_IPK)
