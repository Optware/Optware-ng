###########################################################
#
# heyu
#
###########################################################

#
# HEYU_VERSION, HEYU_SITE and HEYU_SOURCE define
# the upstream location of the source code for the package.
# HEYU_DIR is the directory which is created when the source
# archive is unpacked.
# HEYU_UNZIP is the command used to unzip the source.
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
HEYU_SITE=http://www.heyu.org/download/
HEYU_VERSION=2.0beta.6.2
HEYU_SOURCE=heyu-$(HEYU_VERSION).tgz
HEYU_DIR=heyu-$(HEYU_VERSION)
HEYU_UNZIP=zcat
HEYU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HEYU_DESCRIPTION=X10 home automation control using the CM11A
HEYU_SECTION=misc
HEYU_PRIORITY=optional
HEYU_DEPENDS=setserial
HEYU_SUGGESTS=
HEYU_CONFLICTS=

#
# HEYU_IPK_VERSION should be incremented when the ipk changes.
#
HEYU_IPK_VERSION=2

#
# HEYU_CONFFILES should be a list of user-editable files
HEYU_CONFFILES=/opt/etc/init.d/S99heyu #/opt/etc/heyu/x10.conf /opt/etc/heyu/x10.sched

#
# HEYU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HEYU_PATCHES=
#$(HEYU_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HEYU_CPPFLAGS=
HEYU_LDFLAGS=

