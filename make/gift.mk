###########################################################
#
# gift
#
###########################################################

# You must replace "gift" and "GIFT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIFT_VERSION, GIFT_SITE and GIFT_SOURCE define
# the upstream location of the source code for the package.
# GIFT_DIR is the directory which is created when the source
# archive is unpacked.
# GIFT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFT_SITE=http://unc.dl.sourceforge.net/sourceforge/gift
GIFT_VERSION=0.11.8.1
GIFT_VERSION_LIB=0.0.0
GIFT_SOURCE=gift-$(GIFT_VERSION).tar.bz2
GIFT_DIR=gift-$(GIFT_VERSION)
GIFT_UNZIP=bzcat

#
# GIFT_IPK_VERSION should be incremented when the ipk changes.
#
GIFT_IPK_VERSION=1

#
# GIFT_CONFFILES should be a list of user-editable files
GIFT_CONFFILES=/opt/etc/gift.conf /opt/etc/init.d/SXXgift

#
# GIFT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIFT_PATCHES=$(GIFT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFT_CPPFLAGS=
GIFT_LDFLAGS=

#
# GIFT_BUILD_DIR is the directory in which the build is done.
# GIFT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFT_IPK_DIR is the directory in which the ipk is built.
# GIFT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFT_BUILD_DIR=$(BUILD_DIR)/gift
GIFT_SOURCE_DIR=$(SOURCE_DIR)/gift
GIFT_IPK_DIR=$(BUILD_DIR)/gift-$(GIFT_VERSION)-ipk
GIFT_IPK=$(BUILD_DIR)/gift_$(GIFT_VERSION)-$(GIFT_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIFT_SITE)/$(GIFT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-source: $(DL_DIR)/$(GIFT_SOURCE) $(GIFT_PATCHES)

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
$(GIFT_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFT_SOURCE) $(GIFT_PATCHES)
	$(MAKE) libogg-stage libvorbis-stage
	rm -rf $(BUILD_DIR)/$(GIFT_DIR) $(GIFT_BUILD_DIR)
	$(GIFT_UNZIP) $(DL_DIR)/$(GIFT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIFT_PATCHES) | patch -d $(BUILD_DIR)/$(GIFT_DIR) -p1
	mv $(BUILD_DIR)/$(GIFT_DIR) $(GIFT_BUILD_DIR)
	(cd $(GIFT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIFT_BUILD_DIR)/.configured

gift-unpack: $(GIFT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.

$(GIFT_BUILD_DIR)/src/.libs/giftd: $(GIFT_BUILD_DIR)/.configured
	rm -f $(GIFT_BUILD_DIR)/.built
	$(MAKE) -C $(GIFT_BUILD_DIR)
	touch $(GIFT_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gift: $(GIFT_BUILD_DIR)/src/.libs/giftd

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgift.so.$(GIFT_VERSION): $(GIFT_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include/libgift/proto
	install -m 644 $(GIFT_BUILD_DIR)/lib/list.h $(STAGING_DIR)/opt/include
#	install -m 644 $(GIFT_BUILD_DIR)/lib/memory.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/list_lock.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/tree.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/array.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/tcpc.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/fdbuf.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/interface.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/conf.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/log.h $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_BUILD_DIR)/lib/tcpc.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/libgift.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/stopwatch.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/mime.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/giftconfig.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/platform.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/strobj.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/parse.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/event.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/file.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/list.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/dataset.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/network.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/fdbuf.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/lib/fdbuf.h $(STAGING_DIR)/opt/include/libgift
	install -m 644 $(GIFT_BUILD_DIR)/plugin/transfer_api.h $(STAGING_DIR)/opt/include/libgift/proto
	install -m 644 $(GIFT_BUILD_DIR)/plugin/share_hash.h $(STAGING_DIR)/opt/include/libgift/proto
	install -m 644 $(GIFT_BUILD_DIR)/plugin/share.h $(STAGING_DIR)/opt/include/libgift/proto
	install -m 644 $(GIFT_BUILD_DIR)/plugin/protocol.h $(STAGING_DIR)/opt/include/libgift/proto
	install -m 644 $(GIFT_BUILD_DIR)/plugin/protocol_ver.h $(STAGING_DIR)/opt/include/libgift/proto
	install -m 644 $(GIFT_BUILD_DIR)/plugin/if_event_api.h $(STAGING_DIR)/opt/include/libgift/proto
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFT_BUILD_DIR)/lib/libgift.pc $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFT_BUILD_DIR)/lib/.libs/libgift.so.$(GIFT_VERSION_LIB) $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFT_BUILD_DIR)/plugin/.libs/libgiftproto.so.$(GIFT_VERSION_LIB) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift.so.$(GIFT_VERSION_LIB) libgift.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift.so.$(GIFT_VERSION_LIB) libgift.so.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift.so.$(GIFT_VERSION_LIB) libgift.so
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiftproto.so.$(GIFT_VERSION_LIB) libgiftproto.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiftproto.so.$(GIFT_VERSION_LIB) libgiftproto.so.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiftproto.so.$(GIFT_VERSION_LIB) libgiftproto.so

gift-stage: $(STAGING_DIR)/opt/lib/libgift.so.$(GIFT_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFT_IPK_DIR)/opt/sbin or $(GIFT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFT_IPK_DIR)/opt/etc/gift/...
# Documentation files should be installed in $(GIFT_IPK_DIR)/opt/doc/gift/...
# Daemon startup scripts should be installed in $(GIFT_IPK_DIR)/opt/etc/init.d/S??gift
#
# You may need to patch your application to make it use these locations.
#
$(GIFT_IPK): $(GIFT_BUILD_DIR)/.built
	rm -rf $(GIFT_IPK_DIR) $(BUILD_DIR)/gift_*_armeb.ipk
	install -d $(GIFT_IPK_DIR)/opt/share/giFT
	install -m 644 $(GIFT_BUILD_DIR)/etc/giftd.conf.template $(GIFT_IPK_DIR)/opt/share/giFT/giftd.conf.template
	install -m 644 $(GIFT_BUILD_DIR)/data/mime.types $(GIFT_IPK_DIR)/opt/share/giFT/mime.types
	install -d $(GIFT_IPK_DIR)/opt/bin
	install -m 644 $(GIFT_BUILD_DIR)/gift-setup $(GIFT_IPK_DIR)/opt/bin/gift-setup
	$(STRIP_COMMAND) $(GIFT_BUILD_DIR)/src/.libs/giftd -o $(GIFT_IPK_DIR)/opt/bin/giftd
	install -d $(GIFT_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(GIFT_BUILD_DIR)/lib/.libs/libgift.so.$(GIFT_VERSION_LIB) -o $(GIFT_IPK_DIR)/opt/lib/libgift.so.$(GIFT_VERSION_LIB)
	$(STRIP_COMMAND) $(GIFT_BUILD_DIR)/plugin/.libs/libgiftproto.so.$(GIFT_VERSION_LIB) -o $(GIFT_IPK_DIR)/opt/lib/libgiftproto.so.$(GIFT_VERSION_LIB)
	install -d $(GIFT_IPK_DIR)/CONTROL
	install -m 644 $(GIFT_SOURCE_DIR)/control $(GIFT_IPK_DIR)/CONTROL/control
	cd $(GIFT_IPK_DIR)/opt/lib && ln -fs libgift.so.$(GIFT_VERSION_LIB) libgift.so.0
	cd $(GIFT_IPK_DIR)/opt/lib && ln -fs libgiftproto.so.$(GIFT_VERSION_LIB) libgiftproto.so.0
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-ipk: $(GIFT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-clean:
	-$(MAKE) -C $(GIFT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFT_DIR) $(GIFT_BUILD_DIR) $(GIFT_IPK_DIR) $(GIFT_IPK)
