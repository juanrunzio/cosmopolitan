#!/bin/sh

set -ex

NH_SRC=$1
COSMOS=$2

sed -e 's|^/\* \(#define LINUX\) \*/|\1|' \
	-e 's|^/\* \(#define TIMED_DELAY\) \*/|\1|' \
	-i $NH_SRC/include/unixconf.h

sed -e "s|CFLAGS=-g -O -I../include -DNOTPARMDECL|CFLAGS+=-Os -D_XOPEN_SOURCE_EXTENDED -D__COSMOPOLITAN__ -I../include -I${COSMOS}/include -I${COSMOS}/include/ncurses -DNOTPARMDECL|" \
	-e '/^SHELLDIR/ s|/games|/usr/bin|' \
	-e '/^HACKDIR/a SYSCONFDIR=/zip/cfg'\
	-e '/-DTIMED_DELAY/d' \
	-e 's|\(DSYSCF_FILE=\)\\"[^"]*\\"|\1\\"/zip/cfg/sysconf\\"|' \
	-e 's/LFLAGS=-rdynamic/LFLAGS=$$(LDFLAGS) -rdynamic/' \
	-e '/^POSTINSTALL/ s|INSTDIR|SYSCONFDIR|g'\
	-i $NH_SRC/sys/unix/hints/linux
	#-e '/^HACKDIR/ s|/games/lib/\$$(GAME)dir|/playground/nethack|' \
	#-e 's|\(DHACKDIR=\)\\"[^"]*\\"|\1\\"opt/playground/nethack/\\"|' \
	#-e '/CFLAGS+=-DHACKDIR/a\CFLAGS+=-DVAR_PLAYGROUND=\\\"'$(pwd)'/opt/variables/\\\"' \
	#-e '/^VARDIRPERM/ s|0755|0775|' \
	#-e '/^VARFILEPERM/ s|0600|0664|' \
	#-e '/^GAMEPERM/ s|0755|02755|' \
	#-e '/^VARDIR *=/ s|=[ ]*.*|= /opt/variables/|' \

sed '/^#define __warn_unused_result__/ s,/\*empty\*/,__unused__,' \
	-i $NH_SRC/include/tradstdc.h

#   sed -e 's|^#GAMEUID.*|GAMEUID = root|' \
#   	-e 's|^#GAMEGRP.*|GAMEGRP = games|' \
#   	-e '/^FILEPERM\s*=/ s|0644|0664|' \
#   	-e '/^DIRPERM\s*=/ s|0755|0775|' \
#   	-i $NH_SRC/sys/unix/Makefile.top

sed -e '/^#define DLBFILE/ s|nhdat|/zip/nhdat|' \
	-i $NH_SRC/include/dlb.h

sed -e '/#define CHDIR/ d' \
	-i $NH_SRC/include/config.h

#sed -e "/^MANDIR\s*=/s|/usr/man/man6|$$pkgdir/usr/share/man/man6|" \
#	-i $NH_SRC/sys/unix/Makefile.doc

