#############################################################
#
# nfs-server
#
#############################################################

NFS-SERVER_DIR:=$(BUILD_DIR)/nfs-server

NFS-SERVER_VERSION=2.2beta47
NFS-SERVER=nfs-server-$(NFS-SERVER_VERSION)
NFS-SERVER_SITE=http://linux.mathematik.tu-darmstadt.de/linux/people/okir
NFS-SERVER_SOURCE:=$(NFS-SERVER).tar.gz
NFS-SERVER_UNZIP=zcat
NFS-SERVER_PATCH:=$(SOURCE_DIR)/nfs-server.patch
NFS-SERVER_IPK=$(BUILD_DIR)/nfs-server_$(NFS-SERVER_VERSION)-1_armeb.ipk
NFS-SERVER_IPK_DIR:=$(BUILD_DIR)/nfs-server-$(NFS-SERVER_VERSION)-ipk

$(DL_DIR)/$(NFS-SERVER_SOURCE):
	$(WGET) -P $(DL_DIR) $(NFS-SERVER_SITE)/$(NFS-SERVER_SOURCE)

nfs-server-source: $(DL_DIR)/$(NFS-SERVER_SOURCE) $(NFS-SERVER_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(NFS-SERVER_DIR): $(DL_DIR)/$(NFS-SERVER_SOURCE) $(NFS-SERVER_PATCH)
	@rm -rf $(BUILD_DIR)/$(NFS-SERVER) $(NFS-SERVER_DIR)
	$(NFS-SERVER_UNZIP) $(DL_DIR)/$(NFS-SERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	(cd $(BUILD_DIR)/$(NFS-SERVER) && \
	./BUILD --batch \
		--multi \
		--devtab=no \
		--ugidd=no \
		--nis=no \
		--hosts-access=no \
		--exports-uid=0 \
		--exports-gid=0 \
		--log-mounts=yes)
	patch -d $(BUILD_DIR)/$(NFS-SERVER) -p1 < $(NFS-SERVER_PATCH)
	mv $(BUILD_DIR)/$(NFS-SERVER) $(NFS-SERVER_DIR)
	make -C $(NFS-SERVER_DIR) 

nfs-server: $(NFS-SERVER_DIR)

nfs-server-diff: #$(NFS-SERVER_DIR)/config.h
	@rm -rf $(BUILD_DIR)/$(NFS-SERVER)
	$(NFS-SERVER_UNZIP) $(DL_DIR)/$(NFS-SERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	-make -C $(NFS-SERVER_DIR) distclean
	-cd $(BUILD_DIR) && diff -BurN $(NFS-SERVER) nfs-server | grep -v ^Only > $(NFS-SERVER_PATCH)

$(NFS-SERVER_IPK): $(NFS-SERVER_DIR)
	install -d $(NFS-SERVER_IPK_DIR)/CONTROL
	install -d $(NFS-SERVER_IPK_DIR)/opt/sbin $(NFS-SERVER_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(NFS-SERVER_DIR)/rpc.nfsd -o $(NFS-SERVER_IPK_DIR)/opt/sbin/rpc.nfsd
	$(STRIP) $(NFS-SERVER_DIR)/rpc.mountd -o $(NFS-SERVER_IPK_DIR)/opt/sbin/rpc.mountd
	install -m 755 $(SOURCE_DIR)/nfs-server.rc $(NFS-SERVER_IPK_DIR)/opt/etc/init.d/S55nfsd
	install -m 644 $(SOURCE_DIR)/nfs-server.control  $(NFS-SERVER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NFS-SERVER_IPK_DIR)

nfs-server-ipk: $(NFS-SERVER_IPK)

nfs-server-clean:
	-make -C $(NFS-SERVER_DIR) clean

nfs-server-dirclean:
	rm -rf $(NFS-SERVER_DIR) $(NFS-SERVER_IPK_DIR)
