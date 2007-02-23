###########################################################
#
# libnetfilter-queue
#
###########################################################
#
# LIBNETFILTER_QUEUE_VERSION, LIBNETFILTER_QUEUE_SITE and LIBNETFILTER_QUEUE_SOURCE define
# the upstream location of the source code for the package.
# LIBNETFILTER_QUEUE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNETFILTER_QUEUE_UNZIP is the command used to unzip the source.
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
LIBNETFILTER_QUEUE_SITE=ftp://ftp.netfilter.org/pub/libnetfilter_queue
LIBNETFILTER_QUEUE_VERSION=0.0.11
LIBNETFILTER_QUEUE_SOURCE=libnetfilter_queue-$(LIBNETFILTER_QUEUE_VERSION).tar.bz2
LIBNETFILTER_QUEUE_DIR=libnetfilter_queue-$(LIBNETFILTER_QUEUE_VERSION)
LIBNETFILTER_QUEUE_UNZIP=bzcat
LIBNETFILTER_QUEUE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNETFILTER_QUEUE_DESCRIPTION=API to packets that have been queued by the kernel packet filter.
LIBNETFILTER_QUEUE_SECTION=kernel
LIBNETFILTER_QUEUE_PRIORITY=optional
LIBNETFILTER_QUEUE_DEPENDS=libnfnetlink
LIBNETFILTER_QUEUE_SUGGESTS=
LIBNETFILTER_QUEUE_CONFLICTS=

#
# LIBNETFILTER_QUEUE_IPK_VERSION should be incremented when the ipk changes.
#
LIBNETFILTER_QUEUE_IPK_VERSION=1

#
# LIBNETFILTER_QUEUE_CONFFILES should be a list of user-editable files
#LIBNETFILTER_QUEUE_CONFFILES=/opt/etc/libnetfilter-queue.conf /opt/etc/init.d/SXXlibnetfilter-queue

#
# LIBNETFILTER_QUEUE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNETFILTER_QUEUE_PATCHES=$(LIBNETFILTER_QUEUE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNETFILTER_QUEUE_CPPFLAGS=
LIBNETFILTER_QUEUE_LDFLAGS=

