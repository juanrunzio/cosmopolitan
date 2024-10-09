# syntax = docker/dockerfile:1.3-labs
FROM archlinux AS buildtime

RUN --mount=type=cache,target=/var/cache/pacman/pkg,sharing=locked \
    pacman -Sy --noconfirm \
        base-devel \
        qemu-base

# environment variables
ENV COSMO="/cosmocc"
ENV COSMOS="/opt/cosmos/x86_64"
ENV PATH="${COSMO}/bin:${PATH}"
ENV AS="x86_64-unknown-cosmo-as"
ENV CC="x86_64-unknown-cosmo-cc -L${COSMOS}/lib"
ENV CXX="x86_64-unknown-cosmo-c++ -L${COSMOS}/lib"
ENV CPPFLAGS="-I${COSMOS}/include"
ENV AR="x86_64-unknown-cosmo-ar"
ENV STRIP="x86_64-unknown-cosmo-strip"
ENV INSTALL="x86_64-unknown-cosmo-install"
ENV OBJCOPY="x86_64-unknown-cosmo-objcopy"
ENV OBJDUMP="x86_64-unknown-cosmo-objdump"
ENV ADDR2LINE="x86_64-unknown-cosmo-addr2line"
ENV PKG_CONFIG="pkg-config --with-path=${COSMOS}/lib/pkgconfig"
ENV COSMOPOLITAN_DISABLE_ZIPOS=1

RUN rm /usr/bin/make \
 && ln -s /cosmocc/bin/make /usr/bin/make

RUN ln -s /cosmocc/bin/ape-x86_64.elf /usr/bin/ape
