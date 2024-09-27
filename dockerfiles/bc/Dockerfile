# syntax = docker/dockerfile:1.3-labs
FROM archlinux AS buildtime

RUN --mount=type=cache,target=/var/cache/pacman/pkg,sharing=locked \
    pacman -Sy --noconfirm \
        base-devel \
        wget \
        unzip

RUN mkdir /cosmocc \
 && cd /cosmocc \
 && wget https://cosmo.zip/pub/cosmocc/cosmocc.zip \
 && unzip cosmocc.zip \
 && rm -f cosmocc.zip

# This ARG will not persist in the final image:
ARG COSMOCC="/cosmocc"
ARG COSMOARGS="-I${COSMOCC}/include -L${COSMOCC}/lib"

# This ENV will persist in the final image:
ENV PATH="${PATH}:${COSMOCC}/bin"
ENV CC="cosmocc ${COSMOARGS}"
ENV CXX="cosmoc++ ${COSMOARGS}"
ENV INSTALL="cosmoinstall"
ENV AR="cosmoar"

RUN ln -s "${COSMOCC}/bin/ape-x86_64.elf" "/usr/bin/ape"

WORKDIR /repo
