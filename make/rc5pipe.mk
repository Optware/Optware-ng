###########################################################
#
# rc5pipe
#
###########################################################
#
# RC5PIPE_VERSION, RC5PIPE_SITE and RC5PIPE_SOURCE define
# the upstream location of the source code for the package.
# RC5PIPE_DIR is the directory which is created when the source
# archive is unpacked.
# RC5PIPE_UNZIP is the command used to unzip the source.
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
RC5PIPE_SITE=http://www.hcsw.org/downloads
RC5PIPE_VERSION=1.1
RC5PIPE_SOURCE=rc5pipe-$(RC5PIPE_VERSION).tgz
RC5PIPE_DIR=rc5pipe
RC5PIPE_UNZIP=zcat
RC5PIPE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RC5PIPE_DESCRIPTION=a small unix utility that will decrypt everthing from stdin to stdout using the algorithm RC5-32/12/16
RC5PIPE_SECTION=utils
RC5PIPE_PRIORITY=optional
RC5PIPE_DEPENDS=
RC5PIPE_SUGGESTS=
RC5PIPE_CONFLICTS=

#
# RC5PIPE_IPK_VERSION should be incremented when the ipk changes.
#
RC5PIPE_IPK_VERSION=1

#
# RC5PIPE_CONFFILES should be a list of user-editable files
#RC5PIPE_CONFFILES=/opt/etc/rc5pipe.conf /opt/etc/init.d/SXXrc5pipe

#
# RC5PIPE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RC5PIPE_PATCHES=$(RC5PIPE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RC5PIPE_CPPFLAGS=
RC5PIPE_LDFLAGS=

#
# RC5PIPE_BUILD_DIR is the directory in which the build is done.
# RC5PIPE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RC5PIPE_IPK_DIR is the directory in which the ipk is built.
# RC5PIPE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RC5PIPE_BUILD_DIR=$(BUILD_DIR)/rc5pipe
RC5PIPE_SOURCE_DIR=$(SOURCE_DIR)/rc5pipe
RC5PIPE_IPK_DIR=$(BUILD_DIR)/rc5pipe-$(RC5PIPE_VERSION)-ipk
RC5PIPE_IPK=$(BUILD_DIR)/rc5pipe_$(RC5PIPE_VERSION)-$(RC5PIPE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rc5pipe-source rc5pipe-unpack rc5pipe rc5pipe-stage rc5pipe-ipk rc5pipe-clean rc5pipe-dirclean rc5pipe-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RC5PIPE_SOURCE):
	$(WGET) -P $(@D) $(RC5PIPE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rc5pipe-source: $(DL_DIR)/$(RC5PIPE_SOURCE) $(RC5PIPE_PATCHES)

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
$(RC5PIPE_BUILD_DIR)/.configured: $(DL_DIR)/$(RC5PIPE_SOURCE) $(RC5PIPE_PATCHES) make/rc5pipe.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RC5PIPE_DIR) $(@D)
	$(RC5PIPE_UNZIP) $(DL_DIR)/$(RC5PIPE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RC5PIPE_PATCHES)" ; \
		then cat $(RC5PIPE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RC5PIPE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RC5PIPE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RC5PIPE_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RC5PIPE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RC5PIPE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

rc5pipe-unpack: $(RC5PIPE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RC5PIPE_BUILD_DIR)/.built: $(RC5PIPE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RC5PIPE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RC5PIPE_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(RC5PIPE_CPPFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) $(RC5PIPE_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
rc5pipe: $(RC5PIPE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(RC5PIPE_BUILD_DIR)/.staged: $(RC5PIPE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#rc5pipe-stage: $(RC5PIPE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rc5pipe
#
$(RC5PIPE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rc5pipe" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RC5PIPE_PRIORITY)" >>$@
	@echo "Section: $(RC5PIPE_SECTION)" >>$@
	@echo "Version: $(RC5PIPE_VERSION)-$(RC5PIPE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RC5PIPE_MAINTAINER)" >>$@
	@echo "Source: $(RC5PIPE_SITE)/$(RC5PIPE_SOURCE)" >>$@
	@echo "Description: $(RC5PIPE_DESCRIPTION)" >>$@
	@echo "Depends: $(RC5PIPE_DEPENDS)" >>$@
	@echo "Suggests: $(RC5PIPE_SUGGESTS)" >>$@
	@echo "Conflicts: $(RC5PIPE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RC5PIPE_IPK_DIR)/opt/sbin or $(RC5PIPE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RC5PIPE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RC5PIPE_IPK_DIR)/opt/etc/rc5pipe/...
# Documentation files should be installed in $(RC5PIPE_IPK_DIR)/opt/doc/rc5pipe/...
# Daemon startup scripts should be installed in $(RC5PIPE_IPK_DIR)/opt/etc/init.d/S??rc5pipe
#
# You may need to patch your application to make it use these locations.
#
$(RC5PIPE_IPK): $(RC5PIPE_BUILD_DIR)/.built
	rm -rf $(RC5PIPE_IPK_DIR) $(BUILD_DIR)/rc5pipe_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(RC5PIPE_BUILD_DIR) DESTDIR=$(RC5PIPE_IPK_DIR) install-strip
	install -d $(RC5PIPE_IPK_DIR)/opt/bin/
	install -m 755 $(RC5PIPE_BUILD_DIR)/rc5pipe $(RC5PIPE_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(RC5PIPE_IPK_DIR)/opt/bin/rc5pipe
	install -d $(RC5PIPE_IPK_DIR)/opt/share/doc/rc5pipe
	install -m 644 $(RC5PIPE_BUILD_DIR)/[CLR]* $(RC5PIPE_IPK_DIR)/opt/share/doc/rc5pipe/
	$(MAKE) $(RC5PIPE_IPK_DIR)/CONTROL/control
	echo $(RC5PIPE_CONFFILES) | sed -e 's/ /\n/g' > $(RC5PIPE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RC5PIPE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rc5pipe-ipk: $(RC5PIPE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rc5pipe-clean:
	rm -f $(RC5PIPE_BUILD_DIR)/.built
	-$(MAKE) -C $(RC5PIPE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rc5pipe-dirclean:
	rm -rf $(BUILD_DIR)/$(RC5PIPE_DIR) $(RC5PIPE_BUILD_DIR) $(RC5PIPE_IPK_DIR) $(RC5PIPE_IPK)
#
#
# Some sanity check for the package.
#
rc5pipe-check: $(RC5PIPE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
