#############################################################
#
# mysql server
#
#############################################################

MYSQL_DIR:=$(BUILD_DIR)/mysql

MYSQL_VERSION=4.1.4
MYSQL=mysql-$(MYSQL_VERSION)-gamma
MYSQL_SITE=http://mirrors.develooper.com/mysql/Downloads/MySQL-4.1/
MYSQL_SOURCE:=$(MYSQL).tar.gz
MYSQL_UNZIP=zcat
MYSQL_IPK=$(BUILD_DIR)/mysql_$(MYSQL_VERSION)-1_$(TARGET_ARCH).ipk
MYSQL_IPK_DIR:=$(BUILD_DIR)/mysql-$(MYSQL_VERSION)-ipk
MYSQL_PATCH=$(SOURCE_DIR)/mysql.patch

MYSQL_CFLAGS="-I$(STAGING_DIR)/opt/include/ncurses -I$(STAGING_DIR)/opt/include"
MYSQL_LDFLAGS:="-L$(STAGING_DIR)/opt/lib"

$(DL_DIR)/$(MYSQL_SOURCE):
	$(WGET) -P $(DL_DIR) $(MYSQL_SITE)/$(MYSQL_SOURCE)

mysql-source: $(DL_DIR)/$(MYSQL_SOURCE) $(MYSQL_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(MYSQL_DIR)/.configured: $(DL_DIR)/$(MYSQL_SOURCE)
	@rm -rf $(BUILD_DIR)/$(MYSQL) $(MYSQL_DIR)
	$(MYSQL_UNZIP) $(DL_DIR)/$(MYSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(MYSQL) $(MYSQL_DIR)
	(cd $(MYSQL_DIR) && \
   ./configure \
	   --without-debug \
	   --without-extra-tools \
	   --without-docs \
	   --without-bench \
		 --without-isam \
	   --without-innodb \
	   --without-geometry );
	sed -e 's/"gcc"/$(TARGET_CC)/g' $(MYSQL_DIR)/libtool > $(MYSQL_DIR)/libtool.new
	sed -e 's/"g++"/$(TARGET_CXX)/g' $(MYSQL_DIR)/libtool.new > $(MYSQL_DIR)/libtool
	patch -d $(MYSQL_DIR) -p0 <$(MYSQL_PATCH)

	touch $(MYSQL_DIR)/.configured

mysql-unpack: $(MYSQL_DIR)/.configured

$(MYSQL_DIR)/mysql: $(MYSQL_DIR)/.configured
	make -C $(MYSQL_DIR) CXX=$(TARGET_CXX) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) AUTOMAKE="$(SHELL) $(MYSQL_DIR)/missing --run automake" CFLAGS=$(MYSQL_CFLAGS) CPPFLAGS=$(MYSQL_CFLAGS) LDFLAGS=$(MYSQSL_LDFLAGS) CXXLDFLAGS=$(MYSQL_LDFLAGS) 

mysql: $(MYSQL_DIR)/mysql

$(MYSQL_IPK): $(MYSQL_DIR)/dhcpd
	install -d $(MYSQL_IPK_DIR)/CONTROL
	install -d $(MYSQL_IPK_DIR)/opt/sbin $(MYSQL_IPK_DIR)/opt/etc/init.d
	$(STRIP_COMMAND) $(MYSQL_DIR)/`find  builds/dhcp -name work* | cut -d/ -f3`/server/dhcpd -o $(MYSQL_IPK_DIR)/opt/sbin/dhcpd
	install -m 755 $(SOURCE_DIR)/dhcp.rc $(MYSQL_IPK_DIR)/opt/etc/init.d/S56dhcp
	install -m 644 $(SOURCE_DIR)/dhcp.control  $(MYSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MYSQL_IPK_DIR)

mysql-ipk: $(MYSQL_IPK)

mysql-clean:
	-make -C $(MYSQL_DIR) clean

mysql-dirclean:
	rm -rf $(MYSQL_DIR) $(MYSQL_IPK_DIR) $(MYSQL_IPK)
