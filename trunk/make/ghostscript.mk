###########################################################
#
# ghostscript
#
###########################################################

# You must replace "ghostscript" and "GHOSTSCRIPT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GHOSTSCRIPT_VERSION, GHOSTSCRIPT_SITE and GHOSTSCRIPT_SOURCE define
# the upstream location of the source code for the package.
# GHOSTSCRIPT_DIR is the directory which is created when the source
# archive is unpacked.
# GHOSTSCRIPT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GHOSTSCRIPT_SITE=http://unc.dl.sourceforge.net/sourceforge/ghostscript
GHOSTSCRIPT_VERSION=8.50
GHOSTSCRIPT_SOURCE=ghostscript-$(GHOSTSCRIPT_VERSION).tar.bz2
GHOSTSCRIPT_DIR=ghostscript-$(GHOSTSCRIPT_VERSION)
GHOSTSCRIPT_UNZIP=bzcat

#
# GHOSTSCRIPT_IPK_VERSION should be incremented when the ipk changes.
#
GHOSTSCRIPT_IPK_VERSION=1

#
# GHOSTSCRIPT_CONFFILES should be a list of user-editable files
GHOSTSCRIPT_CONFFILES=/opt/etc/ghostscript.conf /opt/etc/init.d/SXXghostscript

#
## GHOSTSCRIPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GHOSTSCRIPT_PATCHES=$(GHOSTSCRIPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GHOSTSCRIPT_CPPFLAGS=
GHOSTSCRIPT_LDFLAGS=

#
# GHOSTSCRIPT_BUILD_DIR is the directory in which the build is done.
# GHOSTSCRIPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GHOSTSCRIPT_IPK_DIR is the directory in which the ipk is built.
# GHOSTSCRIPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GHOSTSCRIPT_BUILD_DIR=$(BUILD_DIR)/ghostscript
GHOSTSCRIPT_SOURCE_DIR=$(SOURCE_DIR)/ghostscript
GHOSTSCRIPT_IPK_DIR=$(BUILD_DIR)/ghostscript-$(GHOSTSCRIPT_VERSION)-ipk
GHOSTSCRIPT_IPK=$(BUILD_DIR)/ghostscript_$(GHOSTSCRIPT_VERSION)-$(GHOSTSCRIPT_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GHOSTSCRIPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GHOSTSCRIPT_SITE)/$(GHOSTSCRIPT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#ghostscript-source: $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) $(GHOSTSCRIPT_PATCHES)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(GHOSTSCRIPT_BUILD_DIR)/.configured: $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) $(GHOSTSCRIPT_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(GHOSTSCRIPT_BUILD_DIR)
	$(GHOSTSCRIPT_UNZIP) $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GHOSTSCRIPT_PATCHES) | patch -d $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) -p1
	mv $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(GHOSTSCRIPT_BUILD_DIR)
	(cd $(GHOSTSCRIPT_BUILD_DIR); \
		ln -s src/unix-gcc.mak Makefile ; \
		mkdir obj; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GHOSTSCRIPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GHOSTSCRIPT_LDFLAGS)" \
		$(MAKE) obj/arch.h obj/genconf obj/echogs \
	)
	touch $(GHOSTSCRIPT_BUILD_DIR)/.configured

ghostscript-unpack: $(GHOSTSCRIPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GHOSTSCRIPT_BUILD_DIR)/.built: $(GHOSTSCRIPT_BUILD_DIR)/.configured
	rm -f $(GHOSTSCRIPT_BUILD_DIR)/.built
	$(MAKE) -C $(GHOSTSCRIPT_BUILD_DIR)
	touch $(GHOSTSCRIPT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ghostscript: $(GHOSTSCRIPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GHOSTSCRIPT_BUILD_DIR)/.staged: $(GHOSTSCRIPT_BUILD_DIR)/.built
	rm -f $(GHOSTSCRIPT_BUILD_DIR)/.staged
	$(MAKE) -C $(GHOSTSCRIPT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(GHOSTSCRIPT_BUILD_DIR)/.staged

ghostscript-stage: $(GHOSTSCRIPT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GHOSTSCRIPT_IPK_DIR)/opt/sbin or $(GHOSTSCRIPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GHOSTSCRIPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GHOSTSCRIPT_IPK_DIR)/opt/etc/ghostscript/...
# Documentation files should be installed in $(GHOSTSCRIPT_IPK_DIR)/opt/doc/ghostscript/...
# Daemon startup scripts should be installed in $(GHOSTSCRIPT_IPK_DIR)/opt/etc/init.d/S??ghostscript
#
# You may need to patch your application to make it use these locations.
#
$(GHOSTSCRIPT_IPK): $(GHOSTSCRIPT_BUILD_DIR)/.built
	rm -rf $(GHOSTSCRIPT_IPK_DIR) $(BUILD_DIR)/ghostscript_*_armeb.ipk
	$(MAKE) -C $(GHOSTSCRIPT_BUILD_DIR) DESTDIR=$(GHOSTSCRIPT_IPK_DIR) install
	install -d $(GHOSTSCRIPT_IPK_DIR)/opt/etc/
	install -m 644 $(GHOSTSCRIPT_SOURCE_DIR)/ghostscript.conf $(GHOSTSCRIPT_IPK_DIR)/opt/etc/ghostscript.conf
	install -d $(GHOSTSCRIPT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(GHOSTSCRIPT_SOURCE_DIR)/rc.ghostscript $(GHOSTSCRIPT_IPK_DIR)/opt/etc/init.d/SXXghostscript
	install -d $(GHOSTSCRIPT_IPK_DIR)/CONTROL
	install -m 644 $(GHOSTSCRIPT_SOURCE_DIR)/control $(GHOSTSCRIPT_IPK_DIR)/CONTROL/control
	install -m 644 $(GHOSTSCRIPT_SOURCE_DIR)/postinst $(GHOSTSCRIPT_IPK_DIR)/CONTROL/postinst
	install -m 644 $(GHOSTSCRIPT_SOURCE_DIR)/prerm $(GHOSTSCRIPT_IPK_DIR)/CONTROL/prerm
	echo $(GHOSTSCRIPT_CONFFILES) | sed -e 's/ /\n/g' > $(GHOSTSCRIPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GHOSTSCRIPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ghostscript-ipk: $(GHOSTSCRIPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ghostscript-clean:
	-$(MAKE) -C $(GHOSTSCRIPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ghostscript-dirclean:
	rm -rf $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(GHOSTSCRIPT_BUILD_DIR) $(GHOSTSCRIPT_IPK_DIR) $(GHOSTSCRIPT_IPK)
