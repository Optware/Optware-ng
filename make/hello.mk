###########################################################
#
# hello
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
HELLO_SITE=http://ftp.gnu.org/gnu/hello
HELLO_VERSION=2.3
HELLO_SOURCE=hello-$(HELLO_VERSION).tar.gz
HELLO_DIR=hello-$(HELLO_VERSION)
HELLO_UNZIP=zcat
HELLO_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
HELLO_DESCRIPTION=The gnu implementation of the clasical 'hello world' example from Kerningham and Ritchie
HELLO_SECTION=misc
HELLO_PRIORITY=optional
HELLO_DEPENDS=
HELLO_SUGGESTS=
HELLO_CONFLICTS=

#
# HELLO_IPK_VERSION should be incremented when the ipk changes.
#
HELLO_IPK_VERSION=1

#
# HELLO_CONFFILES should be a list of user-editable files
# HELLO_CONFFILES=/opt/etc/hello.conf /opt/etc/init.d/SXXhello

#
# HELLO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# HELLO_PATCHES=$(HELLO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HELLO_CPPFLAGS=
HELLO_LDFLAGS=

#
# HELLO_BUILD_DIR is the directory in which the build is done.
# HELLO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HELLO_IPK_DIR is the directory in which the ipk is built.
# HELLO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HELLO_BUILD_DIR=$(BUILD_DIR)/hello
HELLO_SOURCE_DIR=$(SOURCE_DIR)/hello
HELLO_IPK_DIR=$(BUILD_DIR)/hello-$(HELLO_VERSION)-ipk
HELLO_IPK=$(BUILD_DIR)/hello_$(HELLO_VERSION)-$(HELLO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hello-source hello-unpack hello hello-stage hello-ipk hello-clean hello-dirclean hello-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HELLO_SOURCE):
	$(WGET) -P $(DL_DIR) $(HELLO_SITE)/$(HELLO_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(HELLO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hello-source: $(DL_DIR)/$(HELLO_SOURCE) $(HELLO_PATCHES)

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
$(HELLO_BUILD_DIR)/.configured: $(DL_DIR)/$(HELLO_SOURCE) $(HELLO_PATCHES) make/hello.mk
	rm -rf $(BUILD_DIR)/$(HELLO_DIR) $(HELLO_BUILD_DIR)
	$(HELLO_UNZIP) $(DL_DIR)/$(HELLO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HELLO_PATCHES)" ; \
		then cat $(HELLO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HELLO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HELLO_DIR)" != "$(HELLO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(HELLO_DIR) $(HELLO_BUILD_DIR) ; \
	fi
	(cd $(HELLO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HELLO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HELLO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(HELLO_BUILD_DIR)/libtool
	touch $@

hello-unpack: $(HELLO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HELLO_BUILD_DIR)/.built: $(HELLO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(HELLO_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
hello: $(HELLO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HELLO_BUILD_DIR)/.staged: $(HELLO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(HELLO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

hello-stage: $(HELLO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hello
#
$(HELLO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hello" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HELLO_PRIORITY)" >>$@
	@echo "Section: $(HELLO_SECTION)" >>$@
	@echo "Version: $(HELLO_VERSION)-$(HELLO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HELLO_MAINTAINER)" >>$@
	@echo "Source: $(HELLO_SITE)/$(HELLO_SOURCE)" >>$@
	@echo "Description: $(HELLO_DESCRIPTION)" >>$@
	@echo "Depends: $(HELLO_DEPENDS)" >>$@
	@echo "Suggests: $(HELLO_SUGGESTS)" >>$@
	@echo "Conflicts: $(HELLO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HELLO_IPK_DIR)/opt/sbin or $(HELLO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HELLO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HELLO_IPK_DIR)/opt/etc/hello/...
# Documentation files should be installed in $(HELLO_IPK_DIR)/opt/doc/hello/...
# Daemon startup scripts should be installed in $(HELLO_IPK_DIR)/opt/etc/init.d/S??hello
#
# You may need to patch your application to make it use these locations.
#
$(HELLO_IPK): $(HELLO_BUILD_DIR)/.built
	rm -rf $(HELLO_IPK_DIR) $(BUILD_DIR)/hello_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HELLO_BUILD_DIR) DESTDIR=$(HELLO_IPK_DIR) install-strip
#	install -d $(HELLO_IPK_DIR)/opt/etc/
#	install -m 644 $(HELLO_SOURCE_DIR)/hello.conf $(HELLO_IPK_DIR)/opt/etc/hello.conf
#	install -d $(HELLO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HELLO_SOURCE_DIR)/rc.hello $(HELLO_IPK_DIR)/opt/etc/init.d/SXXhello
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HELLO_IPK_DIR)/opt/etc/init.d/SXXhello
	$(MAKE) $(HELLO_IPK_DIR)/CONTROL/control
#	install -m 755 $(HELLO_SOURCE_DIR)/postinst $(HELLO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HELLO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HELLO_SOURCE_DIR)/prerm $(HELLO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HELLO_IPK_DIR)/CONTROL/prerm
#	echo $(HELLO_CONFFILES) | sed -e 's/ /\n/g' > $(HELLO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HELLO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hello-ipk: $(HELLO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hello-clean:
	rm -f $(HELLO_BUILD_DIR)/.built
	-$(MAKE) -C $(HELLO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hello-dirclean:
	rm -rf $(BUILD_DIR)/$(HELLO_DIR) $(HELLO_BUILD_DIR) $(HELLO_IPK_DIR) $(HELLO_IPK)
#
#
# Some sanity check for the package.
#
hello-check: $(HELLO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HELLO_IPK)
