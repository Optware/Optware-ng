#############################################################
#
# nfs-server
#
#############################################################

NFS_SERVER_DIR:=$(BUILD_DIR)/nfs-server

NFS_SERVER_VERSION=2.2beta47
NFS_SERVER=nfs-server-$(NFS_SERVER_VERSION)
NFS_SERVER_SITE=http://linux.mathematik.tu-darmstadt.de/linux/people/okir
NFS_SERVER_SOURCE:=$(NFS_SERVER).tar.gz
NFS_SERVER_UNZIP=zcat
NFS_SERVER_PATCH:=$(SOURCE_DIR)/nfs-server.patch
NFS_SERVER_IPK=$(BUILD_DIR)/nfs-server_$(NFS_SERVER_VERSION)-1_armeb.ipk
NFS_SERVER_IPK_DIR:=$(BUILD_DIR)/nfs-server-$(NFS_SERVER_VERSION)-ipk

$(DL_DIR)/$(NFS_SERVER_SOURCE):
	$(WGET) -P $(DL_DIR) $(NFS_SERVER_SITE)/$(NFS_SERVER_SOURCE)

nfs-server-source: $(DL_DIR)/$(NFS_SERVER_SOURCE) $(NFS_SERVER_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(NFS_SERVER_DIR)/.configured: $(DL_DIR)/$(NFS_SERVER_SOURCE) $(NFS_SERVER_PATCH)
	@rm -rf $(BUILD_DIR)/$(NFS_SERVER) $(NFS_SERVER_DIR)
	$(NFS_SERVER_UNZIP) $(DL_DIR)/$(NFS_SERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	(cd $(BUILD_DIR)/$(NFS_SERVER) && \
	./BUILD --batch \
		--multi \
		--devtab=no \
		--ugidd=no \
		--nis=no \
		--hosts-access=no \
		--exports-uid=0 \
		--exports-gid=0 \
		--log-mounts=yes)
	patch -d $(BUILD_DIR)/$(NFS_SERVER) -p1 < $(NFS_SERVER_PATCH)
	mv $(BUILD_DIR)/$(NFS_SERVER) $(NFS_SERVER_DIR)
	touch $(NFS_SERVER_DIR)/.configured

nfs-server-unpack: $(NFS_SERVER_DIR)/.configured

$(NFS_SERVER_DIR)/rpc.nfsd: $(NFS_SERVER_DIR)/.configured
	make -C $(NFS_SERVER_DIR) \
		CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)

nfs-server: $(NFS_SERVER_DIR)/rpc.nfsd

nfs-server-diff: #$(NFS_SERVER_DIR)/config.h
	@rm -rf $(BUILD_DIR)/$(NFS_SERVER)
	$(NFS_SERVER_UNZIP) $(DL_DIR)/$(NFS_SERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	-make -C $(NFS_SERVER_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(NFS_SERVER) nfs-server | grep -v ^Only > $(NFS_SERVER_PATCH)

$(NFS_SERVER_IPK): $(NFS_SERVER_DIR)/rpc.nfsd
	install -d $(NFS_SERVER_IPK_DIR)/CONTROL
	install -d $(NFS_SERVER_IPK_DIR)/opt/sbin $(NFS_SERVER_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(NFS_SERVER_DIR)/rpc.nfsd -o $(NFS_SERVER_IPK_DIR)/opt/sbin/rpc.nfsd
	$(STRIP) $(NFS_SERVER_DIR)/rpc.mountd -o $(NFS_SERVER_IPK_DIR)/opt/sbin/rpc.mountd
	install -m 755 $(SOURCE_DIR)/nfs-server.rc $(NFS_SERVER_IPK_DIR)/opt/etc/init.d/S56nfsd
	install -m 644 $(SOURCE_DIR)/nfs-server.control  $(NFS_SERVER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NFS_SERVER_IPK_DIR)

nfs-server-ipk: $(NFS_SERVER_IPK)

nfs-server-clean:
	-make -C $(NFS_SERVER_DIR) clean

nfs-server-dirclean:
	rm -rf $(NFS_SERVER_DIR) $(NFS_SERVER_IPK_DIR) $(NFS_SERVER_IPK)