#
# HEYU_BUILD_DIR is the directory in which the build is done.
# HEYU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HEYU_IPK_DIR is the directory in which the ipk is built.
# HEYU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HEYU_BUILD_DIR=$(BUILD_DIR)/heyu
HEYU_SOURCE_DIR=$(SOURCE_DIR)/heyu
HEYU_IPK_DIR=$(BUILD_DIR)/heyu-$(HEYU_VERSION)-ipk
HEYU_IPK=$(BUILD_DIR)/heyu_$(HEYU_VERSION)-$(HEYU_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: heyu-source heyu-unpack heyu heyu-stage heyu-ipk heyu-clean heyu-dirclean heyu-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HEYU_SOURCE):
	$(WGET) -P $(DL_DIR) $(HEYU_SITE)/$(HEYU_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
heyu-source: $(DL_DIR)/$(HEYU_SOURCE) $(HEYU_PATCHES)

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




$(HEYU_BUILD_DIR)/.configured: $(DL_DIR)/$(HEYU_SOURCE) $(HEYU_PATCHES) make/heyu.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(HEYU_DIR) $(HEYU_BUILD_DIR)
	$(HEYU_UNZIP) $(DL_DIR)/$(HEYU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HEYU_PATCHES)" ; \
		then cat $(HEYU_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HEYU_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HEYU_DIR)" != "$(HEYU_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(HEYU_DIR) $(HEYU_BUILD_DIR) ; \
	fi
	(cd $(HEYU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HEYU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HEYU_LDFLAGS)" \
		./Configure linux \
	)
#	$(PATCH_LIBTOOL) $(HEYU_BUILD_DIR)/libtool
	touch $(HEYU_BUILD_DIR)/.configured

heyu-unpack: $(HEYU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HEYU_BUILD_DIR)/.built: $(HEYU_BUILD_DIR)/.configured
	rm -f $(HEYU_BUILD_DIR)/.built
	$(MAKE) -C $(HEYU_BUILD_DIR) \
		CC=$(TARGET_CC) LD=$(TARGET_LD) \
		CFLAGS="$(STAGING_CPPFLAGS) -I$(HEYU_BUILD_DIR) \$$(DFLAGS) -DLOCKDIR=\\\"/opt/var/run/heyu\\\" -DSYSBASEDIR=\\\"/opt/etc/heyu\\\" -DSPOOLDIR=\\\"/opt/var/spool/heyu\\\" " \
		LDFLAGS="$(STAGING_LDFLAGS)"
	touch $(HEYU_BUILD_DIR)/.built

#
# This is the build convenience target.
#
heyu: $(HEYU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HEYU_BUILD_DIR)/.staged: $(HEYU_BUILD_DIR)/.built
	rm -f $(HEYU_BUILD_DIR)/.staged
	$(MAKE) -C $(HEYU_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(HEYU_BUILD_DIR)/.staged

heyu-stage: $(HEYU_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/heyu
#
$(HEYU_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: heyu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HEYU_PRIORITY)" >>$@
	@echo "Section: $(HEYU_SECTION)" >>$@
	@echo "Version: $(HEYU_VERSION)-$(HEYU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HEYU_MAINTAINER)" >>$@
	@echo "Source: $(HEYU_SITE)/$(HEYU_SOURCE)" >>$@
	@echo "Description: $(HEYU_DESCRIPTION)" >>$@
	@echo "Depends: $(HEYU_DEPENDS)" >>$@
	@echo "Suggests: $(HEYU_SUGGESTS)" >>$@
	@echo "Conflicts: $(HEYU_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HEYU_IPK_DIR)/opt/sbin or $(HEYU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HEYU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HEYU_IPK_DIR)/opt/etc/heyu/...
# Documentation files should be installed in $(HEYU_IPK_DIR)/opt/doc/heyu/...
# Daemon startup scripts should be installed in $(HEYU_IPK_DIR)/opt/etc/init.d/S??heyu
#
# You may need to patch your application to make it use these locations.
#
$(HEYU_IPK): $(HEYU_BUILD_DIR)/.built
	rm -rf $(HEYU_IPK_DIR) $(BUILD_DIR)/heyu_*_$(TARGET_ARCH).ipk
	install -d $(HEYU_IPK_DIR)/opt/bin
	install -d $(HEYU_IPK_DIR)/opt/man/man1
	install -d $(HEYU_IPK_DIR)/opt/man/man5
	install -d -m0777 $(HEYU_IPK_DIR)/opt/etc/heyu
	install -d -m1777 $(HEYU_IPK_DIR)/opt/var/spool/heyu
	install -d -m0777 $(HEYU_IPK_DIR)/opt/var/run/heyu
	install -m0644 $(HEYU_BUILD_DIR)/x10config.sample $(HEYU_IPK_DIR)/opt/etc/heyu/x10.conf.sample
	install -m0644 $(HEYU_BUILD_DIR)/x10.sched.sample $(HEYU_IPK_DIR)/opt/etc/heyu/
	install -m0755 $(HEYU_BUILD_DIR)/heyu $(HEYU_IPK_DIR)/opt/bin
	$(TARGET_STRIP) $(HEYU_IPK_DIR)/opt/bin/heyu
	install -m0644 $(HEYU_BUILD_DIR)/*.1 $(HEYU_IPK_DIR)/opt/man/man1/
	install -m0644 $(HEYU_BUILD_DIR)/*.5 $(HEYU_IPK_DIR)/opt/man/man5/
	install -d $(HEYU_IPK_DIR)/opt/etc/init.d
	install -m 755 $(HEYU_SOURCE_DIR)/rc.heyu $(HEYU_IPK_DIR)/opt/etc/init.d/S99heyu
	$(MAKE) $(HEYU_IPK_DIR)/CONTROL/control
	install -m 755 $(HEYU_SOURCE_DIR)/postinst $(HEYU_IPK_DIR)/CONTROL/postinst
	install -m 755 $(HEYU_SOURCE_DIR)/prerm $(HEYU_IPK_DIR)/CONTROL/prerm
	echo $(HEYU_CONFFILES) | sed -e 's/ /\n/g' > $(HEYU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HEYU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
heyu-ipk: $(HEYU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
heyu-clean:
	rm -f $(HEYU_BUILD_DIR)/.built
	-$(MAKE) -C $(HEYU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
heyu-dirclean:
	rm -rf $(BUILD_DIR)/$(HEYU_DIR) $(HEYU_BUILD_DIR) $(HEYU_IPK_DIR) $(HEYU_IPK)

#
# Some sanity check for the package.
#
heyu-check: $(HEYU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HEYU_IPK)
