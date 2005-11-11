###########################################################
#
# ficy
#
###########################################################

# You must replace "ficy" and "FICY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FICY_VERSION, FICY_SITE and FICY_SOURCE define
# the upstream location of the source code for the package.
# FICY_DIR is the directory which is created when the source
# archive is unpacked.
# FICY_UNZIP is the command used to unzip the source.
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
FICY_SITE=http://dl.sourceforge.net/sourceforge/ficy/
FICY_VERSION=1.0.15
FICY_VERSION_UNDERSCORE=1_0_15
FICY_SOURCE=fIcy-$(FICY_VERSION).tar.gz
FICY_DIR=fIcy-$(FICY_VERSION)
FICY_UNZIP=zcat
FICY_MAINTAINER=Bernhard Walle <bernhard.walle@gmx.de>
FICY_DESCRIPTION=an icecast/shoutcast stream grabber suite
FICY_SECTION=net
FICY_PRIORITY=optional
FICY_DEPENDS=libstdc++
FICY_SUGGESTS=
FICY_CONFLICTS=

#
# FICY_IPK_VERSION should be incremented when the ipk changes.
#
FICY_IPK_VERSION=1

#
# FICY_CONFFILES should be a list of user-editable files
FICY_CONFFILES=

#
# FICY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FICY_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FICY_CPPFLAGS=
FICY_LDFLAGS=

#
# FICY_BUILD_DIR is the directory in which the build is done.
# FICY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FICY_IPK_DIR is the directory in which the ipk is built.
# FICY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FICY_BUILD_DIR=$(BUILD_DIR)/ficy
FICY_SOURCE_DIR=$(SOURCE_DIR)/ficy
FICY_IPK_DIR=$(BUILD_DIR)/ficy-$(FICY_VERSION)-ipk
FICY_IPK=$(BUILD_DIR)/ficy_$(FICY_VERSION)-$(FICY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FICY_SOURCE):
	$(WGET) -P $(DL_DIR) $(FICY_SITE)/$(FICY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ficy-source: $(DL_DIR)/$(FICY_SOURCE) $(FICY_PATCHES)

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
$(FICY_BUILD_DIR)/.configured: $(DL_DIR)/$(FICY_SOURCE) $(FICY_PATCHES)
	rm -rf $(BUILD_DIR)/$(FICY_DIR) $(FICY_BUILD_DIR)
	$(FICY_UNZIP) $(DL_DIR)/$(FICY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(FICY_DIR) $(FICY_BUILD_DIR)
	(cd $(FICY_BUILD_DIR); \
        $(TARGET_CONFIGURE_OPTS) LDFLAGS="$(STAGING_LDFLAGS)" make -e; \
	$(STRIP_COMMAND) fIcy fPls fResync \
	)
	touch $(FICY_BUILD_DIR)/.configured

ficy-unpack: $(FICY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FICY_BUILD_DIR)/.built: $(FICY_BUILD_DIR)/.configured
	rm -f $(FICY_BUILD_DIR)/.built
	$(MAKE) -C $(FICY_BUILD_DIR)
	touch $(FICY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ficy: $(FICY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FICY_BUILD_DIR)/.staged: $(FICY_BUILD_DIR)/.built
	rm -f $(FICY_BUILD_DIR)/.staged
	$(MAKE) -C $(FICY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FICY_BUILD_DIR)/.staged

ficy-stage: $(FICY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ficy
#
$(FICY_IPK_DIR)/CONTROL/control:
	@install -d $(FICY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ficy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FICY_PRIORITY)" >>$@
	@echo "Section: $(FICY_SECTION)" >>$@
	@echo "Version: $(FICY_VERSION)-$(FICY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FICY_MAINTAINER)" >>$@
	@echo "Source: $(FICY_SITE)/$(FICY_SOURCE)" >>$@
	@echo "Description: $(FICY_DESCRIPTION)" >>$@
	@echo "Depends: $(FICY_DEPENDS)" >>$@
	@echo "Suggests: $(FICY_SUGGESTS)" >>$@
	@echo "Conflicts: $(FICY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FICY_IPK_DIR)/opt/sbin or $(FICY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FICY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FICY_IPK_DIR)/opt/etc/ficy/...
# Documentation files should be installed in $(FICY_IPK_DIR)/opt/doc/ficy/...
# Daemon startup scripts should be installed in $(FICY_IPK_DIR)/opt/etc/init.d/S??ficy
#
# You may need to patch your application to make it use these locations.
#
$(FICY_IPK): $(FICY_BUILD_DIR)/.built
	rm -rf $(FICY_IPK_DIR) $(BUILD_DIR)/ficy_*_$(TARGET_ARCH).ipk
	mkdir -p $(FICY_IPK_DIR)/opt/bin
	install -m 755 $(FICY_BUILD_DIR)/fIcy $(FICY_IPK_DIR)/opt/bin
	install -m 755 $(FICY_BUILD_DIR)/fPls $(FICY_IPK_DIR)/opt/bin
	install -m 755 $(FICY_BUILD_DIR)/fResync $(FICY_IPK_DIR)/opt/bin
	$(MAKE) $(FICY_IPK_DIR)/CONTROL/control
	echo $(FICY_CONFFILES) | sed -e 's/ /\n/g' > $(FICY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FICY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ficy-ipk: $(FICY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ficy-clean:
	-$(MAKE) -C $(FICY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ficy-dirclean:
	rm -rf $(BUILD_DIR)/$(FICY_DIR) $(FICY_BUILD_DIR) $(FICY_IPK_DIR) $(FICY_IPK)
