
COSMOS=/opt/cosmos/x86_64 # FIXME: poner en un lugar mejor

BUILDTIME_IMG = 'buildtime:latest'

cosmocc.zip:
	wget -qO $@ https://cosmo.zip/pub/cosmocc/cosmocc-3.9.2.zip
	# TODO: chequear hash

ncurses-6.4.tar.gz:
	wget https://ftp.gnu.org/gnu/ncurses/$@

buildtime_img: Dockerfile
	docker buildx build -t ${BUILDTIME_IMG} .
	touch $@ # FIXME: pensar mejor

ncurses-minimal.patch:
	wget -qO $@ https://raw.githubusercontent.com/ahgamut/superconfigure/refs/heads/main/lib/ncurses/minimal.diff

configure_ncurses: ncurses-6.4.tar.gz ncurses-minimal.patch buildtime_img cosmocc.zip
	# FIXME: mejorar el manejo de estos directorios
	rm -rf ncurses-6.4
	tar xzf $<
	patch -p0 < ncurses-minimal.patch
	rm -rf cosmocc
	mkdir -p cosmocc
	unzip -d cosmocc cosmocc.zip
	rm -rf zip
	mkdir zip
	rm -rf opt
	mkdir -p opt/cosmos/x86_64
	rm -rf ape
	mkdir ape
	docker run \
		--user=$(shell id --user):$(shell id --group) \
		--rm \
		-v ./ncurses-6.4:/ncurses \
	   	-w /ncurses \
		-v ./zip:/zip \
		-v ./cosmocc:/cosmocc \
		-v ./opt:/opt \
		-v ./ape:/ape \
	   	-e CFLAGS="-Os -D_XOPEN_SOURCE_EXTENDED -D__COSMOPOLITAN__" \
		-e TMPDIR="/ape" \
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
	# exit 1
	touch $@

build_ncurses: configure_ncurses
	docker run \
		--user=$(shell id --user):$(shell id --group) \
		--rm \
		-v ./ncurses-6.4:/ncurses \
	   	-w /ncurses \
		-v ./zip:/zip \
		-v ./cosmocc:/cosmocc \
		-v ./opt:/opt \
		-v ./ape:/ape \
		-e TMPDIR="/ape" \
		${BUILDTIME_IMG} \
			/cosmocc/bin/ape-x86_64.elf make -j4 # FIXME: es correcto el uso de ape?
	touch $@

install_ncurses: build_ncurses
	docker run \
		--user=$(shell id --user):$(shell id --group) \
		--rm \
		-v ./ncurses-6.4:/ncurses \
	   	-w /ncurses \
		-v ./zip:/zip \
		-v ./cosmocc:/cosmocc \
		-v ./opt:/opt \
		-v ./ape:/ape \
		-e TMPDIR="/ape" \
		${BUILDTIME_IMG} \
			/cosmocc/bin/ape-x86_64.elf make INSTALL=install install

nethack.tgz:
	wget -O $@ "https://www.nethack.org/download/3.6.7/nethack-367-src.tgz"

build_nethack: nethack.tgz
	rm -rf NetHack-3.6.7
	tar xzf $<
	pushd "NetHack-3.6.7/sys/unix";	sh setup.sh hints/linux; popd # minimal?
	docker run \
		--user=$(shell id --user):$(shell id --group) \
		--rm \
		-v ./NetHack-3.6.7:/nethack \
		-w /nethack \
		-v ./zip:/zip \
		-v ./cosmocc:/cosmocc \
		-v ./opt:/opt \
		-v ./ape:/ape \
		-e TMPDIR="/ape" \
		${BUILDTIME_IMG} \
			/cosmocc/bin/ape-x86_64.elf make -j4 # FIXME: es correcto el uso de ape?


.PHONY = help
