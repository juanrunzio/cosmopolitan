
COSMOS = /opt/cosmos/x86_64
BUILDTIME_IMG = 'buildtime:latest'

.PHONY: help clean deepclean

# La regla deepclean se reserva para cosas que
# provocarían mucho tráfico de red,
# mientras que "clean" es para cosas locales.
# Convención inventada por mi hoy.

###
cosmocc.zip:
	wget -qO $@ https://cosmo.zip/pub/cosmocc/cosmocc-3.9.2.zip
	# TODO: chequear hash
# "doble :" agrega comandos a la regla
deepclean::
	rm -f cosmocc.zip
###

###
cosmocc/: cosmocc.zip
	rm -rf $@
	mkdir $@
	unzip -d $@ $<
clean::
	rm -rf cosmocc/
###

###
ncurses.tar.gz:
	wget -qO $@ https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz
deepclean::
	rm -f ncurses.tar.gz
###

###
ncurses/: ncurses.tar.gz ncurses-minimal.patch
	rm -rf $@
	tar xzf $<
	patch -p0 < ncurses-minimal.patch
	mv ncurses-6.4 ncurses
clean::
	rm -rf ncurses/
###
.docker_buildtime_img: Dockerfile
	docker buildx build -t ${BUILDTIME_IMG} .
	touch $@
deepclean::
	rm -f .docker_buildtime_img
###

###
ncurses-minimal.patch:
	wget -qO $@ https://raw.githubusercontent.com/ahgamut/superconfigure/refs/heads/main/lib/ncurses/minimal.diff
deepclean::
	rm -f ncurses-minimal.patch
###

###
nethack.tar.gz:
	wget -qO $@ "https://www.nethack.org/download/3.6.7/nethack-367-src.tgz"
deepclean::
	rm -f nethack.tar.gz
###

###
nethack/: nethack.tar.gz
	rm -rf nethack
	tar xzf $<
	mv NetHack-3.6.7 nethack
	sed -e 's|^/\* \(#define LINUX\) \*/|\1|' \
		-e 's|^/\* \(#define TIMED_DELAY\) \*/|\1|' \
		-i nethack/include/unixconf.h
	@# $(GAME) tiene que escapearse con doble $$
	sed -e 's|CFLAGS=-g -O -I../include -DNOTPARMDECL|CFLAGS+=-Os -D_XOPEN_SOURCE_EXTENDED -D__COSMOPOLITAN__ -I../include -I${COSMOS}/include/ncurses -DNOTPARMDECL|' \
		-e '/^HACKDIR/ s|/games/lib/\$$(GAME)dir|/var/games/nethack/|' \
		-e '/^SHELLDIR/ s|/games|/usr/bin|' \
		-e '/^VARDIRPERM/ s|0755|0775|' \
		-e '/^VARFILEPERM/ s|0600|0664|' \
		-e '/^GAMEPERM/ s|0755|02755|' \
		-e '/-DTIMED_DELAY/d' \
		-e 's|\(DSYSCF_FILE=\)\\"[^"]*\\"|\1\\"/var/games/nethack/sysconf\\"|' \
		-e 's/LFLAGS=-rdynamic/LFLAGS=$$(LDFLAGS) -rdynamic/' \
		-e 's|\(DHACKDIR=\)\\"[^"]*\\"|\1\\"/var/games/nethack/\\"|' \
		-i nethack/sys/unix/hints/linux
	sed '/^#define __warn_unused_result__/ s,/\*empty\*/,__unused__,' \
		-i nethack/include/tradstdc.h
	sed -e 's|^#GAMEUID.*|GAMEUID = root|' \
		-e 's|^#GAMEGRP.*|GAMEGRP = games|' \
		-e '/^FILEPERM\s*=/ s|0644|0664|' \
		-e '/^DIRPERM\s*=/ s|0755|0775|' \
		-i nethack/sys/unix/Makefile.top
	#sed -e "/^MANDIR\s*=/s|/usr/man/man6|$$pkgdir/usr/share/man/man6|" \
	#	-i sys/unix/Makefile.doc

clean::
	rm -rf nethack/
###

###
zip/:
	rm -rf $@
	mkdir $@
clean::
	rm -rf zip/
###

###
opt/:
	rm -rf $@
	mkdir -p $@/cosmos/x86_64
clean::
	rm -rf opt/
###

# TODO: aprender a usar landlock-make en vez de docker
DOCKER_RUN = docker run \
				--user=$(shell id --user):$(shell id --group) \
				--rm \
				-v ./ncurses:/ncurses \
				-v ./zip:/zip \
				-v ./cosmocc:/cosmocc \
				-v ./opt:/opt \
				-v /tmp:/tmp \
				-e TMPDIR=/tmp


###
# las dependencias luego del "|" no provocan rebuildeo del target si son la única que cambió
.configure_ncurses: .docker_buildtime_img | cosmocc/ ncurses/ zip/ opt/
	$(DOCKER_RUN) \
	   	-e CFLAGS="-Os -D_XOPEN_SOURCE_EXTENDED -D__COSMOPOLITAN__" \
	   	-w /ncurses \
		${BUILDTIME_IMG} \
			./configure \
				--without-libtool --without-shared \
				--without-manpages --without-tests --without-tack \
				--without-ada --without-cxx --without-cxx-binding \
				--without-tests --with-termlib --with-ticlib \
				--without-dlsym --without-pcre2 --without-sysmouse \
				--with-curses-h --disable-stripping --enable-widec \
				--disable-lib-suffixes \
				--prefix=${COSMOS} \
				--sysconfdir=/zip --datarootdir=/zip/usr/share \
				--host=x86_64-pc-linux-musl --build=x86_64-pc-linux-musl
	touch $@
clean::
	rm -f .configure_ncurses
###

###
.build_ncurses: .configure_ncurses | cosmocc/ ncurses/ zip/ opt/
	$(DOCKER_RUN) \
	   	-w /ncurses \
		${BUILDTIME_IMG} \
			ape make -j8
	touch $@
clean::
	rm -f .build_ncurses
###

# TODO: seguramente algunos docker run requieren COSMOPOLITAN_DISABLE_ZIPOS=0

###
.install_ncurses: .build_ncurses | cosmocc/ ncurses/ zip/ opt/
	$(DOCKER_RUN) \
	   	-w /ncurses \
		${BUILDTIME_IMG} \
			ape make INSTALL=install install
	touch $@
clean::
	rm -f .install_ncurses
###

###
.setup_nethack: .install_ncurses nethack/
	$(DOCKER_RUN) \
		-v ./nethack:/nethack \
		-w /nethack \
		${BUILDTIME_IMG} \
			sh sys/unix/setup.sh sys/unix/hints/linux
clean::
	rm -f .setup_nethack
###

###
.build_nethack: .setup_nethack
	$(DOCKER_RUN) \
		-v ./nethack:/nethack \
		-w /nethack \
		${BUILDTIME_IMG} \
			ape make -j8
	ln -s nethack/src/nethack nh.zip
	pushd zip; zip ../nh.zip -r usr/share/terminfo
	rm -f nh.zip
clean::
	rm -f .build_nethack
###

###
.install_nethack: .build_nethack
	$(DOCKER_RUN) \
		-v ./nethack:/nethack \
		-w /nethack \
		${BUILDTIME_IMG} \
			ape make -j1 PREFIX=/opt install # -j mayor que 1 falla
clean::
	rm -f .install_nethack
###
