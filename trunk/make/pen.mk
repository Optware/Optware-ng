###########################################################
#
# pen
#
###########################################################
#
# PEN_VERSION, PEN_SITE and PEN_SOURCE define
# the upstream location of the source code for the package.
# PEN_DIR is the directory which is created when the source
# archive is unpacked.
# PEN_UNZIP is the command used to unzip the source.
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
PEN_SITE=http://siag.nu/pub/pen
PEN_VERSION=0.17.3
PEN_SOURCE=pen-$(PEN_VERSION).tar.gz
PEN_DIR=pen-$(PEN_VERSION)
PEN_UNZIP=zcat
PEN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PEN_DESCRIPTION=A load balancer for "simple" tcp based protocols such as http or smtp.
PEN_SECTION=net
PEN_PRIORITY=optional
PEN_DEPENDS=
PEN_SUGGESTS=
PEN_CONFLICTS=

#
# PEN_IPK_VERSION should be incremented when the ipk changes.
#
PEN_IPK_VERSION=1

#
# PEN_CONFFILES should be a list of user-editable files
#PEN_CONFFILES=/opt/etc/pen.conf /opt/etc/init.d/SXXpen

#
# PEN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PEN_PATCHES=$(PEN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PEN_CPPFLAGS=
PEN_LDFLAGS=

#
# PEN_BUILD_DIR is the directory in which the build is done.
# PEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PEN_IPK_DIR is the directory in which the ipk is built.
# PEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PEN_BUILD_DIR=$(BUILD_DIR)/pen
PEN_SOURCE_DIR=$(SOURCE_DIR)/pen
PEN_IPK_DIR=$(BUILD_DIR)/pen-$(PEN_VERSION)-ipk
PEN_IPK=$(BUILD_DIR)/pen_$(PEN_VERSION)-$(PEN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pen-source pen-unpack pen pen-stage pen-ipk pen-clean pen-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PEN_SOURCE):
	$(WGET) -P $(@D) $(PEN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pen-source: $(DL_DIR)/$(PEN_SOURCE) $(PEN_PATCHES)

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
$(PEN_BUILD_DIR)/.configured: $(DL_DIR)/$(PEN_SOURCE) $(PEN_PATCHES) make/pen.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PEN_DIR) $(PEN_BUILD_DIR)
	$(PEN_UNZIP) $(DL_DIR)/$(PEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PEN_PATCHES)" ; \
		then cat $(PEN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PEN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PEN_DIR)" != "$(PEN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PEN_DIR) $(PEN_BUILD_DIR) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PEN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PEN_LDFLAGS)" \
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

pen-unpack: $(PEN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PEN_BUILD_DIR)/.built: $(PEN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
pen: $(PEN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PEN_BUILD_DIR)/.staged: $(PEN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

pen-stage: $(PEN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pen
#
$(PEN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PEN_PRIORITY)" >>$@
	@echo "Section: $(PEN_SECTION)" >>$@
	@echo "Version: $(PEN_VERSION)-$(PEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PEN_MAINTAINER)" >>$@
	@echo "Source: $(PEN_SITE)/$(PEN_SOURCE)" >>$@
	@echo "Description: $(PEN_DESCRIPTION)" >>$@
	@echo "Depends: $(PEN_DEPENDS)" >>$@
	@echo "Suggests: $(PEN_SUGGESTS)" >>$@
	@echo "Conflicts: $(PEN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PEN_IPK_DIR)/opt/sbin or $(PEN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PEN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PEN_IPK_DIR)/opt/etc/pen/...
# Documentation files should be installed in $(PEN_IPK_DIR)/opt/doc/pen/...
# Daemon startup scripts should be installed in $(PEN_IPK_DIR)/opt/etc/init.d/S??pen
#
# You may need to patch your application to make it use these locations.
#
$(PEN_IPK): $(PEN_BUILD_DIR)/.built
	rm -rf $(PEN_IPK_DIR) $(BUILD_DIR)/pen_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PEN_BUILD_DIR) DESTDIR=$(PEN_IPK_DIR) install
	$(STRIP_COMMAND) $(PEN_IPK_DIR)/opt/bin/*
#	install -d $(PEN_IPK_DIR)/opt/etc/
#	install -m 644 $(PEN_SOURCE_DIR)/pen.conf $(PEN_IPK_DIR)/opt/etc/pen.conf
#	install -d $(PEN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PEN_SOURCE_DIR)/rc.pen $(PEN_IPK_DIR)/opt/etc/init.d/SXXpen
	$(MAKE) $(PEN_IPK_DIR)/CONTROL/control
#	install -m 755 $(PEN_SOURCE_DIR)/postinst $(PEN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PEN_SOURCE_DIR)/prerm $(PEN_IPK_DIR)/CONTROL/prerm
	echo $(PEN_CONFFILES) | sed -e 's/ /\n/g' > $(PEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pen-ipk: $(PEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pen-clean:
	rm -f $(PEN_BUILD_DIR)/.built
	-$(MAKE) -C $(PEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pen-dirclean:
	rm -rf $(BUILD_DIR)/$(PEN_DIR) $(PEN_BUILD_DIR) $(PEN_IPK_DIR) $(PEN_IPK)

#
# Some sanity check for the package.
#
pen-check: $(PEN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PEN_IPK)
