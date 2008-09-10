###########################################################
#
# opendchub
#
###########################################################
#
# OPENDCHUB_VERSION, OPENDCHUB_SITE and OPENDCHUB_SOURCE define
# the upstream location of the source code for the package.
# OPENDCHUB_DIR is the directory which is created when the source
# archive is unpacked.
# OPENDCHUB_UNZIP is the command used to unzip the source.
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
OPENDCHUB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/opendchub
OPENDCHUB_VERSION=0.7.15
OPENDCHUB_SOURCE=opendchub-$(OPENDCHUB_VERSION).tar.gz
OPENDCHUB_DIR=opendchub-$(OPENDCHUB_VERSION)
OPENDCHUB_UNZIP=zcat
OPENDCHUB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENDCHUB_DESCRIPTION=Open DC hub is a Unix/Linux version of the hub software for the Direct Connect network.
OPENDCHUB_SECTION=net
OPENDCHUB_PRIORITY=optional
OPENDCHUB_DEPENDS=$(filter perl, $(PACKAGES))
OPENDCHUB_SUGGESTS=
OPENDCHUB_CONFLICTS=

#
# OPENDCHUB_IPK_VERSION should be incremented when the ipk changes.
#
OPENDCHUB_IPK_VERSION=1

#
# OPENDCHUB_CONFFILES should be a list of user-editable files
#OPENDCHUB_CONFFILES=/opt/etc/opendchub.conf /opt/etc/init.d/SXXopendchub

#
# OPENDCHUB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPENDCHUB_PATCHES=$(OPENDCHUB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENDCHUB_CPPFLAGS=
OPENDCHUB_LDFLAGS=
OPENDCHUB_PERL_LDFLAGS = -L$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR) -Wl,-E -lperl \
$(if $(filter 5.8, $(PERL_MAJOR_VER)), \
$(STAGING_LIB_DIR)/perl5/$(PERL_VERSION)/$(PERL_ARCH)/auto/DynaLoader/DynaLoader.a,)


#
# OPENDCHUB_BUILD_DIR is the directory in which the build is done.
# OPENDCHUB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENDCHUB_IPK_DIR is the directory in which the ipk is built.
# OPENDCHUB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENDCHUB_BUILD_DIR=$(BUILD_DIR)/opendchub
OPENDCHUB_SOURCE_DIR=$(SOURCE_DIR)/opendchub
OPENDCHUB_IPK_DIR=$(BUILD_DIR)/opendchub-$(OPENDCHUB_VERSION)-ipk
OPENDCHUB_IPK=$(BUILD_DIR)/opendchub_$(OPENDCHUB_VERSION)-$(OPENDCHUB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: opendchub-source opendchub-unpack opendchub opendchub-stage opendchub-ipk opendchub-clean opendchub-dirclean opendchub-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENDCHUB_SOURCE):
	$(WGET) -P $(@D) $(OPENDCHUB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
opendchub-source: $(DL_DIR)/$(OPENDCHUB_SOURCE) $(OPENDCHUB_PATCHES)

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
$(OPENDCHUB_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENDCHUB_SOURCE) $(OPENDCHUB_PATCHES) make/opendchub.mk
ifeq (perl, $(filter perl, $(PACKAGES)))
	$(MAKE) perl-stage
endif
	rm -rf $(BUILD_DIR)/$(OPENDCHUB_DIR) $(@D)
	$(OPENDCHUB_UNZIP) $(DL_DIR)/$(OPENDCHUB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPENDCHUB_PATCHES)" ; \
		then cat $(OPENDCHUB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENDCHUB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENDCHUB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(OPENDCHUB_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENDCHUB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENDCHUB_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
	$(if $(filter perl, $(PACKAGES)),,--disable-perl) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

opendchub-unpack: $(OPENDCHUB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENDCHUB_BUILD_DIR)/.built: $(OPENDCHUB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		perl_flags="-I$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)" \
		perl_libs="$(PERL_LDFLAGS) $(OPENDCHUB_PERL_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
opendchub: $(OPENDCHUB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENDCHUB_BUILD_DIR)/.staged: $(OPENDCHUB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

opendchub-stage: $(OPENDCHUB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/opendchub
#
$(OPENDCHUB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: opendchub" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENDCHUB_PRIORITY)" >>$@
	@echo "Section: $(OPENDCHUB_SECTION)" >>$@
	@echo "Version: $(OPENDCHUB_VERSION)-$(OPENDCHUB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENDCHUB_MAINTAINER)" >>$@
	@echo "Source: $(OPENDCHUB_SITE)/$(OPENDCHUB_SOURCE)" >>$@
	@echo "Description: $(OPENDCHUB_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENDCHUB_DEPENDS)" >>$@
	@echo "Suggests: $(OPENDCHUB_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENDCHUB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENDCHUB_IPK_DIR)/opt/sbin or $(OPENDCHUB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENDCHUB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENDCHUB_IPK_DIR)/opt/etc/opendchub/...
# Documentation files should be installed in $(OPENDCHUB_IPK_DIR)/opt/doc/opendchub/...
# Daemon startup scripts should be installed in $(OPENDCHUB_IPK_DIR)/opt/etc/init.d/S??opendchub
#
# You may need to patch your application to make it use these locations.
#
$(OPENDCHUB_IPK): $(OPENDCHUB_BUILD_DIR)/.built
	rm -rf $(OPENDCHUB_IPK_DIR) $(BUILD_DIR)/opendchub_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OPENDCHUB_BUILD_DIR) DESTDIR=$(OPENDCHUB_IPK_DIR) install
	$(STRIP_COMMAND) $(OPENDCHUB_IPK_DIR)/opt/*bin/*
	install -d $(OPENDCHUB_IPK_DIR)/opt/share/doc/opendchub
	install $(OPENDCHUB_BUILD_DIR)/[ACRN]* \
		$(OPENDCHUB_BUILD_DIR)/Documentation/* \
		$(OPENDCHUB_BUILD_DIR)/Samplescripts/* \
		$(OPENDCHUB_IPK_DIR)/opt/share/doc/opendchub/
#	install -d $(OPENDCHUB_IPK_DIR)/opt/etc/
#	install -m 644 $(OPENDCHUB_SOURCE_DIR)/opendchub.conf $(OPENDCHUB_IPK_DIR)/opt/etc/opendchub.conf
#	install -d $(OPENDCHUB_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OPENDCHUB_SOURCE_DIR)/rc.opendchub $(OPENDCHUB_IPK_DIR)/opt/etc/init.d/SXXopendchub
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENDCHUB_IPK_DIR)/opt/etc/init.d/SXXopendchub
	$(MAKE) $(OPENDCHUB_IPK_DIR)/CONTROL/control
	echo $(OPENDCHUB_CONFFILES) | sed -e 's/ /\n/g' > $(OPENDCHUB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENDCHUB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
opendchub-ipk: $(OPENDCHUB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
opendchub-clean:
	rm -f $(OPENDCHUB_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENDCHUB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
opendchub-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENDCHUB_DIR) $(OPENDCHUB_BUILD_DIR) $(OPENDCHUB_IPK_DIR) $(OPENDCHUB_IPK)
#
#
# Some sanity check for the package.
#
opendchub-check: $(OPENDCHUB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENDCHUB_IPK)
