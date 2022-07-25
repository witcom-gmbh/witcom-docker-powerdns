FROM alpine:3.15
LABEL maintainer="Carsten Buchberger <c.buchberger@witcom.de>"

ARG PDNS_AUTH_RELEASE

ENV POWERDNS_VERSION=$PDNS_AUTH_RELEASE \
    PDNS_socket_dir=/var/run \
    PDNS_master=yes \
    PDNS_daemon=no \ 
    PDNS_guardian=yes \
    PDNS_setuid=pdns \
    PDNS_setgid=0 \
    PDNS_launch=gmysql

RUN apk --update add bash libpq sqlite-libs libstdc++ libgcc mariadb-client mariadb-connector-c lua-dev curl-dev py3-pip python3 libcap && \
    apk add --virtual build-deps \
      g++ make mariadb-dev postgresql-dev sqlite-dev curl boost-dev mariadb-connector-c-dev && \
    curl -sSL https://downloads.powerdns.com/releases/pdns-$POWERDNS_VERSION.tar.bz2 | tar xj -C /tmp && \
    cd /tmp/pdns-$POWERDNS_VERSION && \
    ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns \
      --with-modules="bind gmysql gpgsql gsqlite3" && \
    make && make install-strip && cd / && \
    mkdir -p /etc/pdns/conf.d && \
    addgroup -S pdns 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns 2>/dev/null && \
    chown -Rf pdns:0 /etc/pdns && \
    chgrp -R 0 /etc/pdns && \
    chmod -R g+rwX /etc/pdns && \
    chgrp -R 0 /var/run && \
    chmod -R g+rwX /var/run && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/pdns_server && \
    cp /usr/lib/libboost_program_options.so* /tmp && \
    apk del --purge build-deps && \
    apk add boost-libs && \
    mv /tmp/lib* /usr/lib/ && \
    rm -rf /tmp/pdns-$POWERDNS_VERSION /var/cache/apk/*

RUN pip3 install --no-cache-dir envtpl

COPY pdns.conf.tpl /
ADD entrypoint.sh /

EXPOSE 53/tcp 53/udp 8081/tcp

USER pdns

ENTRYPOINT ["/entrypoint.sh"]
