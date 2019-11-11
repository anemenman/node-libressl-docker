ARG LIBRE_SSL_VER=2.9.2

FROM spritsail/debian-builder as builder

ARG LIBRE_SSL_VER
ARG PREFIX=/output

WORKDIR $PREFIX

RUN mkdir -p usr/bin usr/lib etc/ssl/certs

WORKDIR /tmp/libressl

# Build and install LibreSSL
RUN curl -sSL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRE_SSL_VER}.tar.gz \
        | tar xz --strip-components=1 && \
    ./configure \
        --prefix= \
        --exec-prefix=/usr && \
    make -j "$(nproc)" && \
    make DESTDIR="$(pwd)/build" install

RUN cp -d build/usr/lib/*.so* "${PREFIX}/usr/lib" && \
    cp -d build/usr/bin/openssl "${PREFIX}/usr/bin" && \
    mkdir -p "${PREFIX}/etc/ssl" && \
    cp -d build/etc/ssl/openssl.cnf "${PREFIX}/etc/ssl" && \
    cd "${PREFIX}/usr/lib" && \
    ln -s libssl.so libssl.so.1.0.0 && \
    ln -s libssl.so libssl.so.1.0 && \
    ln -s libtls.so libtls.so.1.0.0 && \
    ln -s libtls.so libtls.so.1.0 && \
    ln -s libcrypto.so libcrypto.so.1.0.0 && \
    ln -s libcrypto.so libcrypto.so.1.0

RUN update-ca-certificates && \
    cp /etc/ssl/certs/ca-certificates.crt "${PREFIX}/etc/ssl/certs"



FROM library/node:slim

ARG LIBRE_SSL_VER

LABEL maintainer="A A" \
      org.label-schema.name="Node-slim with LibreSSL" \
      org.label-schema.description="Node-slim, GNU libc and LibreSSL built from source" \
      org.label-schema.version=${LIBRE_SSL_VER} \
      io.spritsail.version.libressl=${LIBRE_SSL_VER}

COPY --from=builder /output/ /

COPY . /app

# Add node app here
# RUN cd /app \
#   && npm install && npm run-script build
#
# WORKDIR /app/dist
#
# CMD node bot.js

