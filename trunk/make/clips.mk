###########################################################
#
# clips
#
###########################################################

#
# CLIPS_VERSION, CLIPS_SITE and CLIPS_SOURCE define
# the upstream location of the source code for the package.
# CLIPS_DIR is the directory which is created when the source
# archive is unpacked.
# CLIPS_UNZIP is the command used to unzip the source.
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
CLIPS_SITE=http://www.ghg.net/clips/download/source
CLIPS_VERSION=6.23
CLIPS_TARBALL=clipssrc.tar.Z
CLIPS_SOURCE=clipssrc-$(CLIPS_VERSION).tar.Z
CLIPS_DIR=clipssrc
CLIPS_UNZIP=zcat
CLIPS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
CLIPS_DESCRIPTION="C" Language Integrated Production System, a a productive development and delivery expert system tool.
CLIPS_SECTION=misc
CLIPS_PRIORITY=optional
CLIPS_DEPENDS=
CLIPS_SUGGESTS=
CLIPS_CONFLICTS=

#
# CLIPS_IPK_VERSION should be incremented when the ipk changes.
#
CLIPS_IPK_VERSION=1

#
# CLIPS_CONFFILES should be a list of user-editable files
#CLIPS_CONFFILES=/opt/etc/clips.conf /opt/etc/init.d/SXXclips

#
# CLIPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CLIPS_PATCHES=$(CLIPS_SOURCE_DIR)/makefile.patch $(CLIPS_SOURCE_DIR)/setup.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CLIPS_CPPFLAGS=-fPIC
CLIPS_LDFLAGS=

#
# CLIPS_BUILD_DIR is the directory in which the build is done.
# CLIPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CLIPS_IPK_DIR is the directory in which the ipk is built.
# CLIPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CLIPS_BUILD_DIR=$(BUILD_DIR)/clips
CLIPS_SOURCE_DIR=$(SOURCE_DIR)/clips
CLIPS_IPK_DIR=$(BUILD_DIR)/clips-$(CLIPS_VERSION)-ipk
CLIPS_IPK=$(BUILD_DIR)/clips_$(CLIPS_VERSION)-$(CLIPS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CLIPS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CLIPS_SITE)/$(CLIPS_TARBALL) -O $(DL_DIR)/$(CLIPS_SOURCE)
	$(WGET) -P $(DL_DIR) $(CLIPS_SITE)/makefile -O $(DL_DIR)/clips-$(CLIPS_VERSION)-Makefile

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
clips-source: $(DL_DIR)/$(CLIPS_SOURCE) $(CLIPS_PATCHES)

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
$(CLIPS_BUILD_DIR)/.configured: $(DL_DIR)/$(CLIPS_SOURCE) $(CLIPS_PATCHES)
	$(MAKE) termcap-stage
	rm -rf $(BUILD_DIR)/$(CLIPS_DIR) $(CLIPS_BUILD_DIR)
	$(CLIPS_UNZIP) $(DL_DIR)/$(CLIPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cp $(DL_DIR)/clips-$(CLIPS_VERSION)-Makefile $(BUILD_DIR)/$(CLIPS_DIR)/clipssrc/Makefile
	mv $(BUILD_DIR)/$(CLIPS_DIR) $(CLIPS_BUILD_DIR)
	cat $(CLIPS_PATCHES) | patch -d $(BUILD_DIR) -p0
	touch $(CLIPS_BUILD_DIR)/.configured

clips-unpack: $(CLIPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CLIPS_BUILD_DIR)/.built: $(CLIPS_BUILD_DIR)/.configured
	rm -f $(CLIPS_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(CLIPS_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(CLIPS_LDFLAGS)" \
		$(MAKE) -C $(CLIPS_BUILD_DIR)/clipssrc
	touch $(CLIPS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
clips: $(CLIPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CLIPS_BUILD_DIR)/.staged: $(CLIPS_BUILD_DIR)/.built
	rm -f $(CLIPS_BUILD_DIR)/.staged
	$(MAKE) -C $(CLIPS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CLIPS_BUILD_DIR)/.staged

clips-stage: $(CLIPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/clips
#
$(CLIPS_IPK_DIR)/CONTROL/control:
	@install -d $(CLIPS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: clips" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CLIPS_PRIORITY)" >>$@
	@echo "Section: $(CLIPS_SECTION)" >>$@
	@echo "Version: $(CLIPS_VERSION)-$(CLIPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CLIPS_MAINTAINER)" >>$@
	@echo "Source: $(CLIPS_SITE)/$(CLIPS_SOURCE)" >>$@
	@echo "Description: $(CLIPS_DESCRIPTION)" >>$@
	@echo "Depends: $(CLIPS_DEPENDS)" >>$@
	@echo "Suggests: $(CLIPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CLIPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CLIPS_IPK_DIR)/opt/sbin or $(CLIPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CLIPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CLIPS_IPK_DIR)/opt/etc/clips/...
# Documentation files should be installed in $(CLIPS_IPK_DIR)/opt/doc/clips/...
# Daemon startup scripts should be installed in $(CLIPS_IPK_DIR)/opt/etc/init.d/S??clips
#
# You may need to patch your application to make it use these locations.
#
$(CLIPS_IPK): $(CLIPS_BUILD_DIR)/.built
	rm -rf $(CLIPS_IPK_DIR) $(BUILD_DIR)/clips_*_$(TARGET_ARCH).ipk
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(CLIPS_BUILD_DIR)/clipssrc DESTDIR=$(CLIPS_IPK_DIR) install
	$(MAKE) $(CLIPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CLIPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
clips-ipk: $(CLIPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
clips-clean:
	-$(MAKE) -C $(CLIPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
clips-dirclean:
	rm -rf $(BUILD_DIR)/$(CLIPS_DIR) $(CLIPS_BUILD_DIR) $(CLIPS_IPK_DIR) $(CLIPS_IPK)
