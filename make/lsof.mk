###########################################################
#
# lsof
#
###########################################################
#
# LSOF_VERSION, LSOF_SITE and LSOF_SOURCE define
# the upstream location of the source code for the package.
# LSOF_DIR is the directory which is created when the source
# archive is unpacked.
# LSOF_UNZIP is the command used to unzip the source.
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
LSOF_SITE=ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof
LSOF_VERSION=4.81
LSOF_SOURCE=lsof_$(LSOF_VERSION).tar.bz2
LSOF_DIR=lsof_$(LSOF_VERSION)_src
LSOF_UNZIP=bzcat
LSOF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LSOF_DESCRIPTION=LiSt Open Files - a diagnostic tool.
LSOF_SECTION=admin
LSOF_PRIORITY=optional
LSOF_DEPENDS=
LSOF_SUGGESTS=
LSOF_CONFLICTS=

#
# LSOF_IPK_VERSION should be incremented when the ipk changes.
#
LSOF_IPK_VERSION=1

#
# LSOF_CONFFILES should be a list of user-editable files
#LSOF_CONFFILES=/opt/etc/lsof.conf /opt/etc/init.d/SXXlsof

#
# LSOF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LSOF_PATCHES=$(LSOF_SOURCE_DIR)/Makefile-lib.patch
ifeq (wl500g,$(OPTWARE_TARGET))
LSOF_PATCHES+=$(LSOF_SOURCE_DIR)/machine_h.patch $(LSOF_SOURCE_DIR)/print_c.patch
endif
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LSOF_CPPFLAGS=
LSOF_LDFLAGS=

#
# LSOF_BUILD_DIR is the directory in which the build is done.
# LSOF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LSOF_IPK_DIR is the directory in which the ipk is built.
# LSOF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LSOF_BUILD_DIR=$(BUILD_DIR)/lsof
LSOF_SOURCE_DIR=$(SOURCE_DIR)/lsof
LSOF_IPK_DIR=$(BUILD_DIR)/lsof-$(LSOF_VERSION)-ipk
LSOF_IPK=$(BUILD_DIR)/lsof_$(LSOF_VERSION)-$(LSOF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lsof-source lsof-unpack lsof lsof-stage lsof-ipk lsof-clean lsof-dirclean lsof-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LSOF_SOURCE):
	$(WGET) -P $(@D) $(LSOF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lsof-source: $(DL_DIR)/$(LSOF_SOURCE) $(LSOF_PATCHES)

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
$(LSOF_BUILD_DIR)/.configured: $(DL_DIR)/$(LSOF_SOURCE) $(LSOF_PATCHES) make/lsof.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LSOF_DIR) $(@D)
	$(LSOF_UNZIP) $(DL_DIR)/$(LSOF_SOURCE) | \
		tar -xOvf - lsof_$(LSOF_VERSION)/lsof_$(LSOF_VERSION)_src.tar | \
		tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(LSOF_DIR)" != "$(LSOF_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LSOF_DIR) $(LSOF_BUILD_DIR) ; \
	fi
	(cd $(@D); \
		echo "n\ny\ny\ny\nn\nn\ny\n" | env \
		LSOF_CC=$(TARGET_CC) \
		LSOF_INCLUDE=$(TARGET_INCDIR) \
		LINUX_CLIB="-DGLIBCV=2" \
		./Configure linux \
	)
	if test -n "$(LSOF_PATCHES)" ; \
		then cat $(LSOF_PATCHES) | \
		patch -d $(@D) -p1 ; \
	fi
	touch $@

lsof-unpack: $(LSOF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LSOF_BUILD_DIR)/.built: $(LSOF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CDEF="$(TARGET_CFLAGS)"
	touch $@

#
# This is the build convenience target.
#
lsof: $(LSOF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LSOF_BUILD_DIR)/.staged: $(LSOF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

lsof-stage: $(LSOF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lsof
#
$(LSOF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lsof" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LSOF_PRIORITY)" >>$@
	@echo "Section: $(LSOF_SECTION)" >>$@
	@echo "Version: $(LSOF_VERSION)-$(LSOF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LSOF_MAINTAINER)" >>$@
	@echo "Source: $(LSOF_SITE)/$(LSOF_SOURCE)" >>$@
	@echo "Description: $(LSOF_DESCRIPTION)" >>$@
	@echo "Depends: $(LSOF_DEPENDS)" >>$@
	@echo "Suggests: $(LSOF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LSOF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LSOF_IPK_DIR)/opt/sbin or $(LSOF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LSOF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LSOF_IPK_DIR)/opt/etc/lsof/...
# Documentation files should be installed in $(LSOF_IPK_DIR)/opt/doc/lsof/...
# Daemon startup scripts should be installed in $(LSOF_IPK_DIR)/opt/etc/init.d/S??lsof
#
# You may need to patch your application to make it use these locations.
#
$(LSOF_IPK): $(LSOF_BUILD_DIR)/.built
	rm -rf $(LSOF_IPK_DIR) $(BUILD_DIR)/lsof_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(LSOF_BUILD_DIR) DESTDIR=$(LSOF_IPK_DIR) install-strip
	install -d $(LSOF_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(LSOF_BUILD_DIR)/lsof -o $(LSOF_IPK_DIR)/opt/sbin/lsof
	install -d $(LSOF_IPK_DIR)/opt/share/man/man8
	install $(LSOF_BUILD_DIR)/lsof.8 $(LSOF_IPK_DIR)/opt/share/man/man8
	$(MAKE) $(LSOF_IPK_DIR)/CONTROL/control
	echo $(LSOF_CONFFILES) | sed -e 's/ /\n/g' > $(LSOF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LSOF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lsof-ipk: $(LSOF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lsof-clean:
	rm -f $(LSOF_BUILD_DIR)/.built
	-$(MAKE) -C $(LSOF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lsof-dirclean:
	rm -rf $(BUILD_DIR)/$(LSOF_DIR) $(LSOF_BUILD_DIR) $(LSOF_IPK_DIR) $(LSOF_IPK)
#
#
# Some sanity check for the package.
#
lsof-check: $(LSOF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LSOF_IPK)
