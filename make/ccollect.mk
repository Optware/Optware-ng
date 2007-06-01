###########################################################
#
# ccollect
#
###########################################################
#
# CCOLLECT_VERSION, CCOLLECT_SITE and CCOLLECT_SOURCE define
# the upstream location of the source code for the package.
# CCOLLECT_DIR is the directory which is created when the source
# archive is unpacked.
# CCOLLECT_UNZIP is the command used to unzip the source.
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
CCOLLECT_SITE=http://unix.schottelius.org/ccollect
CCOLLECT_VERSION=0.5.2
CCOLLECT_SOURCE=ccollect-$(CCOLLECT_VERSION).tar.bz2
CCOLLECT_DIR=ccollect-$(CCOLLECT_VERSION)
CCOLLECT_UNZIP=bzcat
CCOLLECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CCOLLECT_DESCRIPTION=(pseudo) incremental (parallel) backup.
CCOLLECT_SECTION=net
CCOLLECT_PRIORITY=optional
CCOLLECT_DEPENDS=rsync, mktemp
CCOLLECT_SUGGESTS=coreutils, cwrsync
CCOLLECT_CONFLICTS=

#
# CCOLLECT_IPK_VERSION should be incremented when the ipk changes.
#
CCOLLECT_IPK_VERSION=1

#
# CCOLLECT_CONFFILES should be a list of user-editable files
CCOLLECT_CONFFILES=/opt/etc/ccollect/defaults/pre_exec \
		/opt/etc/ccollect/defaults/post_exec \
		/opt/etc/ccollect/defaults/intervals/daily \
		/opt/etc/ccollect/defaults/intervals/weekly \
		/opt/etc/ccollect/defaults/intervals/monthly



#
# CCOLLECT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CCOLLECT_PATCHES=$(CCOLLECT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CCOLLECT_CPPFLAGS=
CCOLLECT_LDFLAGS=

#
# CCOLLECT_BUILD_DIR is the directory in which the build is done.
# CCOLLECT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CCOLLECT_IPK_DIR is the directory in which the ipk is built.
# CCOLLECT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CCOLLECT_BUILD_DIR=$(BUILD_DIR)/ccollect
CCOLLECT_SOURCE_DIR=$(SOURCE_DIR)/ccollect
CCOLLECT_IPK_DIR=$(BUILD_DIR)/ccollect-$(CCOLLECT_VERSION)-ipk
CCOLLECT_IPK=$(BUILD_DIR)/ccollect_$(CCOLLECT_VERSION)-$(CCOLLECT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ccollect-source ccollect-unpack ccollect ccollect-stage ccollect-ipk ccollect-clean ccollect-dirclean ccollect-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CCOLLECT_SOURCE):
	$(WGET) -P $(DL_DIR) $(CCOLLECT_SITE)/$(CCOLLECT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CCOLLECT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ccollect-source: $(DL_DIR)/$(CCOLLECT_SOURCE) $(CCOLLECT_PATCHES)

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
$(CCOLLECT_BUILD_DIR)/.configured: $(DL_DIR)/$(CCOLLECT_SOURCE) $(CCOLLECT_PATCHES) make/ccollect.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CCOLLECT_DIR) $(CCOLLECT_BUILD_DIR)
	$(CCOLLECT_UNZIP) $(DL_DIR)/$(CCOLLECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CCOLLECT_PATCHES)" ; \
		then cat $(CCOLLECT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CCOLLECT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CCOLLECT_DIR)" != "$(CCOLLECT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CCOLLECT_DIR) $(CCOLLECT_BUILD_DIR) ; \
	fi
	(cd $(CCOLLECT_BUILD_DIR); \
		sed -i -e 's|/etc/ccollect|/opt/etc/ccollect|' \
			-e 's|mktemp|/opt/bin/mktemp|' ccollect.sh \
	)
	touch $@

