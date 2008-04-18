###########################################################
#
# gphoto2
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
GPHOTO2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gphoto
GPHOTO2_VERSION=2.4.1
GPHOTO2_SOURCE=gphoto2-$(GPHOTO2_VERSION).tar.bz2
GPHOTO2_DIR=gphoto2-$(GPHOTO2_VERSION)
GPHOTO2_UNZIP=bzcat
GPHOTO2_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
GPHOTO2_DESCRIPTION=Command line digital camera software applications
GPHOTO2_SECTION=apps
GPHOTO2_PRIORITY=optional
GPHOTO2_DEPENDS=libgphoto2
GPHOTO2_SUGGESTS=
GPHOTO2_CONFLICTS=

#
# GPHOTO2_IPK_VERSION should be incremented when the ipk changes.
#
GPHOTO2_IPK_VERSION=1

#
# GPHOTO2_CONFFILES should be a list of user-editable files
GPHOTO2_CONFFILES=

#
# GPHOTO2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# GPHOTO2_PATCHES=$(GPHOTO2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GPHOTO2_CPPFLAGS=
GPHOTO2_LDFLAGS=

#
# GPHOTO2_BUILD_DIR is the directory in which the build is done.
# GPHOTO2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GPHOTO2_IPK_DIR is the directory in which the ipk is built.
# GPHOTO2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GPHOTO2_BUILD_DIR=$(BUILD_DIR)/gphoto2
GPHOTO2_SOURCE_DIR=$(SOURCE_DIR)/gphoto2
GPHOTO2_IPK_DIR=$(BUILD_DIR)/gphoto2-$(GPHOTO2_VERSION)-ipk
GPHOTO2_IPK=$(BUILD_DIR)/gphoto2_$(GPHOTO2_VERSION)-$(GPHOTO2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gphoto2-source gphoto2-unpack gphoto2 gphoto2-stage gphoto2-ipk gphoto2-clean gphoto2-dirclean gphoto2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GPHOTO2_SOURCE):
	$(WGET) -P $(DL_DIR) $(GPHOTO2_SITE)/$(GPHOTO2_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GPHOTO2_SOURCE)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gphoto2-source: $(DL_DIR)/$(GPHOTO2_SOURCE) $(GPHOTO2_PATCHES)

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
$(GPHOTO2_BUILD_DIR)/.configured: $(DL_DIR)/$(GPHOTO2_SOURCE) $(GPHOTO2_PATCHES) make/gphoto2.mk
	$(MAKE) libgphoto2-stage
	rm -rf $(BUILD_DIR)/$(GPHOTO2_DIR) $(GPHOTO2_BUILD_DIR)
	$(GPHOTO2_UNZIP) $(DL_DIR)/$(GPHOTO2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GPHOTO2_PATCHES)" ; \
		then cat $(GPHOTO2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GPHOTO2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GPHOTO2_DIR)" != "$(GPHOTO2_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GPHOTO2_DIR) $(GPHOTO2_BUILD_DIR) ; \
	fi
	(cd $(GPHOTO2_BUILD_DIR);					\
		PATH=$(STAGING_DIR)/opt/bin:$${PATH}			\
		$(TARGET_CONFIGURE_OPTS)				\
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GPHOTO2_CPPFLAGS)"	\
		LDFLAGS="$(STAGING_LDFLAGS) $(GPHOTO2_LDFLAGS)"		\
		POPT_CFLAGS=-I$(STAGING_DIR)/opt/include		\
		POPT_LIBS="-I$(STAGING_DIR)/opt/lib -lpopt"		\
		./configure						\
		--build=$(GNU_HOST_NAME)				\
		--host=$(GNU_TARGET_NAME)				\
		--target=$(GNU_TARGET_NAME)				\
		--prefix=/opt						\
		--with-libgphoto2=$(STAGING_PREFIX)			\
		--disable-nls						\
		--disable-static					\
	)
	$(PATCH_LIBTOOL) $(GPHOTO2_BUILD_DIR)/libtool
	touch $(GPHOTO2_BUILD_DIR)/.configured

