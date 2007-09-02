###########################################################
#
# iptraf
#
###########################################################
#
# IPTRAF_VERSION, IPTRAF_SITE and IPTRAF_SOURCE define
# the upstream location of the source code for the package.
# IPTRAF_DIR is the directory which is created when the source
# archive is unpacked.
# IPTRAF_UNZIP is the command used to unzip the source.
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
IPTRAF_SITE=ftp://iptraf.seul.org/pub/iptraf
IPTRAF_VERSION=3.0.0
IPTRAF_SOURCE=iptraf-$(IPTRAF_VERSION).tar.gz
IPTRAF_DIR=iptraf-$(IPTRAF_VERSION)
IPTRAF_UNZIP=zcat
IPTRAF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPTRAF_DESCRIPTION=IPTraf is a console-based network statistics utility for Linux.
IPTRAF_SECTION=net
IPTRAF_PRIORITY=optional
IPTRAF_DEPENDS=ncurses
IPTRAF_SUGGESTS=
IPTRAF_CONFLICTS=

#
# IPTRAF_IPK_VERSION should be incremented when the ipk changes.
#
IPTRAF_IPK_VERSION=1

#
# IPTRAF_CONFFILES should be a list of user-editable files
#IPTRAF_CONFFILES=/opt/etc/iptraf.conf /opt/etc/init.d/SXXiptraf

#
# IPTRAF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPTRAF_PATCHES=\
$(IPTRAF_SOURCE_DIR)/src-Makefile.patch \
$(IPTRAF_SOURCE_DIR)/support-Makefile.patch \
$(IPTRAF_SOURCE_DIR)/src-install.sh.patch \
$(IPTRAF_SOURCE_DIR)/ixp.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPTRAF_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
IPTRAF_LDFLAGS=

