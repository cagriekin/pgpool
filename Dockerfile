FROM debian:trixie AS builder

ARG PGPOOL_VERSION
RUN test -n "$PGPOOL_VERSION" || (echo "PGPOOL_VERSION build arg is required" && exit 1)

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y hostname && \
    apt-get install -y \
    wget \
    build-essential \
    libpq-dev \
    postgresql-server-dev-all \
    libssl-dev \
    libmemcached-dev \
    libpam0g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN wget "https://www.pgpool.net/mediawiki/download.php?f=pgpool-II-${PGPOOL_VERSION}.tar.gz" -O pgpool.tar.gz && \
    tar -xzf pgpool.tar.gz && \
    rm pgpool.tar.gz

WORKDIR /build/pgpool-II-${PGPOOL_VERSION}
RUN ./configure \
    --prefix=/usr/local \
    --with-openssl \
    --with-pam \
    && make && make install

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local /usr/local

RUN apt-get update && \
    apt-get install -y hostname passwd && \
    apt-get install -y \
    libpq5 \
    libssl3 \
    libmemcached11 \
    libpam0g \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r -g 999 pgpool \
    && useradd -r -u 999 -g pgpool pgpool

USER pgpool

EXPOSE 9999

CMD ["pgpool", "-n"]
