###########################################################
#
# gettext
#
###########################################################

#
# GETTEXT_VERSION, GETTEXT_SITE and GETTEXT_SOURCE define
# the upstream location of the source code for the package.
# GETTEXT_DIR is the directory which is created when the source
# archive is unpacked.
# GETTEXT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GETTEXT_SITE=http://ftp.gnu.org/gnu/gettext
GETTEXT_VERSION=0.14.5
GETTEXT_SOURCE=gettext-$(GETTEXT_VERSION).tar.gz
GETTEXT_DIR=gettext-$(GETTEXT_VERSION)
GETTEXT_UNZIP=zcat
GETTEXT_SECTION=devel
GETTEXT_PRIORITY=optional
GETTEXT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GETTEXT_DESCRIPTION=Set of tools for producing multi-lingual messages
GETTEXT_DEPENDS=
GETTEXT_SUGGESTS=
GETTEXT_CONFLICTS=

#
# GETTEXT_IPK_VERSION should be incremented when the ipk changes.
#
GETTEXT_IPK_VERSION=2

#
# GETTEXT_CONFFILES should be a list of user-editable files
#GETTEXT_CONFFILES=/opt/etc/gettext.conf /opt/etc/init.d/SXXgettext

#
# GETTEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GETTEXT_PATCHES=$(GETTEXT_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GETTEXT_CPPFLAGS=
GETTEXT_LDFLAGS=

#
# GETTEXT_BUILD_DIR is the directory in which the build is done.
# GETTEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GETTEXT_IPK_DIR is the directory in which the ipk is built.
# GETTEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GETTEXT_BUILD_DIR=$(BUILD_DIR)/gettext
GETTEXT_SOURCE_DIR=$(SOURCE_DIR)/gettext
GETTEXT_IPK_DIR=$(BUILD_DIR)/gettext-$(GETTEXT_VERSION)-ipk
GETTEXT_IPK=$(BUILD_DIR)/gettext_$(GETTEXT_VERSION)-$(GETTEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(OPTWARE_TARGET), ts101)
GETTEXT_NLS=enable
else
GETTEXT_NLS=disable
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GETTEXT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gettext-source: $(DL_DIR)/$(GETTEXT_SOURCE) $(GETTEXT_PATCHES)

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
$(GETTEXT_BUILD_DIR)/.configured: $(DL_DIR)/$(GETTEXT_SOURCE) $(GETTEXT_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GETTEXT_DIR) $(GETTEXT_BUILD_DIR)
	$(GETTEXT_UNZIP) $(DL_DIR)/$(GETTEXT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GETTEXT_PATCHES) | patch -d $(BUILD_DIR)/$(GETTEXT_DIR) -p1
	mv $(BUILD_DIR)/$(GETTEXT_DIR) $(GETTEXT_BUILD_DIR)
	(cd $(GETTEXT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GETTEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GETTEXT_LDFLAGS)" \
		ac_cv_func_getline=yes \
		am_cv_func_working_getline=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--$(GETTEXT_NLS)-nls \
	)
	touch $(GETTEXT_BUILD_DIR)/.configured

gettext-unpack: $(GETTEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GETTEXT_BUILD_DIR)/.built: $(GETTEXT_BUILD_DIR)/.configured
	rm -f $(GETTEXT_BUILD_DIR)/.built
	$(MAKE) -C $(GETTEXT_BUILD_DIR)
	touch $(GETTEXT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
gettext: $(GETTEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GETTEXT_BUILD_DIR)/.staged: $(GETTEXT_BUILD_DIR)/.built
	rm -f $(GETTEXT_BUILD_DIR)/.staged
	$(MAKE) -C $(GETTEXT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgettext*.la \
	      $(STAGING_LIB_DIR)/libintl.la \
	      $(STAGING_LIB_DIR)/libasprintf.la
	touch $(GETTEXT_BUILD_DIR)/.staged

gettext-stage: $(GETTEXT_BUILD_DIR)/.staged


#
# This rule creates a control file for ipkg.
#
$(GETTEXT_IPK_DIR)/CONTROL/control:
	@install -d $(GETTEXT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gettext" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GETTEXT_PRIORITY)" >>$@
	@echo "Section: $(GETTEXT_SECTION)" >>$@
	@echo "Version: $(GETTEXT_VERSION)-$(GETTEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GETTEXT_MAINTAINER)" >>$@
	@echo "Source: $(GETTEXT_SITE)/$(GETTEXT_SOURCE)" >>$@
	@echo "Description: $(GETTEXT_DESCRIPTION)" >>$@
	@echo "Depends: $(GETTEXT_DEPENDS)" >>$@
	@echo "Suggests: $(GETTEXT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GETTEXT_CONFLICTS)" >>$@


#
# This builds the IPK file.
#
# Binaries should be installed into $(GETTEXT_IPK_DIR)/opt/sbin or $(GETTEXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GETTEXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GETTEXT_IPK_DIR)/opt/etc/gettext/...
# Documentation files should be installed in $(GETTEXT_IPK_DIR)/opt/doc/gettext/...
# Daemon startup scripts should be installed in $(GETTEXT_IPK_DIR)/opt/etc/init.d/S??gettext
#
# You may need to patch your application to make it use these locations.
#
$(GETTEXT_IPK): $(GETTEXT_BUILD_DIR)/.built
	rm -rf $(GETTEXT_IPK_DIR) $(BUILD_DIR)/gettext_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GETTEXT_BUILD_DIR) DESTDIR=$(GETTEXT_IPK_DIR) install
#	install -d $(GETTEXT_IPK_DIR)/opt/etc/
#	install -m 755 $(GETTEXT_SOURCE_DIR)/gettext.conf $(GETTEXT_IPK_DIR)/opt/etc/gettext.conf
#	install -d $(GETTEXT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GETTEXT_SOURCE_DIR)/rc.gettext $(GETTEXT_IPK_DIR)/opt/etc/init.d/SXXgettext
	$(MAKE) $(GETTEXT_IPK_DIR)/CONTROL/control
#	install -m 644 $(GETTEXT_SOURCE_DIR)/postinst $(GETTEXT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(GETTEXT_SOURCE_DIR)/prerm $(GETTEXT_IPK_DIR)/CONTROL/prerm
#	echo $(GETTEXT_CONFFILES) | sed -e 's/ /\n/g' > $(GETTEXT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GETTEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gettext-ipk: $(GETTEXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gettext-clean:
	-$(MAKE) -C $(GETTEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gettext-dirclean:
	rm -rf $(BUILD_DIR)/$(GETTEXT_DIR) $(GETTEXT_BUILD_DIR) $(GETTEXT_IPK_DIR) $(GETTEXT_IPK)
