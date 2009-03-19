###########################################################
#
# unison
#
###########################################################
#
# $Header$
#
# UNISON_VERSION, UNISON_SITE and UNISON_SOURCE define
# the upstream location of the source code for the package.
# UNISON_DIR is the directory which is created when the source
# archive is unpacked.
# UNISON_UNZIP is the command used to unzip the source.
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
UNISON_VERSION=2.27.57
UNISON_DIR=unison-$(UNISON_VERSION)
UNISON_SITE=http://www.cis.upenn.edu/~bcpierce/unison/download/releases/$(UNISON_DIR)
UNISON_SOURCE=$(UNISON_DIR).tar.gz
UNISON_UNZIP=zcat
UNISON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNISON_DESCRIPTION=A cross-platform file-synchronization tool.
UNISON_SECTION=net
UNISON_PRIORITY=optional
# bytecode version depends on ocaml
UNISON_DEPENDS=ocaml
UNISON_SUGGESTS=
UNISON_CONFLICTS=

#
# UNISON_IPK_VERSION should be incremented when the ipk changes.
#
UNISON_IPK_VERSION=1

#
# UNISON_CONFFILES should be a list of user-editable files
#UNISON_CONFFILES=/opt/etc/unison.conf /opt/etc/init.d/SXXunison

#
# UNISON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UNISON_PATCHES=$(UNISON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNISON_CPPFLAGS=
UNISON_LDFLAGS=

#
# UNISON_BUILD_DIR is the directory in which the build is done.
# UNISON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNISON_IPK_DIR is the directory in which the ipk is built.
# UNISON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNISON_BUILD_DIR=$(BUILD_DIR)/unison
UNISON_SOURCE_DIR=$(SOURCE_DIR)/unison
UNISON_IPK_DIR=$(BUILD_DIR)/unison-$(UNISON_VERSION)-ipk
UNISON_IPK=$(BUILD_DIR)/unison_$(UNISON_VERSION)-$(UNISON_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNISON_SOURCE):
	$(WGET) -P $(@D) $(UNISON_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unison-source: $(DL_DIR)/$(UNISON_SOURCE) $(UNISON_PATCHES)

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
$(UNISON_BUILD_DIR)/.configured: $(DL_DIR)/$(UNISON_SOURCE) $(UNISON_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UNISON_DIR) $(@D)
	$(UNISON_UNZIP) $(DL_DIR)/$(UNISON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(UNISON_PATCHES) | patch -d $(BUILD_DIR)/$(UNISON_DIR) -p1
	mv $(BUILD_DIR)/$(UNISON_DIR) $(@D)
	touch $@

unison-unpack: $(UNISON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNISON_BUILD_DIR)/.built: $(UNISON_BUILD_DIR)/.configured
	rm -f $@
# natively compiled unison segfaults for some reason
#	$(MAKE) -C $(@D) UISTYLE=text NATIVE=true strings.ml buildexecutable
	$(MAKE) -C $(@D) UISTYLE=text NATIVE=false THREADS=true strings.ml buildexecutable
	touch $@

#
# This is the build convenience target.
#
unison: $(UNISON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UNISON_BUILD_DIR)/.staged: $(UNISON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

unison-stage: $(UNISON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unison
#
$(UNISON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: unison" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNISON_PRIORITY)" >>$@
	@echo "Section: $(UNISON_SECTION)" >>$@
	@echo "Version: $(UNISON_VERSION)-$(UNISON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNISON_MAINTAINER)" >>$@
	@echo "Source: $(UNISON_SITE)/$(UNISON_SOURCE)" >>$@
	@echo "Description: $(UNISON_DESCRIPTION)" >>$@
	@echo "Depends: $(UNISON_DEPENDS)" >>$@
	@echo "Suggests: $(UNISON_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNISON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNISON_IPK_DIR)/opt/sbin or $(UNISON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNISON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNISON_IPK_DIR)/opt/etc/unison/...
# Documentation files should be installed in $(UNISON_IPK_DIR)/opt/doc/unison/...
# Daemon startup scripts should be installed in $(UNISON_IPK_DIR)/opt/etc/init.d/S??unison
#
# You may need to patch your application to make it use these locations.
#
$(UNISON_IPK): $(UNISON_BUILD_DIR)/.built
	rm -rf $(UNISON_IPK_DIR) $(BUILD_DIR)/unison_*_$(TARGET_ARCH).ipk
	install -d $(UNISON_IPK_DIR)/opt/bin
	install -m 755 $(UNISON_BUILD_DIR)/unison $(UNISON_IPK_DIR)/opt/bin
	$(MAKE) $(UNISON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNISON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unison-ipk: $(UNISON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unison-clean:
	-$(MAKE) -C $(UNISON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unison-dirclean:
	rm -rf $(BUILD_DIR)/$(UNISON_DIR) $(UNISON_BUILD_DIR) $(UNISON_IPK_DIR) $(UNISON_IPK)
