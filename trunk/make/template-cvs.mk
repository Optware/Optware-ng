###########################################################
#
# <bar>
#
###########################################################

#
# <BAR>_REPOSITORY defines the upstream location of the source code
# for the package.  <BAR>_DIR is the directory which is created when
# this cvs module is checked out.
#

<BAR>_REPOSITORY=:pserver:cvs@nowhere.org:/cvs/<bar>
<BAR>_DIR=<bar>
<BAR>_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
<BAR>_DESCRIPTION=Describe <bar> here.
<BAR>_SECTION=
<BAR>_PRIORITY=optional
<BAR>_DEPENDS=
<BAR>_SUGGESTS=
<BAR>_CONFLICTS=

#
# Software downloaded from CVS repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#

#
# If you want to use a date, uncomment the variables below and modify
# <BAR>_CVS_DATE
#

#<BAR>_CVS_DATE=20050201
#<BAR>_VERSION=cvs$(<BAR>_CVS_DATE)
#<BAR>_CVS_OPTS=-D $(<BAR>_CVS_DATE)

#
# If you want to use a tag, uncomment the variables below and modify
# <BAR>_CVS_TAG and <BAR>_CVS_VERSION
#

#<BAR>_CVS_TAG=version_1_2_3
#<BAR>_VERSION=1.2.3
#<BAR>_CVS_OPTS=-r $(<BAR>_CVS_TAG)

#
# <BAR>_IPK_VERSION should be incremented when the ipk changes.
#
<BAR>_IPK_VERSION=1

#
# <BAR>_CONFFILES should be a list of user-editable files
<BAR>_CONFFILES=

#
# <BAR>_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
<BAR>_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
<BAR>_CPPFLAGS=
<BAR>_LDFLAGS=

#
# <BAR>_BUILD_DIR is the directory in which the build is done.
# <BAR>_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# <BAR>_IPK_DIR is the directory in which the ipk is built.
# <BAR>_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
<BAR>_BUILD_DIR=$(BUILD_DIR)/<bar>
<BAR>_SOURCE_DIR=$(SOURCE_DIR)/<bar>
<BAR>_IPK_DIR=$(BUILD_DIR)/<bar>-$(<BAR>_VERSION)-ipk
<BAR>_IPK=$(BUILD_DIR)/<bar>_$(<BAR>_VERSION)-$(<BAR>_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: <bar>-source <bar>-unpack <bar> <bar>-stage <bar>-ipk <bar>-clean <bar>-dirclean <bar>-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/template-cvs-$(<BAR>_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(<BAR>_DIR) && \
		cvs -d $(<BAR>_REPOSITORY) -z3 co $(<BAR>_CVS_OPTS) $(<BAR>_DIR) && \
		tar -czf $@ $(<BAR>_DIR) && \
		rm -rf $(<BAR>_DIR) \
	)

<bar>-source: $(DL_DIR)/template-cvs-$(<BAR>_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(<BAR>_BUILD_DIR)/.configured: $(DL_DIR)/template-cvs-$(<BAR>_VERSION).tar.gz
	$(MAKE) <foo>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(<BAR>_DIR) $(<BAR>_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/template-cvs-$(<BAR>_VERSION).tar.gz
	if test -n "$(<BAR>_PATCHES)" ; \
		then cat $(<BAR>_PATCHES) | \
		patch -d $(BUILD_DIR)/$(<BAR>_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(<BAR>_DIR)" != "$(<BAR>_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(<BAR>_DIR) $(<BAR>_BUILD_DIR) ; \
	fi
	(cd $(<BAR>_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(<BAR>_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(<BAR>_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(<BAR>_BUILD_DIR)/.configured

<bar>-unpack: $(<BAR>_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(<BAR>_BUILD_DIR)/.built: $(<BAR>_BUILD_DIR)/.configured
	rm -f $(<BAR>_BUILD_DIR)/.built
	$(MAKE) -C $(<BAR>_BUILD_DIR)
	touch $(<BAR>_BUILD_DIR)/.built

#
# This is the build convenience target.
#
<bar>: $(<BAR>_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(<BAR>_BUILD_DIR)/.staged: $(<BAR>_BUILD_DIR)/.built
	rm -f $(<BAR>_BUILD_DIR)/.staged
	$(MAKE) -C $(<BAR>_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(<BAR>_BUILD_DIR)/.staged

<bar>-stage: $(<BAR>_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<bar>
#
$(<BAR>_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: <bar>" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(<BAR>_PRIORITY)" >>$@
	@echo "Section: $(<BAR>_SECTION)" >>$@
	@echo "Version: $(<BAR>_VERSION)-$(<BAR>_IPK_VERSION)" >>$@
	@echo "Maintainer: $(<BAR>_MAINTAINER)" >>$@
	@echo "Source: $(<BAR>_REPOSITORY)" >>$@
	@echo "Description: $(<BAR>_DESCRIPTION)" >>$@
	@echo "Depends: $(<BAR>_DEPENDS)" >>$@
	@echo "Suggests: $(<BAR>_SUGGESTS)" >>$@
	@echo "Conflicts: $(<BAR>_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(<BAR>_IPK_DIR)/opt/sbin or $(<BAR>_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(<BAR>_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(<BAR>_IPK_DIR)/opt/etc/<bar>/...
# Documentation files should be installed in $(<BAR>_IPK_DIR)/opt/doc/<bar>/...
# Daemon startup scripts should be installed in $(<BAR>_IPK_DIR)/opt/etc/init.d/S??<bar>
#
# You may need to patch your application to make it use these locations.
#
$(<BAR>_IPK): $(<BAR>_BUILD_DIR)/.built
	rm -rf $(<BAR>_IPK_DIR) $(BUILD_DIR)/<bar>_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(<BAR>_BUILD_DIR) DESTDIR=$(<BAR>_IPK_DIR) install
	install -d $(<BAR>_IPK_DIR)/opt/etc/
	install -m 644 $(<BAR>_SOURCE_DIR)/<bar>.conf $(<BAR>_IPK_DIR)/opt/etc/<bar>.conf
	install -d $(<BAR>_IPK_DIR)/opt/etc/init.d
	install -m 755 $(<BAR>_SOURCE_DIR)/rc.<bar> $(<BAR>_IPK_DIR)/opt/etc/init.d/SXX<bar>
	$(MAKE) $(<BAR>_IPK_DIR)/CONTROL/control
	install -m 755 $(<BAR>_SOURCE_DIR)/postinst $(<BAR>_IPK_DIR)/CONTROL/postinst
	install -m 755 $(<BAR>_SOURCE_DIR)/prerm $(<BAR>_IPK_DIR)/CONTROL/prerm
ifeq (/opt, $(IPKG_PREFIX))
	sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(IPKG_PREFIX)/bin/&|' \
		$(<BAR>_IPK_DIR)/CONTROL/postinst $(<BAR>_IPK_DIR)/CONTROL/prerm
endif
	echo $(<BAR>_CONFFILES) | sed -e 's/ /\n/g' > $(<BAR>_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(<BAR>_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
<bar>-ipk: $(<BAR>_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
<bar>-clean:
	rm -f $(<FOO>_BUILD_DIR)/.built
	-$(MAKE) -C $(<BAR>_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
<bar>-dirclean:
	rm -rf $(BUILD_DIR)/$(<BAR>_DIR) $(<BAR>_BUILD_DIR) $(<BAR>_IPK_DIR) $(<BAR>_IPK)

#
# Some sanity check for the package.
#
<bar>-check: $(<BAR>_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(<BAR>_IPK)
