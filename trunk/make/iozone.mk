###########################################################
#
# iozone
#
###########################################################
#
# IOZONE_VERSION, IOZONE_SITE and IOZONE_SOURCE define
# the upstream location of the source code for the package.
# IOZONE_DIR is the directory which is created when the source
# archive is unpacked.
# IOZONE_UNZIP is the command used to unzip the source.
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
IOZONE_SITE=http://www.iozone.org/src/current
IOZONE_VERSION=3_283
IOZONE_SOURCE=iozone$(IOZONE_VERSION).tar
IOZONE_DIR=iozone$(IOZONE_VERSION)
IOZONE_UNZIP=cat
IOZONE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IOZONE_DESCRIPTION=Filesystem benchmark tool
IOZONE_SECTION=misc
IOZONE_PRIORITY=optional
IOZONE_DEPENDS=
IOZONE_SUGGESTS=gnuplot
IOZONE_CONFLICTS=

#
# IOZONE_IPK_VERSION should be incremented when the ipk changes.
#
IOZONE_IPK_VERSION=1

#
# IOZONE_CONFFILES should be a list of user-editable files
#IOZONE_CONFFILES=/opt/etc/iozone.conf /opt/etc/init.d/SXXiozone

#
# IOZONE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IOZONE_PATCHES=$(IOZONE_SOURCE_DIR)/makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(LIBC_STYLE), uclibc)
IOZONE_CPPFLAGS=-DNO_MADVISE
IOZONE_TARGET=generic
else
IOZONE_CPPFLAGS=
IOZONE_TARGET=linux-arm
endif
IOZONE_LDFLAGS=

#
# IOZONE_BUILD_DIR is the directory in which the build is done.
# IOZONE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IOZONE_IPK_DIR is the directory in which the ipk is built.
# IOZONE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IOZONE_BUILD_DIR=$(BUILD_DIR)/iozone
IOZONE_SOURCE_DIR=$(SOURCE_DIR)/iozone
IOZONE_IPK_DIR=$(BUILD_DIR)/iozone-$(IOZONE_VERSION)-ipk
IOZONE_IPK=$(BUILD_DIR)/iozone_$(IOZONE_VERSION)-$(IOZONE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: iozone-source iozone-unpack iozone iozone-stage iozone-ipk iozone-clean iozone-dirclean iozone-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IOZONE_SOURCE):
	$(WGET) -P $(DL_DIR) $(IOZONE_SITE)/$(IOZONE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(IOZONE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iozone-source: $(DL_DIR)/$(IOZONE_SOURCE) $(IOZONE_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(IOZONE_BUILD_DIR)/.configured: $(DL_DIR)/$(IOZONE_SOURCE) $(IOZONE_PATCHES) make/iozone.mk
	rm -rf $(BUILD_DIR)/$(IOZONE_DIR) $(IOZONE_BUILD_DIR)
	$(IOZONE_UNZIP) $(DL_DIR)/$(IOZONE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IOZONE_PATCHES)" ; \
		then cat $(IOZONE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IOZONE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IOZONE_DIR)" != "$(IOZONE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IOZONE_DIR) $(IOZONE_BUILD_DIR) ; \
	fi
	touch $(IOZONE_BUILD_DIR)/.configured

iozone-unpack: $(IOZONE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IOZONE_BUILD_DIR)/.built: $(IOZONE_BUILD_DIR)/.configured
	rm -f $(IOZONE_BUILD_DIR)/.built
	$(MAKE) -C $(IOZONE_BUILD_DIR)/src/current $(IOZONE_TARGET) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(IOZONE_CPPFLAGS)" \
		LDFLAGS="$(IOZONE_LDFLAGS)"
	touch $(IOZONE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
iozone: $(IOZONE_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iozone
#
$(IOZONE_IPK_DIR)/CONTROL/control:
	@install -d $(IOZONE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: iozone" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IOZONE_PRIORITY)" >>$@
	@echo "Section: $(IOZONE_SECTION)" >>$@
	@echo "Version: $(IOZONE_VERSION)-$(IOZONE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IOZONE_MAINTAINER)" >>$@
	@echo "Source: $(IOZONE_SITE)/$(IOZONE_SOURCE)" >>$@
	@echo "Description: $(IOZONE_DESCRIPTION)" >>$@
	@echo "Depends: $(IOZONE_DEPENDS)" >>$@
	@echo "Suggests: $(IOZONE_SUGGESTS)" >>$@
	@echo "Conflicts: $(IOZONE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IOZONE_IPK_DIR)/opt/sbin or $(IOZONE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IOZONE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IOZONE_IPK_DIR)/opt/etc/iozone/...
# Documentation files should be installed in $(IOZONE_IPK_DIR)/opt/doc/iozone/...
# Daemon startup scripts should be installed in $(IOZONE_IPK_DIR)/opt/etc/init.d/S??iozone
#
# You may need to patch your application to make it use these locations.
#
$(IOZONE_IPK): $(IOZONE_BUILD_DIR)/.built
	rm -rf $(IOZONE_IPK_DIR) $(BUILD_DIR)/iozone_*_$(TARGET_ARCH).ipk
	install -d $(IOZONE_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(IOZONE_BUILD_DIR)/src/current/iozone
	install -m 755 $(IOZONE_BUILD_DIR)/src/current/iozone $(IOZONE_IPK_DIR)/opt/bin
	install -d $(IOZONE_IPK_DIR)/opt/lib/iozone/
	install -m 755 $(IOZONE_BUILD_DIR)/src/current/Generate_Graphs $(IOZONE_IPK_DIR)/opt/lib/iozone
	install -m 755 $(IOZONE_BUILD_DIR)/src/current/gengnuplot.sh $(IOZONE_IPK_DIR)/opt/lib/iozone
	install -m 755 $(IOZONE_BUILD_DIR)/src/current/gnu3d.dem $(IOZONE_IPK_DIR)/opt/lib/iozone
	install -d $(IOZONE_IPK_DIR)/opt/share/doc/iozone
	install -m 644 $(IOZONE_BUILD_DIR)/docs/IOzone_msword_98.pdf $(IOZONE_IPK_DIR)/opt/share/doc/iozone
	install -m 644 $(IOZONE_BUILD_DIR)/docs/Run_rules.doc $(IOZONE_IPK_DIR)/opt/share/doc/iozone
	install -m 644 $(IOZONE_BUILD_DIR)/docs/Iozone_ps.gz $(IOZONE_IPK_DIR)/opt/share/doc/iozone
	install -d $(IOZONE_IPK_DIR)/opt/man1/
	install -m 644 $(IOZONE_BUILD_DIR)/docs/iozone.1 $(IOZONE_IPK_DIR)/opt/man1
	$(MAKE) $(IOZONE_IPK_DIR)/CONTROL/control
#	install -m 755 $(IOZONE_BUILD_DIR)/postinst $(IOZONE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(IOZONE_BUILD_DIR)/prerm $(IOZONE_IPK_DIR)/CONTROL/prerm
#	echo $(IOZONE_CONFFILES) | sed -e 's/ /\n/g' > $(IOZONE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IOZONE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iozone-ipk: $(IOZONE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iozone-clean:
	rm -f $(IOZONE_BUILD_DIR)/.built
	-$(MAKE) -C $(IOZONE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iozone-dirclean:
	rm -rf $(BUILD_DIR)/$(IOZONE_DIR) $(IOZONE_BUILD_DIR) $(IOZONE_IPK_DIR) $(IOZONE_IPK)
#
#
# Some sanity check for the package.
#
iozone-check: $(IOZONE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IOZONE_IPK)
