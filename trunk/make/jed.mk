###########################################################
#
# jed
#
###########################################################
#
# JED_VERSION, JED_SITE and JED_SOURCE define
# the upstream location of the source code for the package.
# JED_DIR is the directory which is created when the source
# archive is unpacked.
# JED_UNZIP is the command used to unzip the source.
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
JED_SITE=ftp://space.mit.edu/pub/davis/jed/v0.99
JED_VERSION=0.99.18
JED_UPSTREAM_VERSION=0.99-18
JED_SOURCE=jed-$(JED_UPSTREAM_VERSION).tar.bz2
JED_DIR=jed-$(JED_UPSTREAM_VERSION)
JED_UNZIP=bzcat
JED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
JED_DESCRIPTION=A powerful yet friendly text editor.
JED_SECTION=editor
JED_PRIORITY=optional
JED_DEPENDS=slang
JED_SUGGESTS=
JED_CONFLICTS=

#
# JED_IPK_VERSION should be incremented when the ipk changes.
#
JED_IPK_VERSION=1

#
# JED_CONFFILES should be a list of user-editable files
#JED_CONFFILES=/opt/etc/jed.conf /opt/etc/init.d/SXXjed

#
# JED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#JED_PATCHES=$(JED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JED_CPPFLAGS=
JED_LDFLAGS=

#
# JED_BUILD_DIR is the directory in which the build is done.
# JED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JED_IPK_DIR is the directory in which the ipk is built.
# JED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JED_BUILD_DIR=$(BUILD_DIR)/jed
JED_SOURCE_DIR=$(SOURCE_DIR)/jed
JED_IPK_DIR=$(BUILD_DIR)/jed-$(JED_VERSION)-ipk
JED_IPK=$(BUILD_DIR)/jed_$(JED_VERSION)-$(JED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: jed-source jed-unpack jed jed-stage jed-ipk jed-clean jed-dirclean jed-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JED_SOURCE):
	$(WGET) -P $(DL_DIR) $(JED_SITE)/$(JED_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(JED_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jed-source: $(DL_DIR)/$(JED_SOURCE) $(JED_PATCHES)

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
$(JED_BUILD_DIR)/.configured: $(DL_DIR)/$(JED_SOURCE) $(JED_PATCHES) make/jed.mk
	$(MAKE) slang-stage
	rm -rf $(BUILD_DIR)/$(JED_DIR) $(JED_BUILD_DIR)
	$(JED_UNZIP) $(DL_DIR)/$(JED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(JED_PATCHES)" ; \
		then cat $(JED_PATCHES) | \
		patch -d $(BUILD_DIR)/$(JED_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(JED_DIR)" != "$(JED_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(JED_DIR) $(JED_BUILD_DIR) ; \
	fi
	sed -i -e '/if.*\/chkslang/s/^/#/' \
	       -e 's/@RPATH@//' \
		$(JED_BUILD_DIR)/src/Makefile.in
	(cd $(JED_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JED_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(JED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-slang=$(STAGING_PREFIX) \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(JED_BUILD_DIR)/libtool
	touch $@

jed-unpack: $(JED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JED_BUILD_DIR)/.built: $(JED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(JED_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
jed: $(JED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(JED_BUILD_DIR)/.staged: $(JED_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(JED_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

jed-stage: $(JED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jed
#
$(JED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: jed" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JED_PRIORITY)" >>$@
	@echo "Section: $(JED_SECTION)" >>$@
	@echo "Version: $(JED_VERSION)-$(JED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JED_MAINTAINER)" >>$@
	@echo "Source: $(JED_SITE)/$(JED_SOURCE)" >>$@
	@echo "Description: $(JED_DESCRIPTION)" >>$@
	@echo "Depends: $(JED_DEPENDS)" >>$@
	@echo "Suggests: $(JED_SUGGESTS)" >>$@
	@echo "Conflicts: $(JED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JED_IPK_DIR)/opt/sbin or $(JED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JED_IPK_DIR)/opt/etc/jed/...
# Documentation files should be installed in $(JED_IPK_DIR)/opt/doc/jed/...
# Daemon startup scripts should be installed in $(JED_IPK_DIR)/opt/etc/init.d/S??jed
#
# You may need to patch your application to make it use these locations.
#
$(JED_IPK): $(JED_BUILD_DIR)/.built
	rm -rf $(JED_IPK_DIR) $(BUILD_DIR)/jed_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(JED_BUILD_DIR) DESTDIR=$(JED_IPK_DIR) install
	$(STRIP_COMMAND) $(JED_IPK_DIR)/opt/bin/jed
#	install -d $(JED_IPK_DIR)/opt/etc/
#	install -m 644 $(JED_SOURCE_DIR)/jed.conf $(JED_IPK_DIR)/opt/etc/jed.conf
#	install -d $(JED_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(JED_SOURCE_DIR)/rc.jed $(JED_IPK_DIR)/opt/etc/init.d/SXXjed
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(JED_IPK_DIR)/opt/etc/init.d/SXXjed
	$(MAKE) $(JED_IPK_DIR)/CONTROL/control
#	install -m 755 $(JED_SOURCE_DIR)/postinst $(JED_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(JED_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(JED_SOURCE_DIR)/prerm $(JED_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(JED_IPK_DIR)/CONTROL/prerm
	echo $(JED_CONFFILES) | sed -e 's/ /\n/g' > $(JED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jed-ipk: $(JED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jed-clean:
	rm -f $(JED_BUILD_DIR)/.built
	-$(MAKE) -C $(JED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jed-dirclean:
	rm -rf $(BUILD_DIR)/$(JED_DIR) $(JED_BUILD_DIR) $(JED_IPK_DIR) $(JED_IPK)
#
#
# Some sanity check for the package.
#
jed-check: $(JED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(JED_IPK)
