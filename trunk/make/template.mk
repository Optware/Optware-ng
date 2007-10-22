###########################################################
#
# <foo>
#
###########################################################

# You must replace "<foo>" and "<FOO>" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# <FOO>_VERSION, <FOO>_SITE and <FOO>_SOURCE define
# the upstream location of the source code for the package.
# <FOO>_DIR is the directory which is created when the source
# archive is unpacked.
# <FOO>_UNZIP is the command used to unzip the source.
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
<FOO>_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/<foo>
<FOO>_VERSION=3.2.1
<FOO>_SOURCE=<foo>-$(<FOO>_VERSION).tar.gz
<FOO>_DIR=<foo>-$(<FOO>_VERSION)
<FOO>_UNZIP=zcat
<FOO>_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
<FOO>_DESCRIPTION=Describe <foo> here.
<FOO>_SECTION=
<FOO>_PRIORITY=optional
<FOO>_DEPENDS=
<FOO>_SUGGESTS=
<FOO>_CONFLICTS=

#
# <FOO>_IPK_VERSION should be incremented when the ipk changes.
#
<FOO>_IPK_VERSION=1

#
# <FOO>_CONFFILES should be a list of user-editable files
<FOO>_CONFFILES=/opt/etc/<foo>.conf /opt/etc/init.d/SXX<foo>

#
# <FOO>_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
<FOO>_PATCHES=$(<FOO>_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
<FOO>_CPPFLAGS=
<FOO>_LDFLAGS=

#
# <FOO>_BUILD_DIR is the directory in which the build is done.
# <FOO>_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# <FOO>_IPK_DIR is the directory in which the ipk is built.
# <FOO>_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
<FOO>_BUILD_DIR=$(BUILD_DIR)/<foo>
<FOO>_SOURCE_DIR=$(SOURCE_DIR)/<foo>
<FOO>_IPK_DIR=$(BUILD_DIR)/<foo>-$(<FOO>_VERSION)-ipk
<FOO>_IPK=$(BUILD_DIR)/<foo>_$(<FOO>_VERSION)-$(<FOO>_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: <foo>-source <foo>-unpack <foo> <foo>-stage <foo>-ipk <foo>-clean <foo>-dirclean <foo>-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(<FOO>_SOURCE):
	$(WGET) -P $(DL_DIR) $(<FOO>_SITE)/$(<FOO>_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(<FOO>_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
<foo>-source: $(DL_DIR)/$(<FOO>_SOURCE) $(<FOO>_PATCHES)

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
$(<FOO>_BUILD_DIR)/.configured: $(DL_DIR)/$(<FOO>_SOURCE) $(<FOO>_PATCHES) make/<foo>.mk
	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(<FOO>_DIR) $(<FOO>_BUILD_DIR)
	$(<FOO>_UNZIP) $(DL_DIR)/$(<FOO>_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(<FOO>_PATCHES)" ; \
		then cat $(<FOO>_PATCHES) | \
		patch -d $(BUILD_DIR)/$(<FOO>_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(<FOO>_DIR)" != "$(<FOO>_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(<FOO>_DIR) $(<FOO>_BUILD_DIR) ; \
	fi
	(cd $(<FOO>_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(<FOO>_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(<FOO>_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(<FOO>_BUILD_DIR)/libtool
	touch $@

<foo>-unpack: $(<FOO>_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(<FOO>_BUILD_DIR)/.built: $(<FOO>_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(<FOO>_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
<foo>: $(<FOO>_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(<FOO>_BUILD_DIR)/.staged: $(<FOO>_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(<FOO>_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

<foo>-stage: $(<FOO>_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<foo>
#
$(<FOO>_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: <foo>" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(<FOO>_PRIORITY)" >>$@
	@echo "Section: $(<FOO>_SECTION)" >>$@
	@echo "Version: $(<FOO>_VERSION)-$(<FOO>_IPK_VERSION)" >>$@
	@echo "Maintainer: $(<FOO>_MAINTAINER)" >>$@
	@echo "Source: $(<FOO>_SITE)/$(<FOO>_SOURCE)" >>$@
	@echo "Description: $(<FOO>_DESCRIPTION)" >>$@
	@echo "Depends: $(<FOO>_DEPENDS)" >>$@
	@echo "Suggests: $(<FOO>_SUGGESTS)" >>$@
	@echo "Conflicts: $(<FOO>_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(<FOO>_IPK_DIR)/opt/sbin or $(<FOO>_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(<FOO>_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(<FOO>_IPK_DIR)/opt/etc/<foo>/...
# Documentation files should be installed in $(<FOO>_IPK_DIR)/opt/doc/<foo>/...
# Daemon startup scripts should be installed in $(<FOO>_IPK_DIR)/opt/etc/init.d/S??<foo>
#
# You may need to patch your application to make it use these locations.
#
$(<FOO>_IPK): $(<FOO>_BUILD_DIR)/.built
	rm -rf $(<FOO>_IPK_DIR) $(BUILD_DIR)/<foo>_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(<FOO>_BUILD_DIR) DESTDIR=$(<FOO>_IPK_DIR) install-strip
	install -d $(<FOO>_IPK_DIR)/opt/etc/
	install -m 644 $(<FOO>_SOURCE_DIR)/<foo>.conf $(<FOO>_IPK_DIR)/opt/etc/<foo>.conf
	install -d $(<FOO>_IPK_DIR)/opt/etc/init.d
	install -m 755 $(<FOO>_SOURCE_DIR)/rc.<foo> $(<FOO>_IPK_DIR)/opt/etc/init.d/SXX<foo>
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(<FOO>_IPK_DIR)/opt/etc/init.d/SXX<foo>
	$(MAKE) $(<FOO>_IPK_DIR)/CONTROL/control
	install -m 755 $(<FOO>_SOURCE_DIR)/postinst $(<FOO>_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(<FOO>_IPK_DIR)/CONTROL/postinst
	install -m 755 $(<FOO>_SOURCE_DIR)/prerm $(<FOO>_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(<FOO>_IPK_DIR)/CONTROL/prerm
ifeq (/opt, $(IPKG_PREFIX))
	sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(IPKG_PREFIX)/bin/&|' \
		$(<FOO>_IPK_DIR)/CONTROL/postinst $(<FOO>_IPK_DIR)/CONTROL/prerm
endif
	echo $(<FOO>_CONFFILES) | sed -e 's/ /\n/g' > $(<FOO>_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(<FOO>_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
<foo>-ipk: $(<FOO>_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
<foo>-clean:
	rm -f $(<FOO>_BUILD_DIR)/.built
	-$(MAKE) -C $(<FOO>_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
<foo>-dirclean:
	rm -rf $(BUILD_DIR)/$(<FOO>_DIR) $(<FOO>_BUILD_DIR) $(<FOO>_IPK_DIR) $(<FOO>_IPK)
#
#
# Some sanity check for the package.
#
<foo>-check: $(<FOO>_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(<FOO>_IPK)
