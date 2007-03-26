###########################################################
#
# hugs
#
###########################################################

# You must replace "hugs" and "HUGS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HUGS_VERSION, HUGS_SITE and HUGS_SOURCE define
# the upstream location of the source code for the package.
# HUGS_DIR is the directory which is created when the source
# archive is unpacked.
# HUGS_UNZIP is the command used to unzip the source.
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
HUGS_SITE=http://cvs.haskell.org/Hugs/downloads/2006-09
#http://cvs.haskell.org/Hugs/downloads/2006-09/hugs98-plus-Sep2006.tar.gz
HUGS_UPSTREAM_VERSION=Sep2006
HUGS_VERSION=Rel200609
HUGS_SOURCE=hugs98-plus-$(HUGS_UPSTREAM_VERSION).tar.gz
HUGS_DIR=hugs98-plus-$(HUGS_UPSTREAM_VERSION)
HUGS_UNZIP=zcat
HUGS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
HUGS_DESCRIPTION=Hugs 98 is a functional programming system based on Haskell 98, the de facto standard for non-strict functional programming languages.
HUGS_SECTION=misc
HUGS_PRIORITY=optional
HUGS_DEPENDS=
HUGS_CONFLICTS=

#
# HUGS_IPK_VERSION should be incremented when the ipk changes.
#
HUGS_IPK_VERSION=1

#
# HUGS_CONFFILES should be a list of user-editable files
#HUGS_CONFFILES=/opt/etc/hugs.conf /opt/etc/init.d/SXXhugs

#
# HUGS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HUGS_PATCHES=$(HUGS_SOURCE_DIR)/configure.patch \
       	$(HUGS_SOURCE_DIR)/libraries-Makefile.in.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HUGS_CPPFLAGS=
HUGS_LDFLAGS=

#
# HUGS_BUILD_DIR is the directory in which the build is done.
# HUGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HUGS_IPK_DIR is the directory in which the ipk is built.
# HUGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HUGS_BUILD_DIR=$(BUILD_DIR)/hugs
HUGS_SOURCE_DIR=$(SOURCE_DIR)/hugs
HUGS_IPK_DIR=$(BUILD_DIR)/hugs-$(HUGS_VERSION)-ipk
HUGS_IPK=$(BUILD_DIR)/hugs_$(HUGS_VERSION)-$(HUGS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HUGS_SOURCE): make/hugs.mk
	rm -f $(DL_DIR)/$(HUGS_SOURCE)
	$(WGET) -P $(DL_DIR) $(HUGS_SITE)/$(HUGS_SOURCE)
	touch $(DL_DIR)/$(HUGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hugs-source: $(DL_DIR)/$(HUGS_SOURCE) $(HUGS_PATCHES)

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
$(HUGS_BUILD_DIR)/.configured: $(DL_DIR)/$(HUGS_SOURCE) $(HUGS_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(HUGS_DIR) $(HUGS_BUILD_DIR)
	$(HUGS_UNZIP) $(DL_DIR)/$(HUGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(HUGS_PATCHES) | patch -d $(BUILD_DIR)/$(HUGS_DIR) -p1
	mv $(BUILD_DIR)/$(HUGS_DIR) $(HUGS_BUILD_DIR)
	(cd $(HUGS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HUGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HUGS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(HUGS_BUILD_DIR)/.configured

hugs-unpack: $(HUGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HUGS_BUILD_DIR)/.built: $(HUGS_BUILD_DIR)/.configured
	rm -f $(HUGS_BUILD_DIR)/.built
	$(MAKE) -C $(HUGS_BUILD_DIR)
	touch $(HUGS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
hugs: $(HUGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HUGS_BUILD_DIR)/.staged: $(HUGS_BUILD_DIR)/.built
	rm -f $(HUGS_BUILD_DIR)/.staged
	$(MAKE) -C $(HUGS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(HUGS_BUILD_DIR)/.staged

hugs-stage: $(HUGS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hugs
#
$(HUGS_IPK_DIR)/CONTROL/control:
	@install -d $(HUGS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: hugs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HUGS_PRIORITY)" >>$@
	@echo "Section: $(HUGS_SECTION)" >>$@
	@echo "Version: $(HUGS_VERSION)-$(HUGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HUGS_MAINTAINER)" >>$@
	@echo "Source: $(HUGS_SITE)/$(HUGS_SOURCE)" >>$@
	@echo "Description: $(HUGS_DESCRIPTION)" >>$@
	@echo "Depends: $(HUGS_DEPENDS)" >>$@
	@echo "Conflicts: $(HUGS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HUGS_IPK_DIR)/opt/sbin or $(HUGS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HUGS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HUGS_IPK_DIR)/opt/etc/hugs/...
# Documentation files should be installed in $(HUGS_IPK_DIR)/opt/doc/hugs/...
# Daemon startup scripts should be installed in $(HUGS_IPK_DIR)/opt/etc/init.d/S??hugs
#
# You may need to patch your application to make it use these locations.
#
$(HUGS_IPK): $(HUGS_BUILD_DIR)/.built
	rm -rf $(HUGS_IPK_DIR) $(BUILD_DIR)/hugs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HUGS_BUILD_DIR) DESTDIR=$(HUGS_IPK_DIR) install
	for f in \
        	$(HUGS_IPK_DIR)/opt/bin/ffihugs \
        	$(HUGS_IPK_DIR)/opt/bin/runhugs \
                `find $(HUGS_IPK_DIR)/opt/lib/hugs/packages -name '*.so'`; \
            do $(STRIP_COMMAND) $$f; done
	$(MAKE) $(HUGS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HUGS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hugs-ipk: $(HUGS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hugs-clean:
	-$(MAKE) -C $(HUGS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hugs-dirclean:
	rm -rf $(BUILD_DIR)/$(HUGS_DIR) $(HUGS_BUILD_DIR) $(HUGS_IPK_DIR) $(HUGS_IPK)
