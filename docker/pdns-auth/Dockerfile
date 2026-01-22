ARG PDNS_AUTH_RELEASE="5.0.2"
ARG PDNS_AUTH_IMAGE=powerdns/pdns-auth-50

FROM $PDNS_AUTH_IMAGE:$PDNS_AUTH_RELEASE

ENV POWERDNS_VERSION=$PDNS_AUTH_RELEASE \
    ENVTPL_VERSION=2.0.6 \
    PDNS_socket_dir=/run/pdns \
    PDNS_primary=yes \
    # PDNS_daemon=no \ 
    # PDNS_guardian=yes \
    PDNS_setuid=pdns \
    PDNS_setgid=0 \
    PDNS_launch=gpgsql

USER root
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN ARCH=$(dpkg --print-architecture) && \
    curl -k -L "https://github.com/chenrui333/envtpl/releases/download/v${ENVTPL_VERSION}/envtpl_${ENVTPL_VERSION}_Linux_x86_64.tar.gz" \
    | tar -xz -C /usr/local/bin envtpl

# Add proper permissions for non-root containers running arbitrary UIDs
RUN chown -Rf pdns:0 /etc/powerdns && chgrp -R 0 /etc/powerdns && chmod -R g+rwX /etc/powerdns
RUN mkdir -p /run/pdns && chown -Rf pdns:0 /run/pdns && chgrp -R 0 /run/pdns && chmod -R g+rwX /run/pdns
RUN setcap 'cap_net_bind_service=+ep' /usr/local/sbin/pdns_server

USER pdns

COPY pdns.conf.tpl /
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
