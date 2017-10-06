###########################################################
#
# motif
#
###########################################################

# You must replace "motif" and "MOTIF" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MOTIF_VERSION, MOTIF_SITE and MOTIF_SOURCE define
# the upstream location of the source code for the package.
# MOTIF_DIR is the directory which is created when the source
# archive is unpacked.
# MOTIF_UNZIP is the command used to unzip the source.
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
MOTIF_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/motif
MOTIF_VERSION=2.3.4
MOTIF_SOURCE=motif-$(MOTIF_VERSION)-src.tgz
MOTIF_DIR=motif-$(MOTIF_VERSION)
MOTIF_UNZIP=zcat
MOTIF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOTIF_DESCRIPTION=Motif user interface component toolkit.
MOTIF_SECTION=lib
MOTIF_PRIORITY=optional
MOTIF_DEPENDS=x11, xmu, xt, xp, xext, xft, libjpeg, libpng, freetype, fontconfig
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MOTIF_DEPENDS += , libiconv
endif
MOTIF_SUGGESTS=
MOTIF_CONFLICTS=

#
# MOTIF_IPK_VERSION should be incremented when the ipk changes.
#
MOTIF_IPK_VERSION=3

#
# MOTIF_CONFFILES should be a list of user-editable files
#MOTIF_CONFFILES=$(TARGET_PREFIX)/etc/motif.conf $(TARGET_PREFIX)/etc/init.d/SXXmotif

#
# MOTIF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOTIF_PATCHES=$(MOTIF_SOURCE_DIR)/configure.patch $(MOTIF_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOTIF_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
MOTIF_LDFLAGS=-lfreetype -lXt -lXft -lX11 -lXext
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MOTIF_LDFLAGS += -liconv
endif

#
# MOTIF_BUILD_DIR is the directory in which the build is done.
# MOTIF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOTIF_IPK_DIR is the directory in which the ipk is built.
# MOTIF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOTIF_BUILD_DIR=$(BUILD_DIR)/motif
MOTIF_SOURCE_DIR=$(SOURCE_DIR)/motif
MOTIF_IPK_DIR=$(BUILD_DIR)/motif-$(MOTIF_VERSION)-ipk
MOTIF_IPK=$(BUILD_DIR)/motif_$(MOTIF_VERSION)-$(MOTIF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: motif-source motif-unpack motif motif-stage motif-ipk motif-clean motif-dirclean motif-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOTIF_SOURCE):
	$(WGET) -P $(@D) $(MOTIF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
motif-source: $(DL_DIR)/$(MOTIF_SOURCE) $(MOTIF_PATCHES)

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
$(MOTIF_BUILD_DIR)/.configured: $(DL_DIR)/$(MOTIF_SOURCE) $(MOTIF_PATCHES) make/motif.mk
	$(MAKE) x11-stage xmu-stage xt-stage xp-stage xft-stage libjpeg-stage libpng-stage \
	freetype-stage fontconfig-stage xbitmaps-stage xext-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(MOTIF_DIR) $(@D)
	$(MOTIF_UNZIP) $(DL_DIR)/$(MOTIF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOTIF_PATCHES)" ; \
		then cat $(MOTIF_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MOTIF_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MOTIF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MOTIF_DIR) $(@D) ; \
	fi
#	makestrs.host
	cd $(@D)/config/util; $(HOSTCC) -g -O2 -fno-strict-aliasing -fno-tree-ter -o makestrs.host makestrs.c
	touch $(@D)/NEWS $(@D)/AUTHORS
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOTIF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOTIF_LDFLAGS)" \
		FONTCONFIG_LIBS="-lfontconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--x-libraries=$(TARGET_PREFIX)/lib \
		--enable-xft \
		--enable-jpeg \
		--enable-png \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	find $(@D) -type f -name Makefile -exec sed -i -e 's|-I/usr/include/freetype2||g' \
				-e 's|\$${exec_prefix}/lib/X11|\$${exec_prefix}/lib|g' {} \;
	$(MAKE) -C $(@D)/tools/wml wml wmluiltok
