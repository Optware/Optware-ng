###########################################################
#
# open2300
#
###########################################################
#
# OPEN2300_VERSION, OPEN2300_SITE and OPEN2300_SOURCE define
# the upstream location of the source code for the package.
# OPEN2300_DIR is the directory which is created when the source
# archive is unpacked.
# OPEN2300_UNZIP is the command used to unzip the source.
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
OPEN2300_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/open2300
OPEN2300_VERSION=1.10
OPEN2300_SOURCE=open2300-$(OPEN2300_VERSION).tar.gz
OPEN2300_DIR=open2300-$(OPEN2300_VERSION)
OPEN2300_UNZIP=zcat
OPEN2300_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPEN2300_DESCRIPTION=Open2300 is a package of software tools that reads (and writes) data from a Lacrosse WS2300/WS2305/WS2310/WS2315 Weather Station.
OPEN2300_SECTION=misc
OPEN2300_PRIORITY=optional
OPEN2300_DEPENDS=
OPEN2300_SUGGESTS=
OPEN2300_CONFLICTS=

#
# OPEN2300_IPK_VERSION should be incremented when the ipk changes.
#
OPEN2300_IPK_VERSION=1

#
# OPEN2300_CONFFILES should be a list of user-editable files
#OPEN2300_CONFFILES=/opt/etc/open2300.conf /opt/etc/init.d/SXXopen2300

#
# OPEN2300_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPEN2300_PATCHES=$(OPEN2300_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPEN2300_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/mysql
OPEN2300_LDFLAGS=

#
# OPEN2300_BUILD_DIR is the directory in which the build is done.
# OPEN2300_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPEN2300_IPK_DIR is the directory in which the ipk is built.
# OPEN2300_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPEN2300_BUILD_DIR=$(BUILD_DIR)/open2300
OPEN2300_SOURCE_DIR=$(SOURCE_DIR)/open2300
OPEN2300_IPK_DIR=$(BUILD_DIR)/open2300-$(OPEN2300_VERSION)-ipk
OPEN2300_IPK=$(BUILD_DIR)/open2300_$(OPEN2300_VERSION)-$(OPEN2300_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: open2300-source open2300-unpack open2300 open2300-stage open2300-ipk open2300-clean open2300-dirclean open2300-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPEN2300_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPEN2300_SITE)/$(OPEN2300_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(OPEN2300_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
open2300-source: $(DL_DIR)/$(OPEN2300_SOURCE) $(OPEN2300_PATCHES)

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
$(OPEN2300_BUILD_DIR)/.configured: $(DL_DIR)/$(OPEN2300_SOURCE) $(OPEN2300_PATCHES) make/open2300.mk
	$(MAKE) mysql-stage postgresql-stage
	rm -rf $(BUILD_DIR)/$(OPEN2300_DIR) $(OPEN2300_BUILD_DIR)
	$(OPEN2300_UNZIP) $(DL_DIR)/$(OPEN2300_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPEN2300_PATCHES)" ; \
		then cat $(OPEN2300_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPEN2300_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPEN2300_DIR)" != "$(OPEN2300_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPEN2300_DIR) $(OPEN2300_BUILD_DIR) ; \
	fi
	sed -i -e 's|/usr/|$(STAGING_PREFIX)/|g' \
	       -e '/CC_LDFLAGS/s|$$| $$(LDFLAGS)|' \
	       $(OPEN2300_BUILD_DIR)/Makefile
#	(cd $(OPEN2300_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPEN2300_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPEN2300_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(OPEN2300_BUILD_DIR)/libtool
	touch $@

open2300-unpack: $(OPEN2300_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPEN2300_BUILD_DIR)/.built: $(OPEN2300_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(OPEN2300_BUILD_DIR) all mysql2300 pgsql2300 \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPEN2300_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPEN2300_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
open2300: $(OPEN2300_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPEN2300_BUILD_DIR)/.staged: $(OPEN2300_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(OPEN2300_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

open2300-stage: $(OPEN2300_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/open2300
#
$(OPEN2300_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: open2300" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPEN2300_PRIORITY)" >>$@
	@echo "Section: $(OPEN2300_SECTION)" >>$@
	@echo "Version: $(OPEN2300_VERSION)-$(OPEN2300_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPEN2300_MAINTAINER)" >>$@
	@echo "Source: $(OPEN2300_SITE)/$(OPEN2300_SOURCE)" >>$@
	@echo "Description: $(OPEN2300_DESCRIPTION)" >>$@
	@echo "Depends: $(OPEN2300_DEPENDS)" >>$@
	@echo "Suggests: $(OPEN2300_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPEN2300_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPEN2300_IPK_DIR)/opt/sbin or $(OPEN2300_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPEN2300_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPEN2300_IPK_DIR)/opt/etc/open2300/...
# Documentation files should be installed in $(OPEN2300_IPK_DIR)/opt/doc/open2300/...
# Daemon startup scripts should be installed in $(OPEN2300_IPK_DIR)/opt/etc/init.d/S??open2300
#
# You may need to patch your application to make it use these locations.
#
$(OPEN2300_IPK): $(OPEN2300_BUILD_DIR)/.built
	rm -rf $(OPEN2300_IPK_DIR) $(BUILD_DIR)/open2300_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OPEN2300_BUILD_DIR) install \
		prefix=$(OPEN2300_IPK_DIR)/opt \
		;
	install -m 755 $(OPEN2300_BUILD_DIR)/mysql2300 $(OPEN2300_IPK_DIR)/opt/bin
	install -m 755 $(OPEN2300_BUILD_DIR)/pgsql2300 $(OPEN2300_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(OPEN2300_IPK_DIR)/opt/bin/*2300
	install -d $(OPEN2300_IPK_DIR)/opt/etc/
	install -m 644 $(OPEN2300_BUILD_DIR)/open2300-dist.conf $(OPEN2300_IPK_DIR)/opt/etc/
#	install -m 644 $(OPEN2300_SOURCE_DIR)/open2300.conf $(OPEN2300_IPK_DIR)/opt/etc/open2300.conf
#	install -d $(OPEN2300_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OPEN2300_SOURCE_DIR)/rc.open2300 $(OPEN2300_IPK_DIR)/opt/etc/init.d/SXXopen2300
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPEN2300_IPK_DIR)/opt/etc/init.d/SXXopen2300
	$(MAKE) $(OPEN2300_IPK_DIR)/CONTROL/control
#	install -m 755 $(OPEN2300_SOURCE_DIR)/postinst $(OPEN2300_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPEN2300_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OPEN2300_SOURCE_DIR)/prerm $(OPEN2300_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPEN2300_IPK_DIR)/CONTROL/prerm
	echo $(OPEN2300_CONFFILES) | sed -e 's/ /\n/g' > $(OPEN2300_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPEN2300_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
open2300-ipk: $(OPEN2300_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
open2300-clean:
	rm -f $(OPEN2300_BUILD_DIR)/.built
	-$(MAKE) -C $(OPEN2300_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
open2300-dirclean:
	rm -rf $(BUILD_DIR)/$(OPEN2300_DIR) $(OPEN2300_BUILD_DIR) $(OPEN2300_IPK_DIR) $(OPEN2300_IPK)
#
#
# Some sanity check for the package.
#
open2300-check: $(OPEN2300_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPEN2300_IPK)
