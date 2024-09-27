# syntax = docker/dockerfile:1.3-labs
FROM archlinux

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
ARG COSMOS="/cosmos"
ARG COSMOCC_ARGS="-I${COSMOS}/include -L${COSMOS}/lib"

RUN mkdir -p "${COSMOS}/lib" "${COSMOS}/include"
RUN ln -s "${COSMOCC}/bin/ape-x86_64.elf" "/usr/bin/ape"

# This ENV will persist in the final image:
ENV PATH="${PATH}:${COSMOCC}/bin"
ENV CC="cosmocc ${COSMOCC_ARGS}"
ENV CXX="cosmoc++ ${COSMOCC_ARGS}"
ENV INSTALL="cosmoinstall"
ENV AR="cosmoar"
