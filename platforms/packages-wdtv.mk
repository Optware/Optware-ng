PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base asterisk16 asterisk16-addons cdrtools fcgi ficy fish \
	fuppes ghostscript gnu-smalltalk gtmess gtk gutenprint \
	ice iptraf launchtool ldconfig ltrace microdc2 moc \
	monotone mtr newsbeuter nfs-server nfs-utils pango pinentry \
	player puppy mod-python qemu rssh rtorrent \
	sm streamripper taged transcode uemacs vte \
	xauth xaw xchat xmu xt xterm lm-sensors \
	slimserver
