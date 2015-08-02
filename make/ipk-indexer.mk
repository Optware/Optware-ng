#############################################################
#
# ipk-indexer for use on the host system
#
#############################################################

#_______________IPK_INDEXER_DESCRIPTION_____________________#
# ipk files indexer scripts developed by the Entware team.
# We use these to build index.html
# Remember to drop 'css' and 'js' dirs from usr/share/nginx/entware
# on the ipk-indexer archive to the root of your server
#___________________________________________________________#

IPK_INDEXER_SOURCE=http://entware.wl500g.info/sources/indexer.tgz
IPK_INDEXER_SOURCE_FILE=ipk-indexer.tgz


#
# IPK_INDEXER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IPK_INDEXER_PATCHES=

.PHONY: ipk-indexer-source ipk-indexer ipk-indexer-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPK_INDEXER_SOURCE_FILE):
	$(WGET) -O $@ $(IPK_INDEXER_SOURCE) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ipk-indexer-source: $(DL_DIR)/$(IPK_INDEXER_SOURCE_FILE)

#
# This builds the actual binary.
#
$(HOST_STAGING_DIR)/bin/ipk_indexer_html_sorted.sh: $(DL_DIR)/$(IPK_INDEXER_SOURCE_FILE)
	mkdir -p $(HOST_STAGING_DIR)/bin
	tar -C $(HOST_STAGING_DIR)/bin -xzvf $(DL_DIR)/$(IPK_INDEXER_SOURCE_FILE) --wildcards --touch --strip-components=3 usr/local/bin/*

#
# This is the build convenience target.
#
ipk-indexer: $(HOST_STAGING_DIR)/bin/ipk_indexer_html_sorted.sh

ipk-indexer-dirclean:
	rm -rf $(HOST_STAGING_DIR)/bin/ipk_indexer_*.sh


IPK_INDEXER_MAKE_HTML_INDEX := $(HOST_STAGING_DIR)/bin/ipk_indexer_html_sorted.sh > Packages.html