#	wml.host
	cd $(@D)/tools/wml; \
			for src in wmlparse wml wmloutkey wmlouth wmloutmm wmloutp1 wmlresolve wmlsynbld wmlutils; \
				do gcc  -g -O2 -fno-strict-aliasing -fno-tree-ter -c -o $${src}.host.o $${src}.c; \
			done
	cd $(@D)/tools/wml; \
			ar cru libwml.host.a wmlparse.host.o wml.host.o wmloutkey.host.o wmlouth.host.o \
				wmloutmm.host.o wmloutp1.host.o wmlresolve.host.o wmlsynbld.host.o wmlutils.host.o
	cd $(@D)/tools/wml; \
			gcc  -g -O2 -fno-strict-aliasing -fno-tree-ter -o wml.host wml.host.o libwml.host.a
#	wmluiltok.host
	cd $(@D)/tools/wml; \
			gcc  -g -O2 -fno-strict-aliasing -fno-tree-ter -o wmluiltok.host wmluiltok.c -lfl || \
				(echo "make sure flex is installed on the host"; exit 1)
	touch $@

motif-unpack: $(MOTIF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOTIF_BUILD_DIR)/.built: $(MOTIF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) program_transform_name='s&^&&'
	touch $@

#
# This is the build convenience target.
#
motif: $(MOTIF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOTIF_BUILD_DIR)/.staged: $(MOTIF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install program_transform_name='s&^&&'
	rm -f $(STAGING_LIB_DIR)/libMrm.la $(STAGING_LIB_DIR)/libUil.la $(STAGING_LIB_DIR)/libXm.la
	touch $@

motif-stage: $(MOTIF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/motif
#
$(MOTIF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: motif" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOTIF_PRIORITY)" >>$@
	@echo "Section: $(MOTIF_SECTION)" >>$@
	@echo "Version: $(MOTIF_VERSION)-$(MOTIF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOTIF_MAINTAINER)" >>$@
	@echo "Source: $(MOTIF_SITE)/$(MOTIF_SOURCE)" >>$@
	@echo "Description: $(MOTIF_DESCRIPTION)" >>$@
	@echo "Depends: $(MOTIF_DEPENDS)" >>$@
	@echo "Suggests: $(MOTIF_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOTIF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/motif/...
# Documentation files should be installed in $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/doc/motif/...
# Daemon startup scripts should be installed in $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??motif
#
# You may need to patch your application to make it use these locations.
#
$(MOTIF_IPK): $(MOTIF_BUILD_DIR)/.built
	rm -rf $(MOTIF_IPK_DIR) $(BUILD_DIR)/motif_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOTIF_BUILD_DIR) DESTDIR=$(MOTIF_IPK_DIR) install-strip program_transform_name='s&^&&'
	rm -f $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MOTIF_SOURCE_DIR)/motif.conf $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/motif.conf
#	$(INSTALL) -d $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MOTIF_SOURCE_DIR)/rc.motif $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmotif
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOTIF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmotif
	$(MAKE) $(MOTIF_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MOTIF_SOURCE_DIR)/postinst $(MOTIF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOTIF_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MOTIF_SOURCE_DIR)/prerm $(MOTIF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOTIF_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MOTIF_IPK_DIR)/CONTROL/postinst $(MOTIF_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MOTIF_CONFFILES) | sed -e 's/ /\n/g' > $(MOTIF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOTIF_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(MOTIF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
motif-ipk: $(MOTIF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
motif-clean:
	rm -f $(MOTIF_BUILD_DIR)/.built
	-$(MAKE) -C $(MOTIF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
motif-dirclean:
	rm -rf $(BUILD_DIR)/$(MOTIF_DIR) $(MOTIF_BUILD_DIR) $(MOTIF_IPK_DIR) $(MOTIF_IPK)
#
#
# Some sanity check for the package.
#
motif-check: $(MOTIF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
