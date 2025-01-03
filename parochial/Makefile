
COSMOS = /opt/cosmos/x86_64
BUILDTIME_IMG = 'buildtime:latest'

#	DOCKER_CC = x86_64-unknown-cosmo-cc
#	DOCKER_CXX = x86_64-unknown-cosmo-c++
#	DOCKER_AR = x86_64-unknown-cosmo-ar
#	DOCKER_INSTALL = /cosmocc/bin/x86_64-unknown-cosmo-install

DOCKER_CC = cosmocc
DOCKER_CXX = cosmoc++
DOCKER_AR = cosmoar
DOCKER_INSTALL = /cosmocc/bin/cosmoinstall

.PHONY: help clean deepclean

# La regla deepclean se reserva para cosas que
# provocarían mucho tráfico de red,
# mientras que "clean" es para cosas locales.
# Convención inventada por mi hoy.

BANNER_CMD = banner
# BANNER_CMD = echo


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
UNPATCHED_DIR = nethack
NH_CFG_PATCH = nethack-config.patch

${NH_CFG_PATCH}: nethack.tar.gz sediento.sh
	rm -rf nethack_patched ${UNPATCHED_DIR}
	tar xzf $<
	mv NetHack-3.6.7 nethack_patched
	cp -r nethack_patched ${UNPATCHED_DIR}
	sh sediento.sh nethack_patched ${COSMOS}
	diff -ruN ${UNPATCHED_DIR} nethack_patched > $@ || true # "|| true" es necesario porque diff devuelve rc!=0 cuando hay diferencias
	rm -rf nethack_patched ${UNPATCHED_DIR}
clean::
	rm -f ${NH_CFG_PATCH}
	rm -rf nethack_patched ${UNPATCHED_DIR}
###

###
.patched_nethack: ${NH_CFG_PATCH} perm.patch nethack.tar.gz
	rm -rf nethack
	tar xzf nethack.tar.gz
	mv NetHack-3.6.7 nethack
	patch -p0 < ${NH_CFG_PATCH}
	patch -p0 < perm.patch
	touch $@
clean::
	rm -rf nethack .patched_nethack
###

###
.create_zip_opt:
	rm -rf opt/
	mkdir -p opt/cosmos/x86_64
	rm -rf zip/
	mkdir zip/
	touch $@
clean::
	rm -rf opt/
	rm -rf zip/
	rm .create_zip_opt
###


# TODO: aprender a usar landlock-make en vez de docker
DOCKER_RUN = docker run \
				--user=$(shell id --user):$(shell id --group) \
				--rm \
				-e CC=$(DOCKER_CC) \
				-e CXX=$(DOCKER_CXX) \
				-e AR=$(DOCKER_AR) \
				-e INSTALL=$(DOCKER_INSTALL) \
				-v ./ncurses:/ncurses \
				-v ./cosmocc:/cosmocc \
				-v ./zip:/zip \
				-v ./opt:/opt \
				-v /tmp:/tmp \
				-e TMPDIR=/tmp

###
# las dependencias luego del "|" no provocan rebuildeo del target si son la única que cambió
.configure_ncurses: .docker_buildtime_img cosmocc/ ncurses/ .create_zip_opt
	$(BANNER_CMD) $@
	sleep 1
	$(DOCKER_RUN) \
	   	-e CFLAGS="-Os -D_XOPEN_SOURCE_EXTENDED -D__COSMOPOLITAN__" \
	   	-w /ncurses \
		${BUILDTIME_IMG} \
			./configure \
				--without-libtool --without-shared \
				--without-manpages --without-tests --without-tack \
				--without-ada --without-cxx --without-cxx-binding \
				--with-termlib --with-ticlib \
				--without-dlsym --without-pcre2 --without-sysmouse \
				--with-curses-h --disable-stripping --enable-widec \
				--disable-lib-suffixes \
				--prefix=${COSMOS} \
				--sysconfdir=/zip --datarootdir=/zip/usr/share \
				#--host=x86_64-pc-linux-musl --build=x86_64-pc-linux-musl
	touch $@
clean::
	rm -f .configure_ncurses
###

###
.build_ncurses: .configure_ncurses
	$(BANNER_CMD) $@
	sleep 1
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
.install_ncurses: .build_ncurses
	$(BANNER_CMD) $@
	sleep 1
	$(DOCKER_RUN) \
	   	-w /ncurses \
		${BUILDTIME_IMG} \
			ape make INSTALL=$(DOCKER_INSTALL) install
	touch $@
clean::
	rm -f .install_ncurses
###

###
.setup_nethack: .install_ncurses .patched_nethack
	$(BANNER_CMD) $@
	sleep 1
	$(DOCKER_RUN) \
		-v ./nethack:/nethack \
		-w /nethack \
		${BUILDTIME_IMG} \
			sh sys/unix/setup.sh sys/unix/hints/linux
	touch $@
clean::
	rm -f .setup_nethack
###

###
.build_nethack: .setup_nethack
	$(BANNER_CMD) $@
	sleep 1
	$(DOCKER_RUN) \
		-v ./nethack:/nethack \
		-w /nethack \
		${BUILDTIME_IMG} \
			ape make -j8
	ln -s nethack/src/nethack nh.zip
	pushd zip; zip ../nh.zip -r usr/share/terminfo
	rm -f nh.zip
	touch $@
clean::
	rm -f .build_nethack
###

NH_DIR = opt/games/lib/nethackdir
###
.install_nethack: .build_nethack
	$(BANNER_CMD) $@
	sleep 1
	mkdir -p zip/cfg
	$(DOCKER_RUN) \
		-v ./nethack:/nethack \
		-w /nethack \
		${BUILDTIME_IMG} \
			ape make -j1 PREFIX=/opt install # -j mayor que 1 falla
	ln -s ${NH_DIR}/nethack nh.zip
	zip nh.zip ${NH_DIR}/nhdat -j
	pushd zip; zip ../nh.zip cfg/sysconf
	rm -f nh.zip
	touch $@
clean::
	rm -f nh.zip
	rm -f .install_nethack
	###

grafo:
	# requiere make2graph, dot y feh
	make -nd .install_nethack | make2graph | dot -Tpng | feh -
