# This Makefile has been generated from the Configure script.
# Shareware copyright 1993, by Sam Lantinga


CC = gcc
PTYCHAR=\"abcdepqrstuvwxyz\"
HEXDIGIT=\"0123456789abcdef\"
PTYOPTS = -DPTYCHAR=$(PTYCHAR) -DHEXDIGIT=$(HEXDIGIT)

CFLAGS =  -O2 -DTERMCAP -DHAVE_UTHOST -DHAVE_TERMIO_H -DHAVE_UNISTD_H -DNEED_SELECT_H -DHAVE_WAIT4 -DSHELL=\"/bin/sh\" $(PTYOPTS)
LIBS =  -ltermcap -lnsl
OBJS = splitvt.o misc.o utmp.o vt100.o videomem.o terminal.o vttest.o vtmouse.o \
       parserc.o lock.o cut-paste.o

prefix=/opt

splitvt: $(OBJS)
	$(CC) -s -o $@ $(OBJS) $(LDFLAGS) $(LIBS)

clean: 
	rm -f *.o core 

distclean: clean
	rm -f splitvt Makefile

install: install-man
	install -d $(DESTDIR)$(prefix)/bin
	install splitvt $(DESTDIR)$(prefix)/bin/splitvt
	install examples/xsplitvt $(DESTDIR)$(prefix)/bin/xsplitvt

install-man:
	install -d $(DESTDIR)$(prefix)/share/man/man1
	cp splitvt.man $(DESTDIR)$(prefix)/share/man/man1/splitvt.1
