###########################################################
#
# freeradius
#
###########################################################

# You must replace "freeradius" and "FREERADIUS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FREERADIUS_VERSION, FREERADIUS_SITE and FREERADIUS_SOURCE define
# the upstream location of the source code for the package.
# FREERADIUS_DIR is the directory which is created when the source
# archive is unpacked.
# FREERADIUS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
FREERADIUS_SITE=ftp://www.freeradius.org/pub/radius
FREERADIUS_VERSION=1.0.1
FREERADIUS_SOURCE=freeradius-$(FREERADIUS_VERSION).tar.gz
FREERADIUS_DIR=freeradius-$(FREERADIUS_VERSION)
FREERADIUS_UNZIP=zcat

#
# FREERADIUS_IPK_VERSION should be incremented when the ipk changes.
#
FREERADIUS_IPK_VERSION=1

#
# FREERADIUS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FREERADIUS_PATCHES=${FREERADIUS_SOURCE_DIR}/freeradius.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FREERADIUS_CPPFLAGS="-I${FREERADIUS_BUILD_DIR}/src/include"
FREERADIUS_LDFLAGS=

#
# FREERADIUS_BUILD_DIR is the directory in which the build is done.
# FREERADIUS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FREERADIUS_IPK_DIR is the directory in which the ipk is built.
# FREERADIUS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FREERADIUS_BUILD_DIR=$(BUILD_DIR)/freeradius
FREERADIUS_SOURCE_DIR=$(SOURCE_DIR)/freeradius
FREERADIUS_IPK_DIR=$(BUILD_DIR)/freeradius-$(FREERADIUS_VERSION)-ipk
FREERADIUS_DOC_IPK_DIR=$(BUILD_DIR)/freeradius-doc-$(FREERADIUS_VERSION)-ipk
FREERADIUS_IPK=$(BUILD_DIR)/freeradius_$(FREERADIUS_VERSION)-$(FREERADIUS_IPK_VERSION)_armeb.ipk
FREERADIUS_DOC_IPK=$(BUILD_DIR)/freeradius-doc_$(FREERADIUS_VERSION)-$(FREERADIUS_IPK_VERSION)_armeb.ipk
FREERADIUS_RLMCFLAGS="${STAGING_CPPFLAGS} -I${FREERADIUS_BUILD_DIR}/src/include -I../rlm_eap_tls -I${FREERADIUS_BUILD_DIR}/src/modules/rlm_eap -I${FREERADIUS_BUILD_DIR}/src/modules/rlm_eap/libeap/ -DX99_MODULE_NAME=\"rlm_x99_token\"  -DFREERADIUS"
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FREERADIUS_SOURCE):
	$(WGET) -P $(DL_DIR) $(FREERADIUS_SITE)/$(FREERADIUS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
freeradius-source: $(DL_DIR)/$(FREERADIUS_SOURCE) $(FREERADIUS_PATCHES)

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
$(FREERADIUS_BUILD_DIR)/.configured: $(DL_DIR)/$(FREERADIUS_SOURCE) $(FREERADIUS_PATCHES)
	$(MAKE) openssl-stage
	$(MAKE) libtool-stage
	rm -rf $(BUILD_DIR)/$(FREERADIUS_DIR) $(FREERADIUS_BUILD_DIR)
	$(FREERADIUS_UNZIP) $(DL_DIR)/$(FREERADIUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(FREERADIUS_PATCHES) | patch -d $(BUILD_DIR)/$(FREERADIUS_DIR) -p1
	mv $(BUILD_DIR)/$(FREERADIUS_DIR) $(FREERADIUS_BUILD_DIR)
	(cd $(FREERADIUS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FREERADIUS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FREERADIUS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--libdir=/opt/lib \
		--with-logdir=/var/spool/radius/log \
		--with-radacctdir=/var/spool/radius/radacct \
		--with-raddbdir=/opt/etc/raddb \
		--without-rlm-ippool \
	)
	touch $(FREERADIUS_BUILD_DIR)/.configured

freeradius-unpack: $(FREERADIUS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(FREERADIUS_BUILD_DIR)/install/opt/sbin/radiusd: $(FREERADIUS_BUILD_DIR)/.configured
	$(MAKE) -C $(FREERADIUS_BUILD_DIR) RLM_LIBS=$(STAGING_LDFLAGS) RLM_CFLAGS=${FREERADIUS_RLMCFLAGS} \
	 SNMP_INCLUDE="-I${FREERADIUS_BUILD_DIR}/src/include ${STAGING_CPPFLAGS}" LIBLTDL=${STAGING_DIR}/opt/lib/libltdl.so
	$(MAKE) install -C $(FREERADIUS_BUILD_DIR) RLM_LIBS=$(STAGING_LDFLAGS) RLM_CFLAGS=${FREERADIUS_RLMCFLAGS} \
	 LIBLTDL=${STAGING_DIR}/opt/lib/libltdl.so R=$(FREERADIUS_BUILD_DIR)/install CFLAGS=${STAGING_CPPFLAGS} \
	 R=$(FREERADIUS_BUILD_DIR)/install/

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
freeradius: $(FREERADIUS_BUILD_DIR)/install/opt/sbin/radiusd
#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libfreeradius.so.$(FREERADIUS_VERSION): $(FREERADIUS_BUILD_DIR)/libfreeradius.so.$(FREERADIUS_VERSION)
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(FREERADIUS_BUILD_DIR)/freeradius.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(FREERADIUS_BUILD_DIR)/libfreeradius.a $(STAGING_DIR)/opt/lib/freeradius
	install -m 644 $(FREERADIUS_BUILD_DIR)/libfreeradius.so.$(FREERADIUS_VERSION) $(STAGING_DIR)/opt/lib/freeradius
	cd $(STAGING_DIR)/opt/lib && ln -fs libfreeradius.so.$(FREERADIUS_VERSION) libfreeradius.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libfreeradius.so.$(FREERADIUS_VERSION) libfreeradius.so
	cp -rf $(FREERADIUS_BUILD_DIR)/install/lib/* $(STAGIN_DIR)/opt/lib/freeradius/

freeradius-stage: $(STAGING_DIR)/opt/lib/freeradius/libfreeradius.so.$(FREERADIUS_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(FREERADIUS_IPK_DIR)/opt/sbin or $(FREERADIUS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FREERADIUS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FREERADIUS_IPK_DIR)/opt/etc/freeradius/...
# Documentation files should be installed in $(FREERADIUS_IPK_DIR)/opt/doc/freeradius/...
# Daemon startup scripts should be installed in $(FREERADIUS_IPK_DIR)/opt/etc/init.d/S??freeradius
#
# You may need to patch your application to make it use these locations.
#
$(FREERADIUS_IPK): $(FREERADIUS_BUILD_DIR)/install/opt/sbin/radiusd
	rm -rf $(FREERADIUS_IPK_DIR) $(FREERADIUS_IPK)
	install -d $(FREERADIUS_IPK_DIR)/opt
	cp -rf $(FREERADIUS_BUILD_DIR)/install/* $(FREERADIUS_IPK_DIR)/
	rm -rf $(FREERADIUS_IPK_DIR)/opt/share/doc
	install -d $(FREERADIUS_IPK_DIR)/opt/doc/.radius
	rm -rf $(FREERADIUS_IPK_DIR)/opt/lib/*.a
	rm -rf $(FREERADIUS_IPK_DIR)/opt/man/*
	mv $(FREERADIUS_IPK_DIR)/opt/etc/* $(FREERADIUS_IPK_DIR)/opt/doc/.radius/
	mv $(FREERADIUS_SOURCE_DIR)/radiusd.conf $(FREERADIUS_IPK_DIR)/opt/doc/.radius/raddb/radiusd.conf
	install -d $(FREERADIUS_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(FREERADIUS_IPK_DIR)/opt/sbin/radiusd -o $(FREERADIUS_IPK_DIR)/opt/sbin/radiusd
	$(STRIP) $(FREERADIUS_IPK_DIR)/opt/bin/radzap -o $(FREERADIUS_IPK_DIR)/opt/bin/radzap
	$(STRIP) $(FREERADIUS_IPK_DIR)/opt/bin/radrelay -o $(FREERADIUS_IPK_DIR)/opt/bin/radrelay
	$(STRIP) $(FREERADIUS_IPK_DIR)/opt/bin/radclient -o $(FREERADIUS_IPK_DIR)/opt/bin/radclient
	$(STRIP) $(FREERADIUS_IPK_DIR)/opt/bin/smbencrypt -o $(FREERADIUS_IPK_DIR)/opt/bin/smbencrypt
	install -m 755 $(FREERADIUS_SOURCE_DIR)/rc.freeradius $(FREERADIUS_IPK_DIR)/opt/etc/init.d/S55freeradius
	install -d $(FREERADIUS_IPK_DIR)/CONTROL
	install -m 644 $(FREERADIUS_SOURCE_DIR)/control $(FREERADIUS_IPK_DIR)/CONTROL/control
	install -m 644 $(FREERADIUS_SOURCE_DIR)/postinst $(FREERADIUS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(FREERADIUS_SOURCE_DIR)/prerm $(FREERADIUS_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FREERADIUS_IPK_DIR)

$(FREERADIUS_DOC_IPK): $(FREERADIUS_BUILD_DIR)/install/opt/sbin/radiusd
	rm -rf $(FREERADIUS_DOC_IPK_DIR) $(FREERADIUS_DOC_IPK)
	install -d $(FREERADIUS_DOC_IPK_DIR)/opt/doc
	install -d $(FREERADIUS_DOC_IPK_DIR)/opt/man
	cp -rf $(FREERADIUS_BUILD_DIR)/install/opt/man/* $(FREERADIUS_DOC_IPK_DIR)/opt/man/
	cp -rf $(FREERADIUS_BUILD_DIR)/install/opt/share/doc/* $(FREERADIUS_DOC_IPK_DIR)/opt/doc/
	install -d $(FREERADIUS_DOC_IPK_DIR)/CONTROL
	install -m 644 $(FREERADIUS_SOURCE_DIR)/control.doc $(FREERADIUS_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FREERADIUS_DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
freeradius-ipk: $(FREERADIUS_IPK) $(FREERADIUS_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
freeradius-clean:
	-$(MAKE) -C $(FREERADIUS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
freeradius-dirclean:
	rm -rf $(BUILD_DIR)/$(FREERADIUS_DIR) $(FREERADIUS_BUILD_DIR) $(FREERADIUS_IPK_DIR) $(FREERADIUS_IPK)
	rm -rf $(FREERADIUS_DOC_IPK_DIR) $(FREERADIUS_DOC_IPK)
