###########################################################
#
# emacs
#
###########################################################

#
# <FOO>_VERSION, <FOO>_SITE and <FOO>_SOURCE define
# the upstream location of the source code for the package.
# <FOO>_DIR is the directory which is created when the source
# archive is unpacked.
# <FOO>_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XEMACS_SITE=ftp://ftp.xemacs.org/pub/xemacs/xemacs-21.4
XEMACS_VERSION=21.4.17
XEMACS_SOURCE=xemacs-$(XEMACS_VERSION).tar.bz2
XEMACS_DIR=xemacs-$(XEMACS_VERSION)
XEMACS_UNZIP=bzcat

#
# XEMACS_IPK_VERSION should be incremented when the ipk changes.
#
XEMACS_IPK_VERSION=1

#
# XEMACS_CONFFILES should be a list of user-editable files
#XEMACS_CONFFILES=/opt/etc/xemacs.conf /opt/etc/init.d/SXXxemacs

#
# XEMACS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XEMACS_PATCHES=$(XEMACS_SOURCE_DIR)/editfns.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XEMACS_CPPFLAGS=
XEMACS_LDFLAGS=

#
# XEMACS_BUILD_DIR is the directory in which the build is done.
# XEMACS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XEMACS_IPK_DIR is the directory in which the ipk is built.
# XEMACS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XEMACS_BUILD_DIR=$(BUILD_DIR)/xemacs
XEMACS_SOURCE_DIR=$(SOURCE_DIR)/xemacs
XEMACS_IPK_DIR=$(BUILD_DIR)/xemacs-$(XEMACS_VERSION)-ipk
XEMACS_IPK=$(BUILD_DIR)/xemacs_$(XEMACS_VERSION)-$(XEMACS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XEMACS_SOURCE):
	$(WGET) -P $(DL_DIR) $(XEMACS_SITE)/$(XEMACS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xemacs-source: $(DL_DIR)/$(XEMACS_SOURCE) $(XEMACS_PATCHES)

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
$(XEMACS_BUILD_DIR)/.configured: $(DL_DIR)/$(XEMACS_SOURCE) $(XEMACS_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(XEMACS_DIR) $(XEMACS_BUILD_DIR)
	$(XEMACS_UNZIP) $(DL_DIR)/$(XEMACS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(XEMACS_DIR) $(XEMACS_BUILD_DIR)
	cat $(XEMACS_PATCHES) | patch -d $(XEMACS_BUILD_DIR) -p1
	(cd $(XEMACS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XEMACS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XEMACS_LDFLAGS)" \
		./configure \
		--prefix=/opt \
		$(GNU_TARGET_NAME) \
	)
	touch $(XEMACS_BUILD_DIR)/.configured

xemacs-unpack: $(XEMACS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XEMACS_BUILD_DIR)/.built: $(XEMACS_BUILD_DIR)/.configured
	rm -f $(XEMACS_BUILD_DIR)/.built
	$(MAKE) -C $(XEMACS_BUILD_DIR)
	touch $(XEMACS_BUILD_DIR)/.built

#
#
xemacs: $(XEMACS_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(XEMACS_IPK_DIR)/opt/sbin or $(XEMACS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XEMACS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XEMACS_IPK_DIR)/opt/etc/xemacs/...
# Documentation files should be installed in $(XEMACS_IPK_DIR)/opt/doc/xemacs/...
# Daemon startup scripts should be installed in $(XEMACS_IPK_DIR)/opt/etc/init.d/S??xemacs
#
# You may need to patch your application to make it use these locations.
#
$(XEMACS_IPK): $(XEMACS_BUILD_DIR)/.built
	rm -rf $(XEMACS_IPK_DIR) $(BUILD_DIR)/xemacs_*_$(TARGET_ARCH).ipk
	install -d $(XEMACS_IPK_DIR)/opt
	$(MAKE) -C $(XEMACS_BUILD_DIR) prefix=$(XEMACS_IPK_DIR)/opt install
	rm -f $(XEMACS_IPK_DIR)/opt/bin/xemacs
	ln -s /opt/bin/xemacs-$(XEMACS_VERSION) $(XEMACS_IPK_DIR)/opt/bin/xemacs
	install -d $(XEMACS_IPK_DIR)/CONTROL
	install -m 644 $(XEMACS_SOURCE_DIR)/control $(XEMACS_IPK_DIR)/CONTROL/control
#	install -m 644 $(XEMACS_SOURCE_DIR)/postinst $(XEMACS_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(XEMACS_SOURCE_DIR)/prerm $(XEMACS_IPK_DIR)/CONTROL/prerm
#	echo $(XEMACS_CONFFILES) | sed -e 's/ /\n/g' > $(XEMACS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XEMACS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xemacs-ipk: $(XEMACS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xemacs-clean:
	-$(MAKE) -C $(XEMACS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xemacs-dirclean:
	rm -rf $(BUILD_DIR)/$(XEMACS_DIR) $(XEMACS_BUILD_DIR) $(XEMACS_IPK_DIR) $(XEMACS_IPK)