ccollect-unpack: $(CCOLLECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CCOLLECT_BUILD_DIR)/.built: $(CCOLLECT_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(CCOLLECT_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
ccollect: $(CCOLLECT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CCOLLECT_BUILD_DIR)/.staged: $(CCOLLECT_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(CCOLLECT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

ccollect-stage: $(CCOLLECT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ccollect
#
$(CCOLLECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ccollect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CCOLLECT_PRIORITY)" >>$@
	@echo "Section: $(CCOLLECT_SECTION)" >>$@
	@echo "Version: $(CCOLLECT_VERSION)-$(CCOLLECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CCOLLECT_MAINTAINER)" >>$@
	@echo "Source: $(CCOLLECT_SITE)/$(CCOLLECT_SOURCE)" >>$@
	@echo "Description: $(CCOLLECT_DESCRIPTION)" >>$@
	@echo "Depends: $(CCOLLECT_DEPENDS)" >>$@
	@echo "Suggests: $(CCOLLECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CCOLLECT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CCOLLECT_IPK_DIR)/opt/sbin or $(CCOLLECT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CCOLLECT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CCOLLECT_IPK_DIR)/opt/etc/ccollect/...
# Documentation files should be installed in $(CCOLLECT_IPK_DIR)/opt/doc/ccollect/...
# Daemon startup scripts should be installed in $(CCOLLECT_IPK_DIR)/opt/etc/init.d/S??ccollect
#
# You may need to patch your application to make it use these locations.
#
$(CCOLLECT_IPK): $(CCOLLECT_BUILD_DIR)/.built
	rm -rf $(CCOLLECT_IPK_DIR) $(BUILD_DIR)/ccollect_*_$(TARGET_ARCH).ipk
	install -d $(CCOLLECT_IPK_DIR)/opt/bin
	install -m 755 $(CCOLLECT_BUILD_DIR)/ccollect.sh $(CCOLLECT_IPK_DIR)/opt/bin
	install -d $(CCOLLECT_IPK_DIR)/opt/etc/ccollect/sources
	install -d $(CCOLLECT_IPK_DIR)/opt/etc/ccollect/defaults/intervals
	install -m 755 $(CCOLLECT_BUILD_DIR)/conf/defaults/pre_exec  \
		$(CCOLLECT_IPK_DIR)/opt/etc/ccollect/defaults/
	install -m 755 $(CCOLLECT_BUILD_DIR)/conf/defaults/post_exec  \
		$(CCOLLECT_IPK_DIR)/opt/etc/ccollect/defaults/
	install -m 755 $(CCOLLECT_BUILD_DIR)/conf/defaults/intervals/daily \
		$(CCOLLECT_IPK_DIR)/opt/etc/ccollect/defaults/intervals/
	install -m 755 $(CCOLLECT_BUILD_DIR)/conf/defaults/intervals/weekly \
		$(CCOLLECT_IPK_DIR)/opt/etc/ccollect/defaults/intervals/
	install -m 755 $(CCOLLECT_BUILD_DIR)/conf/defaults/intervals/monthly \
		$(CCOLLECT_IPK_DIR)/opt/etc/ccollect/defaults/intervals/
	install -d $(CCOLLECT_IPK_DIR)/opt/man/man1
	install -m 644 $(CCOLLECT_BUILD_DIR)/doc/man/ccollect.man $(CCOLLECT_IPK_DIR)/opt/man/man1/ccollect.1
#	install -m 644 $(CCOLLECT_SOURCE_DIR)/ccollect.conf $(CCOLLECT_IPK_DIR)/opt/etc/ccollect/ccollect.conf
#	install -d $(CCOLLECT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CCOLLECT_SOURCE_DIR)/rc.ccollect $(CCOLLECT_IPK_DIR)/opt/etc/init.d/SXXccollect
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CCOLLECT_IPK_DIR)/opt/etc/init.d/SXXccollect
	$(MAKE) $(CCOLLECT_IPK_DIR)/CONTROL/control
#	install -m 755 $(CCOLLECT_SOURCE_DIR)/postinst $(CCOLLECT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CCOLLECT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CCOLLECT_SOURCE_DIR)/prerm $(CCOLLECT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CCOLLECT_IPK_DIR)/CONTROL/prerm
	echo $(CCOLLECT_CONFFILES) | sed -e 's/ /\n/g' > $(CCOLLECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CCOLLECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ccollect-ipk: $(CCOLLECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ccollect-clean:
	rm -f $(CCOLLECT_BUILD_DIR)/.built
	-$(MAKE) -C $(CCOLLECT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ccollect-dirclean:
	rm -rf $(BUILD_DIR)/$(CCOLLECT_DIR) $(CCOLLECT_BUILD_DIR) $(CCOLLECT_IPK_DIR) $(CCOLLECT_IPK)
#
#
# Some sanity check for the package.
#
ccollect-check: $(CCOLLECT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CCOLLECT_IPK)
