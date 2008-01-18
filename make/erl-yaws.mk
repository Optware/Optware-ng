###########################################################
#
# erl-yaws
#
###########################################################
#
# ERL-YAWS_VERSION, ERL-YAWS_SITE and ERL-YAWS_SOURCE define
# the upstream location of the source code for the package.
# ERL-YAWS_DIR is the directory which is created when the source
# archive is unpacked.
# ERL-YAWS_UNZIP is the command used to unzip the source.
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
ERL-YAWS_SITE=http://yaws.hyber.org/download
ERL-YAWS_VERSION=1.74
ERL-YAWS_SOURCE=yaws-$(ERL-YAWS_VERSION).tar.gz
ERL-YAWS_DIR=yaws-$(ERL-YAWS_VERSION)
ERL-YAWS_UNZIP=zcat
ERL-YAWS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ERL-YAWS_DESCRIPTION=Yet Another Web Server.
ERL-YAWS_SECTION=web
ERL-YAWS_PRIORITY=optional
ERL-YAWS_DEPENDS=erlang
ERL-YAWS_SUGGESTS=
ERL-YAWS_CONFLICTS=

#
# ERL-YAWS_IPK_VERSION should be incremented when the ipk changes.
#
ERL-YAWS_IPK_VERSION=1

#
# ERL-YAWS_CONFFILES should be a list of user-editable files
ERL-YAWS_CONFFILES=/opt/etc/yaws.conf /opt/etc/yaws-cert.pem /opt/etc/yaws-key.pem

#
# ERL-YAWS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# ERL-YAWS_PATCHES=$(ERL-YAWS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ERL-YAWS_CPPFLAGS=-I$(ERLANG_BUILD_DIR)/erts/emulator/beam/
ERL-YAWS_LDFLAGS=

#
# ERL-YAWS_BUILD_DIR is the directory in which the build is done.
# ERL-YAWS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ERL-YAWS_IPK_DIR is the directory in which the ipk is built.
# ERL-YAWS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ERL-YAWS_BUILD_DIR=$(BUILD_DIR)/erl-yaws
ERL-YAWS_SOURCE_DIR=$(SOURCE_DIR)/erl-yaws
ERL-YAWS_IPK_DIR=$(BUILD_DIR)/erl-yaws-$(ERL-YAWS_VERSION)-ipk
ERL-YAWS_IPK=$(BUILD_DIR)/erl-yaws_$(ERL-YAWS_VERSION)-$(ERL-YAWS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: erl-yaws-source erl-yaws-unpack erl-yaws erl-yaws-stage erl-yaws-ipk erl-yaws-clean erl-yaws-dirclean erl-yaws-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ERL-YAWS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ERL-YAWS_SITE)/$(ERL-YAWS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
erl-yaws-source: $(DL_DIR)/$(ERL-YAWS_SOURCE) $(ERL-YAWS_PATCHES)

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
$(ERL-YAWS_BUILD_DIR)/.configured: $(DL_DIR)/$(ERL-YAWS_SOURCE) $(ERL-YAWS_PATCHES) make/erl-yaws.mk
	$(MAKE) erlang
	rm -rf $(BUILD_DIR)/$(ERL-YAWS_DIR) $(@D)
	$(ERL-YAWS_UNZIP) $(DL_DIR)/$(ERL-YAWS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ERL-YAWS_PATCHES)" ; \
		then cat $(ERL-YAWS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ERL-YAWS_DIR) -p0 ; \
	fi
	test -h $(BUILD_DIR)/yaws && rm $(BUILD_DIR)/yaws
	if test "$(BUILD_DIR)/$(ERL-YAWS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ERL-YAWS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		sed -i -e '/LD_SHARED.*ld -shared/s|ld -shared|$(TARGET_LD) -shared|' \
		       -e '/LD_SHARED.*gcc -shared/s|gcc -shared|$(TARGET_CC) -shared|' \
		       -e 's|-I/usr/include/security||' \
			configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERL-YAWS_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(ERL-YAWS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERL-YAWS_LDFLAGS)" \
		ac_cv_path_ERL=$(ERLANG_HOST_BUILD_DIR)/bin/erl \
		ac_cv_path_ERLC=$(ERLANG_HOST_BUILD_DIR)/bin/erlc \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-pam \
		--disable-nls \
		--disable-static \
		; \
	)
	sed -i -e 's|-I/usr/include/pam/||' $(@D)/c_src/Makefile
	sed -i -e '/-noshell.*mime_type_c/{s|-noshell |-noinput |}' $(@D)/src/Makefile
