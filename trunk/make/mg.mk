###########################################################
#
# mg
#
###########################################################
#
# MG_VERSION, MG_SITE and MG_SOURCE define
# the upstream location of the source code for the package.
# MG_DIR is the directory which is created when the source
# archive is unpacked.
# MG_UNZIP is the command used to unzip the source.
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
MG_SITE=http://www.xs4all.nl/~hanb/software/mg
MG_VERSION=20080305
MG_SOURCE=mg-$(MG_VERSION).tar.gz
MG_DIR=mg-$(MG_VERSION)
MG_UNZIP=zcat
MG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MG_DESCRIPTION=mg is a Public Domain EMACS style editor.
MG_SECTION=editor
MG_PRIORITY=optional
MG_DEPENDS=ncurses
MG_SUGGESTS=
MG_CONFLICTS=

#
# MG_IPK_VERSION should be incremented when the ipk changes.
#
MG_IPK_VERSION=1

#
# MG_CONFFILES should be a list of user-editable files
#MG_CONFFILES=/opt/etc/mg.conf /opt/etc/init.d/SXXmg

#
# MG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (wl500g, $(OPTWARE_TARGET))
MG_PATCHES=$(MG_SOURCE_DIR)/errx.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MG_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
MG_LDFLAGS=-lncurses

#
# MG_BUILD_DIR is the directory in which the build is done.
# MG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MG_IPK_DIR is the directory in which the ipk is built.
# MG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MG_BUILD_DIR=$(BUILD_DIR)/mg
MG_SOURCE_DIR=$(SOURCE_DIR)/mg
MG_IPK_DIR=$(BUILD_DIR)/mg-$(MG_VERSION)-ipk
MG_IPK=$(BUILD_DIR)/mg_$(MG_VERSION)-$(MG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mg-source mg-unpack mg mg-stage mg-ipk mg-clean mg-dirclean mg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MG_SOURCE):
	$(WGET) -P $(DL_DIR) $(MG_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mg-source: $(DL_DIR)/$(MG_SOURCE) $(MG_PATCHES)

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
$(MG_BUILD_DIR)/.configured: $(DL_DIR)/$(MG_SOURCE) $(MG_PATCHES) make/mg.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(MG_DIR) $(@D)
	$(MG_UNZIP) $(DL_DIR)/$(MG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MG_PATCHES)" ; \
		then cat $(MG_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(MG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MG_DIR) $(@D) ; \
	fi
#	(cd $(MG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	cd $(@D); ./configure
ifeq (uclibc, $(LIBC_STYLE))
	cd $(@D); \
	sed -i.orig -e 's/ifdef __GLIBC__/if 0/' \
buffer.c \
dired.c \
file.c \
grep.c \
re_search.c \
strtonum.c \
sysdef.h
endif
#	$(PATCH_LIBTOOL) $(MG_BUILD_DIR)/libtool
	touch $@

mg-unpack: $(MG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MG_BUILD_DIR)/.built: $(MG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		prefix=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(MG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MG_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
mg: $(MG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MG_BUILD_DIR)/.staged: $(MG_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(MG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mg-stage: $(MG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mg
#
$(MG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MG_PRIORITY)" >>$@
	@echo "Section: $(MG_SECTION)" >>$@
	@echo "Version: $(MG_VERSION)-$(MG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MG_MAINTAINER)" >>$@
	@echo "Source: $(MG_SITE)/$(MG_SOURCE)" >>$@
	@echo "Description: $(MG_DESCRIPTION)" >>$@
	@echo "Depends: $(MG_DEPENDS)" >>$@
	@echo "Suggests: $(MG_SUGGESTS)" >>$@
	@echo "Conflicts: $(MG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MG_IPK_DIR)/opt/sbin or $(MG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MG_IPK_DIR)/opt/etc/mg/...
# Documentation files should be installed in $(MG_IPK_DIR)/opt/doc/mg/...
# Daemon startup scripts should be installed in $(MG_IPK_DIR)/opt/etc/init.d/S??mg
#
# You may need to patch your application to make it use these locations.
#
$(MG_IPK): $(MG_BUILD_DIR)/.built
	rm -rf $(MG_IPK_DIR) $(BUILD_DIR)/mg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MG_BUILD_DIR) install \
		prefix=$(MG_IPK_DIR)/opt \
		;
	$(STRIP_COMMAND) $(MG_IPK_DIR)/opt/bin/mg
#	install -d $(MG_IPK_DIR)/opt/etc/
#	install -m 644 $(MG_SOURCE_DIR)/mg.conf $(MG_IPK_DIR)/opt/etc/mg.conf
#	install -d $(MG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MG_SOURCE_DIR)/rc.mg $(MG_IPK_DIR)/opt/etc/init.d/SXXmg
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MG_IPK_DIR)/opt/etc/init.d/SXXmg
	$(MAKE) $(MG_IPK_DIR)/CONTROL/control
#	install -m 755 $(MG_SOURCE_DIR)/postinst $(MG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MG_SOURCE_DIR)/prerm $(MG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MG_IPK_DIR)/CONTROL/prerm
	echo $(MG_CONFFILES) | sed -e 's/ /\n/g' > $(MG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mg-ipk: $(MG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mg-clean:
	rm -f $(MG_BUILD_DIR)/.built
	-$(MAKE) -C $(MG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mg-dirclean:
	rm -rf $(BUILD_DIR)/$(MG_DIR) $(MG_BUILD_DIR) $(MG_IPK_DIR) $(MG_IPK)
#
#
# Some sanity check for the package.
#
mg-check: $(MG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MG_IPK)
