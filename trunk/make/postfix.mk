###########################################################
#
# postfix
#
###########################################################

# You must replace "postfix" and "POSTFIX" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# POSTFIX_VERSION, POSTFIX_SITE and POSTFIX_SOURCE define
# the upstream location of the source code for the package.
# POSTFIX_DIR is the directory which is created when the source
# archive is unpacked.
# POSTFIX_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
POSTFIX_SITE=ftp://netmirror.org/postfix.org/official
POSTFIX_VERSION=2.1.5
POSTFIX_SOURCE=postfix-$(POSTFIX_VERSION).tar.gz
POSTFIX_DIR=postfix-$(POSTFIX_VERSION)
POSTFIX_UNZIP=zcat

#
# POSTFIX_IPK_VERSION should be incremented when the ipk changes.
#
POSTFIX_IPK_VERSION=1

#
# POSTFIX_CONFFILES should be a list of user-editable files
#POSTFIX_CONFFILES=/opt/etc/postfix.conf /opt/etc/init.d/SXXpostfix
POSTFIX_CONFFILES=

#
# POSTFIX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
POSTFIX_PATCHES=$(POSTFIX_SOURCE_DIR)/postfix.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POSTFIX_CPPFLAGS=
POSTFIX_LDFLAGS=

#
# POSTFIX_BUILD_DIR is the directory in which the build is done.
# POSTFIX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POSTFIX_IPK_DIR is the directory in which the ipk is built.
# POSTFIX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POSTFIX_BUILD_DIR=$(BUILD_DIR)/postfix
POSTFIX_SOURCE_DIR=$(SOURCE_DIR)/postfix
POSTFIX_IPK_DIR=$(BUILD_DIR)/postfix-$(POSTFIX_VERSION)-ipk
POSTFIX_IPK=$(BUILD_DIR)/postfix_$(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POSTFIX_SOURCE):
	$(WGET) -P $(DL_DIR) $(POSTFIX_SITE)/$(POSTFIX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
postfix-source: $(DL_DIR)/$(POSTFIX_SOURCE) $(POSTFIX_PATCHES)

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
$(POSTFIX_BUILD_DIR)/.configured: $(DL_DIR)/$(POSTFIX_SOURCE) $(POSTFIX_PATCHES)
	$(MAKE) libdb-stage
	$(MAKE) pcre-stage
#	$(MAKE) cyrus-sasl-stage
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR)
	$(POSTFIX_UNZIP) $(DL_DIR)/$(POSTFIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(POSTFIX_PATCHES) | patch -d $(BUILD_DIR)/$(POSTFIX_DIR) -p1
	mv $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR)
	(cd $(POSTFIX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POSTFIX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POSTFIX_LDFLAGS)" \
		make makefiles \
		CCARGS=' \
			-DDEF_COMMAND_DIR=\"/opt/sbin\" \
			-DDEF_CONFIG_DIR=\"/opt/etc/postfix\" \
			-DDEF_DAEMON_DIR=\"/opt/libexec/postfix\" \
			-DDEF_MAILQ_PATH=\"/opt/bin/mailq\" \
			-DDEF_HTML_DIR=\"/opt/share/doc/postfix/html\" \
			-DDEF_MANPAGE_DIR=\"/opt/man\" \
			-DDEF_NEWALIAS_PATH=\"/opt/bin/newaliases\" \
			-DDEF_QUEUE_DIR=\"/var/spool/postfix\" \
			-DDEF_README_DIR=\"/opt/share/doc/postfix/readme\" \
			-DDEF_SENDMAIL_PATH=\"/opt/sbin/sendmail\" \
			-DUSE_SASL_AUTH \
			-I$(STAGING_INCLUDE_DIR) \
			-I$(STAGING_INCLUDE_DIR)/sasl \
			' \
		AUXLIBS="-L$(STAGING_LIB_DIR) -ldb -lsasl2" \
	)
	touch $(POSTFIX_BUILD_DIR)/.configured

postfix-unpack: $(POSTFIX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POSTFIX_BUILD_DIR)/.built: $(POSTFIX_BUILD_DIR)/.configured
	rm -f $(POSTFIX_BUILD_DIR)/.built
	$(MAKE) -C $(POSTFIX_BUILD_DIR)
	touch $(POSTFIX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
postfix: $(POSTFIX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POSTFIX_BUILD_DIR)/.staged: $(POSTFIX_BUILD_DIR)/.built
	rm -f $(POSTFIX_BUILD_DIR)/.staged
#	$(MAKE) -C $(POSTFIX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	echo "The makefile target 'postfix-stage' is still empty."
	touch $(POSTFIX_BUILD_DIR)/.staged

postfix-stage: $(POSTFIX_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(POSTFIX_IPK_DIR)/opt/sbin or $(POSTFIX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POSTFIX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POSTFIX_IPK_DIR)/opt/etc/postfix/...
# Documentation files should be installed in $(POSTFIX_IPK_DIR)/opt/doc/postfix/...
# Daemon startup scripts should be installed in $(POSTFIX_IPK_DIR)/opt/etc/init.d/S??postfix
#
# You may need to patch your application to make it use these locations.
#
$(POSTFIX_IPK): $(POSTFIX_BUILD_DIR)/.built
	echo "The makefile target 'postfix-ipk' is still empty."
#	rm -rf $(POSTFIX_IPK_DIR) $(BUILD_DIR)/postfix_*_armeb.ipk
#	$(MAKE) -C $(POSTFIX_BUILD_DIR) DESTDIR=$(POSTFIX_IPK_DIR) install
#	install -d $(POSTFIX_IPK_DIR)/opt/etc/
#	install -m 755 $(POSTFIX_SOURCE_DIR)/postfix.conf $(POSTFIX_IPK_DIR)/opt/etc/postfix.conf
#	install -d $(POSTFIX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(POSTFIX_SOURCE_DIR)/rc.postfix $(POSTFIX_IPK_DIR)/opt/etc/init.d/SXXpostfix
#	install -d $(POSTFIX_IPK_DIR)/CONTROL
#	install -m 644 $(POSTFIX_SOURCE_DIR)/control $(POSTFIX_IPK_DIR)/CONTROL/control
#	install -m 644 $(POSTFIX_SOURCE_DIR)/postinst $(POSTFIX_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(POSTFIX_SOURCE_DIR)/prerm $(POSTFIX_IPK_DIR)/CONTROL/prerm
#	echo $(POSTFIX_CONFFILES) | sed -e 's/ /\n/g' > $(POSTFIX_IPK_DIR)/CONTROL/conffiles
#	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
postfix-ipk: $(POSTFIX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
postfix-clean:
	-$(MAKE) -C $(POSTFIX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
postfix-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR) $(POSTFIX_IPK_DIR) $(POSTFIX_IPK)