#	$(PATCH_LIBTOOL) $(ERL-YAWS_BUILD_DIR)/libtool
	touch $@

erl-yaws-unpack: $(ERL-YAWS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ERL-YAWS_BUILD_DIR)/.built: $(ERL-YAWS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
erl-yaws: $(ERL-YAWS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ERL-YAWS_BUILD_DIR)/.staged: $(ERL-YAWS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

erl-yaws-stage: $(ERL-YAWS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/erl-yaws
#
$(ERL-YAWS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: erl-yaws" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERL-YAWS_PRIORITY)" >>$@
	@echo "Section: $(ERL-YAWS_SECTION)" >>$@
	@echo "Version: $(ERL-YAWS_VERSION)-$(ERL-YAWS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERL-YAWS_MAINTAINER)" >>$@
	@echo "Source: $(ERL-YAWS_SITE)/$(ERL-YAWS_SOURCE)" >>$@
	@echo "Description: $(ERL-YAWS_DESCRIPTION)" >>$@
	@echo "Depends: $(ERL-YAWS_DEPENDS)" >>$@
	@echo "Suggests: $(ERL-YAWS_SUGGESTS)" >>$@
	@echo "Conflicts: $(ERL-YAWS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ERL-YAWS_IPK_DIR)/opt/sbin or $(ERL-YAWS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ERL-YAWS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ERL-YAWS_IPK_DIR)/opt/etc/erl-yaws/...
# Documentation files should be installed in $(ERL-YAWS_IPK_DIR)/opt/doc/erl-yaws/...
# Daemon startup scripts should be installed in $(ERL-YAWS_IPK_DIR)/opt/etc/init.d/S??erl-yaws
#
# You may need to patch your application to make it use these locations.
#
$(ERL-YAWS_IPK): $(ERL-YAWS_BUILD_DIR)/.built
	rm -rf $(ERL-YAWS_IPK_DIR) $(BUILD_DIR)/erl-yaws_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ERL-YAWS_BUILD_DIR) DESTDIR=$(ERL-YAWS_IPK_DIR) install
	$(STRIP_COMMAND) $(ERL-YAWS_IPK_DIR)/opt/lib/yaws/priv/lib/setuid_drv.so
	mv $(ERL-YAWS_IPK_DIR)/opt/etc/init.d/yaws $(ERL-YAWS_IPK_DIR)/opt/share/doc/$(ERL-YAWS_DIR)/sample-init.d-yaws
	sed -i \
	    -e 's|^erl=.*|erl="/opt/lib/erlang/bin/erl"|' \
	    -e 's|^run_erl=.*|run_erl="/opt/lib/erlang/bin/run_erl"|' \
	    -e 's|^to_erl=.*|to_erl="/opt/lib/erlang/bin/to_erl"|' \
	    $(ERL-YAWS_IPK_DIR)/opt/bin/yaws
	sed -i \
	    -e '/^<server localhost/,$$s/^/#/' \
	    -e 's/<server.*>/<server localhost>/' \
	    $(ERL-YAWS_IPK_DIR)/opt/etc/yaws.conf
#	install -d $(ERL-YAWS_IPK_DIR)/opt/etc/
#	install -m 644 $(ERL-YAWS_SOURCE_DIR)/erl-yaws.conf $(ERL-YAWS_IPK_DIR)/opt/etc/erl-yaws.conf
#	install -d $(ERL-YAWS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ERL-YAWS_SOURCE_DIR)/rc.erl-yaws $(ERL-YAWS_IPK_DIR)/opt/etc/init.d/SXXerl-yaws
	$(MAKE) $(ERL-YAWS_IPK_DIR)/CONTROL/control
#	install -m 755 $(ERL-YAWS_SOURCE_DIR)/postinst $(ERL-YAWS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ERL-YAWS_SOURCE_DIR)/prerm $(ERL-YAWS_IPK_DIR)/CONTROL/prerm
	echo $(ERL-YAWS_CONFFILES) | sed -e 's/ /\n/g' > $(ERL-YAWS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERL-YAWS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
erl-yaws-ipk: $(ERL-YAWS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
erl-yaws-clean:
	rm -f $(ERL-YAWS_BUILD_DIR)/.built
	-$(MAKE) -C $(ERL-YAWS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
erl-yaws-dirclean:
	rm -rf $(BUILD_DIR)/$(ERL-YAWS_DIR) $(ERL-YAWS_BUILD_DIR) $(ERL-YAWS_IPK_DIR) $(ERL-YAWS_IPK)

#
# Some sanity check for the package.
#
erl-yaws-check: $(ERL-YAWS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ERL-YAWS_IPK)