#
# IPTRAF_BUILD_DIR is the directory in which the build is done.
# IPTRAF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPTRAF_IPK_DIR is the directory in which the ipk is built.
# IPTRAF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPTRAF_BUILD_DIR=$(BUILD_DIR)/iptraf
IPTRAF_SOURCE_DIR=$(SOURCE_DIR)/iptraf
IPTRAF_IPK_DIR=$(BUILD_DIR)/iptraf-$(IPTRAF_VERSION)-ipk
IPTRAF_IPK=$(BUILD_DIR)/iptraf_$(IPTRAF_VERSION)-$(IPTRAF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: iptraf-source iptraf-unpack iptraf iptraf-stage iptraf-ipk iptraf-clean iptraf-dirclean iptraf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPTRAF_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPTRAF_SITE)/$(IPTRAF_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(IPTRAF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iptraf-source: $(DL_DIR)/$(IPTRAF_SOURCE) $(IPTRAF_PATCHES)

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
$(IPTRAF_BUILD_DIR)/.configured: $(DL_DIR)/$(IPTRAF_SOURCE) $(IPTRAF_PATCHES) make/iptraf.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(IPTRAF_DIR) $(IPTRAF_BUILD_DIR)
	$(IPTRAF_UNZIP) $(DL_DIR)/$(IPTRAF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IPTRAF_PATCHES)" ; \
		then cat $(IPTRAF_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(IPTRAF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IPTRAF_DIR)" != "$(IPTRAF_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IPTRAF_DIR) $(IPTRAF_BUILD_DIR) ; \
	fi
#	(cd $(IPTRAF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPTRAF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPTRAF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

iptraf-unpack: $(IPTRAF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPTRAF_BUILD_DIR)/.built: $(IPTRAF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(IPTRAF_BUILD_DIR)/src \
		ARCH=$(TARGET_ARCH) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPTRAF_CPPFLAGS)" \
		LDOPTS="$(STAGING_LDFLAGS) $(IPTRAF_LDFLAGS)" \
		TARGET=/opt/bin \
		WORKDIR=/opt/var/iptraf \
		LOGDIR=/opt/var/log/iptraf \
		LOCKDIR=/opt/var/run/iptraf \
		;
	touch $@

#
# This is the build convenience target.
#
iptraf: $(IPTRAF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IPTRAF_BUILD_DIR)/.staged: $(IPTRAF_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(IPTRAF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

iptraf-stage: $(IPTRAF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iptraf
#
$(IPTRAF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: iptraf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPTRAF_PRIORITY)" >>$@
	@echo "Section: $(IPTRAF_SECTION)" >>$@
	@echo "Version: $(IPTRAF_VERSION)-$(IPTRAF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPTRAF_MAINTAINER)" >>$@
	@echo "Source: $(IPTRAF_SITE)/$(IPTRAF_SOURCE)" >>$@
	@echo "Description: $(IPTRAF_DESCRIPTION)" >>$@
	@echo "Depends: $(IPTRAF_DEPENDS)" >>$@
	@echo "Suggests: $(IPTRAF_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPTRAF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPTRAF_IPK_DIR)/opt/sbin or $(IPTRAF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPTRAF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPTRAF_IPK_DIR)/opt/etc/iptraf/...
# Documentation files should be installed in $(IPTRAF_IPK_DIR)/opt/doc/iptraf/...
# Daemon startup scripts should be installed in $(IPTRAF_IPK_DIR)/opt/etc/init.d/S??iptraf
#
# You may need to patch your application to make it use these locations.
#
$(IPTRAF_IPK): $(IPTRAF_BUILD_DIR)/.built
	rm -rf $(IPTRAF_IPK_DIR) $(BUILD_DIR)/iptraf_*_$(TARGET_ARCH).ipk
	install -d $(IPTRAF_IPK_DIR)/opt/bin $(IPTRAF_IPK_DIR)/opt/share/doc/iptraf
	$(MAKE) -C $(IPTRAF_BUILD_DIR)/src install \
		TARGET=$(IPTRAF_IPK_DIR)/opt/bin \
		WORKDIR=$(IPTRAF_IPK_DIR)/opt/var/iptraf \
		LOGDIR=$(IPTRAF_IPK_DIR)/opt/var/log/iptraf \
		LOCKDIR=$(IPTRAF_IPK_DIR)/opt/var/run/iptraf \
		;
	$(STRIP_COMMAND) $(IPTRAF_IPK_DIR)/opt/bin/*
	install \
		$(IPTRAF_BUILD_DIR)/CHANGES \
		$(IPTRAF_BUILD_DIR)/LICENSE \
		$(IPTRAF_BUILD_DIR)/FAQ \
		$(IPTRAF_BUILD_DIR)/INSTALL \
		$(IPTRAF_BUILD_DIR)/README* \
		$(IPTRAF_BUILD_DIR)/RELEASE-NOTES \
		$(IPTRAF_BUILD_DIR)/Setup \
		$(IPTRAF_IPK_DIR)/opt/share/doc/iptraf/
#	cp -pR $(IPTRAF_BUILD_DIR)/Documentation $(IPTRAF_IPK_DIR)/opt/share/doc/iptraf/
	install -d $(IPTRAF_IPK_DIR)/opt/share/man/man8
	install $(IPTRAF_BUILD_DIR)/Documentation/*.8 $(IPTRAF_IPK_DIR)/opt/share/man/man8/
	$(MAKE) $(IPTRAF_IPK_DIR)/CONTROL/control
	echo $(IPTRAF_CONFFILES) | sed -e 's/ /\n/g' > $(IPTRAF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPTRAF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iptraf-ipk: $(IPTRAF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iptraf-clean:
	rm -f $(IPTRAF_BUILD_DIR)/.built
	-$(MAKE) -C $(IPTRAF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iptraf-dirclean:
	rm -rf $(BUILD_DIR)/$(IPTRAF_DIR) $(IPTRAF_BUILD_DIR) $(IPTRAF_IPK_DIR) $(IPTRAF_IPK)
#
#
# Some sanity check for the package.
#
iptraf-check: $(IPTRAF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPTRAF_IPK)