gphoto2-unpack: $(GPHOTO2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GPHOTO2_BUILD_DIR)/.built: $(GPHOTO2_BUILD_DIR)/.configured
	rm -f $(GPHOTO2_BUILD_DIR)/.built
	$(MAKE) -C $(GPHOTO2_BUILD_DIR)
	touch $(GPHOTO2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
gphoto2: $(GPHOTO2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GPHOTO2_BUILD_DIR)/.staged: $(GPHOTO2_BUILD_DIR)/.built
	rm -f $(GPHOTO2_BUILD_DIR)/.staged
	$(MAKE) -C $(GPHOTO2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(GPHOTO2_BUILD_DIR)/.staged

gphoto2-stage: $(GPHOTO2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gphoto2
#
$(GPHOTO2_IPK_DIR)/CONTROL/control:
	@install -d $(GPHOTO2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gphoto2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GPHOTO2_PRIORITY)" >>$@
	@echo "Section: $(GPHOTO2_SECTION)" >>$@
	@echo "Version: $(GPHOTO2_VERSION)-$(GPHOTO2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GPHOTO2_MAINTAINER)" >>$@
	@echo "Source: $(GPHOTO2_SITE)/$(GPHOTO2_SOURCE)" >>$@
	@echo "Description: $(GPHOTO2_DESCRIPTION)" >>$@
	@echo "Depends: $(GPHOTO2_DEPENDS)" >>$@
	@echo "Suggests: $(GPHOTO2_SUGGESTS)" >>$@
	@echo "Conflicts: $(GPHOTO2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GPHOTO2_IPK_DIR)/opt/sbin or $(GPHOTO2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GPHOTO2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GPHOTO2_IPK_DIR)/opt/etc/gphoto2/...
# Documentation files should be installed in $(GPHOTO2_IPK_DIR)/opt/doc/gphoto2/...
# Daemon startup scripts should be installed in $(GPHOTO2_IPK_DIR)/opt/etc/init.d/S??gphoto2
#
# You may need to patch your application to make it use these locations.
#
$(GPHOTO2_IPK): $(GPHOTO2_BUILD_DIR)/.built
	rm -rf $(GPHOTO2_IPK_DIR) $(BUILD_DIR)/gphoto2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GPHOTO2_BUILD_DIR) DESTDIR=$(GPHOTO2_IPK_DIR) install-strip
	install -d $(GPHOTO2_IPK_DIR)/opt/etc/
#	install -m 644 $(GPHOTO2_SOURCE_DIR)/gphoto2.conf $(GPHOTO2_IPK_DIR)/opt/etc/gphoto2.conf
#	install -d $(GPHOTO2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GPHOTO2_SOURCE_DIR)/rc.gphoto2 $(GPHOTO2_IPK_DIR)/opt/etc/init.d/SXXgphoto2
	$(MAKE) $(GPHOTO2_IPK_DIR)/CONTROL/control
#	install -m 755 $(GPHOTO2_SOURCE_DIR)/postinst $(GPHOTO2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GPHOTO2_SOURCE_DIR)/prerm $(GPHOTO2_IPK_DIR)/CONTROL/prerm
	echo $(GPHOTO2_CONFFILES) | sed -e 's/ /\n/g' > $(GPHOTO2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GPHOTO2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gphoto2-ipk: $(GPHOTO2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gphoto2-clean:
	rm -f $(GPHOTO2_BUILD_DIR)/.built
	-$(MAKE) -C $(GPHOTO2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gphoto2-dirclean:
	rm -rf $(BUILD_DIR)/$(GPHOTO2_DIR) $(GPHOTO2_BUILD_DIR) $(GPHOTO2_IPK_DIR) $(GPHOTO2_IPK)
#
#
# Some sanity check for the package.
#
gphoto2-check: $(GPHOTO2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GPHOTO2_IPK)
