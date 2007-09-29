###########################################################
#
# erl-ejabberd
#
###########################################################
#
# ERL_EJABBERD_VERSION, ERL_EJABBERD_SITE and ERL_EJABBERD_SOURCE define
# the upstream location of the source code for the package.
# ERL_EJABBERD_DIR is the directory which is created when the source
# archive is unpacked.
# ERL_EJABBERD_UNZIP is the command used to unzip the source.
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
ERL_EJABBERD_VERSION=1.1.4
ERL_EJABBERD_SITE=http://www.process-one.net/downloads/ejabberd/$(ERL_EJABBERD_VERSION)
ERL_EJABBERD_SOURCE=ejabberd-$(ERL_EJABBERD_VERSION).tar.gz
ERL_EJABBERD_DIR=ejabberd-$(ERL_EJABBERD_VERSION)
ERL_EJABBERD_UNZIP=zcat
ERL_EJABBERD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ERL_EJABBERD_DESCRIPTION=Instant messaging server written in Erlang.
ERL_EJABBERD_SECTION=net
ERL_EJABBERD_PRIORITY=optional
ERL_EJABBERD_DEPENDS=erlang
ERL_EJABBERD_SUGGESTS=
ERL_EJABBERD_CONFLICTS=

#
# ERL_EJABBERD_IPK_VERSION should be incremented when the ipk changes.
#
ERL_EJABBERD_IPK_VERSION=1

#
# ERL_EJABBERD_CONFFILES should be a list of user-editable files
#ERL_EJABBERD_CONFFILES=/opt/etc/erl-ejabberd.conf /opt/etc/init.d/SXXerl-ejabberd

#
# ERL_EJABBERD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ERL_EJABBERD_PATCHES=$(ERL_EJABBERD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ERL_EJABBERD_CPPFLAGS=-I$(ERLANG_BUILD_DIR)/erts/emulator/beam/
ERL_EJABBERD_LDFLAGS=-L$(ERLANG_BUILD_DIR)/lib/erl_interface/obj/$(ERLANG_TARGET)