#
# LIBNETFILTER_QUEUE_BUILD_DIR is the directory in which the build is done.
# LIBNETFILTER_QUEUE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNETFILTER_QUEUE_IPK_DIR is the directory in which the ipk is built.
# LIBNETFILTER_QUEUE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNETFILTER_QUEUE_BUILD_DIR=$(BUILD_DIR)/libnetfilter-queue
LIBNETFILTER_QUEUE_SOURCE_DIR=$(SOURCE_DIR)/libnetfilter-queue
LIBNETFILTER_QUEUE_IPK_DIR=$(BUILD_DIR)/libnetfilter-queue-$(LIBNETFILTER_QUEUE_VERSION)-ipk
LIBNETFILTER_QUEUE_IPK=$(BUILD_DIR)/libnetfilter-queue_$(LIBNETFILTER_QUEUE_VERSION)-$(LIBNETFILTER_QUEUE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnetfilter-queue-source libnetfilter-queue-unpack libnetfilter-queue libnetfilter-queue-stage libnetfilter-queue-ipk libnetfilter-queue-clean libnetfilter-queue-dirclean libnetfilter-queue-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNETFILTER_QUEUE_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNETFILTER_QUEUE_SITE)/$(LIBNETFILTER_QUEUE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNETFILTER_QUEUE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnetfilter-queue-source: $(DL_DIR)/$(LIBNETFILTER_QUEUE_SOURCE) $(LIBNETFILTER_QUEUE_PATCHES)

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
$(LIBNETFILTER_QUEUE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNETFILTER_QUEUE_SOURCE) $(LIBNETFILTER_QUEUE_PATCHES) make/libnetfilter-queue.mk
	$(MAKE) libnfnetlink-stage
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_QUEUE_DIR) $(LIBNETFILTER_QUEUE_BUILD_DIR)
	$(LIBNETFILTER_QUEUE_UNZIP) $(DL_DIR)/$(LIBNETFILTER_QUEUE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNETFILTER_QUEUE_PATCHES)" ; \
		then cat $(LIBNETFILTER_QUEUE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBNETFILTER_QUEUE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNETFILTER_QUEUE_DIR)" != "$(LIBNETFILTER_QUEUE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNETFILTER_QUEUE_DIR) $(LIBNETFILTER_QUEUE_BUILD_DIR) ; \
	fi
	(cd $(LIBNETFILTER_QUEUE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNETFILTER_QUEUE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNETFILTER_QUEUE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBNETFILTER_QUEUE_BUILD_DIR)/libtool
	touch $@

libnetfilter-queue-unpack: $(LIBNETFILTER_QUEUE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNETFILTER_QUEUE_BUILD_DIR)/.built: $(LIBNETFILTER_QUEUE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNETFILTER_QUEUE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnetfilter-queue: $(LIBNETFILTER_QUEUE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNETFILTER_QUEUE_BUILD_DIR)/.staged: $(LIBNETFILTER_QUEUE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNETFILTER_QUEUE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libnetfilter-queue-stage: $(LIBNETFILTER_QUEUE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnetfilter-queue
#
$(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libnetfilter-queue" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNETFILTER_QUEUE_PRIORITY)" >>$@
	@echo "Section: $(LIBNETFILTER_QUEUE_SECTION)" >>$@
	@echo "Version: $(LIBNETFILTER_QUEUE_VERSION)-$(LIBNETFILTER_QUEUE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNETFILTER_QUEUE_MAINTAINER)" >>$@
	@echo "Source: $(LIBNETFILTER_QUEUE_SITE)/$(LIBNETFILTER_QUEUE_SOURCE)" >>$@
	@echo "Description: $(LIBNETFILTER_QUEUE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETFILTER_QUEUE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETFILTER_QUEUE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETFILTER_QUEUE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/sbin or $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/libnetfilter-queue/...
# Documentation files should be installed in $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/doc/libnetfilter-queue/...
# Daemon startup scripts should be installed in $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/init.d/S??libnetfilter-queue
#
# You may need to patch your application to make it use these locations.
#
$(LIBNETFILTER_QUEUE_IPK): $(LIBNETFILTER_QUEUE_BUILD_DIR)/.built
	rm -rf $(LIBNETFILTER_QUEUE_IPK_DIR) $(BUILD_DIR)/libnetfilter-queue_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNETFILTER_QUEUE_BUILD_DIR) DESTDIR=$(LIBNETFILTER_QUEUE_IPK_DIR) install-strip
	rm -rf $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/include
#	install -d $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBNETFILTER_QUEUE_SOURCE_DIR)/libnetfilter-queue.conf $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/libnetfilter-queue.conf
#	install -d $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBNETFILTER_QUEUE_SOURCE_DIR)/rc.libnetfilter-queue $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/init.d/SXXlibnetfilter-queue
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_QUEUE_IPK_DIR)/opt/etc/init.d/SXXlibnetfilter-queue
	$(MAKE) $(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBNETFILTER_QUEUE_SOURCE_DIR)/postinst $(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBNETFILTER_QUEUE_SOURCE_DIR)/prerm $(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/prerm
#	echo $(LIBNETFILTER_QUEUE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNETFILTER_QUEUE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETFILTER_QUEUE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnetfilter-queue-ipk: $(LIBNETFILTER_QUEUE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnetfilter-queue-clean:
	rm -f $(LIBNETFILTER_QUEUE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNETFILTER_QUEUE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnetfilter-queue-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_QUEUE_DIR) $(LIBNETFILTER_QUEUE_BUILD_DIR) $(LIBNETFILTER_QUEUE_IPK_DIR) $(LIBNETFILTER_QUEUE_IPK)
#
#
# Some sanity check for the package.
#
libnetfilter-queue-check: $(LIBNETFILTER_QUEUE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNETFILTER_QUEUE_IPK)