#
# ERL_EJABBERD_BUILD_DIR is the directory in which the build is done.
# ERL_EJABBERD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ERL_EJABBERD_IPK_DIR is the directory in which the ipk is built.
# ERL_EJABBERD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ERL_EJABBERD_BUILD_DIR=$(BUILD_DIR)/erl-ejabberd
ERL_EJABBERD_SOURCE_DIR=$(SOURCE_DIR)/erl-ejabberd
ERL_EJABBERD_IPK_DIR=$(BUILD_DIR)/erl-ejabberd-$(ERL_EJABBERD_VERSION)-ipk
ERL_EJABBERD_IPK=$(BUILD_DIR)/erl-ejabberd_$(ERL_EJABBERD_VERSION)-$(ERL_EJABBERD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: erl-ejabberd-source erl-ejabberd-unpack erl-ejabberd erl-ejabberd-stage erl-ejabberd-ipk erl-ejabberd-clean erl-ejabberd-dirclean erl-ejabberd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ERL_EJABBERD_SOURCE):
	$(WGET) -P $(DL_DIR) $(ERL_EJABBERD_SITE)/$(ERL_EJABBERD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
erl-ejabberd-source: $(DL_DIR)/$(ERL_EJABBERD_SOURCE) $(ERL_EJABBERD_PATCHES)

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
$(ERL_EJABBERD_BUILD_DIR)/.configured: $(DL_DIR)/$(ERL_EJABBERD_SOURCE) $(ERL_EJABBERD_PATCHES) make/erl-ejabberd.mk
	$(MAKE) erlang
	rm -rf $(BUILD_DIR)/$(ERL_EJABBERD_DIR) $(ERL_EJABBERD_BUILD_DIR)
	$(ERL_EJABBERD_UNZIP) $(DL_DIR)/$(ERL_EJABBERD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ERL_EJABBERD_PATCHES)" ; \
		then cat $(ERL_EJABBERD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ERL_EJABBERD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ERL_EJABBERD_DIR)" != "$(ERL_EJABBERD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ERL_EJABBERD_DIR) $(ERL_EJABBERD_BUILD_DIR) ; \
	fi
	(cd $(ERL_EJABBERD_BUILD_DIR)/src; \
		sed -i -e 's/	gcc -Wall/	$$(CC) -Wall/' Makefile.in stringprep/Makefile.in; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERL_EJABBERD_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(ERL-YAWS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERL_EJABBERD_LDFLAGS)" \
		ac_cv_path_ERL=$(ERLANG_HOST_BUILD_DIR)/bin/erl \
		ac_cv_path_ERLC=$(ERLANG_HOST_BUILD_DIR)/bin/erlc \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-openssl=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(ERL_EJABBERD_BUILD_DIR)/libtool
	touch $(ERL_EJABBERD_BUILD_DIR)/.configured

erl-ejabberd-unpack: $(ERL_EJABBERD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ERL_EJABBERD_BUILD_DIR)/.built: $(ERL_EJABBERD_BUILD_DIR)/.configured
	rm -f $(ERL_EJABBERD_BUILD_DIR)/.built
	$(MAKE) -C $(ERL_EJABBERD_BUILD_DIR)/src \
	ERLANG_CFLAGS=-I$(ERLANG_BUILD_DIR)/lib/erl_interface/include \
	ERLC_FLAGS=-I$(ERLANG_BUILD_DIR)/lib
	touch $(ERL_EJABBERD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
erl-ejabberd: $(ERL_EJABBERD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ERL_EJABBERD_BUILD_DIR)/.staged: $(ERL_EJABBERD_BUILD_DIR)/.built
	rm -f $(ERL_EJABBERD_BUILD_DIR)/.staged
	$(MAKE) -C $(ERL_EJABBERD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ERL_EJABBERD_BUILD_DIR)/.staged

erl-ejabberd-stage: $(ERL_EJABBERD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/erl-ejabberd
#
$(ERL_EJABBERD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: erl-ejabberd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERL_EJABBERD_PRIORITY)" >>$@
	@echo "Section: $(ERL_EJABBERD_SECTION)" >>$@
	@echo "Version: $(ERL_EJABBERD_VERSION)-$(ERL_EJABBERD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERL_EJABBERD_MAINTAINER)" >>$@
	@echo "Source: $(ERL_EJABBERD_SITE)/$(ERL_EJABBERD_SOURCE)" >>$@
	@echo "Description: $(ERL_EJABBERD_DESCRIPTION)" >>$@
	@echo "Depends: $(ERL_EJABBERD_DEPENDS)" >>$@
	@echo "Suggests: $(ERL_EJABBERD_SUGGESTS)" >>$@
	@echo "Conflicts: $(ERL_EJABBERD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ERL_EJABBERD_IPK_DIR)/opt/sbin or $(ERL_EJABBERD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ERL_EJABBERD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ERL_EJABBERD_IPK_DIR)/opt/etc/erl-ejabberd/...
# Documentation files should be installed in $(ERL_EJABBERD_IPK_DIR)/opt/doc/erl-ejabberd/...
# Daemon startup scripts should be installed in $(ERL_EJABBERD_IPK_DIR)/opt/etc/init.d/S??erl-ejabberd
#
# You may need to patch your application to make it use these locations.
#
$(ERL_EJABBERD_IPK): $(ERL_EJABBERD_BUILD_DIR)/.built
	rm -rf $(ERL_EJABBERD_IPK_DIR) $(BUILD_DIR)/erl-ejabberd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ERL_EJABBERD_BUILD_DIR)/src DESTDIR=$(ERL_EJABBERD_IPK_DIR) install
#	install -d $(ERL_EJABBERD_IPK_DIR)/opt/etc/
#	install -m 644 $(ERL_EJABBERD_SOURCE_DIR)/erl-ejabberd.conf $(ERL_EJABBERD_IPK_DIR)/opt/etc/erl-ejabberd.conf
#	install -d $(ERL_EJABBERD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ERL_EJABBERD_SOURCE_DIR)/rc.erl-ejabberd $(ERL_EJABBERD_IPK_DIR)/opt/etc/init.d/SXXerl-ejabberd
	(cd $(ERL_EJABBERD_IPK_DIR)/opt/ ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(ERL_EJABBERD_IPK_DIR)/CONTROL/control
#	install -m 755 $(ERL_EJABBERD_SOURCE_DIR)/postinst $(ERL_EJABBERD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ERL_EJABBERD_SOURCE_DIR)/prerm $(ERL_EJABBERD_IPK_DIR)/CONTROL/prerm
	echo $(ERL_EJABBERD_CONFFILES) | sed -e 's/ /\n/g' > $(ERL_EJABBERD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERL_EJABBERD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
erl-ejabberd-ipk: $(ERL_EJABBERD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
erl-ejabberd-clean:
	rm -f $(ERL_EJABBERD_BUILD_DIR)/.built
	-$(MAKE) -C $(ERL_EJABBERD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
erl-ejabberd-dirclean:
	rm -rf $(BUILD_DIR)/$(ERL_EJABBERD_DIR) $(ERL_EJABBERD_BUILD_DIR) $(ERL_EJABBERD_IPK_DIR) $(ERL_EJABBERD_IPK)
#
#
# Some sanity check for the package.
#
erl-ejabberd-check: $(ERL_EJABBERD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ERL_EJABBERD_IPK)
